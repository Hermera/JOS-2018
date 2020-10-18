
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
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 38 08 ff ff    	lea    -0xf7c8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 78 0a 00 00       	call   f0100adb <cprintf>
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
f0100073:	e8 0b 08 00 00       	call   f0100883 <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 54 08 ff ff    	lea    -0xf7ac(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 50 0a 00 00       	call   f0100adb <cprintf>
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
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
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
f01000ca:	e8 16 16 00 00       	call   f01016e5 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 6f 08 ff ff    	lea    -0xf791(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 f3 09 00 00       	call   f0100adb <cprintf>

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
f01000fc:	e8 1e 08 00 00       	call   f010091f <monitor>
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
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
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
f010012d:	e8 ed 07 00 00       	call   f010091f <monitor>
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
f0100147:	8d 83 8a 08 ff ff    	lea    -0xf776(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 88 09 00 00       	call   f0100adb <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 47 09 00 00       	call   f0100aa4 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 c6 08 ff ff    	lea    -0xf73a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 70 09 00 00       	call   f0100adb <cprintf>
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
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 a2 08 ff ff    	lea    -0xf75e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 43 09 00 00       	call   f0100adb <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 00 09 00 00       	call   f0100aa4 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 c6 08 ff ff    	lea    -0xf73a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 29 09 00 00       	call   f0100adb <cprintf>
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
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
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
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
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
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
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
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 f8 09 ff 	movzbl -0xf608(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 f8 08 ff 	movzbl -0xf708(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
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
f01002d7:	8d 83 bc 08 ff ff    	lea    -0xf744(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 f8 07 00 00       	call   f0100adb <cprintf>
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
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
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
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 f8 09 ff 	movzbl -0xf608(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
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
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
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
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 07             	or     $0x7,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 ee 11 00 00       	call   f0101732 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 c8 08 ff ff    	lea    -0xf738(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 ad 03 00 00       	call   f0100adb <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 f8 0a ff ff    	lea    -0xf508(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 16 0b ff ff    	lea    -0xf4ea(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 1b 0b ff ff    	lea    -0xf4e5(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 4c 03 00 00       	call   f0100adb <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 a8 0b ff ff    	lea    -0xf458(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 24 0b ff ff    	lea    -0xf4dc(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 35 03 00 00       	call   f0100adb <cprintf>
	return 0;
}
f01007a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ae:	5b                   	pop    %ebx
f01007af:	5e                   	pop    %esi
f01007b0:	5d                   	pop    %ebp
f01007b1:	c3                   	ret    

f01007b2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	57                   	push   %edi
f01007b6:	56                   	push   %esi
f01007b7:	53                   	push   %ebx
f01007b8:	83 ec 18             	sub    $0x18,%esp
f01007bb:	e8 fc f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007c0:	81 c3 48 0b 01 00    	add    $0x10b48,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c6:	8d 83 2d 0b ff ff    	lea    -0xf4d3(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 09 03 00 00       	call   f0100adb <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007db:	8d 83 d0 0b ff ff    	lea    -0xf430(%ebx),%eax
f01007e1:	50                   	push   %eax
f01007e2:	e8 f4 02 00 00       	call   f0100adb <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f6:	50                   	push   %eax
f01007f7:	57                   	push   %edi
f01007f8:	8d 83 f8 0b ff ff    	lea    -0xf408(%ebx),%eax
f01007fe:	50                   	push   %eax
f01007ff:	e8 d7 02 00 00       	call   f0100adb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	c7 c0 29 1b 10 f0    	mov    $0xf0101b29,%eax
f010080d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100813:	52                   	push   %edx
f0100814:	50                   	push   %eax
f0100815:	8d 83 1c 0c ff ff    	lea    -0xf3e4(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 ba 02 00 00       	call   f0100adb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010082a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100830:	52                   	push   %edx
f0100831:	50                   	push   %eax
f0100832:	8d 83 40 0c ff ff    	lea    -0xf3c0(%ebx),%eax
f0100838:	50                   	push   %eax
f0100839:	e8 9d 02 00 00       	call   f0100adb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100847:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084d:	50                   	push   %eax
f010084e:	56                   	push   %esi
f010084f:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f0100855:	50                   	push   %eax
f0100856:	e8 80 02 00 00       	call   f0100adb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100864:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	c1 fe 0a             	sar    $0xa,%esi
f0100869:	56                   	push   %esi
f010086a:	8d 83 88 0c ff ff    	lea    -0xf378(%ebx),%eax
f0100870:	50                   	push   %eax
f0100871:	e8 65 02 00 00       	call   f0100adb <cprintf>
	return 0;
}
f0100876:	b8 00 00 00 00       	mov    $0x0,%eax
f010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087e:	5b                   	pop    %ebx
f010087f:	5e                   	pop    %esi
f0100880:	5f                   	pop    %edi
f0100881:	5d                   	pop    %ebp
f0100882:	c3                   	ret    

f0100883 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
f0100886:	57                   	push   %edi
f0100887:	56                   	push   %esi
f0100888:	53                   	push   %ebx
f0100889:	83 ec 48             	sub    $0x48,%esp
f010088c:	e8 2b f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100891:	81 c3 77 0a 01 00    	add    $0x10a77,%ebx
	// Your code here.
	 cprintf("Stack backtrace:\n");
f0100897:	8d 83 46 0b ff ff    	lea    -0xf4ba(%ebx),%eax
f010089d:	50                   	push   %eax
f010089e:	e8 38 02 00 00       	call   f0100adb <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a3:	89 ee                	mov    %ebp,%esi
#define READ(x) *((uint32_t*) (x))

	uint32_t ebp = read_ebp();
	uint32_t eip = 0;
	struct Eipdebuginfo info;
	while (ebp) {
f01008a5:	83 c4 10             	add    $0x10,%esp
		eip = READ(ebp + 4);
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008a8:	8d 83 b4 0c ff ff    	lea    -0xf34c(%ebx),%eax
f01008ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			READ(ebp + 12),
			READ(ebp + 16),
			READ(ebp + 20),
			READ(ebp + 24));

		if(!debuginfo_eip(eip, &info)) {
f01008b1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008b4:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (ebp) {
f01008b7:	eb 02                	jmp    f01008bb <mon_backtrace+0x38>
				info.eip_file,
				info.eip_line,
				info.eip_fn_namelen, info.eip_fn_name,
				eip - info.eip_fn_addr);
		}
		ebp = READ(ebp);
f01008b9:	8b 36                	mov    (%esi),%esi
	while (ebp) {
f01008bb:	85 f6                	test   %esi,%esi
f01008bd:	74 53                	je     f0100912 <mon_backtrace+0x8f>
		eip = READ(ebp + 4);
f01008bf:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008c2:	ff 76 18             	pushl  0x18(%esi)
f01008c5:	ff 76 14             	pushl  0x14(%esi)
f01008c8:	ff 76 10             	pushl  0x10(%esi)
f01008cb:	ff 76 0c             	pushl  0xc(%esi)
f01008ce:	ff 76 08             	pushl  0x8(%esi)
f01008d1:	57                   	push   %edi
f01008d2:	56                   	push   %esi
f01008d3:	ff 75 c4             	pushl  -0x3c(%ebp)
f01008d6:	e8 00 02 00 00       	call   f0100adb <cprintf>
		if(!debuginfo_eip(eip, &info)) {
f01008db:	83 c4 18             	add    $0x18,%esp
f01008de:	ff 75 c0             	pushl  -0x40(%ebp)
f01008e1:	57                   	push   %edi
f01008e2:	e8 f8 02 00 00       	call   f0100bdf <debuginfo_eip>
f01008e7:	83 c4 10             	add    $0x10,%esp
f01008ea:	85 c0                	test   %eax,%eax
f01008ec:	75 cb                	jne    f01008b9 <mon_backtrace+0x36>
			cprintf("\t%s:%d: %.*s+%d\n",
f01008ee:	83 ec 08             	sub    $0x8,%esp
f01008f1:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01008f4:	57                   	push   %edi
f01008f5:	ff 75 d8             	pushl  -0x28(%ebp)
f01008f8:	ff 75 dc             	pushl  -0x24(%ebp)
f01008fb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008fe:	ff 75 d0             	pushl  -0x30(%ebp)
f0100901:	8d 83 58 0b ff ff    	lea    -0xf4a8(%ebx),%eax
f0100907:	50                   	push   %eax
f0100908:	e8 ce 01 00 00       	call   f0100adb <cprintf>
f010090d:	83 c4 20             	add    $0x20,%esp
f0100910:	eb a7                	jmp    f01008b9 <mon_backtrace+0x36>
	}
	return 0;
#undef READ
}
f0100912:	b8 00 00 00 00       	mov    $0x0,%eax
f0100917:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010091a:	5b                   	pop    %ebx
f010091b:	5e                   	pop    %esi
f010091c:	5f                   	pop    %edi
f010091d:	5d                   	pop    %ebp
f010091e:	c3                   	ret    

f010091f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010091f:	55                   	push   %ebp
f0100920:	89 e5                	mov    %esp,%ebp
f0100922:	57                   	push   %edi
f0100923:	56                   	push   %esi
f0100924:	53                   	push   %ebx
f0100925:	83 ec 68             	sub    $0x68,%esp
f0100928:	e8 8f f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010092d:	81 c3 db 09 01 00    	add    $0x109db,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100933:	8d 83 e8 0c ff ff    	lea    -0xf318(%ebx),%eax
f0100939:	50                   	push   %eax
f010093a:	e8 9c 01 00 00       	call   f0100adb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010093f:	8d 83 0c 0d ff ff    	lea    -0xf2f4(%ebx),%eax
f0100945:	89 04 24             	mov    %eax,(%esp)
f0100948:	e8 8e 01 00 00       	call   f0100adb <cprintf>
f010094d:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100950:	8d bb 6d 0b ff ff    	lea    -0xf493(%ebx),%edi
f0100956:	eb 4a                	jmp    f01009a2 <monitor+0x83>
f0100958:	83 ec 08             	sub    $0x8,%esp
f010095b:	0f be c0             	movsbl %al,%eax
f010095e:	50                   	push   %eax
f010095f:	57                   	push   %edi
f0100960:	e8 43 0d 00 00       	call   f01016a8 <strchr>
f0100965:	83 c4 10             	add    $0x10,%esp
f0100968:	85 c0                	test   %eax,%eax
f010096a:	74 08                	je     f0100974 <monitor+0x55>
			*buf++ = 0;
f010096c:	c6 06 00             	movb   $0x0,(%esi)
f010096f:	8d 76 01             	lea    0x1(%esi),%esi
f0100972:	eb 79                	jmp    f01009ed <monitor+0xce>
		if (*buf == 0)
f0100974:	80 3e 00             	cmpb   $0x0,(%esi)
f0100977:	74 7f                	je     f01009f8 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f0100979:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010097d:	74 0f                	je     f010098e <monitor+0x6f>
		argv[argc++] = buf;
f010097f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100982:	8d 48 01             	lea    0x1(%eax),%ecx
f0100985:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100988:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f010098c:	eb 44                	jmp    f01009d2 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010098e:	83 ec 08             	sub    $0x8,%esp
f0100991:	6a 10                	push   $0x10
f0100993:	8d 83 72 0b ff ff    	lea    -0xf48e(%ebx),%eax
f0100999:	50                   	push   %eax
f010099a:	e8 3c 01 00 00       	call   f0100adb <cprintf>
f010099f:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009a2:	8d 83 69 0b ff ff    	lea    -0xf497(%ebx),%eax
f01009a8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009ab:	83 ec 0c             	sub    $0xc,%esp
f01009ae:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009b1:	e8 ba 0a 00 00       	call   f0101470 <readline>
f01009b6:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009b8:	83 c4 10             	add    $0x10,%esp
f01009bb:	85 c0                	test   %eax,%eax
f01009bd:	74 ec                	je     f01009ab <monitor+0x8c>
	argv[argc] = 0;
f01009bf:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009c6:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009cd:	eb 1e                	jmp    f01009ed <monitor+0xce>
			buf++;
f01009cf:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009d2:	0f b6 06             	movzbl (%esi),%eax
f01009d5:	84 c0                	test   %al,%al
f01009d7:	74 14                	je     f01009ed <monitor+0xce>
f01009d9:	83 ec 08             	sub    $0x8,%esp
f01009dc:	0f be c0             	movsbl %al,%eax
f01009df:	50                   	push   %eax
f01009e0:	57                   	push   %edi
f01009e1:	e8 c2 0c 00 00       	call   f01016a8 <strchr>
f01009e6:	83 c4 10             	add    $0x10,%esp
f01009e9:	85 c0                	test   %eax,%eax
f01009eb:	74 e2                	je     f01009cf <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f01009ed:	0f b6 06             	movzbl (%esi),%eax
f01009f0:	84 c0                	test   %al,%al
f01009f2:	0f 85 60 ff ff ff    	jne    f0100958 <monitor+0x39>
	argv[argc] = 0;
f01009f8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009fb:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a02:	00 
	if (argc == 0)
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	74 9b                	je     f01009a2 <monitor+0x83>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a07:	83 ec 08             	sub    $0x8,%esp
f0100a0a:	8d 83 16 0b ff ff    	lea    -0xf4ea(%ebx),%eax
f0100a10:	50                   	push   %eax
f0100a11:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a14:	e8 31 0c 00 00       	call   f010164a <strcmp>
f0100a19:	83 c4 10             	add    $0x10,%esp
f0100a1c:	85 c0                	test   %eax,%eax
f0100a1e:	74 38                	je     f0100a58 <monitor+0x139>
f0100a20:	83 ec 08             	sub    $0x8,%esp
f0100a23:	8d 83 24 0b ff ff    	lea    -0xf4dc(%ebx),%eax
f0100a29:	50                   	push   %eax
f0100a2a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a2d:	e8 18 0c 00 00       	call   f010164a <strcmp>
f0100a32:	83 c4 10             	add    $0x10,%esp
f0100a35:	85 c0                	test   %eax,%eax
f0100a37:	74 1a                	je     f0100a53 <monitor+0x134>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a39:	83 ec 08             	sub    $0x8,%esp
f0100a3c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a3f:	8d 83 8f 0b ff ff    	lea    -0xf471(%ebx),%eax
f0100a45:	50                   	push   %eax
f0100a46:	e8 90 00 00 00       	call   f0100adb <cprintf>
f0100a4b:	83 c4 10             	add    $0x10,%esp
f0100a4e:	e9 4f ff ff ff       	jmp    f01009a2 <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a53:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a58:	83 ec 04             	sub    $0x4,%esp
f0100a5b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a5e:	ff 75 08             	pushl  0x8(%ebp)
f0100a61:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a64:	52                   	push   %edx
f0100a65:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a68:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a6f:	83 c4 10             	add    $0x10,%esp
f0100a72:	85 c0                	test   %eax,%eax
f0100a74:	0f 89 28 ff ff ff    	jns    f01009a2 <monitor+0x83>
				break;
	}
}
f0100a7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a7d:	5b                   	pop    %ebx
f0100a7e:	5e                   	pop    %esi
f0100a7f:	5f                   	pop    %edi
f0100a80:	5d                   	pop    %ebp
f0100a81:	c3                   	ret    

f0100a82 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100a82:	55                   	push   %ebp
f0100a83:	89 e5                	mov    %esp,%ebp
f0100a85:	53                   	push   %ebx
f0100a86:	83 ec 10             	sub    $0x10,%esp
f0100a89:	e8 2e f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a8e:	81 c3 7a 08 01 00    	add    $0x1087a,%ebx
	cputchar(ch);
f0100a94:	ff 75 08             	pushl  0x8(%ebp)
f0100a97:	e8 97 fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100a9c:	83 c4 10             	add    $0x10,%esp
f0100a9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aa2:	c9                   	leave  
f0100aa3:	c3                   	ret    

f0100aa4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100aa4:	55                   	push   %ebp
f0100aa5:	89 e5                	mov    %esp,%ebp
f0100aa7:	53                   	push   %ebx
f0100aa8:	83 ec 14             	sub    $0x14,%esp
f0100aab:	e8 0c f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ab0:	81 c3 58 08 01 00    	add    $0x10858,%ebx
	int cnt = 0;
f0100ab6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100abd:	ff 75 0c             	pushl  0xc(%ebp)
f0100ac0:	ff 75 08             	pushl  0x8(%ebp)
f0100ac3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ac6:	50                   	push   %eax
f0100ac7:	8d 83 7a f7 fe ff    	lea    -0x10886(%ebx),%eax
f0100acd:	50                   	push   %eax
f0100ace:	e8 8d 04 00 00       	call   f0100f60 <vprintfmt>
	return cnt;
}
f0100ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ad6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ad9:	c9                   	leave  
f0100ada:	c3                   	ret    

f0100adb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100adb:	55                   	push   %ebp
f0100adc:	89 e5                	mov    %esp,%ebp
f0100ade:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100ae1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100ae4:	50                   	push   %eax
f0100ae5:	ff 75 08             	pushl  0x8(%ebp)
f0100ae8:	e8 b7 ff ff ff       	call   f0100aa4 <vcprintf>
	va_end(ap);

	return cnt;
f0100aed:	c9                   	leave  
f0100aee:	c3                   	ret    

f0100aef <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100aef:	55                   	push   %ebp
f0100af0:	89 e5                	mov    %esp,%ebp
f0100af2:	57                   	push   %edi
f0100af3:	56                   	push   %esi
f0100af4:	53                   	push   %ebx
f0100af5:	83 ec 14             	sub    $0x14,%esp
f0100af8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100afb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100afe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b01:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b04:	8b 32                	mov    (%edx),%esi
f0100b06:	8b 01                	mov    (%ecx),%eax
f0100b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b0b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b12:	eb 2f                	jmp    f0100b43 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b14:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b17:	39 c6                	cmp    %eax,%esi
f0100b19:	7f 49                	jg     f0100b64 <stab_binsearch+0x75>
f0100b1b:	0f b6 0a             	movzbl (%edx),%ecx
f0100b1e:	83 ea 0c             	sub    $0xc,%edx
f0100b21:	39 f9                	cmp    %edi,%ecx
f0100b23:	75 ef                	jne    f0100b14 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b25:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b28:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b2b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b2f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b32:	73 35                	jae    f0100b69 <stab_binsearch+0x7a>
			*region_left = m;
f0100b34:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b37:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b39:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b3c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b43:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b46:	7f 4e                	jg     f0100b96 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b4b:	01 f0                	add    %esi,%eax
f0100b4d:	89 c3                	mov    %eax,%ebx
f0100b4f:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b52:	01 c3                	add    %eax,%ebx
f0100b54:	d1 fb                	sar    %ebx
f0100b56:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b59:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b5c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b60:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b62:	eb b3                	jmp    f0100b17 <stab_binsearch+0x28>
			l = true_m + 1;
f0100b64:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100b67:	eb da                	jmp    f0100b43 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100b69:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b6c:	76 14                	jbe    f0100b82 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100b6e:	83 e8 01             	sub    $0x1,%eax
f0100b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b74:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100b77:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100b79:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b80:	eb c1                	jmp    f0100b43 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100b82:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b85:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100b87:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100b8b:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100b8d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100b94:	eb ad                	jmp    f0100b43 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100b96:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b9a:	74 16                	je     f0100bb2 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100b9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b9f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100ba1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ba4:	8b 0e                	mov    (%esi),%ecx
f0100ba6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ba9:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bac:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bb0:	eb 12                	jmp    f0100bc4 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bb5:	8b 00                	mov    (%eax),%eax
f0100bb7:	83 e8 01             	sub    $0x1,%eax
f0100bba:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bbd:	89 07                	mov    %eax,(%edi)
f0100bbf:	eb 16                	jmp    f0100bd7 <stab_binsearch+0xe8>
		     l--)
f0100bc1:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100bc4:	39 c1                	cmp    %eax,%ecx
f0100bc6:	7d 0a                	jge    f0100bd2 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100bc8:	0f b6 1a             	movzbl (%edx),%ebx
f0100bcb:	83 ea 0c             	sub    $0xc,%edx
f0100bce:	39 fb                	cmp    %edi,%ebx
f0100bd0:	75 ef                	jne    f0100bc1 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100bd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bd5:	89 07                	mov    %eax,(%edi)
	}
}
f0100bd7:	83 c4 14             	add    $0x14,%esp
f0100bda:	5b                   	pop    %ebx
f0100bdb:	5e                   	pop    %esi
f0100bdc:	5f                   	pop    %edi
f0100bdd:	5d                   	pop    %ebp
f0100bde:	c3                   	ret    

f0100bdf <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100bdf:	55                   	push   %ebp
f0100be0:	89 e5                	mov    %esp,%ebp
f0100be2:	57                   	push   %edi
f0100be3:	56                   	push   %esi
f0100be4:	53                   	push   %ebx
f0100be5:	83 ec 3c             	sub    $0x3c,%esp
f0100be8:	e8 cf f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100bed:	81 c3 1b 07 01 00    	add    $0x1071b,%ebx
f0100bf3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100bf6:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100bf9:	8d 83 34 0d ff ff    	lea    -0xf2cc(%ebx),%eax
f0100bff:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c01:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c08:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c0b:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c12:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c15:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c1c:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c22:	0f 86 2f 01 00 00    	jbe    f0100d57 <debuginfo_eip+0x178>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c28:	c7 c0 6d 5f 10 f0    	mov    $0xf0105f6d,%eax
f0100c2e:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c34:	0f 86 00 02 00 00    	jbe    f0100e3a <debuginfo_eip+0x25b>
f0100c3a:	c7 c0 ed 78 10 f0    	mov    $0xf01078ed,%eax
f0100c40:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c44:	0f 85 f7 01 00 00    	jne    f0100e41 <debuginfo_eip+0x262>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c4a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c51:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100c57:	c7 c2 6c 5f 10 f0    	mov    $0xf0105f6c,%edx
f0100c5d:	29 c2                	sub    %eax,%edx
f0100c5f:	c1 fa 02             	sar    $0x2,%edx
f0100c62:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100c68:	83 ea 01             	sub    $0x1,%edx
f0100c6b:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100c6e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100c71:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100c74:	83 ec 08             	sub    $0x8,%esp
f0100c77:	57                   	push   %edi
f0100c78:	6a 64                	push   $0x64
f0100c7a:	e8 70 fe ff ff       	call   f0100aef <stab_binsearch>
	if (lfile == 0)
f0100c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c82:	83 c4 10             	add    $0x10,%esp
f0100c85:	85 c0                	test   %eax,%eax
f0100c87:	0f 84 bb 01 00 00    	je     f0100e48 <debuginfo_eip+0x269>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100c8d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c93:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c96:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c99:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c9c:	83 ec 08             	sub    $0x8,%esp
f0100c9f:	57                   	push   %edi
f0100ca0:	6a 24                	push   $0x24
f0100ca2:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100ca8:	e8 42 fe ff ff       	call   f0100aef <stab_binsearch>

	if (lfun <= rfun) {
f0100cad:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cb0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cb3:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100cb6:	83 c4 10             	add    $0x10,%esp
f0100cb9:	39 c8                	cmp    %ecx,%eax
f0100cbb:	0f 8f ae 00 00 00    	jg     f0100d6f <debuginfo_eip+0x190>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100cc1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cc4:	c7 c1 58 22 10 f0    	mov    $0xf0102258,%ecx
f0100cca:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100ccd:	8b 11                	mov    (%ecx),%edx
f0100ccf:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100cd2:	c7 c2 ed 78 10 f0    	mov    $0xf01078ed,%edx
f0100cd8:	81 ea 6d 5f 10 f0    	sub    $0xf0105f6d,%edx
f0100cde:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100ce1:	73 0c                	jae    f0100cef <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100ce3:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100ce6:	81 c2 6d 5f 10 f0    	add    $0xf0105f6d,%edx
f0100cec:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100cef:	8b 51 08             	mov    0x8(%ecx),%edx
f0100cf2:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100cf5:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100cf7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100cfa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100cfd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d00:	83 ec 08             	sub    $0x8,%esp
f0100d03:	6a 3a                	push   $0x3a
f0100d05:	ff 76 08             	pushl  0x8(%esi)
f0100d08:	e8 bc 09 00 00       	call   f01016c9 <strfind>
f0100d0d:	2b 46 08             	sub    0x8(%esi),%eax
f0100d10:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d13:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d16:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d19:	83 c4 08             	add    $0x8,%esp
f0100d1c:	57                   	push   %edi
f0100d1d:	6a 44                	push   $0x44
f0100d1f:	c7 c7 58 22 10 f0    	mov    $0xf0102258,%edi
f0100d25:	89 f8                	mov    %edi,%eax
f0100d27:	e8 c3 fd ff ff       	call   f0100aef <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100d2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d2f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d32:	c1 e2 02             	shl    $0x2,%edx
f0100d35:	0f b7 4c 3a 06       	movzwl 0x6(%edx,%edi,1),%ecx
f0100d3a:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d3d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d40:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0100d44:	83 c4 10             	add    $0x10,%esp
f0100d47:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0100d4b:	bf 01 00 00 00       	mov    $0x1,%edi
f0100d50:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100d53:	89 ce                	mov    %ecx,%esi
f0100d55:	eb 34                	jmp    f0100d8b <debuginfo_eip+0x1ac>
  	        panic("User address");
f0100d57:	83 ec 04             	sub    $0x4,%esp
f0100d5a:	8d 83 3e 0d ff ff    	lea    -0xf2c2(%ebx),%eax
f0100d60:	50                   	push   %eax
f0100d61:	6a 7f                	push   $0x7f
f0100d63:	8d 83 4b 0d ff ff    	lea    -0xf2b5(%ebx),%eax
f0100d69:	50                   	push   %eax
f0100d6a:	e8 97 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100d6f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100d72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d75:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d7e:	eb 80                	jmp    f0100d00 <debuginfo_eip+0x121>
f0100d80:	83 e8 01             	sub    $0x1,%eax
f0100d83:	83 ea 0c             	sub    $0xc,%edx
f0100d86:	89 f9                	mov    %edi,%ecx
f0100d88:	88 4d c0             	mov    %cl,-0x40(%ebp)
f0100d8b:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0100d8e:	39 c6                	cmp    %eax,%esi
f0100d90:	7f 2a                	jg     f0100dbc <debuginfo_eip+0x1dd>
f0100d92:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	       && stabs[lline].n_type != N_SOL
f0100d95:	0f b6 0a             	movzbl (%edx),%ecx
f0100d98:	80 f9 84             	cmp    $0x84,%cl
f0100d9b:	74 49                	je     f0100de6 <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d9d:	80 f9 64             	cmp    $0x64,%cl
f0100da0:	75 de                	jne    f0100d80 <debuginfo_eip+0x1a1>
f0100da2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100da5:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
f0100da9:	74 d5                	je     f0100d80 <debuginfo_eip+0x1a1>
f0100dab:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dae:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0100db2:	74 3b                	je     f0100def <debuginfo_eip+0x210>
f0100db4:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100db7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100dba:	eb 33                	jmp    f0100def <debuginfo_eip+0x210>
f0100dbc:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100dbf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dc2:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dc5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100dca:	39 fa                	cmp    %edi,%edx
f0100dcc:	0f 8d 82 00 00 00    	jge    f0100e54 <debuginfo_eip+0x275>
		for (lline = lfun + 1;
f0100dd2:	83 c2 01             	add    $0x1,%edx
f0100dd5:	89 d0                	mov    %edx,%eax
f0100dd7:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100dda:	c7 c2 58 22 10 f0    	mov    $0xf0102258,%edx
f0100de0:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100de4:	eb 3b                	jmp    f0100e21 <debuginfo_eip+0x242>
f0100de6:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100de9:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0100ded:	75 26                	jne    f0100e15 <debuginfo_eip+0x236>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100def:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100df2:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100df8:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100dfb:	c7 c0 ed 78 10 f0    	mov    $0xf01078ed,%eax
f0100e01:	81 e8 6d 5f 10 f0    	sub    $0xf0105f6d,%eax
f0100e07:	39 c2                	cmp    %eax,%edx
f0100e09:	73 b4                	jae    f0100dbf <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e0b:	81 c2 6d 5f 10 f0    	add    $0xf0105f6d,%edx
f0100e11:	89 16                	mov    %edx,(%esi)
f0100e13:	eb aa                	jmp    f0100dbf <debuginfo_eip+0x1e0>
f0100e15:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100e18:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e1b:	eb d2                	jmp    f0100def <debuginfo_eip+0x210>
			info->eip_fn_narg++;
f0100e1d:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e21:	39 c7                	cmp    %eax,%edi
f0100e23:	7e 2a                	jle    f0100e4f <debuginfo_eip+0x270>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e25:	0f b6 0a             	movzbl (%edx),%ecx
f0100e28:	83 c0 01             	add    $0x1,%eax
f0100e2b:	83 c2 0c             	add    $0xc,%edx
f0100e2e:	80 f9 a0             	cmp    $0xa0,%cl
f0100e31:	74 ea                	je     f0100e1d <debuginfo_eip+0x23e>
	return 0;
f0100e33:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e38:	eb 1a                	jmp    f0100e54 <debuginfo_eip+0x275>
		return -1;
f0100e3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e3f:	eb 13                	jmp    f0100e54 <debuginfo_eip+0x275>
f0100e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e46:	eb 0c                	jmp    f0100e54 <debuginfo_eip+0x275>
		return -1;
f0100e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e4d:	eb 05                	jmp    f0100e54 <debuginfo_eip+0x275>
	return 0;
f0100e4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e57:	5b                   	pop    %ebx
f0100e58:	5e                   	pop    %esi
f0100e59:	5f                   	pop    %edi
f0100e5a:	5d                   	pop    %ebp
f0100e5b:	c3                   	ret    

f0100e5c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e5c:	55                   	push   %ebp
f0100e5d:	89 e5                	mov    %esp,%ebp
f0100e5f:	57                   	push   %edi
f0100e60:	56                   	push   %esi
f0100e61:	53                   	push   %ebx
f0100e62:	83 ec 2c             	sub    $0x2c,%esp
f0100e65:	e8 02 06 00 00       	call   f010146c <__x86.get_pc_thunk.cx>
f0100e6a:	81 c1 9e 04 01 00    	add    $0x1049e,%ecx
f0100e70:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100e73:	89 c7                	mov    %eax,%edi
f0100e75:	89 d6                	mov    %edx,%esi
f0100e77:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e80:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e83:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100e86:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e8b:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100e8e:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100e91:	39 d3                	cmp    %edx,%ebx
f0100e93:	72 09                	jb     f0100e9e <printnum+0x42>
f0100e95:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100e98:	0f 87 83 00 00 00    	ja     f0100f21 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e9e:	83 ec 0c             	sub    $0xc,%esp
f0100ea1:	ff 75 18             	pushl  0x18(%ebp)
f0100ea4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ea7:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100eaa:	53                   	push   %ebx
f0100eab:	ff 75 10             	pushl  0x10(%ebp)
f0100eae:	83 ec 08             	sub    $0x8,%esp
f0100eb1:	ff 75 dc             	pushl  -0x24(%ebp)
f0100eb4:	ff 75 d8             	pushl  -0x28(%ebp)
f0100eb7:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100eba:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ebd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ec0:	e8 2b 0a 00 00       	call   f01018f0 <__udivdi3>
f0100ec5:	83 c4 18             	add    $0x18,%esp
f0100ec8:	52                   	push   %edx
f0100ec9:	50                   	push   %eax
f0100eca:	89 f2                	mov    %esi,%edx
f0100ecc:	89 f8                	mov    %edi,%eax
f0100ece:	e8 89 ff ff ff       	call   f0100e5c <printnum>
f0100ed3:	83 c4 20             	add    $0x20,%esp
f0100ed6:	eb 13                	jmp    f0100eeb <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ed8:	83 ec 08             	sub    $0x8,%esp
f0100edb:	56                   	push   %esi
f0100edc:	ff 75 18             	pushl  0x18(%ebp)
f0100edf:	ff d7                	call   *%edi
f0100ee1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100ee4:	83 eb 01             	sub    $0x1,%ebx
f0100ee7:	85 db                	test   %ebx,%ebx
f0100ee9:	7f ed                	jg     f0100ed8 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100eeb:	83 ec 08             	sub    $0x8,%esp
f0100eee:	56                   	push   %esi
f0100eef:	83 ec 04             	sub    $0x4,%esp
f0100ef2:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ef5:	ff 75 d8             	pushl  -0x28(%ebp)
f0100ef8:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100efb:	ff 75 d0             	pushl  -0x30(%ebp)
f0100efe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f01:	89 f3                	mov    %esi,%ebx
f0100f03:	e8 08 0b 00 00       	call   f0101a10 <__umoddi3>
f0100f08:	83 c4 14             	add    $0x14,%esp
f0100f0b:	0f be 84 06 59 0d ff 	movsbl -0xf2a7(%esi,%eax,1),%eax
f0100f12:	ff 
f0100f13:	50                   	push   %eax
f0100f14:	ff d7                	call   *%edi
}
f0100f16:	83 c4 10             	add    $0x10,%esp
f0100f19:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f1c:	5b                   	pop    %ebx
f0100f1d:	5e                   	pop    %esi
f0100f1e:	5f                   	pop    %edi
f0100f1f:	5d                   	pop    %ebp
f0100f20:	c3                   	ret    
f0100f21:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f24:	eb be                	jmp    f0100ee4 <printnum+0x88>

f0100f26 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f26:	55                   	push   %ebp
f0100f27:	89 e5                	mov    %esp,%ebp
f0100f29:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f2c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f30:	8b 10                	mov    (%eax),%edx
f0100f32:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f35:	73 0a                	jae    f0100f41 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f37:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f3a:	89 08                	mov    %ecx,(%eax)
f0100f3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f3f:	88 02                	mov    %al,(%edx)
}
f0100f41:	5d                   	pop    %ebp
f0100f42:	c3                   	ret    

f0100f43 <printfmt>:
{
f0100f43:	55                   	push   %ebp
f0100f44:	89 e5                	mov    %esp,%ebp
f0100f46:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f49:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f4c:	50                   	push   %eax
f0100f4d:	ff 75 10             	pushl  0x10(%ebp)
f0100f50:	ff 75 0c             	pushl  0xc(%ebp)
f0100f53:	ff 75 08             	pushl  0x8(%ebp)
f0100f56:	e8 05 00 00 00       	call   f0100f60 <vprintfmt>
}
f0100f5b:	83 c4 10             	add    $0x10,%esp
f0100f5e:	c9                   	leave  
f0100f5f:	c3                   	ret    

f0100f60 <vprintfmt>:
{
f0100f60:	55                   	push   %ebp
f0100f61:	89 e5                	mov    %esp,%ebp
f0100f63:	57                   	push   %edi
f0100f64:	56                   	push   %esi
f0100f65:	53                   	push   %ebx
f0100f66:	83 ec 2c             	sub    $0x2c,%esp
f0100f69:	e8 4e f2 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100f6e:	81 c3 9a 03 01 00    	add    $0x1039a,%ebx
f0100f74:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f77:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100f7a:	e9 c3 03 00 00       	jmp    f0101342 <.L35+0x48>
		padc = ' ';
f0100f7f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100f83:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100f8a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100f91:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100f98:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f9d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fa0:	8d 47 01             	lea    0x1(%edi),%eax
f0100fa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100fa6:	0f b6 17             	movzbl (%edi),%edx
f0100fa9:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100fac:	3c 55                	cmp    $0x55,%al
f0100fae:	0f 87 16 04 00 00    	ja     f01013ca <.L22>
f0100fb4:	0f b6 c0             	movzbl %al,%eax
f0100fb7:	89 d9                	mov    %ebx,%ecx
f0100fb9:	03 8c 83 e8 0d ff ff 	add    -0xf218(%ebx,%eax,4),%ecx
f0100fc0:	ff e1                	jmp    *%ecx

f0100fc2 <.L69>:
f0100fc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100fc5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100fc9:	eb d5                	jmp    f0100fa0 <vprintfmt+0x40>

f0100fcb <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0100fcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100fce:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100fd2:	eb cc                	jmp    f0100fa0 <vprintfmt+0x40>

f0100fd4 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0100fd4:	0f b6 d2             	movzbl %dl,%edx
f0100fd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100fda:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0100fdf:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100fe2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100fe6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100fe9:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100fec:	83 f9 09             	cmp    $0x9,%ecx
f0100fef:	77 55                	ja     f0101046 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0100ff1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0100ff4:	eb e9                	jmp    f0100fdf <.L29+0xb>

f0100ff6 <.L26>:
			precision = va_arg(ap, int);
f0100ff6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff9:	8b 00                	mov    (%eax),%eax
f0100ffb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ffe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101001:	8d 40 04             	lea    0x4(%eax),%eax
f0101004:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101007:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010100a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010100e:	79 90                	jns    f0100fa0 <vprintfmt+0x40>
				width = precision, precision = -1;
f0101010:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101013:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101016:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010101d:	eb 81                	jmp    f0100fa0 <vprintfmt+0x40>

f010101f <.L27>:
f010101f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101022:	85 c0                	test   %eax,%eax
f0101024:	ba 00 00 00 00       	mov    $0x0,%edx
f0101029:	0f 49 d0             	cmovns %eax,%edx
f010102c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010102f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101032:	e9 69 ff ff ff       	jmp    f0100fa0 <vprintfmt+0x40>

f0101037 <.L23>:
f0101037:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010103a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101041:	e9 5a ff ff ff       	jmp    f0100fa0 <vprintfmt+0x40>
f0101046:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101049:	eb bf                	jmp    f010100a <.L26+0x14>

f010104b <.L33>:
			lflag++;
f010104b:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010104f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0101052:	e9 49 ff ff ff       	jmp    f0100fa0 <vprintfmt+0x40>

f0101057 <.L30>:
			putch(va_arg(ap, int), putdat);
f0101057:	8b 45 14             	mov    0x14(%ebp),%eax
f010105a:	8d 78 04             	lea    0x4(%eax),%edi
f010105d:	83 ec 08             	sub    $0x8,%esp
f0101060:	56                   	push   %esi
f0101061:	ff 30                	pushl  (%eax)
f0101063:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101066:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101069:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f010106c:	e9 ce 02 00 00       	jmp    f010133f <.L35+0x45>

f0101071 <.L32>:
			err = va_arg(ap, int);
f0101071:	8b 45 14             	mov    0x14(%ebp),%eax
f0101074:	8d 78 04             	lea    0x4(%eax),%edi
f0101077:	8b 00                	mov    (%eax),%eax
f0101079:	99                   	cltd   
f010107a:	31 d0                	xor    %edx,%eax
f010107c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010107e:	83 f8 06             	cmp    $0x6,%eax
f0101081:	7f 27                	jg     f01010aa <.L32+0x39>
f0101083:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f010108a:	85 d2                	test   %edx,%edx
f010108c:	74 1c                	je     f01010aa <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f010108e:	52                   	push   %edx
f010108f:	8d 83 7a 0d ff ff    	lea    -0xf286(%ebx),%eax
f0101095:	50                   	push   %eax
f0101096:	56                   	push   %esi
f0101097:	ff 75 08             	pushl  0x8(%ebp)
f010109a:	e8 a4 fe ff ff       	call   f0100f43 <printfmt>
f010109f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010a2:	89 7d 14             	mov    %edi,0x14(%ebp)
f01010a5:	e9 95 02 00 00       	jmp    f010133f <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f01010aa:	50                   	push   %eax
f01010ab:	8d 83 71 0d ff ff    	lea    -0xf28f(%ebx),%eax
f01010b1:	50                   	push   %eax
f01010b2:	56                   	push   %esi
f01010b3:	ff 75 08             	pushl  0x8(%ebp)
f01010b6:	e8 88 fe ff ff       	call   f0100f43 <printfmt>
f01010bb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010be:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010c1:	e9 79 02 00 00       	jmp    f010133f <.L35+0x45>

f01010c6 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f01010c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c9:	83 c0 04             	add    $0x4,%eax
f01010cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01010cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01010d4:	85 ff                	test   %edi,%edi
f01010d6:	8d 83 6a 0d ff ff    	lea    -0xf296(%ebx),%eax
f01010dc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01010df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01010e3:	0f 8e b5 00 00 00    	jle    f010119e <.L36+0xd8>
f01010e9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01010ed:	75 08                	jne    f01010f7 <.L36+0x31>
f01010ef:	89 75 0c             	mov    %esi,0xc(%ebp)
f01010f2:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01010f5:	eb 6d                	jmp    f0101164 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f01010f7:	83 ec 08             	sub    $0x8,%esp
f01010fa:	ff 75 cc             	pushl  -0x34(%ebp)
f01010fd:	57                   	push   %edi
f01010fe:	e8 82 04 00 00       	call   f0101585 <strnlen>
f0101103:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101106:	29 c2                	sub    %eax,%edx
f0101108:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010110b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010110e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101112:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101115:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101118:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010111a:	eb 10                	jmp    f010112c <.L36+0x66>
					putch(padc, putdat);
f010111c:	83 ec 08             	sub    $0x8,%esp
f010111f:	56                   	push   %esi
f0101120:	ff 75 e0             	pushl  -0x20(%ebp)
f0101123:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101126:	83 ef 01             	sub    $0x1,%edi
f0101129:	83 c4 10             	add    $0x10,%esp
f010112c:	85 ff                	test   %edi,%edi
f010112e:	7f ec                	jg     f010111c <.L36+0x56>
f0101130:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101133:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101136:	85 d2                	test   %edx,%edx
f0101138:	b8 00 00 00 00       	mov    $0x0,%eax
f010113d:	0f 49 c2             	cmovns %edx,%eax
f0101140:	29 c2                	sub    %eax,%edx
f0101142:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101145:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101148:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010114b:	eb 17                	jmp    f0101164 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f010114d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101151:	75 30                	jne    f0101183 <.L36+0xbd>
					putch(ch, putdat);
f0101153:	83 ec 08             	sub    $0x8,%esp
f0101156:	ff 75 0c             	pushl  0xc(%ebp)
f0101159:	50                   	push   %eax
f010115a:	ff 55 08             	call   *0x8(%ebp)
f010115d:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101160:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0101164:	83 c7 01             	add    $0x1,%edi
f0101167:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f010116b:	0f be c2             	movsbl %dl,%eax
f010116e:	85 c0                	test   %eax,%eax
f0101170:	74 52                	je     f01011c4 <.L36+0xfe>
f0101172:	85 f6                	test   %esi,%esi
f0101174:	78 d7                	js     f010114d <.L36+0x87>
f0101176:	83 ee 01             	sub    $0x1,%esi
f0101179:	79 d2                	jns    f010114d <.L36+0x87>
f010117b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010117e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101181:	eb 32                	jmp    f01011b5 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0101183:	0f be d2             	movsbl %dl,%edx
f0101186:	83 ea 20             	sub    $0x20,%edx
f0101189:	83 fa 5e             	cmp    $0x5e,%edx
f010118c:	76 c5                	jbe    f0101153 <.L36+0x8d>
					putch('?', putdat);
f010118e:	83 ec 08             	sub    $0x8,%esp
f0101191:	ff 75 0c             	pushl  0xc(%ebp)
f0101194:	6a 3f                	push   $0x3f
f0101196:	ff 55 08             	call   *0x8(%ebp)
f0101199:	83 c4 10             	add    $0x10,%esp
f010119c:	eb c2                	jmp    f0101160 <.L36+0x9a>
f010119e:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011a1:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011a4:	eb be                	jmp    f0101164 <.L36+0x9e>
				putch(' ', putdat);
f01011a6:	83 ec 08             	sub    $0x8,%esp
f01011a9:	56                   	push   %esi
f01011aa:	6a 20                	push   $0x20
f01011ac:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01011af:	83 ef 01             	sub    $0x1,%edi
f01011b2:	83 c4 10             	add    $0x10,%esp
f01011b5:	85 ff                	test   %edi,%edi
f01011b7:	7f ed                	jg     f01011a6 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01011b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01011bc:	89 45 14             	mov    %eax,0x14(%ebp)
f01011bf:	e9 7b 01 00 00       	jmp    f010133f <.L35+0x45>
f01011c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011ca:	eb e9                	jmp    f01011b5 <.L36+0xef>

f01011cc <.L31>:
f01011cc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01011cf:	83 f9 01             	cmp    $0x1,%ecx
f01011d2:	7e 40                	jle    f0101214 <.L31+0x48>
		return va_arg(*ap, long long);
f01011d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d7:	8b 50 04             	mov    0x4(%eax),%edx
f01011da:	8b 00                	mov    (%eax),%eax
f01011dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011df:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e5:	8d 40 08             	lea    0x8(%eax),%eax
f01011e8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01011eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01011ef:	79 55                	jns    f0101246 <.L31+0x7a>
				putch('-', putdat);
f01011f1:	83 ec 08             	sub    $0x8,%esp
f01011f4:	56                   	push   %esi
f01011f5:	6a 2d                	push   $0x2d
f01011f7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01011fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01011fd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101200:	f7 da                	neg    %edx
f0101202:	83 d1 00             	adc    $0x0,%ecx
f0101205:	f7 d9                	neg    %ecx
f0101207:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010120a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010120f:	e9 10 01 00 00       	jmp    f0101324 <.L35+0x2a>
	else if (lflag)
f0101214:	85 c9                	test   %ecx,%ecx
f0101216:	75 17                	jne    f010122f <.L31+0x63>
		return va_arg(*ap, int);
f0101218:	8b 45 14             	mov    0x14(%ebp),%eax
f010121b:	8b 00                	mov    (%eax),%eax
f010121d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101220:	99                   	cltd   
f0101221:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101224:	8b 45 14             	mov    0x14(%ebp),%eax
f0101227:	8d 40 04             	lea    0x4(%eax),%eax
f010122a:	89 45 14             	mov    %eax,0x14(%ebp)
f010122d:	eb bc                	jmp    f01011eb <.L31+0x1f>
		return va_arg(*ap, long);
f010122f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101232:	8b 00                	mov    (%eax),%eax
f0101234:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101237:	99                   	cltd   
f0101238:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010123b:	8b 45 14             	mov    0x14(%ebp),%eax
f010123e:	8d 40 04             	lea    0x4(%eax),%eax
f0101241:	89 45 14             	mov    %eax,0x14(%ebp)
f0101244:	eb a5                	jmp    f01011eb <.L31+0x1f>
			num = getint(&ap, lflag);
f0101246:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101249:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010124c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101251:	e9 ce 00 00 00       	jmp    f0101324 <.L35+0x2a>

f0101256 <.L37>:
f0101256:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101259:	83 f9 01             	cmp    $0x1,%ecx
f010125c:	7e 18                	jle    f0101276 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f010125e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101261:	8b 10                	mov    (%eax),%edx
f0101263:	8b 48 04             	mov    0x4(%eax),%ecx
f0101266:	8d 40 08             	lea    0x8(%eax),%eax
f0101269:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010126c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101271:	e9 ae 00 00 00       	jmp    f0101324 <.L35+0x2a>
	else if (lflag)
f0101276:	85 c9                	test   %ecx,%ecx
f0101278:	75 1a                	jne    f0101294 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f010127a:	8b 45 14             	mov    0x14(%ebp),%eax
f010127d:	8b 10                	mov    (%eax),%edx
f010127f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101284:	8d 40 04             	lea    0x4(%eax),%eax
f0101287:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010128a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010128f:	e9 90 00 00 00       	jmp    f0101324 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0101294:	8b 45 14             	mov    0x14(%ebp),%eax
f0101297:	8b 10                	mov    (%eax),%edx
f0101299:	b9 00 00 00 00       	mov    $0x0,%ecx
f010129e:	8d 40 04             	lea    0x4(%eax),%eax
f01012a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012a4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012a9:	eb 79                	jmp    f0101324 <.L35+0x2a>

f01012ab <.L34>:
f01012ab:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012ae:	83 f9 01             	cmp    $0x1,%ecx
f01012b1:	7e 15                	jle    f01012c8 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f01012b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b6:	8b 10                	mov    (%eax),%edx
f01012b8:	8b 48 04             	mov    0x4(%eax),%ecx
f01012bb:	8d 40 08             	lea    0x8(%eax),%eax
f01012be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012c1:	b8 08 00 00 00       	mov    $0x8,%eax
f01012c6:	eb 5c                	jmp    f0101324 <.L35+0x2a>
	else if (lflag)
f01012c8:	85 c9                	test   %ecx,%ecx
f01012ca:	75 17                	jne    f01012e3 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f01012cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01012cf:	8b 10                	mov    (%eax),%edx
f01012d1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012d6:	8d 40 04             	lea    0x4(%eax),%eax
f01012d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012dc:	b8 08 00 00 00       	mov    $0x8,%eax
f01012e1:	eb 41                	jmp    f0101324 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01012e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e6:	8b 10                	mov    (%eax),%edx
f01012e8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012ed:	8d 40 04             	lea    0x4(%eax),%eax
f01012f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012f3:	b8 08 00 00 00       	mov    $0x8,%eax
f01012f8:	eb 2a                	jmp    f0101324 <.L35+0x2a>

f01012fa <.L35>:
			putch('0', putdat);
f01012fa:	83 ec 08             	sub    $0x8,%esp
f01012fd:	56                   	push   %esi
f01012fe:	6a 30                	push   $0x30
f0101300:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101303:	83 c4 08             	add    $0x8,%esp
f0101306:	56                   	push   %esi
f0101307:	6a 78                	push   $0x78
f0101309:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010130c:	8b 45 14             	mov    0x14(%ebp),%eax
f010130f:	8b 10                	mov    (%eax),%edx
f0101311:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101316:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101319:	8d 40 04             	lea    0x4(%eax),%eax
f010131c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010131f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101324:	83 ec 0c             	sub    $0xc,%esp
f0101327:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010132b:	57                   	push   %edi
f010132c:	ff 75 e0             	pushl  -0x20(%ebp)
f010132f:	50                   	push   %eax
f0101330:	51                   	push   %ecx
f0101331:	52                   	push   %edx
f0101332:	89 f2                	mov    %esi,%edx
f0101334:	8b 45 08             	mov    0x8(%ebp),%eax
f0101337:	e8 20 fb ff ff       	call   f0100e5c <printnum>
			break;
f010133c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010133f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101342:	83 c7 01             	add    $0x1,%edi
f0101345:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101349:	83 f8 25             	cmp    $0x25,%eax
f010134c:	0f 84 2d fc ff ff    	je     f0100f7f <vprintfmt+0x1f>
			if (ch == '\0')
f0101352:	85 c0                	test   %eax,%eax
f0101354:	0f 84 91 00 00 00    	je     f01013eb <.L22+0x21>
			putch(ch, putdat);
f010135a:	83 ec 08             	sub    $0x8,%esp
f010135d:	56                   	push   %esi
f010135e:	50                   	push   %eax
f010135f:	ff 55 08             	call   *0x8(%ebp)
f0101362:	83 c4 10             	add    $0x10,%esp
f0101365:	eb db                	jmp    f0101342 <.L35+0x48>

f0101367 <.L38>:
f0101367:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010136a:	83 f9 01             	cmp    $0x1,%ecx
f010136d:	7e 15                	jle    f0101384 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f010136f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101372:	8b 10                	mov    (%eax),%edx
f0101374:	8b 48 04             	mov    0x4(%eax),%ecx
f0101377:	8d 40 08             	lea    0x8(%eax),%eax
f010137a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010137d:	b8 10 00 00 00       	mov    $0x10,%eax
f0101382:	eb a0                	jmp    f0101324 <.L35+0x2a>
	else if (lflag)
f0101384:	85 c9                	test   %ecx,%ecx
f0101386:	75 17                	jne    f010139f <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0101388:	8b 45 14             	mov    0x14(%ebp),%eax
f010138b:	8b 10                	mov    (%eax),%edx
f010138d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101392:	8d 40 04             	lea    0x4(%eax),%eax
f0101395:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101398:	b8 10 00 00 00       	mov    $0x10,%eax
f010139d:	eb 85                	jmp    f0101324 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010139f:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a2:	8b 10                	mov    (%eax),%edx
f01013a4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013a9:	8d 40 04             	lea    0x4(%eax),%eax
f01013ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013af:	b8 10 00 00 00       	mov    $0x10,%eax
f01013b4:	e9 6b ff ff ff       	jmp    f0101324 <.L35+0x2a>

f01013b9 <.L25>:
			putch(ch, putdat);
f01013b9:	83 ec 08             	sub    $0x8,%esp
f01013bc:	56                   	push   %esi
f01013bd:	6a 25                	push   $0x25
f01013bf:	ff 55 08             	call   *0x8(%ebp)
			break;
f01013c2:	83 c4 10             	add    $0x10,%esp
f01013c5:	e9 75 ff ff ff       	jmp    f010133f <.L35+0x45>

f01013ca <.L22>:
			putch('%', putdat);
f01013ca:	83 ec 08             	sub    $0x8,%esp
f01013cd:	56                   	push   %esi
f01013ce:	6a 25                	push   $0x25
f01013d0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013d3:	83 c4 10             	add    $0x10,%esp
f01013d6:	89 f8                	mov    %edi,%eax
f01013d8:	eb 03                	jmp    f01013dd <.L22+0x13>
f01013da:	83 e8 01             	sub    $0x1,%eax
f01013dd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01013e1:	75 f7                	jne    f01013da <.L22+0x10>
f01013e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013e6:	e9 54 ff ff ff       	jmp    f010133f <.L35+0x45>
}
f01013eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013ee:	5b                   	pop    %ebx
f01013ef:	5e                   	pop    %esi
f01013f0:	5f                   	pop    %edi
f01013f1:	5d                   	pop    %ebp
f01013f2:	c3                   	ret    

f01013f3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01013f3:	55                   	push   %ebp
f01013f4:	89 e5                	mov    %esp,%ebp
f01013f6:	53                   	push   %ebx
f01013f7:	83 ec 14             	sub    $0x14,%esp
f01013fa:	e8 bd ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01013ff:	81 c3 09 ff 00 00    	add    $0xff09,%ebx
f0101405:	8b 45 08             	mov    0x8(%ebp),%eax
f0101408:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010140b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010140e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101412:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101415:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010141c:	85 c0                	test   %eax,%eax
f010141e:	74 2b                	je     f010144b <vsnprintf+0x58>
f0101420:	85 d2                	test   %edx,%edx
f0101422:	7e 27                	jle    f010144b <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101424:	ff 75 14             	pushl  0x14(%ebp)
f0101427:	ff 75 10             	pushl  0x10(%ebp)
f010142a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010142d:	50                   	push   %eax
f010142e:	8d 83 1e fc fe ff    	lea    -0x103e2(%ebx),%eax
f0101434:	50                   	push   %eax
f0101435:	e8 26 fb ff ff       	call   f0100f60 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010143a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010143d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101440:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101443:	83 c4 10             	add    $0x10,%esp
}
f0101446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101449:	c9                   	leave  
f010144a:	c3                   	ret    
		return -E_INVAL;
f010144b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101450:	eb f4                	jmp    f0101446 <vsnprintf+0x53>

f0101452 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101452:	55                   	push   %ebp
f0101453:	89 e5                	mov    %esp,%ebp
f0101455:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101458:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010145b:	50                   	push   %eax
f010145c:	ff 75 10             	pushl  0x10(%ebp)
f010145f:	ff 75 0c             	pushl  0xc(%ebp)
f0101462:	ff 75 08             	pushl  0x8(%ebp)
f0101465:	e8 89 ff ff ff       	call   f01013f3 <vsnprintf>
	va_end(ap);

	return rc;
}
f010146a:	c9                   	leave  
f010146b:	c3                   	ret    

f010146c <__x86.get_pc_thunk.cx>:
f010146c:	8b 0c 24             	mov    (%esp),%ecx
f010146f:	c3                   	ret    

f0101470 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101470:	55                   	push   %ebp
f0101471:	89 e5                	mov    %esp,%ebp
f0101473:	57                   	push   %edi
f0101474:	56                   	push   %esi
f0101475:	53                   	push   %ebx
f0101476:	83 ec 1c             	sub    $0x1c,%esp
f0101479:	e8 3e ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010147e:	81 c3 8a fe 00 00    	add    $0xfe8a,%ebx
f0101484:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101487:	85 c0                	test   %eax,%eax
f0101489:	74 13                	je     f010149e <readline+0x2e>
		cprintf("%s", prompt);
f010148b:	83 ec 08             	sub    $0x8,%esp
f010148e:	50                   	push   %eax
f010148f:	8d 83 7a 0d ff ff    	lea    -0xf286(%ebx),%eax
f0101495:	50                   	push   %eax
f0101496:	e8 40 f6 ff ff       	call   f0100adb <cprintf>
f010149b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010149e:	83 ec 0c             	sub    $0xc,%esp
f01014a1:	6a 00                	push   $0x0
f01014a3:	e8 ac f2 ff ff       	call   f0100754 <iscons>
f01014a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014ab:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01014ae:	bf 00 00 00 00       	mov    $0x0,%edi
f01014b3:	eb 46                	jmp    f01014fb <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01014b5:	83 ec 08             	sub    $0x8,%esp
f01014b8:	50                   	push   %eax
f01014b9:	8d 83 40 0f ff ff    	lea    -0xf0c0(%ebx),%eax
f01014bf:	50                   	push   %eax
f01014c0:	e8 16 f6 ff ff       	call   f0100adb <cprintf>
			return NULL;
f01014c5:	83 c4 10             	add    $0x10,%esp
f01014c8:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014d0:	5b                   	pop    %ebx
f01014d1:	5e                   	pop    %esi
f01014d2:	5f                   	pop    %edi
f01014d3:	5d                   	pop    %ebp
f01014d4:	c3                   	ret    
			if (echoing)
f01014d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014d9:	75 05                	jne    f01014e0 <readline+0x70>
			i--;
f01014db:	83 ef 01             	sub    $0x1,%edi
f01014de:	eb 1b                	jmp    f01014fb <readline+0x8b>
				cputchar('\b');
f01014e0:	83 ec 0c             	sub    $0xc,%esp
f01014e3:	6a 08                	push   $0x8
f01014e5:	e8 49 f2 ff ff       	call   f0100733 <cputchar>
f01014ea:	83 c4 10             	add    $0x10,%esp
f01014ed:	eb ec                	jmp    f01014db <readline+0x6b>
			buf[i++] = c;
f01014ef:	89 f0                	mov    %esi,%eax
f01014f1:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f01014f8:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01014fb:	e8 43 f2 ff ff       	call   f0100743 <getchar>
f0101500:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101502:	85 c0                	test   %eax,%eax
f0101504:	78 af                	js     f01014b5 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101506:	83 f8 08             	cmp    $0x8,%eax
f0101509:	0f 94 c2             	sete   %dl
f010150c:	83 f8 7f             	cmp    $0x7f,%eax
f010150f:	0f 94 c0             	sete   %al
f0101512:	08 c2                	or     %al,%dl
f0101514:	74 04                	je     f010151a <readline+0xaa>
f0101516:	85 ff                	test   %edi,%edi
f0101518:	7f bb                	jg     f01014d5 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010151a:	83 fe 1f             	cmp    $0x1f,%esi
f010151d:	7e 1c                	jle    f010153b <readline+0xcb>
f010151f:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101525:	7f 14                	jg     f010153b <readline+0xcb>
			if (echoing)
f0101527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010152b:	74 c2                	je     f01014ef <readline+0x7f>
				cputchar(c);
f010152d:	83 ec 0c             	sub    $0xc,%esp
f0101530:	56                   	push   %esi
f0101531:	e8 fd f1 ff ff       	call   f0100733 <cputchar>
f0101536:	83 c4 10             	add    $0x10,%esp
f0101539:	eb b4                	jmp    f01014ef <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010153b:	83 fe 0a             	cmp    $0xa,%esi
f010153e:	74 05                	je     f0101545 <readline+0xd5>
f0101540:	83 fe 0d             	cmp    $0xd,%esi
f0101543:	75 b6                	jne    f01014fb <readline+0x8b>
			if (echoing)
f0101545:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101549:	75 13                	jne    f010155e <readline+0xee>
			buf[i] = 0;
f010154b:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101552:	00 
			return buf;
f0101553:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101559:	e9 6f ff ff ff       	jmp    f01014cd <readline+0x5d>
				cputchar('\n');
f010155e:	83 ec 0c             	sub    $0xc,%esp
f0101561:	6a 0a                	push   $0xa
f0101563:	e8 cb f1 ff ff       	call   f0100733 <cputchar>
f0101568:	83 c4 10             	add    $0x10,%esp
f010156b:	eb de                	jmp    f010154b <readline+0xdb>

f010156d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010156d:	55                   	push   %ebp
f010156e:	89 e5                	mov    %esp,%ebp
f0101570:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101573:	b8 00 00 00 00       	mov    $0x0,%eax
f0101578:	eb 03                	jmp    f010157d <strlen+0x10>
		n++;
f010157a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010157d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101581:	75 f7                	jne    f010157a <strlen+0xd>
	return n;
}
f0101583:	5d                   	pop    %ebp
f0101584:	c3                   	ret    

f0101585 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101585:	55                   	push   %ebp
f0101586:	89 e5                	mov    %esp,%ebp
f0101588:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010158b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010158e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101593:	eb 03                	jmp    f0101598 <strnlen+0x13>
		n++;
f0101595:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101598:	39 d0                	cmp    %edx,%eax
f010159a:	74 06                	je     f01015a2 <strnlen+0x1d>
f010159c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015a0:	75 f3                	jne    f0101595 <strnlen+0x10>
	return n;
}
f01015a2:	5d                   	pop    %ebp
f01015a3:	c3                   	ret    

f01015a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015a4:	55                   	push   %ebp
f01015a5:	89 e5                	mov    %esp,%ebp
f01015a7:	53                   	push   %ebx
f01015a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015ae:	89 c2                	mov    %eax,%edx
f01015b0:	83 c1 01             	add    $0x1,%ecx
f01015b3:	83 c2 01             	add    $0x1,%edx
f01015b6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01015ba:	88 5a ff             	mov    %bl,-0x1(%edx)
f01015bd:	84 db                	test   %bl,%bl
f01015bf:	75 ef                	jne    f01015b0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01015c1:	5b                   	pop    %ebx
f01015c2:	5d                   	pop    %ebp
f01015c3:	c3                   	ret    

f01015c4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015c4:	55                   	push   %ebp
f01015c5:	89 e5                	mov    %esp,%ebp
f01015c7:	53                   	push   %ebx
f01015c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015cb:	53                   	push   %ebx
f01015cc:	e8 9c ff ff ff       	call   f010156d <strlen>
f01015d1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01015d4:	ff 75 0c             	pushl  0xc(%ebp)
f01015d7:	01 d8                	add    %ebx,%eax
f01015d9:	50                   	push   %eax
f01015da:	e8 c5 ff ff ff       	call   f01015a4 <strcpy>
	return dst;
}
f01015df:	89 d8                	mov    %ebx,%eax
f01015e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015e4:	c9                   	leave  
f01015e5:	c3                   	ret    

f01015e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01015e6:	55                   	push   %ebp
f01015e7:	89 e5                	mov    %esp,%ebp
f01015e9:	56                   	push   %esi
f01015ea:	53                   	push   %ebx
f01015eb:	8b 75 08             	mov    0x8(%ebp),%esi
f01015ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01015f1:	89 f3                	mov    %esi,%ebx
f01015f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01015f6:	89 f2                	mov    %esi,%edx
f01015f8:	eb 0f                	jmp    f0101609 <strncpy+0x23>
		*dst++ = *src;
f01015fa:	83 c2 01             	add    $0x1,%edx
f01015fd:	0f b6 01             	movzbl (%ecx),%eax
f0101600:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101603:	80 39 01             	cmpb   $0x1,(%ecx)
f0101606:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101609:	39 da                	cmp    %ebx,%edx
f010160b:	75 ed                	jne    f01015fa <strncpy+0x14>
	}
	return ret;
}
f010160d:	89 f0                	mov    %esi,%eax
f010160f:	5b                   	pop    %ebx
f0101610:	5e                   	pop    %esi
f0101611:	5d                   	pop    %ebp
f0101612:	c3                   	ret    

f0101613 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101613:	55                   	push   %ebp
f0101614:	89 e5                	mov    %esp,%ebp
f0101616:	56                   	push   %esi
f0101617:	53                   	push   %ebx
f0101618:	8b 75 08             	mov    0x8(%ebp),%esi
f010161b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010161e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101621:	89 f0                	mov    %esi,%eax
f0101623:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101627:	85 c9                	test   %ecx,%ecx
f0101629:	75 0b                	jne    f0101636 <strlcpy+0x23>
f010162b:	eb 17                	jmp    f0101644 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010162d:	83 c2 01             	add    $0x1,%edx
f0101630:	83 c0 01             	add    $0x1,%eax
f0101633:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101636:	39 d8                	cmp    %ebx,%eax
f0101638:	74 07                	je     f0101641 <strlcpy+0x2e>
f010163a:	0f b6 0a             	movzbl (%edx),%ecx
f010163d:	84 c9                	test   %cl,%cl
f010163f:	75 ec                	jne    f010162d <strlcpy+0x1a>
		*dst = '\0';
f0101641:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101644:	29 f0                	sub    %esi,%eax
}
f0101646:	5b                   	pop    %ebx
f0101647:	5e                   	pop    %esi
f0101648:	5d                   	pop    %ebp
f0101649:	c3                   	ret    

