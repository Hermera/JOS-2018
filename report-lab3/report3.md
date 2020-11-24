# Report for lab3

Hongyu Wen, 1800013069

> All exercises finished.
>
> All questions answered.
>
> Challenge 2 completed.


At first, we need to fix the link script in `kern/kernel.ld`:
```ld
	.bss : {
		PROVIDE(edata = .);
		*(.dynbss)
		*(.bss .bss.*)
		*(COMMON)
		PROVIDE(end = .);
	}
```


## Part A: User Environments and Exception Handling

The envs in JOS is processes.

### Exercise 1

In  `pmap.c`:
```c
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
	memset(envs, 0, NENV * sizeof(struct Env));
	...
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
```


### Exercise 2


```c
void
env_init(void)
{
	env_free_list = NULL;
	for (int i = NENV - 1; ~i; --i) { 
	// Note that env_free_list points to env[0]
	// So we need to insert envs to env_free_list reversely.
	
		struct Env * now_env = envs + i;
		memset(now_env, 0, sizeof(struct Env));

		now_env->env_link = env_free_list;
		env_free_list = now_env;
	}
	...
}
```

```c
static int
env_setup_vm(struct Env *e)
{
        ...
	
	p->pp_ref += 1; // maintain page info
	e->env_pgdir = page2kva(p); 
	// get the kernel virtual address. 
	// Note that all this things is in the kernel space 0-0x10000000.
	
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
	// All terms are the same as kern_pgdir's expect one.

	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
	// UVPT points to env_pgdir itself(not kern_pgdir.)

	return 0;
}
```

```c
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	void * begin = ROUNDDOWN(va, PGSIZE);
	void * end = ROUNDUP(va + len, PGSIZE);

	while (begin < end) {
		struct PageInfo *p = page_alloc(0);
		if (!p) {
			panic("Out of memory in region_alloc.\n");
		}

		page_insert(e->env_pgdir, p, begin, PTE_U | PTE_W);
		begin += PGSIZE;
	}
}
```

```c
static void
load_icode(struct Env *e, uint8_t *binary)
{

	struct ELF *elfhdr = (struct Elf *) binary;
	if (elfhdr->e_magic != ELF_MAGIC) {
		panic("binary is not ELF format.\n");
	}

	lcr3(PADDR(e->env_pgdir)); // Set cr3 to qemu for convenience

	struct Proghdr *ph, *eph;
	ph = (struct Proghdr *)((uint8_t *) elfhdr + elfhdr->ephoff);
	eph = ph + elfhdr->ephnum;
	for (; ph < eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, ph->p_va, ph->p_memsz);

			assert(ph->p_filesz <= ph->p_memsz);
			memset((void *)ph->p_va, 0, ph->p_memsz);
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
			// cr3 works there
		}
	}

	lcr3(PADDR(kern_pgdir));

	e->env_tf.tf_eip = ELFHDR->e_entry;
	// environment starts executing there

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, USTACKTOP - PGSIZE, PGSIZE);
}
```

```c
void
env_create(uint8_t *binary, enum EnvType type)
{

	if (env_alloc(&newenv_store, 0) != 0) {
		panic("env_alloc fails in env_create.\n");
	}

	load_icode(newenv_store, binary);
	newenv_store->env_type = type;
}
```

Now we need to check the correctness of our code. Use `make qemu-gdb` and set a breakpoint at `env_pop_tf`:
```shell
(gdb) b env_pop_tf
Breakpoint 1 at 0xf0103bbf: file kern/env.c, line 475.
```

 Single step through this function using si; the processor should enter user mode after the iret instruction. 
```shell
(gdb) c
Continuing.
=> 0xf0103bbf <env_pop_tf>:	push   %ebp

...

(gdb) 
=> 0xf0103bd7 <env_pop_tf+24>:	add    $0x8,%esp
0xf0103bd7	476	//
(gdb) 
=> 0xf0103bda <env_pop_tf+27>:	iret   
0xf0103bda	476	//
(gdb) 
=> 0x800020:	cmp    $0xeebfe000,%esp
                        // At the label start in lib/entry.S
```

Set a breakpoint at the `int $0x30` in `sys_cputs()` by scanning `obj/user/hello.asm`.
```shell
(gdb) b *0x800b91
Breakpoint 2 at 0x800b91
(gdb) c
Continuing.
=> 0x800b91:	int    $0x30
```
It runs successfully.

### Exercise 4

![IDT](figure/idt.jpeg)

Note that the elements in Trapframe is corresponding to the elements push to stack.
```c
struct Trapframe {
    .....
    uint32_t tf_err;
    uintptr_t tf_eip;
    uint16_t tf_cs;
    uint16_t tf_padding3;
    uint32_t tf_eflags;
    /* below here only when crossing rings, such as from user to kernel */
    uintptr_t tf_esp;
    .....
};
```

```
+--------------------+ KSTACKTOP             
| 0x00000 | old SS   |     " - 4
|      old ESP       |     " - 8
|     old EFLAGS     |     " - 12
| 0x00000 | old CS   |     " - 16
|      old EIP       |     " - 20
|     error code     |     " - 24 <---- ESP
+--------------------+
```

