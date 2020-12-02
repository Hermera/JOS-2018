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

	boot_map_region(kern_pgdir, base, len,  head, PTE_PCD | PTE_PWT);
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