f010164a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010164a:	55                   	push   %ebp
f010164b:	89 e5                	mov    %esp,%ebp
f010164d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101650:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101653:	eb 06                	jmp    f010165b <strcmp+0x11>
		p++, q++;
f0101655:	83 c1 01             	add    $0x1,%ecx
f0101658:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010165b:	0f b6 01             	movzbl (%ecx),%eax
f010165e:	84 c0                	test   %al,%al
f0101660:	74 04                	je     f0101666 <strcmp+0x1c>
f0101662:	3a 02                	cmp    (%edx),%al
f0101664:	74 ef                	je     f0101655 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101666:	0f b6 c0             	movzbl %al,%eax
f0101669:	0f b6 12             	movzbl (%edx),%edx
f010166c:	29 d0                	sub    %edx,%eax
}
f010166e:	5d                   	pop    %ebp
f010166f:	c3                   	ret    

f0101670 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101670:	55                   	push   %ebp
f0101671:	89 e5                	mov    %esp,%ebp
f0101673:	53                   	push   %ebx
f0101674:	8b 45 08             	mov    0x8(%ebp),%eax
f0101677:	8b 55 0c             	mov    0xc(%ebp),%edx
f010167a:	89 c3                	mov    %eax,%ebx
f010167c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010167f:	eb 06                	jmp    f0101687 <strncmp+0x17>
		n--, p++, q++;
