	.file	"number-range.c"
	.text
	.section	.rodata
.LC0:
	.string	"num is bigger than 0"
	.text
	.globl	print
	.type	print, @function
print:
.LFB0:
	.cfi_startproc

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x00004567, %rcx
call __afl_maybe_log
/* --- END --- */

	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	leaq	.LC0(%rip), %rdi
	call	puts@PLT
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	print, .-print
	.section	.rodata
.LC1:
	.string	"num is bigger than 5"
.LC2:
	.string	"num is bigger than 10"
.LC3:
	.string	"num is bigger than 15"
.LC4:
	.string	"num is bigger than 18"
	.text
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x000023c6, %rcx
call __afl_maybe_log
/* --- END --- */

	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$15, -4(%rbp)
	cmpl	$0, -4(%rbp)
	jle	.L3

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x00009869, %rcx
call __afl_maybe_log
/* --- END --- */

	call	print
	jmp	.L4
.L3:

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x00004873, %rcx
call __afl_maybe_log
/* --- END --- */

	cmpl	$5, -4(%rbp)
	jle	.L5

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x0000dc51, %rcx
call __afl_maybe_log
/* --- END --- */

	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	jmp	.L4
.L5:

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x00005cff, %rcx
call __afl_maybe_log
/* --- END --- */

	cmpl	$10, -4(%rbp)
	jle	.L6

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x0000944a, %rcx
call __afl_maybe_log
/* --- END --- */

	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	jmp	.L4
.L6:

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x000058ec, %rcx
call __afl_maybe_log
/* --- END --- */

	cmpl	$15, -4(%rbp)
	jle	.L7

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x00001f29, %rcx
call __afl_maybe_log
/* --- END --- */

	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	jmp	.L4
.L7:

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x00007ccd, %rcx
call __afl_maybe_log
/* --- END --- */

	leaq	.LC4(%rip), %rdi
	call	puts@PLT
.L4:

/* --- AFL TRAMPOLINE (64-BIT) --- */
movq $0x000058ba, %rcx
call __afl_maybe_log
/* --- END --- */

	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
/* --- AFL MAIN PAYLOAD (64-BIT) --- */
/* --- END --- */

