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