f0101681:	83 c0 01             	add    $0x1,%eax
f0101684:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101687:	39 d8                	cmp    %ebx,%eax
f0101689:	74 16                	je     f01016a1 <strncmp+0x31>
f010168b:	0f b6 08             	movzbl (%eax),%ecx
f010168e:	84 c9                	test   %cl,%cl
f0101690:	74 04                	je     f0101696 <strncmp+0x26>
f0101692:	3a 0a                	cmp    (%edx),%cl
f0101694:	74 eb                	je     f0101681 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101696:	0f b6 00             	movzbl (%eax),%eax
f0101699:	0f b6 12             	movzbl (%edx),%edx
f010169c:	29 d0                	sub    %edx,%eax
}
f010169e:	5b                   	pop    %ebx
f010169f:	5d                   	pop    %ebp
f01016a0:	c3                   	ret    
		return 0;
f01016a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01016a6:	eb f6                	jmp    f010169e <strncmp+0x2e>

f01016a8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016a8:	55                   	push   %ebp
f01016a9:	89 e5                	mov    %esp,%ebp
f01016ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016b2:	0f b6 10             	movzbl (%eax),%edx
f01016b5:	84 d2                	test   %dl,%dl
f01016b7:	74 09                	je     f01016c2 <strchr+0x1a>
		if (*s == c)
