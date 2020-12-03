# Report for lab4

Hongyu Wen, 1800013069

> All exercises finished.
>
> All questions answered.
>
> Challenge 2 completed.


## Part A: Multiprocessor Support and Cooperative Multitasking

### Exercise 1

```c
void *
mmio_map_region(physaddr_t pa, size_t size)
{
        ...
	physaddr_t head = ROUNDDOWN(pa, PGSIZE);
	physaddr_t tail = ROUNDUP(pa + size, PGSIZE); 
	// Note that the physical page need to be aligned
	
	size_t len = (size_t)(tail - head);
	if (base + len > MMIOLIM) {
		panic("mmio_map_region overflowed");
	}

	boot_map_region(kern_pgdir, base, len,  head, PTE_PCD | PTE_PWT | PTE_W);
	base += len;

	return (void*) (base - len);
	/* panic("mmio_map_region not implemented"); */
}
```
### Exercise 2

> Following a power-up or reset, the APs complete a minimal self-configuration, then wait for a startup signal (a SIPI message) from the BSP processor. Upon receiving a SIPI message, an AP executes the BIOS AP configuration code, which ends with the AP being placed in halt state.

In `page_init`:
```c
	for (i = 0; i < npages; i++) {
		if (i == MPENTRY_PADDR / PGSIZE)
			continue; // Can not use MPENTRY_PADDR
		...
	}

```

Now we get
```shell
check_page_free_list() succeeded!
check_page_alloc() succeeded!
check_page() succeeded!
```

### Question

1. In `boot.S`:
```asm
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
```
Now CPU is under real-mode so it can jump to a physical address directly. But in `mpentry.S`, the BSP has already be in protected-mode thus we need to calculate the physical address by `MPBOOTPHYS`. I guess
```
	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
	call    *%eax
```
that is the same reason.

### Exercise 3

```c
        uintptr_t base = KERNBASE - KSTKSIZE;
	for (int i = 0; i < NCPU; ++i) {
		boot_map_region(kern_pgdir, base, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
		base -= KSTKSIZE + KSTKGAP;
	}
```

### Exercise 4

```
	int cid = cpunum();
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
	// Note the new stack top
	
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cid << 3));
	// Note " + (cid << 3)"

	// Load the IDT
	lidt(&idt_pd);
```

`make qemu CPUS=4` and we get:
```shell
SMP: CPU 0 found 4 CPU(s)
enabled interrupts: 1 2
SMP: CPU 1 starting
SMP: CPU 2 starting
SMP: CPU 3 starting
```

### Questions

2. We cannot guarantee the contents in shared stack are right when we switch one cpu to another.


### Exercise 5

Just do as the exercise says.

### Exercise 6

```c
	int cur = 0;
	if (curenv) {
		cur = curenv->env_id;
	}
	for (int i = 0; i < NENV; ++i) {
		cur = (cur + 1) % NENV;
		if (envs[cur].env_status == ENV_RUNNABLE) {
			env_run(envs + cur);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);

	// sched_halt never returns
	sched_halt();
```

`make qemu CPUS=2` and we get:
```shell
Hello, I am environment 00001001.
Hello, I am environment 00001002.
Back in environment 00001001, iteration 0.
Hello, I am environment 00001000.
Back in environment 00001002, iteration 0.
Back in environment 00001001, iteration 1.
Back in environment 00001000, iteration 0.
Back in environment 00001002, iteration 1.
Back in environment 00001001, iteration 2.
Back in environment 00001000, iteration 1.
Back in environment 00001002, iteration 2.
Back in environment 00001001, iteration 3.
Back in environment 00001000, iteration 2.
Back in environment 00001002, iteration 3.
Back in environment 00001001, iteration 4.
Back in environment 00001000, iteration 3.
All done in environment 00001001.
```

### Questions

3. Because it is in kernel address.
4. In `env.c`: `env_pop_tf(&curenv->env_tf);`

