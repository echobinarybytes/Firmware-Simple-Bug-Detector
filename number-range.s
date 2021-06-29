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
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movl	$15, -4(%rbp)
	cmpl	$0, -4(%rbp)
	jle	.L3
	call	print
	jmp	.L4
.L3:
	cmpl	$5, -4(%rbp)
	jle	.L5
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	jmp	.L4
.L5:
	cmpl	$10, -4(%rbp)
	jle	.L6
	leaq	.LC2(%rip), %rdi
	call	puts@PLT
	jmp	.L4
.L6:
	cmpl	$15, -4(%rbp)
	jle	.L7
	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	jmp	.L4
.L7:
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
.L4:
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
	.section	.note.GNU-stack,"",@progbits