f01016b9:	38 ca                	cmp    %cl,%dl
f01016bb:	74 0a                	je     f01016c7 <strchr+0x1f>
	for (; *s; s++)
f01016bd:	83 c0 01             	add    $0x1,%eax
f01016c0:	eb f0                	jmp    f01016b2 <strchr+0xa>
			return (char *) s;
	return 0;
f01016c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016c7:	5d                   	pop    %ebp
f01016c8:	c3                   	ret    

f01016c9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016c9:	55                   	push   %ebp
f01016ca:	89 e5                	mov    %esp,%ebp
f01016cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01016cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016d3:	eb 03                	jmp    f01016d8 <strfind+0xf>
f01016d5:	83 c0 01             	add    $0x1,%eax
f01016d8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01016db:	38 ca                	cmp    %cl,%dl
f01016dd:	74 04                	je     f01016e3 <strfind+0x1a>
f01016df:	84 d2                	test   %dl,%dl
f01016e1:	75 f2                	jne    f01016d5 <strfind+0xc>
			break;
	return (char *) s;
}
f01016e3:	5d                   	pop    %ebp
f01016e4:	c3                   	ret    

f01016e5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01016e5:	55                   	push   %ebp
f01016e6:	89 e5                	mov    %esp,%ebp
f01016e8:	57                   	push   %edi
f01016e9:	56                   	push   %esi
f01016ea:	53                   	push   %ebx
f01016eb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01016ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01016f1:	85 c9                	test   %ecx,%ecx
f01016f3:	74 13                	je     f0101708 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01016f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01016fb:	75 05                	jne    f0101702 <memset+0x1d>
f01016fd:	f6 c1 03             	test   $0x3,%cl
f0101700:	74 0d                	je     f010170f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101702:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101705:	fc                   	cld    
f0101706:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101708:	89 f8                	mov    %edi,%eax
f010170a:	5b                   	pop    %ebx
f010170b:	5e                   	pop    %esi
f010170c:	5f                   	pop    %edi
f010170d:	5d                   	pop    %ebp
f010170e:	c3                   	ret    
		c &= 0xFF;