The handler in `trapentry.S` just save the registers, error codes, etc and then call `trap()` in `trap.c`. The dispatcher in `trap()` will jump to handler for the trap. 

Read i386 reference and we get
```
Description                       Interrupt     Error Code
Number

Divide error                       0            No
Debug exceptions                   1            No
Breakpoint                         3            No
Overflow                           4            No
Bounds check                       5            No
Invalid opcode                     6            No
Coprocessor not available          7            No
System error                       8            Yes (always 0)
Coprocessor Segment Overrun        9            No
Invalid TSS                       10            Yes
Segment not present               11            Yes
Stack exception                   12            Yes
General protection fault          13            Yes
Page fault                        14            Yes
Coprocessor error                 16            No
Two-byte SW interrupt             0-255         No
```
Thus in `trapentry.S`:

```asm
TRAPHANDLER_NOEC(T_DIVIDE_handler, T_DIVIDE)
TRAPHANDLER_NOEC(T_DEBUG_handler, T_DEBUG)
TRAPHANDLER_NOEC(T_NMI_handler, T_NMI)
TRAPHANDLER_NOEC(T_BRKPT_handler, T_BRKPT)
TRAPHANDLER_NOEC(T_OFLOW_handler, T_OFLOW)
TRAPHANDLER_NOEC(T_BOUND_handler, T_BOUND)
TRAPHANDLER_NOEC(T_ILLOP_handler, T_ILLOP)
TRAPHANDLER_NOEC(T_DEVICE_handler, T_DEVICE)
TRAPHANDLER(T_DBLFLT_handler, T_DBLFLT)
;; TRAPHANDLER_NOEC(trap9, 9)
TRAPHANDLER(T_TSS_handler, T_TSS)
TRAPHANDLER(T_SEGNP_handler, T_SEGNP)
TRAPHANDLER(T_STACK_handler, T_STACK)
TRAPHANDLER(T_GPFLT_handler, T_GPFLT)
TRAPHANDLER(T_PGFLT_handler, T_PGFLT)
;; TRAPHANDLER(trap15, 15)
TRAPHANDLER_NOEC(T_FPERR_handler, T_FPERR)
TRAPHANDLER(T_ALIGN_handler, T_ALIGN)
TRAPHANDLER_NOEC(T_MCHK_handler, T_MCHK)
TRAPHANDLER_NOEC(T_SIMDERR_handler, T_SIMDERR)

```

Following the structure of `Trapframe`, write down `_alltraps`.

```asm
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

```

Corresponding `trap_init`:
```c
void
trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	void T_DIVIDE_handler();
	void T_DEBUG_handler();
	void T_NMI_handler();
	void T_BRKPT_handler();
	void T_OFLOW_handler();
	void T_BOUND_handler();
	void T_ILLOP_handler();
	void T_DEVICE_handler();
	void T_DBLFLT_handler();
	void T_TSS_handler();
	void T_SEGNP_handler();
	void T_STACK_handler();
	void T_GPFLT_handler();
	void T_PGFLT_handler();
	void T_FPERR_handler();
	void T_ALIGN_handler();
	void T_MCHK_handler();
	void T_SIMDERR_handler();

	// See 9.9 of the i386 reference

	SETGATE(idt[T_DIVIDE], 0, GD_KT, T_DIVIDE_handler, 0);
	SETGATE(idt[T_DEBUG], 0, GD_KT, T_DEBUG_handler, 0);
	SETGATE(idt[T_NMI], 0, GD_KT, T_NMI_handler, 0);
	SETGATE(idt[T_BRKPT], 1, GD_KT, T_BRKPT_handler, 0);
	SETGATE(idt[T_OFLOW], 1, GD_KT, T_OFLOW_handler, 0);
	SETGATE(idt[T_BOUND], 0, GD_KT, T_BOUND_handler, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, T_ILLOP_handler, 0);
	SETGATE(idt[T_DEVICE], 0, GD_KT, T_DEVICE_handler, 0);
	SETGATE(idt[T_DBLFLT], 0, GD_KT, T_DBLFLT_handler, 0);
	SETGATE(idt[T_TSS], 0, GD_KT, T_TSS_handler, 0);
	SETGATE(idt[T_SEGNP], 0, GD_KT, T_SEGNP_handler, 0);
	SETGATE(idt[T_STACK], 0, GD_KT, T_STACK_handler, 0);
	SETGATE(idt[T_GPFLT], 0, GD_KT, T_GPFLT_handler, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, T_PGFLT_handler, 0);
	SETGATE(idt[T_FPERR], 0, GD_KT, T_FPERR_handler, 0);
	SETGATE(idt[T_ALIGN], 0, GD_KT, T_ALIGN_handler, 0);
	SETGATE(idt[T_MCHK], 0, GD_KT, T_MCHK_handler, 0);
	SETGATE(idt[T_SIMDERR], 0, GD_KT, T_SIMDERR_handler, 0);

	// Per-CPU setup
	trap_init_percpu();
}
```

And then we can pass the first three tests.


```shell
divzero: OK (1.1s) 
    (Old jos.out.divzero failure log removed)
softint: OK (1.2s) 
    (Old jos.out.softint failure log removed)
badsegment: OK (1.6s) 
    (Old jos.out.badsegment failure log removed)
Part A score: 30/30
```