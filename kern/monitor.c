// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <inc/color.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "showmappings", "Display in a useful and easy-to-read format all of the physical page mappings", showmappings },
	{ "set_perm", "Set new perm for a certain page", set_perm },
	{ "dump", "Dump the contents of a range of memory given either a virtual or physical address range.", dump }
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	cprintf("Stack backtrace:\n");
#define READ(x) *((uint32_t*) (x))

	uint32_t ebp = read_ebp();
	uint32_t eip = 0;
	struct Eipdebuginfo info;
	while (ebp) {
		eip = READ(ebp + 4);
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
			ebp,
			eip,
			READ(ebp + 8),
			READ(ebp + 12),
			READ(ebp + 16),
			READ(ebp + 20),
			READ(ebp + 24));

		if(!debuginfo_eip(eip, &info)) {
			cprintf("\t%s:%d: %.*s+%d\n",
				info.eip_file,
				info.eip_line,
				info.eip_fn_namelen, info.eip_fn_name,
				eip - info.eip_fn_addr);
		}
		ebp = READ(ebp);
	}
	return 0;
#undef READ
}

int xtoi(char *buf) {
	uint32_t ret = 0;
	for (buf += 2; *buf; ++buf) {
		if (*buf >= 'a') {
			ret = ret * 16 + (*buf - 'a') + 10;
		} else {
			ret = ret * 16 + (*buf - '0');
		}
	}
	return ret;
}

int btoi(char *buf) {
	uint32_t ret = 0;
	for (; *buf; ++buf) {
		ret = ret * 2 + (*buf - '0');
	}
	return ret;
}

void pprint(pte_t *pte) {
	cprintf("Present=%d", (bool)(*pte & PTE_P));
	cprintf("Write=%d ", (bool)(*pte & PTE_W));
	cprintf("User=%d\n", (bool)(*pte & PTE_U));
}

int showmappings(int argc, char **argv, struct Trapframe *tf) {
	if (argc <= 1) {
		cprintf("showmappings usage: showmappings begin_addr end_addr\n");
		return 0;
	}

	uint32_t begin_addr = xtoi(argv[1]);
	uint32_t end_addr = xtoi(argv[2]);
	for (uint32_t now = begin_addr; now <= end_addr; now += PGSIZE) {
		pte_t *pte = pgdir_walk(kern_pgdir, (void *)now, 1);
		if (pte == NULL) {
			panic("Out of memory!");
		} else if (*pte & PTE_P) {
			cprintf("page %x: ");
			pprint(pte);
		} else {
			cprintf("page %x does not exist.\n");
		}
	}
	return 0;
}

int set_perm(int argc, char **argv, struct Trapframe *tf) {
	if (argc <= 1) {
		cprintf("set_perm usage: set_perm addr new_perm\n");
		return 0;
	}

	uint32_t addr = xtoi(argv[1]);
	uint32_t perm = btoi(argv[2]);
	uint32_t mask = PTE_P | PTE_U | PTE_W;

	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);

	if (pte == NULL) {
		panic("Out of memory!");
	} else {
		cprintf("Before change: ");
		pprint(pte);
		*pte &= ~mask;
		*pte |= perm;
		cprintf("After change: ");
		pprint(pte);
	}
	return 0;
}

int dump(int argc, char **argv, struct Trapframe *tf) {
	if (argc <= 3) {
		cprintf("dump usage: dump [V/P] begin_addr num_of_addr\n");
		return 0;
	}

	uint32_t begin_addr = xtoi(argv[2]);
	uint32_t end_addr = xtoi(argv[3]);
	if (*argv[1] == 'P') {
		begin_addr += KERNBASE;
		end_addr += KERNBASE;
	}

	for (; begin_addr <= end_addr; begin_addr += 1) {
		uint8_t * addr = (uint8_t *) begin_addr;
		cprintf("%x: %x\n", addr, *addr);
	}
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");
	cprintf("Printf something in %Cred.\n", COLOR_RED);
	cprintf("Printf something in %Cgreen.\n", COLOR_GREEN);
	cprintf("Printf something in %Cblue.\n", COLOR_BLUE);

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