f010170f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101713:	89 d3                	mov    %edx,%ebx
f0101715:	c1 e3 08             	shl    $0x8,%ebx
f0101718:	89 d0                	mov    %edx,%eax
f010171a:	c1 e0 18             	shl    $0x18,%eax
f010171d:	89 d6                	mov    %edx,%esi
f010171f:	c1 e6 10             	shl    $0x10,%esi
f0101722:	09 f0                	or     %esi,%eax
f0101724:	09 c2                	or     %eax,%edx
f0101726:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101728:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010172b:	89 d0                	mov    %edx,%eax
f010172d:	fc                   	cld    
f010172e:	f3 ab                	rep stos %eax,%es:(%edi)
f0101730:	eb d6                	jmp    f0101708 <memset+0x23>

f0101732 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101732:	55                   	push   %ebp
f0101733:	89 e5                	mov    %esp,%ebp
f0101735:	57                   	push   %edi
f0101736:	56                   	push   %esi
f0101737:	8b 45 08             	mov    0x8(%ebp),%eax
f010173a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010173d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101740:	39 c6                	cmp    %eax,%esi
f0101742:	73 35                	jae    f0101779 <memmove+0x47>
f0101744:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101747:	39 c2                	cmp    %eax,%edx
f0101749:	76 2e                	jbe    f0101779 <memmove+0x47>
		s += n;
		d += n;
