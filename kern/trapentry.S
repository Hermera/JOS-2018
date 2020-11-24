/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps



#define EC(name, num)\
	.data			;\
	    .long name		;\
	.text               ;\
	    .global name    ;\
	    .type name, @function       ;\
	.align 2                        ;\
name:\
    pushl $(num)                ;\
    jmp _alltraps


#define NOEC(name, num)\
	.data			;\
	    .long name		;\
	.text               ;\
	    .global name    ;\
	    .type name, @function       ;\
	.align 2                        ;\
name:\
    pushl $0                    ;\
    pushl $(num)                ;\
    jmp _alltraps


#define PAD()\
	.data			;\
	    .long 0


.data
	.p2align 2
	.globl funcs

funcs:
.text
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	NOEC(T_DIVIDE_handler, T_DIVIDE)
	NOEC(T_DEBUG_handler, T_DEBUG)
	NOEC(T_NMI_handler, T_NMI)
	NOEC(T_BRKPT_handler, T_BRKPT)
	NOEC(T_OFLOW_handler, T_OFLOW)
	NOEC(T_BOUND_handler, T_BOUND)
	NOEC(T_ILLOP_handler, T_ILLOP)
	NOEC(T_DEVICE_handler, T_DEVICE)
	EC(T_DBLFLT_handler, T_DBLFLT)
	PAD()
	EC(T_TSS_handler, T_TSS)
	EC(T_SEGNP_handler, T_SEGNP)
	EC(T_STACK_handler, T_STACK)
	EC(T_GPFLT_handler, T_GPFLT)
	EC(T_PGFLT_handler, T_PGFLT)
	PAD()
	NOEC(T_FPERR_handler, T_FPERR)
	EC(T_ALIGN_handler, T_ALIGN)
	NOEC(T_MCHK_handler, T_MCHK)
	NOEC(T_SIMDERR_handler, T_SIMDERR)


	/*
	 * Lab 3: Your code here for _alltraps
	*/
_alltraps:
	pushl %ds
	pushl %es
	pushal
	/* deal with struct PushRegs tf_regs */

	pushl %esp
	/* pass a pointer to the Trapframe as an argument to trap() */

	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es
	/* use %ax for the suffix */

	call trap


