
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	14250513          	addi	a0,a0,322 # ffffffffc02a1178 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	6ca60613          	addi	a2,a2,1738 # ffffffffc02ac708 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	767050ef          	jal	ra,ffffffffc0205fb4 <memset>
    cons_init();                // init the console
ffffffffc0200052:	56a000ef          	jal	ra,ffffffffc02005bc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	39a58593          	addi	a1,a1,922 # ffffffffc02063f0 <etext+0x2>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	3b250513          	addi	a0,a0,946 # ffffffffc0206410 <etext+0x22>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	25a000ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	754010ef          	jal	ra,ffffffffc02017c2 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5be000ef          	jal	ra,ffffffffc0200630 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5c8000ef          	jal	ra,ffffffffc020063e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	215020ef          	jal	ra,ffffffffc0202a8e <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	341050ef          	jal	ra,ffffffffc0205bbe <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4b0000ef          	jal	ra,ffffffffc0200532 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	536030ef          	jal	ra,ffffffffc02035bc <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4dc000ef          	jal	ra,ffffffffc0200566 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5a4000ef          	jal	ra,ffffffffc0200632 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	479050ef          	jal	ra,ffffffffc0205d0a <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	520000ef          	jal	ra,ffffffffc02005be <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	787050ef          	jal	ra,ffffffffc020604a <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	753050ef          	jal	ra,ffffffffc020604a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	4ba0006f          	j	ffffffffc02005be <cons_putc>

ffffffffc0200108 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200108:	1101                	addi	sp,sp,-32
ffffffffc020010a:	e822                	sd	s0,16(sp)
ffffffffc020010c:	ec06                	sd	ra,24(sp)
ffffffffc020010e:	e426                	sd	s1,8(sp)
ffffffffc0200110:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	00054503          	lbu	a0,0(a0)
ffffffffc0200116:	c51d                	beqz	a0,ffffffffc0200144 <cputs+0x3c>
ffffffffc0200118:	0405                	addi	s0,s0,1
ffffffffc020011a:	4485                	li	s1,1
ffffffffc020011c:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011e:	4a0000ef          	jal	ra,ffffffffc02005be <cons_putc>
    (*cnt) ++;
ffffffffc0200122:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012c:	f96d                	bnez	a0,ffffffffc020011e <cputs+0x16>
ffffffffc020012e:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200132:	4529                	li	a0,10
ffffffffc0200134:	48a000ef          	jal	ra,ffffffffc02005be <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200138:	8522                	mv	a0,s0
ffffffffc020013a:	60e2                	ld	ra,24(sp)
ffffffffc020013c:	6442                	ld	s0,16(sp)
ffffffffc020013e:	64a2                	ld	s1,8(sp)
ffffffffc0200140:	6105                	addi	sp,sp,32
ffffffffc0200142:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200144:	4405                	li	s0,1
ffffffffc0200146:	b7f5                	j	ffffffffc0200132 <cputs+0x2a>

ffffffffc0200148 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200148:	1141                	addi	sp,sp,-16
ffffffffc020014a:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014c:	4a8000ef          	jal	ra,ffffffffc02005f4 <cons_getc>
ffffffffc0200150:	dd75                	beqz	a0,ffffffffc020014c <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200152:	60a2                	ld	ra,8(sp)
ffffffffc0200154:	0141                	addi	sp,sp,16
ffffffffc0200156:	8082                	ret

ffffffffc0200158 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200158:	715d                	addi	sp,sp,-80
ffffffffc020015a:	e486                	sd	ra,72(sp)
ffffffffc020015c:	e0a2                	sd	s0,64(sp)
ffffffffc020015e:	fc26                	sd	s1,56(sp)
ffffffffc0200160:	f84a                	sd	s2,48(sp)
ffffffffc0200162:	f44e                	sd	s3,40(sp)
ffffffffc0200164:	f052                	sd	s4,32(sp)
ffffffffc0200166:	ec56                	sd	s5,24(sp)
ffffffffc0200168:	e85a                	sd	s6,16(sp)
ffffffffc020016a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016c:	c901                	beqz	a0,ffffffffc020017c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00006517          	auipc	a0,0x6
ffffffffc0200174:	2a850513          	addi	a0,a0,680 # ffffffffc0206418 <etext+0x2a>
ffffffffc0200178:	f59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200182:	4aa9                	li	s5,10
ffffffffc0200184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200186:	000a1b97          	auipc	s7,0xa1
ffffffffc020018a:	ff2b8b93          	addi	s7,s7,-14 # ffffffffc02a1178 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200192:	fb7ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc0200196:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200198:	00054b63          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019c:	00a95b63          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001a0:	029a5463          	ble	s1,s4,ffffffffc02001c8 <readline+0x70>
        c = getchar();
ffffffffc02001a4:	fa5ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001a8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001aa:	fe0559e3          	bgez	a0,ffffffffc020019c <readline+0x44>
            return NULL;
ffffffffc02001ae:	4501                	li	a0,0
ffffffffc02001b0:	a099                	j	ffffffffc02001f6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b2:	03341463          	bne	s0,s3,ffffffffc02001da <readline+0x82>
ffffffffc02001b6:	e8b9                	bnez	s1,ffffffffc020020c <readline+0xb4>
        c = getchar();
ffffffffc02001b8:	f91ff0ef          	jal	ra,ffffffffc0200148 <getchar>
ffffffffc02001bc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001be:	fe0548e3          	bltz	a0,ffffffffc02001ae <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c2:	fea958e3          	ble	a0,s2,ffffffffc02001b2 <readline+0x5a>
ffffffffc02001c6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c8:	8522                	mv	a0,s0
ffffffffc02001ca:	f3bff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001ce:	009b87b3          	add	a5,s7,s1
ffffffffc02001d2:	00878023          	sb	s0,0(a5)
ffffffffc02001d6:	2485                	addiw	s1,s1,1
ffffffffc02001d8:	bf6d                	j	ffffffffc0200192 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	01540463          	beq	s0,s5,ffffffffc02001e2 <readline+0x8a>
ffffffffc02001de:	fb641ae3          	bne	s0,s6,ffffffffc0200192 <readline+0x3a>
            cputchar(c);
ffffffffc02001e2:	8522                	mv	a0,s0
ffffffffc02001e4:	f21ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e8:	000a1517          	auipc	a0,0xa1
ffffffffc02001ec:	f9050513          	addi	a0,a0,-112 # ffffffffc02a1178 <edata>
ffffffffc02001f0:	94aa                	add	s1,s1,a0
ffffffffc02001f2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f6:	60a6                	ld	ra,72(sp)
ffffffffc02001f8:	6406                	ld	s0,64(sp)
ffffffffc02001fa:	74e2                	ld	s1,56(sp)
ffffffffc02001fc:	7942                	ld	s2,48(sp)
ffffffffc02001fe:	79a2                	ld	s3,40(sp)
ffffffffc0200200:	7a02                	ld	s4,32(sp)
ffffffffc0200202:	6ae2                	ld	s5,24(sp)
ffffffffc0200204:	6b42                	ld	s6,16(sp)
ffffffffc0200206:	6ba2                	ld	s7,8(sp)
ffffffffc0200208:	6161                	addi	sp,sp,80
ffffffffc020020a:	8082                	ret
            cputchar(c);
ffffffffc020020c:	4521                	li	a0,8
ffffffffc020020e:	ef7ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200212:	34fd                	addiw	s1,s1,-1
ffffffffc0200214:	bfbd                	j	ffffffffc0200192 <readline+0x3a>

ffffffffc0200216 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200216:	000ac317          	auipc	t1,0xac
ffffffffc020021a:	36230313          	addi	t1,t1,866 # ffffffffc02ac578 <is_panic>
ffffffffc020021e:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200222:	715d                	addi	sp,sp,-80
ffffffffc0200224:	ec06                	sd	ra,24(sp)
ffffffffc0200226:	e822                	sd	s0,16(sp)
ffffffffc0200228:	f436                	sd	a3,40(sp)
ffffffffc020022a:	f83a                	sd	a4,48(sp)
ffffffffc020022c:	fc3e                	sd	a5,56(sp)
ffffffffc020022e:	e0c2                	sd	a6,64(sp)
ffffffffc0200230:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200232:	02031c63          	bnez	t1,ffffffffc020026a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200236:	4785                	li	a5,1
ffffffffc0200238:	8432                	mv	s0,a2
ffffffffc020023a:	000ac717          	auipc	a4,0xac
ffffffffc020023e:	32f73f23          	sd	a5,830(a4) # ffffffffc02ac578 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200242:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200246:	85aa                	mv	a1,a0
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	1d850513          	addi	a0,a0,472 # ffffffffc0206420 <etext+0x32>
    va_start(ap, fmt);
ffffffffc0200250:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200252:	e7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200256:	65a2                	ld	a1,8(sp)
ffffffffc0200258:	8522                	mv	a0,s0
ffffffffc020025a:	e57ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025e:	00007517          	auipc	a0,0x7
ffffffffc0200262:	f9a50513          	addi	a0,a0,-102 # ffffffffc02071f8 <commands+0xc98>
ffffffffc0200266:	e6bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	4581                	li	a1,0
ffffffffc020026e:	4601                	li	a2,0
ffffffffc0200270:	48a1                	li	a7,8
ffffffffc0200272:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200276:	3c2000ef          	jal	ra,ffffffffc0200638 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	174000ef          	jal	ra,ffffffffc02003f0 <kmonitor>
ffffffffc0200280:	bfed                	j	ffffffffc020027a <__panic+0x64>

ffffffffc0200282 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200282:	715d                	addi	sp,sp,-80
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	fc3e                	sd	a5,56(sp)
ffffffffc0200288:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc020028a:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	862e                	mv	a2,a1
ffffffffc020028e:	85aa                	mv	a1,a0
ffffffffc0200290:	00006517          	auipc	a0,0x6
ffffffffc0200294:	1b050513          	addi	a0,a0,432 # ffffffffc0206440 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200298:	ec06                	sd	ra,24(sp)
ffffffffc020029a:	f436                	sd	a3,40(sp)
ffffffffc020029c:	f83a                	sd	a4,48(sp)
ffffffffc020029e:	e0c2                	sd	a6,64(sp)
ffffffffc02002a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a2:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a4:	e2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a8:	65a2                	ld	a1,8(sp)
ffffffffc02002aa:	8522                	mv	a0,s0
ffffffffc02002ac:	e05ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002b0:	00007517          	auipc	a0,0x7
ffffffffc02002b4:	f4850513          	addi	a0,a0,-184 # ffffffffc02071f8 <commands+0xc98>
ffffffffc02002b8:	e19ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002bc:	60e2                	ld	ra,24(sp)
ffffffffc02002be:	6442                	ld	s0,16(sp)
ffffffffc02002c0:	6161                	addi	sp,sp,80
ffffffffc02002c2:	8082                	ret

ffffffffc02002c4 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	1ca50513          	addi	a0,a0,458 # ffffffffc0206490 <etext+0xa2>
void print_kerninfo(void) {
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	e01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d4:	00000597          	auipc	a1,0x0
ffffffffc02002d8:	d6258593          	addi	a1,a1,-670 # ffffffffc0200036 <kern_init>
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	1d450513          	addi	a0,a0,468 # ffffffffc02064b0 <etext+0xc2>
ffffffffc02002e4:	dedff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e8:	00006597          	auipc	a1,0x6
ffffffffc02002ec:	10658593          	addi	a1,a1,262 # ffffffffc02063ee <etext>
ffffffffc02002f0:	00006517          	auipc	a0,0x6
ffffffffc02002f4:	1e050513          	addi	a0,a0,480 # ffffffffc02064d0 <etext+0xe2>
ffffffffc02002f8:	dd9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fc:	000a1597          	auipc	a1,0xa1
ffffffffc0200300:	e7c58593          	addi	a1,a1,-388 # ffffffffc02a1178 <edata>
ffffffffc0200304:	00006517          	auipc	a0,0x6
ffffffffc0200308:	1ec50513          	addi	a0,a0,492 # ffffffffc02064f0 <etext+0x102>
ffffffffc020030c:	dc5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200310:	000ac597          	auipc	a1,0xac
ffffffffc0200314:	3f858593          	addi	a1,a1,1016 # ffffffffc02ac708 <end>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	1f850513          	addi	a0,a0,504 # ffffffffc0206510 <etext+0x122>
ffffffffc0200320:	db1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200324:	000ac597          	auipc	a1,0xac
ffffffffc0200328:	7e358593          	addi	a1,a1,2019 # ffffffffc02acb07 <end+0x3ff>
ffffffffc020032c:	00000797          	auipc	a5,0x0
ffffffffc0200330:	d0a78793          	addi	a5,a5,-758 # ffffffffc0200036 <kern_init>
ffffffffc0200334:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200338:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200342:	95be                	add	a1,a1,a5
ffffffffc0200344:	85a9                	srai	a1,a1,0xa
ffffffffc0200346:	00006517          	auipc	a0,0x6
ffffffffc020034a:	1ea50513          	addi	a0,a0,490 # ffffffffc0206530 <etext+0x142>
}
ffffffffc020034e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200350:	d81ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200354 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200356:	00006617          	auipc	a2,0x6
ffffffffc020035a:	10a60613          	addi	a2,a2,266 # ffffffffc0206460 <etext+0x72>
ffffffffc020035e:	04d00593          	li	a1,77
ffffffffc0200362:	00006517          	auipc	a0,0x6
ffffffffc0200366:	11650513          	addi	a0,a0,278 # ffffffffc0206478 <etext+0x8a>
void print_stackframe(void) {
ffffffffc020036a:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020036c:	eabff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200370 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200370:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200372:	00006617          	auipc	a2,0x6
ffffffffc0200376:	2ce60613          	addi	a2,a2,718 # ffffffffc0206640 <commands+0xe0>
ffffffffc020037a:	00006597          	auipc	a1,0x6
ffffffffc020037e:	2e658593          	addi	a1,a1,742 # ffffffffc0206660 <commands+0x100>
ffffffffc0200382:	00006517          	auipc	a0,0x6
ffffffffc0200386:	2e650513          	addi	a0,a0,742 # ffffffffc0206668 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020038a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020038c:	d45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200390:	00006617          	auipc	a2,0x6
ffffffffc0200394:	2e860613          	addi	a2,a2,744 # ffffffffc0206678 <commands+0x118>
ffffffffc0200398:	00006597          	auipc	a1,0x6
ffffffffc020039c:	30858593          	addi	a1,a1,776 # ffffffffc02066a0 <commands+0x140>
ffffffffc02003a0:	00006517          	auipc	a0,0x6
ffffffffc02003a4:	2c850513          	addi	a0,a0,712 # ffffffffc0206668 <commands+0x108>
ffffffffc02003a8:	d29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003ac:	00006617          	auipc	a2,0x6
ffffffffc02003b0:	30460613          	addi	a2,a2,772 # ffffffffc02066b0 <commands+0x150>
ffffffffc02003b4:	00006597          	auipc	a1,0x6
ffffffffc02003b8:	31c58593          	addi	a1,a1,796 # ffffffffc02066d0 <commands+0x170>
ffffffffc02003bc:	00006517          	auipc	a0,0x6
ffffffffc02003c0:	2ac50513          	addi	a0,a0,684 # ffffffffc0206668 <commands+0x108>
ffffffffc02003c4:	d0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c8:	60a2                	ld	ra,8(sp)
ffffffffc02003ca:	4501                	li	a0,0
ffffffffc02003cc:	0141                	addi	sp,sp,16
ffffffffc02003ce:	8082                	ret

ffffffffc02003d0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d0:	1141                	addi	sp,sp,-16
ffffffffc02003d2:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d4:	ef1ff0ef          	jal	ra,ffffffffc02002c4 <print_kerninfo>
    return 0;
}
ffffffffc02003d8:	60a2                	ld	ra,8(sp)
ffffffffc02003da:	4501                	li	a0,0
ffffffffc02003dc:	0141                	addi	sp,sp,16
ffffffffc02003de:	8082                	ret

ffffffffc02003e0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e0:	1141                	addi	sp,sp,-16
ffffffffc02003e2:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e4:	f71ff0ef          	jal	ra,ffffffffc0200354 <print_stackframe>
    return 0;
}
ffffffffc02003e8:	60a2                	ld	ra,8(sp)
ffffffffc02003ea:	4501                	li	a0,0
ffffffffc02003ec:	0141                	addi	sp,sp,16
ffffffffc02003ee:	8082                	ret

ffffffffc02003f0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f0:	7115                	addi	sp,sp,-224
ffffffffc02003f2:	e962                	sd	s8,144(sp)
ffffffffc02003f4:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	00006517          	auipc	a0,0x6
ffffffffc02003fa:	1b250513          	addi	a0,a0,434 # ffffffffc02065a8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fe:	ed86                	sd	ra,216(sp)
ffffffffc0200400:	e9a2                	sd	s0,208(sp)
ffffffffc0200402:	e5a6                	sd	s1,200(sp)
ffffffffc0200404:	e1ca                	sd	s2,192(sp)
ffffffffc0200406:	fd4e                	sd	s3,184(sp)
ffffffffc0200408:	f952                	sd	s4,176(sp)
ffffffffc020040a:	f556                	sd	s5,168(sp)
ffffffffc020040c:	f15a                	sd	s6,160(sp)
ffffffffc020040e:	ed5e                	sd	s7,152(sp)
ffffffffc0200410:	e566                	sd	s9,136(sp)
ffffffffc0200412:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200414:	cbdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200418:	00006517          	auipc	a0,0x6
ffffffffc020041c:	1b850513          	addi	a0,a0,440 # ffffffffc02065d0 <commands+0x70>
ffffffffc0200420:	cb1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200424:	000c0563          	beqz	s8,ffffffffc020042e <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200428:	8562                	mv	a0,s8
ffffffffc020042a:	3fc000ef          	jal	ra,ffffffffc0200826 <print_trapframe>
ffffffffc020042e:	00006c97          	auipc	s9,0x6
ffffffffc0200432:	132c8c93          	addi	s9,s9,306 # ffffffffc0206560 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200436:	00006997          	auipc	s3,0x6
ffffffffc020043a:	1c298993          	addi	s3,s3,450 # ffffffffc02065f8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	1c290913          	addi	s2,s2,450 # ffffffffc0206600 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200446:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200448:	00006b17          	auipc	s6,0x6
ffffffffc020044c:	1c0b0b13          	addi	s6,s6,448 # ffffffffc0206608 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200450:	00006a97          	auipc	s5,0x6
ffffffffc0200454:	210a8a93          	addi	s5,s5,528 # ffffffffc0206660 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200458:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020045a:	854e                	mv	a0,s3
ffffffffc020045c:	cfdff0ef          	jal	ra,ffffffffc0200158 <readline>
ffffffffc0200460:	842a                	mv	s0,a0
ffffffffc0200462:	dd65                	beqz	a0,ffffffffc020045a <kmonitor+0x6a>
ffffffffc0200464:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200468:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046a:	c999                	beqz	a1,ffffffffc0200480 <kmonitor+0x90>
ffffffffc020046c:	854a                	mv	a0,s2
ffffffffc020046e:	329050ef          	jal	ra,ffffffffc0205f96 <strchr>
ffffffffc0200472:	c925                	beqz	a0,ffffffffc02004e2 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	f5fd                	bnez	a1,ffffffffc020046c <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200480:	dce9                	beqz	s1,ffffffffc020045a <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200482:	6582                	ld	a1,0(sp)
ffffffffc0200484:	00006d17          	auipc	s10,0x6
ffffffffc0200488:	0dcd0d13          	addi	s10,s10,220 # ffffffffc0206560 <commands>
    if (argc == 0) {
ffffffffc020048c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200490:	0d61                	addi	s10,s10,24
ffffffffc0200492:	2db050ef          	jal	ra,ffffffffc0205f6c <strcmp>
ffffffffc0200496:	c919                	beqz	a0,ffffffffc02004ac <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200498:	2405                	addiw	s0,s0,1
ffffffffc020049a:	09740463          	beq	s0,s7,ffffffffc0200522 <kmonitor+0x132>
ffffffffc020049e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02004a2:	6582                	ld	a1,0(sp)
ffffffffc02004a4:	0d61                	addi	s10,s10,24
ffffffffc02004a6:	2c7050ef          	jal	ra,ffffffffc0205f6c <strcmp>
ffffffffc02004aa:	f57d                	bnez	a0,ffffffffc0200498 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ac:	00141793          	slli	a5,s0,0x1
ffffffffc02004b0:	97a2                	add	a5,a5,s0
ffffffffc02004b2:	078e                	slli	a5,a5,0x3
ffffffffc02004b4:	97e6                	add	a5,a5,s9
ffffffffc02004b6:	6b9c                	ld	a5,16(a5)
ffffffffc02004b8:	8662                	mv	a2,s8
ffffffffc02004ba:	002c                	addi	a1,sp,8
ffffffffc02004bc:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004c0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004c2:	f8055ce3          	bgez	a0,ffffffffc020045a <kmonitor+0x6a>
}
ffffffffc02004c6:	60ee                	ld	ra,216(sp)
ffffffffc02004c8:	644e                	ld	s0,208(sp)
ffffffffc02004ca:	64ae                	ld	s1,200(sp)
ffffffffc02004cc:	690e                	ld	s2,192(sp)
ffffffffc02004ce:	79ea                	ld	s3,184(sp)
ffffffffc02004d0:	7a4a                	ld	s4,176(sp)
ffffffffc02004d2:	7aaa                	ld	s5,168(sp)
ffffffffc02004d4:	7b0a                	ld	s6,160(sp)
ffffffffc02004d6:	6bea                	ld	s7,152(sp)
ffffffffc02004d8:	6c4a                	ld	s8,144(sp)
ffffffffc02004da:	6caa                	ld	s9,136(sp)
ffffffffc02004dc:	6d0a                	ld	s10,128(sp)
ffffffffc02004de:	612d                	addi	sp,sp,224
ffffffffc02004e0:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004e2:	00044783          	lbu	a5,0(s0)
ffffffffc02004e6:	dfc9                	beqz	a5,ffffffffc0200480 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e8:	03448863          	beq	s1,s4,ffffffffc0200518 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004ec:	00349793          	slli	a5,s1,0x3
ffffffffc02004f0:	0118                	addi	a4,sp,128
ffffffffc02004f2:	97ba                	add	a5,a5,a4
ffffffffc02004f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004fc:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fe:	e591                	bnez	a1,ffffffffc020050a <kmonitor+0x11a>
ffffffffc0200500:	b749                	j	ffffffffc0200482 <kmonitor+0x92>
            buf ++;
ffffffffc0200502:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
ffffffffc0200508:	ddad                	beqz	a1,ffffffffc0200482 <kmonitor+0x92>
ffffffffc020050a:	854a                	mv	a0,s2
ffffffffc020050c:	28b050ef          	jal	ra,ffffffffc0205f96 <strchr>
ffffffffc0200510:	d96d                	beqz	a0,ffffffffc0200502 <kmonitor+0x112>
ffffffffc0200512:	00044583          	lbu	a1,0(s0)
ffffffffc0200516:	bf91                	j	ffffffffc020046a <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200518:	45c1                	li	a1,16
ffffffffc020051a:	855a                	mv	a0,s6
ffffffffc020051c:	bb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0200520:	b7f1                	j	ffffffffc02004ec <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200522:	6582                	ld	a1,0(sp)
ffffffffc0200524:	00006517          	auipc	a0,0x6
ffffffffc0200528:	10450513          	addi	a0,a0,260 # ffffffffc0206628 <commands+0xc8>
ffffffffc020052c:	ba5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc0200530:	b72d                	j	ffffffffc020045a <kmonitor+0x6a>

ffffffffc0200532 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200534:	00253513          	sltiu	a0,a0,2
ffffffffc0200538:	8082                	ret

ffffffffc020053a <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020053a:	03800513          	li	a0,56
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200540:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200542:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200546:	000a1517          	auipc	a0,0xa1
ffffffffc020054a:	03250513          	addi	a0,a0,50 # ffffffffc02a1578 <ide>
                   size_t nsecs) {
ffffffffc020054e:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200550:	00969613          	slli	a2,a3,0x9
ffffffffc0200554:	85ba                	mv	a1,a4
ffffffffc0200556:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200558:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020055a:	26d050ef          	jal	ra,ffffffffc0205fc6 <memcpy>
    return 0;
}
ffffffffc020055e:	60a2                	ld	ra,8(sp)
ffffffffc0200560:	4501                	li	a0,0
ffffffffc0200562:	0141                	addi	sp,sp,16
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200566:	67e1                	lui	a5,0x18
ffffffffc0200568:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc10>
ffffffffc020056c:	000ac717          	auipc	a4,0xac
ffffffffc0200570:	00f73a23          	sd	a5,20(a4) # ffffffffc02ac580 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200574:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200578:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020057a:	953e                	add	a0,a0,a5
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	4881                	li	a7,0
ffffffffc0200580:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200584:	02000793          	li	a5,32
ffffffffc0200588:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020058c:	00006517          	auipc	a0,0x6
ffffffffc0200590:	15450513          	addi	a0,a0,340 # ffffffffc02066e0 <commands+0x180>
    ticks = 0;
ffffffffc0200594:	000ac797          	auipc	a5,0xac
ffffffffc0200598:	0407b223          	sd	zero,68(a5) # ffffffffc02ac5d8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020059c:	b35ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02005a0 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005a0:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005a4:	000ac797          	auipc	a5,0xac
ffffffffc02005a8:	fdc78793          	addi	a5,a5,-36 # ffffffffc02ac580 <timebase>
ffffffffc02005ac:	639c                	ld	a5,0(a5)
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	953e                	add	a0,a0,a5
ffffffffc02005b4:	4881                	li	a7,0
ffffffffc02005b6:	00000073          	ecall
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005bc:	8082                	ret

ffffffffc02005be <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005be:	100027f3          	csrr	a5,sstatus
ffffffffc02005c2:	8b89                	andi	a5,a5,2
ffffffffc02005c4:	0ff57513          	andi	a0,a0,255
ffffffffc02005c8:	e799                	bnez	a5,ffffffffc02005d6 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4885                	li	a7,1
ffffffffc02005d0:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005d4:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005d6:	1101                	addi	sp,sp,-32
ffffffffc02005d8:	ec06                	sd	ra,24(sp)
ffffffffc02005da:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005dc:	05c000ef          	jal	ra,ffffffffc0200638 <intr_disable>
ffffffffc02005e0:	6522                	ld	a0,8(sp)
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	4601                	li	a2,0
ffffffffc02005e6:	4885                	li	a7,1
ffffffffc02005e8:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005ec:	60e2                	ld	ra,24(sp)
ffffffffc02005ee:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005f0:	0420006f          	j	ffffffffc0200632 <intr_enable>

ffffffffc02005f4 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005f4:	100027f3          	csrr	a5,sstatus
ffffffffc02005f8:	8b89                	andi	a5,a5,2
ffffffffc02005fa:	eb89                	bnez	a5,ffffffffc020060c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005fc:	4501                	li	a0,0
ffffffffc02005fe:	4581                	li	a1,0
ffffffffc0200600:	4601                	li	a2,0
ffffffffc0200602:	4889                	li	a7,2
ffffffffc0200604:	00000073          	ecall
ffffffffc0200608:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020060a:	8082                	ret
int cons_getc(void) {
ffffffffc020060c:	1101                	addi	sp,sp,-32
ffffffffc020060e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200610:	028000ef          	jal	ra,ffffffffc0200638 <intr_disable>
ffffffffc0200614:	4501                	li	a0,0
ffffffffc0200616:	4581                	li	a1,0
ffffffffc0200618:	4601                	li	a2,0
ffffffffc020061a:	4889                	li	a7,2
ffffffffc020061c:	00000073          	ecall
ffffffffc0200620:	2501                	sext.w	a0,a0
ffffffffc0200622:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200624:	00e000ef          	jal	ra,ffffffffc0200632 <intr_enable>
}
ffffffffc0200628:	60e2                	ld	ra,24(sp)
ffffffffc020062a:	6522                	ld	a0,8(sp)
ffffffffc020062c:	6105                	addi	sp,sp,32
ffffffffc020062e:	8082                	ret

ffffffffc0200630 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200630:	8082                	ret

ffffffffc0200632 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200632:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200636:	8082                	ret

ffffffffc0200638 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200638:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020063c:	8082                	ret

ffffffffc020063e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020063e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200642:	00000797          	auipc	a5,0x0
ffffffffc0200646:	67a78793          	addi	a5,a5,1658 # ffffffffc0200cbc <__alltraps>
ffffffffc020064a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020064e:	000407b7          	lui	a5,0x40
ffffffffc0200652:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200658:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020065a:	1141                	addi	sp,sp,-16
ffffffffc020065c:	e022                	sd	s0,0(sp)
ffffffffc020065e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200660:	00006517          	auipc	a0,0x6
ffffffffc0200664:	3c850513          	addi	a0,a0,968 # ffffffffc0206a28 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200668:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066a:	a67ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066e:	640c                	ld	a1,8(s0)
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	3d050513          	addi	a0,a0,976 # ffffffffc0206a40 <commands+0x4e0>
ffffffffc0200678:	a59ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020067c:	680c                	ld	a1,16(s0)
ffffffffc020067e:	00006517          	auipc	a0,0x6
ffffffffc0200682:	3da50513          	addi	a0,a0,986 # ffffffffc0206a58 <commands+0x4f8>
ffffffffc0200686:	a4bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020068a:	6c0c                	ld	a1,24(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	3e450513          	addi	a0,a0,996 # ffffffffc0206a70 <commands+0x510>
ffffffffc0200694:	a3dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200698:	700c                	ld	a1,32(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0206a88 <commands+0x528>
ffffffffc02006a2:	a2fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a6:	740c                	ld	a1,40(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	3f850513          	addi	a0,a0,1016 # ffffffffc0206aa0 <commands+0x540>
ffffffffc02006b0:	a21ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b4:	780c                	ld	a1,48(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	40250513          	addi	a0,a0,1026 # ffffffffc0206ab8 <commands+0x558>
ffffffffc02006be:	a13ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006c2:	7c0c                	ld	a1,56(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	40c50513          	addi	a0,a0,1036 # ffffffffc0206ad0 <commands+0x570>
ffffffffc02006cc:	a05ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006d0:	602c                	ld	a1,64(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	41650513          	addi	a0,a0,1046 # ffffffffc0206ae8 <commands+0x588>
ffffffffc02006da:	9f7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006de:	642c                	ld	a1,72(s0)
ffffffffc02006e0:	00006517          	auipc	a0,0x6
ffffffffc02006e4:	42050513          	addi	a0,a0,1056 # ffffffffc0206b00 <commands+0x5a0>
ffffffffc02006e8:	9e9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006ec:	682c                	ld	a1,80(s0)
ffffffffc02006ee:	00006517          	auipc	a0,0x6
ffffffffc02006f2:	42a50513          	addi	a0,a0,1066 # ffffffffc0206b18 <commands+0x5b8>
ffffffffc02006f6:	9dbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006fa:	6c2c                	ld	a1,88(s0)
ffffffffc02006fc:	00006517          	auipc	a0,0x6
ffffffffc0200700:	43450513          	addi	a0,a0,1076 # ffffffffc0206b30 <commands+0x5d0>
ffffffffc0200704:	9cdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200708:	702c                	ld	a1,96(s0)
ffffffffc020070a:	00006517          	auipc	a0,0x6
ffffffffc020070e:	43e50513          	addi	a0,a0,1086 # ffffffffc0206b48 <commands+0x5e8>
ffffffffc0200712:	9bfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200716:	742c                	ld	a1,104(s0)
ffffffffc0200718:	00006517          	auipc	a0,0x6
ffffffffc020071c:	44850513          	addi	a0,a0,1096 # ffffffffc0206b60 <commands+0x600>
ffffffffc0200720:	9b1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200724:	782c                	ld	a1,112(s0)
ffffffffc0200726:	00006517          	auipc	a0,0x6
ffffffffc020072a:	45250513          	addi	a0,a0,1106 # ffffffffc0206b78 <commands+0x618>
ffffffffc020072e:	9a3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200732:	7c2c                	ld	a1,120(s0)
ffffffffc0200734:	00006517          	auipc	a0,0x6
ffffffffc0200738:	45c50513          	addi	a0,a0,1116 # ffffffffc0206b90 <commands+0x630>
ffffffffc020073c:	995ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200740:	604c                	ld	a1,128(s0)
ffffffffc0200742:	00006517          	auipc	a0,0x6
ffffffffc0200746:	46650513          	addi	a0,a0,1126 # ffffffffc0206ba8 <commands+0x648>
ffffffffc020074a:	987ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074e:	644c                	ld	a1,136(s0)
ffffffffc0200750:	00006517          	auipc	a0,0x6
ffffffffc0200754:	47050513          	addi	a0,a0,1136 # ffffffffc0206bc0 <commands+0x660>
ffffffffc0200758:	979ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020075c:	684c                	ld	a1,144(s0)
ffffffffc020075e:	00006517          	auipc	a0,0x6
ffffffffc0200762:	47a50513          	addi	a0,a0,1146 # ffffffffc0206bd8 <commands+0x678>
ffffffffc0200766:	96bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020076a:	6c4c                	ld	a1,152(s0)
ffffffffc020076c:	00006517          	auipc	a0,0x6
ffffffffc0200770:	48450513          	addi	a0,a0,1156 # ffffffffc0206bf0 <commands+0x690>
ffffffffc0200774:	95dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200778:	704c                	ld	a1,160(s0)
ffffffffc020077a:	00006517          	auipc	a0,0x6
ffffffffc020077e:	48e50513          	addi	a0,a0,1166 # ffffffffc0206c08 <commands+0x6a8>
ffffffffc0200782:	94fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200786:	744c                	ld	a1,168(s0)
ffffffffc0200788:	00006517          	auipc	a0,0x6
ffffffffc020078c:	49850513          	addi	a0,a0,1176 # ffffffffc0206c20 <commands+0x6c0>
ffffffffc0200790:	941ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200794:	784c                	ld	a1,176(s0)
ffffffffc0200796:	00006517          	auipc	a0,0x6
ffffffffc020079a:	4a250513          	addi	a0,a0,1186 # ffffffffc0206c38 <commands+0x6d8>
ffffffffc020079e:	933ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007a2:	7c4c                	ld	a1,184(s0)
ffffffffc02007a4:	00006517          	auipc	a0,0x6
ffffffffc02007a8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0206c50 <commands+0x6f0>
ffffffffc02007ac:	925ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007b0:	606c                	ld	a1,192(s0)
ffffffffc02007b2:	00006517          	auipc	a0,0x6
ffffffffc02007b6:	4b650513          	addi	a0,a0,1206 # ffffffffc0206c68 <commands+0x708>
ffffffffc02007ba:	917ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007be:	646c                	ld	a1,200(s0)
ffffffffc02007c0:	00006517          	auipc	a0,0x6
ffffffffc02007c4:	4c050513          	addi	a0,a0,1216 # ffffffffc0206c80 <commands+0x720>
ffffffffc02007c8:	909ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007cc:	686c                	ld	a1,208(s0)
ffffffffc02007ce:	00006517          	auipc	a0,0x6
ffffffffc02007d2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0206c98 <commands+0x738>
ffffffffc02007d6:	8fbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007da:	6c6c                	ld	a1,216(s0)
ffffffffc02007dc:	00006517          	auipc	a0,0x6
ffffffffc02007e0:	4d450513          	addi	a0,a0,1236 # ffffffffc0206cb0 <commands+0x750>
ffffffffc02007e4:	8edff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e8:	706c                	ld	a1,224(s0)
ffffffffc02007ea:	00006517          	auipc	a0,0x6
ffffffffc02007ee:	4de50513          	addi	a0,a0,1246 # ffffffffc0206cc8 <commands+0x768>
ffffffffc02007f2:	8dfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f6:	746c                	ld	a1,232(s0)
ffffffffc02007f8:	00006517          	auipc	a0,0x6
ffffffffc02007fc:	4e850513          	addi	a0,a0,1256 # ffffffffc0206ce0 <commands+0x780>
ffffffffc0200800:	8d1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200804:	786c                	ld	a1,240(s0)
ffffffffc0200806:	00006517          	auipc	a0,0x6
ffffffffc020080a:	4f250513          	addi	a0,a0,1266 # ffffffffc0206cf8 <commands+0x798>
ffffffffc020080e:	8c3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200812:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200814:	6402                	ld	s0,0(sp)
ffffffffc0200816:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200818:	00006517          	auipc	a0,0x6
ffffffffc020081c:	4f850513          	addi	a0,a0,1272 # ffffffffc0206d10 <commands+0x7b0>
}
ffffffffc0200820:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	8afff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200826 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	1141                	addi	sp,sp,-16
ffffffffc0200828:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020082a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020082c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020082e:	00006517          	auipc	a0,0x6
ffffffffc0200832:	4fa50513          	addi	a0,a0,1274 # ffffffffc0206d28 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	899ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020083c:	8522                	mv	a0,s0
ffffffffc020083e:	e1bff0ef          	jal	ra,ffffffffc0200658 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200842:	10043583          	ld	a1,256(s0)
ffffffffc0200846:	00006517          	auipc	a0,0x6
ffffffffc020084a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0206d40 <commands+0x7e0>
ffffffffc020084e:	883ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200852:	10843583          	ld	a1,264(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	50250513          	addi	a0,a0,1282 # ffffffffc0206d58 <commands+0x7f8>
ffffffffc020085e:	873ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200862:	11043583          	ld	a1,272(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	50a50513          	addi	a0,a0,1290 # ffffffffc0206d70 <commands+0x810>
ffffffffc020086e:	863ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200872:	11843583          	ld	a1,280(s0)
}
ffffffffc0200876:	6402                	ld	s0,0(sp)
ffffffffc0200878:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	50650513          	addi	a0,a0,1286 # ffffffffc0206d80 <commands+0x820>
}
ffffffffc0200882:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200884:	84dff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200888 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200888:	1101                	addi	sp,sp,-32
ffffffffc020088a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020088c:	000ac497          	auipc	s1,0xac
ffffffffc0200890:	d8448493          	addi	s1,s1,-636 # ffffffffc02ac610 <check_mm_struct>
ffffffffc0200894:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc0200896:	e822                	sd	s0,16(sp)
ffffffffc0200898:	ec06                	sd	ra,24(sp)
ffffffffc020089a:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	cbbd                	beqz	a5,ffffffffc0200912 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020089e:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008a2:	11053583          	ld	a1,272(a0)
ffffffffc02008a6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008aa:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ae:	cba1                	beqz	a5,ffffffffc02008fe <pgfault_handler+0x76>
ffffffffc02008b0:	11843703          	ld	a4,280(s0)
ffffffffc02008b4:	47bd                	li	a5,15
ffffffffc02008b6:	05700693          	li	a3,87
ffffffffc02008ba:	00f70463          	beq	a4,a5,ffffffffc02008c2 <pgfault_handler+0x3a>
ffffffffc02008be:	05200693          	li	a3,82
ffffffffc02008c2:	00006517          	auipc	a0,0x6
ffffffffc02008c6:	0e650513          	addi	a0,a0,230 # ffffffffc02069a8 <commands+0x448>
ffffffffc02008ca:	807ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ce:	6088                	ld	a0,0(s1)
ffffffffc02008d0:	c129                	beqz	a0,ffffffffc0200912 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008d2:	000ac797          	auipc	a5,0xac
ffffffffc02008d6:	ce678793          	addi	a5,a5,-794 # ffffffffc02ac5b8 <current>
ffffffffc02008da:	6398                	ld	a4,0(a5)
ffffffffc02008dc:	000ac797          	auipc	a5,0xac
ffffffffc02008e0:	ce478793          	addi	a5,a5,-796 # ffffffffc02ac5c0 <idleproc>
ffffffffc02008e4:	639c                	ld	a5,0(a5)
ffffffffc02008e6:	04f71763          	bne	a4,a5,ffffffffc0200934 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008ea:	11043603          	ld	a2,272(s0)
ffffffffc02008ee:	11843583          	ld	a1,280(s0)
}
ffffffffc02008f2:	6442                	ld	s0,16(sp)
ffffffffc02008f4:	60e2                	ld	ra,24(sp)
ffffffffc02008f6:	64a2                	ld	s1,8(sp)
ffffffffc02008f8:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008fa:	6da0206f          	j	ffffffffc0202fd4 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008fe:	11843703          	ld	a4,280(s0)
ffffffffc0200902:	47bd                	li	a5,15
ffffffffc0200904:	05500613          	li	a2,85
ffffffffc0200908:	05700693          	li	a3,87
ffffffffc020090c:	faf719e3          	bne	a4,a5,ffffffffc02008be <pgfault_handler+0x36>
ffffffffc0200910:	bf4d                	j	ffffffffc02008c2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200912:	000ac797          	auipc	a5,0xac
ffffffffc0200916:	ca678793          	addi	a5,a5,-858 # ffffffffc02ac5b8 <current>
ffffffffc020091a:	639c                	ld	a5,0(a5)
ffffffffc020091c:	cf85                	beqz	a5,ffffffffc0200954 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	11043603          	ld	a2,272(s0)
ffffffffc0200922:	11843583          	ld	a1,280(s0)
}
ffffffffc0200926:	6442                	ld	s0,16(sp)
ffffffffc0200928:	60e2                	ld	ra,24(sp)
ffffffffc020092a:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc020092c:	7788                	ld	a0,40(a5)
}
ffffffffc020092e:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200930:	6a40206f          	j	ffffffffc0202fd4 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200934:	00006697          	auipc	a3,0x6
ffffffffc0200938:	09468693          	addi	a3,a3,148 # ffffffffc02069c8 <commands+0x468>
ffffffffc020093c:	00006617          	auipc	a2,0x6
ffffffffc0200940:	0a460613          	addi	a2,a2,164 # ffffffffc02069e0 <commands+0x480>
ffffffffc0200944:	06b00593          	li	a1,107
ffffffffc0200948:	00006517          	auipc	a0,0x6
ffffffffc020094c:	0b050513          	addi	a0,a0,176 # ffffffffc02069f8 <commands+0x498>
ffffffffc0200950:	8c7ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200954:	8522                	mv	a0,s0
ffffffffc0200956:	ed1ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020095a:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020095e:	11043583          	ld	a1,272(s0)
ffffffffc0200962:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200966:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020096a:	e399                	bnez	a5,ffffffffc0200970 <pgfault_handler+0xe8>
ffffffffc020096c:	05500613          	li	a2,85
ffffffffc0200970:	11843703          	ld	a4,280(s0)
ffffffffc0200974:	47bd                	li	a5,15
ffffffffc0200976:	02f70663          	beq	a4,a5,ffffffffc02009a2 <pgfault_handler+0x11a>
ffffffffc020097a:	05200693          	li	a3,82
ffffffffc020097e:	00006517          	auipc	a0,0x6
ffffffffc0200982:	02a50513          	addi	a0,a0,42 # ffffffffc02069a8 <commands+0x448>
ffffffffc0200986:	f4aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc020098a:	00006617          	auipc	a2,0x6
ffffffffc020098e:	08660613          	addi	a2,a2,134 # ffffffffc0206a10 <commands+0x4b0>
ffffffffc0200992:	07200593          	li	a1,114
ffffffffc0200996:	00006517          	auipc	a0,0x6
ffffffffc020099a:	06250513          	addi	a0,a0,98 # ffffffffc02069f8 <commands+0x498>
ffffffffc020099e:	879ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009a2:	05700693          	li	a3,87
ffffffffc02009a6:	bfe1                	j	ffffffffc020097e <pgfault_handler+0xf6>

ffffffffc02009a8 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009a8:	11853783          	ld	a5,280(a0)
ffffffffc02009ac:	577d                	li	a4,-1
ffffffffc02009ae:	8305                	srli	a4,a4,0x1
ffffffffc02009b0:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009b2:	472d                	li	a4,11
ffffffffc02009b4:	08f76763          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x9a>
ffffffffc02009b8:	00006717          	auipc	a4,0x6
ffffffffc02009bc:	d4470713          	addi	a4,a4,-700 # ffffffffc02066fc <commands+0x19c>
ffffffffc02009c0:	078a                	slli	a5,a5,0x2
ffffffffc02009c2:	97ba                	add	a5,a5,a4
ffffffffc02009c4:	439c                	lw	a5,0(a5)
ffffffffc02009c6:	97ba                	add	a5,a5,a4
ffffffffc02009c8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ca:	00006517          	auipc	a0,0x6
ffffffffc02009ce:	f9e50513          	addi	a0,a0,-98 # ffffffffc0206968 <commands+0x408>
ffffffffc02009d2:	efeff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009d6:	00006517          	auipc	a0,0x6
ffffffffc02009da:	f7250513          	addi	a0,a0,-142 # ffffffffc0206948 <commands+0x3e8>
ffffffffc02009de:	ef2ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009e2:	00006517          	auipc	a0,0x6
ffffffffc02009e6:	f2650513          	addi	a0,a0,-218 # ffffffffc0206908 <commands+0x3a8>
ffffffffc02009ea:	ee6ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	f3a50513          	addi	a0,a0,-198 # ffffffffc0206928 <commands+0x3c8>
ffffffffc02009f6:	edaff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	f8e50513          	addi	a0,a0,-114 # ffffffffc0206988 <commands+0x428>
ffffffffc0200a02:	eceff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a06:	1141                	addi	sp,sp,-16
ffffffffc0200a08:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a0a:	b97ff0ef          	jal	ra,ffffffffc02005a0 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0e:	000ac797          	auipc	a5,0xac
ffffffffc0200a12:	bca78793          	addi	a5,a5,-1078 # ffffffffc02ac5d8 <ticks>
ffffffffc0200a16:	639c                	ld	a5,0(a5)
ffffffffc0200a18:	06400713          	li	a4,100
ffffffffc0200a1c:	0785                	addi	a5,a5,1
ffffffffc0200a1e:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a22:	000ac697          	auipc	a3,0xac
ffffffffc0200a26:	baf6bb23          	sd	a5,-1098(a3) # ffffffffc02ac5d8 <ticks>
ffffffffc0200a2a:	eb09                	bnez	a4,ffffffffc0200a3c <interrupt_handler+0x94>
ffffffffc0200a2c:	000ac797          	auipc	a5,0xac
ffffffffc0200a30:	b8c78793          	addi	a5,a5,-1140 # ffffffffc02ac5b8 <current>
ffffffffc0200a34:	639c                	ld	a5,0(a5)
ffffffffc0200a36:	c399                	beqz	a5,ffffffffc0200a3c <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a38:	4705                	li	a4,1
ffffffffc0200a3a:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a3c:	60a2                	ld	ra,8(sp)
ffffffffc0200a3e:	0141                	addi	sp,sp,16
ffffffffc0200a40:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a42:	de5ff06f          	j	ffffffffc0200826 <print_trapframe>

ffffffffc0200a46 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a46:	11853783          	ld	a5,280(a0)
ffffffffc0200a4a:	473d                	li	a4,15
ffffffffc0200a4c:	1af76e63          	bltu	a4,a5,ffffffffc0200c08 <exception_handler+0x1c2>
ffffffffc0200a50:	00006717          	auipc	a4,0x6
ffffffffc0200a54:	cdc70713          	addi	a4,a4,-804 # ffffffffc020672c <commands+0x1cc>
ffffffffc0200a58:	078a                	slli	a5,a5,0x2
ffffffffc0200a5a:	97ba                	add	a5,a5,a4
ffffffffc0200a5c:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a5e:	1101                	addi	sp,sp,-32
ffffffffc0200a60:	e822                	sd	s0,16(sp)
ffffffffc0200a62:	ec06                	sd	ra,24(sp)
ffffffffc0200a64:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	842a                	mv	s0,a0
ffffffffc0200a6a:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6c:	00006517          	auipc	a0,0x6
ffffffffc0200a70:	df450513          	addi	a0,a0,-524 # ffffffffc0206860 <commands+0x300>
ffffffffc0200a74:	e5cff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a78:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7c:	60e2                	ld	ra,24(sp)
ffffffffc0200a7e:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a80:	0791                	addi	a5,a5,4
ffffffffc0200a82:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a86:	6442                	ld	s0,16(sp)
ffffffffc0200a88:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a8a:	40c0506f          	j	ffffffffc0205e96 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8e:	00006517          	auipc	a0,0x6
ffffffffc0200a92:	df250513          	addi	a0,a0,-526 # ffffffffc0206880 <commands+0x320>
}
ffffffffc0200a96:	6442                	ld	s0,16(sp)
ffffffffc0200a98:	60e2                	ld	ra,24(sp)
ffffffffc0200a9a:	64a2                	ld	s1,8(sp)
ffffffffc0200a9c:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9e:	e32ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa2:	00006517          	auipc	a0,0x6
ffffffffc0200aa6:	dfe50513          	addi	a0,a0,-514 # ffffffffc02068a0 <commands+0x340>
ffffffffc0200aaa:	b7f5                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aac:	00006517          	auipc	a0,0x6
ffffffffc0200ab0:	e1450513          	addi	a0,a0,-492 # ffffffffc02068c0 <commands+0x360>
ffffffffc0200ab4:	b7cd                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab6:	00006517          	auipc	a0,0x6
ffffffffc0200aba:	e2250513          	addi	a0,a0,-478 # ffffffffc02068d8 <commands+0x378>
ffffffffc0200abe:	e12ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac2:	8522                	mv	a0,s0
ffffffffc0200ac4:	dc5ff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200ac8:	84aa                	mv	s1,a0
ffffffffc0200aca:	14051163          	bnez	a0,ffffffffc0200c0c <exception_handler+0x1c6>
}
ffffffffc0200ace:	60e2                	ld	ra,24(sp)
ffffffffc0200ad0:	6442                	ld	s0,16(sp)
ffffffffc0200ad2:	64a2                	ld	s1,8(sp)
ffffffffc0200ad4:	6105                	addi	sp,sp,32
ffffffffc0200ad6:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad8:	00006517          	auipc	a0,0x6
ffffffffc0200adc:	e1850513          	addi	a0,a0,-488 # ffffffffc02068f0 <commands+0x390>
ffffffffc0200ae0:	df0ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae4:	8522                	mv	a0,s0
ffffffffc0200ae6:	da3ff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200aea:	84aa                	mv	s1,a0
ffffffffc0200aec:	d16d                	beqz	a0,ffffffffc0200ace <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aee:	8522                	mv	a0,s0
ffffffffc0200af0:	d37ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af4:	86a6                	mv	a3,s1
ffffffffc0200af6:	00006617          	auipc	a2,0x6
ffffffffc0200afa:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206810 <commands+0x2b0>
ffffffffc0200afe:	0f800593          	li	a1,248
ffffffffc0200b02:	00006517          	auipc	a0,0x6
ffffffffc0200b06:	ef650513          	addi	a0,a0,-266 # ffffffffc02069f8 <commands+0x498>
ffffffffc0200b0a:	f0cff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0e:	00006517          	auipc	a0,0x6
ffffffffc0200b12:	c6250513          	addi	a0,a0,-926 # ffffffffc0206770 <commands+0x210>
ffffffffc0200b16:	b741                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b18:	00006517          	auipc	a0,0x6
ffffffffc0200b1c:	c7850513          	addi	a0,a0,-904 # ffffffffc0206790 <commands+0x230>
ffffffffc0200b20:	bf9d                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b22:	00006517          	auipc	a0,0x6
ffffffffc0200b26:	c8e50513          	addi	a0,a0,-882 # ffffffffc02067b0 <commands+0x250>
ffffffffc0200b2a:	b7b5                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2c:	00006517          	auipc	a0,0x6
ffffffffc0200b30:	c9c50513          	addi	a0,a0,-868 # ffffffffc02067c8 <commands+0x268>
ffffffffc0200b34:	d9cff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b38:	6458                	ld	a4,136(s0)
ffffffffc0200b3a:	47a9                	li	a5,10
ffffffffc0200b3c:	f8f719e3          	bne	a4,a5,ffffffffc0200ace <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b40:	10843783          	ld	a5,264(s0)
ffffffffc0200b44:	0791                	addi	a5,a5,4
ffffffffc0200b46:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b4a:	34c050ef          	jal	ra,ffffffffc0205e96 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4e:	000ac797          	auipc	a5,0xac
ffffffffc0200b52:	a6a78793          	addi	a5,a5,-1430 # ffffffffc02ac5b8 <current>
ffffffffc0200b56:	639c                	ld	a5,0(a5)
ffffffffc0200b58:	8522                	mv	a0,s0
}
ffffffffc0200b5a:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b5e:	60e2                	ld	ra,24(sp)
ffffffffc0200b60:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b62:	6589                	lui	a1,0x2
ffffffffc0200b64:	95be                	add	a1,a1,a5
}
ffffffffc0200b66:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b68:	2220006f          	j	ffffffffc0200d8a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b6c:	00006517          	auipc	a0,0x6
ffffffffc0200b70:	c6c50513          	addi	a0,a0,-916 # ffffffffc02067d8 <commands+0x278>
ffffffffc0200b74:	b70d                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b76:	00006517          	auipc	a0,0x6
ffffffffc0200b7a:	c8250513          	addi	a0,a0,-894 # ffffffffc02067f8 <commands+0x298>
ffffffffc0200b7e:	d52ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b82:	8522                	mv	a0,s0
ffffffffc0200b84:	d05ff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200b88:	84aa                	mv	s1,a0
ffffffffc0200b8a:	d131                	beqz	a0,ffffffffc0200ace <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b8c:	8522                	mv	a0,s0
ffffffffc0200b8e:	c99ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b92:	86a6                	mv	a3,s1
ffffffffc0200b94:	00006617          	auipc	a2,0x6
ffffffffc0200b98:	c7c60613          	addi	a2,a2,-900 # ffffffffc0206810 <commands+0x2b0>
ffffffffc0200b9c:	0cd00593          	li	a1,205
ffffffffc0200ba0:	00006517          	auipc	a0,0x6
ffffffffc0200ba4:	e5850513          	addi	a0,a0,-424 # ffffffffc02069f8 <commands+0x498>
ffffffffc0200ba8:	e6eff0ef          	jal	ra,ffffffffc0200216 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bac:	00006517          	auipc	a0,0x6
ffffffffc0200bb0:	c9c50513          	addi	a0,a0,-868 # ffffffffc0206848 <commands+0x2e8>
ffffffffc0200bb4:	d1cff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb8:	8522                	mv	a0,s0
ffffffffc0200bba:	ccfff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200bbe:	84aa                	mv	s1,a0
ffffffffc0200bc0:	f00507e3          	beqz	a0,ffffffffc0200ace <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bc4:	8522                	mv	a0,s0
ffffffffc0200bc6:	c61ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bca:	86a6                	mv	a3,s1
ffffffffc0200bcc:	00006617          	auipc	a2,0x6
ffffffffc0200bd0:	c4460613          	addi	a2,a2,-956 # ffffffffc0206810 <commands+0x2b0>
ffffffffc0200bd4:	0d700593          	li	a1,215
ffffffffc0200bd8:	00006517          	auipc	a0,0x6
ffffffffc0200bdc:	e2050513          	addi	a0,a0,-480 # ffffffffc02069f8 <commands+0x498>
ffffffffc0200be0:	e36ff0ef          	jal	ra,ffffffffc0200216 <__panic>
}
ffffffffc0200be4:	6442                	ld	s0,16(sp)
ffffffffc0200be6:	60e2                	ld	ra,24(sp)
ffffffffc0200be8:	64a2                	ld	s1,8(sp)
ffffffffc0200bea:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bec:	c3bff06f          	j	ffffffffc0200826 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	c4060613          	addi	a2,a2,-960 # ffffffffc0206830 <commands+0x2d0>
ffffffffc0200bf8:	0d100593          	li	a1,209
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	dfc50513          	addi	a0,a0,-516 # ffffffffc02069f8 <commands+0x498>
ffffffffc0200c04:	e12ff0ef          	jal	ra,ffffffffc0200216 <__panic>
            print_trapframe(tf);
ffffffffc0200c08:	c1fff06f          	j	ffffffffc0200826 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c0c:	8522                	mv	a0,s0
ffffffffc0200c0e:	c19ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c12:	86a6                	mv	a3,s1
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206810 <commands+0x2b0>
ffffffffc0200c1c:	0f100593          	li	a1,241
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	dd850513          	addi	a0,a0,-552 # ffffffffc02069f8 <commands+0x498>
ffffffffc0200c28:	deeff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200c2c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c2c:	1101                	addi	sp,sp,-32
ffffffffc0200c2e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c30:	000ac417          	auipc	s0,0xac
ffffffffc0200c34:	98840413          	addi	s0,s0,-1656 # ffffffffc02ac5b8 <current>
ffffffffc0200c38:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c3a:	ec06                	sd	ra,24(sp)
ffffffffc0200c3c:	e426                	sd	s1,8(sp)
ffffffffc0200c3e:	e04a                	sd	s2,0(sp)
ffffffffc0200c40:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c44:	cf1d                	beqz	a4,ffffffffc0200c82 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c46:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c4a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c4e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c50:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c54:	0206c463          	bltz	a3,ffffffffc0200c7c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c58:	defff0ef          	jal	ra,ffffffffc0200a46 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c5c:	601c                	ld	a5,0(s0)
ffffffffc0200c5e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c62:	e499                	bnez	s1,ffffffffc0200c70 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c64:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c68:	8b05                	andi	a4,a4,1
ffffffffc0200c6a:	e339                	bnez	a4,ffffffffc0200cb0 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c6c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c6e:	eb95                	bnez	a5,ffffffffc0200ca2 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c70:	60e2                	ld	ra,24(sp)
ffffffffc0200c72:	6442                	ld	s0,16(sp)
ffffffffc0200c74:	64a2                	ld	s1,8(sp)
ffffffffc0200c76:	6902                	ld	s2,0(sp)
ffffffffc0200c78:	6105                	addi	sp,sp,32
ffffffffc0200c7a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c7c:	d2dff0ef          	jal	ra,ffffffffc02009a8 <interrupt_handler>
ffffffffc0200c80:	bff1                	j	ffffffffc0200c5c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c82:	0006c963          	bltz	a3,ffffffffc0200c94 <trap+0x68>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c90:	db7ff06f          	j	ffffffffc0200a46 <exception_handler>
}
ffffffffc0200c94:	6442                	ld	s0,16(sp)
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c9e:	d0bff06f          	j	ffffffffc02009a8 <interrupt_handler>
}
ffffffffc0200ca2:	6442                	ld	s0,16(sp)
ffffffffc0200ca4:	60e2                	ld	ra,24(sp)
ffffffffc0200ca6:	64a2                	ld	s1,8(sp)
ffffffffc0200ca8:	6902                	ld	s2,0(sp)
ffffffffc0200caa:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cac:	0f40506f          	j	ffffffffc0205da0 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cb0:	555d                	li	a0,-9
ffffffffc0200cb2:	57c040ef          	jal	ra,ffffffffc020522e <do_exit>
ffffffffc0200cb6:	601c                	ld	a5,0(s0)
ffffffffc0200cb8:	bf55                	j	ffffffffc0200c6c <trap+0x40>
	...

ffffffffc0200cbc <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cbc:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cc0:	00011463          	bnez	sp,ffffffffc0200cc8 <__alltraps+0xc>
ffffffffc0200cc4:	14002173          	csrr	sp,sscratch
ffffffffc0200cc8:	712d                	addi	sp,sp,-288
ffffffffc0200cca:	e002                	sd	zero,0(sp)
ffffffffc0200ccc:	e406                	sd	ra,8(sp)
ffffffffc0200cce:	ec0e                	sd	gp,24(sp)
ffffffffc0200cd0:	f012                	sd	tp,32(sp)
ffffffffc0200cd2:	f416                	sd	t0,40(sp)
ffffffffc0200cd4:	f81a                	sd	t1,48(sp)
ffffffffc0200cd6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cd8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cda:	e4a6                	sd	s1,72(sp)
ffffffffc0200cdc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cde:	ecae                	sd	a1,88(sp)
ffffffffc0200ce0:	f0b2                	sd	a2,96(sp)
ffffffffc0200ce2:	f4b6                	sd	a3,104(sp)
ffffffffc0200ce4:	f8ba                	sd	a4,112(sp)
ffffffffc0200ce6:	fcbe                	sd	a5,120(sp)
ffffffffc0200ce8:	e142                	sd	a6,128(sp)
ffffffffc0200cea:	e546                	sd	a7,136(sp)
ffffffffc0200cec:	e94a                	sd	s2,144(sp)
ffffffffc0200cee:	ed4e                	sd	s3,152(sp)
ffffffffc0200cf0:	f152                	sd	s4,160(sp)
ffffffffc0200cf2:	f556                	sd	s5,168(sp)
ffffffffc0200cf4:	f95a                	sd	s6,176(sp)
ffffffffc0200cf6:	fd5e                	sd	s7,184(sp)
ffffffffc0200cf8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cfa:	e5e6                	sd	s9,200(sp)
ffffffffc0200cfc:	e9ea                	sd	s10,208(sp)
ffffffffc0200cfe:	edee                	sd	s11,216(sp)
ffffffffc0200d00:	f1f2                	sd	t3,224(sp)
ffffffffc0200d02:	f5f6                	sd	t4,232(sp)
ffffffffc0200d04:	f9fa                	sd	t5,240(sp)
ffffffffc0200d06:	fdfe                	sd	t6,248(sp)
ffffffffc0200d08:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d0c:	100024f3          	csrr	s1,sstatus
ffffffffc0200d10:	14102973          	csrr	s2,sepc
ffffffffc0200d14:	143029f3          	csrr	s3,stval
ffffffffc0200d18:	14202a73          	csrr	s4,scause
ffffffffc0200d1c:	e822                	sd	s0,16(sp)
ffffffffc0200d1e:	e226                	sd	s1,256(sp)
ffffffffc0200d20:	e64a                	sd	s2,264(sp)
ffffffffc0200d22:	ea4e                	sd	s3,272(sp)
ffffffffc0200d24:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d26:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d28:	f05ff0ef          	jal	ra,ffffffffc0200c2c <trap>

ffffffffc0200d2c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d2c:	6492                	ld	s1,256(sp)
ffffffffc0200d2e:	6932                	ld	s2,264(sp)
ffffffffc0200d30:	1004f413          	andi	s0,s1,256
ffffffffc0200d34:	e401                	bnez	s0,ffffffffc0200d3c <__trapret+0x10>
ffffffffc0200d36:	1200                	addi	s0,sp,288
ffffffffc0200d38:	14041073          	csrw	sscratch,s0
ffffffffc0200d3c:	10049073          	csrw	sstatus,s1
ffffffffc0200d40:	14191073          	csrw	sepc,s2
ffffffffc0200d44:	60a2                	ld	ra,8(sp)
ffffffffc0200d46:	61e2                	ld	gp,24(sp)
ffffffffc0200d48:	7202                	ld	tp,32(sp)
ffffffffc0200d4a:	72a2                	ld	t0,40(sp)
ffffffffc0200d4c:	7342                	ld	t1,48(sp)
ffffffffc0200d4e:	73e2                	ld	t2,56(sp)
ffffffffc0200d50:	6406                	ld	s0,64(sp)
ffffffffc0200d52:	64a6                	ld	s1,72(sp)
ffffffffc0200d54:	6546                	ld	a0,80(sp)
ffffffffc0200d56:	65e6                	ld	a1,88(sp)
ffffffffc0200d58:	7606                	ld	a2,96(sp)
ffffffffc0200d5a:	76a6                	ld	a3,104(sp)
ffffffffc0200d5c:	7746                	ld	a4,112(sp)
ffffffffc0200d5e:	77e6                	ld	a5,120(sp)
ffffffffc0200d60:	680a                	ld	a6,128(sp)
ffffffffc0200d62:	68aa                	ld	a7,136(sp)
ffffffffc0200d64:	694a                	ld	s2,144(sp)
ffffffffc0200d66:	69ea                	ld	s3,152(sp)
ffffffffc0200d68:	7a0a                	ld	s4,160(sp)
ffffffffc0200d6a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d6c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d6e:	7bea                	ld	s7,184(sp)
ffffffffc0200d70:	6c0e                	ld	s8,192(sp)
ffffffffc0200d72:	6cae                	ld	s9,200(sp)
ffffffffc0200d74:	6d4e                	ld	s10,208(sp)
ffffffffc0200d76:	6dee                	ld	s11,216(sp)
ffffffffc0200d78:	7e0e                	ld	t3,224(sp)
ffffffffc0200d7a:	7eae                	ld	t4,232(sp)
ffffffffc0200d7c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d7e:	7fee                	ld	t6,248(sp)
ffffffffc0200d80:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d82:	10200073          	sret

ffffffffc0200d86 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d86:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d88:	b755                	j	ffffffffc0200d2c <__trapret>

ffffffffc0200d8a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d8a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76a8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d8e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d92:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d96:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d9a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d9e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200da2:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200da6:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200daa:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dae:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200db0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200db2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200db4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200db6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200db8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dba:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dbc:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dbe:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dc0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dc2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dc4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dc6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dc8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dca:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dcc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dce:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dd0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dd2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dd4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dd6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dd8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dda:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200ddc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dde:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200de0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200de2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200de4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200de6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200de8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dea:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dec:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dee:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200df0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200df2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200df4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200df6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200df8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dfa:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dfc:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dfe:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e00:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e02:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e04:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e06:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e08:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e0a:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e0c:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e0e:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e10:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e12:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e14:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e16:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e18:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e1a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e1c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e1e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e20:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e22:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e24:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e26:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e28:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e2a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e2c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e2e:	812e                	mv	sp,a1
ffffffffc0200e30:	bdf5                	j	ffffffffc0200d2c <__trapret>

ffffffffc0200e32 <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e32:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e34:	00006617          	auipc	a2,0x6
ffffffffc0200e38:	fe460613          	addi	a2,a2,-28 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc0200e3c:	06200593          	li	a1,98
ffffffffc0200e40:	00006517          	auipc	a0,0x6
ffffffffc0200e44:	ff850513          	addi	a0,a0,-8 # ffffffffc0206e38 <commands+0x8d8>
pa2page(uintptr_t pa) {
ffffffffc0200e48:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e4a:	bccff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0200e4e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e4e:	715d                	addi	sp,sp,-80
ffffffffc0200e50:	e0a2                	sd	s0,64(sp)
ffffffffc0200e52:	fc26                	sd	s1,56(sp)
ffffffffc0200e54:	f84a                	sd	s2,48(sp)
ffffffffc0200e56:	f44e                	sd	s3,40(sp)
ffffffffc0200e58:	f052                	sd	s4,32(sp)
ffffffffc0200e5a:	ec56                	sd	s5,24(sp)
ffffffffc0200e5c:	e486                	sd	ra,72(sp)
ffffffffc0200e5e:	842a                	mv	s0,a0
ffffffffc0200e60:	000ab497          	auipc	s1,0xab
ffffffffc0200e64:	78048493          	addi	s1,s1,1920 # ffffffffc02ac5e0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e68:	4985                	li	s3,1
ffffffffc0200e6a:	000aba17          	auipc	s4,0xab
ffffffffc0200e6e:	746a0a13          	addi	s4,s4,1862 # ffffffffc02ac5b0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e72:	0005091b          	sext.w	s2,a0
ffffffffc0200e76:	000aba97          	auipc	s5,0xab
ffffffffc0200e7a:	79aa8a93          	addi	s5,s5,1946 # ffffffffc02ac610 <check_mm_struct>
ffffffffc0200e7e:	a00d                	j	ffffffffc0200ea0 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e80:	609c                	ld	a5,0(s1)
ffffffffc0200e82:	6f9c                	ld	a5,24(a5)
ffffffffc0200e84:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e86:	4601                	li	a2,0
ffffffffc0200e88:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e8a:	ed0d                	bnez	a0,ffffffffc0200ec4 <alloc_pages+0x76>
ffffffffc0200e8c:	0289ec63          	bltu	s3,s0,ffffffffc0200ec4 <alloc_pages+0x76>
ffffffffc0200e90:	000a2783          	lw	a5,0(s4)
ffffffffc0200e94:	2781                	sext.w	a5,a5
ffffffffc0200e96:	c79d                	beqz	a5,ffffffffc0200ec4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e98:	000ab503          	ld	a0,0(s5)
ffffffffc0200e9c:	6c1020ef          	jal	ra,ffffffffc0203d5c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ea0:	100027f3          	csrr	a5,sstatus
ffffffffc0200ea4:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200ea6:	8522                	mv	a0,s0
ffffffffc0200ea8:	dfe1                	beqz	a5,ffffffffc0200e80 <alloc_pages+0x32>
        intr_disable();
ffffffffc0200eaa:	f8eff0ef          	jal	ra,ffffffffc0200638 <intr_disable>
ffffffffc0200eae:	609c                	ld	a5,0(s1)
ffffffffc0200eb0:	8522                	mv	a0,s0
ffffffffc0200eb2:	6f9c                	ld	a5,24(a5)
ffffffffc0200eb4:	9782                	jalr	a5
ffffffffc0200eb6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200eb8:	f7aff0ef          	jal	ra,ffffffffc0200632 <intr_enable>
ffffffffc0200ebc:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ebe:	4601                	li	a2,0
ffffffffc0200ec0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ec2:	d569                	beqz	a0,ffffffffc0200e8c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200ec4:	60a6                	ld	ra,72(sp)
ffffffffc0200ec6:	6406                	ld	s0,64(sp)
ffffffffc0200ec8:	74e2                	ld	s1,56(sp)
ffffffffc0200eca:	7942                	ld	s2,48(sp)
ffffffffc0200ecc:	79a2                	ld	s3,40(sp)
ffffffffc0200ece:	7a02                	ld	s4,32(sp)
ffffffffc0200ed0:	6ae2                	ld	s5,24(sp)
ffffffffc0200ed2:	6161                	addi	sp,sp,80
ffffffffc0200ed4:	8082                	ret

ffffffffc0200ed6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ed6:	100027f3          	csrr	a5,sstatus
ffffffffc0200eda:	8b89                	andi	a5,a5,2
ffffffffc0200edc:	eb89                	bnez	a5,ffffffffc0200eee <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200ede:	000ab797          	auipc	a5,0xab
ffffffffc0200ee2:	70278793          	addi	a5,a5,1794 # ffffffffc02ac5e0 <pmm_manager>
ffffffffc0200ee6:	639c                	ld	a5,0(a5)
ffffffffc0200ee8:	0207b303          	ld	t1,32(a5)
ffffffffc0200eec:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200eee:	1101                	addi	sp,sp,-32
ffffffffc0200ef0:	ec06                	sd	ra,24(sp)
ffffffffc0200ef2:	e822                	sd	s0,16(sp)
ffffffffc0200ef4:	e426                	sd	s1,8(sp)
ffffffffc0200ef6:	842a                	mv	s0,a0
ffffffffc0200ef8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200efa:	f3eff0ef          	jal	ra,ffffffffc0200638 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200efe:	000ab797          	auipc	a5,0xab
ffffffffc0200f02:	6e278793          	addi	a5,a5,1762 # ffffffffc02ac5e0 <pmm_manager>
ffffffffc0200f06:	639c                	ld	a5,0(a5)
ffffffffc0200f08:	85a6                	mv	a1,s1
ffffffffc0200f0a:	8522                	mv	a0,s0
ffffffffc0200f0c:	739c                	ld	a5,32(a5)
ffffffffc0200f0e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f10:	6442                	ld	s0,16(sp)
ffffffffc0200f12:	60e2                	ld	ra,24(sp)
ffffffffc0200f14:	64a2                	ld	s1,8(sp)
ffffffffc0200f16:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f18:	f1aff06f          	j	ffffffffc0200632 <intr_enable>

ffffffffc0200f1c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f1c:	100027f3          	csrr	a5,sstatus
ffffffffc0200f20:	8b89                	andi	a5,a5,2
ffffffffc0200f22:	eb89                	bnez	a5,ffffffffc0200f34 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f24:	000ab797          	auipc	a5,0xab
ffffffffc0200f28:	6bc78793          	addi	a5,a5,1724 # ffffffffc02ac5e0 <pmm_manager>
ffffffffc0200f2c:	639c                	ld	a5,0(a5)
ffffffffc0200f2e:	0287b303          	ld	t1,40(a5)
ffffffffc0200f32:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200f34:	1141                	addi	sp,sp,-16
ffffffffc0200f36:	e406                	sd	ra,8(sp)
ffffffffc0200f38:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f3a:	efeff0ef          	jal	ra,ffffffffc0200638 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f3e:	000ab797          	auipc	a5,0xab
ffffffffc0200f42:	6a278793          	addi	a5,a5,1698 # ffffffffc02ac5e0 <pmm_manager>
ffffffffc0200f46:	639c                	ld	a5,0(a5)
ffffffffc0200f48:	779c                	ld	a5,40(a5)
ffffffffc0200f4a:	9782                	jalr	a5
ffffffffc0200f4c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f4e:	ee4ff0ef          	jal	ra,ffffffffc0200632 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f52:	8522                	mv	a0,s0
ffffffffc0200f54:	60a2                	ld	ra,8(sp)
ffffffffc0200f56:	6402                	ld	s0,0(sp)
ffffffffc0200f58:	0141                	addi	sp,sp,16
ffffffffc0200f5a:	8082                	ret

ffffffffc0200f5c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f5c:	7139                	addi	sp,sp,-64
ffffffffc0200f5e:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f60:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200f64:	1ff4f493          	andi	s1,s1,511
ffffffffc0200f68:	048e                	slli	s1,s1,0x3
ffffffffc0200f6a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f6c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f6e:	f04a                	sd	s2,32(sp)
ffffffffc0200f70:	ec4e                	sd	s3,24(sp)
ffffffffc0200f72:	e852                	sd	s4,16(sp)
ffffffffc0200f74:	fc06                	sd	ra,56(sp)
ffffffffc0200f76:	f822                	sd	s0,48(sp)
ffffffffc0200f78:	e456                	sd	s5,8(sp)
ffffffffc0200f7a:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f7c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f80:	892e                	mv	s2,a1
ffffffffc0200f82:	8a32                	mv	s4,a2
ffffffffc0200f84:	000ab997          	auipc	s3,0xab
ffffffffc0200f88:	60c98993          	addi	s3,s3,1548 # ffffffffc02ac590 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f8c:	e7bd                	bnez	a5,ffffffffc0200ffa <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200f8e:	12060c63          	beqz	a2,ffffffffc02010c6 <get_pte+0x16a>
ffffffffc0200f92:	4505                	li	a0,1
ffffffffc0200f94:	ebbff0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0200f98:	842a                	mv	s0,a0
ffffffffc0200f9a:	12050663          	beqz	a0,ffffffffc02010c6 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200f9e:	000abb17          	auipc	s6,0xab
ffffffffc0200fa2:	65ab0b13          	addi	s6,s6,1626 # ffffffffc02ac5f8 <pages>
ffffffffc0200fa6:	000b3503          	ld	a0,0(s6)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200faa:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200fac:	000ab997          	auipc	s3,0xab
ffffffffc0200fb0:	5e498993          	addi	s3,s3,1508 # ffffffffc02ac590 <npage>
    return page - pages + nbase;
ffffffffc0200fb4:	40a40533          	sub	a0,s0,a0
ffffffffc0200fb8:	00080ab7          	lui	s5,0x80
ffffffffc0200fbc:	8519                	srai	a0,a0,0x6
ffffffffc0200fbe:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0200fc2:	c01c                	sw	a5,0(s0)
ffffffffc0200fc4:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0200fc6:	9556                	add	a0,a0,s5
ffffffffc0200fc8:	83b1                	srli	a5,a5,0xc
ffffffffc0200fca:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fcc:	0532                	slli	a0,a0,0xc
ffffffffc0200fce:	14e7f363          	bleu	a4,a5,ffffffffc0201114 <get_pte+0x1b8>
ffffffffc0200fd2:	000ab797          	auipc	a5,0xab
ffffffffc0200fd6:	61678793          	addi	a5,a5,1558 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0200fda:	639c                	ld	a5,0(a5)
ffffffffc0200fdc:	6605                	lui	a2,0x1
ffffffffc0200fde:	4581                	li	a1,0
ffffffffc0200fe0:	953e                	add	a0,a0,a5
ffffffffc0200fe2:	7d3040ef          	jal	ra,ffffffffc0205fb4 <memset>
    return page - pages + nbase;
ffffffffc0200fe6:	000b3683          	ld	a3,0(s6)
ffffffffc0200fea:	40d406b3          	sub	a3,s0,a3
ffffffffc0200fee:	8699                	srai	a3,a3,0x6
ffffffffc0200ff0:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ff2:	06aa                	slli	a3,a3,0xa
ffffffffc0200ff4:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200ff8:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200ffa:	77fd                	lui	a5,0xfffff
ffffffffc0200ffc:	068a                	slli	a3,a3,0x2
ffffffffc0200ffe:	0009b703          	ld	a4,0(s3)
ffffffffc0201002:	8efd                	and	a3,a3,a5
ffffffffc0201004:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201008:	0ce7f163          	bleu	a4,a5,ffffffffc02010ca <get_pte+0x16e>
ffffffffc020100c:	000aba97          	auipc	s5,0xab
ffffffffc0201010:	5dca8a93          	addi	s5,s5,1500 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0201014:	000ab403          	ld	s0,0(s5)
ffffffffc0201018:	01595793          	srli	a5,s2,0x15
ffffffffc020101c:	1ff7f793          	andi	a5,a5,511
ffffffffc0201020:	96a2                	add	a3,a3,s0
ffffffffc0201022:	00379413          	slli	s0,a5,0x3
ffffffffc0201026:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201028:	6014                	ld	a3,0(s0)
ffffffffc020102a:	0016f793          	andi	a5,a3,1
ffffffffc020102e:	e3ad                	bnez	a5,ffffffffc0201090 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201030:	080a0b63          	beqz	s4,ffffffffc02010c6 <get_pte+0x16a>
ffffffffc0201034:	4505                	li	a0,1
ffffffffc0201036:	e19ff0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc020103a:	84aa                	mv	s1,a0
ffffffffc020103c:	c549                	beqz	a0,ffffffffc02010c6 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020103e:	000abb17          	auipc	s6,0xab
ffffffffc0201042:	5bab0b13          	addi	s6,s6,1466 # ffffffffc02ac5f8 <pages>
ffffffffc0201046:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020104a:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc020104c:	00080a37          	lui	s4,0x80
ffffffffc0201050:	40a48533          	sub	a0,s1,a0
ffffffffc0201054:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201056:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020105a:	c09c                	sw	a5,0(s1)
ffffffffc020105c:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020105e:	9552                	add	a0,a0,s4
ffffffffc0201060:	83b1                	srli	a5,a5,0xc
ffffffffc0201062:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201064:	0532                	slli	a0,a0,0xc
ffffffffc0201066:	08e7fa63          	bleu	a4,a5,ffffffffc02010fa <get_pte+0x19e>
ffffffffc020106a:	000ab783          	ld	a5,0(s5)
ffffffffc020106e:	6605                	lui	a2,0x1
ffffffffc0201070:	4581                	li	a1,0
ffffffffc0201072:	953e                	add	a0,a0,a5
ffffffffc0201074:	741040ef          	jal	ra,ffffffffc0205fb4 <memset>
    return page - pages + nbase;
ffffffffc0201078:	000b3683          	ld	a3,0(s6)
ffffffffc020107c:	40d486b3          	sub	a3,s1,a3
ffffffffc0201080:	8699                	srai	a3,a3,0x6
ffffffffc0201082:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201084:	06aa                	slli	a3,a3,0xa
ffffffffc0201086:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020108a:	e014                	sd	a3,0(s0)
ffffffffc020108c:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201090:	068a                	slli	a3,a3,0x2
ffffffffc0201092:	757d                	lui	a0,0xfffff
ffffffffc0201094:	8ee9                	and	a3,a3,a0
ffffffffc0201096:	00c6d793          	srli	a5,a3,0xc
ffffffffc020109a:	04e7f463          	bleu	a4,a5,ffffffffc02010e2 <get_pte+0x186>
ffffffffc020109e:	000ab503          	ld	a0,0(s5)
ffffffffc02010a2:	00c95793          	srli	a5,s2,0xc
ffffffffc02010a6:	1ff7f793          	andi	a5,a5,511
ffffffffc02010aa:	96aa                	add	a3,a3,a0
ffffffffc02010ac:	00379513          	slli	a0,a5,0x3
ffffffffc02010b0:	9536                	add	a0,a0,a3
}
ffffffffc02010b2:	70e2                	ld	ra,56(sp)
ffffffffc02010b4:	7442                	ld	s0,48(sp)
ffffffffc02010b6:	74a2                	ld	s1,40(sp)
ffffffffc02010b8:	7902                	ld	s2,32(sp)
ffffffffc02010ba:	69e2                	ld	s3,24(sp)
ffffffffc02010bc:	6a42                	ld	s4,16(sp)
ffffffffc02010be:	6aa2                	ld	s5,8(sp)
ffffffffc02010c0:	6b02                	ld	s6,0(sp)
ffffffffc02010c2:	6121                	addi	sp,sp,64
ffffffffc02010c4:	8082                	ret
            return NULL;
ffffffffc02010c6:	4501                	li	a0,0
ffffffffc02010c8:	b7ed                	j	ffffffffc02010b2 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010ca:	00006617          	auipc	a2,0x6
ffffffffc02010ce:	d1660613          	addi	a2,a2,-746 # ffffffffc0206de0 <commands+0x880>
ffffffffc02010d2:	0e300593          	li	a1,227
ffffffffc02010d6:	00006517          	auipc	a0,0x6
ffffffffc02010da:	d3250513          	addi	a0,a0,-718 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02010de:	938ff0ef          	jal	ra,ffffffffc0200216 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010e2:	00006617          	auipc	a2,0x6
ffffffffc02010e6:	cfe60613          	addi	a2,a2,-770 # ffffffffc0206de0 <commands+0x880>
ffffffffc02010ea:	0ee00593          	li	a1,238
ffffffffc02010ee:	00006517          	auipc	a0,0x6
ffffffffc02010f2:	d1a50513          	addi	a0,a0,-742 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02010f6:	920ff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02010fa:	86aa                	mv	a3,a0
ffffffffc02010fc:	00006617          	auipc	a2,0x6
ffffffffc0201100:	ce460613          	addi	a2,a2,-796 # ffffffffc0206de0 <commands+0x880>
ffffffffc0201104:	0eb00593          	li	a1,235
ffffffffc0201108:	00006517          	auipc	a0,0x6
ffffffffc020110c:	d0050513          	addi	a0,a0,-768 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201110:	906ff0ef          	jal	ra,ffffffffc0200216 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201114:	86aa                	mv	a3,a0
ffffffffc0201116:	00006617          	auipc	a2,0x6
ffffffffc020111a:	cca60613          	addi	a2,a2,-822 # ffffffffc0206de0 <commands+0x880>
ffffffffc020111e:	0df00593          	li	a1,223
ffffffffc0201122:	00006517          	auipc	a0,0x6
ffffffffc0201126:	ce650513          	addi	a0,a0,-794 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc020112a:	8ecff0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020112e <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020112e:	1141                	addi	sp,sp,-16
ffffffffc0201130:	e022                	sd	s0,0(sp)
ffffffffc0201132:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201134:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201136:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201138:	e25ff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
    if (ptep_store != NULL) {
ffffffffc020113c:	c011                	beqz	s0,ffffffffc0201140 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020113e:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201140:	c129                	beqz	a0,ffffffffc0201182 <get_page+0x54>
ffffffffc0201142:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201144:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201146:	0017f713          	andi	a4,a5,1
ffffffffc020114a:	e709                	bnez	a4,ffffffffc0201154 <get_page+0x26>
}
ffffffffc020114c:	60a2                	ld	ra,8(sp)
ffffffffc020114e:	6402                	ld	s0,0(sp)
ffffffffc0201150:	0141                	addi	sp,sp,16
ffffffffc0201152:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201154:	000ab717          	auipc	a4,0xab
ffffffffc0201158:	43c70713          	addi	a4,a4,1084 # ffffffffc02ac590 <npage>
ffffffffc020115c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020115e:	078a                	slli	a5,a5,0x2
ffffffffc0201160:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201162:	02e7f563          	bleu	a4,a5,ffffffffc020118c <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201166:	000ab717          	auipc	a4,0xab
ffffffffc020116a:	49270713          	addi	a4,a4,1170 # ffffffffc02ac5f8 <pages>
ffffffffc020116e:	6308                	ld	a0,0(a4)
ffffffffc0201170:	60a2                	ld	ra,8(sp)
ffffffffc0201172:	6402                	ld	s0,0(sp)
ffffffffc0201174:	fff80737          	lui	a4,0xfff80
ffffffffc0201178:	97ba                	add	a5,a5,a4
ffffffffc020117a:	079a                	slli	a5,a5,0x6
ffffffffc020117c:	953e                	add	a0,a0,a5
ffffffffc020117e:	0141                	addi	sp,sp,16
ffffffffc0201180:	8082                	ret
ffffffffc0201182:	60a2                	ld	ra,8(sp)
ffffffffc0201184:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201186:	4501                	li	a0,0
}
ffffffffc0201188:	0141                	addi	sp,sp,16
ffffffffc020118a:	8082                	ret
ffffffffc020118c:	ca7ff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.4>

ffffffffc0201190 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201190:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201192:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201196:	ec86                	sd	ra,88(sp)
ffffffffc0201198:	e8a2                	sd	s0,80(sp)
ffffffffc020119a:	e4a6                	sd	s1,72(sp)
ffffffffc020119c:	e0ca                	sd	s2,64(sp)
ffffffffc020119e:	fc4e                	sd	s3,56(sp)
ffffffffc02011a0:	f852                	sd	s4,48(sp)
ffffffffc02011a2:	f456                	sd	s5,40(sp)
ffffffffc02011a4:	f05a                	sd	s6,32(sp)
ffffffffc02011a6:	ec5e                	sd	s7,24(sp)
ffffffffc02011a8:	e862                	sd	s8,16(sp)
ffffffffc02011aa:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011ac:	03479713          	slli	a4,a5,0x34
ffffffffc02011b0:	eb71                	bnez	a4,ffffffffc0201284 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02011b2:	002007b7          	lui	a5,0x200
ffffffffc02011b6:	842e                	mv	s0,a1
ffffffffc02011b8:	0af5e663          	bltu	a1,a5,ffffffffc0201264 <unmap_range+0xd4>
ffffffffc02011bc:	8932                	mv	s2,a2
ffffffffc02011be:	0ac5f363          	bleu	a2,a1,ffffffffc0201264 <unmap_range+0xd4>
ffffffffc02011c2:	4785                	li	a5,1
ffffffffc02011c4:	07fe                	slli	a5,a5,0x1f
ffffffffc02011c6:	08c7ef63          	bltu	a5,a2,ffffffffc0201264 <unmap_range+0xd4>
ffffffffc02011ca:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011cc:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011ce:	000abc97          	auipc	s9,0xab
ffffffffc02011d2:	3c2c8c93          	addi	s9,s9,962 # ffffffffc02ac590 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011d6:	000abc17          	auipc	s8,0xab
ffffffffc02011da:	422c0c13          	addi	s8,s8,1058 # ffffffffc02ac5f8 <pages>
ffffffffc02011de:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02011e2:	00200b37          	lui	s6,0x200
ffffffffc02011e6:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02011ea:	4601                	li	a2,0
ffffffffc02011ec:	85a2                	mv	a1,s0
ffffffffc02011ee:	854e                	mv	a0,s3
ffffffffc02011f0:	d6dff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc02011f4:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02011f6:	cd21                	beqz	a0,ffffffffc020124e <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02011f8:	611c                	ld	a5,0(a0)
ffffffffc02011fa:	e38d                	bnez	a5,ffffffffc020121c <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02011fc:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02011fe:	ff2466e3          	bltu	s0,s2,ffffffffc02011ea <unmap_range+0x5a>
}
ffffffffc0201202:	60e6                	ld	ra,88(sp)
ffffffffc0201204:	6446                	ld	s0,80(sp)
ffffffffc0201206:	64a6                	ld	s1,72(sp)
ffffffffc0201208:	6906                	ld	s2,64(sp)
ffffffffc020120a:	79e2                	ld	s3,56(sp)
ffffffffc020120c:	7a42                	ld	s4,48(sp)
ffffffffc020120e:	7aa2                	ld	s5,40(sp)
ffffffffc0201210:	7b02                	ld	s6,32(sp)
ffffffffc0201212:	6be2                	ld	s7,24(sp)
ffffffffc0201214:	6c42                	ld	s8,16(sp)
ffffffffc0201216:	6ca2                	ld	s9,8(sp)
ffffffffc0201218:	6125                	addi	sp,sp,96
ffffffffc020121a:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020121c:	0017f713          	andi	a4,a5,1
ffffffffc0201220:	df71                	beqz	a4,ffffffffc02011fc <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0201222:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201226:	078a                	slli	a5,a5,0x2
ffffffffc0201228:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020122a:	06e7fd63          	bleu	a4,a5,ffffffffc02012a4 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc020122e:	000c3503          	ld	a0,0(s8)
ffffffffc0201232:	97de                	add	a5,a5,s7
ffffffffc0201234:	079a                	slli	a5,a5,0x6
ffffffffc0201236:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201238:	411c                	lw	a5,0(a0)
ffffffffc020123a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020123e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201240:	cf11                	beqz	a4,ffffffffc020125c <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201242:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201246:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020124a:	9452                	add	s0,s0,s4
ffffffffc020124c:	bf4d                	j	ffffffffc02011fe <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020124e:	945a                	add	s0,s0,s6
ffffffffc0201250:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201254:	d45d                	beqz	s0,ffffffffc0201202 <unmap_range+0x72>
ffffffffc0201256:	f9246ae3          	bltu	s0,s2,ffffffffc02011ea <unmap_range+0x5a>
ffffffffc020125a:	b765                	j	ffffffffc0201202 <unmap_range+0x72>
            free_page(page);
ffffffffc020125c:	4585                	li	a1,1
ffffffffc020125e:	c79ff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
ffffffffc0201262:	b7c5                	j	ffffffffc0201242 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0201264:	00006697          	auipc	a3,0x6
ffffffffc0201268:	17c68693          	addi	a3,a3,380 # ffffffffc02073e0 <commands+0xe80>
ffffffffc020126c:	00005617          	auipc	a2,0x5
ffffffffc0201270:	77460613          	addi	a2,a2,1908 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201274:	11000593          	li	a1,272
ffffffffc0201278:	00006517          	auipc	a0,0x6
ffffffffc020127c:	b9050513          	addi	a0,a0,-1136 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201280:	f97fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201284:	00006697          	auipc	a3,0x6
ffffffffc0201288:	12c68693          	addi	a3,a3,300 # ffffffffc02073b0 <commands+0xe50>
ffffffffc020128c:	00005617          	auipc	a2,0x5
ffffffffc0201290:	75460613          	addi	a2,a2,1876 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201294:	10f00593          	li	a1,271
ffffffffc0201298:	00006517          	auipc	a0,0x6
ffffffffc020129c:	b7050513          	addi	a0,a0,-1168 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02012a0:	f77fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02012a4:	b8fff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.4>

ffffffffc02012a8 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012a8:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012aa:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012ae:	fc86                	sd	ra,120(sp)
ffffffffc02012b0:	f8a2                	sd	s0,112(sp)
ffffffffc02012b2:	f4a6                	sd	s1,104(sp)
ffffffffc02012b4:	f0ca                	sd	s2,96(sp)
ffffffffc02012b6:	ecce                	sd	s3,88(sp)
ffffffffc02012b8:	e8d2                	sd	s4,80(sp)
ffffffffc02012ba:	e4d6                	sd	s5,72(sp)
ffffffffc02012bc:	e0da                	sd	s6,64(sp)
ffffffffc02012be:	fc5e                	sd	s7,56(sp)
ffffffffc02012c0:	f862                	sd	s8,48(sp)
ffffffffc02012c2:	f466                	sd	s9,40(sp)
ffffffffc02012c4:	f06a                	sd	s10,32(sp)
ffffffffc02012c6:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012c8:	03479713          	slli	a4,a5,0x34
ffffffffc02012cc:	1c071163          	bnez	a4,ffffffffc020148e <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02012d0:	002007b7          	lui	a5,0x200
ffffffffc02012d4:	20f5e563          	bltu	a1,a5,ffffffffc02014de <exit_range+0x236>
ffffffffc02012d8:	8b32                	mv	s6,a2
ffffffffc02012da:	20c5f263          	bleu	a2,a1,ffffffffc02014de <exit_range+0x236>
ffffffffc02012de:	4785                	li	a5,1
ffffffffc02012e0:	07fe                	slli	a5,a5,0x1f
ffffffffc02012e2:	1ec7ee63          	bltu	a5,a2,ffffffffc02014de <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02012e6:	c00009b7          	lui	s3,0xc0000
ffffffffc02012ea:	400007b7          	lui	a5,0x40000
ffffffffc02012ee:	0135f9b3          	and	s3,a1,s3
ffffffffc02012f2:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02012f4:	c0000337          	lui	t1,0xc0000
ffffffffc02012f8:	00698933          	add	s2,s3,t1
ffffffffc02012fc:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201300:	1ff97913          	andi	s2,s2,511
ffffffffc0201304:	8e2a                	mv	t3,a0
ffffffffc0201306:	090e                	slli	s2,s2,0x3
ffffffffc0201308:	9972                	add	s2,s2,t3
ffffffffc020130a:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020130e:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0201312:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0201314:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201318:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020131a:	000abd17          	auipc	s10,0xab
ffffffffc020131e:	276d0d13          	addi	s10,s10,630 # ffffffffc02ac590 <npage>
    return KADDR(page2pa(page));
ffffffffc0201322:	00cddd93          	srli	s11,s11,0xc
ffffffffc0201326:	000ab717          	auipc	a4,0xab
ffffffffc020132a:	2c270713          	addi	a4,a4,706 # ffffffffc02ac5e8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc020132e:	000abe97          	auipc	t4,0xab
ffffffffc0201332:	2cae8e93          	addi	t4,t4,714 # ffffffffc02ac5f8 <pages>
        if (pde1&PTE_V){
ffffffffc0201336:	e79d                	bnez	a5,ffffffffc0201364 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0201338:	12098963          	beqz	s3,ffffffffc020146a <exit_range+0x1c2>
ffffffffc020133c:	400007b7          	lui	a5,0x40000
ffffffffc0201340:	84ce                	mv	s1,s3
ffffffffc0201342:	97ce                	add	a5,a5,s3
ffffffffc0201344:	1369f363          	bleu	s6,s3,ffffffffc020146a <exit_range+0x1c2>
ffffffffc0201348:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020134a:	00698933          	add	s2,s3,t1
ffffffffc020134e:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201352:	1ff97913          	andi	s2,s2,511
ffffffffc0201356:	090e                	slli	s2,s2,0x3
ffffffffc0201358:	9972                	add	s2,s2,t3
ffffffffc020135a:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc020135e:	001bf793          	andi	a5,s7,1
ffffffffc0201362:	dbf9                	beqz	a5,ffffffffc0201338 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201364:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201368:	0b8a                	slli	s7,s7,0x2
ffffffffc020136a:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc020136e:	14fbfc63          	bleu	a5,s7,ffffffffc02014c6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201372:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201376:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0201378:	000806b7          	lui	a3,0x80
ffffffffc020137c:	96d6                	add	a3,a3,s5
ffffffffc020137e:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0201382:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0201386:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201388:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020138a:	12f67263          	bleu	a5,a2,ffffffffc02014ae <exit_range+0x206>
ffffffffc020138e:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0201392:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0201394:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0201398:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020139a:	00080837          	lui	a6,0x80
ffffffffc020139e:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02013a0:	00200c37          	lui	s8,0x200
ffffffffc02013a4:	a801                	j	ffffffffc02013b4 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02013a6:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02013a8:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02013aa:	c0d9                	beqz	s1,ffffffffc0201430 <exit_range+0x188>
ffffffffc02013ac:	0934f263          	bleu	s3,s1,ffffffffc0201430 <exit_range+0x188>
ffffffffc02013b0:	0d64fc63          	bleu	s6,s1,ffffffffc0201488 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013b4:	0154d413          	srli	s0,s1,0x15
ffffffffc02013b8:	1ff47413          	andi	s0,s0,511
ffffffffc02013bc:	040e                	slli	s0,s0,0x3
ffffffffc02013be:	9452                	add	s0,s0,s4
ffffffffc02013c0:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02013c2:	0017f693          	andi	a3,a5,1
ffffffffc02013c6:	d2e5                	beqz	a3,ffffffffc02013a6 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02013c8:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013cc:	00279513          	slli	a0,a5,0x2
ffffffffc02013d0:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013d2:	0eb57a63          	bleu	a1,a0,ffffffffc02014c6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013d6:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02013d8:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02013dc:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02013e0:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013e2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013e4:	0cb7f563          	bleu	a1,a5,ffffffffc02014ae <exit_range+0x206>
ffffffffc02013e8:	631c                	ld	a5,0(a4)
ffffffffc02013ea:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013ec:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02013f0:	629c                	ld	a5,0(a3)
ffffffffc02013f2:	8b85                	andi	a5,a5,1
ffffffffc02013f4:	fbd5                	bnez	a5,ffffffffc02013a8 <exit_range+0x100>
ffffffffc02013f6:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013f8:	fed59ce3          	bne	a1,a3,ffffffffc02013f0 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02013fc:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0201400:	4585                	li	a1,1
ffffffffc0201402:	e072                	sd	t3,0(sp)
ffffffffc0201404:	953e                	add	a0,a0,a5
ffffffffc0201406:	ad1ff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
                d0start += PTSIZE;
ffffffffc020140a:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc020140c:	00043023          	sd	zero,0(s0)
ffffffffc0201410:	000abe97          	auipc	t4,0xab
ffffffffc0201414:	1e8e8e93          	addi	t4,t4,488 # ffffffffc02ac5f8 <pages>
ffffffffc0201418:	6e02                	ld	t3,0(sp)
ffffffffc020141a:	c0000337          	lui	t1,0xc0000
ffffffffc020141e:	fff808b7          	lui	a7,0xfff80
ffffffffc0201422:	00080837          	lui	a6,0x80
ffffffffc0201426:	000ab717          	auipc	a4,0xab
ffffffffc020142a:	1c270713          	addi	a4,a4,450 # ffffffffc02ac5e8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020142e:	fcbd                	bnez	s1,ffffffffc02013ac <exit_range+0x104>
            if (free_pd0) {
ffffffffc0201430:	f00c84e3          	beqz	s9,ffffffffc0201338 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201434:	000d3783          	ld	a5,0(s10)
ffffffffc0201438:	e072                	sd	t3,0(sp)
ffffffffc020143a:	08fbf663          	bleu	a5,s7,ffffffffc02014c6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020143e:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0201442:	67a2                	ld	a5,8(sp)
ffffffffc0201444:	4585                	li	a1,1
ffffffffc0201446:	953e                	add	a0,a0,a5
ffffffffc0201448:	a8fff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020144c:	00093023          	sd	zero,0(s2)
ffffffffc0201450:	000ab717          	auipc	a4,0xab
ffffffffc0201454:	19870713          	addi	a4,a4,408 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0201458:	c0000337          	lui	t1,0xc0000
ffffffffc020145c:	6e02                	ld	t3,0(sp)
ffffffffc020145e:	000abe97          	auipc	t4,0xab
ffffffffc0201462:	19ae8e93          	addi	t4,t4,410 # ffffffffc02ac5f8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0201466:	ec099be3          	bnez	s3,ffffffffc020133c <exit_range+0x94>
}
ffffffffc020146a:	70e6                	ld	ra,120(sp)
ffffffffc020146c:	7446                	ld	s0,112(sp)
ffffffffc020146e:	74a6                	ld	s1,104(sp)
ffffffffc0201470:	7906                	ld	s2,96(sp)
ffffffffc0201472:	69e6                	ld	s3,88(sp)
ffffffffc0201474:	6a46                	ld	s4,80(sp)
ffffffffc0201476:	6aa6                	ld	s5,72(sp)
ffffffffc0201478:	6b06                	ld	s6,64(sp)
ffffffffc020147a:	7be2                	ld	s7,56(sp)
ffffffffc020147c:	7c42                	ld	s8,48(sp)
ffffffffc020147e:	7ca2                	ld	s9,40(sp)
ffffffffc0201480:	7d02                	ld	s10,32(sp)
ffffffffc0201482:	6de2                	ld	s11,24(sp)
ffffffffc0201484:	6109                	addi	sp,sp,128
ffffffffc0201486:	8082                	ret
            if (free_pd0) {
ffffffffc0201488:	ea0c8ae3          	beqz	s9,ffffffffc020133c <exit_range+0x94>
ffffffffc020148c:	b765                	j	ffffffffc0201434 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020148e:	00006697          	auipc	a3,0x6
ffffffffc0201492:	f2268693          	addi	a3,a3,-222 # ffffffffc02073b0 <commands+0xe50>
ffffffffc0201496:	00005617          	auipc	a2,0x5
ffffffffc020149a:	54a60613          	addi	a2,a2,1354 # ffffffffc02069e0 <commands+0x480>
ffffffffc020149e:	12000593          	li	a1,288
ffffffffc02014a2:	00006517          	auipc	a0,0x6
ffffffffc02014a6:	96650513          	addi	a0,a0,-1690 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02014aa:	d6dfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc02014ae:	00006617          	auipc	a2,0x6
ffffffffc02014b2:	93260613          	addi	a2,a2,-1742 # ffffffffc0206de0 <commands+0x880>
ffffffffc02014b6:	06900593          	li	a1,105
ffffffffc02014ba:	00006517          	auipc	a0,0x6
ffffffffc02014be:	97e50513          	addi	a0,a0,-1666 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc02014c2:	d55fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014c6:	00006617          	auipc	a2,0x6
ffffffffc02014ca:	95260613          	addi	a2,a2,-1710 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc02014ce:	06200593          	li	a1,98
ffffffffc02014d2:	00006517          	auipc	a0,0x6
ffffffffc02014d6:	96650513          	addi	a0,a0,-1690 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc02014da:	d3dfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02014de:	00006697          	auipc	a3,0x6
ffffffffc02014e2:	f0268693          	addi	a3,a3,-254 # ffffffffc02073e0 <commands+0xe80>
ffffffffc02014e6:	00005617          	auipc	a2,0x5
ffffffffc02014ea:	4fa60613          	addi	a2,a2,1274 # ffffffffc02069e0 <commands+0x480>
ffffffffc02014ee:	12100593          	li	a1,289
ffffffffc02014f2:	00006517          	auipc	a0,0x6
ffffffffc02014f6:	91650513          	addi	a0,a0,-1770 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02014fa:	d1dfe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02014fe <copy_range>:
               bool share) {
ffffffffc02014fe:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201500:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0201504:	ec86                	sd	ra,88(sp)
ffffffffc0201506:	e8a2                	sd	s0,80(sp)
ffffffffc0201508:	e4a6                	sd	s1,72(sp)
ffffffffc020150a:	e0ca                	sd	s2,64(sp)
ffffffffc020150c:	fc4e                	sd	s3,56(sp)
ffffffffc020150e:	f852                	sd	s4,48(sp)
ffffffffc0201510:	f456                	sd	s5,40(sp)
ffffffffc0201512:	f05a                	sd	s6,32(sp)
ffffffffc0201514:	ec5e                	sd	s7,24(sp)
ffffffffc0201516:	e862                	sd	s8,16(sp)
ffffffffc0201518:	e466                	sd	s9,8(sp)
ffffffffc020151a:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020151c:	03479713          	slli	a4,a5,0x34
ffffffffc0201520:	14071863          	bnez	a4,ffffffffc0201670 <copy_range+0x172>
    assert(USER_ACCESS(start, end));
ffffffffc0201524:	002007b7          	lui	a5,0x200
ffffffffc0201528:	8432                	mv	s0,a2
ffffffffc020152a:	10f66763          	bltu	a2,a5,ffffffffc0201638 <copy_range+0x13a>
ffffffffc020152e:	84b6                	mv	s1,a3
ffffffffc0201530:	10d67463          	bleu	a3,a2,ffffffffc0201638 <copy_range+0x13a>
ffffffffc0201534:	4785                	li	a5,1
ffffffffc0201536:	07fe                	slli	a5,a5,0x1f
ffffffffc0201538:	10d7e063          	bltu	a5,a3,ffffffffc0201638 <copy_range+0x13a>
ffffffffc020153c:	8a2a                	mv	s4,a0
ffffffffc020153e:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc0201540:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201542:	000abb97          	auipc	s7,0xab
ffffffffc0201546:	04eb8b93          	addi	s7,s7,78 # ffffffffc02ac590 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020154a:	000abb17          	auipc	s6,0xab
ffffffffc020154e:	0aeb0b13          	addi	s6,s6,174 # ffffffffc02ac5f8 <pages>
ffffffffc0201552:	fff80ab7          	lui	s5,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201556:	00200cb7          	lui	s9,0x200
ffffffffc020155a:	ffe00c37          	lui	s8,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020155e:	4601                	li	a2,0
ffffffffc0201560:	85a2                	mv	a1,s0
ffffffffc0201562:	854a                	mv	a0,s2
ffffffffc0201564:	9f9ff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc0201568:	8d2a                	mv	s10,a0
        if (ptep == NULL) {
ffffffffc020156a:	c151                	beqz	a0,ffffffffc02015ee <copy_range+0xf0>
        if (*ptep & PTE_V) {
ffffffffc020156c:	611c                	ld	a5,0(a0)
ffffffffc020156e:	8b85                	andi	a5,a5,1
ffffffffc0201570:	e39d                	bnez	a5,ffffffffc0201596 <copy_range+0x98>
        start += PGSIZE;
ffffffffc0201572:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0201574:	fe9465e3          	bltu	s0,s1,ffffffffc020155e <copy_range+0x60>
    return 0;
ffffffffc0201578:	4501                	li	a0,0
}
ffffffffc020157a:	60e6                	ld	ra,88(sp)
ffffffffc020157c:	6446                	ld	s0,80(sp)
ffffffffc020157e:	64a6                	ld	s1,72(sp)
ffffffffc0201580:	6906                	ld	s2,64(sp)
ffffffffc0201582:	79e2                	ld	s3,56(sp)
ffffffffc0201584:	7a42                	ld	s4,48(sp)
ffffffffc0201586:	7aa2                	ld	s5,40(sp)
ffffffffc0201588:	7b02                	ld	s6,32(sp)
ffffffffc020158a:	6be2                	ld	s7,24(sp)
ffffffffc020158c:	6c42                	ld	s8,16(sp)
ffffffffc020158e:	6ca2                	ld	s9,8(sp)
ffffffffc0201590:	6d02                	ld	s10,0(sp)
ffffffffc0201592:	6125                	addi	sp,sp,96
ffffffffc0201594:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0201596:	4605                	li	a2,1
ffffffffc0201598:	85a2                	mv	a1,s0
ffffffffc020159a:	8552                	mv	a0,s4
ffffffffc020159c:	9c1ff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc02015a0:	cd31                	beqz	a0,ffffffffc02015fc <copy_range+0xfe>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02015a2:	000d3783          	ld	a5,0(s10)
    if (!(pte & PTE_V)) {
ffffffffc02015a6:	0017f713          	andi	a4,a5,1
ffffffffc02015aa:	c75d                	beqz	a4,ffffffffc0201658 <copy_range+0x15a>
    if (PPN(pa) >= npage) {
ffffffffc02015ac:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015b0:	078a                	slli	a5,a5,0x2
ffffffffc02015b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015b4:	06e7f663          	bleu	a4,a5,ffffffffc0201620 <copy_range+0x122>
    return &pages[PPN(pa) - nbase];
ffffffffc02015b8:	000b3d03          	ld	s10,0(s6)
ffffffffc02015bc:	97d6                	add	a5,a5,s5
ffffffffc02015be:	079a                	slli	a5,a5,0x6
ffffffffc02015c0:	9d3e                	add	s10,s10,a5
            struct Page *npage = alloc_page();
ffffffffc02015c2:	4505                	li	a0,1
ffffffffc02015c4:	88bff0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
            assert(page != NULL);
ffffffffc02015c8:	020d0c63          	beqz	s10,ffffffffc0201600 <copy_range+0x102>
            assert(npage != NULL);
ffffffffc02015cc:	f15d                	bnez	a0,ffffffffc0201572 <copy_range+0x74>
ffffffffc02015ce:	00006697          	auipc	a3,0x6
ffffffffc02015d2:	80268693          	addi	a3,a3,-2046 # ffffffffc0206dd0 <commands+0x870>
ffffffffc02015d6:	00005617          	auipc	a2,0x5
ffffffffc02015da:	40a60613          	addi	a2,a2,1034 # ffffffffc02069e0 <commands+0x480>
ffffffffc02015de:	17300593          	li	a1,371
ffffffffc02015e2:	00006517          	auipc	a0,0x6
ffffffffc02015e6:	82650513          	addi	a0,a0,-2010 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02015ea:	c2dfe0ef          	jal	ra,ffffffffc0200216 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02015ee:	9466                	add	s0,s0,s9
ffffffffc02015f0:	01847433          	and	s0,s0,s8
    } while (start != 0 && start < end);
ffffffffc02015f4:	d051                	beqz	s0,ffffffffc0201578 <copy_range+0x7a>
ffffffffc02015f6:	f69464e3          	bltu	s0,s1,ffffffffc020155e <copy_range+0x60>
ffffffffc02015fa:	bfbd                	j	ffffffffc0201578 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc02015fc:	5571                	li	a0,-4
ffffffffc02015fe:	bfb5                	j	ffffffffc020157a <copy_range+0x7c>
            assert(page != NULL);
ffffffffc0201600:	00005697          	auipc	a3,0x5
ffffffffc0201604:	7c068693          	addi	a3,a3,1984 # ffffffffc0206dc0 <commands+0x860>
ffffffffc0201608:	00005617          	auipc	a2,0x5
ffffffffc020160c:	3d860613          	addi	a2,a2,984 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201610:	17200593          	li	a1,370
ffffffffc0201614:	00005517          	auipc	a0,0x5
ffffffffc0201618:	7f450513          	addi	a0,a0,2036 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc020161c:	bfbfe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201620:	00005617          	auipc	a2,0x5
ffffffffc0201624:	7f860613          	addi	a2,a2,2040 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc0201628:	06200593          	li	a1,98
ffffffffc020162c:	00006517          	auipc	a0,0x6
ffffffffc0201630:	80c50513          	addi	a0,a0,-2036 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0201634:	be3fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0201638:	00006697          	auipc	a3,0x6
ffffffffc020163c:	da868693          	addi	a3,a3,-600 # ffffffffc02073e0 <commands+0xe80>
ffffffffc0201640:	00005617          	auipc	a2,0x5
ffffffffc0201644:	3a060613          	addi	a2,a2,928 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201648:	15e00593          	li	a1,350
ffffffffc020164c:	00005517          	auipc	a0,0x5
ffffffffc0201650:	7bc50513          	addi	a0,a0,1980 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201654:	bc3fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201658:	00005617          	auipc	a2,0x5
ffffffffc020165c:	74060613          	addi	a2,a2,1856 # ffffffffc0206d98 <commands+0x838>
ffffffffc0201660:	07400593          	li	a1,116
ffffffffc0201664:	00005517          	auipc	a0,0x5
ffffffffc0201668:	7d450513          	addi	a0,a0,2004 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc020166c:	babfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201670:	00006697          	auipc	a3,0x6
ffffffffc0201674:	d4068693          	addi	a3,a3,-704 # ffffffffc02073b0 <commands+0xe50>
ffffffffc0201678:	00005617          	auipc	a2,0x5
ffffffffc020167c:	36860613          	addi	a2,a2,872 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201680:	15d00593          	li	a1,349
ffffffffc0201684:	00005517          	auipc	a0,0x5
ffffffffc0201688:	78450513          	addi	a0,a0,1924 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc020168c:	b8bfe0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0201690 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201690:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201692:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201694:	e426                	sd	s1,8(sp)
ffffffffc0201696:	ec06                	sd	ra,24(sp)
ffffffffc0201698:	e822                	sd	s0,16(sp)
ffffffffc020169a:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020169c:	8c1ff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
    if (ptep != NULL) {
ffffffffc02016a0:	c511                	beqz	a0,ffffffffc02016ac <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02016a2:	611c                	ld	a5,0(a0)
ffffffffc02016a4:	842a                	mv	s0,a0
ffffffffc02016a6:	0017f713          	andi	a4,a5,1
ffffffffc02016aa:	e711                	bnez	a4,ffffffffc02016b6 <page_remove+0x26>
}
ffffffffc02016ac:	60e2                	ld	ra,24(sp)
ffffffffc02016ae:	6442                	ld	s0,16(sp)
ffffffffc02016b0:	64a2                	ld	s1,8(sp)
ffffffffc02016b2:	6105                	addi	sp,sp,32
ffffffffc02016b4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02016b6:	000ab717          	auipc	a4,0xab
ffffffffc02016ba:	eda70713          	addi	a4,a4,-294 # ffffffffc02ac590 <npage>
ffffffffc02016be:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02016c0:	078a                	slli	a5,a5,0x2
ffffffffc02016c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02016c4:	02e7fe63          	bleu	a4,a5,ffffffffc0201700 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc02016c8:	000ab717          	auipc	a4,0xab
ffffffffc02016cc:	f3070713          	addi	a4,a4,-208 # ffffffffc02ac5f8 <pages>
ffffffffc02016d0:	6308                	ld	a0,0(a4)
ffffffffc02016d2:	fff80737          	lui	a4,0xfff80
ffffffffc02016d6:	97ba                	add	a5,a5,a4
ffffffffc02016d8:	079a                	slli	a5,a5,0x6
ffffffffc02016da:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02016dc:	411c                	lw	a5,0(a0)
ffffffffc02016de:	fff7871b          	addiw	a4,a5,-1
ffffffffc02016e2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02016e4:	cb11                	beqz	a4,ffffffffc02016f8 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02016e6:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02016ea:	12048073          	sfence.vma	s1
}
ffffffffc02016ee:	60e2                	ld	ra,24(sp)
ffffffffc02016f0:	6442                	ld	s0,16(sp)
ffffffffc02016f2:	64a2                	ld	s1,8(sp)
ffffffffc02016f4:	6105                	addi	sp,sp,32
ffffffffc02016f6:	8082                	ret
            free_page(page);
ffffffffc02016f8:	4585                	li	a1,1
ffffffffc02016fa:	fdcff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
ffffffffc02016fe:	b7e5                	j	ffffffffc02016e6 <page_remove+0x56>
ffffffffc0201700:	f32ff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.4>

ffffffffc0201704 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201704:	7179                	addi	sp,sp,-48
ffffffffc0201706:	e44e                	sd	s3,8(sp)
ffffffffc0201708:	89b2                	mv	s3,a2
ffffffffc020170a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020170c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020170e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201710:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201712:	ec26                	sd	s1,24(sp)
ffffffffc0201714:	f406                	sd	ra,40(sp)
ffffffffc0201716:	e84a                	sd	s2,16(sp)
ffffffffc0201718:	e052                	sd	s4,0(sp)
ffffffffc020171a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020171c:	841ff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
    if (ptep == NULL) {
ffffffffc0201720:	cd49                	beqz	a0,ffffffffc02017ba <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201722:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201724:	611c                	ld	a5,0(a0)
ffffffffc0201726:	892a                	mv	s2,a0
ffffffffc0201728:	0016871b          	addiw	a4,a3,1
ffffffffc020172c:	c018                	sw	a4,0(s0)
ffffffffc020172e:	0017f713          	andi	a4,a5,1
ffffffffc0201732:	ef05                	bnez	a4,ffffffffc020176a <page_insert+0x66>
ffffffffc0201734:	000ab797          	auipc	a5,0xab
ffffffffc0201738:	ec478793          	addi	a5,a5,-316 # ffffffffc02ac5f8 <pages>
ffffffffc020173c:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc020173e:	8c19                	sub	s0,s0,a4
ffffffffc0201740:	000806b7          	lui	a3,0x80
ffffffffc0201744:	8419                	srai	s0,s0,0x6
ffffffffc0201746:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201748:	042a                	slli	s0,s0,0xa
ffffffffc020174a:	8c45                	or	s0,s0,s1
ffffffffc020174c:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201750:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201754:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201758:	4501                	li	a0,0
}
ffffffffc020175a:	70a2                	ld	ra,40(sp)
ffffffffc020175c:	7402                	ld	s0,32(sp)
ffffffffc020175e:	64e2                	ld	s1,24(sp)
ffffffffc0201760:	6942                	ld	s2,16(sp)
ffffffffc0201762:	69a2                	ld	s3,8(sp)
ffffffffc0201764:	6a02                	ld	s4,0(sp)
ffffffffc0201766:	6145                	addi	sp,sp,48
ffffffffc0201768:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020176a:	000ab717          	auipc	a4,0xab
ffffffffc020176e:	e2670713          	addi	a4,a4,-474 # ffffffffc02ac590 <npage>
ffffffffc0201772:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201774:	078a                	slli	a5,a5,0x2
ffffffffc0201776:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201778:	04e7f363          	bleu	a4,a5,ffffffffc02017be <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc020177c:	000aba17          	auipc	s4,0xab
ffffffffc0201780:	e7ca0a13          	addi	s4,s4,-388 # ffffffffc02ac5f8 <pages>
ffffffffc0201784:	000a3703          	ld	a4,0(s4)
ffffffffc0201788:	fff80537          	lui	a0,0xfff80
ffffffffc020178c:	953e                	add	a0,a0,a5
ffffffffc020178e:	051a                	slli	a0,a0,0x6
ffffffffc0201790:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201792:	00a40a63          	beq	s0,a0,ffffffffc02017a6 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201796:	411c                	lw	a5,0(a0)
ffffffffc0201798:	fff7869b          	addiw	a3,a5,-1
ffffffffc020179c:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc020179e:	c691                	beqz	a3,ffffffffc02017aa <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02017a0:	12098073          	sfence.vma	s3
ffffffffc02017a4:	bf69                	j	ffffffffc020173e <page_insert+0x3a>
ffffffffc02017a6:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02017a8:	bf59                	j	ffffffffc020173e <page_insert+0x3a>
            free_page(page);
ffffffffc02017aa:	4585                	li	a1,1
ffffffffc02017ac:	f2aff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
ffffffffc02017b0:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02017b4:	12098073          	sfence.vma	s3
ffffffffc02017b8:	b759                	j	ffffffffc020173e <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02017ba:	5571                	li	a0,-4
ffffffffc02017bc:	bf79                	j	ffffffffc020175a <page_insert+0x56>
ffffffffc02017be:	e74ff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.4>

ffffffffc02017c2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02017c2:	00007797          	auipc	a5,0x7
ffffffffc02017c6:	8de78793          	addi	a5,a5,-1826 # ffffffffc02080a0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017ca:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02017cc:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017ce:	00005517          	auipc	a0,0x5
ffffffffc02017d2:	69250513          	addi	a0,a0,1682 # ffffffffc0206e60 <commands+0x900>
void pmm_init(void) {
ffffffffc02017d6:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02017d8:	000ab717          	auipc	a4,0xab
ffffffffc02017dc:	e0f73423          	sd	a5,-504(a4) # ffffffffc02ac5e0 <pmm_manager>
void pmm_init(void) {
ffffffffc02017e0:	e0a2                	sd	s0,64(sp)
ffffffffc02017e2:	fc26                	sd	s1,56(sp)
ffffffffc02017e4:	f84a                	sd	s2,48(sp)
ffffffffc02017e6:	f44e                	sd	s3,40(sp)
ffffffffc02017e8:	f052                	sd	s4,32(sp)
ffffffffc02017ea:	ec56                	sd	s5,24(sp)
ffffffffc02017ec:	e85a                	sd	s6,16(sp)
ffffffffc02017ee:	e45e                	sd	s7,8(sp)
ffffffffc02017f0:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02017f2:	000ab417          	auipc	s0,0xab
ffffffffc02017f6:	dee40413          	addi	s0,s0,-530 # ffffffffc02ac5e0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02017fa:	8d7fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc02017fe:	601c                	ld	a5,0(s0)
ffffffffc0201800:	000ab497          	auipc	s1,0xab
ffffffffc0201804:	d9048493          	addi	s1,s1,-624 # ffffffffc02ac590 <npage>
ffffffffc0201808:	000ab917          	auipc	s2,0xab
ffffffffc020180c:	df090913          	addi	s2,s2,-528 # ffffffffc02ac5f8 <pages>
ffffffffc0201810:	679c                	ld	a5,8(a5)
ffffffffc0201812:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201814:	57f5                	li	a5,-3
ffffffffc0201816:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201818:	00005517          	auipc	a0,0x5
ffffffffc020181c:	66050513          	addi	a0,a0,1632 # ffffffffc0206e78 <commands+0x918>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201820:	000ab717          	auipc	a4,0xab
ffffffffc0201824:	dcf73423          	sd	a5,-568(a4) # ffffffffc02ac5e8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201828:	8a9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020182c:	46c5                	li	a3,17
ffffffffc020182e:	06ee                	slli	a3,a3,0x1b
ffffffffc0201830:	40100613          	li	a2,1025
ffffffffc0201834:	16fd                	addi	a3,a3,-1
ffffffffc0201836:	0656                	slli	a2,a2,0x15
ffffffffc0201838:	07e005b7          	lui	a1,0x7e00
ffffffffc020183c:	00005517          	auipc	a0,0x5
ffffffffc0201840:	65450513          	addi	a0,a0,1620 # ffffffffc0206e90 <commands+0x930>
ffffffffc0201844:	88dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201848:	777d                	lui	a4,0xfffff
ffffffffc020184a:	000ac797          	auipc	a5,0xac
ffffffffc020184e:	ebd78793          	addi	a5,a5,-323 # ffffffffc02ad707 <end+0xfff>
ffffffffc0201852:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201854:	00088737          	lui	a4,0x88
ffffffffc0201858:	000ab697          	auipc	a3,0xab
ffffffffc020185c:	d2e6bc23          	sd	a4,-712(a3) # ffffffffc02ac590 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201860:	000ab717          	auipc	a4,0xab
ffffffffc0201864:	d8f73c23          	sd	a5,-616(a4) # ffffffffc02ac5f8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201868:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020186a:	4685                	li	a3,1
ffffffffc020186c:	fff80837          	lui	a6,0xfff80
ffffffffc0201870:	a019                	j	ffffffffc0201876 <pmm_init+0xb4>
ffffffffc0201872:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201876:	00671613          	slli	a2,a4,0x6
ffffffffc020187a:	97b2                	add	a5,a5,a2
ffffffffc020187c:	07a1                	addi	a5,a5,8
ffffffffc020187e:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201882:	6090                	ld	a2,0(s1)
ffffffffc0201884:	0705                	addi	a4,a4,1
ffffffffc0201886:	010607b3          	add	a5,a2,a6
ffffffffc020188a:	fef764e3          	bltu	a4,a5,ffffffffc0201872 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020188e:	00093503          	ld	a0,0(s2)
ffffffffc0201892:	fe0007b7          	lui	a5,0xfe000
ffffffffc0201896:	00661693          	slli	a3,a2,0x6
ffffffffc020189a:	97aa                	add	a5,a5,a0
ffffffffc020189c:	96be                	add	a3,a3,a5
ffffffffc020189e:	c02007b7          	lui	a5,0xc0200
ffffffffc02018a2:	7af6ed63          	bltu	a3,a5,ffffffffc020205c <pmm_init+0x89a>
ffffffffc02018a6:	000ab997          	auipc	s3,0xab
ffffffffc02018aa:	d4298993          	addi	s3,s3,-702 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc02018ae:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02018b2:	47c5                	li	a5,17
ffffffffc02018b4:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02018b6:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02018b8:	02f6f763          	bleu	a5,a3,ffffffffc02018e6 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02018bc:	6585                	lui	a1,0x1
ffffffffc02018be:	15fd                	addi	a1,a1,-1
ffffffffc02018c0:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02018c2:	00c6d713          	srli	a4,a3,0xc
ffffffffc02018c6:	48c77a63          	bleu	a2,a4,ffffffffc0201d5a <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc02018ca:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02018cc:	75fd                	lui	a1,0xfffff
ffffffffc02018ce:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02018d0:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc02018d2:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02018d4:	40d786b3          	sub	a3,a5,a3
ffffffffc02018d8:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02018da:	00c6d593          	srli	a1,a3,0xc
ffffffffc02018de:	953a                	add	a0,a0,a4
ffffffffc02018e0:	9602                	jalr	a2
ffffffffc02018e2:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02018e6:	00005517          	auipc	a0,0x5
ffffffffc02018ea:	5fa50513          	addi	a0,a0,1530 # ffffffffc0206ee0 <commands+0x980>
ffffffffc02018ee:	fe2fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02018f2:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02018f4:	000ab417          	auipc	s0,0xab
ffffffffc02018f8:	c9440413          	addi	s0,s0,-876 # ffffffffc02ac588 <boot_pgdir>
    pmm_manager->check();
ffffffffc02018fc:	7b9c                	ld	a5,48(a5)
ffffffffc02018fe:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201900:	00005517          	auipc	a0,0x5
ffffffffc0201904:	5f850513          	addi	a0,a0,1528 # ffffffffc0206ef8 <commands+0x998>
ffffffffc0201908:	fc8fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020190c:	00009697          	auipc	a3,0x9
ffffffffc0201910:	6f468693          	addi	a3,a3,1780 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0201914:	000ab797          	auipc	a5,0xab
ffffffffc0201918:	c6d7ba23          	sd	a3,-908(a5) # ffffffffc02ac588 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020191c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201920:	10f6eae3          	bltu	a3,a5,ffffffffc0202234 <pmm_init+0xa72>
ffffffffc0201924:	0009b783          	ld	a5,0(s3)
ffffffffc0201928:	8e9d                	sub	a3,a3,a5
ffffffffc020192a:	000ab797          	auipc	a5,0xab
ffffffffc020192e:	ccd7b323          	sd	a3,-826(a5) # ffffffffc02ac5f0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201932:	deaff0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201936:	6098                	ld	a4,0(s1)
ffffffffc0201938:	c80007b7          	lui	a5,0xc8000
ffffffffc020193c:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020193e:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201940:	0ce7eae3          	bltu	a5,a4,ffffffffc0202214 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201944:	6008                	ld	a0,0(s0)
ffffffffc0201946:	44050463          	beqz	a0,ffffffffc0201d8e <pmm_init+0x5cc>
ffffffffc020194a:	6785                	lui	a5,0x1
ffffffffc020194c:	17fd                	addi	a5,a5,-1
ffffffffc020194e:	8fe9                	and	a5,a5,a0
ffffffffc0201950:	2781                	sext.w	a5,a5
ffffffffc0201952:	42079e63          	bnez	a5,ffffffffc0201d8e <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201956:	4601                	li	a2,0
ffffffffc0201958:	4581                	li	a1,0
ffffffffc020195a:	fd4ff0ef          	jal	ra,ffffffffc020112e <get_page>
ffffffffc020195e:	78051b63          	bnez	a0,ffffffffc02020f4 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201962:	4505                	li	a0,1
ffffffffc0201964:	ceaff0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0201968:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020196a:	6008                	ld	a0,0(s0)
ffffffffc020196c:	4681                	li	a3,0
ffffffffc020196e:	4601                	li	a2,0
ffffffffc0201970:	85d6                	mv	a1,s5
ffffffffc0201972:	d93ff0ef          	jal	ra,ffffffffc0201704 <page_insert>
ffffffffc0201976:	7a051f63          	bnez	a0,ffffffffc0202134 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020197a:	6008                	ld	a0,0(s0)
ffffffffc020197c:	4601                	li	a2,0
ffffffffc020197e:	4581                	li	a1,0
ffffffffc0201980:	ddcff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc0201984:	78050863          	beqz	a0,ffffffffc0202114 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0201988:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020198a:	0017f713          	andi	a4,a5,1
ffffffffc020198e:	3e070463          	beqz	a4,ffffffffc0201d76 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0201992:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201994:	078a                	slli	a5,a5,0x2
ffffffffc0201996:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201998:	3ce7f163          	bleu	a4,a5,ffffffffc0201d5a <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020199c:	00093683          	ld	a3,0(s2)
ffffffffc02019a0:	fff80637          	lui	a2,0xfff80
ffffffffc02019a4:	97b2                	add	a5,a5,a2
ffffffffc02019a6:	079a                	slli	a5,a5,0x6
ffffffffc02019a8:	97b6                	add	a5,a5,a3
ffffffffc02019aa:	72fa9563          	bne	s5,a5,ffffffffc02020d4 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc02019ae:	000aab83          	lw	s7,0(s5) # fffffffffff80000 <end+0x3fcd38f8>
ffffffffc02019b2:	4785                	li	a5,1
ffffffffc02019b4:	70fb9063          	bne	s7,a5,ffffffffc02020b4 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02019b8:	6008                	ld	a0,0(s0)
ffffffffc02019ba:	76fd                	lui	a3,0xfffff
ffffffffc02019bc:	611c                	ld	a5,0(a0)
ffffffffc02019be:	078a                	slli	a5,a5,0x2
ffffffffc02019c0:	8ff5                	and	a5,a5,a3
ffffffffc02019c2:	00c7d613          	srli	a2,a5,0xc
ffffffffc02019c6:	66e67e63          	bleu	a4,a2,ffffffffc0202042 <pmm_init+0x880>
ffffffffc02019ca:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02019ce:	97e2                	add	a5,a5,s8
ffffffffc02019d0:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8588>
ffffffffc02019d4:	0b0a                	slli	s6,s6,0x2
ffffffffc02019d6:	00db7b33          	and	s6,s6,a3
ffffffffc02019da:	00cb5793          	srli	a5,s6,0xc
ffffffffc02019de:	56e7f863          	bleu	a4,a5,ffffffffc0201f4e <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02019e2:	4601                	li	a2,0
ffffffffc02019e4:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02019e6:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02019e8:	d74ff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02019ec:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02019ee:	55651063          	bne	a0,s6,ffffffffc0201f2e <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc02019f2:	4505                	li	a0,1
ffffffffc02019f4:	c5aff0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc02019f8:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02019fa:	6008                	ld	a0,0(s0)
ffffffffc02019fc:	46d1                	li	a3,20
ffffffffc02019fe:	6605                	lui	a2,0x1
ffffffffc0201a00:	85da                	mv	a1,s6
ffffffffc0201a02:	d03ff0ef          	jal	ra,ffffffffc0201704 <page_insert>
ffffffffc0201a06:	50051463          	bnez	a0,ffffffffc0201f0e <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201a0a:	6008                	ld	a0,0(s0)
ffffffffc0201a0c:	4601                	li	a2,0
ffffffffc0201a0e:	6585                	lui	a1,0x1
ffffffffc0201a10:	d4cff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc0201a14:	4c050d63          	beqz	a0,ffffffffc0201eee <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0201a18:	611c                	ld	a5,0(a0)
ffffffffc0201a1a:	0107f713          	andi	a4,a5,16
ffffffffc0201a1e:	4a070863          	beqz	a4,ffffffffc0201ece <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0201a22:	8b91                	andi	a5,a5,4
ffffffffc0201a24:	48078563          	beqz	a5,ffffffffc0201eae <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201a28:	6008                	ld	a0,0(s0)
ffffffffc0201a2a:	611c                	ld	a5,0(a0)
ffffffffc0201a2c:	8bc1                	andi	a5,a5,16
ffffffffc0201a2e:	46078063          	beqz	a5,ffffffffc0201e8e <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0201a32:	000b2783          	lw	a5,0(s6)
ffffffffc0201a36:	43779c63          	bne	a5,s7,ffffffffc0201e6e <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201a3a:	4681                	li	a3,0
ffffffffc0201a3c:	6605                	lui	a2,0x1
ffffffffc0201a3e:	85d6                	mv	a1,s5
ffffffffc0201a40:	cc5ff0ef          	jal	ra,ffffffffc0201704 <page_insert>
ffffffffc0201a44:	40051563          	bnez	a0,ffffffffc0201e4e <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0201a48:	000aa703          	lw	a4,0(s5)
ffffffffc0201a4c:	4789                	li	a5,2
ffffffffc0201a4e:	3ef71063          	bne	a4,a5,ffffffffc0201e2e <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0201a52:	000b2783          	lw	a5,0(s6)
ffffffffc0201a56:	3a079c63          	bnez	a5,ffffffffc0201e0e <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201a5a:	6008                	ld	a0,0(s0)
ffffffffc0201a5c:	4601                	li	a2,0
ffffffffc0201a5e:	6585                	lui	a1,0x1
ffffffffc0201a60:	cfcff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc0201a64:	38050563          	beqz	a0,ffffffffc0201dee <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc0201a68:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201a6a:	00177793          	andi	a5,a4,1
ffffffffc0201a6e:	30078463          	beqz	a5,ffffffffc0201d76 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0201a72:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a74:	00271793          	slli	a5,a4,0x2
ffffffffc0201a78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a7a:	2ed7f063          	bleu	a3,a5,ffffffffc0201d5a <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a7e:	00093683          	ld	a3,0(s2)
ffffffffc0201a82:	fff80637          	lui	a2,0xfff80
ffffffffc0201a86:	97b2                	add	a5,a5,a2
ffffffffc0201a88:	079a                	slli	a5,a5,0x6
ffffffffc0201a8a:	97b6                	add	a5,a5,a3
ffffffffc0201a8c:	32fa9163          	bne	s5,a5,ffffffffc0201dae <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201a90:	8b41                	andi	a4,a4,16
ffffffffc0201a92:	70071163          	bnez	a4,ffffffffc0202194 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201a96:	6008                	ld	a0,0(s0)
ffffffffc0201a98:	4581                	li	a1,0
ffffffffc0201a9a:	bf7ff0ef          	jal	ra,ffffffffc0201690 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201a9e:	000aa703          	lw	a4,0(s5)
ffffffffc0201aa2:	4785                	li	a5,1
ffffffffc0201aa4:	6cf71863          	bne	a4,a5,ffffffffc0202174 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0201aa8:	000b2783          	lw	a5,0(s6)
ffffffffc0201aac:	6a079463          	bnez	a5,ffffffffc0202154 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201ab0:	6008                	ld	a0,0(s0)
ffffffffc0201ab2:	6585                	lui	a1,0x1
ffffffffc0201ab4:	bddff0ef          	jal	ra,ffffffffc0201690 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201ab8:	000aa783          	lw	a5,0(s5)
ffffffffc0201abc:	50079363          	bnez	a5,ffffffffc0201fc2 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0201ac0:	000b2783          	lw	a5,0(s6)
ffffffffc0201ac4:	4c079f63          	bnez	a5,ffffffffc0201fa2 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201ac8:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201acc:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ace:	000ab783          	ld	a5,0(s5)
ffffffffc0201ad2:	078a                	slli	a5,a5,0x2
ffffffffc0201ad4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ad6:	28c7f263          	bleu	a2,a5,ffffffffc0201d5a <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ada:	fff80737          	lui	a4,0xfff80
ffffffffc0201ade:	00093503          	ld	a0,0(s2)
ffffffffc0201ae2:	97ba                	add	a5,a5,a4
ffffffffc0201ae4:	079a                	slli	a5,a5,0x6
ffffffffc0201ae6:	00f50733          	add	a4,a0,a5
ffffffffc0201aea:	4314                	lw	a3,0(a4)
ffffffffc0201aec:	4705                	li	a4,1
ffffffffc0201aee:	48e69a63          	bne	a3,a4,ffffffffc0201f82 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0201af2:	8799                	srai	a5,a5,0x6
ffffffffc0201af4:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0201af8:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0201afa:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0201afc:	8331                	srli	a4,a4,0xc
ffffffffc0201afe:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b00:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201b02:	46c77363          	bleu	a2,a4,ffffffffc0201f68 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201b06:	0009b683          	ld	a3,0(s3)
ffffffffc0201b0a:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b0c:	639c                	ld	a5,0(a5)
ffffffffc0201b0e:	078a                	slli	a5,a5,0x2
ffffffffc0201b10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b12:	24c7f463          	bleu	a2,a5,ffffffffc0201d5a <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b16:	416787b3          	sub	a5,a5,s6
ffffffffc0201b1a:	079a                	slli	a5,a5,0x6
ffffffffc0201b1c:	953e                	add	a0,a0,a5
ffffffffc0201b1e:	4585                	li	a1,1
ffffffffc0201b20:	bb6ff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b24:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0201b28:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b2a:	078a                	slli	a5,a5,0x2
ffffffffc0201b2c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b2e:	22e7f663          	bleu	a4,a5,ffffffffc0201d5a <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b32:	00093503          	ld	a0,0(s2)
ffffffffc0201b36:	416787b3          	sub	a5,a5,s6
ffffffffc0201b3a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201b3c:	953e                	add	a0,a0,a5
ffffffffc0201b3e:	4585                	li	a1,1
ffffffffc0201b40:	b96ff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201b44:	601c                	ld	a5,0(s0)
ffffffffc0201b46:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201b4a:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201b4e:	bceff0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>
ffffffffc0201b52:	68aa1163          	bne	s4,a0,ffffffffc02021d4 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201b56:	00005517          	auipc	a0,0x5
ffffffffc0201b5a:	68a50513          	addi	a0,a0,1674 # ffffffffc02071e0 <commands+0xc80>
ffffffffc0201b5e:	d72fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201b62:	bbaff0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201b66:	6098                	ld	a4,0(s1)
ffffffffc0201b68:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201b6c:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201b6e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201b72:	18d7f563          	bleu	a3,a5,ffffffffc0201cfc <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b76:	83b1                	srli	a5,a5,0xc
ffffffffc0201b78:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201b7a:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b7e:	1ae7f163          	bleu	a4,a5,ffffffffc0201d20 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201b82:	7bfd                	lui	s7,0xfffff
ffffffffc0201b84:	6b05                	lui	s6,0x1
ffffffffc0201b86:	a029                	j	ffffffffc0201b90 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b88:	00cad713          	srli	a4,s5,0xc
ffffffffc0201b8c:	18f77a63          	bleu	a5,a4,ffffffffc0201d20 <pmm_init+0x55e>
ffffffffc0201b90:	0009b583          	ld	a1,0(s3)
ffffffffc0201b94:	4601                	li	a2,0
ffffffffc0201b96:	95d6                	add	a1,a1,s5
ffffffffc0201b98:	bc4ff0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc0201b9c:	16050263          	beqz	a0,ffffffffc0201d00 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ba0:	611c                	ld	a5,0(a0)
ffffffffc0201ba2:	078a                	slli	a5,a5,0x2
ffffffffc0201ba4:	0177f7b3          	and	a5,a5,s7
ffffffffc0201ba8:	19579963          	bne	a5,s5,ffffffffc0201d3a <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201bac:	609c                	ld	a5,0(s1)
ffffffffc0201bae:	9ada                	add	s5,s5,s6
ffffffffc0201bb0:	6008                	ld	a0,0(s0)
ffffffffc0201bb2:	00c79713          	slli	a4,a5,0xc
ffffffffc0201bb6:	fceae9e3          	bltu	s5,a4,ffffffffc0201b88 <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201bba:	611c                	ld	a5,0(a0)
ffffffffc0201bbc:	62079c63          	bnez	a5,ffffffffc02021f4 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0201bc0:	4505                	li	a0,1
ffffffffc0201bc2:	a8cff0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0201bc6:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201bc8:	6008                	ld	a0,0(s0)
ffffffffc0201bca:	4699                	li	a3,6
ffffffffc0201bcc:	10000613          	li	a2,256
ffffffffc0201bd0:	85d6                	mv	a1,s5
ffffffffc0201bd2:	b33ff0ef          	jal	ra,ffffffffc0201704 <page_insert>
ffffffffc0201bd6:	1e051c63          	bnez	a0,ffffffffc0201dce <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0201bda:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201bde:	4785                	li	a5,1
ffffffffc0201be0:	44f71163          	bne	a4,a5,ffffffffc0202022 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201be4:	6008                	ld	a0,0(s0)
ffffffffc0201be6:	6b05                	lui	s6,0x1
ffffffffc0201be8:	4699                	li	a3,6
ffffffffc0201bea:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8488>
ffffffffc0201bee:	85d6                	mv	a1,s5
ffffffffc0201bf0:	b15ff0ef          	jal	ra,ffffffffc0201704 <page_insert>
ffffffffc0201bf4:	40051763          	bnez	a0,ffffffffc0202002 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0201bf8:	000aa703          	lw	a4,0(s5)
ffffffffc0201bfc:	4789                	li	a5,2
ffffffffc0201bfe:	3ef71263          	bne	a4,a5,ffffffffc0201fe2 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201c02:	00005597          	auipc	a1,0x5
ffffffffc0201c06:	71658593          	addi	a1,a1,1814 # ffffffffc0207318 <commands+0xdb8>
ffffffffc0201c0a:	10000513          	li	a0,256
ffffffffc0201c0e:	34c040ef          	jal	ra,ffffffffc0205f5a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201c12:	100b0593          	addi	a1,s6,256
ffffffffc0201c16:	10000513          	li	a0,256
ffffffffc0201c1a:	352040ef          	jal	ra,ffffffffc0205f6c <strcmp>
ffffffffc0201c1e:	44051b63          	bnez	a0,ffffffffc0202074 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0201c22:	00093683          	ld	a3,0(s2)
ffffffffc0201c26:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201c2a:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201c2c:	40da86b3          	sub	a3,s5,a3
ffffffffc0201c30:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201c32:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201c34:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201c36:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201c3a:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c3e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201c40:	10f77f63          	bleu	a5,a4,ffffffffc0201d5e <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201c44:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201c48:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201c4c:	96be                	add	a3,a3,a5
ffffffffc0201c4e:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd529f8>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201c52:	2c4040ef          	jal	ra,ffffffffc0205f16 <strlen>
ffffffffc0201c56:	54051f63          	bnez	a0,ffffffffc02021b4 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201c5a:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201c5e:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c60:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd528f8>
ffffffffc0201c64:	068a                	slli	a3,a3,0x2
ffffffffc0201c66:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c68:	0ef6f963          	bleu	a5,a3,ffffffffc0201d5a <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0201c6c:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c70:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201c72:	0efb7663          	bleu	a5,s6,ffffffffc0201d5e <pmm_init+0x59c>
ffffffffc0201c76:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201c7a:	4585                	li	a1,1
ffffffffc0201c7c:	8556                	mv	a0,s5
ffffffffc0201c7e:	99b6                	add	s3,s3,a3
ffffffffc0201c80:	a56ff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c84:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201c88:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c8a:	078a                	slli	a5,a5,0x2
ffffffffc0201c8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201c8e:	0ce7f663          	bleu	a4,a5,ffffffffc0201d5a <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c92:	00093503          	ld	a0,0(s2)
ffffffffc0201c96:	fff809b7          	lui	s3,0xfff80
ffffffffc0201c9a:	97ce                	add	a5,a5,s3
ffffffffc0201c9c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201c9e:	953e                	add	a0,a0,a5
ffffffffc0201ca0:	4585                	li	a1,1
ffffffffc0201ca2:	a34ff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ca6:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201caa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201cac:	078a                	slli	a5,a5,0x2
ffffffffc0201cae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cb0:	0ae7f563          	bleu	a4,a5,ffffffffc0201d5a <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cb4:	00093503          	ld	a0,0(s2)
ffffffffc0201cb8:	97ce                	add	a5,a5,s3
ffffffffc0201cba:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201cbc:	953e                	add	a0,a0,a5
ffffffffc0201cbe:	4585                	li	a1,1
ffffffffc0201cc0:	a16ff0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201cc4:	601c                	ld	a5,0(s0)
ffffffffc0201cc6:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201cca:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201cce:	a4eff0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>
ffffffffc0201cd2:	3caa1163          	bne	s4,a0,ffffffffc0202094 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201cd6:	00005517          	auipc	a0,0x5
ffffffffc0201cda:	6ba50513          	addi	a0,a0,1722 # ffffffffc0207390 <commands+0xe30>
ffffffffc0201cde:	bf2fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201ce2:	6406                	ld	s0,64(sp)
ffffffffc0201ce4:	60a6                	ld	ra,72(sp)
ffffffffc0201ce6:	74e2                	ld	s1,56(sp)
ffffffffc0201ce8:	7942                	ld	s2,48(sp)
ffffffffc0201cea:	79a2                	ld	s3,40(sp)
ffffffffc0201cec:	7a02                	ld	s4,32(sp)
ffffffffc0201cee:	6ae2                	ld	s5,24(sp)
ffffffffc0201cf0:	6b42                	ld	s6,16(sp)
ffffffffc0201cf2:	6ba2                	ld	s7,8(sp)
ffffffffc0201cf4:	6c02                	ld	s8,0(sp)
ffffffffc0201cf6:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201cf8:	6c00106f          	j	ffffffffc02033b8 <kmalloc_init>
ffffffffc0201cfc:	6008                	ld	a0,0(s0)
ffffffffc0201cfe:	bd75                	j	ffffffffc0201bba <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201d00:	00005697          	auipc	a3,0x5
ffffffffc0201d04:	50068693          	addi	a3,a3,1280 # ffffffffc0207200 <commands+0xca0>
ffffffffc0201d08:	00005617          	auipc	a2,0x5
ffffffffc0201d0c:	cd860613          	addi	a2,a2,-808 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201d10:	22400593          	li	a1,548
ffffffffc0201d14:	00005517          	auipc	a0,0x5
ffffffffc0201d18:	0f450513          	addi	a0,a0,244 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201d1c:	cfafe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201d20:	86d6                	mv	a3,s5
ffffffffc0201d22:	00005617          	auipc	a2,0x5
ffffffffc0201d26:	0be60613          	addi	a2,a2,190 # ffffffffc0206de0 <commands+0x880>
ffffffffc0201d2a:	22400593          	li	a1,548
ffffffffc0201d2e:	00005517          	auipc	a0,0x5
ffffffffc0201d32:	0da50513          	addi	a0,a0,218 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201d36:	ce0fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201d3a:	00005697          	auipc	a3,0x5
ffffffffc0201d3e:	50668693          	addi	a3,a3,1286 # ffffffffc0207240 <commands+0xce0>
ffffffffc0201d42:	00005617          	auipc	a2,0x5
ffffffffc0201d46:	c9e60613          	addi	a2,a2,-866 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201d4a:	22500593          	li	a1,549
ffffffffc0201d4e:	00005517          	auipc	a0,0x5
ffffffffc0201d52:	0ba50513          	addi	a0,a0,186 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201d56:	cc0fe0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0201d5a:	8d8ff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201d5e:	00005617          	auipc	a2,0x5
ffffffffc0201d62:	08260613          	addi	a2,a2,130 # ffffffffc0206de0 <commands+0x880>
ffffffffc0201d66:	06900593          	li	a1,105
ffffffffc0201d6a:	00005517          	auipc	a0,0x5
ffffffffc0201d6e:	0ce50513          	addi	a0,a0,206 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0201d72:	ca4fe0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201d76:	00005617          	auipc	a2,0x5
ffffffffc0201d7a:	02260613          	addi	a2,a2,34 # ffffffffc0206d98 <commands+0x838>
ffffffffc0201d7e:	07400593          	li	a1,116
ffffffffc0201d82:	00005517          	auipc	a0,0x5
ffffffffc0201d86:	0b650513          	addi	a0,a0,182 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0201d8a:	c8cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201d8e:	00005697          	auipc	a3,0x5
ffffffffc0201d92:	1aa68693          	addi	a3,a3,426 # ffffffffc0206f38 <commands+0x9d8>
ffffffffc0201d96:	00005617          	auipc	a2,0x5
ffffffffc0201d9a:	c4a60613          	addi	a2,a2,-950 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201d9e:	1e800593          	li	a1,488
ffffffffc0201da2:	00005517          	auipc	a0,0x5
ffffffffc0201da6:	06650513          	addi	a0,a0,102 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201daa:	c6cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201dae:	00005697          	auipc	a3,0x5
ffffffffc0201db2:	24a68693          	addi	a3,a3,586 # ffffffffc0206ff8 <commands+0xa98>
ffffffffc0201db6:	00005617          	auipc	a2,0x5
ffffffffc0201dba:	c2a60613          	addi	a2,a2,-982 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201dbe:	20400593          	li	a1,516
ffffffffc0201dc2:	00005517          	auipc	a0,0x5
ffffffffc0201dc6:	04650513          	addi	a0,a0,70 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201dca:	c4cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201dce:	00005697          	auipc	a3,0x5
ffffffffc0201dd2:	4a268693          	addi	a3,a3,1186 # ffffffffc0207270 <commands+0xd10>
ffffffffc0201dd6:	00005617          	auipc	a2,0x5
ffffffffc0201dda:	c0a60613          	addi	a2,a2,-1014 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201dde:	22d00593          	li	a1,557
ffffffffc0201de2:	00005517          	auipc	a0,0x5
ffffffffc0201de6:	02650513          	addi	a0,a0,38 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201dea:	c2cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201dee:	00005697          	auipc	a3,0x5
ffffffffc0201df2:	29a68693          	addi	a3,a3,666 # ffffffffc0207088 <commands+0xb28>
ffffffffc0201df6:	00005617          	auipc	a2,0x5
ffffffffc0201dfa:	bea60613          	addi	a2,a2,-1046 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201dfe:	20300593          	li	a1,515
ffffffffc0201e02:	00005517          	auipc	a0,0x5
ffffffffc0201e06:	00650513          	addi	a0,a0,6 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201e0a:	c0cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201e0e:	00005697          	auipc	a3,0x5
ffffffffc0201e12:	34268693          	addi	a3,a3,834 # ffffffffc0207150 <commands+0xbf0>
ffffffffc0201e16:	00005617          	auipc	a2,0x5
ffffffffc0201e1a:	bca60613          	addi	a2,a2,-1078 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201e1e:	20200593          	li	a1,514
ffffffffc0201e22:	00005517          	auipc	a0,0x5
ffffffffc0201e26:	fe650513          	addi	a0,a0,-26 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201e2a:	becfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201e2e:	00005697          	auipc	a3,0x5
ffffffffc0201e32:	30a68693          	addi	a3,a3,778 # ffffffffc0207138 <commands+0xbd8>
ffffffffc0201e36:	00005617          	auipc	a2,0x5
ffffffffc0201e3a:	baa60613          	addi	a2,a2,-1110 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201e3e:	20100593          	li	a1,513
ffffffffc0201e42:	00005517          	auipc	a0,0x5
ffffffffc0201e46:	fc650513          	addi	a0,a0,-58 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201e4a:	bccfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201e4e:	00005697          	auipc	a3,0x5
ffffffffc0201e52:	2ba68693          	addi	a3,a3,698 # ffffffffc0207108 <commands+0xba8>
ffffffffc0201e56:	00005617          	auipc	a2,0x5
ffffffffc0201e5a:	b8a60613          	addi	a2,a2,-1142 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201e5e:	20000593          	li	a1,512
ffffffffc0201e62:	00005517          	auipc	a0,0x5
ffffffffc0201e66:	fa650513          	addi	a0,a0,-90 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201e6a:	bacfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201e6e:	00005697          	auipc	a3,0x5
ffffffffc0201e72:	28268693          	addi	a3,a3,642 # ffffffffc02070f0 <commands+0xb90>
ffffffffc0201e76:	00005617          	auipc	a2,0x5
ffffffffc0201e7a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201e7e:	1fe00593          	li	a1,510
ffffffffc0201e82:	00005517          	auipc	a0,0x5
ffffffffc0201e86:	f8650513          	addi	a0,a0,-122 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201e8a:	b8cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201e8e:	00005697          	auipc	a3,0x5
ffffffffc0201e92:	24a68693          	addi	a3,a3,586 # ffffffffc02070d8 <commands+0xb78>
ffffffffc0201e96:	00005617          	auipc	a2,0x5
ffffffffc0201e9a:	b4a60613          	addi	a2,a2,-1206 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201e9e:	1fd00593          	li	a1,509
ffffffffc0201ea2:	00005517          	auipc	a0,0x5
ffffffffc0201ea6:	f6650513          	addi	a0,a0,-154 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201eaa:	b6cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201eae:	00005697          	auipc	a3,0x5
ffffffffc0201eb2:	21a68693          	addi	a3,a3,538 # ffffffffc02070c8 <commands+0xb68>
ffffffffc0201eb6:	00005617          	auipc	a2,0x5
ffffffffc0201eba:	b2a60613          	addi	a2,a2,-1238 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201ebe:	1fc00593          	li	a1,508
ffffffffc0201ec2:	00005517          	auipc	a0,0x5
ffffffffc0201ec6:	f4650513          	addi	a0,a0,-186 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201eca:	b4cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201ece:	00005697          	auipc	a3,0x5
ffffffffc0201ed2:	1ea68693          	addi	a3,a3,490 # ffffffffc02070b8 <commands+0xb58>
ffffffffc0201ed6:	00005617          	auipc	a2,0x5
ffffffffc0201eda:	b0a60613          	addi	a2,a2,-1270 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201ede:	1fb00593          	li	a1,507
ffffffffc0201ee2:	00005517          	auipc	a0,0x5
ffffffffc0201ee6:	f2650513          	addi	a0,a0,-218 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201eea:	b2cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201eee:	00005697          	auipc	a3,0x5
ffffffffc0201ef2:	19a68693          	addi	a3,a3,410 # ffffffffc0207088 <commands+0xb28>
ffffffffc0201ef6:	00005617          	auipc	a2,0x5
ffffffffc0201efa:	aea60613          	addi	a2,a2,-1302 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201efe:	1fa00593          	li	a1,506
ffffffffc0201f02:	00005517          	auipc	a0,0x5
ffffffffc0201f06:	f0650513          	addi	a0,a0,-250 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201f0a:	b0cfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201f0e:	00005697          	auipc	a3,0x5
ffffffffc0201f12:	14268693          	addi	a3,a3,322 # ffffffffc0207050 <commands+0xaf0>
ffffffffc0201f16:	00005617          	auipc	a2,0x5
ffffffffc0201f1a:	aca60613          	addi	a2,a2,-1334 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201f1e:	1f900593          	li	a1,505
ffffffffc0201f22:	00005517          	auipc	a0,0x5
ffffffffc0201f26:	ee650513          	addi	a0,a0,-282 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201f2a:	aecfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201f2e:	00005697          	auipc	a3,0x5
ffffffffc0201f32:	0fa68693          	addi	a3,a3,250 # ffffffffc0207028 <commands+0xac8>
ffffffffc0201f36:	00005617          	auipc	a2,0x5
ffffffffc0201f3a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201f3e:	1f600593          	li	a1,502
ffffffffc0201f42:	00005517          	auipc	a0,0x5
ffffffffc0201f46:	ec650513          	addi	a0,a0,-314 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201f4a:	accfe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201f4e:	86da                	mv	a3,s6
ffffffffc0201f50:	00005617          	auipc	a2,0x5
ffffffffc0201f54:	e9060613          	addi	a2,a2,-368 # ffffffffc0206de0 <commands+0x880>
ffffffffc0201f58:	1f500593          	li	a1,501
ffffffffc0201f5c:	00005517          	auipc	a0,0x5
ffffffffc0201f60:	eac50513          	addi	a0,a0,-340 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201f64:	ab2fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201f68:	86be                	mv	a3,a5
ffffffffc0201f6a:	00005617          	auipc	a2,0x5
ffffffffc0201f6e:	e7660613          	addi	a2,a2,-394 # ffffffffc0206de0 <commands+0x880>
ffffffffc0201f72:	06900593          	li	a1,105
ffffffffc0201f76:	00005517          	auipc	a0,0x5
ffffffffc0201f7a:	ec250513          	addi	a0,a0,-318 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0201f7e:	a98fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201f82:	00005697          	auipc	a3,0x5
ffffffffc0201f86:	21668693          	addi	a3,a3,534 # ffffffffc0207198 <commands+0xc38>
ffffffffc0201f8a:	00005617          	auipc	a2,0x5
ffffffffc0201f8e:	a5660613          	addi	a2,a2,-1450 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201f92:	20f00593          	li	a1,527
ffffffffc0201f96:	00005517          	auipc	a0,0x5
ffffffffc0201f9a:	e7250513          	addi	a0,a0,-398 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201f9e:	a78fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201fa2:	00005697          	auipc	a3,0x5
ffffffffc0201fa6:	1ae68693          	addi	a3,a3,430 # ffffffffc0207150 <commands+0xbf0>
ffffffffc0201faa:	00005617          	auipc	a2,0x5
ffffffffc0201fae:	a3660613          	addi	a2,a2,-1482 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201fb2:	20d00593          	li	a1,525
ffffffffc0201fb6:	00005517          	auipc	a0,0x5
ffffffffc0201fba:	e5250513          	addi	a0,a0,-430 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201fbe:	a58fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201fc2:	00005697          	auipc	a3,0x5
ffffffffc0201fc6:	1be68693          	addi	a3,a3,446 # ffffffffc0207180 <commands+0xc20>
ffffffffc0201fca:	00005617          	auipc	a2,0x5
ffffffffc0201fce:	a1660613          	addi	a2,a2,-1514 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201fd2:	20c00593          	li	a1,524
ffffffffc0201fd6:	00005517          	auipc	a0,0x5
ffffffffc0201fda:	e3250513          	addi	a0,a0,-462 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201fde:	a38fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201fe2:	00005697          	auipc	a3,0x5
ffffffffc0201fe6:	31e68693          	addi	a3,a3,798 # ffffffffc0207300 <commands+0xda0>
ffffffffc0201fea:	00005617          	auipc	a2,0x5
ffffffffc0201fee:	9f660613          	addi	a2,a2,-1546 # ffffffffc02069e0 <commands+0x480>
ffffffffc0201ff2:	23000593          	li	a1,560
ffffffffc0201ff6:	00005517          	auipc	a0,0x5
ffffffffc0201ffa:	e1250513          	addi	a0,a0,-494 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0201ffe:	a18fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202002:	00005697          	auipc	a3,0x5
ffffffffc0202006:	2be68693          	addi	a3,a3,702 # ffffffffc02072c0 <commands+0xd60>
ffffffffc020200a:	00005617          	auipc	a2,0x5
ffffffffc020200e:	9d660613          	addi	a2,a2,-1578 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202012:	22f00593          	li	a1,559
ffffffffc0202016:	00005517          	auipc	a0,0x5
ffffffffc020201a:	df250513          	addi	a0,a0,-526 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc020201e:	9f8fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202022:	00005697          	auipc	a3,0x5
ffffffffc0202026:	28668693          	addi	a3,a3,646 # ffffffffc02072a8 <commands+0xd48>
ffffffffc020202a:	00005617          	auipc	a2,0x5
ffffffffc020202e:	9b660613          	addi	a2,a2,-1610 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202032:	22e00593          	li	a1,558
ffffffffc0202036:	00005517          	auipc	a0,0x5
ffffffffc020203a:	dd250513          	addi	a0,a0,-558 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc020203e:	9d8fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202042:	86be                	mv	a3,a5
ffffffffc0202044:	00005617          	auipc	a2,0x5
ffffffffc0202048:	d9c60613          	addi	a2,a2,-612 # ffffffffc0206de0 <commands+0x880>
ffffffffc020204c:	1f400593          	li	a1,500
ffffffffc0202050:	00005517          	auipc	a0,0x5
ffffffffc0202054:	db850513          	addi	a0,a0,-584 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202058:	9befe0ef          	jal	ra,ffffffffc0200216 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020205c:	00005617          	auipc	a2,0x5
ffffffffc0202060:	e5c60613          	addi	a2,a2,-420 # ffffffffc0206eb8 <commands+0x958>
ffffffffc0202064:	07f00593          	li	a1,127
ffffffffc0202068:	00005517          	auipc	a0,0x5
ffffffffc020206c:	da050513          	addi	a0,a0,-608 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202070:	9a6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202074:	00005697          	auipc	a3,0x5
ffffffffc0202078:	2bc68693          	addi	a3,a3,700 # ffffffffc0207330 <commands+0xdd0>
ffffffffc020207c:	00005617          	auipc	a2,0x5
ffffffffc0202080:	96460613          	addi	a2,a2,-1692 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202084:	23400593          	li	a1,564
ffffffffc0202088:	00005517          	auipc	a0,0x5
ffffffffc020208c:	d8050513          	addi	a0,a0,-640 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202090:	986fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202094:	00005697          	auipc	a3,0x5
ffffffffc0202098:	12c68693          	addi	a3,a3,300 # ffffffffc02071c0 <commands+0xc60>
ffffffffc020209c:	00005617          	auipc	a2,0x5
ffffffffc02020a0:	94460613          	addi	a2,a2,-1724 # ffffffffc02069e0 <commands+0x480>
ffffffffc02020a4:	24000593          	li	a1,576
ffffffffc02020a8:	00005517          	auipc	a0,0x5
ffffffffc02020ac:	d6050513          	addi	a0,a0,-672 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02020b0:	966fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02020b4:	00005697          	auipc	a3,0x5
ffffffffc02020b8:	f5c68693          	addi	a3,a3,-164 # ffffffffc0207010 <commands+0xab0>
ffffffffc02020bc:	00005617          	auipc	a2,0x5
ffffffffc02020c0:	92460613          	addi	a2,a2,-1756 # ffffffffc02069e0 <commands+0x480>
ffffffffc02020c4:	1f200593          	li	a1,498
ffffffffc02020c8:	00005517          	auipc	a0,0x5
ffffffffc02020cc:	d4050513          	addi	a0,a0,-704 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02020d0:	946fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02020d4:	00005697          	auipc	a3,0x5
ffffffffc02020d8:	f2468693          	addi	a3,a3,-220 # ffffffffc0206ff8 <commands+0xa98>
ffffffffc02020dc:	00005617          	auipc	a2,0x5
ffffffffc02020e0:	90460613          	addi	a2,a2,-1788 # ffffffffc02069e0 <commands+0x480>
ffffffffc02020e4:	1f100593          	li	a1,497
ffffffffc02020e8:	00005517          	auipc	a0,0x5
ffffffffc02020ec:	d2050513          	addi	a0,a0,-736 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02020f0:	926fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02020f4:	00005697          	auipc	a3,0x5
ffffffffc02020f8:	e7c68693          	addi	a3,a3,-388 # ffffffffc0206f70 <commands+0xa10>
ffffffffc02020fc:	00005617          	auipc	a2,0x5
ffffffffc0202100:	8e460613          	addi	a2,a2,-1820 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202104:	1e900593          	li	a1,489
ffffffffc0202108:	00005517          	auipc	a0,0x5
ffffffffc020210c:	d0050513          	addi	a0,a0,-768 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202110:	906fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202114:	00005697          	auipc	a3,0x5
ffffffffc0202118:	eb468693          	addi	a3,a3,-332 # ffffffffc0206fc8 <commands+0xa68>
ffffffffc020211c:	00005617          	auipc	a2,0x5
ffffffffc0202120:	8c460613          	addi	a2,a2,-1852 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202124:	1f000593          	li	a1,496
ffffffffc0202128:	00005517          	auipc	a0,0x5
ffffffffc020212c:	ce050513          	addi	a0,a0,-800 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202130:	8e6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202134:	00005697          	auipc	a3,0x5
ffffffffc0202138:	e6468693          	addi	a3,a3,-412 # ffffffffc0206f98 <commands+0xa38>
ffffffffc020213c:	00005617          	auipc	a2,0x5
ffffffffc0202140:	8a460613          	addi	a2,a2,-1884 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202144:	1ed00593          	li	a1,493
ffffffffc0202148:	00005517          	auipc	a0,0x5
ffffffffc020214c:	cc050513          	addi	a0,a0,-832 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202150:	8c6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202154:	00005697          	auipc	a3,0x5
ffffffffc0202158:	ffc68693          	addi	a3,a3,-4 # ffffffffc0207150 <commands+0xbf0>
ffffffffc020215c:	00005617          	auipc	a2,0x5
ffffffffc0202160:	88460613          	addi	a2,a2,-1916 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202164:	20900593          	li	a1,521
ffffffffc0202168:	00005517          	auipc	a0,0x5
ffffffffc020216c:	ca050513          	addi	a0,a0,-864 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202170:	8a6fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202174:	00005697          	auipc	a3,0x5
ffffffffc0202178:	e9c68693          	addi	a3,a3,-356 # ffffffffc0207010 <commands+0xab0>
ffffffffc020217c:	00005617          	auipc	a2,0x5
ffffffffc0202180:	86460613          	addi	a2,a2,-1948 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202184:	20800593          	li	a1,520
ffffffffc0202188:	00005517          	auipc	a0,0x5
ffffffffc020218c:	c8050513          	addi	a0,a0,-896 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202190:	886fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202194:	00005697          	auipc	a3,0x5
ffffffffc0202198:	fd468693          	addi	a3,a3,-44 # ffffffffc0207168 <commands+0xc08>
ffffffffc020219c:	00005617          	auipc	a2,0x5
ffffffffc02021a0:	84460613          	addi	a2,a2,-1980 # ffffffffc02069e0 <commands+0x480>
ffffffffc02021a4:	20500593          	li	a1,517
ffffffffc02021a8:	00005517          	auipc	a0,0x5
ffffffffc02021ac:	c6050513          	addi	a0,a0,-928 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02021b0:	866fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02021b4:	00005697          	auipc	a3,0x5
ffffffffc02021b8:	1b468693          	addi	a3,a3,436 # ffffffffc0207368 <commands+0xe08>
ffffffffc02021bc:	00005617          	auipc	a2,0x5
ffffffffc02021c0:	82460613          	addi	a2,a2,-2012 # ffffffffc02069e0 <commands+0x480>
ffffffffc02021c4:	23700593          	li	a1,567
ffffffffc02021c8:	00005517          	auipc	a0,0x5
ffffffffc02021cc:	c4050513          	addi	a0,a0,-960 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02021d0:	846fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021d4:	00005697          	auipc	a3,0x5
ffffffffc02021d8:	fec68693          	addi	a3,a3,-20 # ffffffffc02071c0 <commands+0xc60>
ffffffffc02021dc:	00005617          	auipc	a2,0x5
ffffffffc02021e0:	80460613          	addi	a2,a2,-2044 # ffffffffc02069e0 <commands+0x480>
ffffffffc02021e4:	21700593          	li	a1,535
ffffffffc02021e8:	00005517          	auipc	a0,0x5
ffffffffc02021ec:	c2050513          	addi	a0,a0,-992 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02021f0:	826fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02021f4:	00005697          	auipc	a3,0x5
ffffffffc02021f8:	06468693          	addi	a3,a3,100 # ffffffffc0207258 <commands+0xcf8>
ffffffffc02021fc:	00004617          	auipc	a2,0x4
ffffffffc0202200:	7e460613          	addi	a2,a2,2020 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202204:	22900593          	li	a1,553
ffffffffc0202208:	00005517          	auipc	a0,0x5
ffffffffc020220c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202210:	806fe0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202214:	00005697          	auipc	a3,0x5
ffffffffc0202218:	d0468693          	addi	a3,a3,-764 # ffffffffc0206f18 <commands+0x9b8>
ffffffffc020221c:	00004617          	auipc	a2,0x4
ffffffffc0202220:	7c460613          	addi	a2,a2,1988 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202224:	1e700593          	li	a1,487
ffffffffc0202228:	00005517          	auipc	a0,0x5
ffffffffc020222c:	be050513          	addi	a0,a0,-1056 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202230:	fe7fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202234:	00005617          	auipc	a2,0x5
ffffffffc0202238:	c8460613          	addi	a2,a2,-892 # ffffffffc0206eb8 <commands+0x958>
ffffffffc020223c:	0c100593          	li	a1,193
ffffffffc0202240:	00005517          	auipc	a0,0x5
ffffffffc0202244:	bc850513          	addi	a0,a0,-1080 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc0202248:	fcffd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020224c <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020224c:	12058073          	sfence.vma	a1
}
ffffffffc0202250:	8082                	ret

ffffffffc0202252 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202252:	7179                	addi	sp,sp,-48
ffffffffc0202254:	e84a                	sd	s2,16(sp)
ffffffffc0202256:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202258:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020225a:	f022                	sd	s0,32(sp)
ffffffffc020225c:	ec26                	sd	s1,24(sp)
ffffffffc020225e:	e44e                	sd	s3,8(sp)
ffffffffc0202260:	f406                	sd	ra,40(sp)
ffffffffc0202262:	84ae                	mv	s1,a1
ffffffffc0202264:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202266:	be9fe0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc020226a:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020226c:	cd1d                	beqz	a0,ffffffffc02022aa <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020226e:	85aa                	mv	a1,a0
ffffffffc0202270:	86ce                	mv	a3,s3
ffffffffc0202272:	8626                	mv	a2,s1
ffffffffc0202274:	854a                	mv	a0,s2
ffffffffc0202276:	c8eff0ef          	jal	ra,ffffffffc0201704 <page_insert>
ffffffffc020227a:	e121                	bnez	a0,ffffffffc02022ba <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc020227c:	000aa797          	auipc	a5,0xaa
ffffffffc0202280:	33478793          	addi	a5,a5,820 # ffffffffc02ac5b0 <swap_init_ok>
ffffffffc0202284:	439c                	lw	a5,0(a5)
ffffffffc0202286:	2781                	sext.w	a5,a5
ffffffffc0202288:	c38d                	beqz	a5,ffffffffc02022aa <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc020228a:	000aa797          	auipc	a5,0xaa
ffffffffc020228e:	38678793          	addi	a5,a5,902 # ffffffffc02ac610 <check_mm_struct>
ffffffffc0202292:	6388                	ld	a0,0(a5)
ffffffffc0202294:	c919                	beqz	a0,ffffffffc02022aa <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202296:	4681                	li	a3,0
ffffffffc0202298:	8622                	mv	a2,s0
ffffffffc020229a:	85a6                	mv	a1,s1
ffffffffc020229c:	2b1010ef          	jal	ra,ffffffffc0203d4c <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02022a0:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02022a2:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02022a4:	4785                	li	a5,1
ffffffffc02022a6:	02f71063          	bne	a4,a5,ffffffffc02022c6 <pgdir_alloc_page+0x74>
}
ffffffffc02022aa:	8522                	mv	a0,s0
ffffffffc02022ac:	70a2                	ld	ra,40(sp)
ffffffffc02022ae:	7402                	ld	s0,32(sp)
ffffffffc02022b0:	64e2                	ld	s1,24(sp)
ffffffffc02022b2:	6942                	ld	s2,16(sp)
ffffffffc02022b4:	69a2                	ld	s3,8(sp)
ffffffffc02022b6:	6145                	addi	sp,sp,48
ffffffffc02022b8:	8082                	ret
            free_page(page);
ffffffffc02022ba:	8522                	mv	a0,s0
ffffffffc02022bc:	4585                	li	a1,1
ffffffffc02022be:	c19fe0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
            return NULL;
ffffffffc02022c2:	4401                	li	s0,0
ffffffffc02022c4:	b7dd                	j	ffffffffc02022aa <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc02022c6:	00005697          	auipc	a3,0x5
ffffffffc02022ca:	b8268693          	addi	a3,a3,-1150 # ffffffffc0206e48 <commands+0x8e8>
ffffffffc02022ce:	00004617          	auipc	a2,0x4
ffffffffc02022d2:	71260613          	addi	a2,a2,1810 # ffffffffc02069e0 <commands+0x480>
ffffffffc02022d6:	1c800593          	li	a1,456
ffffffffc02022da:	00005517          	auipc	a0,0x5
ffffffffc02022de:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0206e08 <commands+0x8a8>
ffffffffc02022e2:	f35fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02022e6 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02022e6:	000aa797          	auipc	a5,0xaa
ffffffffc02022ea:	31a78793          	addi	a5,a5,794 # ffffffffc02ac600 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02022ee:	f51c                	sd	a5,40(a0)
ffffffffc02022f0:	e79c                	sd	a5,8(a5)
ffffffffc02022f2:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02022f4:	4501                	li	a0,0
ffffffffc02022f6:	8082                	ret

ffffffffc02022f8 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02022f8:	4501                	li	a0,0
ffffffffc02022fa:	8082                	ret

ffffffffc02022fc <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02022fc:	4501                	li	a0,0
ffffffffc02022fe:	8082                	ret

ffffffffc0202300 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202300:	4501                	li	a0,0
ffffffffc0202302:	8082                	ret

ffffffffc0202304 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0202304:	711d                	addi	sp,sp,-96
ffffffffc0202306:	fc4e                	sd	s3,56(sp)
ffffffffc0202308:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020230a:	00005517          	auipc	a0,0x5
ffffffffc020230e:	0ee50513          	addi	a0,a0,238 # ffffffffc02073f8 <commands+0xe98>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202312:	698d                	lui	s3,0x3
ffffffffc0202314:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0202316:	e8a2                	sd	s0,80(sp)
ffffffffc0202318:	e4a6                	sd	s1,72(sp)
ffffffffc020231a:	ec86                	sd	ra,88(sp)
ffffffffc020231c:	e0ca                	sd	s2,64(sp)
ffffffffc020231e:	f456                	sd	s5,40(sp)
ffffffffc0202320:	f05a                	sd	s6,32(sp)
ffffffffc0202322:	ec5e                	sd	s7,24(sp)
ffffffffc0202324:	e862                	sd	s8,16(sp)
ffffffffc0202326:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0202328:	000aa417          	auipc	s0,0xaa
ffffffffc020232c:	27040413          	addi	s0,s0,624 # ffffffffc02ac598 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202330:	da1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202334:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6588>
    assert(pgfault_num==4);
ffffffffc0202338:	4004                	lw	s1,0(s0)
ffffffffc020233a:	4791                	li	a5,4
ffffffffc020233c:	2481                	sext.w	s1,s1
ffffffffc020233e:	14f49963          	bne	s1,a5,ffffffffc0202490 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202342:	00005517          	auipc	a0,0x5
ffffffffc0202346:	10650513          	addi	a0,a0,262 # ffffffffc0207448 <commands+0xee8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020234a:	6a85                	lui	s5,0x1
ffffffffc020234c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020234e:	d83fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202352:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8588>
    assert(pgfault_num==4);
ffffffffc0202356:	00042903          	lw	s2,0(s0)
ffffffffc020235a:	2901                	sext.w	s2,s2
ffffffffc020235c:	2a991a63          	bne	s2,s1,ffffffffc0202610 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202360:	00005517          	auipc	a0,0x5
ffffffffc0202364:	11050513          	addi	a0,a0,272 # ffffffffc0207470 <commands+0xf10>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202368:	6b91                	lui	s7,0x4
ffffffffc020236a:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020236c:	d65fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202370:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5588>
    assert(pgfault_num==4);
ffffffffc0202374:	4004                	lw	s1,0(s0)
ffffffffc0202376:	2481                	sext.w	s1,s1
ffffffffc0202378:	27249c63          	bne	s1,s2,ffffffffc02025f0 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020237c:	00005517          	auipc	a0,0x5
ffffffffc0202380:	11c50513          	addi	a0,a0,284 # ffffffffc0207498 <commands+0xf38>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202384:	6909                	lui	s2,0x2
ffffffffc0202386:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202388:	d49fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020238c:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7588>
    assert(pgfault_num==4);
ffffffffc0202390:	401c                	lw	a5,0(s0)
ffffffffc0202392:	2781                	sext.w	a5,a5
ffffffffc0202394:	22979e63          	bne	a5,s1,ffffffffc02025d0 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202398:	00005517          	auipc	a0,0x5
ffffffffc020239c:	12850513          	addi	a0,a0,296 # ffffffffc02074c0 <commands+0xf60>
ffffffffc02023a0:	d31fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02023a4:	6795                	lui	a5,0x5
ffffffffc02023a6:	4739                	li	a4,14
ffffffffc02023a8:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4588>
    assert(pgfault_num==5);
ffffffffc02023ac:	4004                	lw	s1,0(s0)
ffffffffc02023ae:	4795                	li	a5,5
ffffffffc02023b0:	2481                	sext.w	s1,s1
ffffffffc02023b2:	1ef49f63          	bne	s1,a5,ffffffffc02025b0 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02023b6:	00005517          	auipc	a0,0x5
ffffffffc02023ba:	0e250513          	addi	a0,a0,226 # ffffffffc0207498 <commands+0xf38>
ffffffffc02023be:	d13fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02023c2:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02023c6:	401c                	lw	a5,0(s0)
ffffffffc02023c8:	2781                	sext.w	a5,a5
ffffffffc02023ca:	1c979363          	bne	a5,s1,ffffffffc0202590 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02023ce:	00005517          	auipc	a0,0x5
ffffffffc02023d2:	07a50513          	addi	a0,a0,122 # ffffffffc0207448 <commands+0xee8>
ffffffffc02023d6:	cfbfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02023da:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02023de:	401c                	lw	a5,0(s0)
ffffffffc02023e0:	4719                	li	a4,6
ffffffffc02023e2:	2781                	sext.w	a5,a5
ffffffffc02023e4:	18e79663          	bne	a5,a4,ffffffffc0202570 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02023e8:	00005517          	auipc	a0,0x5
ffffffffc02023ec:	0b050513          	addi	a0,a0,176 # ffffffffc0207498 <commands+0xf38>
ffffffffc02023f0:	ce1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02023f4:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02023f8:	401c                	lw	a5,0(s0)
ffffffffc02023fa:	471d                	li	a4,7
ffffffffc02023fc:	2781                	sext.w	a5,a5
ffffffffc02023fe:	14e79963          	bne	a5,a4,ffffffffc0202550 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202402:	00005517          	auipc	a0,0x5
ffffffffc0202406:	ff650513          	addi	a0,a0,-10 # ffffffffc02073f8 <commands+0xe98>
ffffffffc020240a:	cc7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020240e:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0202412:	401c                	lw	a5,0(s0)
ffffffffc0202414:	4721                	li	a4,8
ffffffffc0202416:	2781                	sext.w	a5,a5
ffffffffc0202418:	10e79c63          	bne	a5,a4,ffffffffc0202530 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020241c:	00005517          	auipc	a0,0x5
ffffffffc0202420:	05450513          	addi	a0,a0,84 # ffffffffc0207470 <commands+0xf10>
ffffffffc0202424:	cadfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202428:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc020242c:	401c                	lw	a5,0(s0)
ffffffffc020242e:	4725                	li	a4,9
ffffffffc0202430:	2781                	sext.w	a5,a5
ffffffffc0202432:	0ce79f63          	bne	a5,a4,ffffffffc0202510 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202436:	00005517          	auipc	a0,0x5
ffffffffc020243a:	08a50513          	addi	a0,a0,138 # ffffffffc02074c0 <commands+0xf60>
ffffffffc020243e:	c93fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202442:	6795                	lui	a5,0x5
ffffffffc0202444:	4739                	li	a4,14
ffffffffc0202446:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4588>
    assert(pgfault_num==10);
ffffffffc020244a:	4004                	lw	s1,0(s0)
ffffffffc020244c:	47a9                	li	a5,10
ffffffffc020244e:	2481                	sext.w	s1,s1
ffffffffc0202450:	0af49063          	bne	s1,a5,ffffffffc02024f0 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202454:	00005517          	auipc	a0,0x5
ffffffffc0202458:	ff450513          	addi	a0,a0,-12 # ffffffffc0207448 <commands+0xee8>
ffffffffc020245c:	c75fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202460:	6785                	lui	a5,0x1
ffffffffc0202462:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8588>
ffffffffc0202466:	06979563          	bne	a5,s1,ffffffffc02024d0 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc020246a:	401c                	lw	a5,0(s0)
ffffffffc020246c:	472d                	li	a4,11
ffffffffc020246e:	2781                	sext.w	a5,a5
ffffffffc0202470:	04e79063          	bne	a5,a4,ffffffffc02024b0 <_fifo_check_swap+0x1ac>
}
ffffffffc0202474:	60e6                	ld	ra,88(sp)
ffffffffc0202476:	6446                	ld	s0,80(sp)
ffffffffc0202478:	64a6                	ld	s1,72(sp)
ffffffffc020247a:	6906                	ld	s2,64(sp)
ffffffffc020247c:	79e2                	ld	s3,56(sp)
ffffffffc020247e:	7a42                	ld	s4,48(sp)
ffffffffc0202480:	7aa2                	ld	s5,40(sp)
ffffffffc0202482:	7b02                	ld	s6,32(sp)
ffffffffc0202484:	6be2                	ld	s7,24(sp)
ffffffffc0202486:	6c42                	ld	s8,16(sp)
ffffffffc0202488:	6ca2                	ld	s9,8(sp)
ffffffffc020248a:	4501                	li	a0,0
ffffffffc020248c:	6125                	addi	sp,sp,96
ffffffffc020248e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0202490:	00005697          	auipc	a3,0x5
ffffffffc0202494:	f9068693          	addi	a3,a3,-112 # ffffffffc0207420 <commands+0xec0>
ffffffffc0202498:	00004617          	auipc	a2,0x4
ffffffffc020249c:	54860613          	addi	a2,a2,1352 # ffffffffc02069e0 <commands+0x480>
ffffffffc02024a0:	05100593          	li	a1,81
ffffffffc02024a4:	00005517          	auipc	a0,0x5
ffffffffc02024a8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0207430 <commands+0xed0>
ffffffffc02024ac:	d6bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==11);
ffffffffc02024b0:	00005697          	auipc	a3,0x5
ffffffffc02024b4:	0c068693          	addi	a3,a3,192 # ffffffffc0207570 <commands+0x1010>
ffffffffc02024b8:	00004617          	auipc	a2,0x4
ffffffffc02024bc:	52860613          	addi	a2,a2,1320 # ffffffffc02069e0 <commands+0x480>
ffffffffc02024c0:	07300593          	li	a1,115
ffffffffc02024c4:	00005517          	auipc	a0,0x5
ffffffffc02024c8:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207430 <commands+0xed0>
ffffffffc02024cc:	d4bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02024d0:	00005697          	auipc	a3,0x5
ffffffffc02024d4:	07868693          	addi	a3,a3,120 # ffffffffc0207548 <commands+0xfe8>
ffffffffc02024d8:	00004617          	auipc	a2,0x4
ffffffffc02024dc:	50860613          	addi	a2,a2,1288 # ffffffffc02069e0 <commands+0x480>
ffffffffc02024e0:	07100593          	li	a1,113
ffffffffc02024e4:	00005517          	auipc	a0,0x5
ffffffffc02024e8:	f4c50513          	addi	a0,a0,-180 # ffffffffc0207430 <commands+0xed0>
ffffffffc02024ec:	d2bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==10);
ffffffffc02024f0:	00005697          	auipc	a3,0x5
ffffffffc02024f4:	04868693          	addi	a3,a3,72 # ffffffffc0207538 <commands+0xfd8>
ffffffffc02024f8:	00004617          	auipc	a2,0x4
ffffffffc02024fc:	4e860613          	addi	a2,a2,1256 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202500:	06f00593          	li	a1,111
ffffffffc0202504:	00005517          	auipc	a0,0x5
ffffffffc0202508:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207430 <commands+0xed0>
ffffffffc020250c:	d0bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==9);
ffffffffc0202510:	00005697          	auipc	a3,0x5
ffffffffc0202514:	01868693          	addi	a3,a3,24 # ffffffffc0207528 <commands+0xfc8>
ffffffffc0202518:	00004617          	auipc	a2,0x4
ffffffffc020251c:	4c860613          	addi	a2,a2,1224 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202520:	06c00593          	li	a1,108
ffffffffc0202524:	00005517          	auipc	a0,0x5
ffffffffc0202528:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207430 <commands+0xed0>
ffffffffc020252c:	cebfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==8);
ffffffffc0202530:	00005697          	auipc	a3,0x5
ffffffffc0202534:	fe868693          	addi	a3,a3,-24 # ffffffffc0207518 <commands+0xfb8>
ffffffffc0202538:	00004617          	auipc	a2,0x4
ffffffffc020253c:	4a860613          	addi	a2,a2,1192 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202540:	06900593          	li	a1,105
ffffffffc0202544:	00005517          	auipc	a0,0x5
ffffffffc0202548:	eec50513          	addi	a0,a0,-276 # ffffffffc0207430 <commands+0xed0>
ffffffffc020254c:	ccbfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==7);
ffffffffc0202550:	00005697          	auipc	a3,0x5
ffffffffc0202554:	fb868693          	addi	a3,a3,-72 # ffffffffc0207508 <commands+0xfa8>
ffffffffc0202558:	00004617          	auipc	a2,0x4
ffffffffc020255c:	48860613          	addi	a2,a2,1160 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202560:	06600593          	li	a1,102
ffffffffc0202564:	00005517          	auipc	a0,0x5
ffffffffc0202568:	ecc50513          	addi	a0,a0,-308 # ffffffffc0207430 <commands+0xed0>
ffffffffc020256c:	cabfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==6);
ffffffffc0202570:	00005697          	auipc	a3,0x5
ffffffffc0202574:	f8868693          	addi	a3,a3,-120 # ffffffffc02074f8 <commands+0xf98>
ffffffffc0202578:	00004617          	auipc	a2,0x4
ffffffffc020257c:	46860613          	addi	a2,a2,1128 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202580:	06300593          	li	a1,99
ffffffffc0202584:	00005517          	auipc	a0,0x5
ffffffffc0202588:	eac50513          	addi	a0,a0,-340 # ffffffffc0207430 <commands+0xed0>
ffffffffc020258c:	c8bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc0202590:	00005697          	auipc	a3,0x5
ffffffffc0202594:	f5868693          	addi	a3,a3,-168 # ffffffffc02074e8 <commands+0xf88>
ffffffffc0202598:	00004617          	auipc	a2,0x4
ffffffffc020259c:	44860613          	addi	a2,a2,1096 # ffffffffc02069e0 <commands+0x480>
ffffffffc02025a0:	06000593          	li	a1,96
ffffffffc02025a4:	00005517          	auipc	a0,0x5
ffffffffc02025a8:	e8c50513          	addi	a0,a0,-372 # ffffffffc0207430 <commands+0xed0>
ffffffffc02025ac:	c6bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==5);
ffffffffc02025b0:	00005697          	auipc	a3,0x5
ffffffffc02025b4:	f3868693          	addi	a3,a3,-200 # ffffffffc02074e8 <commands+0xf88>
ffffffffc02025b8:	00004617          	auipc	a2,0x4
ffffffffc02025bc:	42860613          	addi	a2,a2,1064 # ffffffffc02069e0 <commands+0x480>
ffffffffc02025c0:	05d00593          	li	a1,93
ffffffffc02025c4:	00005517          	auipc	a0,0x5
ffffffffc02025c8:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207430 <commands+0xed0>
ffffffffc02025cc:	c4bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc02025d0:	00005697          	auipc	a3,0x5
ffffffffc02025d4:	e5068693          	addi	a3,a3,-432 # ffffffffc0207420 <commands+0xec0>
ffffffffc02025d8:	00004617          	auipc	a2,0x4
ffffffffc02025dc:	40860613          	addi	a2,a2,1032 # ffffffffc02069e0 <commands+0x480>
ffffffffc02025e0:	05a00593          	li	a1,90
ffffffffc02025e4:	00005517          	auipc	a0,0x5
ffffffffc02025e8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207430 <commands+0xed0>
ffffffffc02025ec:	c2bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc02025f0:	00005697          	auipc	a3,0x5
ffffffffc02025f4:	e3068693          	addi	a3,a3,-464 # ffffffffc0207420 <commands+0xec0>
ffffffffc02025f8:	00004617          	auipc	a2,0x4
ffffffffc02025fc:	3e860613          	addi	a2,a2,1000 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202600:	05700593          	li	a1,87
ffffffffc0202604:	00005517          	auipc	a0,0x5
ffffffffc0202608:	e2c50513          	addi	a0,a0,-468 # ffffffffc0207430 <commands+0xed0>
ffffffffc020260c:	c0bfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgfault_num==4);
ffffffffc0202610:	00005697          	auipc	a3,0x5
ffffffffc0202614:	e1068693          	addi	a3,a3,-496 # ffffffffc0207420 <commands+0xec0>
ffffffffc0202618:	00004617          	auipc	a2,0x4
ffffffffc020261c:	3c860613          	addi	a2,a2,968 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202620:	05400593          	li	a1,84
ffffffffc0202624:	00005517          	auipc	a0,0x5
ffffffffc0202628:	e0c50513          	addi	a0,a0,-500 # ffffffffc0207430 <commands+0xed0>
ffffffffc020262c:	bebfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202630 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202630:	751c                	ld	a5,40(a0)
{
ffffffffc0202632:	1141                	addi	sp,sp,-16
ffffffffc0202634:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0202636:	cf91                	beqz	a5,ffffffffc0202652 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0202638:	ee0d                	bnez	a2,ffffffffc0202672 <_fifo_swap_out_victim+0x42>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020263a:	679c                	ld	a5,8(a5)
}
ffffffffc020263c:	60a2                	ld	ra,8(sp)
ffffffffc020263e:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0202640:	6394                	ld	a3,0(a5)
ffffffffc0202642:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0202644:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202648:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020264a:	e314                	sd	a3,0(a4)
ffffffffc020264c:	e19c                	sd	a5,0(a1)
}
ffffffffc020264e:	0141                	addi	sp,sp,16
ffffffffc0202650:	8082                	ret
         assert(head != NULL);
ffffffffc0202652:	00005697          	auipc	a3,0x5
ffffffffc0202656:	f4e68693          	addi	a3,a3,-178 # ffffffffc02075a0 <commands+0x1040>
ffffffffc020265a:	00004617          	auipc	a2,0x4
ffffffffc020265e:	38660613          	addi	a2,a2,902 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202662:	04100593          	li	a1,65
ffffffffc0202666:	00005517          	auipc	a0,0x5
ffffffffc020266a:	dca50513          	addi	a0,a0,-566 # ffffffffc0207430 <commands+0xed0>
ffffffffc020266e:	ba9fd0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(in_tick==0);
ffffffffc0202672:	00005697          	auipc	a3,0x5
ffffffffc0202676:	f3e68693          	addi	a3,a3,-194 # ffffffffc02075b0 <commands+0x1050>
ffffffffc020267a:	00004617          	auipc	a2,0x4
ffffffffc020267e:	36660613          	addi	a2,a2,870 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202682:	04200593          	li	a1,66
ffffffffc0202686:	00005517          	auipc	a0,0x5
ffffffffc020268a:	daa50513          	addi	a0,a0,-598 # ffffffffc0207430 <commands+0xed0>
ffffffffc020268e:	b89fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202692 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0202692:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0202696:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0202698:	cb09                	beqz	a4,ffffffffc02026aa <_fifo_map_swappable+0x18>
ffffffffc020269a:	cb81                	beqz	a5,ffffffffc02026aa <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020269c:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc020269e:	e398                	sd	a4,0(a5)
}
ffffffffc02026a0:	4501                	li	a0,0
ffffffffc02026a2:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc02026a4:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02026a6:	f614                	sd	a3,40(a2)
ffffffffc02026a8:	8082                	ret
{
ffffffffc02026aa:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02026ac:	00005697          	auipc	a3,0x5
ffffffffc02026b0:	ed468693          	addi	a3,a3,-300 # ffffffffc0207580 <commands+0x1020>
ffffffffc02026b4:	00004617          	auipc	a2,0x4
ffffffffc02026b8:	32c60613          	addi	a2,a2,812 # ffffffffc02069e0 <commands+0x480>
ffffffffc02026bc:	03200593          	li	a1,50
ffffffffc02026c0:	00005517          	auipc	a0,0x5
ffffffffc02026c4:	d7050513          	addi	a0,a0,-656 # ffffffffc0207430 <commands+0xed0>
{
ffffffffc02026c8:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02026ca:	b4dfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02026ce <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02026ce:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02026d0:	00005697          	auipc	a3,0x5
ffffffffc02026d4:	f0868693          	addi	a3,a3,-248 # ffffffffc02075d8 <commands+0x1078>
ffffffffc02026d8:	00004617          	auipc	a2,0x4
ffffffffc02026dc:	30860613          	addi	a2,a2,776 # ffffffffc02069e0 <commands+0x480>
ffffffffc02026e0:	06d00593          	li	a1,109
ffffffffc02026e4:	00005517          	auipc	a0,0x5
ffffffffc02026e8:	f1450513          	addi	a0,a0,-236 # ffffffffc02075f8 <commands+0x1098>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02026ec:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02026ee:	b29fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02026f2 <mm_create>:
mm_create(void) {
ffffffffc02026f2:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02026f4:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02026f8:	e022                	sd	s0,0(sp)
ffffffffc02026fa:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02026fc:	4e1000ef          	jal	ra,ffffffffc02033dc <kmalloc>
ffffffffc0202700:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202702:	c515                	beqz	a0,ffffffffc020272e <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202704:	000aa797          	auipc	a5,0xaa
ffffffffc0202708:	eac78793          	addi	a5,a5,-340 # ffffffffc02ac5b0 <swap_init_ok>
ffffffffc020270c:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020270e:	e408                	sd	a0,8(s0)
ffffffffc0202710:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0202712:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202716:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020271a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020271e:	2781                	sext.w	a5,a5
ffffffffc0202720:	ef81                	bnez	a5,ffffffffc0202738 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0202722:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0202726:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020272a:	02043c23          	sd	zero,56(s0)
}
ffffffffc020272e:	8522                	mv	a0,s0
ffffffffc0202730:	60a2                	ld	ra,8(sp)
ffffffffc0202732:	6402                	ld	s0,0(sp)
ffffffffc0202734:	0141                	addi	sp,sp,16
ffffffffc0202736:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202738:	604010ef          	jal	ra,ffffffffc0203d3c <swap_init_mm>
ffffffffc020273c:	b7ed                	j	ffffffffc0202726 <mm_create+0x34>

ffffffffc020273e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020273e:	1101                	addi	sp,sp,-32
ffffffffc0202740:	e04a                	sd	s2,0(sp)
ffffffffc0202742:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202744:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202748:	e822                	sd	s0,16(sp)
ffffffffc020274a:	e426                	sd	s1,8(sp)
ffffffffc020274c:	ec06                	sd	ra,24(sp)
ffffffffc020274e:	84ae                	mv	s1,a1
ffffffffc0202750:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202752:	48b000ef          	jal	ra,ffffffffc02033dc <kmalloc>
    if (vma != NULL) {
ffffffffc0202756:	c509                	beqz	a0,ffffffffc0202760 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202758:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020275c:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020275e:	cd00                	sw	s0,24(a0)
}
ffffffffc0202760:	60e2                	ld	ra,24(sp)
ffffffffc0202762:	6442                	ld	s0,16(sp)
ffffffffc0202764:	64a2                	ld	s1,8(sp)
ffffffffc0202766:	6902                	ld	s2,0(sp)
ffffffffc0202768:	6105                	addi	sp,sp,32
ffffffffc020276a:	8082                	ret

ffffffffc020276c <find_vma>:
    if (mm != NULL) {
ffffffffc020276c:	c51d                	beqz	a0,ffffffffc020279a <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc020276e:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202770:	c781                	beqz	a5,ffffffffc0202778 <find_vma+0xc>
ffffffffc0202772:	6798                	ld	a4,8(a5)
ffffffffc0202774:	02e5f663          	bleu	a4,a1,ffffffffc02027a0 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0202778:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020277a:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020277c:	00f50f63          	beq	a0,a5,ffffffffc020279a <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202780:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202784:	fee5ebe3          	bltu	a1,a4,ffffffffc020277a <find_vma+0xe>
ffffffffc0202788:	ff07b703          	ld	a4,-16(a5)
ffffffffc020278c:	fee5f7e3          	bleu	a4,a1,ffffffffc020277a <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0202790:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0202792:	c781                	beqz	a5,ffffffffc020279a <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0202794:	e91c                	sd	a5,16(a0)
}
ffffffffc0202796:	853e                	mv	a0,a5
ffffffffc0202798:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020279a:	4781                	li	a5,0
}
ffffffffc020279c:	853e                	mv	a0,a5
ffffffffc020279e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02027a0:	6b98                	ld	a4,16(a5)
ffffffffc02027a2:	fce5fbe3          	bleu	a4,a1,ffffffffc0202778 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02027a6:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02027a8:	b7fd                	j	ffffffffc0202796 <find_vma+0x2a>

ffffffffc02027aa <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02027aa:	6590                	ld	a2,8(a1)
ffffffffc02027ac:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02027b0:	1141                	addi	sp,sp,-16
ffffffffc02027b2:	e406                	sd	ra,8(sp)
ffffffffc02027b4:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02027b6:	01066863          	bltu	a2,a6,ffffffffc02027c6 <insert_vma_struct+0x1c>
ffffffffc02027ba:	a8b9                	j	ffffffffc0202818 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02027bc:	fe87b683          	ld	a3,-24(a5)
ffffffffc02027c0:	04d66763          	bltu	a2,a3,ffffffffc020280e <insert_vma_struct+0x64>
ffffffffc02027c4:	873e                	mv	a4,a5
ffffffffc02027c6:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02027c8:	fef51ae3          	bne	a0,a5,ffffffffc02027bc <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02027cc:	02a70463          	beq	a4,a0,ffffffffc02027f4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02027d0:	ff073683          	ld	a3,-16(a4) # 7fff0 <_binary_obj___user_exit_out_size+0x75560>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02027d4:	fe873883          	ld	a7,-24(a4)
ffffffffc02027d8:	08d8f063          	bleu	a3,a7,ffffffffc0202858 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02027dc:	04d66e63          	bltu	a2,a3,ffffffffc0202838 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02027e0:	00f50a63          	beq	a0,a5,ffffffffc02027f4 <insert_vma_struct+0x4a>
ffffffffc02027e4:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02027e8:	0506e863          	bltu	a3,a6,ffffffffc0202838 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02027ec:	ff07b603          	ld	a2,-16(a5)
ffffffffc02027f0:	02c6f263          	bleu	a2,a3,ffffffffc0202814 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02027f4:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02027f6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02027f8:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02027fc:	e390                	sd	a2,0(a5)
ffffffffc02027fe:	e710                	sd	a2,8(a4)
}
ffffffffc0202800:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202802:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202804:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0202806:	2685                	addiw	a3,a3,1
ffffffffc0202808:	d114                	sw	a3,32(a0)
}
ffffffffc020280a:	0141                	addi	sp,sp,16
ffffffffc020280c:	8082                	ret
    if (le_prev != list) {
ffffffffc020280e:	fca711e3          	bne	a4,a0,ffffffffc02027d0 <insert_vma_struct+0x26>
ffffffffc0202812:	bfd9                	j	ffffffffc02027e8 <insert_vma_struct+0x3e>
ffffffffc0202814:	ebbff0ef          	jal	ra,ffffffffc02026ce <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202818:	00005697          	auipc	a3,0x5
ffffffffc020281c:	ed068693          	addi	a3,a3,-304 # ffffffffc02076e8 <commands+0x1188>
ffffffffc0202820:	00004617          	auipc	a2,0x4
ffffffffc0202824:	1c060613          	addi	a2,a2,448 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202828:	07400593          	li	a1,116
ffffffffc020282c:	00005517          	auipc	a0,0x5
ffffffffc0202830:	dcc50513          	addi	a0,a0,-564 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202834:	9e3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202838:	00005697          	auipc	a3,0x5
ffffffffc020283c:	ef068693          	addi	a3,a3,-272 # ffffffffc0207728 <commands+0x11c8>
ffffffffc0202840:	00004617          	auipc	a2,0x4
ffffffffc0202844:	1a060613          	addi	a2,a2,416 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202848:	06c00593          	li	a1,108
ffffffffc020284c:	00005517          	auipc	a0,0x5
ffffffffc0202850:	dac50513          	addi	a0,a0,-596 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202854:	9c3fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202858:	00005697          	auipc	a3,0x5
ffffffffc020285c:	eb068693          	addi	a3,a3,-336 # ffffffffc0207708 <commands+0x11a8>
ffffffffc0202860:	00004617          	auipc	a2,0x4
ffffffffc0202864:	18060613          	addi	a2,a2,384 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202868:	06b00593          	li	a1,107
ffffffffc020286c:	00005517          	auipc	a0,0x5
ffffffffc0202870:	d8c50513          	addi	a0,a0,-628 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202874:	9a3fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202878 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202878:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020287a:	1141                	addi	sp,sp,-16
ffffffffc020287c:	e406                	sd	ra,8(sp)
ffffffffc020287e:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202880:	e78d                	bnez	a5,ffffffffc02028aa <mm_destroy+0x32>
ffffffffc0202882:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202884:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0202886:	00a40c63          	beq	s0,a0,ffffffffc020289e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020288a:	6118                	ld	a4,0(a0)
ffffffffc020288c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020288e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202890:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202892:	e398                	sd	a4,0(a5)
ffffffffc0202894:	405000ef          	jal	ra,ffffffffc0203498 <kfree>
    return listelm->next;
ffffffffc0202898:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020289a:	fea418e3          	bne	s0,a0,ffffffffc020288a <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc020289e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02028a0:	6402                	ld	s0,0(sp)
ffffffffc02028a2:	60a2                	ld	ra,8(sp)
ffffffffc02028a4:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02028a6:	3f30006f          	j	ffffffffc0203498 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02028aa:	00005697          	auipc	a3,0x5
ffffffffc02028ae:	e9e68693          	addi	a3,a3,-354 # ffffffffc0207748 <commands+0x11e8>
ffffffffc02028b2:	00004617          	auipc	a2,0x4
ffffffffc02028b6:	12e60613          	addi	a2,a2,302 # ffffffffc02069e0 <commands+0x480>
ffffffffc02028ba:	09400593          	li	a1,148
ffffffffc02028be:	00005517          	auipc	a0,0x5
ffffffffc02028c2:	d3a50513          	addi	a0,a0,-710 # ffffffffc02075f8 <commands+0x1098>
ffffffffc02028c6:	951fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02028ca <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02028ca:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02028cc:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02028ce:	17fd                	addi	a5,a5,-1
ffffffffc02028d0:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02028d2:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02028d4:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02028d8:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02028da:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02028dc:	fc06                	sd	ra,56(sp)
ffffffffc02028de:	f04a                	sd	s2,32(sp)
ffffffffc02028e0:	ec4e                	sd	s3,24(sp)
ffffffffc02028e2:	e852                	sd	s4,16(sp)
ffffffffc02028e4:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02028e6:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02028ea:	002007b7          	lui	a5,0x200
ffffffffc02028ee:	01047433          	and	s0,s0,a6
ffffffffc02028f2:	06f4e363          	bltu	s1,a5,ffffffffc0202958 <mm_map+0x8e>
ffffffffc02028f6:	0684f163          	bleu	s0,s1,ffffffffc0202958 <mm_map+0x8e>
ffffffffc02028fa:	4785                	li	a5,1
ffffffffc02028fc:	07fe                	slli	a5,a5,0x1f
ffffffffc02028fe:	0487ed63          	bltu	a5,s0,ffffffffc0202958 <mm_map+0x8e>
ffffffffc0202902:	89aa                	mv	s3,a0
ffffffffc0202904:	8a3a                	mv	s4,a4
ffffffffc0202906:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202908:	c931                	beqz	a0,ffffffffc020295c <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc020290a:	85a6                	mv	a1,s1
ffffffffc020290c:	e61ff0ef          	jal	ra,ffffffffc020276c <find_vma>
ffffffffc0202910:	c501                	beqz	a0,ffffffffc0202918 <mm_map+0x4e>
ffffffffc0202912:	651c                	ld	a5,8(a0)
ffffffffc0202914:	0487e263          	bltu	a5,s0,ffffffffc0202958 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202918:	03000513          	li	a0,48
ffffffffc020291c:	2c1000ef          	jal	ra,ffffffffc02033dc <kmalloc>
ffffffffc0202920:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202922:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202924:	02090163          	beqz	s2,ffffffffc0202946 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202928:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020292a:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020292e:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202932:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202936:	85ca                	mv	a1,s2
ffffffffc0202938:	e73ff0ef          	jal	ra,ffffffffc02027aa <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020293c:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020293e:	000a0463          	beqz	s4,ffffffffc0202946 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0202942:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0202946:	70e2                	ld	ra,56(sp)
ffffffffc0202948:	7442                	ld	s0,48(sp)
ffffffffc020294a:	74a2                	ld	s1,40(sp)
ffffffffc020294c:	7902                	ld	s2,32(sp)
ffffffffc020294e:	69e2                	ld	s3,24(sp)
ffffffffc0202950:	6a42                	ld	s4,16(sp)
ffffffffc0202952:	6aa2                	ld	s5,8(sp)
ffffffffc0202954:	6121                	addi	sp,sp,64
ffffffffc0202956:	8082                	ret
        return -E_INVAL;
ffffffffc0202958:	5575                	li	a0,-3
ffffffffc020295a:	b7f5                	j	ffffffffc0202946 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc020295c:	00005697          	auipc	a3,0x5
ffffffffc0202960:	e0468693          	addi	a3,a3,-508 # ffffffffc0207760 <commands+0x1200>
ffffffffc0202964:	00004617          	auipc	a2,0x4
ffffffffc0202968:	07c60613          	addi	a2,a2,124 # ffffffffc02069e0 <commands+0x480>
ffffffffc020296c:	0a700593          	li	a1,167
ffffffffc0202970:	00005517          	auipc	a0,0x5
ffffffffc0202974:	c8850513          	addi	a0,a0,-888 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202978:	89ffd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020297c <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc020297c:	7139                	addi	sp,sp,-64
ffffffffc020297e:	fc06                	sd	ra,56(sp)
ffffffffc0202980:	f822                	sd	s0,48(sp)
ffffffffc0202982:	f426                	sd	s1,40(sp)
ffffffffc0202984:	f04a                	sd	s2,32(sp)
ffffffffc0202986:	ec4e                	sd	s3,24(sp)
ffffffffc0202988:	e852                	sd	s4,16(sp)
ffffffffc020298a:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020298c:	c535                	beqz	a0,ffffffffc02029f8 <dup_mmap+0x7c>
ffffffffc020298e:	892a                	mv	s2,a0
ffffffffc0202990:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202992:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202994:	e59d                	bnez	a1,ffffffffc02029c2 <dup_mmap+0x46>
ffffffffc0202996:	a08d                	j	ffffffffc02029f8 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202998:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020299a:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5578>
        insert_vma_struct(to, nvma);
ffffffffc020299e:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc02029a0:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc02029a4:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02029a8:	e03ff0ef          	jal	ra,ffffffffc02027aa <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02029ac:	ff043683          	ld	a3,-16(s0)
ffffffffc02029b0:	fe843603          	ld	a2,-24(s0)
ffffffffc02029b4:	6c8c                	ld	a1,24(s1)
ffffffffc02029b6:	01893503          	ld	a0,24(s2)
ffffffffc02029ba:	4701                	li	a4,0
ffffffffc02029bc:	b43fe0ef          	jal	ra,ffffffffc02014fe <copy_range>
ffffffffc02029c0:	e105                	bnez	a0,ffffffffc02029e0 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02029c2:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02029c4:	02848863          	beq	s1,s0,ffffffffc02029f4 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029c8:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02029cc:	fe843a83          	ld	s5,-24(s0)
ffffffffc02029d0:	ff043a03          	ld	s4,-16(s0)
ffffffffc02029d4:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02029d8:	205000ef          	jal	ra,ffffffffc02033dc <kmalloc>
ffffffffc02029dc:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02029de:	fd4d                	bnez	a0,ffffffffc0202998 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02029e0:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02029e2:	70e2                	ld	ra,56(sp)
ffffffffc02029e4:	7442                	ld	s0,48(sp)
ffffffffc02029e6:	74a2                	ld	s1,40(sp)
ffffffffc02029e8:	7902                	ld	s2,32(sp)
ffffffffc02029ea:	69e2                	ld	s3,24(sp)
ffffffffc02029ec:	6a42                	ld	s4,16(sp)
ffffffffc02029ee:	6aa2                	ld	s5,8(sp)
ffffffffc02029f0:	6121                	addi	sp,sp,64
ffffffffc02029f2:	8082                	ret
    return 0;
ffffffffc02029f4:	4501                	li	a0,0
ffffffffc02029f6:	b7f5                	j	ffffffffc02029e2 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02029f8:	00005697          	auipc	a3,0x5
ffffffffc02029fc:	cb068693          	addi	a3,a3,-848 # ffffffffc02076a8 <commands+0x1148>
ffffffffc0202a00:	00004617          	auipc	a2,0x4
ffffffffc0202a04:	fe060613          	addi	a2,a2,-32 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202a08:	0c000593          	li	a1,192
ffffffffc0202a0c:	00005517          	auipc	a0,0x5
ffffffffc0202a10:	bec50513          	addi	a0,a0,-1044 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202a14:	803fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202a18 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0202a18:	1101                	addi	sp,sp,-32
ffffffffc0202a1a:	ec06                	sd	ra,24(sp)
ffffffffc0202a1c:	e822                	sd	s0,16(sp)
ffffffffc0202a1e:	e426                	sd	s1,8(sp)
ffffffffc0202a20:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202a22:	c531                	beqz	a0,ffffffffc0202a6e <exit_mmap+0x56>
ffffffffc0202a24:	591c                	lw	a5,48(a0)
ffffffffc0202a26:	84aa                	mv	s1,a0
ffffffffc0202a28:	e3b9                	bnez	a5,ffffffffc0202a6e <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202a2a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202a2c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0202a30:	02850663          	beq	a0,s0,ffffffffc0202a5c <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202a34:	ff043603          	ld	a2,-16(s0)
ffffffffc0202a38:	fe843583          	ld	a1,-24(s0)
ffffffffc0202a3c:	854a                	mv	a0,s2
ffffffffc0202a3e:	f52fe0ef          	jal	ra,ffffffffc0201190 <unmap_range>
ffffffffc0202a42:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202a44:	fe8498e3          	bne	s1,s0,ffffffffc0202a34 <exit_mmap+0x1c>
ffffffffc0202a48:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202a4a:	00848c63          	beq	s1,s0,ffffffffc0202a62 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202a4e:	ff043603          	ld	a2,-16(s0)
ffffffffc0202a52:	fe843583          	ld	a1,-24(s0)
ffffffffc0202a56:	854a                	mv	a0,s2
ffffffffc0202a58:	851fe0ef          	jal	ra,ffffffffc02012a8 <exit_range>
ffffffffc0202a5c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202a5e:	fe8498e3          	bne	s1,s0,ffffffffc0202a4e <exit_mmap+0x36>
    }
}
ffffffffc0202a62:	60e2                	ld	ra,24(sp)
ffffffffc0202a64:	6442                	ld	s0,16(sp)
ffffffffc0202a66:	64a2                	ld	s1,8(sp)
ffffffffc0202a68:	6902                	ld	s2,0(sp)
ffffffffc0202a6a:	6105                	addi	sp,sp,32
ffffffffc0202a6c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202a6e:	00005697          	auipc	a3,0x5
ffffffffc0202a72:	c5a68693          	addi	a3,a3,-934 # ffffffffc02076c8 <commands+0x1168>
ffffffffc0202a76:	00004617          	auipc	a2,0x4
ffffffffc0202a7a:	f6a60613          	addi	a2,a2,-150 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202a7e:	0d600593          	li	a1,214
ffffffffc0202a82:	00005517          	auipc	a0,0x5
ffffffffc0202a86:	b7650513          	addi	a0,a0,-1162 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202a8a:	f8cfd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202a8e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202a8e:	7139                	addi	sp,sp,-64
ffffffffc0202a90:	f822                	sd	s0,48(sp)
ffffffffc0202a92:	f426                	sd	s1,40(sp)
ffffffffc0202a94:	fc06                	sd	ra,56(sp)
ffffffffc0202a96:	f04a                	sd	s2,32(sp)
ffffffffc0202a98:	ec4e                	sd	s3,24(sp)
ffffffffc0202a9a:	e852                	sd	s4,16(sp)
ffffffffc0202a9c:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202a9e:	c55ff0ef          	jal	ra,ffffffffc02026f2 <mm_create>
    assert(mm != NULL);
ffffffffc0202aa2:	842a                	mv	s0,a0
ffffffffc0202aa4:	03200493          	li	s1,50
ffffffffc0202aa8:	e919                	bnez	a0,ffffffffc0202abe <vmm_init+0x30>
ffffffffc0202aaa:	a989                	j	ffffffffc0202efc <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0202aac:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202aae:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202ab0:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202ab4:	14ed                	addi	s1,s1,-5
ffffffffc0202ab6:	8522                	mv	a0,s0
ffffffffc0202ab8:	cf3ff0ef          	jal	ra,ffffffffc02027aa <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202abc:	c88d                	beqz	s1,ffffffffc0202aee <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202abe:	03000513          	li	a0,48
ffffffffc0202ac2:	11b000ef          	jal	ra,ffffffffc02033dc <kmalloc>
ffffffffc0202ac6:	85aa                	mv	a1,a0
ffffffffc0202ac8:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0202acc:	f165                	bnez	a0,ffffffffc0202aac <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202ace:	00005697          	auipc	a3,0x5
ffffffffc0202ad2:	eba68693          	addi	a3,a3,-326 # ffffffffc0207988 <commands+0x1428>
ffffffffc0202ad6:	00004617          	auipc	a2,0x4
ffffffffc0202ada:	f0a60613          	addi	a2,a2,-246 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202ade:	11300593          	li	a1,275
ffffffffc0202ae2:	00005517          	auipc	a0,0x5
ffffffffc0202ae6:	b1650513          	addi	a0,a0,-1258 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202aea:	f2cfd0ef          	jal	ra,ffffffffc0200216 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0202aee:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202af2:	1f900913          	li	s2,505
ffffffffc0202af6:	a819                	j	ffffffffc0202b0c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202af8:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202afa:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202afc:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202b00:	0495                	addi	s1,s1,5
ffffffffc0202b02:	8522                	mv	a0,s0
ffffffffc0202b04:	ca7ff0ef          	jal	ra,ffffffffc02027aa <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202b08:	03248a63          	beq	s1,s2,ffffffffc0202b3c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202b0c:	03000513          	li	a0,48
ffffffffc0202b10:	0cd000ef          	jal	ra,ffffffffc02033dc <kmalloc>
ffffffffc0202b14:	85aa                	mv	a1,a0
ffffffffc0202b16:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0202b1a:	fd79                	bnez	a0,ffffffffc0202af8 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0202b1c:	00005697          	auipc	a3,0x5
ffffffffc0202b20:	e6c68693          	addi	a3,a3,-404 # ffffffffc0207988 <commands+0x1428>
ffffffffc0202b24:	00004617          	auipc	a2,0x4
ffffffffc0202b28:	ebc60613          	addi	a2,a2,-324 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202b2c:	11900593          	li	a1,281
ffffffffc0202b30:	00005517          	auipc	a0,0x5
ffffffffc0202b34:	ac850513          	addi	a0,a0,-1336 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202b38:	edefd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0202b3c:	6418                	ld	a4,8(s0)
ffffffffc0202b3e:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0202b40:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202b44:	2ee40063          	beq	s0,a4,ffffffffc0202e24 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202b48:	fe873603          	ld	a2,-24(a4)
ffffffffc0202b4c:	ffe78693          	addi	a3,a5,-2
ffffffffc0202b50:	24d61a63          	bne	a2,a3,ffffffffc0202da4 <vmm_init+0x316>
ffffffffc0202b54:	ff073683          	ld	a3,-16(a4)
ffffffffc0202b58:	24f69663          	bne	a3,a5,ffffffffc0202da4 <vmm_init+0x316>
ffffffffc0202b5c:	0795                	addi	a5,a5,5
ffffffffc0202b5e:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0202b60:	feb792e3          	bne	a5,a1,ffffffffc0202b44 <vmm_init+0xb6>
ffffffffc0202b64:	491d                	li	s2,7
ffffffffc0202b66:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202b68:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202b6c:	85a6                	mv	a1,s1
ffffffffc0202b6e:	8522                	mv	a0,s0
ffffffffc0202b70:	bfdff0ef          	jal	ra,ffffffffc020276c <find_vma>
ffffffffc0202b74:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0202b76:	30050763          	beqz	a0,ffffffffc0202e84 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202b7a:	00148593          	addi	a1,s1,1
ffffffffc0202b7e:	8522                	mv	a0,s0
ffffffffc0202b80:	bedff0ef          	jal	ra,ffffffffc020276c <find_vma>
ffffffffc0202b84:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202b86:	2c050f63          	beqz	a0,ffffffffc0202e64 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202b8a:	85ca                	mv	a1,s2
ffffffffc0202b8c:	8522                	mv	a0,s0
ffffffffc0202b8e:	bdfff0ef          	jal	ra,ffffffffc020276c <find_vma>
        assert(vma3 == NULL);
ffffffffc0202b92:	2a051963          	bnez	a0,ffffffffc0202e44 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0202b96:	00348593          	addi	a1,s1,3
ffffffffc0202b9a:	8522                	mv	a0,s0
ffffffffc0202b9c:	bd1ff0ef          	jal	ra,ffffffffc020276c <find_vma>
        assert(vma4 == NULL);
ffffffffc0202ba0:	32051263          	bnez	a0,ffffffffc0202ec4 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202ba4:	00448593          	addi	a1,s1,4
ffffffffc0202ba8:	8522                	mv	a0,s0
ffffffffc0202baa:	bc3ff0ef          	jal	ra,ffffffffc020276c <find_vma>
        assert(vma5 == NULL);
ffffffffc0202bae:	2e051b63          	bnez	a0,ffffffffc0202ea4 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202bb2:	008a3783          	ld	a5,8(s4)
ffffffffc0202bb6:	20979763          	bne	a5,s1,ffffffffc0202dc4 <vmm_init+0x336>
ffffffffc0202bba:	010a3783          	ld	a5,16(s4)
ffffffffc0202bbe:	21279363          	bne	a5,s2,ffffffffc0202dc4 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202bc2:	0089b783          	ld	a5,8(s3)
ffffffffc0202bc6:	20979f63          	bne	a5,s1,ffffffffc0202de4 <vmm_init+0x356>
ffffffffc0202bca:	0109b783          	ld	a5,16(s3)
ffffffffc0202bce:	21279b63          	bne	a5,s2,ffffffffc0202de4 <vmm_init+0x356>
ffffffffc0202bd2:	0495                	addi	s1,s1,5
ffffffffc0202bd4:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202bd6:	f9549be3          	bne	s1,s5,ffffffffc0202b6c <vmm_init+0xde>
ffffffffc0202bda:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202bdc:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202bde:	85a6                	mv	a1,s1
ffffffffc0202be0:	8522                	mv	a0,s0
ffffffffc0202be2:	b8bff0ef          	jal	ra,ffffffffc020276c <find_vma>
ffffffffc0202be6:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0202bea:	c90d                	beqz	a0,ffffffffc0202c1c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0202bec:	6914                	ld	a3,16(a0)
ffffffffc0202bee:	6510                	ld	a2,8(a0)
ffffffffc0202bf0:	00005517          	auipc	a0,0x5
ffffffffc0202bf4:	c8050513          	addi	a0,a0,-896 # ffffffffc0207870 <commands+0x1310>
ffffffffc0202bf8:	cd8fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0202bfc:	00005697          	auipc	a3,0x5
ffffffffc0202c00:	c9c68693          	addi	a3,a3,-868 # ffffffffc0207898 <commands+0x1338>
ffffffffc0202c04:	00004617          	auipc	a2,0x4
ffffffffc0202c08:	ddc60613          	addi	a2,a2,-548 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202c0c:	13b00593          	li	a1,315
ffffffffc0202c10:	00005517          	auipc	a0,0x5
ffffffffc0202c14:	9e850513          	addi	a0,a0,-1560 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202c18:	dfefd0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0202c1c:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0202c1e:	fd2490e3          	bne	s1,s2,ffffffffc0202bde <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202c22:	8522                	mv	a0,s0
ffffffffc0202c24:	c55ff0ef          	jal	ra,ffffffffc0202878 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202c28:	00005517          	auipc	a0,0x5
ffffffffc0202c2c:	c8850513          	addi	a0,a0,-888 # ffffffffc02078b0 <commands+0x1350>
ffffffffc0202c30:	ca0fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202c34:	ae8fe0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>
ffffffffc0202c38:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0202c3a:	ab9ff0ef          	jal	ra,ffffffffc02026f2 <mm_create>
ffffffffc0202c3e:	000aa797          	auipc	a5,0xaa
ffffffffc0202c42:	9ca7b923          	sd	a0,-1582(a5) # ffffffffc02ac610 <check_mm_struct>
ffffffffc0202c46:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0202c48:	36050663          	beqz	a0,ffffffffc0202fb4 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c4c:	000aa797          	auipc	a5,0xaa
ffffffffc0202c50:	93c78793          	addi	a5,a5,-1732 # ffffffffc02ac588 <boot_pgdir>
ffffffffc0202c54:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0202c58:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c5c:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202c60:	2c079e63          	bnez	a5,ffffffffc0202f3c <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202c64:	03000513          	li	a0,48
ffffffffc0202c68:	774000ef          	jal	ra,ffffffffc02033dc <kmalloc>
ffffffffc0202c6c:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0202c6e:	18050b63          	beqz	a0,ffffffffc0202e04 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0202c72:	002007b7          	lui	a5,0x200
ffffffffc0202c76:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0202c78:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202c7a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202c7c:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202c7e:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0202c80:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202c84:	b27ff0ef          	jal	ra,ffffffffc02027aa <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202c88:	10000593          	li	a1,256
ffffffffc0202c8c:	8526                	mv	a0,s1
ffffffffc0202c8e:	adfff0ef          	jal	ra,ffffffffc020276c <find_vma>
ffffffffc0202c92:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0202c96:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202c9a:	2ca41163          	bne	s0,a0,ffffffffc0202f5c <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0202c9e:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5570>
        sum += i;
ffffffffc0202ca2:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0202ca4:	fee79de3          	bne	a5,a4,ffffffffc0202c9e <vmm_init+0x210>
        sum += i;
ffffffffc0202ca8:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0202caa:	10000793          	li	a5,256
        sum += i;
ffffffffc0202cae:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8232>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202cb2:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202cb6:	0007c683          	lbu	a3,0(a5)
ffffffffc0202cba:	0785                	addi	a5,a5,1
ffffffffc0202cbc:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202cbe:	fec79ce3          	bne	a5,a2,ffffffffc0202cb6 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0202cc2:	2c071963          	bnez	a4,ffffffffc0202f94 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cc6:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202cca:	000aaa97          	auipc	s5,0xaa
ffffffffc0202cce:	8c6a8a93          	addi	s5,s5,-1850 # ffffffffc02ac590 <npage>
ffffffffc0202cd2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cd6:	078a                	slli	a5,a5,0x2
ffffffffc0202cd8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202cda:	20e7f563          	bleu	a4,a5,ffffffffc0202ee4 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cde:	00006697          	auipc	a3,0x6
ffffffffc0202ce2:	d8a68693          	addi	a3,a3,-630 # ffffffffc0208a68 <nbase>
ffffffffc0202ce6:	0006ba03          	ld	s4,0(a3)
ffffffffc0202cea:	414786b3          	sub	a3,a5,s4
ffffffffc0202cee:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202cf0:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202cf2:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202cf4:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0202cf6:	83b1                	srli	a5,a5,0xc
ffffffffc0202cf8:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cfa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202cfc:	28e7f063          	bleu	a4,a5,ffffffffc0202f7c <vmm_init+0x4ee>
ffffffffc0202d00:	000aa797          	auipc	a5,0xaa
ffffffffc0202d04:	8e878793          	addi	a5,a5,-1816 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0202d08:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202d0a:	4581                	li	a1,0
ffffffffc0202d0c:	854a                	mv	a0,s2
ffffffffc0202d0e:	9436                	add	s0,s0,a3
ffffffffc0202d10:	981fe0ef          	jal	ra,ffffffffc0201690 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d14:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202d16:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d1a:	078a                	slli	a5,a5,0x2
ffffffffc0202d1c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d1e:	1ce7f363          	bleu	a4,a5,ffffffffc0202ee4 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d22:	000aa417          	auipc	s0,0xaa
ffffffffc0202d26:	8d640413          	addi	s0,s0,-1834 # ffffffffc02ac5f8 <pages>
ffffffffc0202d2a:	6008                	ld	a0,0(s0)
ffffffffc0202d2c:	414787b3          	sub	a5,a5,s4
ffffffffc0202d30:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202d32:	953e                	add	a0,a0,a5
ffffffffc0202d34:	4585                	li	a1,1
ffffffffc0202d36:	9a0fe0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d3a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202d3e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d42:	078a                	slli	a5,a5,0x2
ffffffffc0202d44:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d46:	18e7ff63          	bleu	a4,a5,ffffffffc0202ee4 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d4a:	6008                	ld	a0,0(s0)
ffffffffc0202d4c:	414787b3          	sub	a5,a5,s4
ffffffffc0202d50:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202d52:	4585                	li	a1,1
ffffffffc0202d54:	953e                	add	a0,a0,a5
ffffffffc0202d56:	980fe0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    pgdir[0] = 0;
ffffffffc0202d5a:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202d5e:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202d62:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202d66:	8526                	mv	a0,s1
ffffffffc0202d68:	b11ff0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202d6c:	000aa797          	auipc	a5,0xaa
ffffffffc0202d70:	8a07b223          	sd	zero,-1884(a5) # ffffffffc02ac610 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202d74:	9a8fe0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>
ffffffffc0202d78:	1aa99263          	bne	s3,a0,ffffffffc0202f1c <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202d7c:	00005517          	auipc	a0,0x5
ffffffffc0202d80:	bd450513          	addi	a0,a0,-1068 # ffffffffc0207950 <commands+0x13f0>
ffffffffc0202d84:	b4cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202d88:	7442                	ld	s0,48(sp)
ffffffffc0202d8a:	70e2                	ld	ra,56(sp)
ffffffffc0202d8c:	74a2                	ld	s1,40(sp)
ffffffffc0202d8e:	7902                	ld	s2,32(sp)
ffffffffc0202d90:	69e2                	ld	s3,24(sp)
ffffffffc0202d92:	6a42                	ld	s4,16(sp)
ffffffffc0202d94:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202d96:	00005517          	auipc	a0,0x5
ffffffffc0202d9a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0207970 <commands+0x1410>
}
ffffffffc0202d9e:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202da0:	b30fd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202da4:	00005697          	auipc	a3,0x5
ffffffffc0202da8:	9e468693          	addi	a3,a3,-1564 # ffffffffc0207788 <commands+0x1228>
ffffffffc0202dac:	00004617          	auipc	a2,0x4
ffffffffc0202db0:	c3460613          	addi	a2,a2,-972 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202db4:	12200593          	li	a1,290
ffffffffc0202db8:	00005517          	auipc	a0,0x5
ffffffffc0202dbc:	84050513          	addi	a0,a0,-1984 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202dc0:	c56fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202dc4:	00005697          	auipc	a3,0x5
ffffffffc0202dc8:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0207810 <commands+0x12b0>
ffffffffc0202dcc:	00004617          	auipc	a2,0x4
ffffffffc0202dd0:	c1460613          	addi	a2,a2,-1004 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202dd4:	13200593          	li	a1,306
ffffffffc0202dd8:	00005517          	auipc	a0,0x5
ffffffffc0202ddc:	82050513          	addi	a0,a0,-2016 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202de0:	c36fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202de4:	00005697          	auipc	a3,0x5
ffffffffc0202de8:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0207840 <commands+0x12e0>
ffffffffc0202dec:	00004617          	auipc	a2,0x4
ffffffffc0202df0:	bf460613          	addi	a2,a2,-1036 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202df4:	13300593          	li	a1,307
ffffffffc0202df8:	00005517          	auipc	a0,0x5
ffffffffc0202dfc:	80050513          	addi	a0,a0,-2048 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202e00:	c16fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(vma != NULL);
ffffffffc0202e04:	00005697          	auipc	a3,0x5
ffffffffc0202e08:	b8468693          	addi	a3,a3,-1148 # ffffffffc0207988 <commands+0x1428>
ffffffffc0202e0c:	00004617          	auipc	a2,0x4
ffffffffc0202e10:	bd460613          	addi	a2,a2,-1068 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202e14:	15200593          	li	a1,338
ffffffffc0202e18:	00004517          	auipc	a0,0x4
ffffffffc0202e1c:	7e050513          	addi	a0,a0,2016 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202e20:	bf6fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202e24:	00005697          	auipc	a3,0x5
ffffffffc0202e28:	94c68693          	addi	a3,a3,-1716 # ffffffffc0207770 <commands+0x1210>
ffffffffc0202e2c:	00004617          	auipc	a2,0x4
ffffffffc0202e30:	bb460613          	addi	a2,a2,-1100 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202e34:	12000593          	li	a1,288
ffffffffc0202e38:	00004517          	auipc	a0,0x4
ffffffffc0202e3c:	7c050513          	addi	a0,a0,1984 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202e40:	bd6fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma3 == NULL);
ffffffffc0202e44:	00005697          	auipc	a3,0x5
ffffffffc0202e48:	99c68693          	addi	a3,a3,-1636 # ffffffffc02077e0 <commands+0x1280>
ffffffffc0202e4c:	00004617          	auipc	a2,0x4
ffffffffc0202e50:	b9460613          	addi	a2,a2,-1132 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202e54:	12c00593          	li	a1,300
ffffffffc0202e58:	00004517          	auipc	a0,0x4
ffffffffc0202e5c:	7a050513          	addi	a0,a0,1952 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202e60:	bb6fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma2 != NULL);
ffffffffc0202e64:	00005697          	auipc	a3,0x5
ffffffffc0202e68:	96c68693          	addi	a3,a3,-1684 # ffffffffc02077d0 <commands+0x1270>
ffffffffc0202e6c:	00004617          	auipc	a2,0x4
ffffffffc0202e70:	b7460613          	addi	a2,a2,-1164 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202e74:	12a00593          	li	a1,298
ffffffffc0202e78:	00004517          	auipc	a0,0x4
ffffffffc0202e7c:	78050513          	addi	a0,a0,1920 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202e80:	b96fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma1 != NULL);
ffffffffc0202e84:	00005697          	auipc	a3,0x5
ffffffffc0202e88:	93c68693          	addi	a3,a3,-1732 # ffffffffc02077c0 <commands+0x1260>
ffffffffc0202e8c:	00004617          	auipc	a2,0x4
ffffffffc0202e90:	b5460613          	addi	a2,a2,-1196 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202e94:	12800593          	li	a1,296
ffffffffc0202e98:	00004517          	auipc	a0,0x4
ffffffffc0202e9c:	76050513          	addi	a0,a0,1888 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202ea0:	b76fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma5 == NULL);
ffffffffc0202ea4:	00005697          	auipc	a3,0x5
ffffffffc0202ea8:	95c68693          	addi	a3,a3,-1700 # ffffffffc0207800 <commands+0x12a0>
ffffffffc0202eac:	00004617          	auipc	a2,0x4
ffffffffc0202eb0:	b3460613          	addi	a2,a2,-1228 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202eb4:	13000593          	li	a1,304
ffffffffc0202eb8:	00004517          	auipc	a0,0x4
ffffffffc0202ebc:	74050513          	addi	a0,a0,1856 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202ec0:	b56fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        assert(vma4 == NULL);
ffffffffc0202ec4:	00005697          	auipc	a3,0x5
ffffffffc0202ec8:	92c68693          	addi	a3,a3,-1748 # ffffffffc02077f0 <commands+0x1290>
ffffffffc0202ecc:	00004617          	auipc	a2,0x4
ffffffffc0202ed0:	b1460613          	addi	a2,a2,-1260 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202ed4:	12e00593          	li	a1,302
ffffffffc0202ed8:	00004517          	auipc	a0,0x4
ffffffffc0202edc:	72050513          	addi	a0,a0,1824 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202ee0:	b36fd0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202ee4:	00004617          	auipc	a2,0x4
ffffffffc0202ee8:	f3460613          	addi	a2,a2,-204 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc0202eec:	06200593          	li	a1,98
ffffffffc0202ef0:	00004517          	auipc	a0,0x4
ffffffffc0202ef4:	f4850513          	addi	a0,a0,-184 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0202ef8:	b1efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(mm != NULL);
ffffffffc0202efc:	00005697          	auipc	a3,0x5
ffffffffc0202f00:	86468693          	addi	a3,a3,-1948 # ffffffffc0207760 <commands+0x1200>
ffffffffc0202f04:	00004617          	auipc	a2,0x4
ffffffffc0202f08:	adc60613          	addi	a2,a2,-1316 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202f0c:	10c00593          	li	a1,268
ffffffffc0202f10:	00004517          	auipc	a0,0x4
ffffffffc0202f14:	6e850513          	addi	a0,a0,1768 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202f18:	afefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202f1c:	00005697          	auipc	a3,0x5
ffffffffc0202f20:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0207928 <commands+0x13c8>
ffffffffc0202f24:	00004617          	auipc	a2,0x4
ffffffffc0202f28:	abc60613          	addi	a2,a2,-1348 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202f2c:	17000593          	li	a1,368
ffffffffc0202f30:	00004517          	auipc	a0,0x4
ffffffffc0202f34:	6c850513          	addi	a0,a0,1736 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202f38:	adefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202f3c:	00005697          	auipc	a3,0x5
ffffffffc0202f40:	9ac68693          	addi	a3,a3,-1620 # ffffffffc02078e8 <commands+0x1388>
ffffffffc0202f44:	00004617          	auipc	a2,0x4
ffffffffc0202f48:	a9c60613          	addi	a2,a2,-1380 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202f4c:	14f00593          	li	a1,335
ffffffffc0202f50:	00004517          	auipc	a0,0x4
ffffffffc0202f54:	6a850513          	addi	a0,a0,1704 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202f58:	abefd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202f5c:	00005697          	auipc	a3,0x5
ffffffffc0202f60:	99c68693          	addi	a3,a3,-1636 # ffffffffc02078f8 <commands+0x1398>
ffffffffc0202f64:	00004617          	auipc	a2,0x4
ffffffffc0202f68:	a7c60613          	addi	a2,a2,-1412 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202f6c:	15700593          	li	a1,343
ffffffffc0202f70:	00004517          	auipc	a0,0x4
ffffffffc0202f74:	68850513          	addi	a0,a0,1672 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202f78:	a9efd0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f7c:	00004617          	auipc	a2,0x4
ffffffffc0202f80:	e6460613          	addi	a2,a2,-412 # ffffffffc0206de0 <commands+0x880>
ffffffffc0202f84:	06900593          	li	a1,105
ffffffffc0202f88:	00004517          	auipc	a0,0x4
ffffffffc0202f8c:	eb050513          	addi	a0,a0,-336 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0202f90:	a86fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(sum == 0);
ffffffffc0202f94:	00005697          	auipc	a3,0x5
ffffffffc0202f98:	98468693          	addi	a3,a3,-1660 # ffffffffc0207918 <commands+0x13b8>
ffffffffc0202f9c:	00004617          	auipc	a2,0x4
ffffffffc0202fa0:	a4460613          	addi	a2,a2,-1468 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202fa4:	16300593          	li	a1,355
ffffffffc0202fa8:	00004517          	auipc	a0,0x4
ffffffffc0202fac:	65050513          	addi	a0,a0,1616 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202fb0:	a66fd0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202fb4:	00005697          	auipc	a3,0x5
ffffffffc0202fb8:	91c68693          	addi	a3,a3,-1764 # ffffffffc02078d0 <commands+0x1370>
ffffffffc0202fbc:	00004617          	auipc	a2,0x4
ffffffffc0202fc0:	a2460613          	addi	a2,a2,-1500 # ffffffffc02069e0 <commands+0x480>
ffffffffc0202fc4:	14b00593          	li	a1,331
ffffffffc0202fc8:	00004517          	auipc	a0,0x4
ffffffffc0202fcc:	63050513          	addi	a0,a0,1584 # ffffffffc02075f8 <commands+0x1098>
ffffffffc0202fd0:	a46fd0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0202fd4 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202fd4:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202fd6:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202fd8:	e822                	sd	s0,16(sp)
ffffffffc0202fda:	e426                	sd	s1,8(sp)
ffffffffc0202fdc:	ec06                	sd	ra,24(sp)
ffffffffc0202fde:	e04a                	sd	s2,0(sp)
ffffffffc0202fe0:	8432                	mv	s0,a2
ffffffffc0202fe2:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202fe4:	f88ff0ef          	jal	ra,ffffffffc020276c <find_vma>

    pgfault_num++;
ffffffffc0202fe8:	000a9797          	auipc	a5,0xa9
ffffffffc0202fec:	5b078793          	addi	a5,a5,1456 # ffffffffc02ac598 <pgfault_num>
ffffffffc0202ff0:	439c                	lw	a5,0(a5)
ffffffffc0202ff2:	2785                	addiw	a5,a5,1
ffffffffc0202ff4:	000a9717          	auipc	a4,0xa9
ffffffffc0202ff8:	5af72223          	sw	a5,1444(a4) # ffffffffc02ac598 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202ffc:	cd21                	beqz	a0,ffffffffc0203054 <do_pgfault+0x80>
ffffffffc0202ffe:	651c                	ld	a5,8(a0)
ffffffffc0203000:	04f46a63          	bltu	s0,a5,ffffffffc0203054 <do_pgfault+0x80>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203004:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203006:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203008:	8b89                	andi	a5,a5,2
ffffffffc020300a:	e78d                	bnez	a5,ffffffffc0203034 <do_pgfault+0x60>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020300c:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020300e:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203010:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203012:	85a2                	mv	a1,s0
ffffffffc0203014:	4605                	li	a2,1
ffffffffc0203016:	f47fd0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc020301a:	cd31                	beqz	a0,ffffffffc0203076 <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc020301c:	610c                	ld	a1,0(a0)
ffffffffc020301e:	cd89                	beqz	a1,ffffffffc0203038 <do_pgfault+0x64>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203020:	000a9797          	auipc	a5,0xa9
ffffffffc0203024:	59078793          	addi	a5,a5,1424 # ffffffffc02ac5b0 <swap_init_ok>
ffffffffc0203028:	439c                	lw	a5,0(a5)
ffffffffc020302a:	2781                	sext.w	a5,a5
ffffffffc020302c:	cf8d                	beqz	a5,ffffffffc0203066 <do_pgfault+0x92>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc020302e:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9550>
ffffffffc0203032:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0203034:	495d                	li	s2,23
ffffffffc0203036:	bfd9                	j	ffffffffc020300c <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203038:	6c88                	ld	a0,24(s1)
ffffffffc020303a:	864a                	mv	a2,s2
ffffffffc020303c:	85a2                	mv	a1,s0
ffffffffc020303e:	a14ff0ef          	jal	ra,ffffffffc0202252 <pgdir_alloc_page>
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0203042:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203044:	c129                	beqz	a0,ffffffffc0203086 <do_pgfault+0xb2>
failed:
    return ret;
}
ffffffffc0203046:	60e2                	ld	ra,24(sp)
ffffffffc0203048:	6442                	ld	s0,16(sp)
ffffffffc020304a:	64a2                	ld	s1,8(sp)
ffffffffc020304c:	6902                	ld	s2,0(sp)
ffffffffc020304e:	853e                	mv	a0,a5
ffffffffc0203050:	6105                	addi	sp,sp,32
ffffffffc0203052:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203054:	85a2                	mv	a1,s0
ffffffffc0203056:	00004517          	auipc	a0,0x4
ffffffffc020305a:	5b250513          	addi	a0,a0,1458 # ffffffffc0207608 <commands+0x10a8>
ffffffffc020305e:	872fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203062:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203064:	b7cd                	j	ffffffffc0203046 <do_pgfault+0x72>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203066:	00004517          	auipc	a0,0x4
ffffffffc020306a:	61a50513          	addi	a0,a0,1562 # ffffffffc0207680 <commands+0x1120>
ffffffffc020306e:	862fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203072:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203074:	bfc9                	j	ffffffffc0203046 <do_pgfault+0x72>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203076:	00004517          	auipc	a0,0x4
ffffffffc020307a:	5c250513          	addi	a0,a0,1474 # ffffffffc0207638 <commands+0x10d8>
ffffffffc020307e:	852fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203082:	57f1                	li	a5,-4
        goto failed;
ffffffffc0203084:	b7c9                	j	ffffffffc0203046 <do_pgfault+0x72>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203086:	00004517          	auipc	a0,0x4
ffffffffc020308a:	5d250513          	addi	a0,a0,1490 # ffffffffc0207658 <commands+0x10f8>
ffffffffc020308e:	842fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203092:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203094:	bf4d                	j	ffffffffc0203046 <do_pgfault+0x72>

ffffffffc0203096 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0203096:	7179                	addi	sp,sp,-48
ffffffffc0203098:	f022                	sd	s0,32(sp)
ffffffffc020309a:	f406                	sd	ra,40(sp)
ffffffffc020309c:	ec26                	sd	s1,24(sp)
ffffffffc020309e:	e84a                	sd	s2,16(sp)
ffffffffc02030a0:	e44e                	sd	s3,8(sp)
ffffffffc02030a2:	e052                	sd	s4,0(sp)
ffffffffc02030a4:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc02030a6:	c135                	beqz	a0,ffffffffc020310a <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc02030a8:	002007b7          	lui	a5,0x200
ffffffffc02030ac:	04f5e663          	bltu	a1,a5,ffffffffc02030f8 <user_mem_check+0x62>
ffffffffc02030b0:	00c584b3          	add	s1,a1,a2
ffffffffc02030b4:	0495f263          	bleu	s1,a1,ffffffffc02030f8 <user_mem_check+0x62>
ffffffffc02030b8:	4785                	li	a5,1
ffffffffc02030ba:	07fe                	slli	a5,a5,0x1f
ffffffffc02030bc:	0297ee63          	bltu	a5,s1,ffffffffc02030f8 <user_mem_check+0x62>
ffffffffc02030c0:	892a                	mv	s2,a0
ffffffffc02030c2:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02030c4:	6a05                	lui	s4,0x1
ffffffffc02030c6:	a821                	j	ffffffffc02030de <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02030c8:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02030cc:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02030ce:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02030d0:	c685                	beqz	a3,ffffffffc02030f8 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02030d2:	c399                	beqz	a5,ffffffffc02030d8 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02030d4:	02e46263          	bltu	s0,a4,ffffffffc02030f8 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02030d8:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc02030da:	04947663          	bleu	s1,s0,ffffffffc0203126 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc02030de:	85a2                	mv	a1,s0
ffffffffc02030e0:	854a                	mv	a0,s2
ffffffffc02030e2:	e8aff0ef          	jal	ra,ffffffffc020276c <find_vma>
ffffffffc02030e6:	c909                	beqz	a0,ffffffffc02030f8 <user_mem_check+0x62>
ffffffffc02030e8:	6518                	ld	a4,8(a0)
ffffffffc02030ea:	00e46763          	bltu	s0,a4,ffffffffc02030f8 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02030ee:	4d1c                	lw	a5,24(a0)
ffffffffc02030f0:	fc099ce3          	bnez	s3,ffffffffc02030c8 <user_mem_check+0x32>
ffffffffc02030f4:	8b85                	andi	a5,a5,1
ffffffffc02030f6:	f3ed                	bnez	a5,ffffffffc02030d8 <user_mem_check+0x42>
            return 0;
ffffffffc02030f8:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02030fa:	70a2                	ld	ra,40(sp)
ffffffffc02030fc:	7402                	ld	s0,32(sp)
ffffffffc02030fe:	64e2                	ld	s1,24(sp)
ffffffffc0203100:	6942                	ld	s2,16(sp)
ffffffffc0203102:	69a2                	ld	s3,8(sp)
ffffffffc0203104:	6a02                	ld	s4,0(sp)
ffffffffc0203106:	6145                	addi	sp,sp,48
ffffffffc0203108:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc020310a:	c02007b7          	lui	a5,0xc0200
ffffffffc020310e:	4501                	li	a0,0
ffffffffc0203110:	fef5e5e3          	bltu	a1,a5,ffffffffc02030fa <user_mem_check+0x64>
ffffffffc0203114:	962e                	add	a2,a2,a1
ffffffffc0203116:	fec5f2e3          	bleu	a2,a1,ffffffffc02030fa <user_mem_check+0x64>
ffffffffc020311a:	c8000537          	lui	a0,0xc8000
ffffffffc020311e:	0505                	addi	a0,a0,1
ffffffffc0203120:	00a63533          	sltu	a0,a2,a0
ffffffffc0203124:	bfd9                	j	ffffffffc02030fa <user_mem_check+0x64>
        return 1;
ffffffffc0203126:	4505                	li	a0,1
ffffffffc0203128:	bfc9                	j	ffffffffc02030fa <user_mem_check+0x64>

ffffffffc020312a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020312a:	c125                	beqz	a0,ffffffffc020318a <slob_free+0x60>
		return;

	if (size)
ffffffffc020312c:	e1a5                	bnez	a1,ffffffffc020318c <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020312e:	100027f3          	csrr	a5,sstatus
ffffffffc0203132:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203134:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203136:	e3bd                	bnez	a5,ffffffffc020319c <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203138:	0009e797          	auipc	a5,0x9e
ffffffffc020313c:	03078793          	addi	a5,a5,48 # ffffffffc02a1168 <slobfree>
ffffffffc0203140:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203142:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203144:	00a7fa63          	bleu	a0,a5,ffffffffc0203158 <slob_free+0x2e>
ffffffffc0203148:	00e56c63          	bltu	a0,a4,ffffffffc0203160 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020314c:	00e7fa63          	bleu	a4,a5,ffffffffc0203160 <slob_free+0x36>
    return 0;
ffffffffc0203150:	87ba                	mv	a5,a4
ffffffffc0203152:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203154:	fea7eae3          	bltu	a5,a0,ffffffffc0203148 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203158:	fee7ece3          	bltu	a5,a4,ffffffffc0203150 <slob_free+0x26>
ffffffffc020315c:	fee57ae3          	bleu	a4,a0,ffffffffc0203150 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0203160:	4110                	lw	a2,0(a0)
ffffffffc0203162:	00461693          	slli	a3,a2,0x4
ffffffffc0203166:	96aa                	add	a3,a3,a0
ffffffffc0203168:	08d70b63          	beq	a4,a3,ffffffffc02031fe <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020316c:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc020316e:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203170:	00469713          	slli	a4,a3,0x4
ffffffffc0203174:	973e                	add	a4,a4,a5
ffffffffc0203176:	08e50f63          	beq	a0,a4,ffffffffc0203214 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020317a:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc020317c:	0009e717          	auipc	a4,0x9e
ffffffffc0203180:	fef73623          	sd	a5,-20(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc0203184:	c199                	beqz	a1,ffffffffc020318a <slob_free+0x60>
        intr_enable();
ffffffffc0203186:	cacfd06f          	j	ffffffffc0200632 <intr_enable>
ffffffffc020318a:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc020318c:	05bd                	addi	a1,a1,15
ffffffffc020318e:	8191                	srli	a1,a1,0x4
ffffffffc0203190:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203192:	100027f3          	csrr	a5,sstatus
ffffffffc0203196:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203198:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020319a:	dfd9                	beqz	a5,ffffffffc0203138 <slob_free+0xe>
{
ffffffffc020319c:	1101                	addi	sp,sp,-32
ffffffffc020319e:	e42a                	sd	a0,8(sp)
ffffffffc02031a0:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02031a2:	c96fd0ef          	jal	ra,ffffffffc0200638 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02031a6:	0009e797          	auipc	a5,0x9e
ffffffffc02031aa:	fc278793          	addi	a5,a5,-62 # ffffffffc02a1168 <slobfree>
ffffffffc02031ae:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02031b0:	6522                	ld	a0,8(sp)
ffffffffc02031b2:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02031b4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02031b6:	00a7fa63          	bleu	a0,a5,ffffffffc02031ca <slob_free+0xa0>
ffffffffc02031ba:	00e56c63          	bltu	a0,a4,ffffffffc02031d2 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02031be:	00e7fa63          	bleu	a4,a5,ffffffffc02031d2 <slob_free+0xa8>
    return 0;
ffffffffc02031c2:	87ba                	mv	a5,a4
ffffffffc02031c4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02031c6:	fea7eae3          	bltu	a5,a0,ffffffffc02031ba <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02031ca:	fee7ece3          	bltu	a5,a4,ffffffffc02031c2 <slob_free+0x98>
ffffffffc02031ce:	fee57ae3          	bleu	a4,a0,ffffffffc02031c2 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02031d2:	4110                	lw	a2,0(a0)
ffffffffc02031d4:	00461693          	slli	a3,a2,0x4
ffffffffc02031d8:	96aa                	add	a3,a3,a0
ffffffffc02031da:	04d70763          	beq	a4,a3,ffffffffc0203228 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc02031de:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02031e0:	4394                	lw	a3,0(a5)
ffffffffc02031e2:	00469713          	slli	a4,a3,0x4
ffffffffc02031e6:	973e                	add	a4,a4,a5
ffffffffc02031e8:	04e50663          	beq	a0,a4,ffffffffc0203234 <slob_free+0x10a>
		cur->next = b;
ffffffffc02031ec:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc02031ee:	0009e717          	auipc	a4,0x9e
ffffffffc02031f2:	f6f73d23          	sd	a5,-134(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc02031f6:	e58d                	bnez	a1,ffffffffc0203220 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02031f8:	60e2                	ld	ra,24(sp)
ffffffffc02031fa:	6105                	addi	sp,sp,32
ffffffffc02031fc:	8082                	ret
		b->units += cur->next->units;
ffffffffc02031fe:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203200:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0203202:	9e35                	addw	a2,a2,a3
ffffffffc0203204:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0203206:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203208:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020320a:	00469713          	slli	a4,a3,0x4
ffffffffc020320e:	973e                	add	a4,a4,a5
ffffffffc0203210:	f6e515e3          	bne	a0,a4,ffffffffc020317a <slob_free+0x50>
		cur->units += b->units;
ffffffffc0203214:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203216:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203218:	9eb9                	addw	a3,a3,a4
ffffffffc020321a:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020321c:	e790                	sd	a2,8(a5)
ffffffffc020321e:	bfb9                	j	ffffffffc020317c <slob_free+0x52>
}
ffffffffc0203220:	60e2                	ld	ra,24(sp)
ffffffffc0203222:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203224:	c0efd06f          	j	ffffffffc0200632 <intr_enable>
		b->units += cur->next->units;
ffffffffc0203228:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020322a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020322c:	9e35                	addw	a2,a2,a3
ffffffffc020322e:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0203230:	e518                	sd	a4,8(a0)
ffffffffc0203232:	b77d                	j	ffffffffc02031e0 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0203234:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203236:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203238:	9eb9                	addw	a3,a3,a4
ffffffffc020323a:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020323c:	e790                	sd	a2,8(a5)
ffffffffc020323e:	bf45                	j	ffffffffc02031ee <slob_free+0xc4>

ffffffffc0203240 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203240:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203242:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203244:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203248:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020324a:	c05fd0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
  if(!page)
ffffffffc020324e:	c139                	beqz	a0,ffffffffc0203294 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0203250:	000a9797          	auipc	a5,0xa9
ffffffffc0203254:	3a878793          	addi	a5,a5,936 # ffffffffc02ac5f8 <pages>
ffffffffc0203258:	6394                	ld	a3,0(a5)
ffffffffc020325a:	00006797          	auipc	a5,0x6
ffffffffc020325e:	80e78793          	addi	a5,a5,-2034 # ffffffffc0208a68 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203262:	000a9717          	auipc	a4,0xa9
ffffffffc0203266:	32e70713          	addi	a4,a4,814 # ffffffffc02ac590 <npage>
    return page - pages + nbase;
ffffffffc020326a:	40d506b3          	sub	a3,a0,a3
ffffffffc020326e:	6388                	ld	a0,0(a5)
ffffffffc0203270:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203272:	57fd                	li	a5,-1
ffffffffc0203274:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0203276:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0203278:	83b1                	srli	a5,a5,0xc
ffffffffc020327a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020327c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020327e:	00e7ff63          	bleu	a4,a5,ffffffffc020329c <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0203282:	000a9797          	auipc	a5,0xa9
ffffffffc0203286:	36678793          	addi	a5,a5,870 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc020328a:	6388                	ld	a0,0(a5)
}
ffffffffc020328c:	60a2                	ld	ra,8(sp)
ffffffffc020328e:	9536                	add	a0,a0,a3
ffffffffc0203290:	0141                	addi	sp,sp,16
ffffffffc0203292:	8082                	ret
ffffffffc0203294:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0203296:	4501                	li	a0,0
}
ffffffffc0203298:	0141                	addi	sp,sp,16
ffffffffc020329a:	8082                	ret
ffffffffc020329c:	00004617          	auipc	a2,0x4
ffffffffc02032a0:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206de0 <commands+0x880>
ffffffffc02032a4:	06900593          	li	a1,105
ffffffffc02032a8:	00004517          	auipc	a0,0x4
ffffffffc02032ac:	b9050513          	addi	a0,a0,-1136 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc02032b0:	f67fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02032b4 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02032b4:	7179                	addi	sp,sp,-48
ffffffffc02032b6:	f406                	sd	ra,40(sp)
ffffffffc02032b8:	f022                	sd	s0,32(sp)
ffffffffc02032ba:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02032bc:	01050713          	addi	a4,a0,16
ffffffffc02032c0:	6785                	lui	a5,0x1
ffffffffc02032c2:	0cf77b63          	bleu	a5,a4,ffffffffc0203398 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02032c6:	00f50413          	addi	s0,a0,15
ffffffffc02032ca:	8011                	srli	s0,s0,0x4
ffffffffc02032cc:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02032ce:	10002673          	csrr	a2,sstatus
ffffffffc02032d2:	8a09                	andi	a2,a2,2
ffffffffc02032d4:	ea5d                	bnez	a2,ffffffffc020338a <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc02032d6:	0009e497          	auipc	s1,0x9e
ffffffffc02032da:	e9248493          	addi	s1,s1,-366 # ffffffffc02a1168 <slobfree>
ffffffffc02032de:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02032e0:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02032e2:	4398                	lw	a4,0(a5)
ffffffffc02032e4:	0a875763          	ble	s0,a4,ffffffffc0203392 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc02032e8:	00f68a63          	beq	a3,a5,ffffffffc02032fc <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02032ec:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02032ee:	4118                	lw	a4,0(a0)
ffffffffc02032f0:	02875763          	ble	s0,a4,ffffffffc020331e <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc02032f4:	6094                	ld	a3,0(s1)
ffffffffc02032f6:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc02032f8:	fef69ae3          	bne	a3,a5,ffffffffc02032ec <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc02032fc:	ea39                	bnez	a2,ffffffffc0203352 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02032fe:	4501                	li	a0,0
ffffffffc0203300:	f41ff0ef          	jal	ra,ffffffffc0203240 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0203304:	cd29                	beqz	a0,ffffffffc020335e <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203306:	6585                	lui	a1,0x1
ffffffffc0203308:	e23ff0ef          	jal	ra,ffffffffc020312a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020330c:	10002673          	csrr	a2,sstatus
ffffffffc0203310:	8a09                	andi	a2,a2,2
ffffffffc0203312:	ea1d                	bnez	a2,ffffffffc0203348 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0203314:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203316:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203318:	4118                	lw	a4,0(a0)
ffffffffc020331a:	fc874de3          	blt	a4,s0,ffffffffc02032f4 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc020331e:	04e40663          	beq	s0,a4,ffffffffc020336a <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0203322:	00441693          	slli	a3,s0,0x4
ffffffffc0203326:	96aa                	add	a3,a3,a0
ffffffffc0203328:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc020332a:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc020332c:	9f01                	subw	a4,a4,s0
ffffffffc020332e:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0203330:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0203332:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0203334:	0009e717          	auipc	a4,0x9e
ffffffffc0203338:	e2f73a23          	sd	a5,-460(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc020333c:	ee15                	bnez	a2,ffffffffc0203378 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc020333e:	70a2                	ld	ra,40(sp)
ffffffffc0203340:	7402                	ld	s0,32(sp)
ffffffffc0203342:	64e2                	ld	s1,24(sp)
ffffffffc0203344:	6145                	addi	sp,sp,48
ffffffffc0203346:	8082                	ret
        intr_disable();
ffffffffc0203348:	af0fd0ef          	jal	ra,ffffffffc0200638 <intr_disable>
ffffffffc020334c:	4605                	li	a2,1
			cur = slobfree;
ffffffffc020334e:	609c                	ld	a5,0(s1)
ffffffffc0203350:	b7d9                	j	ffffffffc0203316 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0203352:	ae0fd0ef          	jal	ra,ffffffffc0200632 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203356:	4501                	li	a0,0
ffffffffc0203358:	ee9ff0ef          	jal	ra,ffffffffc0203240 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc020335c:	f54d                	bnez	a0,ffffffffc0203306 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc020335e:	70a2                	ld	ra,40(sp)
ffffffffc0203360:	7402                	ld	s0,32(sp)
ffffffffc0203362:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0203364:	4501                	li	a0,0
}
ffffffffc0203366:	6145                	addi	sp,sp,48
ffffffffc0203368:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020336a:	6518                	ld	a4,8(a0)
ffffffffc020336c:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc020336e:	0009e717          	auipc	a4,0x9e
ffffffffc0203372:	def73d23          	sd	a5,-518(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc0203376:	d661                	beqz	a2,ffffffffc020333e <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0203378:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020337a:	ab8fd0ef          	jal	ra,ffffffffc0200632 <intr_enable>
}
ffffffffc020337e:	70a2                	ld	ra,40(sp)
ffffffffc0203380:	7402                	ld	s0,32(sp)
ffffffffc0203382:	6522                	ld	a0,8(sp)
ffffffffc0203384:	64e2                	ld	s1,24(sp)
ffffffffc0203386:	6145                	addi	sp,sp,48
ffffffffc0203388:	8082                	ret
        intr_disable();
ffffffffc020338a:	aaefd0ef          	jal	ra,ffffffffc0200638 <intr_disable>
ffffffffc020338e:	4605                	li	a2,1
ffffffffc0203390:	b799                	j	ffffffffc02032d6 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203392:	853e                	mv	a0,a5
ffffffffc0203394:	87b6                	mv	a5,a3
ffffffffc0203396:	b761                	j	ffffffffc020331e <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0203398:	00004697          	auipc	a3,0x4
ffffffffc020339c:	62068693          	addi	a3,a3,1568 # ffffffffc02079b8 <commands+0x1458>
ffffffffc02033a0:	00003617          	auipc	a2,0x3
ffffffffc02033a4:	64060613          	addi	a2,a2,1600 # ffffffffc02069e0 <commands+0x480>
ffffffffc02033a8:	06400593          	li	a1,100
ffffffffc02033ac:	00004517          	auipc	a0,0x4
ffffffffc02033b0:	62c50513          	addi	a0,a0,1580 # ffffffffc02079d8 <commands+0x1478>
ffffffffc02033b4:	e63fc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02033b8 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02033b8:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02033ba:	00004517          	auipc	a0,0x4
ffffffffc02033be:	63650513          	addi	a0,a0,1590 # ffffffffc02079f0 <commands+0x1490>
kmalloc_init(void) {
ffffffffc02033c2:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02033c4:	d0dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02033c8:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02033ca:	00004517          	auipc	a0,0x4
ffffffffc02033ce:	5ce50513          	addi	a0,a0,1486 # ffffffffc0207998 <commands+0x1438>
}
ffffffffc02033d2:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02033d4:	cfdfc06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02033d8 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02033d8:	4501                	li	a0,0
ffffffffc02033da:	8082                	ret

ffffffffc02033dc <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02033dc:	1101                	addi	sp,sp,-32
ffffffffc02033de:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02033e0:	6905                	lui	s2,0x1
{
ffffffffc02033e2:	e822                	sd	s0,16(sp)
ffffffffc02033e4:	ec06                	sd	ra,24(sp)
ffffffffc02033e6:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02033e8:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8599>
{
ffffffffc02033ec:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02033ee:	04a7fc63          	bleu	a0,a5,ffffffffc0203446 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02033f2:	4561                	li	a0,24
ffffffffc02033f4:	ec1ff0ef          	jal	ra,ffffffffc02032b4 <slob_alloc.isra.1.constprop.3>
ffffffffc02033f8:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02033fa:	cd21                	beqz	a0,ffffffffc0203452 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02033fc:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0203400:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203402:	00f95763          	ble	a5,s2,ffffffffc0203410 <kmalloc+0x34>
ffffffffc0203406:	6705                	lui	a4,0x1
ffffffffc0203408:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc020340a:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc020340c:	fef74ee3          	blt	a4,a5,ffffffffc0203408 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0203410:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0203412:	e2fff0ef          	jal	ra,ffffffffc0203240 <__slob_get_free_pages.isra.0>
ffffffffc0203416:	e488                	sd	a0,8(s1)
ffffffffc0203418:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc020341a:	c935                	beqz	a0,ffffffffc020348e <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020341c:	100027f3          	csrr	a5,sstatus
ffffffffc0203420:	8b89                	andi	a5,a5,2
ffffffffc0203422:	e3a1                	bnez	a5,ffffffffc0203462 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0203424:	000a9797          	auipc	a5,0xa9
ffffffffc0203428:	17c78793          	addi	a5,a5,380 # ffffffffc02ac5a0 <bigblocks>
ffffffffc020342c:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc020342e:	000a9717          	auipc	a4,0xa9
ffffffffc0203432:	16973923          	sd	s1,370(a4) # ffffffffc02ac5a0 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203436:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203438:	8522                	mv	a0,s0
ffffffffc020343a:	60e2                	ld	ra,24(sp)
ffffffffc020343c:	6442                	ld	s0,16(sp)
ffffffffc020343e:	64a2                	ld	s1,8(sp)
ffffffffc0203440:	6902                	ld	s2,0(sp)
ffffffffc0203442:	6105                	addi	sp,sp,32
ffffffffc0203444:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203446:	0541                	addi	a0,a0,16
ffffffffc0203448:	e6dff0ef          	jal	ra,ffffffffc02032b4 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc020344c:	01050413          	addi	s0,a0,16
ffffffffc0203450:	f565                	bnez	a0,ffffffffc0203438 <kmalloc+0x5c>
ffffffffc0203452:	4401                	li	s0,0
}
ffffffffc0203454:	8522                	mv	a0,s0
ffffffffc0203456:	60e2                	ld	ra,24(sp)
ffffffffc0203458:	6442                	ld	s0,16(sp)
ffffffffc020345a:	64a2                	ld	s1,8(sp)
ffffffffc020345c:	6902                	ld	s2,0(sp)
ffffffffc020345e:	6105                	addi	sp,sp,32
ffffffffc0203460:	8082                	ret
        intr_disable();
ffffffffc0203462:	9d6fd0ef          	jal	ra,ffffffffc0200638 <intr_disable>
		bb->next = bigblocks;
ffffffffc0203466:	000a9797          	auipc	a5,0xa9
ffffffffc020346a:	13a78793          	addi	a5,a5,314 # ffffffffc02ac5a0 <bigblocks>
ffffffffc020346e:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203470:	000a9717          	auipc	a4,0xa9
ffffffffc0203474:	12973823          	sd	s1,304(a4) # ffffffffc02ac5a0 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203478:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc020347a:	9b8fd0ef          	jal	ra,ffffffffc0200632 <intr_enable>
ffffffffc020347e:	6480                	ld	s0,8(s1)
}
ffffffffc0203480:	60e2                	ld	ra,24(sp)
ffffffffc0203482:	64a2                	ld	s1,8(sp)
ffffffffc0203484:	8522                	mv	a0,s0
ffffffffc0203486:	6442                	ld	s0,16(sp)
ffffffffc0203488:	6902                	ld	s2,0(sp)
ffffffffc020348a:	6105                	addi	sp,sp,32
ffffffffc020348c:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020348e:	45e1                	li	a1,24
ffffffffc0203490:	8526                	mv	a0,s1
ffffffffc0203492:	c99ff0ef          	jal	ra,ffffffffc020312a <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203496:	b74d                	j	ffffffffc0203438 <kmalloc+0x5c>

ffffffffc0203498 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203498:	c175                	beqz	a0,ffffffffc020357c <kfree+0xe4>
{
ffffffffc020349a:	1101                	addi	sp,sp,-32
ffffffffc020349c:	e426                	sd	s1,8(sp)
ffffffffc020349e:	ec06                	sd	ra,24(sp)
ffffffffc02034a0:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02034a2:	03451793          	slli	a5,a0,0x34
ffffffffc02034a6:	84aa                	mv	s1,a0
ffffffffc02034a8:	eb8d                	bnez	a5,ffffffffc02034da <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034aa:	100027f3          	csrr	a5,sstatus
ffffffffc02034ae:	8b89                	andi	a5,a5,2
ffffffffc02034b0:	efc9                	bnez	a5,ffffffffc020354a <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02034b2:	000a9797          	auipc	a5,0xa9
ffffffffc02034b6:	0ee78793          	addi	a5,a5,238 # ffffffffc02ac5a0 <bigblocks>
ffffffffc02034ba:	6394                	ld	a3,0(a5)
ffffffffc02034bc:	ce99                	beqz	a3,ffffffffc02034da <kfree+0x42>
			if (bb->pages == block) {
ffffffffc02034be:	669c                	ld	a5,8(a3)
ffffffffc02034c0:	6a80                	ld	s0,16(a3)
ffffffffc02034c2:	0af50e63          	beq	a0,a5,ffffffffc020357e <kfree+0xe6>
    return 0;
ffffffffc02034c6:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02034c8:	c801                	beqz	s0,ffffffffc02034d8 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc02034ca:	6418                	ld	a4,8(s0)
ffffffffc02034cc:	681c                	ld	a5,16(s0)
ffffffffc02034ce:	00970f63          	beq	a4,s1,ffffffffc02034ec <kfree+0x54>
ffffffffc02034d2:	86a2                	mv	a3,s0
ffffffffc02034d4:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02034d6:	f875                	bnez	s0,ffffffffc02034ca <kfree+0x32>
    if (flag) {
ffffffffc02034d8:	e659                	bnez	a2,ffffffffc0203566 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02034da:	6442                	ld	s0,16(sp)
ffffffffc02034dc:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02034de:	ff048513          	addi	a0,s1,-16
}
ffffffffc02034e2:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02034e4:	4581                	li	a1,0
}
ffffffffc02034e6:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02034e8:	c43ff06f          	j	ffffffffc020312a <slob_free>
				*last = bb->next;
ffffffffc02034ec:	ea9c                	sd	a5,16(a3)
ffffffffc02034ee:	e641                	bnez	a2,ffffffffc0203576 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc02034f0:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02034f4:	4018                	lw	a4,0(s0)
ffffffffc02034f6:	08f4ea63          	bltu	s1,a5,ffffffffc020358a <kfree+0xf2>
ffffffffc02034fa:	000a9797          	auipc	a5,0xa9
ffffffffc02034fe:	0ee78793          	addi	a5,a5,238 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0203502:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203504:	000a9797          	auipc	a5,0xa9
ffffffffc0203508:	08c78793          	addi	a5,a5,140 # ffffffffc02ac590 <npage>
ffffffffc020350c:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020350e:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0203510:	80b1                	srli	s1,s1,0xc
ffffffffc0203512:	08f4f963          	bleu	a5,s1,ffffffffc02035a4 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203516:	00005797          	auipc	a5,0x5
ffffffffc020351a:	55278793          	addi	a5,a5,1362 # ffffffffc0208a68 <nbase>
ffffffffc020351e:	639c                	ld	a5,0(a5)
ffffffffc0203520:	000a9697          	auipc	a3,0xa9
ffffffffc0203524:	0d868693          	addi	a3,a3,216 # ffffffffc02ac5f8 <pages>
ffffffffc0203528:	6288                	ld	a0,0(a3)
ffffffffc020352a:	8c9d                	sub	s1,s1,a5
ffffffffc020352c:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc020352e:	4585                	li	a1,1
ffffffffc0203530:	9526                	add	a0,a0,s1
ffffffffc0203532:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203536:	9a1fd0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020353a:	8522                	mv	a0,s0
}
ffffffffc020353c:	6442                	ld	s0,16(sp)
ffffffffc020353e:	60e2                	ld	ra,24(sp)
ffffffffc0203540:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203542:	45e1                	li	a1,24
}
ffffffffc0203544:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203546:	be5ff06f          	j	ffffffffc020312a <slob_free>
        intr_disable();
ffffffffc020354a:	8eefd0ef          	jal	ra,ffffffffc0200638 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020354e:	000a9797          	auipc	a5,0xa9
ffffffffc0203552:	05278793          	addi	a5,a5,82 # ffffffffc02ac5a0 <bigblocks>
ffffffffc0203556:	6394                	ld	a3,0(a5)
ffffffffc0203558:	c699                	beqz	a3,ffffffffc0203566 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc020355a:	669c                	ld	a5,8(a3)
ffffffffc020355c:	6a80                	ld	s0,16(a3)
ffffffffc020355e:	00f48763          	beq	s1,a5,ffffffffc020356c <kfree+0xd4>
        return 1;
ffffffffc0203562:	4605                	li	a2,1
ffffffffc0203564:	b795                	j	ffffffffc02034c8 <kfree+0x30>
        intr_enable();
ffffffffc0203566:	8ccfd0ef          	jal	ra,ffffffffc0200632 <intr_enable>
ffffffffc020356a:	bf85                	j	ffffffffc02034da <kfree+0x42>
				*last = bb->next;
ffffffffc020356c:	000a9797          	auipc	a5,0xa9
ffffffffc0203570:	0287ba23          	sd	s0,52(a5) # ffffffffc02ac5a0 <bigblocks>
ffffffffc0203574:	8436                	mv	s0,a3
ffffffffc0203576:	8bcfd0ef          	jal	ra,ffffffffc0200632 <intr_enable>
ffffffffc020357a:	bf9d                	j	ffffffffc02034f0 <kfree+0x58>
ffffffffc020357c:	8082                	ret
ffffffffc020357e:	000a9797          	auipc	a5,0xa9
ffffffffc0203582:	0287b123          	sd	s0,34(a5) # ffffffffc02ac5a0 <bigblocks>
ffffffffc0203586:	8436                	mv	s0,a3
ffffffffc0203588:	b7a5                	j	ffffffffc02034f0 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc020358a:	86a6                	mv	a3,s1
ffffffffc020358c:	00004617          	auipc	a2,0x4
ffffffffc0203590:	92c60613          	addi	a2,a2,-1748 # ffffffffc0206eb8 <commands+0x958>
ffffffffc0203594:	06e00593          	li	a1,110
ffffffffc0203598:	00004517          	auipc	a0,0x4
ffffffffc020359c:	8a050513          	addi	a0,a0,-1888 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc02035a0:	c77fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02035a4:	00004617          	auipc	a2,0x4
ffffffffc02035a8:	87460613          	addi	a2,a2,-1932 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc02035ac:	06200593          	li	a1,98
ffffffffc02035b0:	00004517          	auipc	a0,0x4
ffffffffc02035b4:	88850513          	addi	a0,a0,-1912 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc02035b8:	c5ffc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02035bc <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02035bc:	7135                	addi	sp,sp,-160
ffffffffc02035be:	ed06                	sd	ra,152(sp)
ffffffffc02035c0:	e922                	sd	s0,144(sp)
ffffffffc02035c2:	e526                	sd	s1,136(sp)
ffffffffc02035c4:	e14a                	sd	s2,128(sp)
ffffffffc02035c6:	fcce                	sd	s3,120(sp)
ffffffffc02035c8:	f8d2                	sd	s4,112(sp)
ffffffffc02035ca:	f4d6                	sd	s5,104(sp)
ffffffffc02035cc:	f0da                	sd	s6,96(sp)
ffffffffc02035ce:	ecde                	sd	s7,88(sp)
ffffffffc02035d0:	e8e2                	sd	s8,80(sp)
ffffffffc02035d2:	e4e6                	sd	s9,72(sp)
ffffffffc02035d4:	e0ea                	sd	s10,64(sp)
ffffffffc02035d6:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02035d8:	3e6010ef          	jal	ra,ffffffffc02049be <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02035dc:	000a9797          	auipc	a5,0xa9
ffffffffc02035e0:	0c478793          	addi	a5,a5,196 # ffffffffc02ac6a0 <max_swap_offset>
ffffffffc02035e4:	6394                	ld	a3,0(a5)
ffffffffc02035e6:	010007b7          	lui	a5,0x1000
ffffffffc02035ea:	17e1                	addi	a5,a5,-8
ffffffffc02035ec:	ff968713          	addi	a4,a3,-7
ffffffffc02035f0:	4ae7ee63          	bltu	a5,a4,ffffffffc0203aac <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02035f4:	0009e797          	auipc	a5,0x9e
ffffffffc02035f8:	b2478793          	addi	a5,a5,-1244 # ffffffffc02a1118 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02035fc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02035fe:	000a9697          	auipc	a3,0xa9
ffffffffc0203602:	faf6b523          	sd	a5,-86(a3) # ffffffffc02ac5a8 <sm>
     int r = sm->init();
ffffffffc0203606:	9702                	jalr	a4
ffffffffc0203608:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc020360a:	c10d                	beqz	a0,ffffffffc020362c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020360c:	60ea                	ld	ra,152(sp)
ffffffffc020360e:	644a                	ld	s0,144(sp)
ffffffffc0203610:	8556                	mv	a0,s5
ffffffffc0203612:	64aa                	ld	s1,136(sp)
ffffffffc0203614:	690a                	ld	s2,128(sp)
ffffffffc0203616:	79e6                	ld	s3,120(sp)
ffffffffc0203618:	7a46                	ld	s4,112(sp)
ffffffffc020361a:	7aa6                	ld	s5,104(sp)
ffffffffc020361c:	7b06                	ld	s6,96(sp)
ffffffffc020361e:	6be6                	ld	s7,88(sp)
ffffffffc0203620:	6c46                	ld	s8,80(sp)
ffffffffc0203622:	6ca6                	ld	s9,72(sp)
ffffffffc0203624:	6d06                	ld	s10,64(sp)
ffffffffc0203626:	7de2                	ld	s11,56(sp)
ffffffffc0203628:	610d                	addi	sp,sp,160
ffffffffc020362a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020362c:	000a9797          	auipc	a5,0xa9
ffffffffc0203630:	f7c78793          	addi	a5,a5,-132 # ffffffffc02ac5a8 <sm>
ffffffffc0203634:	639c                	ld	a5,0(a5)
ffffffffc0203636:	00004517          	auipc	a0,0x4
ffffffffc020363a:	40250513          	addi	a0,a0,1026 # ffffffffc0207a38 <commands+0x14d8>
ffffffffc020363e:	000a9417          	auipc	s0,0xa9
ffffffffc0203642:	0a240413          	addi	s0,s0,162 # ffffffffc02ac6e0 <free_area>
ffffffffc0203646:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203648:	4785                	li	a5,1
ffffffffc020364a:	000a9717          	auipc	a4,0xa9
ffffffffc020364e:	f6f72323          	sw	a5,-154(a4) # ffffffffc02ac5b0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203652:	a7ffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0203656:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203658:	36878e63          	beq	a5,s0,ffffffffc02039d4 <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020365c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203660:	8305                	srli	a4,a4,0x1
ffffffffc0203662:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203664:	36070c63          	beqz	a4,ffffffffc02039dc <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203668:	4481                	li	s1,0
ffffffffc020366a:	4901                	li	s2,0
ffffffffc020366c:	a031                	j	ffffffffc0203678 <swap_init+0xbc>
ffffffffc020366e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203672:	8b09                	andi	a4,a4,2
ffffffffc0203674:	36070463          	beqz	a4,ffffffffc02039dc <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203678:	ff87a703          	lw	a4,-8(a5)
ffffffffc020367c:	679c                	ld	a5,8(a5)
ffffffffc020367e:	2905                	addiw	s2,s2,1
ffffffffc0203680:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203682:	fe8796e3          	bne	a5,s0,ffffffffc020366e <swap_init+0xb2>
ffffffffc0203686:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203688:	895fd0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>
ffffffffc020368c:	69351863          	bne	a0,s3,ffffffffc0203d1c <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203690:	8626                	mv	a2,s1
ffffffffc0203692:	85ca                	mv	a1,s2
ffffffffc0203694:	00004517          	auipc	a0,0x4
ffffffffc0203698:	3ec50513          	addi	a0,a0,1004 # ffffffffc0207a80 <commands+0x1520>
ffffffffc020369c:	a35fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02036a0:	852ff0ef          	jal	ra,ffffffffc02026f2 <mm_create>
ffffffffc02036a4:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02036a6:	60050b63          	beqz	a0,ffffffffc0203cbc <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02036aa:	000a9797          	auipc	a5,0xa9
ffffffffc02036ae:	f6678793          	addi	a5,a5,-154 # ffffffffc02ac610 <check_mm_struct>
ffffffffc02036b2:	639c                	ld	a5,0(a5)
ffffffffc02036b4:	62079463          	bnez	a5,ffffffffc0203cdc <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02036b8:	000a9797          	auipc	a5,0xa9
ffffffffc02036bc:	ed078793          	addi	a5,a5,-304 # ffffffffc02ac588 <boot_pgdir>
ffffffffc02036c0:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02036c4:	000a9797          	auipc	a5,0xa9
ffffffffc02036c8:	f4a7b623          	sd	a0,-180(a5) # ffffffffc02ac610 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02036cc:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02036d0:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02036d4:	4e079863          	bnez	a5,ffffffffc0203bc4 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02036d8:	6599                	lui	a1,0x6
ffffffffc02036da:	460d                	li	a2,3
ffffffffc02036dc:	6505                	lui	a0,0x1
ffffffffc02036de:	860ff0ef          	jal	ra,ffffffffc020273e <vma_create>
ffffffffc02036e2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02036e4:	50050063          	beqz	a0,ffffffffc0203be4 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02036e8:	855e                	mv	a0,s7
ffffffffc02036ea:	8c0ff0ef          	jal	ra,ffffffffc02027aa <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02036ee:	00004517          	auipc	a0,0x4
ffffffffc02036f2:	3d250513          	addi	a0,a0,978 # ffffffffc0207ac0 <commands+0x1560>
ffffffffc02036f6:	9dbfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02036fa:	018bb503          	ld	a0,24(s7)
ffffffffc02036fe:	4605                	li	a2,1
ffffffffc0203700:	6585                	lui	a1,0x1
ffffffffc0203702:	85bfd0ef          	jal	ra,ffffffffc0200f5c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203706:	4e050f63          	beqz	a0,ffffffffc0203c04 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020370a:	00004517          	auipc	a0,0x4
ffffffffc020370e:	40650513          	addi	a0,a0,1030 # ffffffffc0207b10 <commands+0x15b0>
ffffffffc0203712:	000a9997          	auipc	s3,0xa9
ffffffffc0203716:	f0698993          	addi	s3,s3,-250 # ffffffffc02ac618 <check_rp>
ffffffffc020371a:	9b7fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020371e:	000a9a17          	auipc	s4,0xa9
ffffffffc0203722:	f1aa0a13          	addi	s4,s4,-230 # ffffffffc02ac638 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203726:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0203728:	4505                	li	a0,1
ffffffffc020372a:	f24fd0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc020372e:	00ac3023          	sd	a0,0(s8) # ffffffffffe00000 <end+0x3fb538f8>
          assert(check_rp[i] != NULL );
ffffffffc0203732:	32050d63          	beqz	a0,ffffffffc0203a6c <swap_init+0x4b0>
ffffffffc0203736:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203738:	8b89                	andi	a5,a5,2
ffffffffc020373a:	30079963          	bnez	a5,ffffffffc0203a4c <swap_init+0x490>
ffffffffc020373e:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203740:	ff4c14e3          	bne	s8,s4,ffffffffc0203728 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203744:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203746:	000a9c17          	auipc	s8,0xa9
ffffffffc020374a:	ed2c0c13          	addi	s8,s8,-302 # ffffffffc02ac618 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020374e:	ec3e                	sd	a5,24(sp)
ffffffffc0203750:	641c                	ld	a5,8(s0)
ffffffffc0203752:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203754:	481c                	lw	a5,16(s0)
ffffffffc0203756:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203758:	000a9797          	auipc	a5,0xa9
ffffffffc020375c:	f887b823          	sd	s0,-112(a5) # ffffffffc02ac6e8 <free_area+0x8>
ffffffffc0203760:	000a9797          	auipc	a5,0xa9
ffffffffc0203764:	f887b023          	sd	s0,-128(a5) # ffffffffc02ac6e0 <free_area>
     nr_free = 0;
ffffffffc0203768:	000a9797          	auipc	a5,0xa9
ffffffffc020376c:	f807a423          	sw	zero,-120(a5) # ffffffffc02ac6f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203770:	000c3503          	ld	a0,0(s8)
ffffffffc0203774:	4585                	li	a1,1
ffffffffc0203776:	0c21                	addi	s8,s8,8
ffffffffc0203778:	f5efd0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020377c:	ff4c1ae3          	bne	s8,s4,ffffffffc0203770 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203780:	01042c03          	lw	s8,16(s0)
ffffffffc0203784:	4791                	li	a5,4
ffffffffc0203786:	50fc1b63          	bne	s8,a5,ffffffffc0203c9c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020378a:	00004517          	auipc	a0,0x4
ffffffffc020378e:	40e50513          	addi	a0,a0,1038 # ffffffffc0207b98 <commands+0x1638>
ffffffffc0203792:	93ffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203796:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203798:	000a9797          	auipc	a5,0xa9
ffffffffc020379c:	e007a023          	sw	zero,-512(a5) # ffffffffc02ac598 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02037a0:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02037a2:	000a9797          	auipc	a5,0xa9
ffffffffc02037a6:	df678793          	addi	a5,a5,-522 # ffffffffc02ac598 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02037aa:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8588>
     assert(pgfault_num==1);
ffffffffc02037ae:	4398                	lw	a4,0(a5)
ffffffffc02037b0:	4585                	li	a1,1
ffffffffc02037b2:	2701                	sext.w	a4,a4
ffffffffc02037b4:	38b71863          	bne	a4,a1,ffffffffc0203b44 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02037b8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02037bc:	4394                	lw	a3,0(a5)
ffffffffc02037be:	2681                	sext.w	a3,a3
ffffffffc02037c0:	3ae69263          	bne	a3,a4,ffffffffc0203b64 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02037c4:	6689                	lui	a3,0x2
ffffffffc02037c6:	462d                	li	a2,11
ffffffffc02037c8:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7588>
     assert(pgfault_num==2);
ffffffffc02037cc:	4398                	lw	a4,0(a5)
ffffffffc02037ce:	4589                	li	a1,2
ffffffffc02037d0:	2701                	sext.w	a4,a4
ffffffffc02037d2:	2eb71963          	bne	a4,a1,ffffffffc0203ac4 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02037d6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02037da:	4394                	lw	a3,0(a5)
ffffffffc02037dc:	2681                	sext.w	a3,a3
ffffffffc02037de:	30e69363          	bne	a3,a4,ffffffffc0203ae4 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02037e2:	668d                	lui	a3,0x3
ffffffffc02037e4:	4631                	li	a2,12
ffffffffc02037e6:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6588>
     assert(pgfault_num==3);
ffffffffc02037ea:	4398                	lw	a4,0(a5)
ffffffffc02037ec:	458d                	li	a1,3
ffffffffc02037ee:	2701                	sext.w	a4,a4
ffffffffc02037f0:	30b71a63          	bne	a4,a1,ffffffffc0203b04 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02037f4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02037f8:	4394                	lw	a3,0(a5)
ffffffffc02037fa:	2681                	sext.w	a3,a3
ffffffffc02037fc:	32e69463          	bne	a3,a4,ffffffffc0203b24 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203800:	6691                	lui	a3,0x4
ffffffffc0203802:	4635                	li	a2,13
ffffffffc0203804:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5588>
     assert(pgfault_num==4);
ffffffffc0203808:	4398                	lw	a4,0(a5)
ffffffffc020380a:	2701                	sext.w	a4,a4
ffffffffc020380c:	37871c63          	bne	a4,s8,ffffffffc0203b84 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203810:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203814:	439c                	lw	a5,0(a5)
ffffffffc0203816:	2781                	sext.w	a5,a5
ffffffffc0203818:	38e79663          	bne	a5,a4,ffffffffc0203ba4 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020381c:	481c                	lw	a5,16(s0)
ffffffffc020381e:	40079363          	bnez	a5,ffffffffc0203c24 <swap_init+0x668>
ffffffffc0203822:	000a9797          	auipc	a5,0xa9
ffffffffc0203826:	e1678793          	addi	a5,a5,-490 # ffffffffc02ac638 <swap_in_seq_no>
ffffffffc020382a:	000a9717          	auipc	a4,0xa9
ffffffffc020382e:	e3670713          	addi	a4,a4,-458 # ffffffffc02ac660 <swap_out_seq_no>
ffffffffc0203832:	000a9617          	auipc	a2,0xa9
ffffffffc0203836:	e2e60613          	addi	a2,a2,-466 # ffffffffc02ac660 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020383a:	56fd                	li	a3,-1
ffffffffc020383c:	c394                	sw	a3,0(a5)
ffffffffc020383e:	c314                	sw	a3,0(a4)
ffffffffc0203840:	0791                	addi	a5,a5,4
ffffffffc0203842:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203844:	fef61ce3          	bne	a2,a5,ffffffffc020383c <swap_init+0x280>
ffffffffc0203848:	000a9697          	auipc	a3,0xa9
ffffffffc020384c:	e7868693          	addi	a3,a3,-392 # ffffffffc02ac6c0 <check_ptep>
ffffffffc0203850:	000a9817          	auipc	a6,0xa9
ffffffffc0203854:	dc880813          	addi	a6,a6,-568 # ffffffffc02ac618 <check_rp>
ffffffffc0203858:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020385a:	000a9c97          	auipc	s9,0xa9
ffffffffc020385e:	d36c8c93          	addi	s9,s9,-714 # ffffffffc02ac590 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203862:	00005d97          	auipc	s11,0x5
ffffffffc0203866:	206d8d93          	addi	s11,s11,518 # ffffffffc0208a68 <nbase>
ffffffffc020386a:	000a9c17          	auipc	s8,0xa9
ffffffffc020386e:	d8ec0c13          	addi	s8,s8,-626 # ffffffffc02ac5f8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203872:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203876:	4601                	li	a2,0
ffffffffc0203878:	85ea                	mv	a1,s10
ffffffffc020387a:	855a                	mv	a0,s6
ffffffffc020387c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020387e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203880:	edcfd0ef          	jal	ra,ffffffffc0200f5c <get_pte>
ffffffffc0203884:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203886:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203888:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020388a:	20050163          	beqz	a0,ffffffffc0203a8c <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020388e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203890:	0017f613          	andi	a2,a5,1
ffffffffc0203894:	1a060063          	beqz	a2,ffffffffc0203a34 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203898:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020389c:	078a                	slli	a5,a5,0x2
ffffffffc020389e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038a0:	14c7fe63          	bleu	a2,a5,ffffffffc02039fc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02038a4:	000db703          	ld	a4,0(s11)
ffffffffc02038a8:	000c3603          	ld	a2,0(s8)
ffffffffc02038ac:	00083583          	ld	a1,0(a6)
ffffffffc02038b0:	8f99                	sub	a5,a5,a4
ffffffffc02038b2:	079a                	slli	a5,a5,0x6
ffffffffc02038b4:	e43a                	sd	a4,8(sp)
ffffffffc02038b6:	97b2                	add	a5,a5,a2
ffffffffc02038b8:	14f59e63          	bne	a1,a5,ffffffffc0203a14 <swap_init+0x458>
ffffffffc02038bc:	6785                	lui	a5,0x1
ffffffffc02038be:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02038c0:	6795                	lui	a5,0x5
ffffffffc02038c2:	06a1                	addi	a3,a3,8
ffffffffc02038c4:	0821                	addi	a6,a6,8
ffffffffc02038c6:	fafd16e3          	bne	s10,a5,ffffffffc0203872 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02038ca:	00004517          	auipc	a0,0x4
ffffffffc02038ce:	37650513          	addi	a0,a0,886 # ffffffffc0207c40 <commands+0x16e0>
ffffffffc02038d2:	ffefc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc02038d6:	000a9797          	auipc	a5,0xa9
ffffffffc02038da:	cd278793          	addi	a5,a5,-814 # ffffffffc02ac5a8 <sm>
ffffffffc02038de:	639c                	ld	a5,0(a5)
ffffffffc02038e0:	7f9c                	ld	a5,56(a5)
ffffffffc02038e2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02038e4:	40051c63          	bnez	a0,ffffffffc0203cfc <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02038e8:	77a2                	ld	a5,40(sp)
ffffffffc02038ea:	000a9717          	auipc	a4,0xa9
ffffffffc02038ee:	e0f72323          	sw	a5,-506(a4) # ffffffffc02ac6f0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02038f2:	67e2                	ld	a5,24(sp)
ffffffffc02038f4:	000a9717          	auipc	a4,0xa9
ffffffffc02038f8:	def73623          	sd	a5,-532(a4) # ffffffffc02ac6e0 <free_area>
ffffffffc02038fc:	7782                	ld	a5,32(sp)
ffffffffc02038fe:	000a9717          	auipc	a4,0xa9
ffffffffc0203902:	def73523          	sd	a5,-534(a4) # ffffffffc02ac6e8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203906:	0009b503          	ld	a0,0(s3)
ffffffffc020390a:	4585                	li	a1,1
ffffffffc020390c:	09a1                	addi	s3,s3,8
ffffffffc020390e:	dc8fd0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203912:	ff499ae3          	bne	s3,s4,ffffffffc0203906 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203916:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc020391a:	855e                	mv	a0,s7
ffffffffc020391c:	f5dfe0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203920:	000a9797          	auipc	a5,0xa9
ffffffffc0203924:	c6878793          	addi	a5,a5,-920 # ffffffffc02ac588 <boot_pgdir>
ffffffffc0203928:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc020392a:	000a9697          	auipc	a3,0xa9
ffffffffc020392e:	ce06b323          	sd	zero,-794(a3) # ffffffffc02ac610 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0203932:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203936:	6394                	ld	a3,0(a5)
ffffffffc0203938:	068a                	slli	a3,a3,0x2
ffffffffc020393a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020393c:	0ce6f063          	bleu	a4,a3,ffffffffc02039fc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203940:	67a2                	ld	a5,8(sp)
ffffffffc0203942:	000c3503          	ld	a0,0(s8)
ffffffffc0203946:	8e9d                	sub	a3,a3,a5
ffffffffc0203948:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020394a:	8699                	srai	a3,a3,0x6
ffffffffc020394c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020394e:	57fd                	li	a5,-1
ffffffffc0203950:	83b1                	srli	a5,a5,0xc
ffffffffc0203952:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203954:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203956:	2ee7f763          	bleu	a4,a5,ffffffffc0203c44 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020395a:	000a9797          	auipc	a5,0xa9
ffffffffc020395e:	c8e78793          	addi	a5,a5,-882 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0203962:	639c                	ld	a5,0(a5)
ffffffffc0203964:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203966:	629c                	ld	a5,0(a3)
ffffffffc0203968:	078a                	slli	a5,a5,0x2
ffffffffc020396a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020396c:	08e7f863          	bleu	a4,a5,ffffffffc02039fc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203970:	69a2                	ld	s3,8(sp)
ffffffffc0203972:	4585                	li	a1,1
ffffffffc0203974:	413787b3          	sub	a5,a5,s3
ffffffffc0203978:	079a                	slli	a5,a5,0x6
ffffffffc020397a:	953e                	add	a0,a0,a5
ffffffffc020397c:	d5afd0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203980:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203984:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203988:	078a                	slli	a5,a5,0x2
ffffffffc020398a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020398c:	06e7f863          	bleu	a4,a5,ffffffffc02039fc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203990:	000c3503          	ld	a0,0(s8)
ffffffffc0203994:	413787b3          	sub	a5,a5,s3
ffffffffc0203998:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020399a:	4585                	li	a1,1
ffffffffc020399c:	953e                	add	a0,a0,a5
ffffffffc020399e:	d38fd0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
     pgdir[0] = 0;
ffffffffc02039a2:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02039a6:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02039aa:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02039ac:	00878963          	beq	a5,s0,ffffffffc02039be <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02039b0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02039b4:	679c                	ld	a5,8(a5)
ffffffffc02039b6:	397d                	addiw	s2,s2,-1
ffffffffc02039b8:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02039ba:	fe879be3          	bne	a5,s0,ffffffffc02039b0 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc02039be:	28091f63          	bnez	s2,ffffffffc0203c5c <swap_init+0x6a0>
     assert(total==0);
ffffffffc02039c2:	2a049d63          	bnez	s1,ffffffffc0203c7c <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc02039c6:	00004517          	auipc	a0,0x4
ffffffffc02039ca:	2ca50513          	addi	a0,a0,714 # ffffffffc0207c90 <commands+0x1730>
ffffffffc02039ce:	f02fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02039d2:	b92d                	j	ffffffffc020360c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02039d4:	4481                	li	s1,0
ffffffffc02039d6:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02039d8:	4981                	li	s3,0
ffffffffc02039da:	b17d                	j	ffffffffc0203688 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02039dc:	00004697          	auipc	a3,0x4
ffffffffc02039e0:	07468693          	addi	a3,a3,116 # ffffffffc0207a50 <commands+0x14f0>
ffffffffc02039e4:	00003617          	auipc	a2,0x3
ffffffffc02039e8:	ffc60613          	addi	a2,a2,-4 # ffffffffc02069e0 <commands+0x480>
ffffffffc02039ec:	0bc00593          	li	a1,188
ffffffffc02039f0:	00004517          	auipc	a0,0x4
ffffffffc02039f4:	03850513          	addi	a0,a0,56 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc02039f8:	81ffc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02039fc:	00003617          	auipc	a2,0x3
ffffffffc0203a00:	41c60613          	addi	a2,a2,1052 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc0203a04:	06200593          	li	a1,98
ffffffffc0203a08:	00003517          	auipc	a0,0x3
ffffffffc0203a0c:	43050513          	addi	a0,a0,1072 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0203a10:	807fc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203a14:	00004697          	auipc	a3,0x4
ffffffffc0203a18:	20468693          	addi	a3,a3,516 # ffffffffc0207c18 <commands+0x16b8>
ffffffffc0203a1c:	00003617          	auipc	a2,0x3
ffffffffc0203a20:	fc460613          	addi	a2,a2,-60 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203a24:	0fc00593          	li	a1,252
ffffffffc0203a28:	00004517          	auipc	a0,0x4
ffffffffc0203a2c:	00050513          	mv	a0,a0
ffffffffc0203a30:	fe6fc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203a34:	00003617          	auipc	a2,0x3
ffffffffc0203a38:	36460613          	addi	a2,a2,868 # ffffffffc0206d98 <commands+0x838>
ffffffffc0203a3c:	07400593          	li	a1,116
ffffffffc0203a40:	00003517          	auipc	a0,0x3
ffffffffc0203a44:	3f850513          	addi	a0,a0,1016 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0203a48:	fcefc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203a4c:	00004697          	auipc	a3,0x4
ffffffffc0203a50:	10468693          	addi	a3,a3,260 # ffffffffc0207b50 <commands+0x15f0>
ffffffffc0203a54:	00003617          	auipc	a2,0x3
ffffffffc0203a58:	f8c60613          	addi	a2,a2,-116 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203a5c:	0dd00593          	li	a1,221
ffffffffc0203a60:	00004517          	auipc	a0,0x4
ffffffffc0203a64:	fc850513          	addi	a0,a0,-56 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203a68:	faefc0ef          	jal	ra,ffffffffc0200216 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203a6c:	00004697          	auipc	a3,0x4
ffffffffc0203a70:	0cc68693          	addi	a3,a3,204 # ffffffffc0207b38 <commands+0x15d8>
ffffffffc0203a74:	00003617          	auipc	a2,0x3
ffffffffc0203a78:	f6c60613          	addi	a2,a2,-148 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203a7c:	0dc00593          	li	a1,220
ffffffffc0203a80:	00004517          	auipc	a0,0x4
ffffffffc0203a84:	fa850513          	addi	a0,a0,-88 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203a88:	f8efc0ef          	jal	ra,ffffffffc0200216 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203a8c:	00004697          	auipc	a3,0x4
ffffffffc0203a90:	17468693          	addi	a3,a3,372 # ffffffffc0207c00 <commands+0x16a0>
ffffffffc0203a94:	00003617          	auipc	a2,0x3
ffffffffc0203a98:	f4c60613          	addi	a2,a2,-180 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203a9c:	0fb00593          	li	a1,251
ffffffffc0203aa0:	00004517          	auipc	a0,0x4
ffffffffc0203aa4:	f8850513          	addi	a0,a0,-120 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203aa8:	f6efc0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203aac:	00004617          	auipc	a2,0x4
ffffffffc0203ab0:	f5c60613          	addi	a2,a2,-164 # ffffffffc0207a08 <commands+0x14a8>
ffffffffc0203ab4:	02800593          	li	a1,40
ffffffffc0203ab8:	00004517          	auipc	a0,0x4
ffffffffc0203abc:	f7050513          	addi	a0,a0,-144 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203ac0:	f56fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0203ac4:	00004697          	auipc	a3,0x4
ffffffffc0203ac8:	10c68693          	addi	a3,a3,268 # ffffffffc0207bd0 <commands+0x1670>
ffffffffc0203acc:	00003617          	auipc	a2,0x3
ffffffffc0203ad0:	f1460613          	addi	a2,a2,-236 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203ad4:	09700593          	li	a1,151
ffffffffc0203ad8:	00004517          	auipc	a0,0x4
ffffffffc0203adc:	f5050513          	addi	a0,a0,-176 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203ae0:	f36fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==2);
ffffffffc0203ae4:	00004697          	auipc	a3,0x4
ffffffffc0203ae8:	0ec68693          	addi	a3,a3,236 # ffffffffc0207bd0 <commands+0x1670>
ffffffffc0203aec:	00003617          	auipc	a2,0x3
ffffffffc0203af0:	ef460613          	addi	a2,a2,-268 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203af4:	09900593          	li	a1,153
ffffffffc0203af8:	00004517          	auipc	a0,0x4
ffffffffc0203afc:	f3050513          	addi	a0,a0,-208 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203b00:	f16fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0203b04:	00004697          	auipc	a3,0x4
ffffffffc0203b08:	0dc68693          	addi	a3,a3,220 # ffffffffc0207be0 <commands+0x1680>
ffffffffc0203b0c:	00003617          	auipc	a2,0x3
ffffffffc0203b10:	ed460613          	addi	a2,a2,-300 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203b14:	09b00593          	li	a1,155
ffffffffc0203b18:	00004517          	auipc	a0,0x4
ffffffffc0203b1c:	f1050513          	addi	a0,a0,-240 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203b20:	ef6fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==3);
ffffffffc0203b24:	00004697          	auipc	a3,0x4
ffffffffc0203b28:	0bc68693          	addi	a3,a3,188 # ffffffffc0207be0 <commands+0x1680>
ffffffffc0203b2c:	00003617          	auipc	a2,0x3
ffffffffc0203b30:	eb460613          	addi	a2,a2,-332 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203b34:	09d00593          	li	a1,157
ffffffffc0203b38:	00004517          	auipc	a0,0x4
ffffffffc0203b3c:	ef050513          	addi	a0,a0,-272 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203b40:	ed6fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc0203b44:	00004697          	auipc	a3,0x4
ffffffffc0203b48:	07c68693          	addi	a3,a3,124 # ffffffffc0207bc0 <commands+0x1660>
ffffffffc0203b4c:	00003617          	auipc	a2,0x3
ffffffffc0203b50:	e9460613          	addi	a2,a2,-364 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203b54:	09300593          	li	a1,147
ffffffffc0203b58:	00004517          	auipc	a0,0x4
ffffffffc0203b5c:	ed050513          	addi	a0,a0,-304 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203b60:	eb6fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==1);
ffffffffc0203b64:	00004697          	auipc	a3,0x4
ffffffffc0203b68:	05c68693          	addi	a3,a3,92 # ffffffffc0207bc0 <commands+0x1660>
ffffffffc0203b6c:	00003617          	auipc	a2,0x3
ffffffffc0203b70:	e7460613          	addi	a2,a2,-396 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203b74:	09500593          	li	a1,149
ffffffffc0203b78:	00004517          	auipc	a0,0x4
ffffffffc0203b7c:	eb050513          	addi	a0,a0,-336 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203b80:	e96fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0203b84:	00004697          	auipc	a3,0x4
ffffffffc0203b88:	89c68693          	addi	a3,a3,-1892 # ffffffffc0207420 <commands+0xec0>
ffffffffc0203b8c:	00003617          	auipc	a2,0x3
ffffffffc0203b90:	e5460613          	addi	a2,a2,-428 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203b94:	09f00593          	li	a1,159
ffffffffc0203b98:	00004517          	auipc	a0,0x4
ffffffffc0203b9c:	e9050513          	addi	a0,a0,-368 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203ba0:	e76fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgfault_num==4);
ffffffffc0203ba4:	00004697          	auipc	a3,0x4
ffffffffc0203ba8:	87c68693          	addi	a3,a3,-1924 # ffffffffc0207420 <commands+0xec0>
ffffffffc0203bac:	00003617          	auipc	a2,0x3
ffffffffc0203bb0:	e3460613          	addi	a2,a2,-460 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203bb4:	0a100593          	li	a1,161
ffffffffc0203bb8:	00004517          	auipc	a0,0x4
ffffffffc0203bbc:	e7050513          	addi	a0,a0,-400 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203bc0:	e56fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203bc4:	00004697          	auipc	a3,0x4
ffffffffc0203bc8:	d2468693          	addi	a3,a3,-732 # ffffffffc02078e8 <commands+0x1388>
ffffffffc0203bcc:	00003617          	auipc	a2,0x3
ffffffffc0203bd0:	e1460613          	addi	a2,a2,-492 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203bd4:	0cc00593          	li	a1,204
ffffffffc0203bd8:	00004517          	auipc	a0,0x4
ffffffffc0203bdc:	e5050513          	addi	a0,a0,-432 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203be0:	e36fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(vma != NULL);
ffffffffc0203be4:	00004697          	auipc	a3,0x4
ffffffffc0203be8:	da468693          	addi	a3,a3,-604 # ffffffffc0207988 <commands+0x1428>
ffffffffc0203bec:	00003617          	auipc	a2,0x3
ffffffffc0203bf0:	df460613          	addi	a2,a2,-524 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203bf4:	0cf00593          	li	a1,207
ffffffffc0203bf8:	00004517          	auipc	a0,0x4
ffffffffc0203bfc:	e3050513          	addi	a0,a0,-464 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203c00:	e16fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203c04:	00004697          	auipc	a3,0x4
ffffffffc0203c08:	ef468693          	addi	a3,a3,-268 # ffffffffc0207af8 <commands+0x1598>
ffffffffc0203c0c:	00003617          	auipc	a2,0x3
ffffffffc0203c10:	dd460613          	addi	a2,a2,-556 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203c14:	0d700593          	li	a1,215
ffffffffc0203c18:	00004517          	auipc	a0,0x4
ffffffffc0203c1c:	e1050513          	addi	a0,a0,-496 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203c20:	df6fc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert( nr_free == 0);         
ffffffffc0203c24:	00004697          	auipc	a3,0x4
ffffffffc0203c28:	fcc68693          	addi	a3,a3,-52 # ffffffffc0207bf0 <commands+0x1690>
ffffffffc0203c2c:	00003617          	auipc	a2,0x3
ffffffffc0203c30:	db460613          	addi	a2,a2,-588 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203c34:	0f300593          	li	a1,243
ffffffffc0203c38:	00004517          	auipc	a0,0x4
ffffffffc0203c3c:	df050513          	addi	a0,a0,-528 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203c40:	dd6fc0ef          	jal	ra,ffffffffc0200216 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203c44:	00003617          	auipc	a2,0x3
ffffffffc0203c48:	19c60613          	addi	a2,a2,412 # ffffffffc0206de0 <commands+0x880>
ffffffffc0203c4c:	06900593          	li	a1,105
ffffffffc0203c50:	00003517          	auipc	a0,0x3
ffffffffc0203c54:	1e850513          	addi	a0,a0,488 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0203c58:	dbefc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(count==0);
ffffffffc0203c5c:	00004697          	auipc	a3,0x4
ffffffffc0203c60:	01468693          	addi	a3,a3,20 # ffffffffc0207c70 <commands+0x1710>
ffffffffc0203c64:	00003617          	auipc	a2,0x3
ffffffffc0203c68:	d7c60613          	addi	a2,a2,-644 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203c6c:	11d00593          	li	a1,285
ffffffffc0203c70:	00004517          	auipc	a0,0x4
ffffffffc0203c74:	db850513          	addi	a0,a0,-584 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203c78:	d9efc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total==0);
ffffffffc0203c7c:	00004697          	auipc	a3,0x4
ffffffffc0203c80:	00468693          	addi	a3,a3,4 # ffffffffc0207c80 <commands+0x1720>
ffffffffc0203c84:	00003617          	auipc	a2,0x3
ffffffffc0203c88:	d5c60613          	addi	a2,a2,-676 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203c8c:	11e00593          	li	a1,286
ffffffffc0203c90:	00004517          	auipc	a0,0x4
ffffffffc0203c94:	d9850513          	addi	a0,a0,-616 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203c98:	d7efc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203c9c:	00004697          	auipc	a3,0x4
ffffffffc0203ca0:	ed468693          	addi	a3,a3,-300 # ffffffffc0207b70 <commands+0x1610>
ffffffffc0203ca4:	00003617          	auipc	a2,0x3
ffffffffc0203ca8:	d3c60613          	addi	a2,a2,-708 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203cac:	0ea00593          	li	a1,234
ffffffffc0203cb0:	00004517          	auipc	a0,0x4
ffffffffc0203cb4:	d7850513          	addi	a0,a0,-648 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203cb8:	d5efc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(mm != NULL);
ffffffffc0203cbc:	00004697          	auipc	a3,0x4
ffffffffc0203cc0:	aa468693          	addi	a3,a3,-1372 # ffffffffc0207760 <commands+0x1200>
ffffffffc0203cc4:	00003617          	auipc	a2,0x3
ffffffffc0203cc8:	d1c60613          	addi	a2,a2,-740 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203ccc:	0c400593          	li	a1,196
ffffffffc0203cd0:	00004517          	auipc	a0,0x4
ffffffffc0203cd4:	d5850513          	addi	a0,a0,-680 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203cd8:	d3efc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203cdc:	00004697          	auipc	a3,0x4
ffffffffc0203ce0:	dcc68693          	addi	a3,a3,-564 # ffffffffc0207aa8 <commands+0x1548>
ffffffffc0203ce4:	00003617          	auipc	a2,0x3
ffffffffc0203ce8:	cfc60613          	addi	a2,a2,-772 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203cec:	0c700593          	li	a1,199
ffffffffc0203cf0:	00004517          	auipc	a0,0x4
ffffffffc0203cf4:	d3850513          	addi	a0,a0,-712 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203cf8:	d1efc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(ret==0);
ffffffffc0203cfc:	00004697          	auipc	a3,0x4
ffffffffc0203d00:	f6c68693          	addi	a3,a3,-148 # ffffffffc0207c68 <commands+0x1708>
ffffffffc0203d04:	00003617          	auipc	a2,0x3
ffffffffc0203d08:	cdc60613          	addi	a2,a2,-804 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203d0c:	10200593          	li	a1,258
ffffffffc0203d10:	00004517          	auipc	a0,0x4
ffffffffc0203d14:	d1850513          	addi	a0,a0,-744 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203d18:	cfefc0ef          	jal	ra,ffffffffc0200216 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203d1c:	00004697          	auipc	a3,0x4
ffffffffc0203d20:	d4468693          	addi	a3,a3,-700 # ffffffffc0207a60 <commands+0x1500>
ffffffffc0203d24:	00003617          	auipc	a2,0x3
ffffffffc0203d28:	cbc60613          	addi	a2,a2,-836 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203d2c:	0bf00593          	li	a1,191
ffffffffc0203d30:	00004517          	auipc	a0,0x4
ffffffffc0203d34:	cf850513          	addi	a0,a0,-776 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203d38:	cdefc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203d3c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203d3c:	000a9797          	auipc	a5,0xa9
ffffffffc0203d40:	86c78793          	addi	a5,a5,-1940 # ffffffffc02ac5a8 <sm>
ffffffffc0203d44:	639c                	ld	a5,0(a5)
ffffffffc0203d46:	0107b303          	ld	t1,16(a5)
ffffffffc0203d4a:	8302                	jr	t1

ffffffffc0203d4c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203d4c:	000a9797          	auipc	a5,0xa9
ffffffffc0203d50:	85c78793          	addi	a5,a5,-1956 # ffffffffc02ac5a8 <sm>
ffffffffc0203d54:	639c                	ld	a5,0(a5)
ffffffffc0203d56:	0207b303          	ld	t1,32(a5)
ffffffffc0203d5a:	8302                	jr	t1

ffffffffc0203d5c <swap_out>:
{
ffffffffc0203d5c:	711d                	addi	sp,sp,-96
ffffffffc0203d5e:	ec86                	sd	ra,88(sp)
ffffffffc0203d60:	e8a2                	sd	s0,80(sp)
ffffffffc0203d62:	e4a6                	sd	s1,72(sp)
ffffffffc0203d64:	e0ca                	sd	s2,64(sp)
ffffffffc0203d66:	fc4e                	sd	s3,56(sp)
ffffffffc0203d68:	f852                	sd	s4,48(sp)
ffffffffc0203d6a:	f456                	sd	s5,40(sp)
ffffffffc0203d6c:	f05a                	sd	s6,32(sp)
ffffffffc0203d6e:	ec5e                	sd	s7,24(sp)
ffffffffc0203d70:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203d72:	cde9                	beqz	a1,ffffffffc0203e4c <swap_out+0xf0>
ffffffffc0203d74:	8ab2                	mv	s5,a2
ffffffffc0203d76:	892a                	mv	s2,a0
ffffffffc0203d78:	8a2e                	mv	s4,a1
ffffffffc0203d7a:	4401                	li	s0,0
ffffffffc0203d7c:	000a9997          	auipc	s3,0xa9
ffffffffc0203d80:	82c98993          	addi	s3,s3,-2004 # ffffffffc02ac5a8 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203d84:	00004b17          	auipc	s6,0x4
ffffffffc0203d88:	f8cb0b13          	addi	s6,s6,-116 # ffffffffc0207d10 <commands+0x17b0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203d8c:	00004b97          	auipc	s7,0x4
ffffffffc0203d90:	f6cb8b93          	addi	s7,s7,-148 # ffffffffc0207cf8 <commands+0x1798>
ffffffffc0203d94:	a825                	j	ffffffffc0203dcc <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203d96:	67a2                	ld	a5,8(sp)
ffffffffc0203d98:	8626                	mv	a2,s1
ffffffffc0203d9a:	85a2                	mv	a1,s0
ffffffffc0203d9c:	7f94                	ld	a3,56(a5)
ffffffffc0203d9e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203da0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203da2:	82b1                	srli	a3,a3,0xc
ffffffffc0203da4:	0685                	addi	a3,a3,1
ffffffffc0203da6:	b2afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203daa:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203dac:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203dae:	7d1c                	ld	a5,56(a0)
ffffffffc0203db0:	83b1                	srli	a5,a5,0xc
ffffffffc0203db2:	0785                	addi	a5,a5,1
ffffffffc0203db4:	07a2                	slli	a5,a5,0x8
ffffffffc0203db6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203dba:	91cfd0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203dbe:	01893503          	ld	a0,24(s2)
ffffffffc0203dc2:	85a6                	mv	a1,s1
ffffffffc0203dc4:	c88fe0ef          	jal	ra,ffffffffc020224c <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203dc8:	048a0d63          	beq	s4,s0,ffffffffc0203e22 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203dcc:	0009b783          	ld	a5,0(s3)
ffffffffc0203dd0:	8656                	mv	a2,s5
ffffffffc0203dd2:	002c                	addi	a1,sp,8
ffffffffc0203dd4:	7b9c                	ld	a5,48(a5)
ffffffffc0203dd6:	854a                	mv	a0,s2
ffffffffc0203dd8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203dda:	e12d                	bnez	a0,ffffffffc0203e3c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203ddc:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203dde:	01893503          	ld	a0,24(s2)
ffffffffc0203de2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203de4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203de6:	85a6                	mv	a1,s1
ffffffffc0203de8:	974fd0ef          	jal	ra,ffffffffc0200f5c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203dec:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203dee:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203df0:	8b85                	andi	a5,a5,1
ffffffffc0203df2:	cfb9                	beqz	a5,ffffffffc0203e50 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203df4:	65a2                	ld	a1,8(sp)
ffffffffc0203df6:	7d9c                	ld	a5,56(a1)
ffffffffc0203df8:	83b1                	srli	a5,a5,0xc
ffffffffc0203dfa:	00178513          	addi	a0,a5,1
ffffffffc0203dfe:	0522                	slli	a0,a0,0x8
ffffffffc0203e00:	3f7000ef          	jal	ra,ffffffffc02049f6 <swapfs_write>
ffffffffc0203e04:	d949                	beqz	a0,ffffffffc0203d96 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203e06:	855e                	mv	a0,s7
ffffffffc0203e08:	ac8fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203e0c:	0009b783          	ld	a5,0(s3)
ffffffffc0203e10:	6622                	ld	a2,8(sp)
ffffffffc0203e12:	4681                	li	a3,0
ffffffffc0203e14:	739c                	ld	a5,32(a5)
ffffffffc0203e16:	85a6                	mv	a1,s1
ffffffffc0203e18:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203e1a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203e1c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203e1e:	fa8a17e3          	bne	s4,s0,ffffffffc0203dcc <swap_out+0x70>
}
ffffffffc0203e22:	8522                	mv	a0,s0
ffffffffc0203e24:	60e6                	ld	ra,88(sp)
ffffffffc0203e26:	6446                	ld	s0,80(sp)
ffffffffc0203e28:	64a6                	ld	s1,72(sp)
ffffffffc0203e2a:	6906                	ld	s2,64(sp)
ffffffffc0203e2c:	79e2                	ld	s3,56(sp)
ffffffffc0203e2e:	7a42                	ld	s4,48(sp)
ffffffffc0203e30:	7aa2                	ld	s5,40(sp)
ffffffffc0203e32:	7b02                	ld	s6,32(sp)
ffffffffc0203e34:	6be2                	ld	s7,24(sp)
ffffffffc0203e36:	6c42                	ld	s8,16(sp)
ffffffffc0203e38:	6125                	addi	sp,sp,96
ffffffffc0203e3a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203e3c:	85a2                	mv	a1,s0
ffffffffc0203e3e:	00004517          	auipc	a0,0x4
ffffffffc0203e42:	e7250513          	addi	a0,a0,-398 # ffffffffc0207cb0 <commands+0x1750>
ffffffffc0203e46:	a8afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0203e4a:	bfe1                	j	ffffffffc0203e22 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203e4c:	4401                	li	s0,0
ffffffffc0203e4e:	bfd1                	j	ffffffffc0203e22 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203e50:	00004697          	auipc	a3,0x4
ffffffffc0203e54:	e9068693          	addi	a3,a3,-368 # ffffffffc0207ce0 <commands+0x1780>
ffffffffc0203e58:	00003617          	auipc	a2,0x3
ffffffffc0203e5c:	b8860613          	addi	a2,a2,-1144 # ffffffffc02069e0 <commands+0x480>
ffffffffc0203e60:	06800593          	li	a1,104
ffffffffc0203e64:	00004517          	auipc	a0,0x4
ffffffffc0203e68:	bc450513          	addi	a0,a0,-1084 # ffffffffc0207a28 <commands+0x14c8>
ffffffffc0203e6c:	baafc0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0203e70 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203e70:	000a9797          	auipc	a5,0xa9
ffffffffc0203e74:	87078793          	addi	a5,a5,-1936 # ffffffffc02ac6e0 <free_area>
ffffffffc0203e78:	e79c                	sd	a5,8(a5)
ffffffffc0203e7a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203e7c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203e80:	8082                	ret

ffffffffc0203e82 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203e82:	000a9517          	auipc	a0,0xa9
ffffffffc0203e86:	86e56503          	lwu	a0,-1938(a0) # ffffffffc02ac6f0 <free_area+0x10>
ffffffffc0203e8a:	8082                	ret

ffffffffc0203e8c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203e8c:	715d                	addi	sp,sp,-80
ffffffffc0203e8e:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203e90:	000a9917          	auipc	s2,0xa9
ffffffffc0203e94:	85090913          	addi	s2,s2,-1968 # ffffffffc02ac6e0 <free_area>
ffffffffc0203e98:	00893783          	ld	a5,8(s2)
ffffffffc0203e9c:	e486                	sd	ra,72(sp)
ffffffffc0203e9e:	e0a2                	sd	s0,64(sp)
ffffffffc0203ea0:	fc26                	sd	s1,56(sp)
ffffffffc0203ea2:	f44e                	sd	s3,40(sp)
ffffffffc0203ea4:	f052                	sd	s4,32(sp)
ffffffffc0203ea6:	ec56                	sd	s5,24(sp)
ffffffffc0203ea8:	e85a                	sd	s6,16(sp)
ffffffffc0203eaa:	e45e                	sd	s7,8(sp)
ffffffffc0203eac:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203eae:	31278463          	beq	a5,s2,ffffffffc02041b6 <default_check+0x32a>
ffffffffc0203eb2:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203eb6:	8305                	srli	a4,a4,0x1
ffffffffc0203eb8:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203eba:	30070263          	beqz	a4,ffffffffc02041be <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0203ebe:	4401                	li	s0,0
ffffffffc0203ec0:	4481                	li	s1,0
ffffffffc0203ec2:	a031                	j	ffffffffc0203ece <default_check+0x42>
ffffffffc0203ec4:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203ec8:	8b09                	andi	a4,a4,2
ffffffffc0203eca:	2e070a63          	beqz	a4,ffffffffc02041be <default_check+0x332>
        count ++, total += p->property;
ffffffffc0203ece:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203ed2:	679c                	ld	a5,8(a5)
ffffffffc0203ed4:	2485                	addiw	s1,s1,1
ffffffffc0203ed6:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203ed8:	ff2796e3          	bne	a5,s2,ffffffffc0203ec4 <default_check+0x38>
ffffffffc0203edc:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0203ede:	83efd0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>
ffffffffc0203ee2:	73351e63          	bne	a0,s3,ffffffffc020461e <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203ee6:	4505                	li	a0,1
ffffffffc0203ee8:	f67fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203eec:	8a2a                	mv	s4,a0
ffffffffc0203eee:	46050863          	beqz	a0,ffffffffc020435e <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203ef2:	4505                	li	a0,1
ffffffffc0203ef4:	f5bfc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203ef8:	89aa                	mv	s3,a0
ffffffffc0203efa:	74050263          	beqz	a0,ffffffffc020463e <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203efe:	4505                	li	a0,1
ffffffffc0203f00:	f4ffc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203f04:	8aaa                	mv	s5,a0
ffffffffc0203f06:	4c050c63          	beqz	a0,ffffffffc02043de <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203f0a:	2d3a0a63          	beq	s4,s3,ffffffffc02041de <default_check+0x352>
ffffffffc0203f0e:	2caa0863          	beq	s4,a0,ffffffffc02041de <default_check+0x352>
ffffffffc0203f12:	2ca98663          	beq	s3,a0,ffffffffc02041de <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203f16:	000a2783          	lw	a5,0(s4)
ffffffffc0203f1a:	2e079263          	bnez	a5,ffffffffc02041fe <default_check+0x372>
ffffffffc0203f1e:	0009a783          	lw	a5,0(s3)
ffffffffc0203f22:	2c079e63          	bnez	a5,ffffffffc02041fe <default_check+0x372>
ffffffffc0203f26:	411c                	lw	a5,0(a0)
ffffffffc0203f28:	2c079b63          	bnez	a5,ffffffffc02041fe <default_check+0x372>
    return page - pages + nbase;
ffffffffc0203f2c:	000a8797          	auipc	a5,0xa8
ffffffffc0203f30:	6cc78793          	addi	a5,a5,1740 # ffffffffc02ac5f8 <pages>
ffffffffc0203f34:	639c                	ld	a5,0(a5)
ffffffffc0203f36:	00005717          	auipc	a4,0x5
ffffffffc0203f3a:	b3270713          	addi	a4,a4,-1230 # ffffffffc0208a68 <nbase>
ffffffffc0203f3e:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203f40:	000a8717          	auipc	a4,0xa8
ffffffffc0203f44:	65070713          	addi	a4,a4,1616 # ffffffffc02ac590 <npage>
ffffffffc0203f48:	6314                	ld	a3,0(a4)
ffffffffc0203f4a:	40fa0733          	sub	a4,s4,a5
ffffffffc0203f4e:	8719                	srai	a4,a4,0x6
ffffffffc0203f50:	9732                	add	a4,a4,a2
ffffffffc0203f52:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f54:	0732                	slli	a4,a4,0xc
ffffffffc0203f56:	2cd77463          	bleu	a3,a4,ffffffffc020421e <default_check+0x392>
    return page - pages + nbase;
ffffffffc0203f5a:	40f98733          	sub	a4,s3,a5
ffffffffc0203f5e:	8719                	srai	a4,a4,0x6
ffffffffc0203f60:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f62:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203f64:	4ed77d63          	bleu	a3,a4,ffffffffc020445e <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0203f68:	40f507b3          	sub	a5,a0,a5
ffffffffc0203f6c:	8799                	srai	a5,a5,0x6
ffffffffc0203f6e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f70:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203f72:	34d7f663          	bleu	a3,a5,ffffffffc02042be <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0203f76:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203f78:	00093c03          	ld	s8,0(s2)
ffffffffc0203f7c:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0203f80:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0203f84:	000a8797          	auipc	a5,0xa8
ffffffffc0203f88:	7727b223          	sd	s2,1892(a5) # ffffffffc02ac6e8 <free_area+0x8>
ffffffffc0203f8c:	000a8797          	auipc	a5,0xa8
ffffffffc0203f90:	7527ba23          	sd	s2,1876(a5) # ffffffffc02ac6e0 <free_area>
    nr_free = 0;
ffffffffc0203f94:	000a8797          	auipc	a5,0xa8
ffffffffc0203f98:	7407ae23          	sw	zero,1884(a5) # ffffffffc02ac6f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203f9c:	eb3fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203fa0:	2e051f63          	bnez	a0,ffffffffc020429e <default_check+0x412>
    free_page(p0);
ffffffffc0203fa4:	4585                	li	a1,1
ffffffffc0203fa6:	8552                	mv	a0,s4
ffffffffc0203fa8:	f2ffc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    free_page(p1);
ffffffffc0203fac:	4585                	li	a1,1
ffffffffc0203fae:	854e                	mv	a0,s3
ffffffffc0203fb0:	f27fc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    free_page(p2);
ffffffffc0203fb4:	4585                	li	a1,1
ffffffffc0203fb6:	8556                	mv	a0,s5
ffffffffc0203fb8:	f1ffc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    assert(nr_free == 3);
ffffffffc0203fbc:	01092703          	lw	a4,16(s2)
ffffffffc0203fc0:	478d                	li	a5,3
ffffffffc0203fc2:	2af71e63          	bne	a4,a5,ffffffffc020427e <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203fc6:	4505                	li	a0,1
ffffffffc0203fc8:	e87fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203fcc:	89aa                	mv	s3,a0
ffffffffc0203fce:	28050863          	beqz	a0,ffffffffc020425e <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203fd2:	4505                	li	a0,1
ffffffffc0203fd4:	e7bfc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203fd8:	8aaa                	mv	s5,a0
ffffffffc0203fda:	3e050263          	beqz	a0,ffffffffc02043be <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203fde:	4505                	li	a0,1
ffffffffc0203fe0:	e6ffc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203fe4:	8a2a                	mv	s4,a0
ffffffffc0203fe6:	3a050c63          	beqz	a0,ffffffffc020439e <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0203fea:	4505                	li	a0,1
ffffffffc0203fec:	e63fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0203ff0:	38051763          	bnez	a0,ffffffffc020437e <default_check+0x4f2>
    free_page(p0);
ffffffffc0203ff4:	4585                	li	a1,1
ffffffffc0203ff6:	854e                	mv	a0,s3
ffffffffc0203ff8:	edffc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203ffc:	00893783          	ld	a5,8(s2)
ffffffffc0204000:	23278f63          	beq	a5,s2,ffffffffc020423e <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0204004:	4505                	li	a0,1
ffffffffc0204006:	e49fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc020400a:	32a99a63          	bne	s3,a0,ffffffffc020433e <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc020400e:	4505                	li	a0,1
ffffffffc0204010:	e3ffc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204014:	30051563          	bnez	a0,ffffffffc020431e <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0204018:	01092783          	lw	a5,16(s2)
ffffffffc020401c:	2e079163          	bnez	a5,ffffffffc02042fe <default_check+0x472>
    free_page(p);
ffffffffc0204020:	854e                	mv	a0,s3
ffffffffc0204022:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0204024:	000a8797          	auipc	a5,0xa8
ffffffffc0204028:	6b87be23          	sd	s8,1724(a5) # ffffffffc02ac6e0 <free_area>
ffffffffc020402c:	000a8797          	auipc	a5,0xa8
ffffffffc0204030:	6b77be23          	sd	s7,1724(a5) # ffffffffc02ac6e8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0204034:	000a8797          	auipc	a5,0xa8
ffffffffc0204038:	6b67ae23          	sw	s6,1724(a5) # ffffffffc02ac6f0 <free_area+0x10>
    free_page(p);
ffffffffc020403c:	e9bfc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    free_page(p1);
ffffffffc0204040:	4585                	li	a1,1
ffffffffc0204042:	8556                	mv	a0,s5
ffffffffc0204044:	e93fc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    free_page(p2);
ffffffffc0204048:	4585                	li	a1,1
ffffffffc020404a:	8552                	mv	a0,s4
ffffffffc020404c:	e8bfc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0204050:	4515                	li	a0,5
ffffffffc0204052:	dfdfc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204056:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0204058:	28050363          	beqz	a0,ffffffffc02042de <default_check+0x452>
ffffffffc020405c:	651c                	ld	a5,8(a0)
ffffffffc020405e:	8385                	srli	a5,a5,0x1
ffffffffc0204060:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0204062:	54079e63          	bnez	a5,ffffffffc02045be <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0204066:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0204068:	00093b03          	ld	s6,0(s2)
ffffffffc020406c:	00893a83          	ld	s5,8(s2)
ffffffffc0204070:	000a8797          	auipc	a5,0xa8
ffffffffc0204074:	6727b823          	sd	s2,1648(a5) # ffffffffc02ac6e0 <free_area>
ffffffffc0204078:	000a8797          	auipc	a5,0xa8
ffffffffc020407c:	6727b823          	sd	s2,1648(a5) # ffffffffc02ac6e8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0204080:	dcffc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204084:	50051d63          	bnez	a0,ffffffffc020459e <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0204088:	08098a13          	addi	s4,s3,128
ffffffffc020408c:	8552                	mv	a0,s4
ffffffffc020408e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0204090:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0204094:	000a8797          	auipc	a5,0xa8
ffffffffc0204098:	6407ae23          	sw	zero,1628(a5) # ffffffffc02ac6f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020409c:	e3bfc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02040a0:	4511                	li	a0,4
ffffffffc02040a2:	dadfc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc02040a6:	4c051c63          	bnez	a0,ffffffffc020457e <default_check+0x6f2>
ffffffffc02040aa:	0889b783          	ld	a5,136(s3)
ffffffffc02040ae:	8385                	srli	a5,a5,0x1
ffffffffc02040b0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02040b2:	4a078663          	beqz	a5,ffffffffc020455e <default_check+0x6d2>
ffffffffc02040b6:	0909a703          	lw	a4,144(s3)
ffffffffc02040ba:	478d                	li	a5,3
ffffffffc02040bc:	4af71163          	bne	a4,a5,ffffffffc020455e <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02040c0:	450d                	li	a0,3
ffffffffc02040c2:	d8dfc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc02040c6:	8c2a                	mv	s8,a0
ffffffffc02040c8:	46050b63          	beqz	a0,ffffffffc020453e <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02040cc:	4505                	li	a0,1
ffffffffc02040ce:	d81fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc02040d2:	44051663          	bnez	a0,ffffffffc020451e <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02040d6:	438a1463          	bne	s4,s8,ffffffffc02044fe <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02040da:	4585                	li	a1,1
ffffffffc02040dc:	854e                	mv	a0,s3
ffffffffc02040de:	df9fc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    free_pages(p1, 3);
ffffffffc02040e2:	458d                	li	a1,3
ffffffffc02040e4:	8552                	mv	a0,s4
ffffffffc02040e6:	df1fc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
ffffffffc02040ea:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02040ee:	04098c13          	addi	s8,s3,64
ffffffffc02040f2:	8385                	srli	a5,a5,0x1
ffffffffc02040f4:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02040f6:	3e078463          	beqz	a5,ffffffffc02044de <default_check+0x652>
ffffffffc02040fa:	0109a703          	lw	a4,16(s3)
ffffffffc02040fe:	4785                	li	a5,1
ffffffffc0204100:	3cf71f63          	bne	a4,a5,ffffffffc02044de <default_check+0x652>
ffffffffc0204104:	008a3783          	ld	a5,8(s4)
ffffffffc0204108:	8385                	srli	a5,a5,0x1
ffffffffc020410a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020410c:	3a078963          	beqz	a5,ffffffffc02044be <default_check+0x632>
ffffffffc0204110:	010a2703          	lw	a4,16(s4)
ffffffffc0204114:	478d                	li	a5,3
ffffffffc0204116:	3af71463          	bne	a4,a5,ffffffffc02044be <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020411a:	4505                	li	a0,1
ffffffffc020411c:	d33fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204120:	36a99f63          	bne	s3,a0,ffffffffc020449e <default_check+0x612>
    free_page(p0);
ffffffffc0204124:	4585                	li	a1,1
ffffffffc0204126:	db1fc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020412a:	4509                	li	a0,2
ffffffffc020412c:	d23fc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204130:	34aa1763          	bne	s4,a0,ffffffffc020447e <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0204134:	4589                	li	a1,2
ffffffffc0204136:	da1fc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    free_page(p2);
ffffffffc020413a:	4585                	li	a1,1
ffffffffc020413c:	8562                	mv	a0,s8
ffffffffc020413e:	d99fc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204142:	4515                	li	a0,5
ffffffffc0204144:	d0bfc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204148:	89aa                	mv	s3,a0
ffffffffc020414a:	48050a63          	beqz	a0,ffffffffc02045de <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc020414e:	4505                	li	a0,1
ffffffffc0204150:	cfffc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204154:	2e051563          	bnez	a0,ffffffffc020443e <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0204158:	01092783          	lw	a5,16(s2)
ffffffffc020415c:	2c079163          	bnez	a5,ffffffffc020441e <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0204160:	4595                	li	a1,5
ffffffffc0204162:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0204164:	000a8797          	auipc	a5,0xa8
ffffffffc0204168:	5977a623          	sw	s7,1420(a5) # ffffffffc02ac6f0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020416c:	000a8797          	auipc	a5,0xa8
ffffffffc0204170:	5767ba23          	sd	s6,1396(a5) # ffffffffc02ac6e0 <free_area>
ffffffffc0204174:	000a8797          	auipc	a5,0xa8
ffffffffc0204178:	5757ba23          	sd	s5,1396(a5) # ffffffffc02ac6e8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020417c:	d5bfc0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    return listelm->next;
ffffffffc0204180:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204184:	01278963          	beq	a5,s2,ffffffffc0204196 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0204188:	ff87a703          	lw	a4,-8(a5)
ffffffffc020418c:	679c                	ld	a5,8(a5)
ffffffffc020418e:	34fd                	addiw	s1,s1,-1
ffffffffc0204190:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204192:	ff279be3          	bne	a5,s2,ffffffffc0204188 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0204196:	26049463          	bnez	s1,ffffffffc02043fe <default_check+0x572>
    assert(total == 0);
ffffffffc020419a:	46041263          	bnez	s0,ffffffffc02045fe <default_check+0x772>
}
ffffffffc020419e:	60a6                	ld	ra,72(sp)
ffffffffc02041a0:	6406                	ld	s0,64(sp)
ffffffffc02041a2:	74e2                	ld	s1,56(sp)
ffffffffc02041a4:	7942                	ld	s2,48(sp)
ffffffffc02041a6:	79a2                	ld	s3,40(sp)
ffffffffc02041a8:	7a02                	ld	s4,32(sp)
ffffffffc02041aa:	6ae2                	ld	s5,24(sp)
ffffffffc02041ac:	6b42                	ld	s6,16(sp)
ffffffffc02041ae:	6ba2                	ld	s7,8(sp)
ffffffffc02041b0:	6c02                	ld	s8,0(sp)
ffffffffc02041b2:	6161                	addi	sp,sp,80
ffffffffc02041b4:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02041b6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02041b8:	4401                	li	s0,0
ffffffffc02041ba:	4481                	li	s1,0
ffffffffc02041bc:	b30d                	j	ffffffffc0203ede <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02041be:	00004697          	auipc	a3,0x4
ffffffffc02041c2:	89268693          	addi	a3,a3,-1902 # ffffffffc0207a50 <commands+0x14f0>
ffffffffc02041c6:	00003617          	auipc	a2,0x3
ffffffffc02041ca:	81a60613          	addi	a2,a2,-2022 # ffffffffc02069e0 <commands+0x480>
ffffffffc02041ce:	0f000593          	li	a1,240
ffffffffc02041d2:	00004517          	auipc	a0,0x4
ffffffffc02041d6:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02041da:	83cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02041de:	00004697          	auipc	a3,0x4
ffffffffc02041e2:	bea68693          	addi	a3,a3,-1046 # ffffffffc0207dc8 <commands+0x1868>
ffffffffc02041e6:	00002617          	auipc	a2,0x2
ffffffffc02041ea:	7fa60613          	addi	a2,a2,2042 # ffffffffc02069e0 <commands+0x480>
ffffffffc02041ee:	0bd00593          	li	a1,189
ffffffffc02041f2:	00004517          	auipc	a0,0x4
ffffffffc02041f6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02041fa:	81cfc0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02041fe:	00004697          	auipc	a3,0x4
ffffffffc0204202:	bf268693          	addi	a3,a3,-1038 # ffffffffc0207df0 <commands+0x1890>
ffffffffc0204206:	00002617          	auipc	a2,0x2
ffffffffc020420a:	7da60613          	addi	a2,a2,2010 # ffffffffc02069e0 <commands+0x480>
ffffffffc020420e:	0be00593          	li	a1,190
ffffffffc0204212:	00004517          	auipc	a0,0x4
ffffffffc0204216:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020421a:	ffdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020421e:	00004697          	auipc	a3,0x4
ffffffffc0204222:	c1268693          	addi	a3,a3,-1006 # ffffffffc0207e30 <commands+0x18d0>
ffffffffc0204226:	00002617          	auipc	a2,0x2
ffffffffc020422a:	7ba60613          	addi	a2,a2,1978 # ffffffffc02069e0 <commands+0x480>
ffffffffc020422e:	0c000593          	li	a1,192
ffffffffc0204232:	00004517          	auipc	a0,0x4
ffffffffc0204236:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020423a:	fddfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020423e:	00004697          	auipc	a3,0x4
ffffffffc0204242:	c7a68693          	addi	a3,a3,-902 # ffffffffc0207eb8 <commands+0x1958>
ffffffffc0204246:	00002617          	auipc	a2,0x2
ffffffffc020424a:	79a60613          	addi	a2,a2,1946 # ffffffffc02069e0 <commands+0x480>
ffffffffc020424e:	0d900593          	li	a1,217
ffffffffc0204252:	00004517          	auipc	a0,0x4
ffffffffc0204256:	afe50513          	addi	a0,a0,-1282 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020425a:	fbdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020425e:	00004697          	auipc	a3,0x4
ffffffffc0204262:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0207d68 <commands+0x1808>
ffffffffc0204266:	00002617          	auipc	a2,0x2
ffffffffc020426a:	77a60613          	addi	a2,a2,1914 # ffffffffc02069e0 <commands+0x480>
ffffffffc020426e:	0d200593          	li	a1,210
ffffffffc0204272:	00004517          	auipc	a0,0x4
ffffffffc0204276:	ade50513          	addi	a0,a0,-1314 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020427a:	f9dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 3);
ffffffffc020427e:	00004697          	auipc	a3,0x4
ffffffffc0204282:	c2a68693          	addi	a3,a3,-982 # ffffffffc0207ea8 <commands+0x1948>
ffffffffc0204286:	00002617          	auipc	a2,0x2
ffffffffc020428a:	75a60613          	addi	a2,a2,1882 # ffffffffc02069e0 <commands+0x480>
ffffffffc020428e:	0d000593          	li	a1,208
ffffffffc0204292:	00004517          	auipc	a0,0x4
ffffffffc0204296:	abe50513          	addi	a0,a0,-1346 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020429a:	f7dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020429e:	00004697          	auipc	a3,0x4
ffffffffc02042a2:	bf268693          	addi	a3,a3,-1038 # ffffffffc0207e90 <commands+0x1930>
ffffffffc02042a6:	00002617          	auipc	a2,0x2
ffffffffc02042aa:	73a60613          	addi	a2,a2,1850 # ffffffffc02069e0 <commands+0x480>
ffffffffc02042ae:	0cb00593          	li	a1,203
ffffffffc02042b2:	00004517          	auipc	a0,0x4
ffffffffc02042b6:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02042ba:	f5dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02042be:	00004697          	auipc	a3,0x4
ffffffffc02042c2:	bb268693          	addi	a3,a3,-1102 # ffffffffc0207e70 <commands+0x1910>
ffffffffc02042c6:	00002617          	auipc	a2,0x2
ffffffffc02042ca:	71a60613          	addi	a2,a2,1818 # ffffffffc02069e0 <commands+0x480>
ffffffffc02042ce:	0c200593          	li	a1,194
ffffffffc02042d2:	00004517          	auipc	a0,0x4
ffffffffc02042d6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02042da:	f3dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 != NULL);
ffffffffc02042de:	00004697          	auipc	a3,0x4
ffffffffc02042e2:	c1268693          	addi	a3,a3,-1006 # ffffffffc0207ef0 <commands+0x1990>
ffffffffc02042e6:	00002617          	auipc	a2,0x2
ffffffffc02042ea:	6fa60613          	addi	a2,a2,1786 # ffffffffc02069e0 <commands+0x480>
ffffffffc02042ee:	0f800593          	li	a1,248
ffffffffc02042f2:	00004517          	auipc	a0,0x4
ffffffffc02042f6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02042fa:	f1dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc02042fe:	00004697          	auipc	a3,0x4
ffffffffc0204302:	8f268693          	addi	a3,a3,-1806 # ffffffffc0207bf0 <commands+0x1690>
ffffffffc0204306:	00002617          	auipc	a2,0x2
ffffffffc020430a:	6da60613          	addi	a2,a2,1754 # ffffffffc02069e0 <commands+0x480>
ffffffffc020430e:	0df00593          	li	a1,223
ffffffffc0204312:	00004517          	auipc	a0,0x4
ffffffffc0204316:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020431a:	efdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020431e:	00004697          	auipc	a3,0x4
ffffffffc0204322:	b7268693          	addi	a3,a3,-1166 # ffffffffc0207e90 <commands+0x1930>
ffffffffc0204326:	00002617          	auipc	a2,0x2
ffffffffc020432a:	6ba60613          	addi	a2,a2,1722 # ffffffffc02069e0 <commands+0x480>
ffffffffc020432e:	0dd00593          	li	a1,221
ffffffffc0204332:	00004517          	auipc	a0,0x4
ffffffffc0204336:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020433a:	eddfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020433e:	00004697          	auipc	a3,0x4
ffffffffc0204342:	b9268693          	addi	a3,a3,-1134 # ffffffffc0207ed0 <commands+0x1970>
ffffffffc0204346:	00002617          	auipc	a2,0x2
ffffffffc020434a:	69a60613          	addi	a2,a2,1690 # ffffffffc02069e0 <commands+0x480>
ffffffffc020434e:	0dc00593          	li	a1,220
ffffffffc0204352:	00004517          	auipc	a0,0x4
ffffffffc0204356:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020435a:	ebdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020435e:	00004697          	auipc	a3,0x4
ffffffffc0204362:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0207d68 <commands+0x1808>
ffffffffc0204366:	00002617          	auipc	a2,0x2
ffffffffc020436a:	67a60613          	addi	a2,a2,1658 # ffffffffc02069e0 <commands+0x480>
ffffffffc020436e:	0b900593          	li	a1,185
ffffffffc0204372:	00004517          	auipc	a0,0x4
ffffffffc0204376:	9de50513          	addi	a0,a0,-1570 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020437a:	e9dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020437e:	00004697          	auipc	a3,0x4
ffffffffc0204382:	b1268693          	addi	a3,a3,-1262 # ffffffffc0207e90 <commands+0x1930>
ffffffffc0204386:	00002617          	auipc	a2,0x2
ffffffffc020438a:	65a60613          	addi	a2,a2,1626 # ffffffffc02069e0 <commands+0x480>
ffffffffc020438e:	0d600593          	li	a1,214
ffffffffc0204392:	00004517          	auipc	a0,0x4
ffffffffc0204396:	9be50513          	addi	a0,a0,-1602 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020439a:	e7dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020439e:	00004697          	auipc	a3,0x4
ffffffffc02043a2:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0207da8 <commands+0x1848>
ffffffffc02043a6:	00002617          	auipc	a2,0x2
ffffffffc02043aa:	63a60613          	addi	a2,a2,1594 # ffffffffc02069e0 <commands+0x480>
ffffffffc02043ae:	0d400593          	li	a1,212
ffffffffc02043b2:	00004517          	auipc	a0,0x4
ffffffffc02043b6:	99e50513          	addi	a0,a0,-1634 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02043ba:	e5dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02043be:	00004697          	auipc	a3,0x4
ffffffffc02043c2:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0207d88 <commands+0x1828>
ffffffffc02043c6:	00002617          	auipc	a2,0x2
ffffffffc02043ca:	61a60613          	addi	a2,a2,1562 # ffffffffc02069e0 <commands+0x480>
ffffffffc02043ce:	0d300593          	li	a1,211
ffffffffc02043d2:	00004517          	auipc	a0,0x4
ffffffffc02043d6:	97e50513          	addi	a0,a0,-1666 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02043da:	e3dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02043de:	00004697          	auipc	a3,0x4
ffffffffc02043e2:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0207da8 <commands+0x1848>
ffffffffc02043e6:	00002617          	auipc	a2,0x2
ffffffffc02043ea:	5fa60613          	addi	a2,a2,1530 # ffffffffc02069e0 <commands+0x480>
ffffffffc02043ee:	0bb00593          	li	a1,187
ffffffffc02043f2:	00004517          	auipc	a0,0x4
ffffffffc02043f6:	95e50513          	addi	a0,a0,-1698 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02043fa:	e1dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(count == 0);
ffffffffc02043fe:	00004697          	auipc	a3,0x4
ffffffffc0204402:	c4268693          	addi	a3,a3,-958 # ffffffffc0208040 <commands+0x1ae0>
ffffffffc0204406:	00002617          	auipc	a2,0x2
ffffffffc020440a:	5da60613          	addi	a2,a2,1498 # ffffffffc02069e0 <commands+0x480>
ffffffffc020440e:	12500593          	li	a1,293
ffffffffc0204412:	00004517          	auipc	a0,0x4
ffffffffc0204416:	93e50513          	addi	a0,a0,-1730 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020441a:	dfdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_free == 0);
ffffffffc020441e:	00003697          	auipc	a3,0x3
ffffffffc0204422:	7d268693          	addi	a3,a3,2002 # ffffffffc0207bf0 <commands+0x1690>
ffffffffc0204426:	00002617          	auipc	a2,0x2
ffffffffc020442a:	5ba60613          	addi	a2,a2,1466 # ffffffffc02069e0 <commands+0x480>
ffffffffc020442e:	11a00593          	li	a1,282
ffffffffc0204432:	00004517          	auipc	a0,0x4
ffffffffc0204436:	91e50513          	addi	a0,a0,-1762 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020443a:	dddfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020443e:	00004697          	auipc	a3,0x4
ffffffffc0204442:	a5268693          	addi	a3,a3,-1454 # ffffffffc0207e90 <commands+0x1930>
ffffffffc0204446:	00002617          	auipc	a2,0x2
ffffffffc020444a:	59a60613          	addi	a2,a2,1434 # ffffffffc02069e0 <commands+0x480>
ffffffffc020444e:	11800593          	li	a1,280
ffffffffc0204452:	00004517          	auipc	a0,0x4
ffffffffc0204456:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020445a:	dbdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020445e:	00004697          	auipc	a3,0x4
ffffffffc0204462:	9f268693          	addi	a3,a3,-1550 # ffffffffc0207e50 <commands+0x18f0>
ffffffffc0204466:	00002617          	auipc	a2,0x2
ffffffffc020446a:	57a60613          	addi	a2,a2,1402 # ffffffffc02069e0 <commands+0x480>
ffffffffc020446e:	0c100593          	li	a1,193
ffffffffc0204472:	00004517          	auipc	a0,0x4
ffffffffc0204476:	8de50513          	addi	a0,a0,-1826 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020447a:	d9dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020447e:	00004697          	auipc	a3,0x4
ffffffffc0204482:	b8268693          	addi	a3,a3,-1150 # ffffffffc0208000 <commands+0x1aa0>
ffffffffc0204486:	00002617          	auipc	a2,0x2
ffffffffc020448a:	55a60613          	addi	a2,a2,1370 # ffffffffc02069e0 <commands+0x480>
ffffffffc020448e:	11200593          	li	a1,274
ffffffffc0204492:	00004517          	auipc	a0,0x4
ffffffffc0204496:	8be50513          	addi	a0,a0,-1858 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020449a:	d7dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020449e:	00004697          	auipc	a3,0x4
ffffffffc02044a2:	b4268693          	addi	a3,a3,-1214 # ffffffffc0207fe0 <commands+0x1a80>
ffffffffc02044a6:	00002617          	auipc	a2,0x2
ffffffffc02044aa:	53a60613          	addi	a2,a2,1338 # ffffffffc02069e0 <commands+0x480>
ffffffffc02044ae:	11000593          	li	a1,272
ffffffffc02044b2:	00004517          	auipc	a0,0x4
ffffffffc02044b6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02044ba:	d5dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02044be:	00004697          	auipc	a3,0x4
ffffffffc02044c2:	afa68693          	addi	a3,a3,-1286 # ffffffffc0207fb8 <commands+0x1a58>
ffffffffc02044c6:	00002617          	auipc	a2,0x2
ffffffffc02044ca:	51a60613          	addi	a2,a2,1306 # ffffffffc02069e0 <commands+0x480>
ffffffffc02044ce:	10e00593          	li	a1,270
ffffffffc02044d2:	00004517          	auipc	a0,0x4
ffffffffc02044d6:	87e50513          	addi	a0,a0,-1922 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02044da:	d3dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02044de:	00004697          	auipc	a3,0x4
ffffffffc02044e2:	ab268693          	addi	a3,a3,-1358 # ffffffffc0207f90 <commands+0x1a30>
ffffffffc02044e6:	00002617          	auipc	a2,0x2
ffffffffc02044ea:	4fa60613          	addi	a2,a2,1274 # ffffffffc02069e0 <commands+0x480>
ffffffffc02044ee:	10d00593          	li	a1,269
ffffffffc02044f2:	00004517          	auipc	a0,0x4
ffffffffc02044f6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02044fa:	d1dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02044fe:	00004697          	auipc	a3,0x4
ffffffffc0204502:	a8268693          	addi	a3,a3,-1406 # ffffffffc0207f80 <commands+0x1a20>
ffffffffc0204506:	00002617          	auipc	a2,0x2
ffffffffc020450a:	4da60613          	addi	a2,a2,1242 # ffffffffc02069e0 <commands+0x480>
ffffffffc020450e:	10800593          	li	a1,264
ffffffffc0204512:	00004517          	auipc	a0,0x4
ffffffffc0204516:	83e50513          	addi	a0,a0,-1986 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020451a:	cfdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020451e:	00004697          	auipc	a3,0x4
ffffffffc0204522:	97268693          	addi	a3,a3,-1678 # ffffffffc0207e90 <commands+0x1930>
ffffffffc0204526:	00002617          	auipc	a2,0x2
ffffffffc020452a:	4ba60613          	addi	a2,a2,1210 # ffffffffc02069e0 <commands+0x480>
ffffffffc020452e:	10700593          	li	a1,263
ffffffffc0204532:	00004517          	auipc	a0,0x4
ffffffffc0204536:	81e50513          	addi	a0,a0,-2018 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020453a:	cddfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020453e:	00004697          	auipc	a3,0x4
ffffffffc0204542:	a2268693          	addi	a3,a3,-1502 # ffffffffc0207f60 <commands+0x1a00>
ffffffffc0204546:	00002617          	auipc	a2,0x2
ffffffffc020454a:	49a60613          	addi	a2,a2,1178 # ffffffffc02069e0 <commands+0x480>
ffffffffc020454e:	10600593          	li	a1,262
ffffffffc0204552:	00003517          	auipc	a0,0x3
ffffffffc0204556:	7fe50513          	addi	a0,a0,2046 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020455a:	cbdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020455e:	00004697          	auipc	a3,0x4
ffffffffc0204562:	9d268693          	addi	a3,a3,-1582 # ffffffffc0207f30 <commands+0x19d0>
ffffffffc0204566:	00002617          	auipc	a2,0x2
ffffffffc020456a:	47a60613          	addi	a2,a2,1146 # ffffffffc02069e0 <commands+0x480>
ffffffffc020456e:	10500593          	li	a1,261
ffffffffc0204572:	00003517          	auipc	a0,0x3
ffffffffc0204576:	7de50513          	addi	a0,a0,2014 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020457a:	c9dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020457e:	00004697          	auipc	a3,0x4
ffffffffc0204582:	99a68693          	addi	a3,a3,-1638 # ffffffffc0207f18 <commands+0x19b8>
ffffffffc0204586:	00002617          	auipc	a2,0x2
ffffffffc020458a:	45a60613          	addi	a2,a2,1114 # ffffffffc02069e0 <commands+0x480>
ffffffffc020458e:	10400593          	li	a1,260
ffffffffc0204592:	00003517          	auipc	a0,0x3
ffffffffc0204596:	7be50513          	addi	a0,a0,1982 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020459a:	c7dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020459e:	00004697          	auipc	a3,0x4
ffffffffc02045a2:	8f268693          	addi	a3,a3,-1806 # ffffffffc0207e90 <commands+0x1930>
ffffffffc02045a6:	00002617          	auipc	a2,0x2
ffffffffc02045aa:	43a60613          	addi	a2,a2,1082 # ffffffffc02069e0 <commands+0x480>
ffffffffc02045ae:	0fe00593          	li	a1,254
ffffffffc02045b2:	00003517          	auipc	a0,0x3
ffffffffc02045b6:	79e50513          	addi	a0,a0,1950 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02045ba:	c5dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(!PageProperty(p0));
ffffffffc02045be:	00004697          	auipc	a3,0x4
ffffffffc02045c2:	94268693          	addi	a3,a3,-1726 # ffffffffc0207f00 <commands+0x19a0>
ffffffffc02045c6:	00002617          	auipc	a2,0x2
ffffffffc02045ca:	41a60613          	addi	a2,a2,1050 # ffffffffc02069e0 <commands+0x480>
ffffffffc02045ce:	0f900593          	li	a1,249
ffffffffc02045d2:	00003517          	auipc	a0,0x3
ffffffffc02045d6:	77e50513          	addi	a0,a0,1918 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02045da:	c3dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02045de:	00004697          	auipc	a3,0x4
ffffffffc02045e2:	a4268693          	addi	a3,a3,-1470 # ffffffffc0208020 <commands+0x1ac0>
ffffffffc02045e6:	00002617          	auipc	a2,0x2
ffffffffc02045ea:	3fa60613          	addi	a2,a2,1018 # ffffffffc02069e0 <commands+0x480>
ffffffffc02045ee:	11700593          	li	a1,279
ffffffffc02045f2:	00003517          	auipc	a0,0x3
ffffffffc02045f6:	75e50513          	addi	a0,a0,1886 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02045fa:	c1dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == 0);
ffffffffc02045fe:	00004697          	auipc	a3,0x4
ffffffffc0204602:	a5268693          	addi	a3,a3,-1454 # ffffffffc0208050 <commands+0x1af0>
ffffffffc0204606:	00002617          	auipc	a2,0x2
ffffffffc020460a:	3da60613          	addi	a2,a2,986 # ffffffffc02069e0 <commands+0x480>
ffffffffc020460e:	12600593          	li	a1,294
ffffffffc0204612:	00003517          	auipc	a0,0x3
ffffffffc0204616:	73e50513          	addi	a0,a0,1854 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020461a:	bfdfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(total == nr_free_pages());
ffffffffc020461e:	00003697          	auipc	a3,0x3
ffffffffc0204622:	44268693          	addi	a3,a3,1090 # ffffffffc0207a60 <commands+0x1500>
ffffffffc0204626:	00002617          	auipc	a2,0x2
ffffffffc020462a:	3ba60613          	addi	a2,a2,954 # ffffffffc02069e0 <commands+0x480>
ffffffffc020462e:	0f300593          	li	a1,243
ffffffffc0204632:	00003517          	auipc	a0,0x3
ffffffffc0204636:	71e50513          	addi	a0,a0,1822 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020463a:	bddfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020463e:	00003697          	auipc	a3,0x3
ffffffffc0204642:	74a68693          	addi	a3,a3,1866 # ffffffffc0207d88 <commands+0x1828>
ffffffffc0204646:	00002617          	auipc	a2,0x2
ffffffffc020464a:	39a60613          	addi	a2,a2,922 # ffffffffc02069e0 <commands+0x480>
ffffffffc020464e:	0ba00593          	li	a1,186
ffffffffc0204652:	00003517          	auipc	a0,0x3
ffffffffc0204656:	6fe50513          	addi	a0,a0,1790 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020465a:	bbdfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020465e <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020465e:	1141                	addi	sp,sp,-16
ffffffffc0204660:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204662:	16058e63          	beqz	a1,ffffffffc02047de <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0204666:	00659693          	slli	a3,a1,0x6
ffffffffc020466a:	96aa                	add	a3,a3,a0
ffffffffc020466c:	02d50d63          	beq	a0,a3,ffffffffc02046a6 <default_free_pages+0x48>
ffffffffc0204670:	651c                	ld	a5,8(a0)
ffffffffc0204672:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204674:	14079563          	bnez	a5,ffffffffc02047be <default_free_pages+0x160>
ffffffffc0204678:	651c                	ld	a5,8(a0)
ffffffffc020467a:	8385                	srli	a5,a5,0x1
ffffffffc020467c:	8b85                	andi	a5,a5,1
ffffffffc020467e:	14079063          	bnez	a5,ffffffffc02047be <default_free_pages+0x160>
ffffffffc0204682:	87aa                	mv	a5,a0
ffffffffc0204684:	a809                	j	ffffffffc0204696 <default_free_pages+0x38>
ffffffffc0204686:	6798                	ld	a4,8(a5)
ffffffffc0204688:	8b05                	andi	a4,a4,1
ffffffffc020468a:	12071a63          	bnez	a4,ffffffffc02047be <default_free_pages+0x160>
ffffffffc020468e:	6798                	ld	a4,8(a5)
ffffffffc0204690:	8b09                	andi	a4,a4,2
ffffffffc0204692:	12071663          	bnez	a4,ffffffffc02047be <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0204696:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc020469a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020469e:	04078793          	addi	a5,a5,64
ffffffffc02046a2:	fed792e3          	bne	a5,a3,ffffffffc0204686 <default_free_pages+0x28>
    base->property = n;
ffffffffc02046a6:	2581                	sext.w	a1,a1
ffffffffc02046a8:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02046aa:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02046ae:	4789                	li	a5,2
ffffffffc02046b0:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02046b4:	000a8697          	auipc	a3,0xa8
ffffffffc02046b8:	02c68693          	addi	a3,a3,44 # ffffffffc02ac6e0 <free_area>
ffffffffc02046bc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02046be:	669c                	ld	a5,8(a3)
ffffffffc02046c0:	9db9                	addw	a1,a1,a4
ffffffffc02046c2:	000a8717          	auipc	a4,0xa8
ffffffffc02046c6:	02b72723          	sw	a1,46(a4) # ffffffffc02ac6f0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02046ca:	0cd78163          	beq	a5,a3,ffffffffc020478c <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02046ce:	fe878713          	addi	a4,a5,-24
ffffffffc02046d2:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02046d4:	4801                	li	a6,0
ffffffffc02046d6:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02046da:	00e56a63          	bltu	a0,a4,ffffffffc02046ee <default_free_pages+0x90>
    return listelm->next;
ffffffffc02046de:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02046e0:	04d70f63          	beq	a4,a3,ffffffffc020473e <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02046e4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02046e6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02046ea:	fee57ae3          	bleu	a4,a0,ffffffffc02046de <default_free_pages+0x80>
ffffffffc02046ee:	00080663          	beqz	a6,ffffffffc02046fa <default_free_pages+0x9c>
ffffffffc02046f2:	000a8817          	auipc	a6,0xa8
ffffffffc02046f6:	feb83723          	sd	a1,-18(a6) # ffffffffc02ac6e0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02046fa:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02046fc:	e390                	sd	a2,0(a5)
ffffffffc02046fe:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0204700:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204702:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0204704:	06d58a63          	beq	a1,a3,ffffffffc0204778 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0204708:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x8590>
        p = le2page(le, page_link);
ffffffffc020470c:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0204710:	02061793          	slli	a5,a2,0x20
ffffffffc0204714:	83e9                	srli	a5,a5,0x1a
ffffffffc0204716:	97ba                	add	a5,a5,a4
ffffffffc0204718:	04f51b63          	bne	a0,a5,ffffffffc020476e <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020471c:	491c                	lw	a5,16(a0)
ffffffffc020471e:	9e3d                	addw	a2,a2,a5
ffffffffc0204720:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204724:	57f5                	li	a5,-3
ffffffffc0204726:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020472a:	01853803          	ld	a6,24(a0)
ffffffffc020472e:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0204730:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0204732:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0204736:	659c                	ld	a5,8(a1)
ffffffffc0204738:	01063023          	sd	a6,0(a2)
ffffffffc020473c:	a815                	j	ffffffffc0204770 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020473e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204740:	f114                	sd	a3,32(a0)
ffffffffc0204742:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204744:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0204746:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204748:	00d70563          	beq	a4,a3,ffffffffc0204752 <default_free_pages+0xf4>
ffffffffc020474c:	4805                	li	a6,1
ffffffffc020474e:	87ba                	mv	a5,a4
ffffffffc0204750:	bf59                	j	ffffffffc02046e6 <default_free_pages+0x88>
ffffffffc0204752:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0204754:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0204756:	00d78d63          	beq	a5,a3,ffffffffc0204770 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc020475a:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020475e:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0204762:	02061793          	slli	a5,a2,0x20
ffffffffc0204766:	83e9                	srli	a5,a5,0x1a
ffffffffc0204768:	97ba                	add	a5,a5,a4
ffffffffc020476a:	faf509e3          	beq	a0,a5,ffffffffc020471c <default_free_pages+0xbe>
ffffffffc020476e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0204770:	fe878713          	addi	a4,a5,-24
ffffffffc0204774:	00d78963          	beq	a5,a3,ffffffffc0204786 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0204778:	4910                	lw	a2,16(a0)
ffffffffc020477a:	02061693          	slli	a3,a2,0x20
ffffffffc020477e:	82e9                	srli	a3,a3,0x1a
ffffffffc0204780:	96aa                	add	a3,a3,a0
ffffffffc0204782:	00d70e63          	beq	a4,a3,ffffffffc020479e <default_free_pages+0x140>
}
ffffffffc0204786:	60a2                	ld	ra,8(sp)
ffffffffc0204788:	0141                	addi	sp,sp,16
ffffffffc020478a:	8082                	ret
ffffffffc020478c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020478e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204792:	e398                	sd	a4,0(a5)
ffffffffc0204794:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204796:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204798:	ed1c                	sd	a5,24(a0)
}
ffffffffc020479a:	0141                	addi	sp,sp,16
ffffffffc020479c:	8082                	ret
            base->property += p->property;
ffffffffc020479e:	ff87a703          	lw	a4,-8(a5)
ffffffffc02047a2:	ff078693          	addi	a3,a5,-16
ffffffffc02047a6:	9e39                	addw	a2,a2,a4
ffffffffc02047a8:	c910                	sw	a2,16(a0)
ffffffffc02047aa:	5775                	li	a4,-3
ffffffffc02047ac:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02047b0:	6398                	ld	a4,0(a5)
ffffffffc02047b2:	679c                	ld	a5,8(a5)
}
ffffffffc02047b4:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02047b6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02047b8:	e398                	sd	a4,0(a5)
ffffffffc02047ba:	0141                	addi	sp,sp,16
ffffffffc02047bc:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02047be:	00004697          	auipc	a3,0x4
ffffffffc02047c2:	8a268693          	addi	a3,a3,-1886 # ffffffffc0208060 <commands+0x1b00>
ffffffffc02047c6:	00002617          	auipc	a2,0x2
ffffffffc02047ca:	21a60613          	addi	a2,a2,538 # ffffffffc02069e0 <commands+0x480>
ffffffffc02047ce:	08300593          	li	a1,131
ffffffffc02047d2:	00003517          	auipc	a0,0x3
ffffffffc02047d6:	57e50513          	addi	a0,a0,1406 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02047da:	a3dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc02047de:	00004697          	auipc	a3,0x4
ffffffffc02047e2:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0208088 <commands+0x1b28>
ffffffffc02047e6:	00002617          	auipc	a2,0x2
ffffffffc02047ea:	1fa60613          	addi	a2,a2,506 # ffffffffc02069e0 <commands+0x480>
ffffffffc02047ee:	08000593          	li	a1,128
ffffffffc02047f2:	00003517          	auipc	a0,0x3
ffffffffc02047f6:	55e50513          	addi	a0,a0,1374 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02047fa:	a1dfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02047fe <default_alloc_pages>:
    assert(n > 0);
ffffffffc02047fe:	c959                	beqz	a0,ffffffffc0204894 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0204800:	000a8597          	auipc	a1,0xa8
ffffffffc0204804:	ee058593          	addi	a1,a1,-288 # ffffffffc02ac6e0 <free_area>
ffffffffc0204808:	0105a803          	lw	a6,16(a1)
ffffffffc020480c:	862a                	mv	a2,a0
ffffffffc020480e:	02081793          	slli	a5,a6,0x20
ffffffffc0204812:	9381                	srli	a5,a5,0x20
ffffffffc0204814:	00a7ee63          	bltu	a5,a0,ffffffffc0204830 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0204818:	87ae                	mv	a5,a1
ffffffffc020481a:	a801                	j	ffffffffc020482a <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020481c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204820:	02071693          	slli	a3,a4,0x20
ffffffffc0204824:	9281                	srli	a3,a3,0x20
ffffffffc0204826:	00c6f763          	bleu	a2,a3,ffffffffc0204834 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020482a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020482c:	feb798e3          	bne	a5,a1,ffffffffc020481c <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0204830:	4501                	li	a0,0
}
ffffffffc0204832:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0204834:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0204838:	dd6d                	beqz	a0,ffffffffc0204832 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc020483a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020483e:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0204842:	00060e1b          	sext.w	t3,a2
ffffffffc0204846:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3900>
    next->prev = prev;
ffffffffc020484a:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5570>
        if (page->property > n) {
ffffffffc020484e:	02d67863          	bleu	a3,a2,ffffffffc020487e <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0204852:	061a                	slli	a2,a2,0x6
ffffffffc0204854:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0204856:	41c7073b          	subw	a4,a4,t3
ffffffffc020485a:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020485c:	00860693          	addi	a3,a2,8
ffffffffc0204860:	4709                	li	a4,2
ffffffffc0204862:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204866:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020486a:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc020486e:	0105a803          	lw	a6,16(a1)
ffffffffc0204872:	e314                	sd	a3,0(a4)
ffffffffc0204874:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0204878:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc020487a:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc020487e:	41c8083b          	subw	a6,a6,t3
ffffffffc0204882:	000a8717          	auipc	a4,0xa8
ffffffffc0204886:	e7072723          	sw	a6,-402(a4) # ffffffffc02ac6f0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020488a:	5775                	li	a4,-3
ffffffffc020488c:	17c1                	addi	a5,a5,-16
ffffffffc020488e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0204892:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0204894:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204896:	00003697          	auipc	a3,0x3
ffffffffc020489a:	7f268693          	addi	a3,a3,2034 # ffffffffc0208088 <commands+0x1b28>
ffffffffc020489e:	00002617          	auipc	a2,0x2
ffffffffc02048a2:	14260613          	addi	a2,a2,322 # ffffffffc02069e0 <commands+0x480>
ffffffffc02048a6:	06200593          	li	a1,98
ffffffffc02048aa:	00003517          	auipc	a0,0x3
ffffffffc02048ae:	4a650513          	addi	a0,a0,1190 # ffffffffc0207d50 <commands+0x17f0>
default_alloc_pages(size_t n) {
ffffffffc02048b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02048b4:	963fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02048b8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02048b8:	1141                	addi	sp,sp,-16
ffffffffc02048ba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02048bc:	c1ed                	beqz	a1,ffffffffc020499e <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02048be:	00659693          	slli	a3,a1,0x6
ffffffffc02048c2:	96aa                	add	a3,a3,a0
ffffffffc02048c4:	02d50463          	beq	a0,a3,ffffffffc02048ec <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02048c8:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02048ca:	87aa                	mv	a5,a0
ffffffffc02048cc:	8b05                	andi	a4,a4,1
ffffffffc02048ce:	e709                	bnez	a4,ffffffffc02048d8 <default_init_memmap+0x20>
ffffffffc02048d0:	a07d                	j	ffffffffc020497e <default_init_memmap+0xc6>
ffffffffc02048d2:	6798                	ld	a4,8(a5)
ffffffffc02048d4:	8b05                	andi	a4,a4,1
ffffffffc02048d6:	c745                	beqz	a4,ffffffffc020497e <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02048d8:	0007a823          	sw	zero,16(a5)
ffffffffc02048dc:	0007b423          	sd	zero,8(a5)
ffffffffc02048e0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02048e4:	04078793          	addi	a5,a5,64
ffffffffc02048e8:	fed795e3          	bne	a5,a3,ffffffffc02048d2 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02048ec:	2581                	sext.w	a1,a1
ffffffffc02048ee:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02048f0:	4789                	li	a5,2
ffffffffc02048f2:	00850713          	addi	a4,a0,8
ffffffffc02048f6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02048fa:	000a8697          	auipc	a3,0xa8
ffffffffc02048fe:	de668693          	addi	a3,a3,-538 # ffffffffc02ac6e0 <free_area>
ffffffffc0204902:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204904:	669c                	ld	a5,8(a3)
ffffffffc0204906:	9db9                	addw	a1,a1,a4
ffffffffc0204908:	000a8717          	auipc	a4,0xa8
ffffffffc020490c:	deb72423          	sw	a1,-536(a4) # ffffffffc02ac6f0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204910:	04d78a63          	beq	a5,a3,ffffffffc0204964 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0204914:	fe878713          	addi	a4,a5,-24
ffffffffc0204918:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020491a:	4801                	li	a6,0
ffffffffc020491c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204920:	00e56a63          	bltu	a0,a4,ffffffffc0204934 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0204924:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204926:	02d70563          	beq	a4,a3,ffffffffc0204950 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020492a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020492c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204930:	fee57ae3          	bleu	a4,a0,ffffffffc0204924 <default_init_memmap+0x6c>
ffffffffc0204934:	00080663          	beqz	a6,ffffffffc0204940 <default_init_memmap+0x88>
ffffffffc0204938:	000a8717          	auipc	a4,0xa8
ffffffffc020493c:	dab73423          	sd	a1,-600(a4) # ffffffffc02ac6e0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204940:	6398                	ld	a4,0(a5)
}
ffffffffc0204942:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204944:	e390                	sd	a2,0(a5)
ffffffffc0204946:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204948:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020494a:	ed18                	sd	a4,24(a0)
ffffffffc020494c:	0141                	addi	sp,sp,16
ffffffffc020494e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204950:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204952:	f114                	sd	a3,32(a0)
ffffffffc0204954:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204956:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0204958:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020495a:	00d70e63          	beq	a4,a3,ffffffffc0204976 <default_init_memmap+0xbe>
ffffffffc020495e:	4805                	li	a6,1
ffffffffc0204960:	87ba                	mv	a5,a4
ffffffffc0204962:	b7e9                	j	ffffffffc020492c <default_init_memmap+0x74>
}
ffffffffc0204964:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204966:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020496a:	e398                	sd	a4,0(a5)
ffffffffc020496c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020496e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204970:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204972:	0141                	addi	sp,sp,16
ffffffffc0204974:	8082                	ret
ffffffffc0204976:	60a2                	ld	ra,8(sp)
ffffffffc0204978:	e290                	sd	a2,0(a3)
ffffffffc020497a:	0141                	addi	sp,sp,16
ffffffffc020497c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020497e:	00003697          	auipc	a3,0x3
ffffffffc0204982:	71268693          	addi	a3,a3,1810 # ffffffffc0208090 <commands+0x1b30>
ffffffffc0204986:	00002617          	auipc	a2,0x2
ffffffffc020498a:	05a60613          	addi	a2,a2,90 # ffffffffc02069e0 <commands+0x480>
ffffffffc020498e:	04900593          	li	a1,73
ffffffffc0204992:	00003517          	auipc	a0,0x3
ffffffffc0204996:	3be50513          	addi	a0,a0,958 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc020499a:	87dfb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(n > 0);
ffffffffc020499e:	00003697          	auipc	a3,0x3
ffffffffc02049a2:	6ea68693          	addi	a3,a3,1770 # ffffffffc0208088 <commands+0x1b28>
ffffffffc02049a6:	00002617          	auipc	a2,0x2
ffffffffc02049aa:	03a60613          	addi	a2,a2,58 # ffffffffc02069e0 <commands+0x480>
ffffffffc02049ae:	04600593          	li	a1,70
ffffffffc02049b2:	00003517          	auipc	a0,0x3
ffffffffc02049b6:	39e50513          	addi	a0,a0,926 # ffffffffc0207d50 <commands+0x17f0>
ffffffffc02049ba:	85dfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02049be <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc02049be:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02049c0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc02049c2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc02049c4:	b71fb0ef          	jal	ra,ffffffffc0200534 <ide_device_valid>
ffffffffc02049c8:	cd01                	beqz	a0,ffffffffc02049e0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02049ca:	4505                	li	a0,1
ffffffffc02049cc:	b6ffb0ef          	jal	ra,ffffffffc020053a <ide_device_size>
}
ffffffffc02049d0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc02049d2:	810d                	srli	a0,a0,0x3
ffffffffc02049d4:	000a8797          	auipc	a5,0xa8
ffffffffc02049d8:	cca7b623          	sd	a0,-820(a5) # ffffffffc02ac6a0 <max_swap_offset>
}
ffffffffc02049dc:	0141                	addi	sp,sp,16
ffffffffc02049de:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc02049e0:	00003617          	auipc	a2,0x3
ffffffffc02049e4:	71060613          	addi	a2,a2,1808 # ffffffffc02080f0 <default_pmm_manager+0x50>
ffffffffc02049e8:	45b5                	li	a1,13
ffffffffc02049ea:	00003517          	auipc	a0,0x3
ffffffffc02049ee:	72650513          	addi	a0,a0,1830 # ffffffffc0208110 <default_pmm_manager+0x70>
ffffffffc02049f2:	825fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02049f6 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02049f6:	1141                	addi	sp,sp,-16
ffffffffc02049f8:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02049fa:	00855793          	srli	a5,a0,0x8
ffffffffc02049fe:	cfb9                	beqz	a5,ffffffffc0204a5c <swapfs_write+0x66>
ffffffffc0204a00:	000a8717          	auipc	a4,0xa8
ffffffffc0204a04:	ca070713          	addi	a4,a4,-864 # ffffffffc02ac6a0 <max_swap_offset>
ffffffffc0204a08:	6318                	ld	a4,0(a4)
ffffffffc0204a0a:	04e7f963          	bleu	a4,a5,ffffffffc0204a5c <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204a0e:	000a8717          	auipc	a4,0xa8
ffffffffc0204a12:	bea70713          	addi	a4,a4,-1046 # ffffffffc02ac5f8 <pages>
ffffffffc0204a16:	6310                	ld	a2,0(a4)
ffffffffc0204a18:	00004717          	auipc	a4,0x4
ffffffffc0204a1c:	05070713          	addi	a4,a4,80 # ffffffffc0208a68 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204a20:	000a8697          	auipc	a3,0xa8
ffffffffc0204a24:	b7068693          	addi	a3,a3,-1168 # ffffffffc02ac590 <npage>
    return page - pages + nbase;
ffffffffc0204a28:	40c58633          	sub	a2,a1,a2
ffffffffc0204a2c:	630c                	ld	a1,0(a4)
ffffffffc0204a2e:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204a30:	577d                	li	a4,-1
ffffffffc0204a32:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204a34:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204a36:	8331                	srli	a4,a4,0xc
ffffffffc0204a38:	8f71                	and	a4,a4,a2
ffffffffc0204a3a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a3e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204a40:	02d77a63          	bleu	a3,a4,ffffffffc0204a74 <swapfs_write+0x7e>
ffffffffc0204a44:	000a8797          	auipc	a5,0xa8
ffffffffc0204a48:	ba478793          	addi	a5,a5,-1116 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0204a4c:	639c                	ld	a5,0(a5)
}
ffffffffc0204a4e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204a50:	46a1                	li	a3,8
ffffffffc0204a52:	963e                	add	a2,a2,a5
ffffffffc0204a54:	4505                	li	a0,1
}
ffffffffc0204a56:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204a58:	ae9fb06f          	j	ffffffffc0200540 <ide_write_secs>
ffffffffc0204a5c:	86aa                	mv	a3,a0
ffffffffc0204a5e:	00003617          	auipc	a2,0x3
ffffffffc0204a62:	6ca60613          	addi	a2,a2,1738 # ffffffffc0208128 <default_pmm_manager+0x88>
ffffffffc0204a66:	45e5                	li	a1,25
ffffffffc0204a68:	00003517          	auipc	a0,0x3
ffffffffc0204a6c:	6a850513          	addi	a0,a0,1704 # ffffffffc0208110 <default_pmm_manager+0x70>
ffffffffc0204a70:	fa6fb0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc0204a74:	86b2                	mv	a3,a2
ffffffffc0204a76:	06900593          	li	a1,105
ffffffffc0204a7a:	00002617          	auipc	a2,0x2
ffffffffc0204a7e:	36660613          	addi	a2,a2,870 # ffffffffc0206de0 <commands+0x880>
ffffffffc0204a82:	00002517          	auipc	a0,0x2
ffffffffc0204a86:	3b650513          	addi	a0,a0,950 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0204a8a:	f8cfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204a8e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204a8e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204a92:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204a96:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204a98:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204a9a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204a9e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204aa2:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204aa6:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204aaa:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204aae:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204ab2:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204ab6:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204aba:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204abe:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204ac2:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204ac6:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204aca:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204acc:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204ace:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204ad2:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204ad6:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204ada:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204ade:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204ae2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204ae6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204aea:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204aee:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204af2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204af6:	8082                	ret

ffffffffc0204af8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204af8:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204afa:	9402                	jalr	s0

	jal do_exit
ffffffffc0204afc:	732000ef          	jal	ra,ffffffffc020522e <do_exit>

ffffffffc0204b00 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204b00:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204b02:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204b06:	e022                	sd	s0,0(sp)
ffffffffc0204b08:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204b0a:	8d3fe0ef          	jal	ra,ffffffffc02033dc <kmalloc>
ffffffffc0204b0e:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204b10:	cd29                	beqz	a0,ffffffffc0204b6a <alloc_proc+0x6a>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204b12:	57fd                	li	a5,-1
ffffffffc0204b14:	1782                	slli	a5,a5,0x20
ffffffffc0204b16:	e11c                	sd	a5,0(a0)
    	proc->runs = 0;
    	proc->kstack = NULL;
    	proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204b18:	07000613          	li	a2,112
ffffffffc0204b1c:	4581                	li	a1,0
    	proc->runs = 0;
ffffffffc0204b1e:	00052423          	sw	zero,8(a0)
    	proc->kstack = NULL;
ffffffffc0204b22:	00053823          	sd	zero,16(a0)
    	proc->need_resched = 0;
ffffffffc0204b26:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204b2a:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204b2e:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204b32:	03050513          	addi	a0,a0,48
ffffffffc0204b36:	47e010ef          	jal	ra,ffffffffc0205fb4 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204b3a:	000a8797          	auipc	a5,0xa8
ffffffffc0204b3e:	ab678793          	addi	a5,a5,-1354 # ffffffffc02ac5f0 <boot_cr3>
ffffffffc0204b42:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204b44:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204b48:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204b4c:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204b4e:	463d                	li	a2,15
ffffffffc0204b50:	4581                	li	a1,0
ffffffffc0204b52:	0b440513          	addi	a0,s0,180
ffffffffc0204b56:	45e010ef          	jal	ra,ffffffffc0205fb4 <memset>
        proc->wait_state = 0; //PCB新增的条目，初始化进程等待状态
ffffffffc0204b5a:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;//设置指针
ffffffffc0204b5e:	0e043c23          	sd	zero,248(s0)
ffffffffc0204b62:	10043023          	sd	zero,256(s0)
ffffffffc0204b66:	0e043823          	sd	zero,240(s0)

    }
    return proc;
}
ffffffffc0204b6a:	8522                	mv	a0,s0
ffffffffc0204b6c:	60a2                	ld	ra,8(sp)
ffffffffc0204b6e:	6402                	ld	s0,0(sp)
ffffffffc0204b70:	0141                	addi	sp,sp,16
ffffffffc0204b72:	8082                	ret

ffffffffc0204b74 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204b74:	000a8797          	auipc	a5,0xa8
ffffffffc0204b78:	a4478793          	addi	a5,a5,-1468 # ffffffffc02ac5b8 <current>
ffffffffc0204b7c:	639c                	ld	a5,0(a5)
ffffffffc0204b7e:	73c8                	ld	a0,160(a5)
ffffffffc0204b80:	a06fc06f          	j	ffffffffc0200d86 <forkrets>

ffffffffc0204b84 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204b84:	000a8797          	auipc	a5,0xa8
ffffffffc0204b88:	a3478793          	addi	a5,a5,-1484 # ffffffffc02ac5b8 <current>
ffffffffc0204b8c:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204b8e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204b90:	00004617          	auipc	a2,0x4
ffffffffc0204b94:	9a860613          	addi	a2,a2,-1624 # ffffffffc0208538 <default_pmm_manager+0x498>
ffffffffc0204b98:	43cc                	lw	a1,4(a5)
ffffffffc0204b9a:	00004517          	auipc	a0,0x4
ffffffffc0204b9e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0208548 <default_pmm_manager+0x4a8>
user_main(void *arg) {
ffffffffc0204ba2:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ba4:	d2cfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204ba8:	00004797          	auipc	a5,0x4
ffffffffc0204bac:	99078793          	addi	a5,a5,-1648 # ffffffffc0208538 <default_pmm_manager+0x498>
ffffffffc0204bb0:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204bb4:	74070713          	addi	a4,a4,1856 # a2f0 <_binary_obj___user_forktest_out_size>
ffffffffc0204bb8:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204bba:	853e                	mv	a0,a5
ffffffffc0204bbc:	00089717          	auipc	a4,0x89
ffffffffc0204bc0:	ae470713          	addi	a4,a4,-1308 # ffffffffc028d6a0 <_binary_obj___user_forktest_out_start>
ffffffffc0204bc4:	f03a                	sd	a4,32(sp)
ffffffffc0204bc6:	f43e                	sd	a5,40(sp)
ffffffffc0204bc8:	e802                	sd	zero,16(sp)
ffffffffc0204bca:	34c010ef          	jal	ra,ffffffffc0205f16 <strlen>
ffffffffc0204bce:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204bd0:	4511                	li	a0,4
ffffffffc0204bd2:	55a2                	lw	a1,40(sp)
ffffffffc0204bd4:	4662                	lw	a2,24(sp)
ffffffffc0204bd6:	5682                	lw	a3,32(sp)
ffffffffc0204bd8:	4722                	lw	a4,8(sp)
ffffffffc0204bda:	48a9                	li	a7,10
ffffffffc0204bdc:	9002                	ebreak
ffffffffc0204bde:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204be0:	65c2                	ld	a1,16(sp)
ffffffffc0204be2:	00004517          	auipc	a0,0x4
ffffffffc0204be6:	98e50513          	addi	a0,a0,-1650 # ffffffffc0208570 <default_pmm_manager+0x4d0>
ffffffffc0204bea:	ce6fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204bee:	00004617          	auipc	a2,0x4
ffffffffc0204bf2:	99260613          	addi	a2,a2,-1646 # ffffffffc0208580 <default_pmm_manager+0x4e0>
ffffffffc0204bf6:	34b00593          	li	a1,843
ffffffffc0204bfa:	00004517          	auipc	a0,0x4
ffffffffc0204bfe:	9a650513          	addi	a0,a0,-1626 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0204c02:	e14fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c06 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204c06:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204c08:	1141                	addi	sp,sp,-16
ffffffffc0204c0a:	e406                	sd	ra,8(sp)
ffffffffc0204c0c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c10:	04f6e263          	bltu	a3,a5,ffffffffc0204c54 <put_pgdir+0x4e>
ffffffffc0204c14:	000a8797          	auipc	a5,0xa8
ffffffffc0204c18:	9d478793          	addi	a5,a5,-1580 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0204c1c:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204c1e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c22:	97278793          	addi	a5,a5,-1678 # ffffffffc02ac590 <npage>
ffffffffc0204c26:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204c28:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204c2a:	82b1                	srli	a3,a3,0xc
ffffffffc0204c2c:	04f6f063          	bleu	a5,a3,ffffffffc0204c6c <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204c30:	00004797          	auipc	a5,0x4
ffffffffc0204c34:	e3878793          	addi	a5,a5,-456 # ffffffffc0208a68 <nbase>
ffffffffc0204c38:	639c                	ld	a5,0(a5)
ffffffffc0204c3a:	000a8717          	auipc	a4,0xa8
ffffffffc0204c3e:	9be70713          	addi	a4,a4,-1602 # ffffffffc02ac5f8 <pages>
ffffffffc0204c42:	6308                	ld	a0,0(a4)
}
ffffffffc0204c44:	60a2                	ld	ra,8(sp)
ffffffffc0204c46:	8e9d                	sub	a3,a3,a5
ffffffffc0204c48:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204c4a:	4585                	li	a1,1
ffffffffc0204c4c:	9536                	add	a0,a0,a3
}
ffffffffc0204c4e:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204c50:	a86fc06f          	j	ffffffffc0200ed6 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204c54:	00002617          	auipc	a2,0x2
ffffffffc0204c58:	26460613          	addi	a2,a2,612 # ffffffffc0206eb8 <commands+0x958>
ffffffffc0204c5c:	06e00593          	li	a1,110
ffffffffc0204c60:	00002517          	auipc	a0,0x2
ffffffffc0204c64:	1d850513          	addi	a0,a0,472 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0204c68:	daefb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204c6c:	00002617          	auipc	a2,0x2
ffffffffc0204c70:	1ac60613          	addi	a2,a2,428 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc0204c74:	06200593          	li	a1,98
ffffffffc0204c78:	00002517          	auipc	a0,0x2
ffffffffc0204c7c:	1c050513          	addi	a0,a0,448 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0204c80:	d96fb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204c84 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204c84:	1101                	addi	sp,sp,-32
ffffffffc0204c86:	e426                	sd	s1,8(sp)
ffffffffc0204c88:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204c8a:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204c8c:	ec06                	sd	ra,24(sp)
ffffffffc0204c8e:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204c90:	9befc0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
ffffffffc0204c94:	c125                	beqz	a0,ffffffffc0204cf4 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204c96:	000a8797          	auipc	a5,0xa8
ffffffffc0204c9a:	96278793          	addi	a5,a5,-1694 # ffffffffc02ac5f8 <pages>
ffffffffc0204c9e:	6394                	ld	a3,0(a5)
ffffffffc0204ca0:	00004797          	auipc	a5,0x4
ffffffffc0204ca4:	dc878793          	addi	a5,a5,-568 # ffffffffc0208a68 <nbase>
ffffffffc0204ca8:	6380                	ld	s0,0(a5)
ffffffffc0204caa:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204cae:	000a8717          	auipc	a4,0xa8
ffffffffc0204cb2:	8e270713          	addi	a4,a4,-1822 # ffffffffc02ac590 <npage>
    return page - pages + nbase;
ffffffffc0204cb6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204cb8:	57fd                	li	a5,-1
ffffffffc0204cba:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204cbc:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204cbe:	83b1                	srli	a5,a5,0xc
ffffffffc0204cc0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cc2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cc4:	02e7fa63          	bleu	a4,a5,ffffffffc0204cf8 <setup_pgdir+0x74>
ffffffffc0204cc8:	000a8797          	auipc	a5,0xa8
ffffffffc0204ccc:	92078793          	addi	a5,a5,-1760 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0204cd0:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204cd2:	000a8797          	auipc	a5,0xa8
ffffffffc0204cd6:	8b678793          	addi	a5,a5,-1866 # ffffffffc02ac588 <boot_pgdir>
ffffffffc0204cda:	638c                	ld	a1,0(a5)
ffffffffc0204cdc:	9436                	add	s0,s0,a3
ffffffffc0204cde:	6605                	lui	a2,0x1
ffffffffc0204ce0:	8522                	mv	a0,s0
ffffffffc0204ce2:	2e4010ef          	jal	ra,ffffffffc0205fc6 <memcpy>
    return 0;
ffffffffc0204ce6:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204ce8:	ec80                	sd	s0,24(s1)
}
ffffffffc0204cea:	60e2                	ld	ra,24(sp)
ffffffffc0204cec:	6442                	ld	s0,16(sp)
ffffffffc0204cee:	64a2                	ld	s1,8(sp)
ffffffffc0204cf0:	6105                	addi	sp,sp,32
ffffffffc0204cf2:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204cf4:	5571                	li	a0,-4
ffffffffc0204cf6:	bfd5                	j	ffffffffc0204cea <setup_pgdir+0x66>
ffffffffc0204cf8:	00002617          	auipc	a2,0x2
ffffffffc0204cfc:	0e860613          	addi	a2,a2,232 # ffffffffc0206de0 <commands+0x880>
ffffffffc0204d00:	06900593          	li	a1,105
ffffffffc0204d04:	00002517          	auipc	a0,0x2
ffffffffc0204d08:	13450513          	addi	a0,a0,308 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0204d0c:	d0afb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0204d10 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d10:	1101                	addi	sp,sp,-32
ffffffffc0204d12:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d14:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d18:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d1a:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d1c:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d1e:	8522                	mv	a0,s0
ffffffffc0204d20:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204d22:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d24:	290010ef          	jal	ra,ffffffffc0205fb4 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d28:	8522                	mv	a0,s0
}
ffffffffc0204d2a:	6442                	ld	s0,16(sp)
ffffffffc0204d2c:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d2e:	85a6                	mv	a1,s1
}
ffffffffc0204d30:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d32:	463d                	li	a2,15
}
ffffffffc0204d34:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204d36:	2900106f          	j	ffffffffc0205fc6 <memcpy>

ffffffffc0204d3a <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204d3a:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204d3c:	000a8797          	auipc	a5,0xa8
ffffffffc0204d40:	87c78793          	addi	a5,a5,-1924 # ffffffffc02ac5b8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204d44:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204d46:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204d48:	ec06                	sd	ra,24(sp)
ffffffffc0204d4a:	e822                	sd	s0,16(sp)
ffffffffc0204d4c:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204d4e:	02a48b63          	beq	s1,a0,ffffffffc0204d84 <proc_run+0x4a>
ffffffffc0204d52:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d54:	100027f3          	csrr	a5,sstatus
ffffffffc0204d58:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204d5a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d5c:	e3a9                	bnez	a5,ffffffffc0204d9e <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204d5e:	745c                	ld	a5,168(s0)
        current = proc;
ffffffffc0204d60:	000a8717          	auipc	a4,0xa8
ffffffffc0204d64:	84873c23          	sd	s0,-1960(a4) # ffffffffc02ac5b8 <current>
ffffffffc0204d68:	577d                	li	a4,-1
ffffffffc0204d6a:	177e                	slli	a4,a4,0x3f
ffffffffc0204d6c:	83b1                	srli	a5,a5,0xc
ffffffffc0204d6e:	8fd9                	or	a5,a5,a4
ffffffffc0204d70:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(next->context));
ffffffffc0204d74:	03040593          	addi	a1,s0,48
ffffffffc0204d78:	03048513          	addi	a0,s1,48
ffffffffc0204d7c:	d13ff0ef          	jal	ra,ffffffffc0204a8e <switch_to>
    if (flag) {
ffffffffc0204d80:	00091863          	bnez	s2,ffffffffc0204d90 <proc_run+0x56>
}
ffffffffc0204d84:	60e2                	ld	ra,24(sp)
ffffffffc0204d86:	6442                	ld	s0,16(sp)
ffffffffc0204d88:	64a2                	ld	s1,8(sp)
ffffffffc0204d8a:	6902                	ld	s2,0(sp)
ffffffffc0204d8c:	6105                	addi	sp,sp,32
ffffffffc0204d8e:	8082                	ret
ffffffffc0204d90:	6442                	ld	s0,16(sp)
ffffffffc0204d92:	60e2                	ld	ra,24(sp)
ffffffffc0204d94:	64a2                	ld	s1,8(sp)
ffffffffc0204d96:	6902                	ld	s2,0(sp)
ffffffffc0204d98:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204d9a:	899fb06f          	j	ffffffffc0200632 <intr_enable>
        intr_disable();
ffffffffc0204d9e:	89bfb0ef          	jal	ra,ffffffffc0200638 <intr_disable>
        return 1;
ffffffffc0204da2:	4905                	li	s2,1
ffffffffc0204da4:	bf6d                	j	ffffffffc0204d5e <proc_run+0x24>

ffffffffc0204da6 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204da6:	0005071b          	sext.w	a4,a0
ffffffffc0204daa:	6789                	lui	a5,0x2
ffffffffc0204dac:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204db0:	17f9                	addi	a5,a5,-2
ffffffffc0204db2:	04d7e063          	bltu	a5,a3,ffffffffc0204df2 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204db6:	1141                	addi	sp,sp,-16
ffffffffc0204db8:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204dba:	45a9                	li	a1,10
ffffffffc0204dbc:	842a                	mv	s0,a0
ffffffffc0204dbe:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204dc0:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204dc2:	614010ef          	jal	ra,ffffffffc02063d6 <hash32>
ffffffffc0204dc6:	02051693          	slli	a3,a0,0x20
ffffffffc0204dca:	82f1                	srli	a3,a3,0x1c
ffffffffc0204dcc:	000a3517          	auipc	a0,0xa3
ffffffffc0204dd0:	7ac50513          	addi	a0,a0,1964 # ffffffffc02a8578 <hash_list>
ffffffffc0204dd4:	96aa                	add	a3,a3,a0
ffffffffc0204dd6:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204dd8:	a029                	j	ffffffffc0204de2 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204dda:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x765c>
ffffffffc0204dde:	00870c63          	beq	a4,s0,ffffffffc0204df6 <find_proc+0x50>
    return listelm->next;
ffffffffc0204de2:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204de4:	fef69be3          	bne	a3,a5,ffffffffc0204dda <find_proc+0x34>
}
ffffffffc0204de8:	60a2                	ld	ra,8(sp)
ffffffffc0204dea:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204dec:	4501                	li	a0,0
}
ffffffffc0204dee:	0141                	addi	sp,sp,16
ffffffffc0204df0:	8082                	ret
    return NULL;
ffffffffc0204df2:	4501                	li	a0,0
}
ffffffffc0204df4:	8082                	ret
ffffffffc0204df6:	60a2                	ld	ra,8(sp)
ffffffffc0204df8:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204dfa:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204dfe:	0141                	addi	sp,sp,16
ffffffffc0204e00:	8082                	ret

ffffffffc0204e02 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204e02:	7159                	addi	sp,sp,-112
ffffffffc0204e04:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204e06:	000a7a17          	auipc	s4,0xa7
ffffffffc0204e0a:	7caa0a13          	addi	s4,s4,1994 # ffffffffc02ac5d0 <nr_process>
ffffffffc0204e0e:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204e12:	f486                	sd	ra,104(sp)
ffffffffc0204e14:	f0a2                	sd	s0,96(sp)
ffffffffc0204e16:	eca6                	sd	s1,88(sp)
ffffffffc0204e18:	e8ca                	sd	s2,80(sp)
ffffffffc0204e1a:	e4ce                	sd	s3,72(sp)
ffffffffc0204e1c:	fc56                	sd	s5,56(sp)
ffffffffc0204e1e:	f85a                	sd	s6,48(sp)
ffffffffc0204e20:	f45e                	sd	s7,40(sp)
ffffffffc0204e22:	f062                	sd	s8,32(sp)
ffffffffc0204e24:	ec66                	sd	s9,24(sp)
ffffffffc0204e26:	e86a                	sd	s10,16(sp)
ffffffffc0204e28:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204e2a:	6785                	lui	a5,0x1
ffffffffc0204e2c:	30f75a63          	ble	a5,a4,ffffffffc0205140 <do_fork+0x33e>
ffffffffc0204e30:	89aa                	mv	s3,a0
ffffffffc0204e32:	892e                	mv	s2,a1
ffffffffc0204e34:	84b2                	mv	s1,a2
     if ((proc = alloc_proc()) == NULL)
ffffffffc0204e36:	ccbff0ef          	jal	ra,ffffffffc0204b00 <alloc_proc>
ffffffffc0204e3a:	842a                	mv	s0,a0
ffffffffc0204e3c:	2e050463          	beqz	a0,ffffffffc0205124 <do_fork+0x322>
    proc->parent = current;
ffffffffc0204e40:	000a7c17          	auipc	s8,0xa7
ffffffffc0204e44:	778c0c13          	addi	s8,s8,1912 # ffffffffc02ac5b8 <current>
ffffffffc0204e48:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204e4c:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x849c>
    proc->parent = current;
ffffffffc0204e50:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204e52:	30071563          	bnez	a4,ffffffffc020515c <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204e56:	4509                	li	a0,2
ffffffffc0204e58:	ff7fb0ef          	jal	ra,ffffffffc0200e4e <alloc_pages>
    if (page != NULL) {
ffffffffc0204e5c:	2c050163          	beqz	a0,ffffffffc020511e <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0204e60:	000a7a97          	auipc	s5,0xa7
ffffffffc0204e64:	798a8a93          	addi	s5,s5,1944 # ffffffffc02ac5f8 <pages>
ffffffffc0204e68:	000ab683          	ld	a3,0(s5)
ffffffffc0204e6c:	00004b17          	auipc	s6,0x4
ffffffffc0204e70:	bfcb0b13          	addi	s6,s6,-1028 # ffffffffc0208a68 <nbase>
ffffffffc0204e74:	000b3783          	ld	a5,0(s6)
ffffffffc0204e78:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e7c:	000a7b97          	auipc	s7,0xa7
ffffffffc0204e80:	714b8b93          	addi	s7,s7,1812 # ffffffffc02ac590 <npage>
    return page - pages + nbase;
ffffffffc0204e84:	8699                	srai	a3,a3,0x6
ffffffffc0204e86:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204e88:	000bb703          	ld	a4,0(s7)
ffffffffc0204e8c:	57fd                	li	a5,-1
ffffffffc0204e8e:	83b1                	srli	a5,a5,0xc
ffffffffc0204e90:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e92:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e94:	2ae7f863          	bleu	a4,a5,ffffffffc0205144 <do_fork+0x342>
ffffffffc0204e98:	000a7c97          	auipc	s9,0xa7
ffffffffc0204e9c:	750c8c93          	addi	s9,s9,1872 # ffffffffc02ac5e8 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204ea0:	000c3703          	ld	a4,0(s8)
ffffffffc0204ea4:	000cb783          	ld	a5,0(s9)
ffffffffc0204ea8:	02873c03          	ld	s8,40(a4)
ffffffffc0204eac:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204eae:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0204eb0:	020c0863          	beqz	s8,ffffffffc0204ee0 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0204eb4:	1009f993          	andi	s3,s3,256
ffffffffc0204eb8:	1e098163          	beqz	s3,ffffffffc020509a <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204ebc:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204ec0:	018c3783          	ld	a5,24(s8)
ffffffffc0204ec4:	c02006b7          	lui	a3,0xc0200
ffffffffc0204ec8:	2705                	addiw	a4,a4,1
ffffffffc0204eca:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0204ece:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204ed2:	2ad7e563          	bltu	a5,a3,ffffffffc020517c <do_fork+0x37a>
ffffffffc0204ed6:	000cb703          	ld	a4,0(s9)
ffffffffc0204eda:	6814                	ld	a3,16(s0)
ffffffffc0204edc:	8f99                	sub	a5,a5,a4
ffffffffc0204ede:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ee0:	6789                	lui	a5,0x2
ffffffffc0204ee2:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76a8>
ffffffffc0204ee6:	96be                	add	a3,a3,a5
ffffffffc0204ee8:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204eea:	87b6                	mv	a5,a3
ffffffffc0204eec:	12048813          	addi	a6,s1,288
ffffffffc0204ef0:	6088                	ld	a0,0(s1)
ffffffffc0204ef2:	648c                	ld	a1,8(s1)
ffffffffc0204ef4:	6890                	ld	a2,16(s1)
ffffffffc0204ef6:	6c98                	ld	a4,24(s1)
ffffffffc0204ef8:	e388                	sd	a0,0(a5)
ffffffffc0204efa:	e78c                	sd	a1,8(a5)
ffffffffc0204efc:	eb90                	sd	a2,16(a5)
ffffffffc0204efe:	ef98                	sd	a4,24(a5)
ffffffffc0204f00:	02048493          	addi	s1,s1,32
ffffffffc0204f04:	02078793          	addi	a5,a5,32
ffffffffc0204f08:	ff0494e3          	bne	s1,a6,ffffffffc0204ef0 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc0204f0c:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204f10:	12090e63          	beqz	s2,ffffffffc020504c <do_fork+0x24a>
ffffffffc0204f14:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204f18:	00000797          	auipc	a5,0x0
ffffffffc0204f1c:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204b74 <forkret>
ffffffffc0204f20:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204f22:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f24:	100027f3          	csrr	a5,sstatus
ffffffffc0204f28:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f2a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f2c:	12079f63          	bnez	a5,ffffffffc020506a <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204f30:	0009c797          	auipc	a5,0x9c
ffffffffc0204f34:	24078793          	addi	a5,a5,576 # ffffffffc02a1170 <last_pid.1691>
ffffffffc0204f38:	439c                	lw	a5,0(a5)
ffffffffc0204f3a:	6709                	lui	a4,0x2
ffffffffc0204f3c:	0017851b          	addiw	a0,a5,1
ffffffffc0204f40:	0009c697          	auipc	a3,0x9c
ffffffffc0204f44:	22a6a823          	sw	a0,560(a3) # ffffffffc02a1170 <last_pid.1691>
ffffffffc0204f48:	14e55263          	ble	a4,a0,ffffffffc020508c <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc0204f4c:	0009c797          	auipc	a5,0x9c
ffffffffc0204f50:	22878793          	addi	a5,a5,552 # ffffffffc02a1174 <next_safe.1690>
ffffffffc0204f54:	439c                	lw	a5,0(a5)
ffffffffc0204f56:	000a7497          	auipc	s1,0xa7
ffffffffc0204f5a:	7a248493          	addi	s1,s1,1954 # ffffffffc02ac6f8 <proc_list>
ffffffffc0204f5e:	06f54063          	blt	a0,a5,ffffffffc0204fbe <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0204f62:	6789                	lui	a5,0x2
ffffffffc0204f64:	0009c717          	auipc	a4,0x9c
ffffffffc0204f68:	20f72823          	sw	a5,528(a4) # ffffffffc02a1174 <next_safe.1690>
ffffffffc0204f6c:	4581                	li	a1,0
ffffffffc0204f6e:	87aa                	mv	a5,a0
ffffffffc0204f70:	000a7497          	auipc	s1,0xa7
ffffffffc0204f74:	78848493          	addi	s1,s1,1928 # ffffffffc02ac6f8 <proc_list>
    repeat:
ffffffffc0204f78:	6889                	lui	a7,0x2
ffffffffc0204f7a:	882e                	mv	a6,a1
ffffffffc0204f7c:	6609                	lui	a2,0x2
        le = list;
ffffffffc0204f7e:	000a7697          	auipc	a3,0xa7
ffffffffc0204f82:	77a68693          	addi	a3,a3,1914 # ffffffffc02ac6f8 <proc_list>
ffffffffc0204f86:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0204f88:	00968f63          	beq	a3,s1,ffffffffc0204fa6 <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc0204f8c:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204f90:	0ae78963          	beq	a5,a4,ffffffffc0205042 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204f94:	fee7d9e3          	ble	a4,a5,ffffffffc0204f86 <do_fork+0x184>
ffffffffc0204f98:	fec757e3          	ble	a2,a4,ffffffffc0204f86 <do_fork+0x184>
ffffffffc0204f9c:	6694                	ld	a3,8(a3)
ffffffffc0204f9e:	863a                	mv	a2,a4
ffffffffc0204fa0:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204fa2:	fe9695e3          	bne	a3,s1,ffffffffc0204f8c <do_fork+0x18a>
ffffffffc0204fa6:	c591                	beqz	a1,ffffffffc0204fb2 <do_fork+0x1b0>
ffffffffc0204fa8:	0009c717          	auipc	a4,0x9c
ffffffffc0204fac:	1cf72423          	sw	a5,456(a4) # ffffffffc02a1170 <last_pid.1691>
ffffffffc0204fb0:	853e                	mv	a0,a5
ffffffffc0204fb2:	00080663          	beqz	a6,ffffffffc0204fbe <do_fork+0x1bc>
ffffffffc0204fb6:	0009c797          	auipc	a5,0x9c
ffffffffc0204fba:	1ac7af23          	sw	a2,446(a5) # ffffffffc02a1174 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc0204fbe:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204fc0:	45a9                	li	a1,10
ffffffffc0204fc2:	2501                	sext.w	a0,a0
ffffffffc0204fc4:	412010ef          	jal	ra,ffffffffc02063d6 <hash32>
ffffffffc0204fc8:	1502                	slli	a0,a0,0x20
ffffffffc0204fca:	000a3797          	auipc	a5,0xa3
ffffffffc0204fce:	5ae78793          	addi	a5,a5,1454 # ffffffffc02a8578 <hash_list>
ffffffffc0204fd2:	8171                	srli	a0,a0,0x1c
ffffffffc0204fd4:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204fd6:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204fd8:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204fda:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0204fde:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204fe0:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0204fe2:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204fe4:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204fe6:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0204fea:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0204fec:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204fee:	e21c                	sd	a5,0(a2)
ffffffffc0204ff0:	000a7597          	auipc	a1,0xa7
ffffffffc0204ff4:	70f5b823          	sd	a5,1808(a1) # ffffffffc02ac700 <proc_list+0x8>
    elm->next = next;
ffffffffc0204ff8:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204ffa:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0204ffc:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205000:	10e43023          	sd	a4,256(s0)
ffffffffc0205004:	c311                	beqz	a4,ffffffffc0205008 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc0205006:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205008:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc020500c:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc020500e:	2785                	addiw	a5,a5,1
ffffffffc0205010:	000a7717          	auipc	a4,0xa7
ffffffffc0205014:	5cf72023          	sw	a5,1472(a4) # ffffffffc02ac5d0 <nr_process>
    if (flag) {
ffffffffc0205018:	10091863          	bnez	s2,ffffffffc0205128 <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc020501c:	8522                	mv	a0,s0
ffffffffc020501e:	507000ef          	jal	ra,ffffffffc0205d24 <wakeup_proc>
    ret = proc->pid;
ffffffffc0205022:	4048                	lw	a0,4(s0)
}
ffffffffc0205024:	70a6                	ld	ra,104(sp)
ffffffffc0205026:	7406                	ld	s0,96(sp)
ffffffffc0205028:	64e6                	ld	s1,88(sp)
ffffffffc020502a:	6946                	ld	s2,80(sp)
ffffffffc020502c:	69a6                	ld	s3,72(sp)
ffffffffc020502e:	6a06                	ld	s4,64(sp)
ffffffffc0205030:	7ae2                	ld	s5,56(sp)
ffffffffc0205032:	7b42                	ld	s6,48(sp)
ffffffffc0205034:	7ba2                	ld	s7,40(sp)
ffffffffc0205036:	7c02                	ld	s8,32(sp)
ffffffffc0205038:	6ce2                	ld	s9,24(sp)
ffffffffc020503a:	6d42                	ld	s10,16(sp)
ffffffffc020503c:	6da2                	ld	s11,8(sp)
ffffffffc020503e:	6165                	addi	sp,sp,112
ffffffffc0205040:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205042:	2785                	addiw	a5,a5,1
ffffffffc0205044:	0ec7d563          	ble	a2,a5,ffffffffc020512e <do_fork+0x32c>
ffffffffc0205048:	4585                	li	a1,1
ffffffffc020504a:	bf35                	j	ffffffffc0204f86 <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020504c:	8936                	mv	s2,a3
ffffffffc020504e:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205052:	00000797          	auipc	a5,0x0
ffffffffc0205056:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204b74 <forkret>
ffffffffc020505a:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020505c:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020505e:	100027f3          	csrr	a5,sstatus
ffffffffc0205062:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205064:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205066:	ec0785e3          	beqz	a5,ffffffffc0204f30 <do_fork+0x12e>
        intr_disable();
ffffffffc020506a:	dcefb0ef          	jal	ra,ffffffffc0200638 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc020506e:	0009c797          	auipc	a5,0x9c
ffffffffc0205072:	10278793          	addi	a5,a5,258 # ffffffffc02a1170 <last_pid.1691>
ffffffffc0205076:	439c                	lw	a5,0(a5)
ffffffffc0205078:	6709                	lui	a4,0x2
        return 1;
ffffffffc020507a:	4905                	li	s2,1
ffffffffc020507c:	0017851b          	addiw	a0,a5,1
ffffffffc0205080:	0009c697          	auipc	a3,0x9c
ffffffffc0205084:	0ea6a823          	sw	a0,240(a3) # ffffffffc02a1170 <last_pid.1691>
ffffffffc0205088:	ece542e3          	blt	a0,a4,ffffffffc0204f4c <do_fork+0x14a>
        last_pid = 1;
ffffffffc020508c:	4785                	li	a5,1
ffffffffc020508e:	0009c717          	auipc	a4,0x9c
ffffffffc0205092:	0ef72123          	sw	a5,226(a4) # ffffffffc02a1170 <last_pid.1691>
ffffffffc0205096:	4505                	li	a0,1
ffffffffc0205098:	b5e9                	j	ffffffffc0204f62 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc020509a:	e58fd0ef          	jal	ra,ffffffffc02026f2 <mm_create>
ffffffffc020509e:	8daa                	mv	s11,a0
ffffffffc02050a0:	c539                	beqz	a0,ffffffffc02050ee <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc02050a2:	be3ff0ef          	jal	ra,ffffffffc0204c84 <setup_pgdir>
ffffffffc02050a6:	e949                	bnez	a0,ffffffffc0205138 <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02050a8:	038c0993          	addi	s3,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02050ac:	4785                	li	a5,1
ffffffffc02050ae:	40f9b7af          	amoor.d	a5,a5,(s3)
ffffffffc02050b2:	8b85                	andi	a5,a5,1
ffffffffc02050b4:	4d05                	li	s10,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02050b6:	c799                	beqz	a5,ffffffffc02050c4 <do_fork+0x2c2>
        schedule();
ffffffffc02050b8:	4e9000ef          	jal	ra,ffffffffc0205da0 <schedule>
ffffffffc02050bc:	41a9b7af          	amoor.d	a5,s10,(s3)
ffffffffc02050c0:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02050c2:	fbfd                	bnez	a5,ffffffffc02050b8 <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc02050c4:	85e2                	mv	a1,s8
ffffffffc02050c6:	856e                	mv	a0,s11
ffffffffc02050c8:	8b5fd0ef          	jal	ra,ffffffffc020297c <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02050cc:	57f9                	li	a5,-2
ffffffffc02050ce:	60f9b7af          	amoand.d	a5,a5,(s3)
ffffffffc02050d2:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02050d4:	c3e9                	beqz	a5,ffffffffc0205196 <do_fork+0x394>
    if (ret != 0) {
ffffffffc02050d6:	8c6e                	mv	s8,s11
ffffffffc02050d8:	de0502e3          	beqz	a0,ffffffffc0204ebc <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02050dc:	856e                	mv	a0,s11
ffffffffc02050de:	93bfd0ef          	jal	ra,ffffffffc0202a18 <exit_mmap>
    put_pgdir(mm);
ffffffffc02050e2:	856e                	mv	a0,s11
ffffffffc02050e4:	b23ff0ef          	jal	ra,ffffffffc0204c06 <put_pgdir>
    mm_destroy(mm);
ffffffffc02050e8:	856e                	mv	a0,s11
ffffffffc02050ea:	f8efd0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02050ee:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02050f0:	c02007b7          	lui	a5,0xc0200
ffffffffc02050f4:	0cf6e963          	bltu	a3,a5,ffffffffc02051c6 <do_fork+0x3c4>
ffffffffc02050f8:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02050fc:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205100:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205104:	83b1                	srli	a5,a5,0xc
ffffffffc0205106:	0ae7f463          	bleu	a4,a5,ffffffffc02051ae <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc020510a:	000b3703          	ld	a4,0(s6)
ffffffffc020510e:	000ab503          	ld	a0,0(s5)
ffffffffc0205112:	4589                	li	a1,2
ffffffffc0205114:	8f99                	sub	a5,a5,a4
ffffffffc0205116:	079a                	slli	a5,a5,0x6
ffffffffc0205118:	953e                	add	a0,a0,a5
ffffffffc020511a:	dbdfb0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    kfree(proc);
ffffffffc020511e:	8522                	mv	a0,s0
ffffffffc0205120:	b78fe0ef          	jal	ra,ffffffffc0203498 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205124:	5571                	li	a0,-4
    return ret;
ffffffffc0205126:	bdfd                	j	ffffffffc0205024 <do_fork+0x222>
        intr_enable();
ffffffffc0205128:	d0afb0ef          	jal	ra,ffffffffc0200632 <intr_enable>
ffffffffc020512c:	bdc5                	j	ffffffffc020501c <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc020512e:	0117c363          	blt	a5,a7,ffffffffc0205134 <do_fork+0x332>
                        last_pid = 1;
ffffffffc0205132:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205134:	4585                	li	a1,1
ffffffffc0205136:	b591                	j	ffffffffc0204f7a <do_fork+0x178>
    mm_destroy(mm);
ffffffffc0205138:	856e                	mv	a0,s11
ffffffffc020513a:	f3efd0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
ffffffffc020513e:	bf45                	j	ffffffffc02050ee <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205140:	556d                	li	a0,-5
ffffffffc0205142:	b5cd                	j	ffffffffc0205024 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc0205144:	00002617          	auipc	a2,0x2
ffffffffc0205148:	c9c60613          	addi	a2,a2,-868 # ffffffffc0206de0 <commands+0x880>
ffffffffc020514c:	06900593          	li	a1,105
ffffffffc0205150:	00002517          	auipc	a0,0x2
ffffffffc0205154:	ce850513          	addi	a0,a0,-792 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0205158:	8befb0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc020515c:	00003697          	auipc	a3,0x3
ffffffffc0205160:	1b468693          	addi	a3,a3,436 # ffffffffc0208310 <default_pmm_manager+0x270>
ffffffffc0205164:	00002617          	auipc	a2,0x2
ffffffffc0205168:	87c60613          	addi	a2,a2,-1924 # ffffffffc02069e0 <commands+0x480>
ffffffffc020516c:	1af00593          	li	a1,431
ffffffffc0205170:	00003517          	auipc	a0,0x3
ffffffffc0205174:	43050513          	addi	a0,a0,1072 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205178:	89efb0ef          	jal	ra,ffffffffc0200216 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020517c:	86be                	mv	a3,a5
ffffffffc020517e:	00002617          	auipc	a2,0x2
ffffffffc0205182:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206eb8 <commands+0x958>
ffffffffc0205186:	16300593          	li	a1,355
ffffffffc020518a:	00003517          	auipc	a0,0x3
ffffffffc020518e:	41650513          	addi	a0,a0,1046 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205192:	884fb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205196:	00003617          	auipc	a2,0x3
ffffffffc020519a:	19a60613          	addi	a2,a2,410 # ffffffffc0208330 <default_pmm_manager+0x290>
ffffffffc020519e:	03100593          	li	a1,49
ffffffffc02051a2:	00003517          	auipc	a0,0x3
ffffffffc02051a6:	19e50513          	addi	a0,a0,414 # ffffffffc0208340 <default_pmm_manager+0x2a0>
ffffffffc02051aa:	86cfb0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02051ae:	00002617          	auipc	a2,0x2
ffffffffc02051b2:	c6a60613          	addi	a2,a2,-918 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc02051b6:	06200593          	li	a1,98
ffffffffc02051ba:	00002517          	auipc	a0,0x2
ffffffffc02051be:	c7e50513          	addi	a0,a0,-898 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc02051c2:	854fb0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02051c6:	00002617          	auipc	a2,0x2
ffffffffc02051ca:	cf260613          	addi	a2,a2,-782 # ffffffffc0206eb8 <commands+0x958>
ffffffffc02051ce:	06e00593          	li	a1,110
ffffffffc02051d2:	00002517          	auipc	a0,0x2
ffffffffc02051d6:	c6650513          	addi	a0,a0,-922 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc02051da:	83cfb0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc02051de <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02051de:	7129                	addi	sp,sp,-320
ffffffffc02051e0:	fa22                	sd	s0,304(sp)
ffffffffc02051e2:	f626                	sd	s1,296(sp)
ffffffffc02051e4:	f24a                	sd	s2,288(sp)
ffffffffc02051e6:	84ae                	mv	s1,a1
ffffffffc02051e8:	892a                	mv	s2,a0
ffffffffc02051ea:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02051ec:	4581                	li	a1,0
ffffffffc02051ee:	12000613          	li	a2,288
ffffffffc02051f2:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02051f4:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02051f6:	5bf000ef          	jal	ra,ffffffffc0205fb4 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02051fa:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02051fc:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02051fe:	100027f3          	csrr	a5,sstatus
ffffffffc0205202:	edd7f793          	andi	a5,a5,-291
ffffffffc0205206:	1207e793          	ori	a5,a5,288
ffffffffc020520a:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020520c:	860a                	mv	a2,sp
ffffffffc020520e:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205212:	00000797          	auipc	a5,0x0
ffffffffc0205216:	8e678793          	addi	a5,a5,-1818 # ffffffffc0204af8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020521a:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020521c:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020521e:	be5ff0ef          	jal	ra,ffffffffc0204e02 <do_fork>
}
ffffffffc0205222:	70f2                	ld	ra,312(sp)
ffffffffc0205224:	7452                	ld	s0,304(sp)
ffffffffc0205226:	74b2                	ld	s1,296(sp)
ffffffffc0205228:	7912                	ld	s2,288(sp)
ffffffffc020522a:	6131                	addi	sp,sp,320
ffffffffc020522c:	8082                	ret

ffffffffc020522e <do_exit>:
do_exit(int error_code) {
ffffffffc020522e:	7179                	addi	sp,sp,-48
ffffffffc0205230:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205232:	000a7717          	auipc	a4,0xa7
ffffffffc0205236:	38e70713          	addi	a4,a4,910 # ffffffffc02ac5c0 <idleproc>
ffffffffc020523a:	000a7917          	auipc	s2,0xa7
ffffffffc020523e:	37e90913          	addi	s2,s2,894 # ffffffffc02ac5b8 <current>
ffffffffc0205242:	00093783          	ld	a5,0(s2)
ffffffffc0205246:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205248:	f406                	sd	ra,40(sp)
ffffffffc020524a:	f022                	sd	s0,32(sp)
ffffffffc020524c:	ec26                	sd	s1,24(sp)
ffffffffc020524e:	e44e                	sd	s3,8(sp)
ffffffffc0205250:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205252:	0ce78c63          	beq	a5,a4,ffffffffc020532a <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205256:	000a7417          	auipc	s0,0xa7
ffffffffc020525a:	37240413          	addi	s0,s0,882 # ffffffffc02ac5c8 <initproc>
ffffffffc020525e:	6018                	ld	a4,0(s0)
ffffffffc0205260:	0ee78b63          	beq	a5,a4,ffffffffc0205356 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205264:	7784                	ld	s1,40(a5)
ffffffffc0205266:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205268:	c48d                	beqz	s1,ffffffffc0205292 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc020526a:	000a7797          	auipc	a5,0xa7
ffffffffc020526e:	38678793          	addi	a5,a5,902 # ffffffffc02ac5f0 <boot_cr3>
ffffffffc0205272:	639c                	ld	a5,0(a5)
ffffffffc0205274:	577d                	li	a4,-1
ffffffffc0205276:	177e                	slli	a4,a4,0x3f
ffffffffc0205278:	83b1                	srli	a5,a5,0xc
ffffffffc020527a:	8fd9                	or	a5,a5,a4
ffffffffc020527c:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205280:	589c                	lw	a5,48(s1)
ffffffffc0205282:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205286:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205288:	cf4d                	beqz	a4,ffffffffc0205342 <do_exit+0x114>
        current->mm = NULL;
ffffffffc020528a:	00093783          	ld	a5,0(s2)
ffffffffc020528e:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205292:	00093783          	ld	a5,0(s2)
ffffffffc0205296:	470d                	li	a4,3
ffffffffc0205298:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc020529a:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020529e:	100027f3          	csrr	a5,sstatus
ffffffffc02052a2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052a4:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052a6:	e7e1                	bnez	a5,ffffffffc020536e <do_exit+0x140>
        proc = current->parent;
ffffffffc02052a8:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052ac:	800007b7          	lui	a5,0x80000
ffffffffc02052b0:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02052b2:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02052b4:	0ec52703          	lw	a4,236(a0)
ffffffffc02052b8:	0af70f63          	beq	a4,a5,ffffffffc0205376 <do_exit+0x148>
ffffffffc02052bc:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052c0:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052c4:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052c6:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc02052c8:	7afc                	ld	a5,240(a3)
ffffffffc02052ca:	cb95                	beqz	a5,ffffffffc02052fe <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02052cc:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5670>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052d0:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02052d2:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052d4:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02052d6:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02052da:	10e7b023          	sd	a4,256(a5)
ffffffffc02052de:	c311                	beqz	a4,ffffffffc02052e2 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02052e0:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052e2:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02052e4:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02052e6:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052e8:	fe9710e3          	bne	a4,s1,ffffffffc02052c8 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02052ec:	0ec52783          	lw	a5,236(a0)
ffffffffc02052f0:	fd379ce3          	bne	a5,s3,ffffffffc02052c8 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02052f4:	231000ef          	jal	ra,ffffffffc0205d24 <wakeup_proc>
ffffffffc02052f8:	00093683          	ld	a3,0(s2)
ffffffffc02052fc:	b7f1                	j	ffffffffc02052c8 <do_exit+0x9a>
    if (flag) {
ffffffffc02052fe:	020a1363          	bnez	s4,ffffffffc0205324 <do_exit+0xf6>
    schedule();
ffffffffc0205302:	29f000ef          	jal	ra,ffffffffc0205da0 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205306:	00093783          	ld	a5,0(s2)
ffffffffc020530a:	00003617          	auipc	a2,0x3
ffffffffc020530e:	fe660613          	addi	a2,a2,-26 # ffffffffc02082f0 <default_pmm_manager+0x250>
ffffffffc0205312:	20400593          	li	a1,516
ffffffffc0205316:	43d4                	lw	a3,4(a5)
ffffffffc0205318:	00003517          	auipc	a0,0x3
ffffffffc020531c:	28850513          	addi	a0,a0,648 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205320:	ef7fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_enable();
ffffffffc0205324:	b0efb0ef          	jal	ra,ffffffffc0200632 <intr_enable>
ffffffffc0205328:	bfe9                	j	ffffffffc0205302 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc020532a:	00003617          	auipc	a2,0x3
ffffffffc020532e:	fa660613          	addi	a2,a2,-90 # ffffffffc02082d0 <default_pmm_manager+0x230>
ffffffffc0205332:	1d800593          	li	a1,472
ffffffffc0205336:	00003517          	auipc	a0,0x3
ffffffffc020533a:	26a50513          	addi	a0,a0,618 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc020533e:	ed9fa0ef          	jal	ra,ffffffffc0200216 <__panic>
            exit_mmap(mm);
ffffffffc0205342:	8526                	mv	a0,s1
ffffffffc0205344:	ed4fd0ef          	jal	ra,ffffffffc0202a18 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205348:	8526                	mv	a0,s1
ffffffffc020534a:	8bdff0ef          	jal	ra,ffffffffc0204c06 <put_pgdir>
            mm_destroy(mm);
ffffffffc020534e:	8526                	mv	a0,s1
ffffffffc0205350:	d28fd0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
ffffffffc0205354:	bf1d                	j	ffffffffc020528a <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205356:	00003617          	auipc	a2,0x3
ffffffffc020535a:	f8a60613          	addi	a2,a2,-118 # ffffffffc02082e0 <default_pmm_manager+0x240>
ffffffffc020535e:	1db00593          	li	a1,475
ffffffffc0205362:	00003517          	auipc	a0,0x3
ffffffffc0205366:	23e50513          	addi	a0,a0,574 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc020536a:	eadfa0ef          	jal	ra,ffffffffc0200216 <__panic>
        intr_disable();
ffffffffc020536e:	acafb0ef          	jal	ra,ffffffffc0200638 <intr_disable>
        return 1;
ffffffffc0205372:	4a05                	li	s4,1
ffffffffc0205374:	bf15                	j	ffffffffc02052a8 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205376:	1af000ef          	jal	ra,ffffffffc0205d24 <wakeup_proc>
ffffffffc020537a:	b789                	j	ffffffffc02052bc <do_exit+0x8e>

ffffffffc020537c <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc020537c:	7139                	addi	sp,sp,-64
ffffffffc020537e:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205380:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205384:	f426                	sd	s1,40(sp)
ffffffffc0205386:	f04a                	sd	s2,32(sp)
ffffffffc0205388:	ec4e                	sd	s3,24(sp)
ffffffffc020538a:	e456                	sd	s5,8(sp)
ffffffffc020538c:	e05a                	sd	s6,0(sp)
ffffffffc020538e:	fc06                	sd	ra,56(sp)
ffffffffc0205390:	f822                	sd	s0,48(sp)
ffffffffc0205392:	89aa                	mv	s3,a0
ffffffffc0205394:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205396:	000a7917          	auipc	s2,0xa7
ffffffffc020539a:	22290913          	addi	s2,s2,546 # ffffffffc02ac5b8 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020539e:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02053a0:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02053a2:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc02053a4:	02098f63          	beqz	s3,ffffffffc02053e2 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02053a8:	854e                	mv	a0,s3
ffffffffc02053aa:	9fdff0ef          	jal	ra,ffffffffc0204da6 <find_proc>
ffffffffc02053ae:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02053b0:	12050063          	beqz	a0,ffffffffc02054d0 <do_wait.part.1+0x154>
ffffffffc02053b4:	00093703          	ld	a4,0(s2)
ffffffffc02053b8:	711c                	ld	a5,32(a0)
ffffffffc02053ba:	10e79b63          	bne	a5,a4,ffffffffc02054d0 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053be:	411c                	lw	a5,0(a0)
ffffffffc02053c0:	02978c63          	beq	a5,s1,ffffffffc02053f8 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02053c4:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02053c8:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02053cc:	1d5000ef          	jal	ra,ffffffffc0205da0 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02053d0:	00093783          	ld	a5,0(s2)
ffffffffc02053d4:	0b07a783          	lw	a5,176(a5)
ffffffffc02053d8:	8b85                	andi	a5,a5,1
ffffffffc02053da:	d7e9                	beqz	a5,ffffffffc02053a4 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02053dc:	555d                	li	a0,-9
ffffffffc02053de:	e51ff0ef          	jal	ra,ffffffffc020522e <do_exit>
        proc = current->cptr;
ffffffffc02053e2:	00093703          	ld	a4,0(s2)
ffffffffc02053e6:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02053e8:	e409                	bnez	s0,ffffffffc02053f2 <do_wait.part.1+0x76>
ffffffffc02053ea:	a0dd                	j	ffffffffc02054d0 <do_wait.part.1+0x154>
ffffffffc02053ec:	10043403          	ld	s0,256(s0)
ffffffffc02053f0:	d871                	beqz	s0,ffffffffc02053c4 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053f2:	401c                	lw	a5,0(s0)
ffffffffc02053f4:	fe979ce3          	bne	a5,s1,ffffffffc02053ec <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02053f8:	000a7797          	auipc	a5,0xa7
ffffffffc02053fc:	1c878793          	addi	a5,a5,456 # ffffffffc02ac5c0 <idleproc>
ffffffffc0205400:	639c                	ld	a5,0(a5)
ffffffffc0205402:	0c878d63          	beq	a5,s0,ffffffffc02054dc <do_wait.part.1+0x160>
ffffffffc0205406:	000a7797          	auipc	a5,0xa7
ffffffffc020540a:	1c278793          	addi	a5,a5,450 # ffffffffc02ac5c8 <initproc>
ffffffffc020540e:	639c                	ld	a5,0(a5)
ffffffffc0205410:	0cf40663          	beq	s0,a5,ffffffffc02054dc <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205414:	000b0663          	beqz	s6,ffffffffc0205420 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205418:	0e842783          	lw	a5,232(s0)
ffffffffc020541c:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205420:	100027f3          	csrr	a5,sstatus
ffffffffc0205424:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205426:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205428:	e7d5                	bnez	a5,ffffffffc02054d4 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc020542a:	6c70                	ld	a2,216(s0)
ffffffffc020542c:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020542e:	10043703          	ld	a4,256(s0)
ffffffffc0205432:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205434:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205436:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205438:	6470                	ld	a2,200(s0)
ffffffffc020543a:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020543c:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020543e:	e290                	sd	a2,0(a3)
ffffffffc0205440:	c319                	beqz	a4,ffffffffc0205446 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205442:	ff7c                	sd	a5,248(a4)
ffffffffc0205444:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205446:	c3d1                	beqz	a5,ffffffffc02054ca <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205448:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020544c:	000a7797          	auipc	a5,0xa7
ffffffffc0205450:	18478793          	addi	a5,a5,388 # ffffffffc02ac5d0 <nr_process>
ffffffffc0205454:	439c                	lw	a5,0(a5)
ffffffffc0205456:	37fd                	addiw	a5,a5,-1
ffffffffc0205458:	000a7717          	auipc	a4,0xa7
ffffffffc020545c:	16f72c23          	sw	a5,376(a4) # ffffffffc02ac5d0 <nr_process>
    if (flag) {
ffffffffc0205460:	e1b5                	bnez	a1,ffffffffc02054c4 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205462:	6814                	ld	a3,16(s0)
ffffffffc0205464:	c02007b7          	lui	a5,0xc0200
ffffffffc0205468:	0af6e263          	bltu	a3,a5,ffffffffc020550c <do_wait.part.1+0x190>
ffffffffc020546c:	000a7797          	auipc	a5,0xa7
ffffffffc0205470:	17c78793          	addi	a5,a5,380 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0205474:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205476:	000a7797          	auipc	a5,0xa7
ffffffffc020547a:	11a78793          	addi	a5,a5,282 # ffffffffc02ac590 <npage>
ffffffffc020547e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205480:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205482:	82b1                	srli	a3,a3,0xc
ffffffffc0205484:	06f6f863          	bleu	a5,a3,ffffffffc02054f4 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205488:	00003797          	auipc	a5,0x3
ffffffffc020548c:	5e078793          	addi	a5,a5,1504 # ffffffffc0208a68 <nbase>
ffffffffc0205490:	639c                	ld	a5,0(a5)
ffffffffc0205492:	000a7717          	auipc	a4,0xa7
ffffffffc0205496:	16670713          	addi	a4,a4,358 # ffffffffc02ac5f8 <pages>
ffffffffc020549a:	6308                	ld	a0,0(a4)
ffffffffc020549c:	8e9d                	sub	a3,a3,a5
ffffffffc020549e:	069a                	slli	a3,a3,0x6
ffffffffc02054a0:	9536                	add	a0,a0,a3
ffffffffc02054a2:	4589                	li	a1,2
ffffffffc02054a4:	a33fb0ef          	jal	ra,ffffffffc0200ed6 <free_pages>
    kfree(proc);
ffffffffc02054a8:	8522                	mv	a0,s0
ffffffffc02054aa:	feffd0ef          	jal	ra,ffffffffc0203498 <kfree>
    return 0;
ffffffffc02054ae:	4501                	li	a0,0
}
ffffffffc02054b0:	70e2                	ld	ra,56(sp)
ffffffffc02054b2:	7442                	ld	s0,48(sp)
ffffffffc02054b4:	74a2                	ld	s1,40(sp)
ffffffffc02054b6:	7902                	ld	s2,32(sp)
ffffffffc02054b8:	69e2                	ld	s3,24(sp)
ffffffffc02054ba:	6a42                	ld	s4,16(sp)
ffffffffc02054bc:	6aa2                	ld	s5,8(sp)
ffffffffc02054be:	6b02                	ld	s6,0(sp)
ffffffffc02054c0:	6121                	addi	sp,sp,64
ffffffffc02054c2:	8082                	ret
        intr_enable();
ffffffffc02054c4:	96efb0ef          	jal	ra,ffffffffc0200632 <intr_enable>
ffffffffc02054c8:	bf69                	j	ffffffffc0205462 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc02054ca:	701c                	ld	a5,32(s0)
ffffffffc02054cc:	fbf8                	sd	a4,240(a5)
ffffffffc02054ce:	bfbd                	j	ffffffffc020544c <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02054d0:	5579                	li	a0,-2
ffffffffc02054d2:	bff9                	j	ffffffffc02054b0 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02054d4:	964fb0ef          	jal	ra,ffffffffc0200638 <intr_disable>
        return 1;
ffffffffc02054d8:	4585                	li	a1,1
ffffffffc02054da:	bf81                	j	ffffffffc020542a <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02054dc:	00003617          	auipc	a2,0x3
ffffffffc02054e0:	e7c60613          	addi	a2,a2,-388 # ffffffffc0208358 <default_pmm_manager+0x2b8>
ffffffffc02054e4:	2f900593          	li	a1,761
ffffffffc02054e8:	00003517          	auipc	a0,0x3
ffffffffc02054ec:	0b850513          	addi	a0,a0,184 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc02054f0:	d27fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02054f4:	00002617          	auipc	a2,0x2
ffffffffc02054f8:	92460613          	addi	a2,a2,-1756 # ffffffffc0206e18 <commands+0x8b8>
ffffffffc02054fc:	06200593          	li	a1,98
ffffffffc0205500:	00002517          	auipc	a0,0x2
ffffffffc0205504:	93850513          	addi	a0,a0,-1736 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0205508:	d0ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020550c:	00002617          	auipc	a2,0x2
ffffffffc0205510:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206eb8 <commands+0x958>
ffffffffc0205514:	06e00593          	li	a1,110
ffffffffc0205518:	00002517          	auipc	a0,0x2
ffffffffc020551c:	92050513          	addi	a0,a0,-1760 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0205520:	cf7fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205524 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205524:	1141                	addi	sp,sp,-16
ffffffffc0205526:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205528:	9f5fb0ef          	jal	ra,ffffffffc0200f1c <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020552c:	eadfd0ef          	jal	ra,ffffffffc02033d8 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205530:	4601                	li	a2,0
ffffffffc0205532:	4581                	li	a1,0
ffffffffc0205534:	fffff517          	auipc	a0,0xfffff
ffffffffc0205538:	65050513          	addi	a0,a0,1616 # ffffffffc0204b84 <user_main>
ffffffffc020553c:	ca3ff0ef          	jal	ra,ffffffffc02051de <kernel_thread>
    if (pid <= 0) {
ffffffffc0205540:	00a04563          	bgtz	a0,ffffffffc020554a <init_main+0x26>
ffffffffc0205544:	a841                	j	ffffffffc02055d4 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205546:	05b000ef          	jal	ra,ffffffffc0205da0 <schedule>
    if (code_store != NULL) {
ffffffffc020554a:	4581                	li	a1,0
ffffffffc020554c:	4501                	li	a0,0
ffffffffc020554e:	e2fff0ef          	jal	ra,ffffffffc020537c <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205552:	d975                	beqz	a0,ffffffffc0205546 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205554:	00003517          	auipc	a0,0x3
ffffffffc0205558:	e4450513          	addi	a0,a0,-444 # ffffffffc0208398 <default_pmm_manager+0x2f8>
ffffffffc020555c:	b75fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205560:	000a7797          	auipc	a5,0xa7
ffffffffc0205564:	06878793          	addi	a5,a5,104 # ffffffffc02ac5c8 <initproc>
ffffffffc0205568:	639c                	ld	a5,0(a5)
ffffffffc020556a:	7bf8                	ld	a4,240(a5)
ffffffffc020556c:	e721                	bnez	a4,ffffffffc02055b4 <init_main+0x90>
ffffffffc020556e:	7ff8                	ld	a4,248(a5)
ffffffffc0205570:	e331                	bnez	a4,ffffffffc02055b4 <init_main+0x90>
ffffffffc0205572:	1007b703          	ld	a4,256(a5)
ffffffffc0205576:	ef1d                	bnez	a4,ffffffffc02055b4 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205578:	000a7717          	auipc	a4,0xa7
ffffffffc020557c:	05870713          	addi	a4,a4,88 # ffffffffc02ac5d0 <nr_process>
ffffffffc0205580:	4314                	lw	a3,0(a4)
ffffffffc0205582:	4709                	li	a4,2
ffffffffc0205584:	0ae69463          	bne	a3,a4,ffffffffc020562c <init_main+0x108>
    return listelm->next;
ffffffffc0205588:	000a7697          	auipc	a3,0xa7
ffffffffc020558c:	17068693          	addi	a3,a3,368 # ffffffffc02ac6f8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205590:	6698                	ld	a4,8(a3)
ffffffffc0205592:	0c878793          	addi	a5,a5,200
ffffffffc0205596:	06f71b63          	bne	a4,a5,ffffffffc020560c <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020559a:	629c                	ld	a5,0(a3)
ffffffffc020559c:	04f71863          	bne	a4,a5,ffffffffc02055ec <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02055a0:	00003517          	auipc	a0,0x3
ffffffffc02055a4:	ee050513          	addi	a0,a0,-288 # ffffffffc0208480 <default_pmm_manager+0x3e0>
ffffffffc02055a8:	b29fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc02055ac:	60a2                	ld	ra,8(sp)
ffffffffc02055ae:	4501                	li	a0,0
ffffffffc02055b0:	0141                	addi	sp,sp,16
ffffffffc02055b2:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02055b4:	00003697          	auipc	a3,0x3
ffffffffc02055b8:	e0c68693          	addi	a3,a3,-500 # ffffffffc02083c0 <default_pmm_manager+0x320>
ffffffffc02055bc:	00001617          	auipc	a2,0x1
ffffffffc02055c0:	42460613          	addi	a2,a2,1060 # ffffffffc02069e0 <commands+0x480>
ffffffffc02055c4:	35e00593          	li	a1,862
ffffffffc02055c8:	00003517          	auipc	a0,0x3
ffffffffc02055cc:	fd850513          	addi	a0,a0,-40 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc02055d0:	c47fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create user_main failed.\n");
ffffffffc02055d4:	00003617          	auipc	a2,0x3
ffffffffc02055d8:	da460613          	addi	a2,a2,-604 # ffffffffc0208378 <default_pmm_manager+0x2d8>
ffffffffc02055dc:	35600593          	li	a1,854
ffffffffc02055e0:	00003517          	auipc	a0,0x3
ffffffffc02055e4:	fc050513          	addi	a0,a0,-64 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc02055e8:	c2ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02055ec:	00003697          	auipc	a3,0x3
ffffffffc02055f0:	e6468693          	addi	a3,a3,-412 # ffffffffc0208450 <default_pmm_manager+0x3b0>
ffffffffc02055f4:	00001617          	auipc	a2,0x1
ffffffffc02055f8:	3ec60613          	addi	a2,a2,1004 # ffffffffc02069e0 <commands+0x480>
ffffffffc02055fc:	36100593          	li	a1,865
ffffffffc0205600:	00003517          	auipc	a0,0x3
ffffffffc0205604:	fa050513          	addi	a0,a0,-96 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205608:	c0ffa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020560c:	00003697          	auipc	a3,0x3
ffffffffc0205610:	e1468693          	addi	a3,a3,-492 # ffffffffc0208420 <default_pmm_manager+0x380>
ffffffffc0205614:	00001617          	auipc	a2,0x1
ffffffffc0205618:	3cc60613          	addi	a2,a2,972 # ffffffffc02069e0 <commands+0x480>
ffffffffc020561c:	36000593          	li	a1,864
ffffffffc0205620:	00003517          	auipc	a0,0x3
ffffffffc0205624:	f8050513          	addi	a0,a0,-128 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205628:	beffa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(nr_process == 2);
ffffffffc020562c:	00003697          	auipc	a3,0x3
ffffffffc0205630:	de468693          	addi	a3,a3,-540 # ffffffffc0208410 <default_pmm_manager+0x370>
ffffffffc0205634:	00001617          	auipc	a2,0x1
ffffffffc0205638:	3ac60613          	addi	a2,a2,940 # ffffffffc02069e0 <commands+0x480>
ffffffffc020563c:	35f00593          	li	a1,863
ffffffffc0205640:	00003517          	auipc	a0,0x3
ffffffffc0205644:	f6050513          	addi	a0,a0,-160 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205648:	bcffa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc020564c <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020564c:	7135                	addi	sp,sp,-160
ffffffffc020564e:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205650:	000a7a17          	auipc	s4,0xa7
ffffffffc0205654:	f68a0a13          	addi	s4,s4,-152 # ffffffffc02ac5b8 <current>
ffffffffc0205658:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020565c:	e14a                	sd	s2,128(sp)
ffffffffc020565e:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205660:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205664:	fcce                	sd	s3,120(sp)
ffffffffc0205666:	842e                	mv	s0,a1
ffffffffc0205668:	89aa                	mv	s3,a0
ffffffffc020566a:	e832                	sd	a2,16(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020566c:	4681                	li	a3,0
ffffffffc020566e:	862e                	mv	a2,a1
ffffffffc0205670:	85aa                	mv	a1,a0
ffffffffc0205672:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205674:	ed06                	sd	ra,152(sp)
ffffffffc0205676:	e526                	sd	s1,136(sp)
ffffffffc0205678:	f4d6                	sd	s5,104(sp)
ffffffffc020567a:	f0da                	sd	s6,96(sp)
ffffffffc020567c:	ecde                	sd	s7,88(sp)
ffffffffc020567e:	e8e2                	sd	s8,80(sp)
ffffffffc0205680:	e4e6                	sd	s9,72(sp)
ffffffffc0205682:	e0ea                	sd	s10,64(sp)
ffffffffc0205684:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205686:	a11fd0ef          	jal	ra,ffffffffc0203096 <user_mem_check>
ffffffffc020568a:	3e050163          	beqz	a0,ffffffffc0205a6c <do_execve+0x420>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020568e:	4641                	li	a2,16
ffffffffc0205690:	4581                	li	a1,0
ffffffffc0205692:	1008                	addi	a0,sp,32
ffffffffc0205694:	121000ef          	jal	ra,ffffffffc0205fb4 <memset>
    memcpy(local_name, name, len);
ffffffffc0205698:	47bd                	li	a5,15
ffffffffc020569a:	8622                	mv	a2,s0
ffffffffc020569c:	0687ee63          	bltu	a5,s0,ffffffffc0205718 <do_execve+0xcc>
ffffffffc02056a0:	85ce                	mv	a1,s3
ffffffffc02056a2:	1008                	addi	a0,sp,32
ffffffffc02056a4:	123000ef          	jal	ra,ffffffffc0205fc6 <memcpy>
    if (mm != NULL) {
ffffffffc02056a8:	06090f63          	beqz	s2,ffffffffc0205726 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc02056ac:	00002517          	auipc	a0,0x2
ffffffffc02056b0:	0b450513          	addi	a0,a0,180 # ffffffffc0207760 <commands+0x1200>
ffffffffc02056b4:	a55fa0ef          	jal	ra,ffffffffc0200108 <cputs>
        lcr3(boot_cr3);
ffffffffc02056b8:	000a7797          	auipc	a5,0xa7
ffffffffc02056bc:	f3878793          	addi	a5,a5,-200 # ffffffffc02ac5f0 <boot_cr3>
ffffffffc02056c0:	639c                	ld	a5,0(a5)
ffffffffc02056c2:	577d                	li	a4,-1
ffffffffc02056c4:	177e                	slli	a4,a4,0x3f
ffffffffc02056c6:	83b1                	srli	a5,a5,0xc
ffffffffc02056c8:	8fd9                	or	a5,a5,a4
ffffffffc02056ca:	18079073          	csrw	satp,a5
ffffffffc02056ce:	03092783          	lw	a5,48(s2)
ffffffffc02056d2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02056d6:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc02056da:	26070a63          	beqz	a4,ffffffffc020594e <do_execve+0x302>
        current->mm = NULL;
ffffffffc02056de:	000a3783          	ld	a5,0(s4)
ffffffffc02056e2:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02056e6:	80cfd0ef          	jal	ra,ffffffffc02026f2 <mm_create>
ffffffffc02056ea:	892a                	mv	s2,a0
ffffffffc02056ec:	c135                	beqz	a0,ffffffffc0205750 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02056ee:	d96ff0ef          	jal	ra,ffffffffc0204c84 <setup_pgdir>
ffffffffc02056f2:	e931                	bnez	a0,ffffffffc0205746 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02056f4:	67c2                	ld	a5,16(sp)
ffffffffc02056f6:	4398                	lw	a4,0(a5)
ffffffffc02056f8:	464c47b7          	lui	a5,0x464c4
ffffffffc02056fc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aef>
ffffffffc0205700:	04f70a63          	beq	a4,a5,ffffffffc0205754 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205704:	854a                	mv	a0,s2
ffffffffc0205706:	d00ff0ef          	jal	ra,ffffffffc0204c06 <put_pgdir>
    mm_destroy(mm);
ffffffffc020570a:	854a                	mv	a0,s2
ffffffffc020570c:	96cfd0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205710:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205712:	854e                	mv	a0,s3
ffffffffc0205714:	b1bff0ef          	jal	ra,ffffffffc020522e <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205718:	463d                	li	a2,15
ffffffffc020571a:	85ce                	mv	a1,s3
ffffffffc020571c:	1008                	addi	a0,sp,32
ffffffffc020571e:	0a9000ef          	jal	ra,ffffffffc0205fc6 <memcpy>
    if (mm != NULL) {
ffffffffc0205722:	f80915e3          	bnez	s2,ffffffffc02056ac <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205726:	000a3783          	ld	a5,0(s4)
ffffffffc020572a:	779c                	ld	a5,40(a5)
ffffffffc020572c:	dfcd                	beqz	a5,ffffffffc02056e6 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020572e:	00003617          	auipc	a2,0x3
ffffffffc0205732:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0208148 <default_pmm_manager+0xa8>
ffffffffc0205736:	20e00593          	li	a1,526
ffffffffc020573a:	00003517          	auipc	a0,0x3
ffffffffc020573e:	e6650513          	addi	a0,a0,-410 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205742:	ad5fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    mm_destroy(mm);
ffffffffc0205746:	854a                	mv	a0,s2
ffffffffc0205748:	930fd0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc020574c:	59f1                	li	s3,-4
ffffffffc020574e:	b7d1                	j	ffffffffc0205712 <do_execve+0xc6>
ffffffffc0205750:	59f1                	li	s3,-4
ffffffffc0205752:	b7c1                	j	ffffffffc0205712 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205754:	66c2                	ld	a3,16(sp)
ffffffffc0205756:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020575a:	7280                	ld	s0,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020575c:	00371793          	slli	a5,a4,0x3
ffffffffc0205760:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205762:	9436                	add	s0,s0,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205764:	078e                	slli	a5,a5,0x3
ffffffffc0205766:	97a2                	add	a5,a5,s0
ffffffffc0205768:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020576a:	02f47b63          	bleu	a5,s0,ffffffffc02057a0 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc020576e:	5b7d                	li	s6,-1
ffffffffc0205770:	00cb5793          	srli	a5,s6,0xc
    return page - pages + nbase;
ffffffffc0205774:	000a7d97          	auipc	s11,0xa7
ffffffffc0205778:	e84d8d93          	addi	s11,s11,-380 # ffffffffc02ac5f8 <pages>
ffffffffc020577c:	00003d17          	auipc	s10,0x3
ffffffffc0205780:	2ecd0d13          	addi	s10,s10,748 # ffffffffc0208a68 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205784:	e03e                	sd	a5,0(sp)
ffffffffc0205786:	000a7c97          	auipc	s9,0xa7
ffffffffc020578a:	e0ac8c93          	addi	s9,s9,-502 # ffffffffc02ac590 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc020578e:	4018                	lw	a4,0(s0)
ffffffffc0205790:	4785                	li	a5,1
ffffffffc0205792:	0cf70f63          	beq	a4,a5,ffffffffc0205870 <do_execve+0x224>
    for (; ph < ph_end; ph ++) {
ffffffffc0205796:	67e2                	ld	a5,24(sp)
ffffffffc0205798:	03840413          	addi	s0,s0,56
ffffffffc020579c:	fef469e3          	bltu	s0,a5,ffffffffc020578e <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02057a0:	4701                	li	a4,0
ffffffffc02057a2:	46ad                	li	a3,11
ffffffffc02057a4:	00100637          	lui	a2,0x100
ffffffffc02057a8:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02057ac:	854a                	mv	a0,s2
ffffffffc02057ae:	91cfd0ef          	jal	ra,ffffffffc02028ca <mm_map>
ffffffffc02057b2:	89aa                	mv	s3,a0
ffffffffc02057b4:	18051363          	bnez	a0,ffffffffc020593a <do_execve+0x2ee>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02057b8:	01893503          	ld	a0,24(s2)
ffffffffc02057bc:	467d                	li	a2,31
ffffffffc02057be:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02057c2:	a91fc0ef          	jal	ra,ffffffffc0202252 <pgdir_alloc_page>
ffffffffc02057c6:	32050f63          	beqz	a0,ffffffffc0205b04 <do_execve+0x4b8>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02057ca:	01893503          	ld	a0,24(s2)
ffffffffc02057ce:	467d                	li	a2,31
ffffffffc02057d0:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02057d4:	a7ffc0ef          	jal	ra,ffffffffc0202252 <pgdir_alloc_page>
ffffffffc02057d8:	30050663          	beqz	a0,ffffffffc0205ae4 <do_execve+0x498>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02057dc:	01893503          	ld	a0,24(s2)
ffffffffc02057e0:	467d                	li	a2,31
ffffffffc02057e2:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02057e6:	a6dfc0ef          	jal	ra,ffffffffc0202252 <pgdir_alloc_page>
ffffffffc02057ea:	2c050d63          	beqz	a0,ffffffffc0205ac4 <do_execve+0x478>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02057ee:	01893503          	ld	a0,24(s2)
ffffffffc02057f2:	467d                	li	a2,31
ffffffffc02057f4:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02057f8:	a5bfc0ef          	jal	ra,ffffffffc0202252 <pgdir_alloc_page>
ffffffffc02057fc:	2a050463          	beqz	a0,ffffffffc0205aa4 <do_execve+0x458>
    mm->mm_count += 1;
ffffffffc0205800:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205804:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205808:	01893683          	ld	a3,24(s2)
ffffffffc020580c:	2785                	addiw	a5,a5,1
ffffffffc020580e:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205812:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5598>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205816:	c02007b7          	lui	a5,0xc0200
ffffffffc020581a:	26f6e963          	bltu	a3,a5,ffffffffc0205a8c <do_execve+0x440>
ffffffffc020581e:	000a7797          	auipc	a5,0xa7
ffffffffc0205822:	dca78793          	addi	a5,a5,-566 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc0205826:	639c                	ld	a5,0(a5)
ffffffffc0205828:	577d                	li	a4,-1
ffffffffc020582a:	177e                	slli	a4,a4,0x3f
ffffffffc020582c:	8e9d                	sub	a3,a3,a5
ffffffffc020582e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205832:	f654                	sd	a3,168(a2)
ffffffffc0205834:	8fd9                	or	a5,a5,a4
ffffffffc0205836:	18079073          	csrw	satp,a5
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020583a:	7248                	ld	a0,160(a2)
ffffffffc020583c:	4581                	li	a1,0
ffffffffc020583e:	12000613          	li	a2,288
ffffffffc0205842:	772000ef          	jal	ra,ffffffffc0205fb4 <memset>
    set_proc_name(current, local_name);
ffffffffc0205846:	000a3503          	ld	a0,0(s4)
ffffffffc020584a:	100c                	addi	a1,sp,32
ffffffffc020584c:	cc4ff0ef          	jal	ra,ffffffffc0204d10 <set_proc_name>
}
ffffffffc0205850:	60ea                	ld	ra,152(sp)
ffffffffc0205852:	644a                	ld	s0,144(sp)
ffffffffc0205854:	854e                	mv	a0,s3
ffffffffc0205856:	64aa                	ld	s1,136(sp)
ffffffffc0205858:	690a                	ld	s2,128(sp)
ffffffffc020585a:	79e6                	ld	s3,120(sp)
ffffffffc020585c:	7a46                	ld	s4,112(sp)
ffffffffc020585e:	7aa6                	ld	s5,104(sp)
ffffffffc0205860:	7b06                	ld	s6,96(sp)
ffffffffc0205862:	6be6                	ld	s7,88(sp)
ffffffffc0205864:	6c46                	ld	s8,80(sp)
ffffffffc0205866:	6ca6                	ld	s9,72(sp)
ffffffffc0205868:	6d06                	ld	s10,64(sp)
ffffffffc020586a:	7de2                	ld	s11,56(sp)
ffffffffc020586c:	610d                	addi	sp,sp,160
ffffffffc020586e:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205870:	7410                	ld	a2,40(s0)
ffffffffc0205872:	701c                	ld	a5,32(s0)
ffffffffc0205874:	1ef66e63          	bltu	a2,a5,ffffffffc0205a70 <do_execve+0x424>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205878:	405c                	lw	a5,4(s0)
ffffffffc020587a:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020587e:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205882:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205884:	0c071f63          	bnez	a4,ffffffffc0205962 <do_execve+0x316>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205888:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc020588a:	4bc5                	li	s7,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020588c:	c781                	beqz	a5,ffffffffc0205894 <do_execve+0x248>
ffffffffc020588e:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205892:	4bcd                	li	s7,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205894:	0026f793          	andi	a5,a3,2
ffffffffc0205898:	ebf1                	bnez	a5,ffffffffc020596c <do_execve+0x320>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc020589a:	0046f793          	andi	a5,a3,4
ffffffffc020589e:	c399                	beqz	a5,ffffffffc02058a4 <do_execve+0x258>
ffffffffc02058a0:	008beb93          	ori	s7,s7,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc02058a4:	680c                	ld	a1,16(s0)
ffffffffc02058a6:	4701                	li	a4,0
ffffffffc02058a8:	854a                	mv	a0,s2
ffffffffc02058aa:	820fd0ef          	jal	ra,ffffffffc02028ca <mm_map>
ffffffffc02058ae:	89aa                	mv	s3,a0
ffffffffc02058b0:	e549                	bnez	a0,ffffffffc020593a <do_execve+0x2ee>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02058b2:	01043b03          	ld	s6,16(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02058b6:	67c2                	ld	a5,16(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc02058b8:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02058bc:	00843a83          	ld	s5,8(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc02058c0:	99da                	add	s3,s3,s6
        unsigned char *from = binary + ph->p_offset;
ffffffffc02058c2:	9abe                	add	s5,s5,a5
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02058c4:	77fd                	lui	a5,0xfffff
ffffffffc02058c6:	00fb7c33          	and	s8,s6,a5
        while (start < end) {
ffffffffc02058ca:	053b6f63          	bltu	s6,s3,ffffffffc0205928 <do_execve+0x2dc>
ffffffffc02058ce:	aa69                	j	ffffffffc0205a68 <do_execve+0x41c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02058d0:	6785                	lui	a5,0x1
ffffffffc02058d2:	418b0533          	sub	a0,s6,s8
ffffffffc02058d6:	9c3e                	add	s8,s8,a5
ffffffffc02058d8:	416c0833          	sub	a6,s8,s6
            if (end < la) {
ffffffffc02058dc:	0189f463          	bleu	s8,s3,ffffffffc02058e4 <do_execve+0x298>
                size -= la - end;
ffffffffc02058e0:	41698833          	sub	a6,s3,s6
    return page - pages + nbase;
ffffffffc02058e4:	000db683          	ld	a3,0(s11)
ffffffffc02058e8:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc02058ec:	6782                	ld	a5,0(sp)
    return page - pages + nbase;
ffffffffc02058ee:	40d486b3          	sub	a3,s1,a3
ffffffffc02058f2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02058f4:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02058f8:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02058fa:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02058fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205900:	16c5fa63          	bleu	a2,a1,ffffffffc0205a74 <do_execve+0x428>
ffffffffc0205904:	000a7797          	auipc	a5,0xa7
ffffffffc0205908:	ce478793          	addi	a5,a5,-796 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc020590c:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205910:	85d6                	mv	a1,s5
ffffffffc0205912:	8642                	mv	a2,a6
ffffffffc0205914:	96c6                	add	a3,a3,a7
ffffffffc0205916:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205918:	9b42                	add	s6,s6,a6
ffffffffc020591a:	e442                	sd	a6,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc020591c:	6aa000ef          	jal	ra,ffffffffc0205fc6 <memcpy>
            start += size, from += size;
ffffffffc0205920:	6822                	ld	a6,8(sp)
ffffffffc0205922:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205924:	053b7663          	bleu	s3,s6,ffffffffc0205970 <do_execve+0x324>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205928:	01893503          	ld	a0,24(s2)
ffffffffc020592c:	865e                	mv	a2,s7
ffffffffc020592e:	85e2                	mv	a1,s8
ffffffffc0205930:	923fc0ef          	jal	ra,ffffffffc0202252 <pgdir_alloc_page>
ffffffffc0205934:	84aa                	mv	s1,a0
ffffffffc0205936:	fd49                	bnez	a0,ffffffffc02058d0 <do_execve+0x284>
        ret = -E_NO_MEM;
ffffffffc0205938:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc020593a:	854a                	mv	a0,s2
ffffffffc020593c:	8dcfd0ef          	jal	ra,ffffffffc0202a18 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205940:	854a                	mv	a0,s2
ffffffffc0205942:	ac4ff0ef          	jal	ra,ffffffffc0204c06 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205946:	854a                	mv	a0,s2
ffffffffc0205948:	f31fc0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
    return ret;
ffffffffc020594c:	b3d9                	j	ffffffffc0205712 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc020594e:	854a                	mv	a0,s2
ffffffffc0205950:	8c8fd0ef          	jal	ra,ffffffffc0202a18 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205954:	854a                	mv	a0,s2
ffffffffc0205956:	ab0ff0ef          	jal	ra,ffffffffc0204c06 <put_pgdir>
            mm_destroy(mm);
ffffffffc020595a:	854a                	mv	a0,s2
ffffffffc020595c:	f1dfc0ef          	jal	ra,ffffffffc0202878 <mm_destroy>
ffffffffc0205960:	bbbd                	j	ffffffffc02056de <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205962:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205966:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205968:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020596a:	f395                	bnez	a5,ffffffffc020588e <do_execve+0x242>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc020596c:	4bdd                	li	s7,23
ffffffffc020596e:	b735                	j	ffffffffc020589a <do_execve+0x24e>
ffffffffc0205970:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205974:	7414                	ld	a3,40(s0)
ffffffffc0205976:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205978:	098b7163          	bleu	s8,s6,ffffffffc02059fa <do_execve+0x3ae>
            if (start == end) {
ffffffffc020597c:	e1698de3          	beq	s3,s6,ffffffffc0205796 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205980:	6505                	lui	a0,0x1
ffffffffc0205982:	955a                	add	a0,a0,s6
ffffffffc0205984:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205988:	41698ab3          	sub	s5,s3,s6
            if (end < la) {
ffffffffc020598c:	0d89fb63          	bleu	s8,s3,ffffffffc0205a62 <do_execve+0x416>
    return page - pages + nbase;
ffffffffc0205990:	000db683          	ld	a3,0(s11)
ffffffffc0205994:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205998:	6782                	ld	a5,0(sp)
    return page - pages + nbase;
ffffffffc020599a:	40d486b3          	sub	a3,s1,a3
ffffffffc020599e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02059a0:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02059a4:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02059a6:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02059aa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02059ac:	0cc5f463          	bleu	a2,a1,ffffffffc0205a74 <do_execve+0x428>
ffffffffc02059b0:	000a7617          	auipc	a2,0xa7
ffffffffc02059b4:	c3860613          	addi	a2,a2,-968 # ffffffffc02ac5e8 <va_pa_offset>
ffffffffc02059b8:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc02059bc:	4581                	li	a1,0
ffffffffc02059be:	8656                	mv	a2,s5
ffffffffc02059c0:	96c2                	add	a3,a3,a6
ffffffffc02059c2:	9536                	add	a0,a0,a3
ffffffffc02059c4:	5f0000ef          	jal	ra,ffffffffc0205fb4 <memset>
            start += size;
ffffffffc02059c8:	016a8733          	add	a4,s5,s6
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc02059cc:	0389f463          	bleu	s8,s3,ffffffffc02059f4 <do_execve+0x3a8>
ffffffffc02059d0:	dce983e3          	beq	s3,a4,ffffffffc0205796 <do_execve+0x14a>
ffffffffc02059d4:	00002697          	auipc	a3,0x2
ffffffffc02059d8:	79c68693          	addi	a3,a3,1948 # ffffffffc0208170 <default_pmm_manager+0xd0>
ffffffffc02059dc:	00001617          	auipc	a2,0x1
ffffffffc02059e0:	00460613          	addi	a2,a2,4 # ffffffffc02069e0 <commands+0x480>
ffffffffc02059e4:	26300593          	li	a1,611
ffffffffc02059e8:	00003517          	auipc	a0,0x3
ffffffffc02059ec:	bb850513          	addi	a0,a0,-1096 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc02059f0:	827fa0ef          	jal	ra,ffffffffc0200216 <__panic>
ffffffffc02059f4:	ff8710e3          	bne	a4,s8,ffffffffc02059d4 <do_execve+0x388>
ffffffffc02059f8:	8b62                	mv	s6,s8
ffffffffc02059fa:	000a7a97          	auipc	s5,0xa7
ffffffffc02059fe:	beea8a93          	addi	s5,s5,-1042 # ffffffffc02ac5e8 <va_pa_offset>
        while (start < end) {
ffffffffc0205a02:	053b6763          	bltu	s6,s3,ffffffffc0205a50 <do_execve+0x404>
ffffffffc0205a06:	bb41                	j	ffffffffc0205796 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a08:	6785                	lui	a5,0x1
ffffffffc0205a0a:	418b0533          	sub	a0,s6,s8
ffffffffc0205a0e:	9c3e                	add	s8,s8,a5
ffffffffc0205a10:	416c0633          	sub	a2,s8,s6
            if (end < la) {
ffffffffc0205a14:	0189f463          	bleu	s8,s3,ffffffffc0205a1c <do_execve+0x3d0>
                size -= la - end;
ffffffffc0205a18:	41698633          	sub	a2,s3,s6
    return page - pages + nbase;
ffffffffc0205a1c:	000db683          	ld	a3,0(s11)
ffffffffc0205a20:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205a24:	6782                	ld	a5,0(sp)
    return page - pages + nbase;
ffffffffc0205a26:	40d486b3          	sub	a3,s1,a3
ffffffffc0205a2a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205a2c:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205a30:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205a32:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a36:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a38:	02b87e63          	bleu	a1,a6,ffffffffc0205a74 <do_execve+0x428>
ffffffffc0205a3c:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205a40:	9b32                	add	s6,s6,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205a42:	4581                	li	a1,0
ffffffffc0205a44:	96c2                	add	a3,a3,a6
ffffffffc0205a46:	9536                	add	a0,a0,a3
ffffffffc0205a48:	56c000ef          	jal	ra,ffffffffc0205fb4 <memset>
        while (start < end) {
ffffffffc0205a4c:	d53b75e3          	bleu	s3,s6,ffffffffc0205796 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a50:	01893503          	ld	a0,24(s2)
ffffffffc0205a54:	865e                	mv	a2,s7
ffffffffc0205a56:	85e2                	mv	a1,s8
ffffffffc0205a58:	ffafc0ef          	jal	ra,ffffffffc0202252 <pgdir_alloc_page>
ffffffffc0205a5c:	84aa                	mv	s1,a0
ffffffffc0205a5e:	f54d                	bnez	a0,ffffffffc0205a08 <do_execve+0x3bc>
ffffffffc0205a60:	bde1                	j	ffffffffc0205938 <do_execve+0x2ec>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205a62:	416c0ab3          	sub	s5,s8,s6
ffffffffc0205a66:	b72d                	j	ffffffffc0205990 <do_execve+0x344>
        while (start < end) {
ffffffffc0205a68:	89da                	mv	s3,s6
ffffffffc0205a6a:	b729                	j	ffffffffc0205974 <do_execve+0x328>
        return -E_INVAL;
ffffffffc0205a6c:	59f5                	li	s3,-3
ffffffffc0205a6e:	b3cd                	j	ffffffffc0205850 <do_execve+0x204>
            ret = -E_INVAL_ELF;
ffffffffc0205a70:	59e1                	li	s3,-8
ffffffffc0205a72:	b5e1                	j	ffffffffc020593a <do_execve+0x2ee>
ffffffffc0205a74:	00001617          	auipc	a2,0x1
ffffffffc0205a78:	36c60613          	addi	a2,a2,876 # ffffffffc0206de0 <commands+0x880>
ffffffffc0205a7c:	06900593          	li	a1,105
ffffffffc0205a80:	00001517          	auipc	a0,0x1
ffffffffc0205a84:	3b850513          	addi	a0,a0,952 # ffffffffc0206e38 <commands+0x8d8>
ffffffffc0205a88:	f8efa0ef          	jal	ra,ffffffffc0200216 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205a8c:	00001617          	auipc	a2,0x1
ffffffffc0205a90:	42c60613          	addi	a2,a2,1068 # ffffffffc0206eb8 <commands+0x958>
ffffffffc0205a94:	27e00593          	li	a1,638
ffffffffc0205a98:	00003517          	auipc	a0,0x3
ffffffffc0205a9c:	b0850513          	addi	a0,a0,-1272 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205aa0:	f76fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205aa4:	00002697          	auipc	a3,0x2
ffffffffc0205aa8:	7e468693          	addi	a3,a3,2020 # ffffffffc0208288 <default_pmm_manager+0x1e8>
ffffffffc0205aac:	00001617          	auipc	a2,0x1
ffffffffc0205ab0:	f3460613          	addi	a2,a2,-204 # ffffffffc02069e0 <commands+0x480>
ffffffffc0205ab4:	27900593          	li	a1,633
ffffffffc0205ab8:	00003517          	auipc	a0,0x3
ffffffffc0205abc:	ae850513          	addi	a0,a0,-1304 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205ac0:	f56fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ac4:	00002697          	auipc	a3,0x2
ffffffffc0205ac8:	77c68693          	addi	a3,a3,1916 # ffffffffc0208240 <default_pmm_manager+0x1a0>
ffffffffc0205acc:	00001617          	auipc	a2,0x1
ffffffffc0205ad0:	f1460613          	addi	a2,a2,-236 # ffffffffc02069e0 <commands+0x480>
ffffffffc0205ad4:	27800593          	li	a1,632
ffffffffc0205ad8:	00003517          	auipc	a0,0x3
ffffffffc0205adc:	ac850513          	addi	a0,a0,-1336 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205ae0:	f36fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ae4:	00002697          	auipc	a3,0x2
ffffffffc0205ae8:	71468693          	addi	a3,a3,1812 # ffffffffc02081f8 <default_pmm_manager+0x158>
ffffffffc0205aec:	00001617          	auipc	a2,0x1
ffffffffc0205af0:	ef460613          	addi	a2,a2,-268 # ffffffffc02069e0 <commands+0x480>
ffffffffc0205af4:	27700593          	li	a1,631
ffffffffc0205af8:	00003517          	auipc	a0,0x3
ffffffffc0205afc:	aa850513          	addi	a0,a0,-1368 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205b00:	f16fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205b04:	00002697          	auipc	a3,0x2
ffffffffc0205b08:	6ac68693          	addi	a3,a3,1708 # ffffffffc02081b0 <default_pmm_manager+0x110>
ffffffffc0205b0c:	00001617          	auipc	a2,0x1
ffffffffc0205b10:	ed460613          	addi	a2,a2,-300 # ffffffffc02069e0 <commands+0x480>
ffffffffc0205b14:	27600593          	li	a1,630
ffffffffc0205b18:	00003517          	auipc	a0,0x3
ffffffffc0205b1c:	a8850513          	addi	a0,a0,-1400 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205b20:	ef6fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205b24 <do_yield>:
    current->need_resched = 1;
ffffffffc0205b24:	000a7797          	auipc	a5,0xa7
ffffffffc0205b28:	a9478793          	addi	a5,a5,-1388 # ffffffffc02ac5b8 <current>
ffffffffc0205b2c:	639c                	ld	a5,0(a5)
ffffffffc0205b2e:	4705                	li	a4,1
}
ffffffffc0205b30:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205b32:	ef98                	sd	a4,24(a5)
}
ffffffffc0205b34:	8082                	ret

ffffffffc0205b36 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205b36:	1101                	addi	sp,sp,-32
ffffffffc0205b38:	e822                	sd	s0,16(sp)
ffffffffc0205b3a:	e426                	sd	s1,8(sp)
ffffffffc0205b3c:	ec06                	sd	ra,24(sp)
ffffffffc0205b3e:	842e                	mv	s0,a1
ffffffffc0205b40:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205b42:	cd81                	beqz	a1,ffffffffc0205b5a <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205b44:	000a7797          	auipc	a5,0xa7
ffffffffc0205b48:	a7478793          	addi	a5,a5,-1420 # ffffffffc02ac5b8 <current>
ffffffffc0205b4c:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205b4e:	4685                	li	a3,1
ffffffffc0205b50:	4611                	li	a2,4
ffffffffc0205b52:	7788                	ld	a0,40(a5)
ffffffffc0205b54:	d42fd0ef          	jal	ra,ffffffffc0203096 <user_mem_check>
ffffffffc0205b58:	c909                	beqz	a0,ffffffffc0205b6a <do_wait+0x34>
ffffffffc0205b5a:	85a2                	mv	a1,s0
}
ffffffffc0205b5c:	6442                	ld	s0,16(sp)
ffffffffc0205b5e:	60e2                	ld	ra,24(sp)
ffffffffc0205b60:	8526                	mv	a0,s1
ffffffffc0205b62:	64a2                	ld	s1,8(sp)
ffffffffc0205b64:	6105                	addi	sp,sp,32
ffffffffc0205b66:	817ff06f          	j	ffffffffc020537c <do_wait.part.1>
ffffffffc0205b6a:	60e2                	ld	ra,24(sp)
ffffffffc0205b6c:	6442                	ld	s0,16(sp)
ffffffffc0205b6e:	64a2                	ld	s1,8(sp)
ffffffffc0205b70:	5575                	li	a0,-3
ffffffffc0205b72:	6105                	addi	sp,sp,32
ffffffffc0205b74:	8082                	ret

ffffffffc0205b76 <do_kill>:
do_kill(int pid) {
ffffffffc0205b76:	1141                	addi	sp,sp,-16
ffffffffc0205b78:	e406                	sd	ra,8(sp)
ffffffffc0205b7a:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205b7c:	a2aff0ef          	jal	ra,ffffffffc0204da6 <find_proc>
ffffffffc0205b80:	cd0d                	beqz	a0,ffffffffc0205bba <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205b82:	0b052703          	lw	a4,176(a0)
ffffffffc0205b86:	00177693          	andi	a3,a4,1
ffffffffc0205b8a:	e695                	bnez	a3,ffffffffc0205bb6 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205b8c:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205b90:	00176713          	ori	a4,a4,1
ffffffffc0205b94:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205b98:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205b9a:	0006c763          	bltz	a3,ffffffffc0205ba8 <do_kill+0x32>
}
ffffffffc0205b9e:	8522                	mv	a0,s0
ffffffffc0205ba0:	60a2                	ld	ra,8(sp)
ffffffffc0205ba2:	6402                	ld	s0,0(sp)
ffffffffc0205ba4:	0141                	addi	sp,sp,16
ffffffffc0205ba6:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205ba8:	17c000ef          	jal	ra,ffffffffc0205d24 <wakeup_proc>
}
ffffffffc0205bac:	8522                	mv	a0,s0
ffffffffc0205bae:	60a2                	ld	ra,8(sp)
ffffffffc0205bb0:	6402                	ld	s0,0(sp)
ffffffffc0205bb2:	0141                	addi	sp,sp,16
ffffffffc0205bb4:	8082                	ret
        return -E_KILLED;
ffffffffc0205bb6:	545d                	li	s0,-9
ffffffffc0205bb8:	b7dd                	j	ffffffffc0205b9e <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205bba:	5475                	li	s0,-3
ffffffffc0205bbc:	b7cd                	j	ffffffffc0205b9e <do_kill+0x28>

ffffffffc0205bbe <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205bbe:	000a7797          	auipc	a5,0xa7
ffffffffc0205bc2:	b3a78793          	addi	a5,a5,-1222 # ffffffffc02ac6f8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205bc6:	1101                	addi	sp,sp,-32
ffffffffc0205bc8:	000a7717          	auipc	a4,0xa7
ffffffffc0205bcc:	b2f73c23          	sd	a5,-1224(a4) # ffffffffc02ac700 <proc_list+0x8>
ffffffffc0205bd0:	000a7717          	auipc	a4,0xa7
ffffffffc0205bd4:	b2f73423          	sd	a5,-1240(a4) # ffffffffc02ac6f8 <proc_list>
ffffffffc0205bd8:	ec06                	sd	ra,24(sp)
ffffffffc0205bda:	e822                	sd	s0,16(sp)
ffffffffc0205bdc:	e426                	sd	s1,8(sp)
ffffffffc0205bde:	000a3797          	auipc	a5,0xa3
ffffffffc0205be2:	99a78793          	addi	a5,a5,-1638 # ffffffffc02a8578 <hash_list>
ffffffffc0205be6:	000a7717          	auipc	a4,0xa7
ffffffffc0205bea:	99270713          	addi	a4,a4,-1646 # ffffffffc02ac578 <is_panic>
ffffffffc0205bee:	e79c                	sd	a5,8(a5)
ffffffffc0205bf0:	e39c                	sd	a5,0(a5)
ffffffffc0205bf2:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205bf4:	fee79de3          	bne	a5,a4,ffffffffc0205bee <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205bf8:	f09fe0ef          	jal	ra,ffffffffc0204b00 <alloc_proc>
ffffffffc0205bfc:	000a7717          	auipc	a4,0xa7
ffffffffc0205c00:	9ca73223          	sd	a0,-1596(a4) # ffffffffc02ac5c0 <idleproc>
ffffffffc0205c04:	000a7497          	auipc	s1,0xa7
ffffffffc0205c08:	9bc48493          	addi	s1,s1,-1604 # ffffffffc02ac5c0 <idleproc>
ffffffffc0205c0c:	c559                	beqz	a0,ffffffffc0205c9a <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205c0e:	4709                	li	a4,2
ffffffffc0205c10:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205c12:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205c14:	00003717          	auipc	a4,0x3
ffffffffc0205c18:	3ec70713          	addi	a4,a4,1004 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205c1c:	00003597          	auipc	a1,0x3
ffffffffc0205c20:	89c58593          	addi	a1,a1,-1892 # ffffffffc02084b8 <default_pmm_manager+0x418>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205c24:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205c26:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205c28:	8e8ff0ef          	jal	ra,ffffffffc0204d10 <set_proc_name>
    nr_process ++;
ffffffffc0205c2c:	000a7797          	auipc	a5,0xa7
ffffffffc0205c30:	9a478793          	addi	a5,a5,-1628 # ffffffffc02ac5d0 <nr_process>
ffffffffc0205c34:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205c36:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205c38:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205c3a:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205c3c:	4581                	li	a1,0
ffffffffc0205c3e:	00000517          	auipc	a0,0x0
ffffffffc0205c42:	8e650513          	addi	a0,a0,-1818 # ffffffffc0205524 <init_main>
    nr_process ++;
ffffffffc0205c46:	000a7697          	auipc	a3,0xa7
ffffffffc0205c4a:	98f6a523          	sw	a5,-1654(a3) # ffffffffc02ac5d0 <nr_process>
    current = idleproc;
ffffffffc0205c4e:	000a7797          	auipc	a5,0xa7
ffffffffc0205c52:	96e7b523          	sd	a4,-1686(a5) # ffffffffc02ac5b8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205c56:	d88ff0ef          	jal	ra,ffffffffc02051de <kernel_thread>
    if (pid <= 0) {
ffffffffc0205c5a:	08a05c63          	blez	a0,ffffffffc0205cf2 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205c5e:	948ff0ef          	jal	ra,ffffffffc0204da6 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205c62:	00003597          	auipc	a1,0x3
ffffffffc0205c66:	87e58593          	addi	a1,a1,-1922 # ffffffffc02084e0 <default_pmm_manager+0x440>
    initproc = find_proc(pid);
ffffffffc0205c6a:	000a7797          	auipc	a5,0xa7
ffffffffc0205c6e:	94a7bf23          	sd	a0,-1698(a5) # ffffffffc02ac5c8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205c72:	89eff0ef          	jal	ra,ffffffffc0204d10 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205c76:	609c                	ld	a5,0(s1)
ffffffffc0205c78:	cfa9                	beqz	a5,ffffffffc0205cd2 <proc_init+0x114>
ffffffffc0205c7a:	43dc                	lw	a5,4(a5)
ffffffffc0205c7c:	ebb9                	bnez	a5,ffffffffc0205cd2 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205c7e:	000a7797          	auipc	a5,0xa7
ffffffffc0205c82:	94a78793          	addi	a5,a5,-1718 # ffffffffc02ac5c8 <initproc>
ffffffffc0205c86:	639c                	ld	a5,0(a5)
ffffffffc0205c88:	c78d                	beqz	a5,ffffffffc0205cb2 <proc_init+0xf4>
ffffffffc0205c8a:	43dc                	lw	a5,4(a5)
ffffffffc0205c8c:	02879363          	bne	a5,s0,ffffffffc0205cb2 <proc_init+0xf4>
}
ffffffffc0205c90:	60e2                	ld	ra,24(sp)
ffffffffc0205c92:	6442                	ld	s0,16(sp)
ffffffffc0205c94:	64a2                	ld	s1,8(sp)
ffffffffc0205c96:	6105                	addi	sp,sp,32
ffffffffc0205c98:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205c9a:	00003617          	auipc	a2,0x3
ffffffffc0205c9e:	80660613          	addi	a2,a2,-2042 # ffffffffc02084a0 <default_pmm_manager+0x400>
ffffffffc0205ca2:	37300593          	li	a1,883
ffffffffc0205ca6:	00003517          	auipc	a0,0x3
ffffffffc0205caa:	8fa50513          	addi	a0,a0,-1798 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205cae:	d68fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205cb2:	00003697          	auipc	a3,0x3
ffffffffc0205cb6:	85e68693          	addi	a3,a3,-1954 # ffffffffc0208510 <default_pmm_manager+0x470>
ffffffffc0205cba:	00001617          	auipc	a2,0x1
ffffffffc0205cbe:	d2660613          	addi	a2,a2,-730 # ffffffffc02069e0 <commands+0x480>
ffffffffc0205cc2:	38800593          	li	a1,904
ffffffffc0205cc6:	00003517          	auipc	a0,0x3
ffffffffc0205cca:	8da50513          	addi	a0,a0,-1830 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205cce:	d48fa0ef          	jal	ra,ffffffffc0200216 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205cd2:	00003697          	auipc	a3,0x3
ffffffffc0205cd6:	81668693          	addi	a3,a3,-2026 # ffffffffc02084e8 <default_pmm_manager+0x448>
ffffffffc0205cda:	00001617          	auipc	a2,0x1
ffffffffc0205cde:	d0660613          	addi	a2,a2,-762 # ffffffffc02069e0 <commands+0x480>
ffffffffc0205ce2:	38700593          	li	a1,903
ffffffffc0205ce6:	00003517          	auipc	a0,0x3
ffffffffc0205cea:	8ba50513          	addi	a0,a0,-1862 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205cee:	d28fa0ef          	jal	ra,ffffffffc0200216 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205cf2:	00002617          	auipc	a2,0x2
ffffffffc0205cf6:	7ce60613          	addi	a2,a2,1998 # ffffffffc02084c0 <default_pmm_manager+0x420>
ffffffffc0205cfa:	38100593          	li	a1,897
ffffffffc0205cfe:	00003517          	auipc	a0,0x3
ffffffffc0205d02:	8a250513          	addi	a0,a0,-1886 # ffffffffc02085a0 <default_pmm_manager+0x500>
ffffffffc0205d06:	d10fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205d0a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205d0a:	1141                	addi	sp,sp,-16
ffffffffc0205d0c:	e022                	sd	s0,0(sp)
ffffffffc0205d0e:	e406                	sd	ra,8(sp)
ffffffffc0205d10:	000a7417          	auipc	s0,0xa7
ffffffffc0205d14:	8a840413          	addi	s0,s0,-1880 # ffffffffc02ac5b8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205d18:	6018                	ld	a4,0(s0)
ffffffffc0205d1a:	6f1c                	ld	a5,24(a4)
ffffffffc0205d1c:	dffd                	beqz	a5,ffffffffc0205d1a <cpu_idle+0x10>
            schedule();
ffffffffc0205d1e:	082000ef          	jal	ra,ffffffffc0205da0 <schedule>
ffffffffc0205d22:	bfdd                	j	ffffffffc0205d18 <cpu_idle+0xe>

ffffffffc0205d24 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d24:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205d26:	1101                	addi	sp,sp,-32
ffffffffc0205d28:	ec06                	sd	ra,24(sp)
ffffffffc0205d2a:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d2c:	478d                	li	a5,3
ffffffffc0205d2e:	04f70a63          	beq	a4,a5,ffffffffc0205d82 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d32:	100027f3          	csrr	a5,sstatus
ffffffffc0205d36:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205d38:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d3a:	ef8d                	bnez	a5,ffffffffc0205d74 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205d3c:	4789                	li	a5,2
ffffffffc0205d3e:	00f70f63          	beq	a4,a5,ffffffffc0205d5c <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205d42:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205d44:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205d48:	e409                	bnez	s0,ffffffffc0205d52 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205d4a:	60e2                	ld	ra,24(sp)
ffffffffc0205d4c:	6442                	ld	s0,16(sp)
ffffffffc0205d4e:	6105                	addi	sp,sp,32
ffffffffc0205d50:	8082                	ret
ffffffffc0205d52:	6442                	ld	s0,16(sp)
ffffffffc0205d54:	60e2                	ld	ra,24(sp)
ffffffffc0205d56:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205d58:	8dbfa06f          	j	ffffffffc0200632 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205d5c:	00003617          	auipc	a2,0x3
ffffffffc0205d60:	89460613          	addi	a2,a2,-1900 # ffffffffc02085f0 <default_pmm_manager+0x550>
ffffffffc0205d64:	45c9                	li	a1,18
ffffffffc0205d66:	00003517          	auipc	a0,0x3
ffffffffc0205d6a:	87250513          	addi	a0,a0,-1934 # ffffffffc02085d8 <default_pmm_manager+0x538>
ffffffffc0205d6e:	d14fa0ef          	jal	ra,ffffffffc0200282 <__warn>
ffffffffc0205d72:	bfd9                	j	ffffffffc0205d48 <wakeup_proc+0x24>
ffffffffc0205d74:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205d76:	8c3fa0ef          	jal	ra,ffffffffc0200638 <intr_disable>
        return 1;
ffffffffc0205d7a:	6522                	ld	a0,8(sp)
ffffffffc0205d7c:	4405                	li	s0,1
ffffffffc0205d7e:	4118                	lw	a4,0(a0)
ffffffffc0205d80:	bf75                	j	ffffffffc0205d3c <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d82:	00003697          	auipc	a3,0x3
ffffffffc0205d86:	83668693          	addi	a3,a3,-1994 # ffffffffc02085b8 <default_pmm_manager+0x518>
ffffffffc0205d8a:	00001617          	auipc	a2,0x1
ffffffffc0205d8e:	c5660613          	addi	a2,a2,-938 # ffffffffc02069e0 <commands+0x480>
ffffffffc0205d92:	45a5                	li	a1,9
ffffffffc0205d94:	00003517          	auipc	a0,0x3
ffffffffc0205d98:	84450513          	addi	a0,a0,-1980 # ffffffffc02085d8 <default_pmm_manager+0x538>
ffffffffc0205d9c:	c7afa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205da0 <schedule>:

void
schedule(void) {
ffffffffc0205da0:	1141                	addi	sp,sp,-16
ffffffffc0205da2:	e406                	sd	ra,8(sp)
ffffffffc0205da4:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205da6:	100027f3          	csrr	a5,sstatus
ffffffffc0205daa:	8b89                	andi	a5,a5,2
ffffffffc0205dac:	4401                	li	s0,0
ffffffffc0205dae:	e3d1                	bnez	a5,ffffffffc0205e32 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205db0:	000a7797          	auipc	a5,0xa7
ffffffffc0205db4:	80878793          	addi	a5,a5,-2040 # ffffffffc02ac5b8 <current>
ffffffffc0205db8:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205dbc:	000a7797          	auipc	a5,0xa7
ffffffffc0205dc0:	80478793          	addi	a5,a5,-2044 # ffffffffc02ac5c0 <idleproc>
ffffffffc0205dc4:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205dc6:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7570>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205dca:	04a88e63          	beq	a7,a0,ffffffffc0205e26 <schedule+0x86>
ffffffffc0205dce:	0c888693          	addi	a3,a7,200
ffffffffc0205dd2:	000a7617          	auipc	a2,0xa7
ffffffffc0205dd6:	92660613          	addi	a2,a2,-1754 # ffffffffc02ac6f8 <proc_list>
        le = last;
ffffffffc0205dda:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205ddc:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205dde:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205de0:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205de2:	00c78863          	beq	a5,a2,ffffffffc0205df2 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205de6:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205dea:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205dee:	01070463          	beq	a4,a6,ffffffffc0205df6 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205df2:	fef697e3          	bne	a3,a5,ffffffffc0205de0 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205df6:	c589                	beqz	a1,ffffffffc0205e00 <schedule+0x60>
ffffffffc0205df8:	4198                	lw	a4,0(a1)
ffffffffc0205dfa:	4789                	li	a5,2
ffffffffc0205dfc:	00f70e63          	beq	a4,a5,ffffffffc0205e18 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205e00:	451c                	lw	a5,8(a0)
ffffffffc0205e02:	2785                	addiw	a5,a5,1
ffffffffc0205e04:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205e06:	00a88463          	beq	a7,a0,ffffffffc0205e0e <schedule+0x6e>
            proc_run(next);
ffffffffc0205e0a:	f31fe0ef          	jal	ra,ffffffffc0204d3a <proc_run>
    if (flag) {
ffffffffc0205e0e:	e419                	bnez	s0,ffffffffc0205e1c <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205e10:	60a2                	ld	ra,8(sp)
ffffffffc0205e12:	6402                	ld	s0,0(sp)
ffffffffc0205e14:	0141                	addi	sp,sp,16
ffffffffc0205e16:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205e18:	852e                	mv	a0,a1
ffffffffc0205e1a:	b7dd                	j	ffffffffc0205e00 <schedule+0x60>
}
ffffffffc0205e1c:	6402                	ld	s0,0(sp)
ffffffffc0205e1e:	60a2                	ld	ra,8(sp)
ffffffffc0205e20:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205e22:	811fa06f          	j	ffffffffc0200632 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205e26:	000a7617          	auipc	a2,0xa7
ffffffffc0205e2a:	8d260613          	addi	a2,a2,-1838 # ffffffffc02ac6f8 <proc_list>
ffffffffc0205e2e:	86b2                	mv	a3,a2
ffffffffc0205e30:	b76d                	j	ffffffffc0205dda <schedule+0x3a>
        intr_disable();
ffffffffc0205e32:	807fa0ef          	jal	ra,ffffffffc0200638 <intr_disable>
        return 1;
ffffffffc0205e36:	4405                	li	s0,1
ffffffffc0205e38:	bfa5                	j	ffffffffc0205db0 <schedule+0x10>

ffffffffc0205e3a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205e3a:	000a6797          	auipc	a5,0xa6
ffffffffc0205e3e:	77e78793          	addi	a5,a5,1918 # ffffffffc02ac5b8 <current>
ffffffffc0205e42:	639c                	ld	a5,0(a5)
}
ffffffffc0205e44:	43c8                	lw	a0,4(a5)
ffffffffc0205e46:	8082                	ret

ffffffffc0205e48 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205e48:	4501                	li	a0,0
ffffffffc0205e4a:	8082                	ret

ffffffffc0205e4c <sys_putc>:
    cputchar(c);
ffffffffc0205e4c:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205e4e:	1141                	addi	sp,sp,-16
ffffffffc0205e50:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205e52:	ab2fa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc0205e56:	60a2                	ld	ra,8(sp)
ffffffffc0205e58:	4501                	li	a0,0
ffffffffc0205e5a:	0141                	addi	sp,sp,16
ffffffffc0205e5c:	8082                	ret

ffffffffc0205e5e <sys_kill>:
    return do_kill(pid);
ffffffffc0205e5e:	4108                	lw	a0,0(a0)
ffffffffc0205e60:	d17ff06f          	j	ffffffffc0205b76 <do_kill>

ffffffffc0205e64 <sys_yield>:
    return do_yield();
ffffffffc0205e64:	cc1ff06f          	j	ffffffffc0205b24 <do_yield>

ffffffffc0205e68 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205e68:	6d14                	ld	a3,24(a0)
ffffffffc0205e6a:	6910                	ld	a2,16(a0)
ffffffffc0205e6c:	650c                	ld	a1,8(a0)
ffffffffc0205e6e:	6108                	ld	a0,0(a0)
ffffffffc0205e70:	fdcff06f          	j	ffffffffc020564c <do_execve>

ffffffffc0205e74 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205e74:	650c                	ld	a1,8(a0)
ffffffffc0205e76:	4108                	lw	a0,0(a0)
ffffffffc0205e78:	cbfff06f          	j	ffffffffc0205b36 <do_wait>

ffffffffc0205e7c <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205e7c:	000a6797          	auipc	a5,0xa6
ffffffffc0205e80:	73c78793          	addi	a5,a5,1852 # ffffffffc02ac5b8 <current>
ffffffffc0205e84:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0205e86:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0205e88:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205e8a:	6a0c                	ld	a1,16(a2)
ffffffffc0205e8c:	f77fe06f          	j	ffffffffc0204e02 <do_fork>

ffffffffc0205e90 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205e90:	4108                	lw	a0,0(a0)
ffffffffc0205e92:	b9cff06f          	j	ffffffffc020522e <do_exit>

ffffffffc0205e96 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205e96:	715d                	addi	sp,sp,-80
ffffffffc0205e98:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205e9a:	000a6497          	auipc	s1,0xa6
ffffffffc0205e9e:	71e48493          	addi	s1,s1,1822 # ffffffffc02ac5b8 <current>
ffffffffc0205ea2:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205ea4:	e0a2                	sd	s0,64(sp)
ffffffffc0205ea6:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205ea8:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205eaa:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205eac:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205eae:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205eb2:	0327ee63          	bltu	a5,s2,ffffffffc0205eee <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205eb6:	00391713          	slli	a4,s2,0x3
ffffffffc0205eba:	00002797          	auipc	a5,0x2
ffffffffc0205ebe:	79e78793          	addi	a5,a5,1950 # ffffffffc0208658 <syscalls>
ffffffffc0205ec2:	97ba                	add	a5,a5,a4
ffffffffc0205ec4:	639c                	ld	a5,0(a5)
ffffffffc0205ec6:	c785                	beqz	a5,ffffffffc0205eee <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205ec8:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205eca:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205ecc:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205ece:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205ed0:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205ed2:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205ed4:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205ed6:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205ed8:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205eda:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205edc:	0028                	addi	a0,sp,8
ffffffffc0205ede:	9782                	jalr	a5
ffffffffc0205ee0:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205ee2:	60a6                	ld	ra,72(sp)
ffffffffc0205ee4:	6406                	ld	s0,64(sp)
ffffffffc0205ee6:	74e2                	ld	s1,56(sp)
ffffffffc0205ee8:	7942                	ld	s2,48(sp)
ffffffffc0205eea:	6161                	addi	sp,sp,80
ffffffffc0205eec:	8082                	ret
    print_trapframe(tf);
ffffffffc0205eee:	8522                	mv	a0,s0
ffffffffc0205ef0:	937fa0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205ef4:	609c                	ld	a5,0(s1)
ffffffffc0205ef6:	86ca                	mv	a3,s2
ffffffffc0205ef8:	00002617          	auipc	a2,0x2
ffffffffc0205efc:	71860613          	addi	a2,a2,1816 # ffffffffc0208610 <default_pmm_manager+0x570>
ffffffffc0205f00:	43d8                	lw	a4,4(a5)
ffffffffc0205f02:	06300593          	li	a1,99
ffffffffc0205f06:	0b478793          	addi	a5,a5,180
ffffffffc0205f0a:	00002517          	auipc	a0,0x2
ffffffffc0205f0e:	73650513          	addi	a0,a0,1846 # ffffffffc0208640 <default_pmm_manager+0x5a0>
ffffffffc0205f12:	b04fa0ef          	jal	ra,ffffffffc0200216 <__panic>

ffffffffc0205f16 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205f16:	00054783          	lbu	a5,0(a0)
ffffffffc0205f1a:	cb91                	beqz	a5,ffffffffc0205f2e <strlen+0x18>
    size_t cnt = 0;
ffffffffc0205f1c:	4781                	li	a5,0
        cnt ++;
ffffffffc0205f1e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0205f20:	00f50733          	add	a4,a0,a5
ffffffffc0205f24:	00074703          	lbu	a4,0(a4)
ffffffffc0205f28:	fb7d                	bnez	a4,ffffffffc0205f1e <strlen+0x8>
    }
    return cnt;
}
ffffffffc0205f2a:	853e                	mv	a0,a5
ffffffffc0205f2c:	8082                	ret
    size_t cnt = 0;
ffffffffc0205f2e:	4781                	li	a5,0
}
ffffffffc0205f30:	853e                	mv	a0,a5
ffffffffc0205f32:	8082                	ret

ffffffffc0205f34 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205f34:	c185                	beqz	a1,ffffffffc0205f54 <strnlen+0x20>
ffffffffc0205f36:	00054783          	lbu	a5,0(a0)
ffffffffc0205f3a:	cf89                	beqz	a5,ffffffffc0205f54 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0205f3c:	4781                	li	a5,0
ffffffffc0205f3e:	a021                	j	ffffffffc0205f46 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205f40:	00074703          	lbu	a4,0(a4)
ffffffffc0205f44:	c711                	beqz	a4,ffffffffc0205f50 <strnlen+0x1c>
        cnt ++;
ffffffffc0205f46:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205f48:	00f50733          	add	a4,a0,a5
ffffffffc0205f4c:	fef59ae3          	bne	a1,a5,ffffffffc0205f40 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0205f50:	853e                	mv	a0,a5
ffffffffc0205f52:	8082                	ret
    size_t cnt = 0;
ffffffffc0205f54:	4781                	li	a5,0
}
ffffffffc0205f56:	853e                	mv	a0,a5
ffffffffc0205f58:	8082                	ret

ffffffffc0205f5a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205f5a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205f5c:	0585                	addi	a1,a1,1
ffffffffc0205f5e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205f62:	0785                	addi	a5,a5,1
ffffffffc0205f64:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205f68:	fb75                	bnez	a4,ffffffffc0205f5c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205f6a:	8082                	ret

ffffffffc0205f6c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205f6c:	00054783          	lbu	a5,0(a0)
ffffffffc0205f70:	0005c703          	lbu	a4,0(a1)
ffffffffc0205f74:	cb91                	beqz	a5,ffffffffc0205f88 <strcmp+0x1c>
ffffffffc0205f76:	00e79c63          	bne	a5,a4,ffffffffc0205f8e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0205f7a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205f7c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0205f80:	0585                	addi	a1,a1,1
ffffffffc0205f82:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205f86:	fbe5                	bnez	a5,ffffffffc0205f76 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205f88:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205f8a:	9d19                	subw	a0,a0,a4
ffffffffc0205f8c:	8082                	ret
ffffffffc0205f8e:	0007851b          	sext.w	a0,a5
ffffffffc0205f92:	9d19                	subw	a0,a0,a4
ffffffffc0205f94:	8082                	ret

ffffffffc0205f96 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205f96:	00054783          	lbu	a5,0(a0)
ffffffffc0205f9a:	cb91                	beqz	a5,ffffffffc0205fae <strchr+0x18>
        if (*s == c) {
ffffffffc0205f9c:	00b79563          	bne	a5,a1,ffffffffc0205fa6 <strchr+0x10>
ffffffffc0205fa0:	a809                	j	ffffffffc0205fb2 <strchr+0x1c>
ffffffffc0205fa2:	00b78763          	beq	a5,a1,ffffffffc0205fb0 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0205fa6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205fa8:	00054783          	lbu	a5,0(a0)
ffffffffc0205fac:	fbfd                	bnez	a5,ffffffffc0205fa2 <strchr+0xc>
    }
    return NULL;
ffffffffc0205fae:	4501                	li	a0,0
}
ffffffffc0205fb0:	8082                	ret
ffffffffc0205fb2:	8082                	ret

ffffffffc0205fb4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205fb4:	ca01                	beqz	a2,ffffffffc0205fc4 <memset+0x10>
ffffffffc0205fb6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205fb8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205fba:	0785                	addi	a5,a5,1
ffffffffc0205fbc:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205fc0:	fec79de3          	bne	a5,a2,ffffffffc0205fba <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205fc4:	8082                	ret

ffffffffc0205fc6 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205fc6:	ca19                	beqz	a2,ffffffffc0205fdc <memcpy+0x16>
ffffffffc0205fc8:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205fca:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205fcc:	0585                	addi	a1,a1,1
ffffffffc0205fce:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205fd2:	0785                	addi	a5,a5,1
ffffffffc0205fd4:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205fd8:	fec59ae3          	bne	a1,a2,ffffffffc0205fcc <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205fdc:	8082                	ret

ffffffffc0205fde <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205fde:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205fe2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205fe4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205fe8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205fea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205fee:	f022                	sd	s0,32(sp)
ffffffffc0205ff0:	ec26                	sd	s1,24(sp)
ffffffffc0205ff2:	e84a                	sd	s2,16(sp)
ffffffffc0205ff4:	f406                	sd	ra,40(sp)
ffffffffc0205ff6:	e44e                	sd	s3,8(sp)
ffffffffc0205ff8:	84aa                	mv	s1,a0
ffffffffc0205ffa:	892e                	mv	s2,a1
ffffffffc0205ffc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206000:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0206002:	03067e63          	bleu	a6,a2,ffffffffc020603e <printnum+0x60>
ffffffffc0206006:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206008:	00805763          	blez	s0,ffffffffc0206016 <printnum+0x38>
ffffffffc020600c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020600e:	85ca                	mv	a1,s2
ffffffffc0206010:	854e                	mv	a0,s3
ffffffffc0206012:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206014:	fc65                	bnez	s0,ffffffffc020600c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206016:	1a02                	slli	s4,s4,0x20
ffffffffc0206018:	020a5a13          	srli	s4,s4,0x20
ffffffffc020601c:	00003797          	auipc	a5,0x3
ffffffffc0206020:	95c78793          	addi	a5,a5,-1700 # ffffffffc0208978 <error_string+0xc8>
ffffffffc0206024:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206026:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206028:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020602c:	70a2                	ld	ra,40(sp)
ffffffffc020602e:	69a2                	ld	s3,8(sp)
ffffffffc0206030:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206032:	85ca                	mv	a1,s2
ffffffffc0206034:	8326                	mv	t1,s1
}
ffffffffc0206036:	6942                	ld	s2,16(sp)
ffffffffc0206038:	64e2                	ld	s1,24(sp)
ffffffffc020603a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020603c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020603e:	03065633          	divu	a2,a2,a6
ffffffffc0206042:	8722                	mv	a4,s0
ffffffffc0206044:	f9bff0ef          	jal	ra,ffffffffc0205fde <printnum>
ffffffffc0206048:	b7f9                	j	ffffffffc0206016 <printnum+0x38>

ffffffffc020604a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020604a:	7119                	addi	sp,sp,-128
ffffffffc020604c:	f4a6                	sd	s1,104(sp)
ffffffffc020604e:	f0ca                	sd	s2,96(sp)
ffffffffc0206050:	e8d2                	sd	s4,80(sp)
ffffffffc0206052:	e4d6                	sd	s5,72(sp)
ffffffffc0206054:	e0da                	sd	s6,64(sp)
ffffffffc0206056:	fc5e                	sd	s7,56(sp)
ffffffffc0206058:	f862                	sd	s8,48(sp)
ffffffffc020605a:	f06a                	sd	s10,32(sp)
ffffffffc020605c:	fc86                	sd	ra,120(sp)
ffffffffc020605e:	f8a2                	sd	s0,112(sp)
ffffffffc0206060:	ecce                	sd	s3,88(sp)
ffffffffc0206062:	f466                	sd	s9,40(sp)
ffffffffc0206064:	ec6e                	sd	s11,24(sp)
ffffffffc0206066:	892a                	mv	s2,a0
ffffffffc0206068:	84ae                	mv	s1,a1
ffffffffc020606a:	8d32                	mv	s10,a2
ffffffffc020606c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020606e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206070:	00002a17          	auipc	s4,0x2
ffffffffc0206074:	6e8a0a13          	addi	s4,s4,1768 # ffffffffc0208758 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206078:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020607c:	00003c17          	auipc	s8,0x3
ffffffffc0206080:	834c0c13          	addi	s8,s8,-1996 # ffffffffc02088b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206084:	000d4503          	lbu	a0,0(s10)
ffffffffc0206088:	02500793          	li	a5,37
ffffffffc020608c:	001d0413          	addi	s0,s10,1
ffffffffc0206090:	00f50e63          	beq	a0,a5,ffffffffc02060ac <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0206094:	c521                	beqz	a0,ffffffffc02060dc <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206096:	02500993          	li	s3,37
ffffffffc020609a:	a011                	j	ffffffffc020609e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020609c:	c121                	beqz	a0,ffffffffc02060dc <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020609e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02060a0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02060a2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02060a4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02060a8:	ff351ae3          	bne	a0,s3,ffffffffc020609c <vprintfmt+0x52>
ffffffffc02060ac:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02060b0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02060b4:	4981                	li	s3,0
ffffffffc02060b6:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02060b8:	5cfd                	li	s9,-1
ffffffffc02060ba:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060bc:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02060c0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060c2:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02060c6:	0ff6f693          	andi	a3,a3,255
ffffffffc02060ca:	00140d13          	addi	s10,s0,1
ffffffffc02060ce:	20d5e563          	bltu	a1,a3,ffffffffc02062d8 <vprintfmt+0x28e>
ffffffffc02060d2:	068a                	slli	a3,a3,0x2
ffffffffc02060d4:	96d2                	add	a3,a3,s4
ffffffffc02060d6:	4294                	lw	a3,0(a3)
ffffffffc02060d8:	96d2                	add	a3,a3,s4
ffffffffc02060da:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02060dc:	70e6                	ld	ra,120(sp)
ffffffffc02060de:	7446                	ld	s0,112(sp)
ffffffffc02060e0:	74a6                	ld	s1,104(sp)
ffffffffc02060e2:	7906                	ld	s2,96(sp)
ffffffffc02060e4:	69e6                	ld	s3,88(sp)
ffffffffc02060e6:	6a46                	ld	s4,80(sp)
ffffffffc02060e8:	6aa6                	ld	s5,72(sp)
ffffffffc02060ea:	6b06                	ld	s6,64(sp)
ffffffffc02060ec:	7be2                	ld	s7,56(sp)
ffffffffc02060ee:	7c42                	ld	s8,48(sp)
ffffffffc02060f0:	7ca2                	ld	s9,40(sp)
ffffffffc02060f2:	7d02                	ld	s10,32(sp)
ffffffffc02060f4:	6de2                	ld	s11,24(sp)
ffffffffc02060f6:	6109                	addi	sp,sp,128
ffffffffc02060f8:	8082                	ret
    if (lflag >= 2) {
ffffffffc02060fa:	4705                	li	a4,1
ffffffffc02060fc:	008a8593          	addi	a1,s5,8
ffffffffc0206100:	01074463          	blt	a4,a6,ffffffffc0206108 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0206104:	26080363          	beqz	a6,ffffffffc020636a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0206108:	000ab603          	ld	a2,0(s5)
ffffffffc020610c:	46c1                	li	a3,16
ffffffffc020610e:	8aae                	mv	s5,a1
ffffffffc0206110:	a06d                	j	ffffffffc02061ba <vprintfmt+0x170>
            goto reswitch;
ffffffffc0206112:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206116:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206118:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020611a:	b765                	j	ffffffffc02060c2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020611c:	000aa503          	lw	a0,0(s5)
ffffffffc0206120:	85a6                	mv	a1,s1
ffffffffc0206122:	0aa1                	addi	s5,s5,8
ffffffffc0206124:	9902                	jalr	s2
            break;
ffffffffc0206126:	bfb9                	j	ffffffffc0206084 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206128:	4705                	li	a4,1
ffffffffc020612a:	008a8993          	addi	s3,s5,8
ffffffffc020612e:	01074463          	blt	a4,a6,ffffffffc0206136 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0206132:	22080463          	beqz	a6,ffffffffc020635a <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0206136:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020613a:	24044463          	bltz	s0,ffffffffc0206382 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020613e:	8622                	mv	a2,s0
ffffffffc0206140:	8ace                	mv	s5,s3
ffffffffc0206142:	46a9                	li	a3,10
ffffffffc0206144:	a89d                	j	ffffffffc02061ba <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0206146:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020614a:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020614c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020614e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206152:	8fb5                	xor	a5,a5,a3
ffffffffc0206154:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206158:	1ad74363          	blt	a4,a3,ffffffffc02062fe <vprintfmt+0x2b4>
ffffffffc020615c:	00369793          	slli	a5,a3,0x3
ffffffffc0206160:	97e2                	add	a5,a5,s8
ffffffffc0206162:	639c                	ld	a5,0(a5)
ffffffffc0206164:	18078d63          	beqz	a5,ffffffffc02062fe <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206168:	86be                	mv	a3,a5
ffffffffc020616a:	00000617          	auipc	a2,0x0
ffffffffc020616e:	2ae60613          	addi	a2,a2,686 # ffffffffc0206418 <etext+0x2a>
ffffffffc0206172:	85a6                	mv	a1,s1
ffffffffc0206174:	854a                	mv	a0,s2
ffffffffc0206176:	240000ef          	jal	ra,ffffffffc02063b6 <printfmt>
ffffffffc020617a:	b729                	j	ffffffffc0206084 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020617c:	00144603          	lbu	a2,1(s0)
ffffffffc0206180:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206182:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206184:	bf3d                	j	ffffffffc02060c2 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206186:	4705                	li	a4,1
ffffffffc0206188:	008a8593          	addi	a1,s5,8
ffffffffc020618c:	01074463          	blt	a4,a6,ffffffffc0206194 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0206190:	1e080263          	beqz	a6,ffffffffc0206374 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0206194:	000ab603          	ld	a2,0(s5)
ffffffffc0206198:	46a1                	li	a3,8
ffffffffc020619a:	8aae                	mv	s5,a1
ffffffffc020619c:	a839                	j	ffffffffc02061ba <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020619e:	03000513          	li	a0,48
ffffffffc02061a2:	85a6                	mv	a1,s1
ffffffffc02061a4:	e03e                	sd	a5,0(sp)
ffffffffc02061a6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02061a8:	85a6                	mv	a1,s1
ffffffffc02061aa:	07800513          	li	a0,120
ffffffffc02061ae:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02061b0:	0aa1                	addi	s5,s5,8
ffffffffc02061b2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02061b6:	6782                	ld	a5,0(sp)
ffffffffc02061b8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02061ba:	876e                	mv	a4,s11
ffffffffc02061bc:	85a6                	mv	a1,s1
ffffffffc02061be:	854a                	mv	a0,s2
ffffffffc02061c0:	e1fff0ef          	jal	ra,ffffffffc0205fde <printnum>
            break;
ffffffffc02061c4:	b5c1                	j	ffffffffc0206084 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02061c6:	000ab603          	ld	a2,0(s5)
ffffffffc02061ca:	0aa1                	addi	s5,s5,8
ffffffffc02061cc:	1c060663          	beqz	a2,ffffffffc0206398 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02061d0:	00160413          	addi	s0,a2,1
ffffffffc02061d4:	17b05c63          	blez	s11,ffffffffc020634c <vprintfmt+0x302>
ffffffffc02061d8:	02d00593          	li	a1,45
ffffffffc02061dc:	14b79263          	bne	a5,a1,ffffffffc0206320 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02061e0:	00064783          	lbu	a5,0(a2)
ffffffffc02061e4:	0007851b          	sext.w	a0,a5
ffffffffc02061e8:	c905                	beqz	a0,ffffffffc0206218 <vprintfmt+0x1ce>
ffffffffc02061ea:	000cc563          	bltz	s9,ffffffffc02061f4 <vprintfmt+0x1aa>
ffffffffc02061ee:	3cfd                	addiw	s9,s9,-1
ffffffffc02061f0:	036c8263          	beq	s9,s6,ffffffffc0206214 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02061f4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02061f6:	18098463          	beqz	s3,ffffffffc020637e <vprintfmt+0x334>
ffffffffc02061fa:	3781                	addiw	a5,a5,-32
ffffffffc02061fc:	18fbf163          	bleu	a5,s7,ffffffffc020637e <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0206200:	03f00513          	li	a0,63
ffffffffc0206204:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206206:	0405                	addi	s0,s0,1
ffffffffc0206208:	fff44783          	lbu	a5,-1(s0)
ffffffffc020620c:	3dfd                	addiw	s11,s11,-1
ffffffffc020620e:	0007851b          	sext.w	a0,a5
ffffffffc0206212:	fd61                	bnez	a0,ffffffffc02061ea <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206214:	e7b058e3          	blez	s11,ffffffffc0206084 <vprintfmt+0x3a>
ffffffffc0206218:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020621a:	85a6                	mv	a1,s1
ffffffffc020621c:	02000513          	li	a0,32
ffffffffc0206220:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206222:	e60d81e3          	beqz	s11,ffffffffc0206084 <vprintfmt+0x3a>
ffffffffc0206226:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206228:	85a6                	mv	a1,s1
ffffffffc020622a:	02000513          	li	a0,32
ffffffffc020622e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206230:	fe0d94e3          	bnez	s11,ffffffffc0206218 <vprintfmt+0x1ce>
ffffffffc0206234:	bd81                	j	ffffffffc0206084 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206236:	4705                	li	a4,1
ffffffffc0206238:	008a8593          	addi	a1,s5,8
ffffffffc020623c:	01074463          	blt	a4,a6,ffffffffc0206244 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0206240:	12080063          	beqz	a6,ffffffffc0206360 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206244:	000ab603          	ld	a2,0(s5)
ffffffffc0206248:	46a9                	li	a3,10
ffffffffc020624a:	8aae                	mv	s5,a1
ffffffffc020624c:	b7bd                	j	ffffffffc02061ba <vprintfmt+0x170>
ffffffffc020624e:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0206252:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206256:	846a                	mv	s0,s10
ffffffffc0206258:	b5ad                	j	ffffffffc02060c2 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020625a:	85a6                	mv	a1,s1
ffffffffc020625c:	02500513          	li	a0,37
ffffffffc0206260:	9902                	jalr	s2
            break;
ffffffffc0206262:	b50d                	j	ffffffffc0206084 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206264:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206268:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020626c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020626e:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206270:	e40dd9e3          	bgez	s11,ffffffffc02060c2 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206274:	8de6                	mv	s11,s9
ffffffffc0206276:	5cfd                	li	s9,-1
ffffffffc0206278:	b5a9                	j	ffffffffc02060c2 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020627a:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020627e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206282:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206284:	bd3d                	j	ffffffffc02060c2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0206286:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020628a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020628e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206290:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206294:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206298:	fcd56ce3          	bltu	a0,a3,ffffffffc0206270 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020629c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020629e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02062a2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02062a6:	0196873b          	addw	a4,a3,s9
ffffffffc02062aa:	0017171b          	slliw	a4,a4,0x1
ffffffffc02062ae:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02062b2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02062b6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02062ba:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02062be:	fcd57fe3          	bleu	a3,a0,ffffffffc020629c <vprintfmt+0x252>
ffffffffc02062c2:	b77d                	j	ffffffffc0206270 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02062c4:	fffdc693          	not	a3,s11
ffffffffc02062c8:	96fd                	srai	a3,a3,0x3f
ffffffffc02062ca:	00ddfdb3          	and	s11,s11,a3
ffffffffc02062ce:	00144603          	lbu	a2,1(s0)
ffffffffc02062d2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062d4:	846a                	mv	s0,s10
ffffffffc02062d6:	b3f5                	j	ffffffffc02060c2 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02062d8:	85a6                	mv	a1,s1
ffffffffc02062da:	02500513          	li	a0,37
ffffffffc02062de:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02062e0:	fff44703          	lbu	a4,-1(s0)
ffffffffc02062e4:	02500793          	li	a5,37
ffffffffc02062e8:	8d22                	mv	s10,s0
ffffffffc02062ea:	d8f70de3          	beq	a4,a5,ffffffffc0206084 <vprintfmt+0x3a>
ffffffffc02062ee:	02500713          	li	a4,37
ffffffffc02062f2:	1d7d                	addi	s10,s10,-1
ffffffffc02062f4:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02062f8:	fee79de3          	bne	a5,a4,ffffffffc02062f2 <vprintfmt+0x2a8>
ffffffffc02062fc:	b361                	j	ffffffffc0206084 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02062fe:	00002617          	auipc	a2,0x2
ffffffffc0206302:	75a60613          	addi	a2,a2,1882 # ffffffffc0208a58 <error_string+0x1a8>
ffffffffc0206306:	85a6                	mv	a1,s1
ffffffffc0206308:	854a                	mv	a0,s2
ffffffffc020630a:	0ac000ef          	jal	ra,ffffffffc02063b6 <printfmt>
ffffffffc020630e:	bb9d                	j	ffffffffc0206084 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206310:	00002617          	auipc	a2,0x2
ffffffffc0206314:	74060613          	addi	a2,a2,1856 # ffffffffc0208a50 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206318:	00002417          	auipc	s0,0x2
ffffffffc020631c:	73940413          	addi	s0,s0,1849 # ffffffffc0208a51 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206320:	8532                	mv	a0,a2
ffffffffc0206322:	85e6                	mv	a1,s9
ffffffffc0206324:	e032                	sd	a2,0(sp)
ffffffffc0206326:	e43e                	sd	a5,8(sp)
ffffffffc0206328:	c0dff0ef          	jal	ra,ffffffffc0205f34 <strnlen>
ffffffffc020632c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206330:	6602                	ld	a2,0(sp)
ffffffffc0206332:	01b05d63          	blez	s11,ffffffffc020634c <vprintfmt+0x302>
ffffffffc0206336:	67a2                	ld	a5,8(sp)
ffffffffc0206338:	2781                	sext.w	a5,a5
ffffffffc020633a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020633c:	6522                	ld	a0,8(sp)
ffffffffc020633e:	85a6                	mv	a1,s1
ffffffffc0206340:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206342:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206344:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206346:	6602                	ld	a2,0(sp)
ffffffffc0206348:	fe0d9ae3          	bnez	s11,ffffffffc020633c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020634c:	00064783          	lbu	a5,0(a2)
ffffffffc0206350:	0007851b          	sext.w	a0,a5
ffffffffc0206354:	e8051be3          	bnez	a0,ffffffffc02061ea <vprintfmt+0x1a0>
ffffffffc0206358:	b335                	j	ffffffffc0206084 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020635a:	000aa403          	lw	s0,0(s5)
ffffffffc020635e:	bbf1                	j	ffffffffc020613a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0206360:	000ae603          	lwu	a2,0(s5)
ffffffffc0206364:	46a9                	li	a3,10
ffffffffc0206366:	8aae                	mv	s5,a1
ffffffffc0206368:	bd89                	j	ffffffffc02061ba <vprintfmt+0x170>
ffffffffc020636a:	000ae603          	lwu	a2,0(s5)
ffffffffc020636e:	46c1                	li	a3,16
ffffffffc0206370:	8aae                	mv	s5,a1
ffffffffc0206372:	b5a1                	j	ffffffffc02061ba <vprintfmt+0x170>
ffffffffc0206374:	000ae603          	lwu	a2,0(s5)
ffffffffc0206378:	46a1                	li	a3,8
ffffffffc020637a:	8aae                	mv	s5,a1
ffffffffc020637c:	bd3d                	j	ffffffffc02061ba <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020637e:	9902                	jalr	s2
ffffffffc0206380:	b559                	j	ffffffffc0206206 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0206382:	85a6                	mv	a1,s1
ffffffffc0206384:	02d00513          	li	a0,45
ffffffffc0206388:	e03e                	sd	a5,0(sp)
ffffffffc020638a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020638c:	8ace                	mv	s5,s3
ffffffffc020638e:	40800633          	neg	a2,s0
ffffffffc0206392:	46a9                	li	a3,10
ffffffffc0206394:	6782                	ld	a5,0(sp)
ffffffffc0206396:	b515                	j	ffffffffc02061ba <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0206398:	01b05663          	blez	s11,ffffffffc02063a4 <vprintfmt+0x35a>
ffffffffc020639c:	02d00693          	li	a3,45
ffffffffc02063a0:	f6d798e3          	bne	a5,a3,ffffffffc0206310 <vprintfmt+0x2c6>
ffffffffc02063a4:	00002417          	auipc	s0,0x2
ffffffffc02063a8:	6ad40413          	addi	s0,s0,1709 # ffffffffc0208a51 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02063ac:	02800513          	li	a0,40
ffffffffc02063b0:	02800793          	li	a5,40
ffffffffc02063b4:	bd1d                	j	ffffffffc02061ea <vprintfmt+0x1a0>

ffffffffc02063b6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063b6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02063b8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063bc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02063be:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063c0:	ec06                	sd	ra,24(sp)
ffffffffc02063c2:	f83a                	sd	a4,48(sp)
ffffffffc02063c4:	fc3e                	sd	a5,56(sp)
ffffffffc02063c6:	e0c2                	sd	a6,64(sp)
ffffffffc02063c8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02063ca:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02063cc:	c7fff0ef          	jal	ra,ffffffffc020604a <vprintfmt>
}
ffffffffc02063d0:	60e2                	ld	ra,24(sp)
ffffffffc02063d2:	6161                	addi	sp,sp,80
ffffffffc02063d4:	8082                	ret

ffffffffc02063d6 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02063d6:	9e3707b7          	lui	a5,0x9e370
ffffffffc02063da:	2785                	addiw	a5,a5,1
ffffffffc02063dc:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02063e0:	02000793          	li	a5,32
ffffffffc02063e4:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02063e8:	00b5553b          	srlw	a0,a0,a1
ffffffffc02063ec:	8082                	ret