f010174b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010174e:	89 d6                	mov    %edx,%esi
f0101750:	09 fe                	or     %edi,%esi
f0101752:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101758:	74 0c                	je     f0101766 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010175a:	83 ef 01             	sub    $0x1,%edi
f010175d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101760:	fd                   	std    
f0101761:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101763:	fc                   	cld    
f0101764:	eb 21                	jmp    f0101787 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101766:	f6 c1 03             	test   $0x3,%cl
f0101769:	75 ef                	jne    f010175a <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010176b:	83 ef 04             	sub    $0x4,%edi
f010176e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101771:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101774:	fd                   	std    
f0101775:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101777:	eb ea                	jmp    f0101763 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101779:	89 f2                	mov    %esi,%edx
f010177b:	09 c2                	or     %eax,%edx
f010177d:	f6 c2 03             	test   $0x3,%dl
f0101780:	74 09                	je     f010178b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101782:	89 c7                	mov    %eax,%edi
f0101784:	fc                   	cld    
f0101785:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101787:	5e                   	pop    %esi
f0101788:	5f                   	pop    %edi
f0101789:	5d                   	pop    %ebp
f010178a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010178b:	f6 c1 03             	test   $0x3,%cl
f010178e:	75 f2                	jne    f0101782 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101790:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101793:	89 c7                	mov    %eax,%edi
f0101795:	fc                   	cld    
f0101796:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101798:	eb ed                	jmp    f0101787 <memmove+0x55>

