  __afl_maybe_log:
    lahf
    seto %al
    /* 检查
    /* Check if SHM region is already mapped. */
    movl  __afl_area_ptr(%rip), %edx
    testl %edx, %edx
    je    __afl_setup
  /* 只有第一个区块会执行__afl_setup区块的代码 */
  __afl_store:
  /* 计算和存储到达此位置， */
    /* Calculate and store hit for the code location specified in ecx. There
       is a double-XOR way of doing this without tainting another register,
       and we use it on 64-bit systems; but it's slower for 32-bit ones. */
#ifndef COVERAGE_ONLY
    movl __afl_prev_loc, %edi
    xorl %ecx, %edi
    shrl $1, %ecx
    movl %ecx, __afl_prev_loc
#else
    movl %ecx, %edi
#endif /* ^!COVERAGE_ONLY */
#ifdef SKIP_COUNTS
    # %edi存储着SHM regin.
    orb  $1, (%edx, %edi, 1) # 置１表示该块被访问
#else
    incb (%edx, %edi, 1) # 加1表示该块又被访问
#endif /* ^SKIP_COUNTS */
  __afl_return:
    addb $127, %al
    sahf
    ret
  .align 8
  __afl_setup:
    /* Do not retry setup if we had previous failures. */
    cmpb $0, __afl_setup_failure
    jne  __afl_return
    /* Map SHM, jumping to __afl_setup_abort if something goes wrong.
       We do not save FPU/MMX/SSE registers here, but hopefully, nobody
       will notice this early in the game. */
    pushl %eax
    pushl %ecx
    pushl $.AFL_SHM_ENV
    call  getenv
    addl  $4, %esp
    testl %eax, %eax
    je    __afl_setup_abort
    pushl %eax
    call  atoi
    addl  $4, %esp
    pushl $0          /* shmat flags    */
    pushl $0          /* requested addr */
    pushl %eax        /* SHM ID         */
    call  shmat
    addl  $12, %esp
    cmpl $-1, %eax
    je   __afl_setup_abort
    /* Store the address of the SHM region. */
    movl %eax, __afl_area_ptr
    movl %eax, %edx
    popl %ecx
    popl %eax
  __afl_forkserver:
  
    /* Enter the fork server mode to avoid the overhead of execve() calls. */
  
    pushl %eax
    pushl %ecx
    pushl %edx
  
    /* Phone home and tell the parent that we're OK. (Note that signals with
       no SA_RESTART will mess it up). If this fails, assume that the fd is
       closed because we were execve()d from an instrumented binary, or because 
       the parent doesn't want to use the fork server. */
  
    pushl $4          /* length    */
    pushl $__afl_temp /* data      */
    pushl $ STRINGIFY((FORKSRV_FD + 1))   /* file desc */
    call  write
    addl  $12, %esp
  
    cmpl  $4, %eax
    jne   __afl_fork_resume
  
  __afl_fork_wait_loop:
  
    /* Wait for parent by reading from the pipe. Abort if read fails. */
  
    pushl $4          /* length    */
    pushl $__afl_temp /* data      */
    pushl $ STRINGIFY(FORKSRV_FD)         /* file desc */
    call  read
    addl  $12, %esp
  
    cmpl  $4, %eax
    jne   __afl_die
  
    /* Once woken up, create a clone of our process. This is an excellent use
       case for syscall(__NR_clone, 0, CLONE_PARENT), but glibc boneheadedly
       caches getpid() results and offers no way to update the value, breaking
       abort(), raise(), and a bunch of other things :-( */
  
    call fork
  
    cmpl $0, %eax
    jl   __afl_die
    je   __afl_fork_resume
  
    /* In parent process: write PID to pipe, then wait for child. */
  
    movl  %eax, __afl_fork_pid
  
    pushl $4              /* length    */
    pushl $__afl_fork_pid /* data      */
    pushl $ STRINGIFY((FORKSRV_FD + 1))       /* file desc */
    call  write
    addl  $12, %esp
  
    pushl $0             /* no flags  */
    pushl $__afl_temp    /* status    */
    pushl __afl_fork_pid /* PID       */
    call  waitpid
    addl  $12, %esp
  
    cmpl  $0, %eax
    jle   __afl_die
  
    /* Relay wait status to pipe, then loop back. */
  
    pushl $4          /* length    */
    pushl $__afl_temp /* data      */
    pushl $ STRINGIFY((FORKSRV_FD + 1))   /* file desc */
    call  write
    addl  $12, %esp
  
    jmp __afl_fork_wait_loop
  
  __afl_fork_resume:
  
    /* In child process: close fds, resume execution. */
  
    pushl $ STRINGIFY(FORKSRV_FD) 
    call  close
  
    pushl $ STRINGIFY((FORKSRV_FD + 1)) 
    call  close
  
    addl  $8, %esp
  
    popl %edx
    popl %ecx
    popl %eax
    jmp  __afl_store
  
  __afl_die:
  
    xorl %eax, %eax
    call _exit
  
  __afl_setup_abort:
  
    /* Record setup failure so that we don't keep calling
       shmget() / shmat() over and over again. */
  
    incb __afl_setup_failure
    popl %ecx
    popl %eax
    jmp __afl_return
  
  .AFL_VARS:
  
    .comm   __afl_area_ptr, 4, 32
    .comm   __afl_setup_failure, 1, 32
#ifndef COVERAGE_ONLY
    .comm   __afl_prev_loc, 4, 32
#endif /* !COVERAGE_ONLY */
    .comm   __afl_fork_pid, 4, 32
    .comm   __afl_temp, 4, 32
  
  .AFL_SHM_ENV:
    .asciz \ SHM_ENV_VAR \
  
  /* --- END --- */
  ;

/* The OpenBSD hack is due to lahf and sahf not being recognized by some
   versions of binutils: http://marc.info/?l=openbsd-cvs&m=141636589924400

   The Apple code is a bit different when calling libc functions because
   they are doing relocations differently from everybody else. We also need
   to work around the crash issue with .lcomm and the fact that they don't
   recognize .string. */

#ifdef __APPLE__
#  define CALL_L64(str)		call _ str 
#else
#  define CALL_L64(str)		call  str @PLT
#endif /* ^__APPLE__ */

