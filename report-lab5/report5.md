# Report for lab5

Hongyu Wen, 1800013069

> All exercises finished.
>
> All questions answered.
>
> 2 Challenges completed.


## On-Disk File System Structure

- Our file system will not use inodes at all and instead will simply store all of a file's (or sub-directory's) meta-data within the (one and only) directory entry describing that file.
- Our file system does allow user environments to read directory meta-data directly (e.g., with read), which means that user environments can perform directory scanning operations themselves (e.g., to implement the ls program) rather than having to rely on additional special calls to the file system. The disadvantage of this approach to directory scanning, and the reason most modern UNIX variants discourage it, is that it makes application programs dependent on the format of directory meta-data, making it difficult to change the file system's internal layout without changing or at least recompiling application programs as well.
- Our file system will use a block size of 4096 bytes, conveniently matching the processor's page size.
- Our file system will have exactly one superblock, which will always be at block 1 on the disk. Its layout is defined by struct Super in `inc/fs.h`.
- As mentioned above, we do not have inodes, so this meta-data is stored in a directory entry on disk. Unlike in most "real" file systems, for simplicity we will use this one File structure to represent file meta-data as it appears both on disk and in memory.
- Only support single-indirect blocks.


## Disk Access

- Instead of taking the conventional "monolithic" operating system strategy of adding an IDE disk driver to the kernel along with the necessary system calls to allow the file system to access it, we instead implement the IDE disk driver as part of the **user-level file system environment**.
- It is easy to implement disk access in user space this way as long as we rely on polling, "programmed I/O" (PIO)-based disk access and do not use disk interrupts.
- The x86 processor uses the IOPL bits in the EFLAGS register to determine whether protected-mode code is allowed to perform special device I/O instructions such as the IN and OUT instructions.

### Exercise 1

```c
void
env_create(uint8_t *binary, enum EnvType type)
{
        ...
	if (type == ENV_TYPE_FS) {
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
	}
}
```

Run `make grade` we get:

```shell
internal FS tests [fs/test.c]: OK (1.2s) 
  fs i/o: OK 
```

### Questions

1. Do you have to do anything else to ensure that this I/O privilege setting is saved and restored properly when you subsequently switch from one environment to another? Why?

No. Because all the registers will be set well automatically.



## The Block Cache

### Exercise 2

`bc_pgfoult`:
```c
	addr = ROUNDDOWN(addr, PGSIZE);
	if ((r = sys_page_alloc(0, addr, PTE_U | PTE_W | PTE_P)) < 0)
		panic("in bc_pgfault, sys_page_alloc: %e", r);
	if ((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
		panic("in bc_pgfault, ide_read: %e", r);
```

`flush_block`:
```
	addr = ROUNDDOWN(addr, PGSIZE);
	if (!va_is_mapped(addr) || !va_is_dirty(addr))
		return;

	int r;
	if ((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
		panic("in flush_block, ide_write: %e", r);

	// clean PTE_D
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
		panic("in bc_pgfault, sys_page_map: %e", r);
```

Run `make grade` we get:
```shell
  fs i/o: OK 
  check_bc: OK 
  check_super: OK 
  check_bitmap: OK 
```

## The Block Bitmap

### Exercise 3
```c
int
alloc_block(void)
{
	int offset = 2; // 1 for super and 2 for bitmap
	for (uint32_t i = 0; i < super->s_nblocks; ++i) {
		if (block_is_free(i)) {
			bitmap[i/32] &= ~(1 << (i%32));

			// flush the bitmap
			flush_block(diskaddr(offset + i / 32 / NINDIRECT));
			return i;
		}
	}
	return -E_NO_DISK;
}
```

Now we can pass `alloc_block`.

## File Operations