f010179a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010179a:	55                   	push   %ebp
f010179b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010179d:	ff 75 10             	pushl  0x10(%ebp)
f01017a0:	ff 75 0c             	pushl  0xc(%ebp)
f01017a3:	ff 75 08             	pushl  0x8(%ebp)
f01017a6:	e8 87 ff ff ff       	call   f0101732 <memmove>
}
f01017ab:	c9                   	leave  
f01017ac:	c3                   	ret    

f01017ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017ad:	55                   	push   %ebp
f01017ae:	89 e5                	mov    %esp,%ebp
f01017b0:	56                   	push   %esi
f01017b1:	53                   	push   %ebx
f01017b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017b8:	89 c6                	mov    %eax,%esi
f01017ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017bd:	39 f0                	cmp    %esi,%eax
f01017bf:	74 1c                	je     f01017dd <memcmp+0x30>
		if (*s1 != *s2)
f01017c1:	0f b6 08             	movzbl (%eax),%ecx
f01017c4:	0f b6 1a             	movzbl (%edx),%ebx
f01017c7:	38 d9                	cmp    %bl,%cl
f01017c9:	75 08                	jne    f01017d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01017cb:	83 c0 01             	add    $0x1,%eax
f01017ce:	83 c2 01             	add    $0x1,%edx
f01017d1:	eb ea                	jmp    f01017bd <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01017d3:	0f b6 c1             	movzbl %cl,%eax
f01017d6:	0f b6 db             	movzbl %bl,%ebx
f01017d9:	29 d8                	sub    %ebx,%eax
f01017db:	eb 05                	jmp    f01017e2 <memcmp+0x35>
	}

	return 0;
f01017dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017e2:	5b                   	pop    %ebx
f01017e3:	5e                   	pop    %esi
f01017e4:	5d                   	pop    %ebp
f01017e5:	c3                   	ret    

f01017e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01017e6:	55                   	push   %ebp
f01017e7:	89 e5                	mov    %esp,%ebp
f01017e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01017ef:	89 c2                	mov    %eax,%edx
f01017f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01017f4:	39 d0                	cmp    %edx,%eax
f01017f6:	73 09                	jae    f0101801 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01017f8:	38 08                	cmp    %cl,(%eax)
f01017fa:	74 05                	je     f0101801 <memfind+0x1b>
	for (; s < ends; s++)
f01017fc:	83 c0 01             	add    $0x1,%eax
f01017ff:	eb f3                	jmp    f01017f4 <memfind+0xe>
			break;
	return (void *) s;
}
f0101801:	5d                   	pop    %ebp
f0101802:	c3                   	ret    

f0101803 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101803:	55                   	push   %ebp
f0101804:	89 e5                	mov    %esp,%ebp
f0101806:	57                   	push   %edi
f0101807:	56                   	push   %esi
f0101808:	53                   	push   %ebx
f0101809:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010180c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010180f:	eb 03                	jmp    f0101814 <strtol+0x11>
		s++;
f0101811:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101814:	0f b6 01             	movzbl (%ecx),%eax
f0101817:	3c 20                	cmp    $0x20,%al
f0101819:	74 f6                	je     f0101811 <strtol+0xe>
f010181b:	3c 09                	cmp    $0x9,%al
f010181d:	74 f2                	je     f0101811 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010181f:	3c 2b                	cmp    $0x2b,%al
f0101821:	74 2e                	je     f0101851 <strtol+0x4e>
	int neg = 0;
f0101823:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101828:	3c 2d                	cmp    $0x2d,%al
f010182a:	74 2f                	je     f010185b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010182c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101832:	75 05                	jne    f0101839 <strtol+0x36>
f0101834:	80 39 30             	cmpb   $0x30,(%ecx)
f0101837:	74 2c                	je     f0101865 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101839:	85 db                	test   %ebx,%ebx
f010183b:	75 0a                	jne    f0101847 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010183d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101842:	80 39 30             	cmpb   $0x30,(%ecx)
f0101845:	74 28                	je     f010186f <strtol+0x6c>
		base = 10;
f0101847:	b8 00 00 00 00       	mov    $0x0,%eax
f010184c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010184f:	eb 50                	jmp    f01018a1 <strtol+0x9e>
		s++;
f0101851:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101854:	bf 00 00 00 00       	mov    $0x0,%edi
f0101859:	eb d1                	jmp    f010182c <strtol+0x29>
		s++, neg = 1;
f010185b:	83 c1 01             	add    $0x1,%ecx
f010185e:	bf 01 00 00 00       	mov    $0x1,%edi
f0101863:	eb c7                	jmp    f010182c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101865:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101869:	74 0e                	je     f0101879 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010186b:	85 db                	test   %ebx,%ebx
f010186d:	75 d8                	jne    f0101847 <strtol+0x44>
		s++, base = 8;
f010186f:	83 c1 01             	add    $0x1,%ecx
f0101872:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101877:	eb ce                	jmp    f0101847 <strtol+0x44>
		s += 2, base = 16;
f0101879:	83 c1 02             	add    $0x2,%ecx
f010187c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101881:	eb c4                	jmp    f0101847 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101883:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101886:	89 f3                	mov    %esi,%ebx
f0101888:	80 fb 19             	cmp    $0x19,%bl
f010188b:	77 29                	ja     f01018b6 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010188d:	0f be d2             	movsbl %dl,%edx
f0101890:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101893:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101896:	7d 30                	jge    f01018c8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0101898:	83 c1 01             	add    $0x1,%ecx
f010189b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010189f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01018a1:	0f b6 11             	movzbl (%ecx),%edx
f01018a4:	8d 72 d0             	lea    -0x30(%edx),%esi
f01018a7:	89 f3                	mov    %esi,%ebx
f01018a9:	80 fb 09             	cmp    $0x9,%bl
f01018ac:	77 d5                	ja     f0101883 <strtol+0x80>
			dig = *s - '0';
f01018ae:	0f be d2             	movsbl %dl,%edx
f01018b1:	83 ea 30             	sub    $0x30,%edx
f01018b4:	eb dd                	jmp    f0101893 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01018b6:	8d 72 bf             	lea    -0x41(%edx),%esi
f01018b9:	89 f3                	mov    %esi,%ebx
f01018bb:	80 fb 19             	cmp    $0x19,%bl
f01018be:	77 08                	ja     f01018c8 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01018c0:	0f be d2             	movsbl %dl,%edx
f01018c3:	83 ea 37             	sub    $0x37,%edx
f01018c6:	eb cb                	jmp    f0101893 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01018c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01018cc:	74 05                	je     f01018d3 <strtol+0xd0>
		*endptr = (char *) s;
f01018ce:	8b 75 0c             	mov    0xc(%ebp),%esi
f01018d1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01018d3:	89 c2                	mov    %eax,%edx
f01018d5:	f7 da                	neg    %edx
f01018d7:	85 ff                	test   %edi,%edi
f01018d9:	0f 45 c2             	cmovne %edx,%eax
}
f01018dc:	5b                   	pop    %ebx
f01018dd:	5e                   	pop    %esi
f01018de:	5f                   	pop    %edi
f01018df:	5d                   	pop    %ebp
f01018e0:	c3                   	ret    
f01018e1:	66 90                	xchg   %ax,%ax
f01018e3:	66 90                	xchg   %ax,%ax
f01018e5:	66 90                	xchg   %ax,%ax
f01018e7:	66 90                	xchg   %ax,%ax
f01018e9:	66 90                	xchg   %ax,%ax
f01018eb:	66 90                	xchg   %ax,%ax
f01018ed:	66 90                	xchg   %ax,%ax
f01018ef:	90                   	nop

