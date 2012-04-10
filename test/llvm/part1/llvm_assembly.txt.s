	.file	"llvm_assembly.txt"
	.text
	.globl	matvec
	.align	16, 0x90
	.type	matvec,@function
matvec:                                 # @matvec
.Ltmp0:
	.cfi_startproc
# BB#0:
	movq	%rdi, -8(%rsp)
	movq	%rsi, -16(%rsp)
	movq	%rdx, -24(%rsp)
	movl	%ecx, -28(%rsp)
	movl	$0, -32(%rsp)
	jmp	.LBB0_1
	.align	16, 0x90
.LBB0_4:                                #   in Loop: Header=BB0_3 Depth=2
	movslq	-32(%rsp), %rax
	movq	-8(%rsp), %rcx
	movq	(%rcx,%rax,8), %rdx
	movslq	-36(%rsp), %rcx
	movsd	(%rdx,%rcx,8), %xmm0
	movq	-16(%rsp), %rdx
	mulsd	(%rdx,%rcx,8), %xmm0
	movq	-24(%rsp), %rcx
	addsd	(%rcx,%rax,8), %xmm0
	movsd	%xmm0, (%rcx,%rax,8)
	incl	-36(%rsp)
.LBB0_3:                                #   Parent Loop BB0_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movl	-36(%rsp), %eax
	cmpl	-28(%rsp), %eax
	jl	.LBB0_4
# BB#5:                                 #   in Loop: Header=BB0_1 Depth=1
	incl	-32(%rsp)
.LBB0_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
	movl	-32(%rsp), %eax
	cmpl	-28(%rsp), %eax
	jge	.LBB0_6
# BB#2:                                 #   in Loop: Header=BB0_1 Depth=1
	movq	-24(%rsp), %rax
	movslq	-32(%rsp), %rcx
	movq	$0, (%rax,%rcx,8)
	movl	$0, -36(%rsp)
	jmp	.LBB0_3
.LBB0_6:
	movq	-24(%rsp), %rax
	ret
.Ltmp1:
	.size	matvec, .Ltmp1-matvec
.Ltmp2:
	.cfi_endproc
.Leh_func_end0:


	.section	".note.GNU-stack","",@progbits
