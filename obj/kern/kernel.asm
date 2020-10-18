
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 c2 12 01 00    	add    $0x112c2,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 b4 08 ff ff    	lea    -0xf74c(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 bc 0a 00 00       	call   f0100b1f <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 13 08 00 00       	call   f010088b <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 d0 08 ff ff    	lea    -0xf730(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 94 0a 00 00       	call   f0100b1f <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 5a 12 01 00    	add    $0x1125a,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 a7 16 00 00       	call   f0101776 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 45 05 00 00       	call   f0100619 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 eb 08 ff ff    	lea    -0xf715(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 37 0a 00 00       	call   f0100b1f <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 26 08 00 00       	call   f0100927 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f8 11 01 00    	add    $0x111f8,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 f5 07 00 00       	call   f0100927 <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 cc 09 00 00       	call   f0100b1f <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 8b 09 00 00       	call   f0100ae8 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 42 09 ff ff    	lea    -0xf6be(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 b4 09 00 00       	call   f0100b1f <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 92 11 01 00    	add    $0x11192,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 1e 09 ff ff    	lea    -0xf6e2(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 87 09 00 00       	call   f0100b1f <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 44 09 00 00       	call   f0100ae8 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 42 09 ff ff    	lea    -0xf6be(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 6d 09 00 00       	call   f0100b1f <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 23 11 01 00    	add    $0x11123,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 78 1f 00 00    	mov    0x1f78(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 78 1f 00 00    	mov    %edx,0x1f78(%ebx)
f010020b:	88 84 0b 74 1d 00 00 	mov    %al,0x1d74(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d8 10 01 00    	add    $0x110d8,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 54 1d 00 00    	mov    0x1d54(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 54 1d 00 00    	mov    %ecx,0x1d54(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 74 0a ff 	movzbl -0xf58c(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 54 1d 00 00    	or     0x1d54(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 74 09 ff 	movzbl -0xf68c(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 54 1d 00 00    	mov    %eax,0x1d54(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f4 1c 00 00 	mov    0x1cf4(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 38 09 ff ff    	lea    -0xf6c8(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 3c 08 00 00       	call   f0100b1f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 54 1d 00 00 40 	orl    $0x40,0x1d54(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 54 1d 00 00    	mov    0x1d54(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 74 0a ff 	movzbl -0xf58c(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 54 1d 00 00    	mov    %eax,0x1d54(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 a2 0f 01 00    	add    $0x10fa2,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01003f1:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01003f6:	75 0b                	jne    f0100403 <cons_putc+0xa7>
		c |= color;
f01003f8:	8b bb f4 ff ff ff    	mov    -0xc(%ebx),%edi
f01003fe:	09 f8                	or     %edi,%eax
f0100400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100403:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100407:	83 f8 09             	cmp    $0x9,%eax
f010040a:	0f 84 c3 00 00 00    	je     f01004d3 <cons_putc+0x177>
f0100410:	83 f8 09             	cmp    $0x9,%eax
f0100413:	7e 74                	jle    f0100489 <cons_putc+0x12d>
f0100415:	83 f8 0a             	cmp    $0xa,%eax
f0100418:	0f 84 9e 00 00 00    	je     f01004bc <cons_putc+0x160>
f010041e:	83 f8 0d             	cmp    $0xd,%eax
f0100421:	0f 85 e3 00 00 00    	jne    f010050a <cons_putc+0x1ae>
		crt_pos -= (crt_pos % CRT_COLS);
f0100427:	0f b7 83 7c 1f 00 00 	movzwl 0x1f7c(%ebx),%eax
f010042e:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100434:	c1 e8 16             	shr    $0x16,%eax
f0100437:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043a:	c1 e0 04             	shl    $0x4,%eax
f010043d:	66 89 83 7c 1f 00 00 	mov    %ax,0x1f7c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100444:	66 81 bb 7c 1f 00 00 	cmpw   $0x7cf,0x1f7c(%ebx)
f010044b:	cf 07 
f010044d:	0f 87 de 00 00 00    	ja     f0100531 <cons_putc+0x1d5>
	outb(addr_6845, 14);
f0100453:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100459:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045e:	89 ca                	mov    %ecx,%edx
f0100460:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100461:	0f b7 9b 7c 1f 00 00 	movzwl 0x1f7c(%ebx),%ebx
f0100468:	8d 71 01             	lea    0x1(%ecx),%esi
f010046b:	89 d8                	mov    %ebx,%eax
f010046d:	66 c1 e8 08          	shr    $0x8,%ax
f0100471:	89 f2                	mov    %esi,%edx
f0100473:	ee                   	out    %al,(%dx)
f0100474:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100479:	89 ca                	mov    %ecx,%edx
f010047b:	ee                   	out    %al,(%dx)
f010047c:	89 d8                	mov    %ebx,%eax
f010047e:	89 f2                	mov    %esi,%edx
f0100480:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100481:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100484:	5b                   	pop    %ebx
f0100485:	5e                   	pop    %esi
f0100486:	5f                   	pop    %edi
f0100487:	5d                   	pop    %ebp
f0100488:	c3                   	ret    
	switch (c & 0xff) {
f0100489:	83 f8 08             	cmp    $0x8,%eax
f010048c:	75 7c                	jne    f010050a <cons_putc+0x1ae>
		if (crt_pos > 0) {
f010048e:	0f b7 83 7c 1f 00 00 	movzwl 0x1f7c(%ebx),%eax
f0100495:	66 85 c0             	test   %ax,%ax
f0100498:	74 b9                	je     f0100453 <cons_putc+0xf7>
			crt_pos--;
f010049a:	83 e8 01             	sub    $0x1,%eax
f010049d:	66 89 83 7c 1f 00 00 	mov    %ax,0x1f7c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a4:	0f b7 c0             	movzwl %ax,%eax
f01004a7:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ab:	b2 00                	mov    $0x0,%dl
f01004ad:	83 ca 20             	or     $0x20,%edx
f01004b0:	8b 8b 80 1f 00 00    	mov    0x1f80(%ebx),%ecx
f01004b6:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004ba:	eb 88                	jmp    f0100444 <cons_putc+0xe8>
		crt_pos += CRT_COLS;
f01004bc:	66 83 83 7c 1f 00 00 	addw   $0x50,0x1f7c(%ebx)
f01004c3:	50 
		color = COLOR_WHITE; // reset color
f01004c4:	c7 83 f4 ff ff ff 00 	movl   $0x700,-0xc(%ebx)
f01004cb:	07 00 00 
f01004ce:	e9 54 ff ff ff       	jmp    f0100427 <cons_putc+0xcb>
		cons_putc(' ');
f01004d3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d8:	e8 7f fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004dd:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e2:	e8 75 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ec:	e8 6b fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f6:	e8 61 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0100500:	e8 57 fe ff ff       	call   f010035c <cons_putc>
f0100505:	e9 3a ff ff ff       	jmp    f0100444 <cons_putc+0xe8>
		crt_buf[crt_pos++] = c;		/* write the character */
f010050a:	0f b7 83 7c 1f 00 00 	movzwl 0x1f7c(%ebx),%eax
f0100511:	8d 50 01             	lea    0x1(%eax),%edx
f0100514:	66 89 93 7c 1f 00 00 	mov    %dx,0x1f7c(%ebx)
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	8b 93 80 1f 00 00    	mov    0x1f80(%ebx),%edx
f0100524:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100528:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052c:	e9 13 ff ff ff       	jmp    f0100444 <cons_putc+0xe8>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100531:	8b 83 80 1f 00 00    	mov    0x1f80(%ebx),%eax
f0100537:	83 ec 04             	sub    $0x4,%esp
f010053a:	68 00 0f 00 00       	push   $0xf00
f010053f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100545:	52                   	push   %edx
f0100546:	50                   	push   %eax
f0100547:	e8 77 12 00 00       	call   f01017c3 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010054c:	8b 93 80 1f 00 00    	mov    0x1f80(%ebx),%edx
f0100552:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100558:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010055e:	83 c4 10             	add    $0x10,%esp
f0100561:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100566:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100569:	39 d0                	cmp    %edx,%eax
f010056b:	75 f4                	jne    f0100561 <cons_putc+0x205>
		crt_pos -= CRT_COLS;
f010056d:	66 83 ab 7c 1f 00 00 	subw   $0x50,0x1f7c(%ebx)
f0100574:	50 
f0100575:	e9 d9 fe ff ff       	jmp    f0100453 <cons_putc+0xf7>

f010057a <serial_intr>:
{
f010057a:	e8 e7 01 00 00       	call   f0100766 <__x86.get_pc_thunk.ax>
f010057f:	05 8d 0d 01 00       	add    $0x10d8d,%eax
	if (serial_exists)
f0100584:	80 b8 88 1f 00 00 00 	cmpb   $0x0,0x1f88(%eax)
f010058b:	75 02                	jne    f010058f <serial_intr+0x15>
f010058d:	f3 c3                	repz ret 
{
f010058f:	55                   	push   %ebp
f0100590:	89 e5                	mov    %esp,%ebp
f0100592:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100595:	8d 80 b4 ee fe ff    	lea    -0x1114c(%eax),%eax
f010059b:	e8 3f fc ff ff       	call   f01001df <cons_intr>
}
f01005a0:	c9                   	leave  
f01005a1:	c3                   	ret    

f01005a2 <kbd_intr>:
{
f01005a2:	55                   	push   %ebp
f01005a3:	89 e5                	mov    %esp,%ebp
f01005a5:	83 ec 08             	sub    $0x8,%esp
f01005a8:	e8 b9 01 00 00       	call   f0100766 <__x86.get_pc_thunk.ax>
f01005ad:	05 5f 0d 01 00       	add    $0x10d5f,%eax
	cons_intr(kbd_proc_data);
f01005b2:	8d 80 1e ef fe ff    	lea    -0x110e2(%eax),%eax
f01005b8:	e8 22 fc ff ff       	call   f01001df <cons_intr>
}
f01005bd:	c9                   	leave  
f01005be:	c3                   	ret    

f01005bf <cons_getc>:
{
f01005bf:	55                   	push   %ebp
f01005c0:	89 e5                	mov    %esp,%ebp
f01005c2:	53                   	push   %ebx
f01005c3:	83 ec 04             	sub    $0x4,%esp
f01005c6:	e8 f1 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005cb:	81 c3 41 0d 01 00    	add    $0x10d41,%ebx
	serial_intr();
f01005d1:	e8 a4 ff ff ff       	call   f010057a <serial_intr>
	kbd_intr();
f01005d6:	e8 c7 ff ff ff       	call   f01005a2 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005db:	8b 93 74 1f 00 00    	mov    0x1f74(%ebx),%edx
	return 0;
f01005e1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005e6:	3b 93 78 1f 00 00    	cmp    0x1f78(%ebx),%edx
f01005ec:	74 19                	je     f0100607 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005ee:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005f1:	89 8b 74 1f 00 00    	mov    %ecx,0x1f74(%ebx)
f01005f7:	0f b6 84 13 74 1d 00 	movzbl 0x1d74(%ebx,%edx,1),%eax
f01005fe:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005ff:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100605:	74 06                	je     f010060d <cons_getc+0x4e>
}
f0100607:	83 c4 04             	add    $0x4,%esp
f010060a:	5b                   	pop    %ebx
f010060b:	5d                   	pop    %ebp
f010060c:	c3                   	ret    
			cons.rpos = 0;
f010060d:	c7 83 74 1f 00 00 00 	movl   $0x0,0x1f74(%ebx)
f0100614:	00 00 00 
f0100617:	eb ee                	jmp    f0100607 <cons_getc+0x48>

f0100619 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100619:	55                   	push   %ebp
f010061a:	89 e5                	mov    %esp,%ebp
f010061c:	57                   	push   %edi
f010061d:	56                   	push   %esi
f010061e:	53                   	push   %ebx
f010061f:	83 ec 1c             	sub    $0x1c,%esp
f0100622:	e8 95 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100627:	81 c3 e5 0c 01 00    	add    $0x10ce5,%ebx
	was = *cp;
f010062d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100634:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010063b:	5a a5 
	if (*cp != 0xA55A) {
f010063d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100644:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100648:	0f 84 bc 00 00 00    	je     f010070a <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f010064e:	c7 83 84 1f 00 00 b4 	movl   $0x3b4,0x1f84(%ebx)
f0100655:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100658:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f010065f:	8b bb 84 1f 00 00    	mov    0x1f84(%ebx),%edi
f0100665:	b8 0e 00 00 00       	mov    $0xe,%eax
f010066a:	89 fa                	mov    %edi,%edx
f010066c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010066d:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100670:	89 ca                	mov    %ecx,%edx
f0100672:	ec                   	in     (%dx),%al
f0100673:	0f b6 f0             	movzbl %al,%esi
f0100676:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100679:	b8 0f 00 00 00       	mov    $0xf,%eax
f010067e:	89 fa                	mov    %edi,%edx
f0100680:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100681:	89 ca                	mov    %ecx,%edx
f0100683:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100687:	89 bb 80 1f 00 00    	mov    %edi,0x1f80(%ebx)
	pos |= inb(addr_6845 + 1);
f010068d:	0f b6 c0             	movzbl %al,%eax
f0100690:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100692:	66 89 b3 7c 1f 00 00 	mov    %si,0x1f7c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100699:	b9 00 00 00 00       	mov    $0x0,%ecx
f010069e:	89 c8                	mov    %ecx,%eax
f01006a0:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006a5:	ee                   	out    %al,(%dx)
f01006a6:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006ab:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006b0:	89 fa                	mov    %edi,%edx
f01006b2:	ee                   	out    %al,(%dx)
f01006b3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006bd:	ee                   	out    %al,(%dx)
f01006be:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006c3:	89 c8                	mov    %ecx,%eax
f01006c5:	89 f2                	mov    %esi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	b8 03 00 00 00       	mov    $0x3,%eax
f01006cd:	89 fa                	mov    %edi,%edx
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006d5:	89 c8                	mov    %ecx,%eax
f01006d7:	ee                   	out    %al,(%dx)
f01006d8:	b8 01 00 00 00       	mov    $0x1,%eax
f01006dd:	89 f2                	mov    %esi,%edx
f01006df:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006e5:	ec                   	in     (%dx),%al
f01006e6:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e8:	3c ff                	cmp    $0xff,%al
f01006ea:	0f 95 83 88 1f 00 00 	setne  0x1f88(%ebx)
f01006f1:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006f6:	ec                   	in     (%dx),%al
f01006f7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006fc:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006fd:	80 f9 ff             	cmp    $0xff,%cl
f0100700:	74 25                	je     f0100727 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f0100702:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100705:	5b                   	pop    %ebx
f0100706:	5e                   	pop    %esi
f0100707:	5f                   	pop    %edi
f0100708:	5d                   	pop    %ebp
f0100709:	c3                   	ret    
		*cp = was;
f010070a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100711:	c7 83 84 1f 00 00 d4 	movl   $0x3d4,0x1f84(%ebx)
f0100718:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010071b:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100722:	e9 38 ff ff ff       	jmp    f010065f <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100727:	83 ec 0c             	sub    $0xc,%esp
f010072a:	8d 83 44 09 ff ff    	lea    -0xf6bc(%ebx),%eax
f0100730:	50                   	push   %eax
f0100731:	e8 e9 03 00 00       	call   f0100b1f <cprintf>
f0100736:	83 c4 10             	add    $0x10,%esp
}
f0100739:	eb c7                	jmp    f0100702 <cons_init+0xe9>

f010073b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010073b:	55                   	push   %ebp
f010073c:	89 e5                	mov    %esp,%ebp
f010073e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100741:	8b 45 08             	mov    0x8(%ebp),%eax
f0100744:	e8 13 fc ff ff       	call   f010035c <cons_putc>
}
f0100749:	c9                   	leave  
f010074a:	c3                   	ret    

f010074b <getchar>:

int
getchar(void)
{
f010074b:	55                   	push   %ebp
f010074c:	89 e5                	mov    %esp,%ebp
f010074e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100751:	e8 69 fe ff ff       	call   f01005bf <cons_getc>
f0100756:	85 c0                	test   %eax,%eax
f0100758:	74 f7                	je     f0100751 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010075a:	c9                   	leave  
f010075b:	c3                   	ret    

f010075c <iscons>:

int
iscons(int fdnum)
{
f010075c:	55                   	push   %ebp
f010075d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010075f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100764:	5d                   	pop    %ebp
f0100765:	c3                   	ret    

f0100766 <__x86.get_pc_thunk.ax>:
f0100766:	8b 04 24             	mov    (%esp),%eax
f0100769:	c3                   	ret    

f010076a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010076a:	55                   	push   %ebp
f010076b:	89 e5                	mov    %esp,%ebp
f010076d:	56                   	push   %esi
f010076e:	53                   	push   %ebx
f010076f:	e8 48 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100774:	81 c3 98 0b 01 00    	add    $0x10b98,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010077a:	83 ec 04             	sub    $0x4,%esp
f010077d:	8d 83 74 0b ff ff    	lea    -0xf48c(%ebx),%eax
f0100783:	50                   	push   %eax
f0100784:	8d 83 92 0b ff ff    	lea    -0xf46e(%ebx),%eax
f010078a:	50                   	push   %eax
f010078b:	8d b3 97 0b ff ff    	lea    -0xf469(%ebx),%esi
f0100791:	56                   	push   %esi
f0100792:	e8 88 03 00 00       	call   f0100b1f <cprintf>
f0100797:	83 c4 0c             	add    $0xc,%esp
f010079a:	8d 83 78 0c ff ff    	lea    -0xf388(%ebx),%eax
f01007a0:	50                   	push   %eax
f01007a1:	8d 83 a0 0b ff ff    	lea    -0xf460(%ebx),%eax
f01007a7:	50                   	push   %eax
f01007a8:	56                   	push   %esi
f01007a9:	e8 71 03 00 00       	call   f0100b1f <cprintf>
	return 0;
}
f01007ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007b6:	5b                   	pop    %ebx
f01007b7:	5e                   	pop    %esi
f01007b8:	5d                   	pop    %ebp
f01007b9:	c3                   	ret    

f01007ba <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ba:	55                   	push   %ebp
f01007bb:	89 e5                	mov    %esp,%ebp
f01007bd:	57                   	push   %edi
f01007be:	56                   	push   %esi
f01007bf:	53                   	push   %ebx
f01007c0:	83 ec 18             	sub    $0x18,%esp
f01007c3:	e8 f4 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007c8:	81 c3 44 0b 01 00    	add    $0x10b44,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007ce:	8d 83 a9 0b ff ff    	lea    -0xf457(%ebx),%eax
f01007d4:	50                   	push   %eax
f01007d5:	e8 45 03 00 00       	call   f0100b1f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007da:	83 c4 08             	add    $0x8,%esp
f01007dd:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007e3:	8d 83 a0 0c ff ff    	lea    -0xf360(%ebx),%eax
f01007e9:	50                   	push   %eax
f01007ea:	e8 30 03 00 00       	call   f0100b1f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007ef:	83 c4 0c             	add    $0xc,%esp
f01007f2:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f8:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007fe:	50                   	push   %eax
f01007ff:	57                   	push   %edi
f0100800:	8d 83 c8 0c ff ff    	lea    -0xf338(%ebx),%eax
f0100806:	50                   	push   %eax
f0100807:	e8 13 03 00 00       	call   f0100b1f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010080c:	83 c4 0c             	add    $0xc,%esp
f010080f:	c7 c0 b9 1b 10 f0    	mov    $0xf0101bb9,%eax
f0100815:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081b:	52                   	push   %edx
f010081c:	50                   	push   %eax
f010081d:	8d 83 ec 0c ff ff    	lea    -0xf314(%ebx),%eax
f0100823:	50                   	push   %eax
f0100824:	e8 f6 02 00 00       	call   f0100b1f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100829:	83 c4 0c             	add    $0xc,%esp
f010082c:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100832:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100838:	52                   	push   %edx
f0100839:	50                   	push   %eax
f010083a:	8d 83 10 0d ff ff    	lea    -0xf2f0(%ebx),%eax
f0100840:	50                   	push   %eax
f0100841:	e8 d9 02 00 00       	call   f0100b1f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100846:	83 c4 0c             	add    $0xc,%esp
f0100849:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f010084f:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100855:	50                   	push   %eax
f0100856:	56                   	push   %esi
f0100857:	8d 83 34 0d ff ff    	lea    -0xf2cc(%ebx),%eax
f010085d:	50                   	push   %eax
f010085e:	e8 bc 02 00 00       	call   f0100b1f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100863:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100866:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010086c:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010086e:	c1 fe 0a             	sar    $0xa,%esi
f0100871:	56                   	push   %esi
f0100872:	8d 83 58 0d ff ff    	lea    -0xf2a8(%ebx),%eax
f0100878:	50                   	push   %eax
f0100879:	e8 a1 02 00 00       	call   f0100b1f <cprintf>
	return 0;
}
f010087e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100883:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100886:	5b                   	pop    %ebx
f0100887:	5e                   	pop    %esi
f0100888:	5f                   	pop    %edi
f0100889:	5d                   	pop    %ebp
f010088a:	c3                   	ret    

f010088b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010088b:	55                   	push   %ebp
f010088c:	89 e5                	mov    %esp,%ebp
f010088e:	57                   	push   %edi
f010088f:	56                   	push   %esi
f0100890:	53                   	push   %ebx
f0100891:	83 ec 48             	sub    $0x48,%esp
f0100894:	e8 23 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100899:	81 c3 73 0a 01 00    	add    $0x10a73,%ebx
	// Your code here.
	 cprintf("Stack backtrace:\n");
f010089f:	8d 83 c2 0b ff ff    	lea    -0xf43e(%ebx),%eax
f01008a5:	50                   	push   %eax
f01008a6:	e8 74 02 00 00       	call   f0100b1f <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ab:	89 ee                	mov    %ebp,%esi
#define READ(x) *((uint32_t*) (x))

	uint32_t ebp = read_ebp();
	uint32_t eip = 0;
	struct Eipdebuginfo info;
	while (ebp) {
f01008ad:	83 c4 10             	add    $0x10,%esp
		eip = READ(ebp + 4);
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008b0:	8d 83 84 0d ff ff    	lea    -0xf27c(%ebx),%eax
f01008b6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			READ(ebp + 12),
			READ(ebp + 16),
			READ(ebp + 20),
			READ(ebp + 24));

		if(!debuginfo_eip(eip, &info)) {
f01008b9:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008bc:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (ebp) {
f01008bf:	eb 02                	jmp    f01008c3 <mon_backtrace+0x38>
				info.eip_file,
				info.eip_line,
				info.eip_fn_namelen, info.eip_fn_name,
				eip - info.eip_fn_addr);
		}
		ebp = READ(ebp);
f01008c1:	8b 36                	mov    (%esi),%esi
	while (ebp) {
f01008c3:	85 f6                	test   %esi,%esi
f01008c5:	74 53                	je     f010091a <mon_backtrace+0x8f>
		eip = READ(ebp + 4);
f01008c7:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008ca:	ff 76 18             	pushl  0x18(%esi)
f01008cd:	ff 76 14             	pushl  0x14(%esi)
f01008d0:	ff 76 10             	pushl  0x10(%esi)
f01008d3:	ff 76 0c             	pushl  0xc(%esi)
f01008d6:	ff 76 08             	pushl  0x8(%esi)
f01008d9:	57                   	push   %edi
f01008da:	56                   	push   %esi
f01008db:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008de:	e8 3c 02 00 00       	call   f0100b1f <cprintf>
		if(!debuginfo_eip(eip, &info)) {
f01008e3:	83 c4 18             	add    $0x18,%esp
f01008e6:	ff 75 c0             	pushl  -0x40(%ebp)
f01008e9:	57                   	push   %edi
f01008ea:	e8 34 03 00 00       	call   f0100c23 <debuginfo_eip>
f01008ef:	83 c4 10             	add    $0x10,%esp
f01008f2:	85 c0                	test   %eax,%eax
f01008f4:	75 cb                	jne    f01008c1 <mon_backtrace+0x36>
			cprintf("\t%s:%d: %.*s+%d\n",
f01008f6:	83 ec 08             	sub    $0x8,%esp
f01008f9:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01008fc:	57                   	push   %edi
f01008fd:	ff 75 d8             	pushl  -0x28(%ebp)
f0100900:	ff 75 dc             	pushl  -0x24(%ebp)
f0100903:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100906:	ff 75 d0             	pushl  -0x30(%ebp)
f0100909:	8d 83 d4 0b ff ff    	lea    -0xf42c(%ebx),%eax
f010090f:	50                   	push   %eax
f0100910:	e8 0a 02 00 00       	call   f0100b1f <cprintf>
f0100915:	83 c4 20             	add    $0x20,%esp
f0100918:	eb a7                	jmp    f01008c1 <mon_backtrace+0x36>
	}
	return 0;
#undef READ
}
f010091a:	b8 00 00 00 00       	mov    $0x0,%eax
f010091f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100922:	5b                   	pop    %ebx
f0100923:	5e                   	pop    %esi
f0100924:	5f                   	pop    %edi
f0100925:	5d                   	pop    %ebp
f0100926:	c3                   	ret    

f0100927 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100927:	55                   	push   %ebp
f0100928:	89 e5                	mov    %esp,%ebp
f010092a:	57                   	push   %edi
f010092b:	56                   	push   %esi
f010092c:	53                   	push   %ebx
f010092d:	83 ec 68             	sub    $0x68,%esp
f0100930:	e8 87 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100935:	81 c3 d7 09 01 00    	add    $0x109d7,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010093b:	8d 83 b8 0d ff ff    	lea    -0xf248(%ebx),%eax
f0100941:	50                   	push   %eax
f0100942:	e8 d8 01 00 00       	call   f0100b1f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100947:	8d 83 dc 0d ff ff    	lea    -0xf224(%ebx),%eax
f010094d:	89 04 24             	mov    %eax,(%esp)
f0100950:	e8 ca 01 00 00       	call   f0100b1f <cprintf>
	cprintf("Printf something in %Cred.\n", COLOR_RED);
f0100955:	83 c4 08             	add    $0x8,%esp
f0100958:	68 00 04 00 00       	push   $0x400
f010095d:	8d 83 e5 0b ff ff    	lea    -0xf41b(%ebx),%eax
f0100963:	50                   	push   %eax
f0100964:	e8 b6 01 00 00       	call   f0100b1f <cprintf>
	cprintf("Printf something in %Cgreen.\n", COLOR_GREEN);
f0100969:	83 c4 08             	add    $0x8,%esp
f010096c:	68 00 02 00 00       	push   $0x200
f0100971:	8d 83 01 0c ff ff    	lea    -0xf3ff(%ebx),%eax
f0100977:	50                   	push   %eax
f0100978:	e8 a2 01 00 00       	call   f0100b1f <cprintf>
	cprintf("Printf something in %Cblue.\n", COLOR_BLUE);
f010097d:	83 c4 08             	add    $0x8,%esp
f0100980:	68 00 01 00 00       	push   $0x100
f0100985:	8d 83 1f 0c ff ff    	lea    -0xf3e1(%ebx),%eax
f010098b:	50                   	push   %eax
f010098c:	e8 8e 01 00 00       	call   f0100b1f <cprintf>
f0100991:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100994:	8d bb 40 0c ff ff    	lea    -0xf3c0(%ebx),%edi
f010099a:	eb 4a                	jmp    f01009e6 <monitor+0xbf>
f010099c:	83 ec 08             	sub    $0x8,%esp
f010099f:	0f be c0             	movsbl %al,%eax
f01009a2:	50                   	push   %eax
f01009a3:	57                   	push   %edi
f01009a4:	e8 90 0d 00 00       	call   f0101739 <strchr>
f01009a9:	83 c4 10             	add    $0x10,%esp
f01009ac:	85 c0                	test   %eax,%eax
f01009ae:	74 08                	je     f01009b8 <monitor+0x91>
			*buf++ = 0;
f01009b0:	c6 06 00             	movb   $0x0,(%esi)
f01009b3:	8d 76 01             	lea    0x1(%esi),%esi
f01009b6:	eb 79                	jmp    f0100a31 <monitor+0x10a>
		if (*buf == 0)
f01009b8:	80 3e 00             	cmpb   $0x0,(%esi)
f01009bb:	74 7f                	je     f0100a3c <monitor+0x115>
		if (argc == MAXARGS-1) {
f01009bd:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009c1:	74 0f                	je     f01009d2 <monitor+0xab>
		argv[argc++] = buf;
f01009c3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009c6:	8d 48 01             	lea    0x1(%eax),%ecx
f01009c9:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009cc:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009d0:	eb 44                	jmp    f0100a16 <monitor+0xef>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009d2:	83 ec 08             	sub    $0x8,%esp
f01009d5:	6a 10                	push   $0x10
f01009d7:	8d 83 45 0c ff ff    	lea    -0xf3bb(%ebx),%eax
f01009dd:	50                   	push   %eax
f01009de:	e8 3c 01 00 00       	call   f0100b1f <cprintf>
f01009e3:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009e6:	8d 83 3c 0c ff ff    	lea    -0xf3c4(%ebx),%eax
f01009ec:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009ef:	83 ec 0c             	sub    $0xc,%esp
f01009f2:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009f5:	e8 07 0b 00 00       	call   f0101501 <readline>
f01009fa:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009fc:	83 c4 10             	add    $0x10,%esp
f01009ff:	85 c0                	test   %eax,%eax
f0100a01:	74 ec                	je     f01009ef <monitor+0xc8>
	argv[argc] = 0;
f0100a03:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a0a:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a11:	eb 1e                	jmp    f0100a31 <monitor+0x10a>
			buf++;
f0100a13:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a16:	0f b6 06             	movzbl (%esi),%eax
f0100a19:	84 c0                	test   %al,%al
f0100a1b:	74 14                	je     f0100a31 <monitor+0x10a>
f0100a1d:	83 ec 08             	sub    $0x8,%esp
f0100a20:	0f be c0             	movsbl %al,%eax
f0100a23:	50                   	push   %eax
f0100a24:	57                   	push   %edi
f0100a25:	e8 0f 0d 00 00       	call   f0101739 <strchr>
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	74 e2                	je     f0100a13 <monitor+0xec>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a31:	0f b6 06             	movzbl (%esi),%eax
f0100a34:	84 c0                	test   %al,%al
f0100a36:	0f 85 60 ff ff ff    	jne    f010099c <monitor+0x75>
	argv[argc] = 0;
f0100a3c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a3f:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a46:	00 
	if (argc == 0)
f0100a47:	85 c0                	test   %eax,%eax
f0100a49:	74 9b                	je     f01009e6 <monitor+0xbf>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a4b:	83 ec 08             	sub    $0x8,%esp
f0100a4e:	8d 83 92 0b ff ff    	lea    -0xf46e(%ebx),%eax
f0100a54:	50                   	push   %eax
f0100a55:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a58:	e8 7e 0c 00 00       	call   f01016db <strcmp>
f0100a5d:	83 c4 10             	add    $0x10,%esp
f0100a60:	85 c0                	test   %eax,%eax
f0100a62:	74 38                	je     f0100a9c <monitor+0x175>
f0100a64:	83 ec 08             	sub    $0x8,%esp
f0100a67:	8d 83 a0 0b ff ff    	lea    -0xf460(%ebx),%eax
f0100a6d:	50                   	push   %eax
f0100a6e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a71:	e8 65 0c 00 00       	call   f01016db <strcmp>
f0100a76:	83 c4 10             	add    $0x10,%esp
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	74 1a                	je     f0100a97 <monitor+0x170>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a7d:	83 ec 08             	sub    $0x8,%esp
f0100a80:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a83:	8d 83 62 0c ff ff    	lea    -0xf39e(%ebx),%eax
f0100a89:	50                   	push   %eax
f0100a8a:	e8 90 00 00 00       	call   f0100b1f <cprintf>
f0100a8f:	83 c4 10             	add    $0x10,%esp
f0100a92:	e9 4f ff ff ff       	jmp    f01009e6 <monitor+0xbf>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a97:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a9c:	83 ec 04             	sub    $0x4,%esp
f0100a9f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100aa2:	ff 75 08             	pushl  0x8(%ebp)
f0100aa5:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100aa8:	52                   	push   %edx
f0100aa9:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100aac:	ff 94 83 0c 1d 00 00 	call   *0x1d0c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ab3:	83 c4 10             	add    $0x10,%esp
f0100ab6:	85 c0                	test   %eax,%eax
f0100ab8:	0f 89 28 ff ff ff    	jns    f01009e6 <monitor+0xbf>
				break;
	}
}
f0100abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ac1:	5b                   	pop    %ebx
f0100ac2:	5e                   	pop    %esi
f0100ac3:	5f                   	pop    %edi
f0100ac4:	5d                   	pop    %ebp
f0100ac5:	c3                   	ret    

f0100ac6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ac6:	55                   	push   %ebp
f0100ac7:	89 e5                	mov    %esp,%ebp
f0100ac9:	53                   	push   %ebx
f0100aca:	83 ec 10             	sub    $0x10,%esp
f0100acd:	e8 ea f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ad2:	81 c3 3a 08 01 00    	add    $0x1083a,%ebx
	cputchar(ch);
f0100ad8:	ff 75 08             	pushl  0x8(%ebp)
f0100adb:	e8 5b fc ff ff       	call   f010073b <cputchar>
	*cnt++;
}
f0100ae0:	83 c4 10             	add    $0x10,%esp
f0100ae3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ae6:	c9                   	leave  
f0100ae7:	c3                   	ret    

f0100ae8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100ae8:	55                   	push   %ebp
f0100ae9:	89 e5                	mov    %esp,%ebp
f0100aeb:	53                   	push   %ebx
f0100aec:	83 ec 14             	sub    $0x14,%esp
f0100aef:	e8 c8 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100af4:	81 c3 18 08 01 00    	add    $0x10818,%ebx
	int cnt = 0;
f0100afa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b01:	ff 75 0c             	pushl  0xc(%ebp)
f0100b04:	ff 75 08             	pushl  0x8(%ebp)
f0100b07:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b0a:	50                   	push   %eax
f0100b0b:	8d 83 ba f7 fe ff    	lea    -0x10846(%ebx),%eax
f0100b11:	50                   	push   %eax
f0100b12:	e8 8d 04 00 00       	call   f0100fa4 <vprintfmt>
	return cnt;
}
f0100b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b1d:	c9                   	leave  
f0100b1e:	c3                   	ret    

f0100b1f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b1f:	55                   	push   %ebp
f0100b20:	89 e5                	mov    %esp,%ebp
f0100b22:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b25:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b28:	50                   	push   %eax
f0100b29:	ff 75 08             	pushl  0x8(%ebp)
f0100b2c:	e8 b7 ff ff ff       	call   f0100ae8 <vcprintf>
	va_end(ap);

	return cnt;
f0100b31:	c9                   	leave  
f0100b32:	c3                   	ret    

f0100b33 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	57                   	push   %edi
f0100b37:	56                   	push   %esi
f0100b38:	53                   	push   %ebx
f0100b39:	83 ec 14             	sub    $0x14,%esp
f0100b3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b3f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b42:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b45:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b48:	8b 32                	mov    (%edx),%esi
f0100b4a:	8b 01                	mov    (%ecx),%eax
f0100b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b4f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b56:	eb 2f                	jmp    f0100b87 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b58:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b5b:	39 c6                	cmp    %eax,%esi
f0100b5d:	7f 49                	jg     f0100ba8 <stab_binsearch+0x75>
f0100b5f:	0f b6 0a             	movzbl (%edx),%ecx
f0100b62:	83 ea 0c             	sub    $0xc,%edx
f0100b65:	39 f9                	cmp    %edi,%ecx
f0100b67:	75 ef                	jne    f0100b58 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b69:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b6c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b6f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b73:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b76:	73 35                	jae    f0100bad <stab_binsearch+0x7a>
			*region_left = m;
f0100b78:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b7b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b7d:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b80:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b87:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b8a:	7f 4e                	jg     f0100bda <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b8f:	01 f0                	add    %esi,%eax
f0100b91:	89 c3                	mov    %eax,%ebx
f0100b93:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b96:	01 c3                	add    %eax,%ebx
f0100b98:	d1 fb                	sar    %ebx
f0100b9a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b9d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ba0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100ba4:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100ba6:	eb b3                	jmp    f0100b5b <stab_binsearch+0x28>
			l = true_m + 1;
f0100ba8:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100bab:	eb da                	jmp    f0100b87 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100bad:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bb0:	76 14                	jbe    f0100bc6 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100bb2:	83 e8 01             	sub    $0x1,%eax
f0100bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bb8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100bbb:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100bbd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bc4:	eb c1                	jmp    f0100b87 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bc6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bc9:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100bcb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bcf:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100bd1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bd8:	eb ad                	jmp    f0100b87 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100bda:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bde:	74 16                	je     f0100bf6 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100be0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100be5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100be8:	8b 0e                	mov    (%esi),%ecx
f0100bea:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bed:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bf0:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bf4:	eb 12                	jmp    f0100c08 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf9:	8b 00                	mov    (%eax),%eax
f0100bfb:	83 e8 01             	sub    $0x1,%eax
f0100bfe:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c01:	89 07                	mov    %eax,(%edi)
f0100c03:	eb 16                	jmp    f0100c1b <stab_binsearch+0xe8>
		     l--)
f0100c05:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100c08:	39 c1                	cmp    %eax,%ecx
f0100c0a:	7d 0a                	jge    f0100c16 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100c0c:	0f b6 1a             	movzbl (%edx),%ebx
f0100c0f:	83 ea 0c             	sub    $0xc,%edx
f0100c12:	39 fb                	cmp    %edi,%ebx
f0100c14:	75 ef                	jne    f0100c05 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100c16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c19:	89 07                	mov    %eax,(%edi)
	}
}
f0100c1b:	83 c4 14             	add    $0x14,%esp
f0100c1e:	5b                   	pop    %ebx
f0100c1f:	5e                   	pop    %esi
f0100c20:	5f                   	pop    %edi
f0100c21:	5d                   	pop    %ebp
f0100c22:	c3                   	ret    

f0100c23 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c23:	55                   	push   %ebp
f0100c24:	89 e5                	mov    %esp,%ebp
f0100c26:	57                   	push   %edi
f0100c27:	56                   	push   %esi
f0100c28:	53                   	push   %ebx
f0100c29:	83 ec 3c             	sub    $0x3c,%esp
f0100c2c:	e8 8b f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c31:	81 c3 db 06 01 00    	add    $0x106db,%ebx
f0100c37:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c3a:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c3d:	8d 83 04 0e ff ff    	lea    -0xf1fc(%ebx),%eax
f0100c43:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c45:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c4c:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c4f:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c56:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c59:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c60:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c66:	0f 86 2f 01 00 00    	jbe    f0100d9b <debuginfo_eip+0x178>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c6c:	c7 c0 f5 60 10 f0    	mov    $0xf01060f5,%eax
f0100c72:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c78:	0f 86 00 02 00 00    	jbe    f0100e7e <debuginfo_eip+0x25b>
f0100c7e:	c7 c0 82 7a 10 f0    	mov    $0xf0107a82,%eax
f0100c84:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c88:	0f 85 f7 01 00 00    	jne    f0100e85 <debuginfo_eip+0x262>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c8e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c95:	c7 c0 2c 23 10 f0    	mov    $0xf010232c,%eax
f0100c9b:	c7 c2 f4 60 10 f0    	mov    $0xf01060f4,%edx
f0100ca1:	29 c2                	sub    %eax,%edx
f0100ca3:	c1 fa 02             	sar    $0x2,%edx
f0100ca6:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100cac:	83 ea 01             	sub    $0x1,%edx
f0100caf:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cb2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cb5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cb8:	83 ec 08             	sub    $0x8,%esp
f0100cbb:	57                   	push   %edi
f0100cbc:	6a 64                	push   $0x64
f0100cbe:	e8 70 fe ff ff       	call   f0100b33 <stab_binsearch>
	if (lfile == 0)
f0100cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cc6:	83 c4 10             	add    $0x10,%esp
f0100cc9:	85 c0                	test   %eax,%eax
f0100ccb:	0f 84 bb 01 00 00    	je     f0100e8c <debuginfo_eip+0x269>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cd1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100cd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cd7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cda:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cdd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ce0:	83 ec 08             	sub    $0x8,%esp
f0100ce3:	57                   	push   %edi
f0100ce4:	6a 24                	push   $0x24
f0100ce6:	c7 c0 2c 23 10 f0    	mov    $0xf010232c,%eax
f0100cec:	e8 42 fe ff ff       	call   f0100b33 <stab_binsearch>

	if (lfun <= rfun) {
f0100cf1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cf4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cf7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100cfa:	83 c4 10             	add    $0x10,%esp
f0100cfd:	39 c8                	cmp    %ecx,%eax
f0100cff:	0f 8f ae 00 00 00    	jg     f0100db3 <debuginfo_eip+0x190>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d05:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d08:	c7 c1 2c 23 10 f0    	mov    $0xf010232c,%ecx
f0100d0e:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d11:	8b 11                	mov    (%ecx),%edx
f0100d13:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d16:	c7 c2 82 7a 10 f0    	mov    $0xf0107a82,%edx
f0100d1c:	81 ea f5 60 10 f0    	sub    $0xf01060f5,%edx
f0100d22:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100d25:	73 0c                	jae    f0100d33 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d27:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d2a:	81 c2 f5 60 10 f0    	add    $0xf01060f5,%edx
f0100d30:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d33:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d36:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d39:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d3e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d41:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d44:	83 ec 08             	sub    $0x8,%esp
f0100d47:	6a 3a                	push   $0x3a
f0100d49:	ff 76 08             	pushl  0x8(%esi)
f0100d4c:	e8 09 0a 00 00       	call   f010175a <strfind>
f0100d51:	2b 46 08             	sub    0x8(%esi),%eax
f0100d54:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d57:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d5a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d5d:	83 c4 08             	add    $0x8,%esp
f0100d60:	57                   	push   %edi
f0100d61:	6a 44                	push   $0x44
f0100d63:	c7 c7 2c 23 10 f0    	mov    $0xf010232c,%edi
f0100d69:	89 f8                	mov    %edi,%eax
f0100d6b:	e8 c3 fd ff ff       	call   f0100b33 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100d70:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d73:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d76:	c1 e2 02             	shl    $0x2,%edx
f0100d79:	0f b7 4c 3a 06       	movzwl 0x6(%edx,%edi,1),%ecx
f0100d7e:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d81:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d84:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0100d88:	83 c4 10             	add    $0x10,%esp
f0100d8b:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0100d8f:	bf 01 00 00 00       	mov    $0x1,%edi
f0100d94:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100d97:	89 ce                	mov    %ecx,%esi
f0100d99:	eb 34                	jmp    f0100dcf <debuginfo_eip+0x1ac>
  	        panic("User address");
f0100d9b:	83 ec 04             	sub    $0x4,%esp
f0100d9e:	8d 83 0e 0e ff ff    	lea    -0xf1f2(%ebx),%eax
f0100da4:	50                   	push   %eax
f0100da5:	6a 7f                	push   $0x7f
f0100da7:	8d 83 1b 0e ff ff    	lea    -0xf1e5(%ebx),%eax
f0100dad:	50                   	push   %eax
f0100dae:	e8 53 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100db3:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100db9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100dbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dbf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dc2:	eb 80                	jmp    f0100d44 <debuginfo_eip+0x121>
f0100dc4:	83 e8 01             	sub    $0x1,%eax
f0100dc7:	83 ea 0c             	sub    $0xc,%edx
f0100dca:	89 f9                	mov    %edi,%ecx
f0100dcc:	88 4d c0             	mov    %cl,-0x40(%ebp)
f0100dcf:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0100dd2:	39 c6                	cmp    %eax,%esi
f0100dd4:	7f 2a                	jg     f0100e00 <debuginfo_eip+0x1dd>
f0100dd6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	       && stabs[lline].n_type != N_SOL
f0100dd9:	0f b6 0a             	movzbl (%edx),%ecx
f0100ddc:	80 f9 84             	cmp    $0x84,%cl
f0100ddf:	74 49                	je     f0100e2a <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100de1:	80 f9 64             	cmp    $0x64,%cl
f0100de4:	75 de                	jne    f0100dc4 <debuginfo_eip+0x1a1>
f0100de6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100de9:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
f0100ded:	74 d5                	je     f0100dc4 <debuginfo_eip+0x1a1>
f0100def:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100df2:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0100df6:	74 3b                	je     f0100e33 <debuginfo_eip+0x210>
f0100df8:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100dfb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100dfe:	eb 33                	jmp    f0100e33 <debuginfo_eip+0x210>
f0100e00:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e03:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e06:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e09:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e0e:	39 fa                	cmp    %edi,%edx
f0100e10:	0f 8d 82 00 00 00    	jge    f0100e98 <debuginfo_eip+0x275>
		for (lline = lfun + 1;
f0100e16:	83 c2 01             	add    $0x1,%edx
f0100e19:	89 d0                	mov    %edx,%eax
f0100e1b:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e1e:	c7 c2 2c 23 10 f0    	mov    $0xf010232c,%edx
f0100e24:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e28:	eb 3b                	jmp    f0100e65 <debuginfo_eip+0x242>
f0100e2a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e2d:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0100e31:	75 26                	jne    f0100e59 <debuginfo_eip+0x236>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e33:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e36:	c7 c0 2c 23 10 f0    	mov    $0xf010232c,%eax
f0100e3c:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e3f:	c7 c0 82 7a 10 f0    	mov    $0xf0107a82,%eax
f0100e45:	81 e8 f5 60 10 f0    	sub    $0xf01060f5,%eax
f0100e4b:	39 c2                	cmp    %eax,%edx
f0100e4d:	73 b4                	jae    f0100e03 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e4f:	81 c2 f5 60 10 f0    	add    $0xf01060f5,%edx
f0100e55:	89 16                	mov    %edx,(%esi)
f0100e57:	eb aa                	jmp    f0100e03 <debuginfo_eip+0x1e0>
f0100e59:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100e5c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e5f:	eb d2                	jmp    f0100e33 <debuginfo_eip+0x210>
			info->eip_fn_narg++;
f0100e61:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e65:	39 c7                	cmp    %eax,%edi
f0100e67:	7e 2a                	jle    f0100e93 <debuginfo_eip+0x270>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e69:	0f b6 0a             	movzbl (%edx),%ecx
f0100e6c:	83 c0 01             	add    $0x1,%eax
f0100e6f:	83 c2 0c             	add    $0xc,%edx
f0100e72:	80 f9 a0             	cmp    $0xa0,%cl
f0100e75:	74 ea                	je     f0100e61 <debuginfo_eip+0x23e>
	return 0;
f0100e77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7c:	eb 1a                	jmp    f0100e98 <debuginfo_eip+0x275>
		return -1;
f0100e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e83:	eb 13                	jmp    f0100e98 <debuginfo_eip+0x275>
f0100e85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8a:	eb 0c                	jmp    f0100e98 <debuginfo_eip+0x275>
		return -1;
f0100e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e91:	eb 05                	jmp    f0100e98 <debuginfo_eip+0x275>
	return 0;
f0100e93:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e9b:	5b                   	pop    %ebx
f0100e9c:	5e                   	pop    %esi
f0100e9d:	5f                   	pop    %edi
f0100e9e:	5d                   	pop    %ebp
f0100e9f:	c3                   	ret    

f0100ea0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ea0:	55                   	push   %ebp
f0100ea1:	89 e5                	mov    %esp,%ebp
f0100ea3:	57                   	push   %edi
f0100ea4:	56                   	push   %esi
f0100ea5:	53                   	push   %ebx
f0100ea6:	83 ec 2c             	sub    $0x2c,%esp
f0100ea9:	e8 4f 06 00 00       	call   f01014fd <__x86.get_pc_thunk.cx>
f0100eae:	81 c1 5e 04 01 00    	add    $0x1045e,%ecx
f0100eb4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100eb7:	89 c7                	mov    %eax,%edi
f0100eb9:	89 d6                	mov    %edx,%esi
f0100ebb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ec1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ec4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ec7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100eca:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ecf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100ed2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100ed5:	39 d3                	cmp    %edx,%ebx
f0100ed7:	72 09                	jb     f0100ee2 <printnum+0x42>
f0100ed9:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100edc:	0f 87 83 00 00 00    	ja     f0100f65 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ee2:	83 ec 0c             	sub    $0xc,%esp
f0100ee5:	ff 75 18             	pushl  0x18(%ebp)
f0100ee8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eeb:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100eee:	53                   	push   %ebx
f0100eef:	ff 75 10             	pushl  0x10(%ebp)
f0100ef2:	83 ec 08             	sub    $0x8,%esp
f0100ef5:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ef8:	ff 75 d8             	pushl  -0x28(%ebp)
f0100efb:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100efe:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f01:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f04:	e8 77 0a 00 00       	call   f0101980 <__udivdi3>
f0100f09:	83 c4 18             	add    $0x18,%esp
f0100f0c:	52                   	push   %edx
f0100f0d:	50                   	push   %eax
f0100f0e:	89 f2                	mov    %esi,%edx
f0100f10:	89 f8                	mov    %edi,%eax
f0100f12:	e8 89 ff ff ff       	call   f0100ea0 <printnum>
f0100f17:	83 c4 20             	add    $0x20,%esp
f0100f1a:	eb 13                	jmp    f0100f2f <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f1c:	83 ec 08             	sub    $0x8,%esp
f0100f1f:	56                   	push   %esi
f0100f20:	ff 75 18             	pushl  0x18(%ebp)
f0100f23:	ff d7                	call   *%edi
f0100f25:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f28:	83 eb 01             	sub    $0x1,%ebx
f0100f2b:	85 db                	test   %ebx,%ebx
f0100f2d:	7f ed                	jg     f0100f1c <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f2f:	83 ec 08             	sub    $0x8,%esp
f0100f32:	56                   	push   %esi
f0100f33:	83 ec 04             	sub    $0x4,%esp
f0100f36:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f39:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f3c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f3f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f42:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f45:	89 f3                	mov    %esi,%ebx
f0100f47:	e8 54 0b 00 00       	call   f0101aa0 <__umoddi3>
f0100f4c:	83 c4 14             	add    $0x14,%esp
f0100f4f:	0f be 84 06 29 0e ff 	movsbl -0xf1d7(%esi,%eax,1),%eax
f0100f56:	ff 
f0100f57:	50                   	push   %eax
f0100f58:	ff d7                	call   *%edi
}
f0100f5a:	83 c4 10             	add    $0x10,%esp
f0100f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f60:	5b                   	pop    %ebx
f0100f61:	5e                   	pop    %esi
f0100f62:	5f                   	pop    %edi
f0100f63:	5d                   	pop    %ebp
f0100f64:	c3                   	ret    
f0100f65:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f68:	eb be                	jmp    f0100f28 <printnum+0x88>

f0100f6a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f6a:	55                   	push   %ebp
f0100f6b:	89 e5                	mov    %esp,%ebp
f0100f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f70:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f74:	8b 10                	mov    (%eax),%edx
f0100f76:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f79:	73 0a                	jae    f0100f85 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f7b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f7e:	89 08                	mov    %ecx,(%eax)
f0100f80:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f83:	88 02                	mov    %al,(%edx)
}
f0100f85:	5d                   	pop    %ebp
f0100f86:	c3                   	ret    

f0100f87 <printfmt>:
{
f0100f87:	55                   	push   %ebp
f0100f88:	89 e5                	mov    %esp,%ebp
f0100f8a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f8d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f90:	50                   	push   %eax
f0100f91:	ff 75 10             	pushl  0x10(%ebp)
f0100f94:	ff 75 0c             	pushl  0xc(%ebp)
f0100f97:	ff 75 08             	pushl  0x8(%ebp)
f0100f9a:	e8 05 00 00 00       	call   f0100fa4 <vprintfmt>
}
f0100f9f:	83 c4 10             	add    $0x10,%esp
f0100fa2:	c9                   	leave  
f0100fa3:	c3                   	ret    

f0100fa4 <vprintfmt>:
{
f0100fa4:	55                   	push   %ebp
f0100fa5:	89 e5                	mov    %esp,%ebp
f0100fa7:	57                   	push   %edi
f0100fa8:	56                   	push   %esi
f0100fa9:	53                   	push   %ebx
f0100faa:	83 ec 3c             	sub    $0x3c,%esp
f0100fad:	e8 0a f2 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100fb2:	81 c3 5a 03 01 00    	add    $0x1035a,%ebx
f0100fb8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fbb:	8b 7d 10             	mov    0x10(%ebp),%edi
			color = num;
f0100fbe:	c7 c0 00 13 11 f0    	mov    $0xf0111300,%eax
f0100fc4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100fc7:	e9 07 04 00 00       	jmp    f01013d3 <.L36+0x48>
		padc = ' ';
f0100fcc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100fd0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100fd7:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100fde:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100fe5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fea:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fed:	8d 47 01             	lea    0x1(%edi),%eax
f0100ff0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ff3:	0f b6 17             	movzbl (%edi),%edx
f0100ff6:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100ff9:	3c 55                	cmp    $0x55,%al
f0100ffb:	0f 87 5a 04 00 00    	ja     f010145b <.L22>
f0101001:	0f b6 c0             	movzbl %al,%eax
f0101004:	89 d9                	mov    %ebx,%ecx
f0101006:	03 8c 83 b8 0e ff ff 	add    -0xf148(%ebx,%eax,4),%ecx
f010100d:	ff e1                	jmp    *%ecx

f010100f <.L73>:
f010100f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0101012:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0101016:	eb d5                	jmp    f0100fed <vprintfmt+0x49>

f0101018 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0101018:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f010101b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010101f:	eb cc                	jmp    f0100fed <vprintfmt+0x49>

f0101021 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0101021:	0f b6 d2             	movzbl %dl,%edx
f0101024:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0101027:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f010102c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010102f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101033:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0101036:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101039:	83 f9 09             	cmp    $0x9,%ecx
f010103c:	77 55                	ja     f0101093 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f010103e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0101041:	eb e9                	jmp    f010102c <.L29+0xb>

f0101043 <.L26>:
			precision = va_arg(ap, int);
f0101043:	8b 45 14             	mov    0x14(%ebp),%eax
f0101046:	8b 00                	mov    (%eax),%eax
f0101048:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010104b:	8b 45 14             	mov    0x14(%ebp),%eax
f010104e:	8d 40 04             	lea    0x4(%eax),%eax
f0101051:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101054:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101057:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010105b:	79 90                	jns    f0100fed <vprintfmt+0x49>
				width = precision, precision = -1;
f010105d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101060:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101063:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010106a:	eb 81                	jmp    f0100fed <vprintfmt+0x49>

f010106c <.L27>:
f010106c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010106f:	85 c0                	test   %eax,%eax
f0101071:	ba 00 00 00 00       	mov    $0x0,%edx
f0101076:	0f 49 d0             	cmovns %eax,%edx
f0101079:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010107c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010107f:	e9 69 ff ff ff       	jmp    f0100fed <vprintfmt+0x49>

f0101084 <.L23>:
f0101084:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101087:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010108e:	e9 5a ff ff ff       	jmp    f0100fed <vprintfmt+0x49>
f0101093:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101096:	eb bf                	jmp    f0101057 <.L26+0x14>

f0101098 <.L34>:
			lflag++;
f0101098:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010109c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f010109f:	e9 49 ff ff ff       	jmp    f0100fed <vprintfmt+0x49>

f01010a4 <.L31>:
			putch(va_arg(ap, int), putdat);
f01010a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a7:	8d 78 04             	lea    0x4(%eax),%edi
f01010aa:	83 ec 08             	sub    $0x8,%esp
f01010ad:	56                   	push   %esi
f01010ae:	ff 30                	pushl  (%eax)
f01010b0:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010b3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010b6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01010b9:	e9 12 03 00 00       	jmp    f01013d0 <.L36+0x45>

f01010be <.L30>:
f01010be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01010c1:	83 f9 01             	cmp    $0x1,%ecx
f01010c4:	7e 18                	jle    f01010de <.L30+0x20>
		return va_arg(*ap, long long);
f01010c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c9:	8b 00                	mov    (%eax),%eax
f01010cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01010ce:	8d 49 08             	lea    0x8(%ecx),%ecx
f01010d1:	89 4d 14             	mov    %ecx,0x14(%ebp)
			color = num;
f01010d4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01010d7:	89 01                	mov    %eax,(%ecx)
			break;
f01010d9:	e9 f2 02 00 00       	jmp    f01013d0 <.L36+0x45>
	else if (lflag)
f01010de:	85 c9                	test   %ecx,%ecx
f01010e0:	75 10                	jne    f01010f2 <.L30+0x34>
		return va_arg(*ap, int);
f01010e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e5:	8b 00                	mov    (%eax),%eax
f01010e7:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01010ea:	8d 49 04             	lea    0x4(%ecx),%ecx
f01010ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01010f0:	eb e2                	jmp    f01010d4 <.L30+0x16>
		return va_arg(*ap, long);
f01010f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f5:	8b 00                	mov    (%eax),%eax
f01010f7:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01010fa:	8d 49 04             	lea    0x4(%ecx),%ecx
f01010fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101100:	eb d2                	jmp    f01010d4 <.L30+0x16>

f0101102 <.L33>:
			err = va_arg(ap, int);
f0101102:	8b 45 14             	mov    0x14(%ebp),%eax
f0101105:	8d 78 04             	lea    0x4(%eax),%edi
f0101108:	8b 00                	mov    (%eax),%eax
f010110a:	99                   	cltd   
f010110b:	31 d0                	xor    %edx,%eax
f010110d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010110f:	83 f8 06             	cmp    $0x6,%eax
f0101112:	7f 27                	jg     f010113b <.L33+0x39>
f0101114:	8b 94 83 1c 1d 00 00 	mov    0x1d1c(%ebx,%eax,4),%edx
f010111b:	85 d2                	test   %edx,%edx
f010111d:	74 1c                	je     f010113b <.L33+0x39>
				printfmt(putch, putdat, "%s", p);
f010111f:	52                   	push   %edx
f0101120:	8d 83 4a 0e ff ff    	lea    -0xf1b6(%ebx),%eax
f0101126:	50                   	push   %eax
f0101127:	56                   	push   %esi
f0101128:	ff 75 08             	pushl  0x8(%ebp)
f010112b:	e8 57 fe ff ff       	call   f0100f87 <printfmt>
f0101130:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101133:	89 7d 14             	mov    %edi,0x14(%ebp)
f0101136:	e9 95 02 00 00       	jmp    f01013d0 <.L36+0x45>
				printfmt(putch, putdat, "error %d", err);
f010113b:	50                   	push   %eax
f010113c:	8d 83 41 0e ff ff    	lea    -0xf1bf(%ebx),%eax
f0101142:	50                   	push   %eax
f0101143:	56                   	push   %esi
f0101144:	ff 75 08             	pushl  0x8(%ebp)
f0101147:	e8 3b fe ff ff       	call   f0100f87 <printfmt>
f010114c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010114f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101152:	e9 79 02 00 00       	jmp    f01013d0 <.L36+0x45>

f0101157 <.L37>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101157:	8b 45 14             	mov    0x14(%ebp),%eax
f010115a:	83 c0 04             	add    $0x4,%eax
f010115d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101160:	8b 45 14             	mov    0x14(%ebp),%eax
f0101163:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101165:	85 ff                	test   %edi,%edi
f0101167:	8d 83 3a 0e ff ff    	lea    -0xf1c6(%ebx),%eax
f010116d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101170:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101174:	0f 8e b5 00 00 00    	jle    f010122f <.L37+0xd8>
f010117a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010117e:	75 08                	jne    f0101188 <.L37+0x31>
f0101180:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101183:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101186:	eb 6d                	jmp    f01011f5 <.L37+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101188:	83 ec 08             	sub    $0x8,%esp
f010118b:	ff 75 cc             	pushl  -0x34(%ebp)
f010118e:	57                   	push   %edi
f010118f:	e8 82 04 00 00       	call   f0101616 <strnlen>
f0101194:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101197:	29 c2                	sub    %eax,%edx
f0101199:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010119c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010119f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01011a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011a6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01011a9:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01011ab:	eb 10                	jmp    f01011bd <.L37+0x66>
					putch(padc, putdat);
f01011ad:	83 ec 08             	sub    $0x8,%esp
f01011b0:	56                   	push   %esi
f01011b1:	ff 75 e0             	pushl  -0x20(%ebp)
f01011b4:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01011b7:	83 ef 01             	sub    $0x1,%edi
f01011ba:	83 c4 10             	add    $0x10,%esp
f01011bd:	85 ff                	test   %edi,%edi
f01011bf:	7f ec                	jg     f01011ad <.L37+0x56>
f01011c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01011c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01011c7:	85 d2                	test   %edx,%edx
f01011c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01011ce:	0f 49 c2             	cmovns %edx,%eax
f01011d1:	29 c2                	sub    %eax,%edx
f01011d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01011d6:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011d9:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011dc:	eb 17                	jmp    f01011f5 <.L37+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01011de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011e2:	75 30                	jne    f0101214 <.L37+0xbd>
					putch(ch, putdat);
f01011e4:	83 ec 08             	sub    $0x8,%esp
f01011e7:	ff 75 0c             	pushl  0xc(%ebp)
f01011ea:	50                   	push   %eax
f01011eb:	ff 55 08             	call   *0x8(%ebp)
f01011ee:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011f1:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01011f5:	83 c7 01             	add    $0x1,%edi
f01011f8:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01011fc:	0f be c2             	movsbl %dl,%eax
f01011ff:	85 c0                	test   %eax,%eax
f0101201:	74 52                	je     f0101255 <.L37+0xfe>
f0101203:	85 f6                	test   %esi,%esi
f0101205:	78 d7                	js     f01011de <.L37+0x87>
f0101207:	83 ee 01             	sub    $0x1,%esi
f010120a:	79 d2                	jns    f01011de <.L37+0x87>
f010120c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010120f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101212:	eb 32                	jmp    f0101246 <.L37+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0101214:	0f be d2             	movsbl %dl,%edx
f0101217:	83 ea 20             	sub    $0x20,%edx
f010121a:	83 fa 5e             	cmp    $0x5e,%edx
f010121d:	76 c5                	jbe    f01011e4 <.L37+0x8d>
					putch('?', putdat);
f010121f:	83 ec 08             	sub    $0x8,%esp
f0101222:	ff 75 0c             	pushl  0xc(%ebp)
f0101225:	6a 3f                	push   $0x3f
f0101227:	ff 55 08             	call   *0x8(%ebp)
f010122a:	83 c4 10             	add    $0x10,%esp
f010122d:	eb c2                	jmp    f01011f1 <.L37+0x9a>
f010122f:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101232:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101235:	eb be                	jmp    f01011f5 <.L37+0x9e>
				putch(' ', putdat);
f0101237:	83 ec 08             	sub    $0x8,%esp
f010123a:	56                   	push   %esi
f010123b:	6a 20                	push   $0x20
f010123d:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0101240:	83 ef 01             	sub    $0x1,%edi
f0101243:	83 c4 10             	add    $0x10,%esp
f0101246:	85 ff                	test   %edi,%edi
f0101248:	7f ed                	jg     f0101237 <.L37+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f010124a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010124d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101250:	e9 7b 01 00 00       	jmp    f01013d0 <.L36+0x45>
f0101255:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101258:	8b 75 0c             	mov    0xc(%ebp),%esi
f010125b:	eb e9                	jmp    f0101246 <.L37+0xef>

f010125d <.L32>:
f010125d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101260:	83 f9 01             	cmp    $0x1,%ecx
f0101263:	7e 40                	jle    f01012a5 <.L32+0x48>
		return va_arg(*ap, long long);
f0101265:	8b 45 14             	mov    0x14(%ebp),%eax
f0101268:	8b 50 04             	mov    0x4(%eax),%edx
f010126b:	8b 00                	mov    (%eax),%eax
f010126d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101270:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101273:	8b 45 14             	mov    0x14(%ebp),%eax
f0101276:	8d 40 08             	lea    0x8(%eax),%eax
f0101279:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010127c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101280:	79 55                	jns    f01012d7 <.L32+0x7a>
				putch('-', putdat);
f0101282:	83 ec 08             	sub    $0x8,%esp
f0101285:	56                   	push   %esi
f0101286:	6a 2d                	push   $0x2d
f0101288:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010128b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010128e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101291:	f7 da                	neg    %edx
f0101293:	83 d1 00             	adc    $0x0,%ecx
f0101296:	f7 d9                	neg    %ecx
f0101298:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010129b:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012a0:	e9 10 01 00 00       	jmp    f01013b5 <.L36+0x2a>
	else if (lflag)
f01012a5:	85 c9                	test   %ecx,%ecx
f01012a7:	75 17                	jne    f01012c0 <.L32+0x63>
		return va_arg(*ap, int);
f01012a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ac:	8b 00                	mov    (%eax),%eax
f01012ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012b1:	99                   	cltd   
f01012b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b8:	8d 40 04             	lea    0x4(%eax),%eax
f01012bb:	89 45 14             	mov    %eax,0x14(%ebp)
f01012be:	eb bc                	jmp    f010127c <.L32+0x1f>
		return va_arg(*ap, long);
f01012c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c3:	8b 00                	mov    (%eax),%eax
f01012c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012c8:	99                   	cltd   
f01012c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01012cf:	8d 40 04             	lea    0x4(%eax),%eax
f01012d2:	89 45 14             	mov    %eax,0x14(%ebp)
f01012d5:	eb a5                	jmp    f010127c <.L32+0x1f>
			num = getint(&ap, lflag);
f01012d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012dd:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012e2:	e9 ce 00 00 00       	jmp    f01013b5 <.L36+0x2a>

f01012e7 <.L38>:
f01012e7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012ea:	83 f9 01             	cmp    $0x1,%ecx
f01012ed:	7e 18                	jle    f0101307 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f01012ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f2:	8b 10                	mov    (%eax),%edx
f01012f4:	8b 48 04             	mov    0x4(%eax),%ecx
f01012f7:	8d 40 08             	lea    0x8(%eax),%eax
f01012fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012fd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101302:	e9 ae 00 00 00       	jmp    f01013b5 <.L36+0x2a>
	else if (lflag)
f0101307:	85 c9                	test   %ecx,%ecx
f0101309:	75 1a                	jne    f0101325 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f010130b:	8b 45 14             	mov    0x14(%ebp),%eax
f010130e:	8b 10                	mov    (%eax),%edx
f0101310:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101315:	8d 40 04             	lea    0x4(%eax),%eax
f0101318:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010131b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101320:	e9 90 00 00 00       	jmp    f01013b5 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0101325:	8b 45 14             	mov    0x14(%ebp),%eax
f0101328:	8b 10                	mov    (%eax),%edx
f010132a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010132f:	8d 40 04             	lea    0x4(%eax),%eax
f0101332:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101335:	b8 0a 00 00 00       	mov    $0xa,%eax
f010133a:	eb 79                	jmp    f01013b5 <.L36+0x2a>

f010133c <.L35>:
f010133c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010133f:	83 f9 01             	cmp    $0x1,%ecx
f0101342:	7e 15                	jle    f0101359 <.L35+0x1d>
		return va_arg(*ap, unsigned long long);
f0101344:	8b 45 14             	mov    0x14(%ebp),%eax
f0101347:	8b 10                	mov    (%eax),%edx
f0101349:	8b 48 04             	mov    0x4(%eax),%ecx
f010134c:	8d 40 08             	lea    0x8(%eax),%eax
f010134f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101352:	b8 08 00 00 00       	mov    $0x8,%eax
f0101357:	eb 5c                	jmp    f01013b5 <.L36+0x2a>
	else if (lflag)
f0101359:	85 c9                	test   %ecx,%ecx
f010135b:	75 17                	jne    f0101374 <.L35+0x38>
		return va_arg(*ap, unsigned int);
f010135d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101360:	8b 10                	mov    (%eax),%edx
f0101362:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101367:	8d 40 04             	lea    0x4(%eax),%eax
f010136a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010136d:	b8 08 00 00 00       	mov    $0x8,%eax
f0101372:	eb 41                	jmp    f01013b5 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0101374:	8b 45 14             	mov    0x14(%ebp),%eax
f0101377:	8b 10                	mov    (%eax),%edx
f0101379:	b9 00 00 00 00       	mov    $0x0,%ecx
f010137e:	8d 40 04             	lea    0x4(%eax),%eax
f0101381:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101384:	b8 08 00 00 00       	mov    $0x8,%eax
f0101389:	eb 2a                	jmp    f01013b5 <.L36+0x2a>

f010138b <.L36>:
			putch('0', putdat);
f010138b:	83 ec 08             	sub    $0x8,%esp
f010138e:	56                   	push   %esi
f010138f:	6a 30                	push   $0x30
f0101391:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101394:	83 c4 08             	add    $0x8,%esp
f0101397:	56                   	push   %esi
f0101398:	6a 78                	push   $0x78
f010139a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010139d:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a0:	8b 10                	mov    (%eax),%edx
f01013a2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01013a7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01013aa:	8d 40 04             	lea    0x4(%eax),%eax
f01013ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013b0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013b5:	83 ec 0c             	sub    $0xc,%esp
f01013b8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01013bc:	57                   	push   %edi
f01013bd:	ff 75 e0             	pushl  -0x20(%ebp)
f01013c0:	50                   	push   %eax
f01013c1:	51                   	push   %ecx
f01013c2:	52                   	push   %edx
f01013c3:	89 f2                	mov    %esi,%edx
f01013c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01013c8:	e8 d3 fa ff ff       	call   f0100ea0 <printnum>
			break;
f01013cd:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01013d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013d3:	83 c7 01             	add    $0x1,%edi
f01013d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01013da:	83 f8 25             	cmp    $0x25,%eax
f01013dd:	0f 84 e9 fb ff ff    	je     f0100fcc <vprintfmt+0x28>
			if (ch == '\0')
f01013e3:	85 c0                	test   %eax,%eax
f01013e5:	0f 84 91 00 00 00    	je     f010147c <.L22+0x21>
			putch(ch, putdat);
f01013eb:	83 ec 08             	sub    $0x8,%esp
f01013ee:	56                   	push   %esi
f01013ef:	50                   	push   %eax
f01013f0:	ff 55 08             	call   *0x8(%ebp)
f01013f3:	83 c4 10             	add    $0x10,%esp
f01013f6:	eb db                	jmp    f01013d3 <.L36+0x48>

f01013f8 <.L39>:
f01013f8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01013fb:	83 f9 01             	cmp    $0x1,%ecx
f01013fe:	7e 15                	jle    f0101415 <.L39+0x1d>
		return va_arg(*ap, unsigned long long);
f0101400:	8b 45 14             	mov    0x14(%ebp),%eax
f0101403:	8b 10                	mov    (%eax),%edx
f0101405:	8b 48 04             	mov    0x4(%eax),%ecx
f0101408:	8d 40 08             	lea    0x8(%eax),%eax
f010140b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010140e:	b8 10 00 00 00       	mov    $0x10,%eax
f0101413:	eb a0                	jmp    f01013b5 <.L36+0x2a>
	else if (lflag)
f0101415:	85 c9                	test   %ecx,%ecx
f0101417:	75 17                	jne    f0101430 <.L39+0x38>
		return va_arg(*ap, unsigned int);
f0101419:	8b 45 14             	mov    0x14(%ebp),%eax
f010141c:	8b 10                	mov    (%eax),%edx
f010141e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101423:	8d 40 04             	lea    0x4(%eax),%eax
f0101426:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101429:	b8 10 00 00 00       	mov    $0x10,%eax
f010142e:	eb 85                	jmp    f01013b5 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0101430:	8b 45 14             	mov    0x14(%ebp),%eax
f0101433:	8b 10                	mov    (%eax),%edx
f0101435:	b9 00 00 00 00       	mov    $0x0,%ecx
f010143a:	8d 40 04             	lea    0x4(%eax),%eax
f010143d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101440:	b8 10 00 00 00       	mov    $0x10,%eax
f0101445:	e9 6b ff ff ff       	jmp    f01013b5 <.L36+0x2a>

f010144a <.L25>:
			putch(ch, putdat);
f010144a:	83 ec 08             	sub    $0x8,%esp
f010144d:	56                   	push   %esi
f010144e:	6a 25                	push   $0x25
f0101450:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	e9 75 ff ff ff       	jmp    f01013d0 <.L36+0x45>

f010145b <.L22>:
			putch('%', putdat);
f010145b:	83 ec 08             	sub    $0x8,%esp
f010145e:	56                   	push   %esi
f010145f:	6a 25                	push   $0x25
f0101461:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101464:	83 c4 10             	add    $0x10,%esp
f0101467:	89 f8                	mov    %edi,%eax
f0101469:	eb 03                	jmp    f010146e <.L22+0x13>
f010146b:	83 e8 01             	sub    $0x1,%eax
f010146e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101472:	75 f7                	jne    f010146b <.L22+0x10>
f0101474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101477:	e9 54 ff ff ff       	jmp    f01013d0 <.L36+0x45>
}
f010147c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010147f:	5b                   	pop    %ebx
f0101480:	5e                   	pop    %esi
f0101481:	5f                   	pop    %edi
f0101482:	5d                   	pop    %ebp
f0101483:	c3                   	ret    

f0101484 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101484:	55                   	push   %ebp
f0101485:	89 e5                	mov    %esp,%ebp
f0101487:	53                   	push   %ebx
f0101488:	83 ec 14             	sub    $0x14,%esp
f010148b:	e8 2c ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101490:	81 c3 7c fe 00 00    	add    $0xfe7c,%ebx
f0101496:	8b 45 08             	mov    0x8(%ebp),%eax
f0101499:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010149c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010149f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014a3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014ad:	85 c0                	test   %eax,%eax
f01014af:	74 2b                	je     f01014dc <vsnprintf+0x58>
f01014b1:	85 d2                	test   %edx,%edx
f01014b3:	7e 27                	jle    f01014dc <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014b5:	ff 75 14             	pushl  0x14(%ebp)
f01014b8:	ff 75 10             	pushl  0x10(%ebp)
f01014bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014be:	50                   	push   %eax
f01014bf:	8d 83 5e fc fe ff    	lea    -0x103a2(%ebx),%eax
f01014c5:	50                   	push   %eax
f01014c6:	e8 d9 fa ff ff       	call   f0100fa4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014d4:	83 c4 10             	add    $0x10,%esp
}
f01014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014da:	c9                   	leave  
f01014db:	c3                   	ret    
		return -E_INVAL;
f01014dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014e1:	eb f4                	jmp    f01014d7 <vsnprintf+0x53>

f01014e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014e3:	55                   	push   %ebp
f01014e4:	89 e5                	mov    %esp,%ebp
f01014e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014ec:	50                   	push   %eax
f01014ed:	ff 75 10             	pushl  0x10(%ebp)
f01014f0:	ff 75 0c             	pushl  0xc(%ebp)
f01014f3:	ff 75 08             	pushl  0x8(%ebp)
f01014f6:	e8 89 ff ff ff       	call   f0101484 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014fb:	c9                   	leave  
f01014fc:	c3                   	ret    

f01014fd <__x86.get_pc_thunk.cx>:
f01014fd:	8b 0c 24             	mov    (%esp),%ecx
f0101500:	c3                   	ret    

f0101501 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101501:	55                   	push   %ebp
f0101502:	89 e5                	mov    %esp,%ebp
f0101504:	57                   	push   %edi
f0101505:	56                   	push   %esi
f0101506:	53                   	push   %ebx
f0101507:	83 ec 1c             	sub    $0x1c,%esp
f010150a:	e8 ad ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010150f:	81 c3 fd fd 00 00    	add    $0xfdfd,%ebx
f0101515:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101518:	85 c0                	test   %eax,%eax
f010151a:	74 13                	je     f010152f <readline+0x2e>
		cprintf("%s", prompt);
f010151c:	83 ec 08             	sub    $0x8,%esp
f010151f:	50                   	push   %eax
f0101520:	8d 83 4a 0e ff ff    	lea    -0xf1b6(%ebx),%eax
f0101526:	50                   	push   %eax
f0101527:	e8 f3 f5 ff ff       	call   f0100b1f <cprintf>
f010152c:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010152f:	83 ec 0c             	sub    $0xc,%esp
f0101532:	6a 00                	push   $0x0
f0101534:	e8 23 f2 ff ff       	call   f010075c <iscons>
f0101539:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010153c:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010153f:	bf 00 00 00 00       	mov    $0x0,%edi
f0101544:	eb 46                	jmp    f010158c <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101546:	83 ec 08             	sub    $0x8,%esp
f0101549:	50                   	push   %eax
f010154a:	8d 83 10 10 ff ff    	lea    -0xeff0(%ebx),%eax
f0101550:	50                   	push   %eax
f0101551:	e8 c9 f5 ff ff       	call   f0100b1f <cprintf>
			return NULL;
f0101556:	83 c4 10             	add    $0x10,%esp
f0101559:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010155e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101561:	5b                   	pop    %ebx
f0101562:	5e                   	pop    %esi
f0101563:	5f                   	pop    %edi
f0101564:	5d                   	pop    %ebp
f0101565:	c3                   	ret    
			if (echoing)
f0101566:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010156a:	75 05                	jne    f0101571 <readline+0x70>
			i--;
f010156c:	83 ef 01             	sub    $0x1,%edi
f010156f:	eb 1b                	jmp    f010158c <readline+0x8b>
				cputchar('\b');
f0101571:	83 ec 0c             	sub    $0xc,%esp
f0101574:	6a 08                	push   $0x8
f0101576:	e8 c0 f1 ff ff       	call   f010073b <cputchar>
f010157b:	83 c4 10             	add    $0x10,%esp
f010157e:	eb ec                	jmp    f010156c <readline+0x6b>
			buf[i++] = c;
f0101580:	89 f0                	mov    %esi,%eax
f0101582:	88 84 3b 94 1f 00 00 	mov    %al,0x1f94(%ebx,%edi,1)
f0101589:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010158c:	e8 ba f1 ff ff       	call   f010074b <getchar>
f0101591:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101593:	85 c0                	test   %eax,%eax
f0101595:	78 af                	js     f0101546 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101597:	83 f8 08             	cmp    $0x8,%eax
f010159a:	0f 94 c2             	sete   %dl
f010159d:	83 f8 7f             	cmp    $0x7f,%eax
f01015a0:	0f 94 c0             	sete   %al
f01015a3:	08 c2                	or     %al,%dl
f01015a5:	74 04                	je     f01015ab <readline+0xaa>
f01015a7:	85 ff                	test   %edi,%edi
f01015a9:	7f bb                	jg     f0101566 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01015ab:	83 fe 1f             	cmp    $0x1f,%esi
f01015ae:	7e 1c                	jle    f01015cc <readline+0xcb>
f01015b0:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01015b6:	7f 14                	jg     f01015cc <readline+0xcb>
			if (echoing)
f01015b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015bc:	74 c2                	je     f0101580 <readline+0x7f>
				cputchar(c);
f01015be:	83 ec 0c             	sub    $0xc,%esp
f01015c1:	56                   	push   %esi
f01015c2:	e8 74 f1 ff ff       	call   f010073b <cputchar>
f01015c7:	83 c4 10             	add    $0x10,%esp
f01015ca:	eb b4                	jmp    f0101580 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f01015cc:	83 fe 0a             	cmp    $0xa,%esi
f01015cf:	74 05                	je     f01015d6 <readline+0xd5>
f01015d1:	83 fe 0d             	cmp    $0xd,%esi
f01015d4:	75 b6                	jne    f010158c <readline+0x8b>
			if (echoing)
f01015d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015da:	75 13                	jne    f01015ef <readline+0xee>
			buf[i] = 0;
f01015dc:	c6 84 3b 94 1f 00 00 	movb   $0x0,0x1f94(%ebx,%edi,1)
f01015e3:	00 
			return buf;
f01015e4:	8d 83 94 1f 00 00    	lea    0x1f94(%ebx),%eax
f01015ea:	e9 6f ff ff ff       	jmp    f010155e <readline+0x5d>
				cputchar('\n');
f01015ef:	83 ec 0c             	sub    $0xc,%esp
f01015f2:	6a 0a                	push   $0xa
f01015f4:	e8 42 f1 ff ff       	call   f010073b <cputchar>
f01015f9:	83 c4 10             	add    $0x10,%esp
f01015fc:	eb de                	jmp    f01015dc <readline+0xdb>

f01015fe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015fe:	55                   	push   %ebp
f01015ff:	89 e5                	mov    %esp,%ebp
f0101601:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101604:	b8 00 00 00 00       	mov    $0x0,%eax
f0101609:	eb 03                	jmp    f010160e <strlen+0x10>
		n++;
f010160b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010160e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101612:	75 f7                	jne    f010160b <strlen+0xd>
	return n;
}
f0101614:	5d                   	pop    %ebp
f0101615:	c3                   	ret    

f0101616 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101616:	55                   	push   %ebp
f0101617:	89 e5                	mov    %esp,%ebp
f0101619:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010161c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010161f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101624:	eb 03                	jmp    f0101629 <strnlen+0x13>
		n++;
f0101626:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101629:	39 d0                	cmp    %edx,%eax
f010162b:	74 06                	je     f0101633 <strnlen+0x1d>
f010162d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101631:	75 f3                	jne    f0101626 <strnlen+0x10>
	return n;
}
f0101633:	5d                   	pop    %ebp
f0101634:	c3                   	ret    

f0101635 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101635:	55                   	push   %ebp
f0101636:	89 e5                	mov    %esp,%ebp
f0101638:	53                   	push   %ebx
f0101639:	8b 45 08             	mov    0x8(%ebp),%eax
f010163c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010163f:	89 c2                	mov    %eax,%edx
f0101641:	83 c1 01             	add    $0x1,%ecx
f0101644:	83 c2 01             	add    $0x1,%edx
f0101647:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010164b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010164e:	84 db                	test   %bl,%bl
f0101650:	75 ef                	jne    f0101641 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101652:	5b                   	pop    %ebx
f0101653:	5d                   	pop    %ebp
f0101654:	c3                   	ret    

f0101655 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101655:	55                   	push   %ebp
f0101656:	89 e5                	mov    %esp,%ebp
f0101658:	53                   	push   %ebx
f0101659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010165c:	53                   	push   %ebx
f010165d:	e8 9c ff ff ff       	call   f01015fe <strlen>
f0101662:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101665:	ff 75 0c             	pushl  0xc(%ebp)
f0101668:	01 d8                	add    %ebx,%eax
f010166a:	50                   	push   %eax
f010166b:	e8 c5 ff ff ff       	call   f0101635 <strcpy>
	return dst;
}
f0101670:	89 d8                	mov    %ebx,%eax
f0101672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101675:	c9                   	leave  
f0101676:	c3                   	ret    

f0101677 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101677:	55                   	push   %ebp
f0101678:	89 e5                	mov    %esp,%ebp
f010167a:	56                   	push   %esi
f010167b:	53                   	push   %ebx
f010167c:	8b 75 08             	mov    0x8(%ebp),%esi
f010167f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101682:	89 f3                	mov    %esi,%ebx
f0101684:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101687:	89 f2                	mov    %esi,%edx
f0101689:	eb 0f                	jmp    f010169a <strncpy+0x23>
		*dst++ = *src;
f010168b:	83 c2 01             	add    $0x1,%edx
f010168e:	0f b6 01             	movzbl (%ecx),%eax
f0101691:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101694:	80 39 01             	cmpb   $0x1,(%ecx)
f0101697:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010169a:	39 da                	cmp    %ebx,%edx
f010169c:	75 ed                	jne    f010168b <strncpy+0x14>
	}
	return ret;
}
f010169e:	89 f0                	mov    %esi,%eax
f01016a0:	5b                   	pop    %ebx
f01016a1:	5e                   	pop    %esi
f01016a2:	5d                   	pop    %ebp
f01016a3:	c3                   	ret    

f01016a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01016a4:	55                   	push   %ebp
f01016a5:	89 e5                	mov    %esp,%ebp
f01016a7:	56                   	push   %esi
f01016a8:	53                   	push   %ebx
f01016a9:	8b 75 08             	mov    0x8(%ebp),%esi
f01016ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016af:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01016b2:	89 f0                	mov    %esi,%eax
f01016b4:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01016b8:	85 c9                	test   %ecx,%ecx
f01016ba:	75 0b                	jne    f01016c7 <strlcpy+0x23>
f01016bc:	eb 17                	jmp    f01016d5 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01016be:	83 c2 01             	add    $0x1,%edx
f01016c1:	83 c0 01             	add    $0x1,%eax
f01016c4:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01016c7:	39 d8                	cmp    %ebx,%eax
f01016c9:	74 07                	je     f01016d2 <strlcpy+0x2e>
f01016cb:	0f b6 0a             	movzbl (%edx),%ecx
f01016ce:	84 c9                	test   %cl,%cl
f01016d0:	75 ec                	jne    f01016be <strlcpy+0x1a>
		*dst = '\0';
f01016d2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016d5:	29 f0                	sub    %esi,%eax
}
f01016d7:	5b                   	pop    %ebx
f01016d8:	5e                   	pop    %esi
f01016d9:	5d                   	pop    %ebp
f01016da:	c3                   	ret    

f01016db <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016db:	55                   	push   %ebp
f01016dc:	89 e5                	mov    %esp,%ebp
f01016de:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016e4:	eb 06                	jmp    f01016ec <strcmp+0x11>
		p++, q++;
f01016e6:	83 c1 01             	add    $0x1,%ecx
f01016e9:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016ec:	0f b6 01             	movzbl (%ecx),%eax
f01016ef:	84 c0                	test   %al,%al
f01016f1:	74 04                	je     f01016f7 <strcmp+0x1c>
f01016f3:	3a 02                	cmp    (%edx),%al
f01016f5:	74 ef                	je     f01016e6 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016f7:	0f b6 c0             	movzbl %al,%eax
f01016fa:	0f b6 12             	movzbl (%edx),%edx
f01016fd:	29 d0                	sub    %edx,%eax
}
f01016ff:	5d                   	pop    %ebp
f0101700:	c3                   	ret    

f0101701 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101701:	55                   	push   %ebp
f0101702:	89 e5                	mov    %esp,%ebp
f0101704:	53                   	push   %ebx
f0101705:	8b 45 08             	mov    0x8(%ebp),%eax
f0101708:	8b 55 0c             	mov    0xc(%ebp),%edx
f010170b:	89 c3                	mov    %eax,%ebx
f010170d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101710:	eb 06                	jmp    f0101718 <strncmp+0x17>
		n--, p++, q++;
f0101712:	83 c0 01             	add    $0x1,%eax
f0101715:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101718:	39 d8                	cmp    %ebx,%eax
f010171a:	74 16                	je     f0101732 <strncmp+0x31>
f010171c:	0f b6 08             	movzbl (%eax),%ecx
f010171f:	84 c9                	test   %cl,%cl
f0101721:	74 04                	je     f0101727 <strncmp+0x26>
f0101723:	3a 0a                	cmp    (%edx),%cl
f0101725:	74 eb                	je     f0101712 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101727:	0f b6 00             	movzbl (%eax),%eax
f010172a:	0f b6 12             	movzbl (%edx),%edx
f010172d:	29 d0                	sub    %edx,%eax
}
f010172f:	5b                   	pop    %ebx
f0101730:	5d                   	pop    %ebp
f0101731:	c3                   	ret    
		return 0;
f0101732:	b8 00 00 00 00       	mov    $0x0,%eax
f0101737:	eb f6                	jmp    f010172f <strncmp+0x2e>

f0101739 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101739:	55                   	push   %ebp
f010173a:	89 e5                	mov    %esp,%ebp
f010173c:	8b 45 08             	mov    0x8(%ebp),%eax
f010173f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101743:	0f b6 10             	movzbl (%eax),%edx
f0101746:	84 d2                	test   %dl,%dl
f0101748:	74 09                	je     f0101753 <strchr+0x1a>
		if (*s == c)
f010174a:	38 ca                	cmp    %cl,%dl
f010174c:	74 0a                	je     f0101758 <strchr+0x1f>
	for (; *s; s++)
f010174e:	83 c0 01             	add    $0x1,%eax
f0101751:	eb f0                	jmp    f0101743 <strchr+0xa>
			return (char *) s;
	return 0;
f0101753:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101758:	5d                   	pop    %ebp
f0101759:	c3                   	ret    

f010175a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010175a:	55                   	push   %ebp
f010175b:	89 e5                	mov    %esp,%ebp
f010175d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101760:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101764:	eb 03                	jmp    f0101769 <strfind+0xf>
f0101766:	83 c0 01             	add    $0x1,%eax
f0101769:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010176c:	38 ca                	cmp    %cl,%dl
f010176e:	74 04                	je     f0101774 <strfind+0x1a>
f0101770:	84 d2                	test   %dl,%dl
f0101772:	75 f2                	jne    f0101766 <strfind+0xc>
			break;
	return (char *) s;
}
f0101774:	5d                   	pop    %ebp
f0101775:	c3                   	ret    

f0101776 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101776:	55                   	push   %ebp
f0101777:	89 e5                	mov    %esp,%ebp
f0101779:	57                   	push   %edi
f010177a:	56                   	push   %esi
f010177b:	53                   	push   %ebx
f010177c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010177f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101782:	85 c9                	test   %ecx,%ecx
f0101784:	74 13                	je     f0101799 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101786:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010178c:	75 05                	jne    f0101793 <memset+0x1d>
f010178e:	f6 c1 03             	test   $0x3,%cl
f0101791:	74 0d                	je     f01017a0 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101793:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101796:	fc                   	cld    
f0101797:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101799:	89 f8                	mov    %edi,%eax
f010179b:	5b                   	pop    %ebx
f010179c:	5e                   	pop    %esi
f010179d:	5f                   	pop    %edi
f010179e:	5d                   	pop    %ebp
f010179f:	c3                   	ret    
		c &= 0xFF;
f01017a0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01017a4:	89 d3                	mov    %edx,%ebx
f01017a6:	c1 e3 08             	shl    $0x8,%ebx
f01017a9:	89 d0                	mov    %edx,%eax
f01017ab:	c1 e0 18             	shl    $0x18,%eax
f01017ae:	89 d6                	mov    %edx,%esi
f01017b0:	c1 e6 10             	shl    $0x10,%esi
f01017b3:	09 f0                	or     %esi,%eax
f01017b5:	09 c2                	or     %eax,%edx
f01017b7:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01017b9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01017bc:	89 d0                	mov    %edx,%eax
f01017be:	fc                   	cld    
f01017bf:	f3 ab                	rep stos %eax,%es:(%edi)
f01017c1:	eb d6                	jmp    f0101799 <memset+0x23>

f01017c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01017c3:	55                   	push   %ebp
f01017c4:	89 e5                	mov    %esp,%ebp
f01017c6:	57                   	push   %edi
f01017c7:	56                   	push   %esi
f01017c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01017cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017d1:	39 c6                	cmp    %eax,%esi
f01017d3:	73 35                	jae    f010180a <memmove+0x47>
f01017d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017d8:	39 c2                	cmp    %eax,%edx
f01017da:	76 2e                	jbe    f010180a <memmove+0x47>
		s += n;
		d += n;
f01017dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017df:	89 d6                	mov    %edx,%esi
f01017e1:	09 fe                	or     %edi,%esi
f01017e3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017e9:	74 0c                	je     f01017f7 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017eb:	83 ef 01             	sub    $0x1,%edi
f01017ee:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017f1:	fd                   	std    
f01017f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017f4:	fc                   	cld    
f01017f5:	eb 21                	jmp    f0101818 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017f7:	f6 c1 03             	test   $0x3,%cl
f01017fa:	75 ef                	jne    f01017eb <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017fc:	83 ef 04             	sub    $0x4,%edi
f01017ff:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101802:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101805:	fd                   	std    
f0101806:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101808:	eb ea                	jmp    f01017f4 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010180a:	89 f2                	mov    %esi,%edx
f010180c:	09 c2                	or     %eax,%edx
f010180e:	f6 c2 03             	test   $0x3,%dl
f0101811:	74 09                	je     f010181c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101813:	89 c7                	mov    %eax,%edi
f0101815:	fc                   	cld    
f0101816:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101818:	5e                   	pop    %esi
f0101819:	5f                   	pop    %edi
f010181a:	5d                   	pop    %ebp
f010181b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010181c:	f6 c1 03             	test   $0x3,%cl
f010181f:	75 f2                	jne    f0101813 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101821:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101824:	89 c7                	mov    %eax,%edi
f0101826:	fc                   	cld    
f0101827:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101829:	eb ed                	jmp    f0101818 <memmove+0x55>

f010182b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010182b:	55                   	push   %ebp
f010182c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010182e:	ff 75 10             	pushl  0x10(%ebp)
f0101831:	ff 75 0c             	pushl  0xc(%ebp)
f0101834:	ff 75 08             	pushl  0x8(%ebp)
f0101837:	e8 87 ff ff ff       	call   f01017c3 <memmove>
}
f010183c:	c9                   	leave  
f010183d:	c3                   	ret    

f010183e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010183e:	55                   	push   %ebp
f010183f:	89 e5                	mov    %esp,%ebp
f0101841:	56                   	push   %esi
f0101842:	53                   	push   %ebx
f0101843:	8b 45 08             	mov    0x8(%ebp),%eax
f0101846:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101849:	89 c6                	mov    %eax,%esi
f010184b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010184e:	39 f0                	cmp    %esi,%eax
f0101850:	74 1c                	je     f010186e <memcmp+0x30>
		if (*s1 != *s2)
f0101852:	0f b6 08             	movzbl (%eax),%ecx
f0101855:	0f b6 1a             	movzbl (%edx),%ebx
f0101858:	38 d9                	cmp    %bl,%cl
f010185a:	75 08                	jne    f0101864 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010185c:	83 c0 01             	add    $0x1,%eax
f010185f:	83 c2 01             	add    $0x1,%edx
f0101862:	eb ea                	jmp    f010184e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101864:	0f b6 c1             	movzbl %cl,%eax
f0101867:	0f b6 db             	movzbl %bl,%ebx
f010186a:	29 d8                	sub    %ebx,%eax
f010186c:	eb 05                	jmp    f0101873 <memcmp+0x35>
	}

	return 0;
f010186e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101873:	5b                   	pop    %ebx
f0101874:	5e                   	pop    %esi
f0101875:	5d                   	pop    %ebp
f0101876:	c3                   	ret    

f0101877 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101877:	55                   	push   %ebp
f0101878:	89 e5                	mov    %esp,%ebp
f010187a:	8b 45 08             	mov    0x8(%ebp),%eax
f010187d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101880:	89 c2                	mov    %eax,%edx
f0101882:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101885:	39 d0                	cmp    %edx,%eax
f0101887:	73 09                	jae    f0101892 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101889:	38 08                	cmp    %cl,(%eax)
f010188b:	74 05                	je     f0101892 <memfind+0x1b>
	for (; s < ends; s++)
f010188d:	83 c0 01             	add    $0x1,%eax
f0101890:	eb f3                	jmp    f0101885 <memfind+0xe>
			break;
	return (void *) s;
}
f0101892:	5d                   	pop    %ebp
f0101893:	c3                   	ret    

f0101894 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101894:	55                   	push   %ebp
f0101895:	89 e5                	mov    %esp,%ebp
f0101897:	57                   	push   %edi
f0101898:	56                   	push   %esi
f0101899:	53                   	push   %ebx
f010189a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010189d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01018a0:	eb 03                	jmp    f01018a5 <strtol+0x11>
		s++;
f01018a2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01018a5:	0f b6 01             	movzbl (%ecx),%eax
f01018a8:	3c 20                	cmp    $0x20,%al
f01018aa:	74 f6                	je     f01018a2 <strtol+0xe>
f01018ac:	3c 09                	cmp    $0x9,%al
f01018ae:	74 f2                	je     f01018a2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01018b0:	3c 2b                	cmp    $0x2b,%al
f01018b2:	74 2e                	je     f01018e2 <strtol+0x4e>
	int neg = 0;
f01018b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01018b9:	3c 2d                	cmp    $0x2d,%al
f01018bb:	74 2f                	je     f01018ec <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01018c3:	75 05                	jne    f01018ca <strtol+0x36>
f01018c5:	80 39 30             	cmpb   $0x30,(%ecx)
f01018c8:	74 2c                	je     f01018f6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01018ca:	85 db                	test   %ebx,%ebx
f01018cc:	75 0a                	jne    f01018d8 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01018ce:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01018d3:	80 39 30             	cmpb   $0x30,(%ecx)
f01018d6:	74 28                	je     f0101900 <strtol+0x6c>
		base = 10;
f01018d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01018dd:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01018e0:	eb 50                	jmp    f0101932 <strtol+0x9e>
		s++;
f01018e2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01018e5:	bf 00 00 00 00       	mov    $0x0,%edi
f01018ea:	eb d1                	jmp    f01018bd <strtol+0x29>
		s++, neg = 1;
f01018ec:	83 c1 01             	add    $0x1,%ecx
f01018ef:	bf 01 00 00 00       	mov    $0x1,%edi
f01018f4:	eb c7                	jmp    f01018bd <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01018fa:	74 0e                	je     f010190a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01018fc:	85 db                	test   %ebx,%ebx
f01018fe:	75 d8                	jne    f01018d8 <strtol+0x44>
		s++, base = 8;
f0101900:	83 c1 01             	add    $0x1,%ecx
f0101903:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101908:	eb ce                	jmp    f01018d8 <strtol+0x44>
		s += 2, base = 16;
f010190a:	83 c1 02             	add    $0x2,%ecx
f010190d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101912:	eb c4                	jmp    f01018d8 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101914:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101917:	89 f3                	mov    %esi,%ebx
f0101919:	80 fb 19             	cmp    $0x19,%bl
f010191c:	77 29                	ja     f0101947 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010191e:	0f be d2             	movsbl %dl,%edx
f0101921:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101924:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101927:	7d 30                	jge    f0101959 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101929:	83 c1 01             	add    $0x1,%ecx
f010192c:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101930:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101932:	0f b6 11             	movzbl (%ecx),%edx
f0101935:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101938:	89 f3                	mov    %esi,%ebx
f010193a:	80 fb 09             	cmp    $0x9,%bl
f010193d:	77 d5                	ja     f0101914 <strtol+0x80>
			dig = *s - '0';
f010193f:	0f be d2             	movsbl %dl,%edx
f0101942:	83 ea 30             	sub    $0x30,%edx
f0101945:	eb dd                	jmp    f0101924 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0101947:	8d 72 bf             	lea    -0x41(%edx),%esi
f010194a:	89 f3                	mov    %esi,%ebx
f010194c:	80 fb 19             	cmp    $0x19,%bl
f010194f:	77 08                	ja     f0101959 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101951:	0f be d2             	movsbl %dl,%edx
f0101954:	83 ea 37             	sub    $0x37,%edx
f0101957:	eb cb                	jmp    f0101924 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101959:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010195d:	74 05                	je     f0101964 <strtol+0xd0>
		*endptr = (char *) s;
f010195f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101962:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101964:	89 c2                	mov    %eax,%edx
f0101966:	f7 da                	neg    %edx
f0101968:	85 ff                	test   %edi,%edi
f010196a:	0f 45 c2             	cmovne %edx,%eax
}
f010196d:	5b                   	pop    %ebx
f010196e:	5e                   	pop    %esi
f010196f:	5f                   	pop    %edi
f0101970:	5d                   	pop    %ebp
f0101971:	c3                   	ret    
f0101972:	66 90                	xchg   %ax,%ax
f0101974:	66 90                	xchg   %ax,%ax
f0101976:	66 90                	xchg   %ax,%ax
f0101978:	66 90                	xchg   %ax,%ax
f010197a:	66 90                	xchg   %ax,%ax
f010197c:	66 90                	xchg   %ax,%ax
f010197e:	66 90                	xchg   %ax,%ax

f0101980 <__udivdi3>:
f0101980:	55                   	push   %ebp
f0101981:	57                   	push   %edi
f0101982:	56                   	push   %esi
f0101983:	53                   	push   %ebx
f0101984:	83 ec 1c             	sub    $0x1c,%esp
f0101987:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010198b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010198f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101993:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101997:	85 d2                	test   %edx,%edx
f0101999:	75 35                	jne    f01019d0 <__udivdi3+0x50>
f010199b:	39 f3                	cmp    %esi,%ebx
f010199d:	0f 87 bd 00 00 00    	ja     f0101a60 <__udivdi3+0xe0>
f01019a3:	85 db                	test   %ebx,%ebx
f01019a5:	89 d9                	mov    %ebx,%ecx
f01019a7:	75 0b                	jne    f01019b4 <__udivdi3+0x34>
f01019a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01019ae:	31 d2                	xor    %edx,%edx
f01019b0:	f7 f3                	div    %ebx
f01019b2:	89 c1                	mov    %eax,%ecx
f01019b4:	31 d2                	xor    %edx,%edx
f01019b6:	89 f0                	mov    %esi,%eax
f01019b8:	f7 f1                	div    %ecx
f01019ba:	89 c6                	mov    %eax,%esi
f01019bc:	89 e8                	mov    %ebp,%eax
f01019be:	89 f7                	mov    %esi,%edi
f01019c0:	f7 f1                	div    %ecx
f01019c2:	89 fa                	mov    %edi,%edx
f01019c4:	83 c4 1c             	add    $0x1c,%esp
f01019c7:	5b                   	pop    %ebx
f01019c8:	5e                   	pop    %esi
f01019c9:	5f                   	pop    %edi
f01019ca:	5d                   	pop    %ebp
f01019cb:	c3                   	ret    
f01019cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019d0:	39 f2                	cmp    %esi,%edx
f01019d2:	77 7c                	ja     f0101a50 <__udivdi3+0xd0>
f01019d4:	0f bd fa             	bsr    %edx,%edi
f01019d7:	83 f7 1f             	xor    $0x1f,%edi
f01019da:	0f 84 98 00 00 00    	je     f0101a78 <__udivdi3+0xf8>
f01019e0:	89 f9                	mov    %edi,%ecx
f01019e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01019e7:	29 f8                	sub    %edi,%eax
f01019e9:	d3 e2                	shl    %cl,%edx
f01019eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019ef:	89 c1                	mov    %eax,%ecx
f01019f1:	89 da                	mov    %ebx,%edx
f01019f3:	d3 ea                	shr    %cl,%edx
f01019f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019f9:	09 d1                	or     %edx,%ecx
f01019fb:	89 f2                	mov    %esi,%edx
f01019fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a01:	89 f9                	mov    %edi,%ecx
f0101a03:	d3 e3                	shl    %cl,%ebx
f0101a05:	89 c1                	mov    %eax,%ecx
f0101a07:	d3 ea                	shr    %cl,%edx
f0101a09:	89 f9                	mov    %edi,%ecx
f0101a0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101a0f:	d3 e6                	shl    %cl,%esi
f0101a11:	89 eb                	mov    %ebp,%ebx
f0101a13:	89 c1                	mov    %eax,%ecx
f0101a15:	d3 eb                	shr    %cl,%ebx
f0101a17:	09 de                	or     %ebx,%esi
f0101a19:	89 f0                	mov    %esi,%eax
f0101a1b:	f7 74 24 08          	divl   0x8(%esp)
f0101a1f:	89 d6                	mov    %edx,%esi
f0101a21:	89 c3                	mov    %eax,%ebx
f0101a23:	f7 64 24 0c          	mull   0xc(%esp)
f0101a27:	39 d6                	cmp    %edx,%esi
f0101a29:	72 0c                	jb     f0101a37 <__udivdi3+0xb7>
f0101a2b:	89 f9                	mov    %edi,%ecx
f0101a2d:	d3 e5                	shl    %cl,%ebp
f0101a2f:	39 c5                	cmp    %eax,%ebp
f0101a31:	73 5d                	jae    f0101a90 <__udivdi3+0x110>
f0101a33:	39 d6                	cmp    %edx,%esi
f0101a35:	75 59                	jne    f0101a90 <__udivdi3+0x110>
f0101a37:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a3a:	31 ff                	xor    %edi,%edi
f0101a3c:	89 fa                	mov    %edi,%edx
f0101a3e:	83 c4 1c             	add    $0x1c,%esp
f0101a41:	5b                   	pop    %ebx
f0101a42:	5e                   	pop    %esi
f0101a43:	5f                   	pop    %edi
f0101a44:	5d                   	pop    %ebp
f0101a45:	c3                   	ret    
f0101a46:	8d 76 00             	lea    0x0(%esi),%esi
f0101a49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101a50:	31 ff                	xor    %edi,%edi
f0101a52:	31 c0                	xor    %eax,%eax
f0101a54:	89 fa                	mov    %edi,%edx
f0101a56:	83 c4 1c             	add    $0x1c,%esp
f0101a59:	5b                   	pop    %ebx
f0101a5a:	5e                   	pop    %esi
f0101a5b:	5f                   	pop    %edi
f0101a5c:	5d                   	pop    %ebp
f0101a5d:	c3                   	ret    
f0101a5e:	66 90                	xchg   %ax,%ax
f0101a60:	31 ff                	xor    %edi,%edi
f0101a62:	89 e8                	mov    %ebp,%eax
f0101a64:	89 f2                	mov    %esi,%edx
f0101a66:	f7 f3                	div    %ebx
f0101a68:	89 fa                	mov    %edi,%edx
f0101a6a:	83 c4 1c             	add    $0x1c,%esp
f0101a6d:	5b                   	pop    %ebx
f0101a6e:	5e                   	pop    %esi
f0101a6f:	5f                   	pop    %edi
f0101a70:	5d                   	pop    %ebp
f0101a71:	c3                   	ret    
f0101a72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a78:	39 f2                	cmp    %esi,%edx
f0101a7a:	72 06                	jb     f0101a82 <__udivdi3+0x102>
f0101a7c:	31 c0                	xor    %eax,%eax
f0101a7e:	39 eb                	cmp    %ebp,%ebx
f0101a80:	77 d2                	ja     f0101a54 <__udivdi3+0xd4>
f0101a82:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a87:	eb cb                	jmp    f0101a54 <__udivdi3+0xd4>
f0101a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a90:	89 d8                	mov    %ebx,%eax
f0101a92:	31 ff                	xor    %edi,%edi
f0101a94:	eb be                	jmp    f0101a54 <__udivdi3+0xd4>
f0101a96:	66 90                	xchg   %ax,%ax
f0101a98:	66 90                	xchg   %ax,%ax
f0101a9a:	66 90                	xchg   %ax,%ax
f0101a9c:	66 90                	xchg   %ax,%ax
f0101a9e:	66 90                	xchg   %ax,%ax

f0101aa0 <__umoddi3>:
f0101aa0:	55                   	push   %ebp
f0101aa1:	57                   	push   %edi
f0101aa2:	56                   	push   %esi
f0101aa3:	53                   	push   %ebx
f0101aa4:	83 ec 1c             	sub    $0x1c,%esp
f0101aa7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101aab:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101aaf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101ab3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101ab7:	85 ed                	test   %ebp,%ebp
f0101ab9:	89 f0                	mov    %esi,%eax
f0101abb:	89 da                	mov    %ebx,%edx
f0101abd:	75 19                	jne    f0101ad8 <__umoddi3+0x38>
f0101abf:	39 df                	cmp    %ebx,%edi
f0101ac1:	0f 86 b1 00 00 00    	jbe    f0101b78 <__umoddi3+0xd8>
f0101ac7:	f7 f7                	div    %edi
f0101ac9:	89 d0                	mov    %edx,%eax
f0101acb:	31 d2                	xor    %edx,%edx
f0101acd:	83 c4 1c             	add    $0x1c,%esp
f0101ad0:	5b                   	pop    %ebx
f0101ad1:	5e                   	pop    %esi
f0101ad2:	5f                   	pop    %edi
f0101ad3:	5d                   	pop    %ebp
f0101ad4:	c3                   	ret    
f0101ad5:	8d 76 00             	lea    0x0(%esi),%esi
f0101ad8:	39 dd                	cmp    %ebx,%ebp
f0101ada:	77 f1                	ja     f0101acd <__umoddi3+0x2d>
f0101adc:	0f bd cd             	bsr    %ebp,%ecx
f0101adf:	83 f1 1f             	xor    $0x1f,%ecx
f0101ae2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101ae6:	0f 84 b4 00 00 00    	je     f0101ba0 <__umoddi3+0x100>
f0101aec:	b8 20 00 00 00       	mov    $0x20,%eax
f0101af1:	89 c2                	mov    %eax,%edx
f0101af3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101af7:	29 c2                	sub    %eax,%edx
f0101af9:	89 c1                	mov    %eax,%ecx
f0101afb:	89 f8                	mov    %edi,%eax
f0101afd:	d3 e5                	shl    %cl,%ebp
f0101aff:	89 d1                	mov    %edx,%ecx
f0101b01:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101b05:	d3 e8                	shr    %cl,%eax
f0101b07:	09 c5                	or     %eax,%ebp
f0101b09:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101b0d:	89 c1                	mov    %eax,%ecx
f0101b0f:	d3 e7                	shl    %cl,%edi
f0101b11:	89 d1                	mov    %edx,%ecx
f0101b13:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101b17:	89 df                	mov    %ebx,%edi
f0101b19:	d3 ef                	shr    %cl,%edi
f0101b1b:	89 c1                	mov    %eax,%ecx
f0101b1d:	89 f0                	mov    %esi,%eax
f0101b1f:	d3 e3                	shl    %cl,%ebx
f0101b21:	89 d1                	mov    %edx,%ecx
f0101b23:	89 fa                	mov    %edi,%edx
f0101b25:	d3 e8                	shr    %cl,%eax
f0101b27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b2c:	09 d8                	or     %ebx,%eax
f0101b2e:	f7 f5                	div    %ebp
f0101b30:	d3 e6                	shl    %cl,%esi
f0101b32:	89 d1                	mov    %edx,%ecx
f0101b34:	f7 64 24 08          	mull   0x8(%esp)
f0101b38:	39 d1                	cmp    %edx,%ecx
f0101b3a:	89 c3                	mov    %eax,%ebx
f0101b3c:	89 d7                	mov    %edx,%edi
f0101b3e:	72 06                	jb     f0101b46 <__umoddi3+0xa6>
f0101b40:	75 0e                	jne    f0101b50 <__umoddi3+0xb0>
f0101b42:	39 c6                	cmp    %eax,%esi
f0101b44:	73 0a                	jae    f0101b50 <__umoddi3+0xb0>
f0101b46:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101b4a:	19 ea                	sbb    %ebp,%edx
f0101b4c:	89 d7                	mov    %edx,%edi
f0101b4e:	89 c3                	mov    %eax,%ebx
f0101b50:	89 ca                	mov    %ecx,%edx
f0101b52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b57:	29 de                	sub    %ebx,%esi
f0101b59:	19 fa                	sbb    %edi,%edx
f0101b5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101b5f:	89 d0                	mov    %edx,%eax
f0101b61:	d3 e0                	shl    %cl,%eax
f0101b63:	89 d9                	mov    %ebx,%ecx
f0101b65:	d3 ee                	shr    %cl,%esi
f0101b67:	d3 ea                	shr    %cl,%edx
f0101b69:	09 f0                	or     %esi,%eax
f0101b6b:	83 c4 1c             	add    $0x1c,%esp
f0101b6e:	5b                   	pop    %ebx
f0101b6f:	5e                   	pop    %esi
f0101b70:	5f                   	pop    %edi
f0101b71:	5d                   	pop    %ebp
f0101b72:	c3                   	ret    
f0101b73:	90                   	nop
f0101b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b78:	85 ff                	test   %edi,%edi
f0101b7a:	89 f9                	mov    %edi,%ecx
f0101b7c:	75 0b                	jne    f0101b89 <__umoddi3+0xe9>
f0101b7e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b83:	31 d2                	xor    %edx,%edx
f0101b85:	f7 f7                	div    %edi
f0101b87:	89 c1                	mov    %eax,%ecx
f0101b89:	89 d8                	mov    %ebx,%eax
f0101b8b:	31 d2                	xor    %edx,%edx
f0101b8d:	f7 f1                	div    %ecx
f0101b8f:	89 f0                	mov    %esi,%eax
f0101b91:	f7 f1                	div    %ecx
f0101b93:	e9 31 ff ff ff       	jmp    f0101ac9 <__umoddi3+0x29>
f0101b98:	90                   	nop
f0101b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ba0:	39 dd                	cmp    %ebx,%ebp
f0101ba2:	72 08                	jb     f0101bac <__umoddi3+0x10c>
f0101ba4:	39 f7                	cmp    %esi,%edi
f0101ba6:	0f 87 21 ff ff ff    	ja     f0101acd <__umoddi3+0x2d>
f0101bac:	89 da                	mov    %ebx,%edx
f0101bae:	89 f0                	mov    %esi,%eax
f0101bb0:	29 f8                	sub    %edi,%eax
f0101bb2:	19 ea                	sbb    %ebp,%edx
f0101bb4:	e9 14 ff ff ff       	jmp    f0101acd <__umoddi3+0x2d>