f01018f0 <__udivdi3>:
f01018f0:	55                   	push   %ebp
f01018f1:	57                   	push   %edi
f01018f2:	56                   	push   %esi
f01018f3:	53                   	push   %ebx
f01018f4:	83 ec 1c             	sub    $0x1c,%esp
f01018f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01018fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01018ff:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101903:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101907:	85 d2                	test   %edx,%edx
f0101909:	75 35                	jne    f0101940 <__udivdi3+0x50>
f010190b:	39 f3                	cmp    %esi,%ebx
f010190d:	0f 87 bd 00 00 00    	ja     f01019d0 <__udivdi3+0xe0>
f0101913:	85 db                	test   %ebx,%ebx
f0101915:	89 d9                	mov    %ebx,%ecx
f0101917:	75 0b                	jne    f0101924 <__udivdi3+0x34>
f0101919:	b8 01 00 00 00       	mov    $0x1,%eax
f010191e:	31 d2                	xor    %edx,%edx
f0101920:	f7 f3                	div    %ebx
f0101922:	89 c1                	mov    %eax,%ecx
f0101924:	31 d2                	xor    %edx,%edx
f0101926:	89 f0                	mov    %esi,%eax
f0101928:	f7 f1                	div    %ecx
f010192a:	89 c6                	mov    %eax,%esi
f010192c:	89 e8                	mov    %ebp,%eax
f010192e:	89 f7                	mov    %esi,%edi
f0101930:	f7 f1                	div    %ecx
f0101932:	89 fa                	mov    %edi,%edx
f0101934:	83 c4 1c             	add    $0x1c,%esp
f0101937:	5b                   	pop    %ebx
f0101938:	5e                   	pop    %esi
f0101939:	5f                   	pop    %edi
f010193a:	5d                   	pop    %ebp
f010193b:	c3                   	ret    
f010193c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101940:	39 f2                	cmp    %esi,%edx
f0101942:	77 7c                	ja     f01019c0 <__udivdi3+0xd0>
f0101944:	0f bd fa             	bsr    %edx,%edi
f0101947:	83 f7 1f             	xor    $0x1f,%edi
f010194a:	0f 84 98 00 00 00    	je     f01019e8 <__udivdi3+0xf8>
f0101950:	89 f9                	mov    %edi,%ecx
f0101952:	b8 20 00 00 00       	mov    $0x20,%eax
f0101957:	29 f8                	sub    %edi,%eax
f0101959:	d3 e2                	shl    %cl,%edx
f010195b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010195f:	89 c1                	mov    %eax,%ecx
f0101961:	89 da                	mov    %ebx,%edx
f0101963:	d3 ea                	shr    %cl,%edx
f0101965:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101969:	09 d1                	or     %edx,%ecx
f010196b:	89 f2                	mov    %esi,%edx
f010196d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101971:	89 f9                	mov    %edi,%ecx
f0101973:	d3 e3                	shl    %cl,%ebx
f0101975:	89 c1                	mov    %eax,%ecx
f0101977:	d3 ea                	shr    %cl,%edx
f0101979:	89 f9                	mov    %edi,%ecx
f010197b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010197f:	d3 e6                	shl    %cl,%esi
f0101981:	89 eb                	mov    %ebp,%ebx
f0101983:	89 c1                	mov    %eax,%ecx
f0101985:	d3 eb                	shr    %cl,%ebx
f0101987:	09 de                	or     %ebx,%esi
f0101989:	89 f0                	mov    %esi,%eax
f010198b:	f7 74 24 08          	divl   0x8(%esp)
f010198f:	89 d6                	mov    %edx,%esi
f0101991:	89 c3                	mov    %eax,%ebx
f0101993:	f7 64 24 0c          	mull   0xc(%esp)
f0101997:	39 d6                	cmp    %edx,%esi
f0101999:	72 0c                	jb     f01019a7 <__udivdi3+0xb7>
f010199b:	89 f9                	mov    %edi,%ecx
f010199d:	d3 e5                	shl    %cl,%ebp
f010199f:	39 c5                	cmp    %eax,%ebp
f01019a1:	73 5d                	jae    f0101a00 <__udivdi3+0x110>
f01019a3:	39 d6                	cmp    %edx,%esi
f01019a5:	75 59                	jne    f0101a00 <__udivdi3+0x110>
f01019a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019aa:	31 ff                	xor    %edi,%edi
f01019ac:	89 fa                	mov    %edi,%edx
f01019ae:	83 c4 1c             	add    $0x1c,%esp
f01019b1:	5b                   	pop    %ebx
f01019b2:	5e                   	pop    %esi
f01019b3:	5f                   	pop    %edi
f01019b4:	5d                   	pop    %ebp
f01019b5:	c3                   	ret    
f01019b6:	8d 76 00             	lea    0x0(%esi),%esi
f01019b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01019c0:	31 ff                	xor    %edi,%edi
f01019c2:	31 c0                	xor    %eax,%eax
f01019c4:	89 fa                	mov    %edi,%edx
f01019c6:	83 c4 1c             	add    $0x1c,%esp
f01019c9:	5b                   	pop    %ebx
f01019ca:	5e                   	pop    %esi
f01019cb:	5f                   	pop    %edi
f01019cc:	5d                   	pop    %ebp
f01019cd:	c3                   	ret    
f01019ce:	66 90                	xchg   %ax,%ax
f01019d0:	31 ff                	xor    %edi,%edi
f01019d2:	89 e8                	mov    %ebp,%eax
f01019d4:	89 f2                	mov    %esi,%edx
f01019d6:	f7 f3                	div    %ebx
f01019d8:	89 fa                	mov    %edi,%edx
f01019da:	83 c4 1c             	add    $0x1c,%esp
f01019dd:	5b                   	pop    %ebx
f01019de:	5e                   	pop    %esi
f01019df:	5f                   	pop    %edi
f01019e0:	5d                   	pop    %ebp
f01019e1:	c3                   	ret    
f01019e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01019e8:	39 f2                	cmp    %esi,%edx
f01019ea:	72 06                	jb     f01019f2 <__udivdi3+0x102>
f01019ec:	31 c0                	xor    %eax,%eax
f01019ee:	39 eb                	cmp    %ebp,%ebx
f01019f0:	77 d2                	ja     f01019c4 <__udivdi3+0xd4>
f01019f2:	b8 01 00 00 00       	mov    $0x1,%eax
f01019f7:	eb cb                	jmp    f01019c4 <__udivdi3+0xd4>
f01019f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a00:	89 d8                	mov    %ebx,%eax
f0101a02:	31 ff                	xor    %edi,%edi
f0101a04:	eb be                	jmp    f01019c4 <__udivdi3+0xd4>
f0101a06:	66 90                	xchg   %ax,%ax
f0101a08:	66 90                	xchg   %ax,%ax
f0101a0a:	66 90                	xchg   %ax,%ax
f0101a0c:	66 90                	xchg   %ax,%ax
f0101a0e:	66 90                	xchg   %ax,%ax

f0101a10 <__umoddi3>:
f0101a10:	55                   	push   %ebp
f0101a11:	57                   	push   %edi
f0101a12:	56                   	push   %esi
f0101a13:	53                   	push   %ebx
f0101a14:	83 ec 1c             	sub    $0x1c,%esp
f0101a17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a1b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a23:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a27:	85 ed                	test   %ebp,%ebp
f0101a29:	89 f0                	mov    %esi,%eax
f0101a2b:	89 da                	mov    %ebx,%edx
f0101a2d:	75 19                	jne    f0101a48 <__umoddi3+0x38>
f0101a2f:	39 df                	cmp    %ebx,%edi
f0101a31:	0f 86 b1 00 00 00    	jbe    f0101ae8 <__umoddi3+0xd8>
f0101a37:	f7 f7                	div    %edi
f0101a39:	89 d0                	mov    %edx,%eax
f0101a3b:	31 d2                	xor    %edx,%edx
f0101a3d:	83 c4 1c             	add    $0x1c,%esp
f0101a40:	5b                   	pop    %ebx
f0101a41:	5e                   	pop    %esi
f0101a42:	5f                   	pop    %edi
f0101a43:	5d                   	pop    %ebp
f0101a44:	c3                   	ret    
f0101a45:	8d 76 00             	lea    0x0(%esi),%esi
f0101a48:	39 dd                	cmp    %ebx,%ebp
f0101a4a:	77 f1                	ja     f0101a3d <__umoddi3+0x2d>
f0101a4c:	0f bd cd             	bsr    %ebp,%ecx
f0101a4f:	83 f1 1f             	xor    $0x1f,%ecx
f0101a52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101a56:	0f 84 b4 00 00 00    	je     f0101b10 <__umoddi3+0x100>
f0101a5c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a61:	89 c2                	mov    %eax,%edx
f0101a63:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a67:	29 c2                	sub    %eax,%edx
f0101a69:	89 c1                	mov    %eax,%ecx
f0101a6b:	89 f8                	mov    %edi,%eax
f0101a6d:	d3 e5                	shl    %cl,%ebp
f0101a6f:	89 d1                	mov    %edx,%ecx
f0101a71:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101a75:	d3 e8                	shr    %cl,%eax
f0101a77:	09 c5                	or     %eax,%ebp
f0101a79:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101a7d:	89 c1                	mov    %eax,%ecx
f0101a7f:	d3 e7                	shl    %cl,%edi
f0101a81:	89 d1                	mov    %edx,%ecx
f0101a83:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101a87:	89 df                	mov    %ebx,%edi
f0101a89:	d3 ef                	shr    %cl,%edi
f0101a8b:	89 c1                	mov    %eax,%ecx
f0101a8d:	89 f0                	mov    %esi,%eax
f0101a8f:	d3 e3                	shl    %cl,%ebx
f0101a91:	89 d1                	mov    %edx,%ecx
f0101a93:	89 fa                	mov    %edi,%edx
f0101a95:	d3 e8                	shr    %cl,%eax
f0101a97:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101a9c:	09 d8                	or     %ebx,%eax
f0101a9e:	f7 f5                	div    %ebp
f0101aa0:	d3 e6                	shl    %cl,%esi
f0101aa2:	89 d1                	mov    %edx,%ecx
f0101aa4:	f7 64 24 08          	mull   0x8(%esp)
f0101aa8:	39 d1                	cmp    %edx,%ecx
f0101aaa:	89 c3                	mov    %eax,%ebx
f0101aac:	89 d7                	mov    %edx,%edi
f0101aae:	72 06                	jb     f0101ab6 <__umoddi3+0xa6>
f0101ab0:	75 0e                	jne    f0101ac0 <__umoddi3+0xb0>
f0101ab2:	39 c6                	cmp    %eax,%esi
f0101ab4:	73 0a                	jae    f0101ac0 <__umoddi3+0xb0>
f0101ab6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101aba:	19 ea                	sbb    %ebp,%edx
f0101abc:	89 d7                	mov    %edx,%edi
f0101abe:	89 c3                	mov    %eax,%ebx
f0101ac0:	89 ca                	mov    %ecx,%edx
f0101ac2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101ac7:	29 de                	sub    %ebx,%esi
f0101ac9:	19 fa                	sbb    %edi,%edx
f0101acb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101acf:	89 d0                	mov    %edx,%eax
f0101ad1:	d3 e0                	shl    %cl,%eax
f0101ad3:	89 d9                	mov    %ebx,%ecx
f0101ad5:	d3 ee                	shr    %cl,%esi
f0101ad7:	d3 ea                	shr    %cl,%edx
f0101ad9:	09 f0                	or     %esi,%eax
f0101adb:	83 c4 1c             	add    $0x1c,%esp
f0101ade:	5b                   	pop    %ebx
f0101adf:	5e                   	pop    %esi
f0101ae0:	5f                   	pop    %edi
f0101ae1:	5d                   	pop    %ebp
f0101ae2:	c3                   	ret    
f0101ae3:	90                   	nop
f0101ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ae8:	85 ff                	test   %edi,%edi
f0101aea:	89 f9                	mov    %edi,%ecx
f0101aec:	75 0b                	jne    f0101af9 <__umoddi3+0xe9>
f0101aee:	b8 01 00 00 00       	mov    $0x1,%eax
f0101af3:	31 d2                	xor    %edx,%edx
f0101af5:	f7 f7                	div    %edi
f0101af7:	89 c1                	mov    %eax,%ecx
f0101af9:	89 d8                	mov    %ebx,%eax
f0101afb:	31 d2                	xor    %edx,%edx
f0101afd:	f7 f1                	div    %ecx
f0101aff:	89 f0                	mov    %esi,%eax
f0101b01:	f7 f1                	div    %ecx
f0101b03:	e9 31 ff ff ff       	jmp    f0101a39 <__umoddi3+0x29>
f0101b08:	90                   	nop
f0101b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b10:	39 dd                	cmp    %ebx,%ebp
f0101b12:	72 08                	jb     f0101b1c <__umoddi3+0x10c>
f0101b14:	39 f7                	cmp    %esi,%edi
f0101b16:	0f 87 21 ff ff ff    	ja     f0101a3d <__umoddi3+0x2d>
f0101b1c:	89 da                	mov    %ebx,%edx
f0101b1e:	89 f0                	mov    %esi,%eax
f0101b20:	29 f8                	sub    %edi,%eax
f0101b22:	19 ea                	sbb    %ebp,%edx
f0101b24:	e9 14 ff ff ff       	jmp    f0101a3d <__umoddi3+0x2d>
