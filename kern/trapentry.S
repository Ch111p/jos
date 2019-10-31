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

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(divide    , 0)
TRAPHANDLER_NOEC(debug     , 1)
TRAPHANDLER_NOEC(nmi       , 2)
TRAPHANDLER_NOEC(brkpt     , 3)
TRAPHANDLER_NOEC(oflow     , 4)
TRAPHANDLER_NOEC(bound     , 5)
TRAPHANDLER_NOEC(illop     , 6)
TRAPHANDLER_NOEC(device    , 7)
TRAPHANDLER(dblflt    , 8)
TRAPHANDLER(tss       ,10)
TRAPHANDLER(segnp     ,11)
TRAPHANDLER(stack     ,12)
TRAPHANDLER(gpflt     ,13)
TRAPHANDLER(pgflt     ,14)
// TRAPHANDLER_NOEC(res       ,15)
TRAPHANDLER(fperr     ,16)
TRAPHANDLER(align     ,17)
TRAPHANDLER(mchk      ,18)
TRAPHANDLER(simderr   ,19)
TRAPHANDLER_NOEC(syscall_tmp,T_SYSCALL)
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	push %ds;
	push %es;
	pushal;
	mov $(GD_KD), %ax;
	mov %ax, %ds;
	mov %ax, %es;
	pushl %esp;
	call trap;