
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02042b7          	lui	t0,0xc0204
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
ffffffffc0200028:	c0204137          	lui	sp,0xc0204

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00005517          	auipc	a0,0x5
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0205010 <edata>
ffffffffc020003e:	000a7617          	auipc	a2,0xa7
ffffffffc0200042:	5fa60613          	addi	a2,a2,1530 # ffffffffc02a7638 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	0b0010ef          	jal	ra,ffffffffc02010fe <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(NKU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0201620 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	67b000ef          	jal	ra,ffffffffc0200ee4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	0d2010ef          	jal	ra,ffffffffc020117c <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	09e010ef          	jal	ra,ffffffffc020117c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013e:	00005317          	auipc	t1,0x5
ffffffffc0200142:	2d230313          	addi	t1,t1,722 # ffffffffc0205410 <is_panic>
ffffffffc0200146:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020014a:	715d                	addi	sp,sp,-80
ffffffffc020014c:	ec06                	sd	ra,24(sp)
ffffffffc020014e:	e822                	sd	s0,16(sp)
ffffffffc0200150:	f436                	sd	a3,40(sp)
ffffffffc0200152:	f83a                	sd	a4,48(sp)
ffffffffc0200154:	fc3e                	sd	a5,56(sp)
ffffffffc0200156:	e0c2                	sd	a6,64(sp)
ffffffffc0200158:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020015a:	02031c63          	bnez	t1,ffffffffc0200192 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015e:	4785                	li	a5,1
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	00005717          	auipc	a4,0x5
ffffffffc0200166:	2af72723          	sw	a5,686(a4) # ffffffffc0205410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016a:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020016c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00001517          	auipc	a0,0x1
ffffffffc0200174:	4d050513          	addi	a0,a0,1232 # ffffffffc0201640 <etext+0x24>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f15ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00001517          	auipc	a0,0x1
ffffffffc020018a:	5d250513          	addi	a0,a0,1490 # ffffffffc0201758 <etext+0x13c>
ffffffffc020018e:	f29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200192:	2d2000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200196:	4501                	li	a0,0
ffffffffc0200198:	132000ef          	jal	ra,ffffffffc02002ca <kmonitor>
ffffffffc020019c:	bfed                	j	ffffffffc0200196 <__panic+0x58>

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00001517          	auipc	a0,0x1
ffffffffc02001a4:	4f050513          	addi	a0,a0,1264 # ffffffffc0201690 <etext+0x74>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00001517          	auipc	a0,0x1
ffffffffc02001ba:	4fa50513          	addi	a0,a0,1274 # ffffffffc02016b0 <etext+0x94>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00001597          	auipc	a1,0x1
ffffffffc02001c6:	45a58593          	addi	a1,a1,1114 # ffffffffc020161c <etext>
ffffffffc02001ca:	00001517          	auipc	a0,0x1
ffffffffc02001ce:	50650513          	addi	a0,a0,1286 # ffffffffc02016d0 <etext+0xb4>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00005597          	auipc	a1,0x5
ffffffffc02001da:	e3a58593          	addi	a1,a1,-454 # ffffffffc0205010 <edata>
ffffffffc02001de:	00001517          	auipc	a0,0x1
ffffffffc02001e2:	51250513          	addi	a0,a0,1298 # ffffffffc02016f0 <etext+0xd4>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	000a7597          	auipc	a1,0xa7
ffffffffc02001ee:	44e58593          	addi	a1,a1,1102 # ffffffffc02a7638 <end>
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	51e50513          	addi	a0,a0,1310 # ffffffffc0201710 <etext+0xf4>
ffffffffc02001fa:	ebdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	000a8597          	auipc	a1,0xa8
ffffffffc0200202:	83958593          	addi	a1,a1,-1991 # ffffffffc02a7a37 <end+0x3ff>
ffffffffc0200206:	00000797          	auipc	a5,0x0
ffffffffc020020a:	e3078793          	addi	a5,a5,-464 # ffffffffc0200036 <kern_init>
ffffffffc020020e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200212:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200218:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021c:	95be                	add	a1,a1,a5
ffffffffc020021e:	85a9                	srai	a1,a1,0xa
ffffffffc0200220:	00001517          	auipc	a0,0x1
ffffffffc0200224:	51050513          	addi	a0,a0,1296 # ffffffffc0201730 <etext+0x114>
}
ffffffffc0200228:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020022a:	e8dff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020022e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200230:	00001617          	auipc	a2,0x1
ffffffffc0200234:	43060613          	addi	a2,a2,1072 # ffffffffc0201660 <etext+0x44>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00001517          	auipc	a0,0x1
ffffffffc0200240:	43c50513          	addi	a0,a0,1084 # ffffffffc0201678 <etext+0x5c>
void print_stackframe(void) {
ffffffffc0200244:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200246:	ef9ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020024a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020024c:	00001617          	auipc	a2,0x1
ffffffffc0200250:	5f460613          	addi	a2,a2,1524 # ffffffffc0201840 <commands+0xe0>
ffffffffc0200254:	00001597          	auipc	a1,0x1
ffffffffc0200258:	60c58593          	addi	a1,a1,1548 # ffffffffc0201860 <commands+0x100>
ffffffffc020025c:	00001517          	auipc	a0,0x1
ffffffffc0200260:	60c50513          	addi	a0,a0,1548 # ffffffffc0201868 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00001617          	auipc	a2,0x1
ffffffffc020026e:	60e60613          	addi	a2,a2,1550 # ffffffffc0201878 <commands+0x118>
ffffffffc0200272:	00001597          	auipc	a1,0x1
ffffffffc0200276:	62e58593          	addi	a1,a1,1582 # ffffffffc02018a0 <commands+0x140>
ffffffffc020027a:	00001517          	auipc	a0,0x1
ffffffffc020027e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201868 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00001617          	auipc	a2,0x1
ffffffffc020028a:	62a60613          	addi	a2,a2,1578 # ffffffffc02018b0 <commands+0x150>
ffffffffc020028e:	00001597          	auipc	a1,0x1
ffffffffc0200292:	64258593          	addi	a1,a1,1602 # ffffffffc02018d0 <commands+0x170>
ffffffffc0200296:	00001517          	auipc	a0,0x1
ffffffffc020029a:	5d250513          	addi	a0,a0,1490 # ffffffffc0201868 <commands+0x108>
ffffffffc020029e:	e19ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc02002a2:	60a2                	ld	ra,8(sp)
ffffffffc02002a4:	4501                	li	a0,0
ffffffffc02002a6:	0141                	addi	sp,sp,16
ffffffffc02002a8:	8082                	ret

ffffffffc02002aa <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ae:	ef1ff0ef          	jal	ra,ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
ffffffffc02002b4:	4501                	li	a0,0
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	8082                	ret

ffffffffc02002ba <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002be:	f71ff0ef          	jal	ra,ffffffffc020022e <print_stackframe>
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ca:	7115                	addi	sp,sp,-224
ffffffffc02002cc:	e962                	sd	s8,144(sp)
ffffffffc02002ce:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002d0:	00001517          	auipc	a0,0x1
ffffffffc02002d4:	4d850513          	addi	a0,a0,1240 # ffffffffc02017a8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	ed86                	sd	ra,216(sp)
ffffffffc02002da:	e9a2                	sd	s0,208(sp)
ffffffffc02002dc:	e5a6                	sd	s1,200(sp)
ffffffffc02002de:	e1ca                	sd	s2,192(sp)
ffffffffc02002e0:	fd4e                	sd	s3,184(sp)
ffffffffc02002e2:	f952                	sd	s4,176(sp)
ffffffffc02002e4:	f556                	sd	s5,168(sp)
ffffffffc02002e6:	f15a                	sd	s6,160(sp)
ffffffffc02002e8:	ed5e                	sd	s7,152(sp)
ffffffffc02002ea:	e566                	sd	s9,136(sp)
ffffffffc02002ec:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ee:	dc9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002f2:	00001517          	auipc	a0,0x1
ffffffffc02002f6:	4de50513          	addi	a0,a0,1246 # ffffffffc02017d0 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	178000ef          	jal	ra,ffffffffc020047c <print_trapframe>
ffffffffc0200308:	00001c97          	auipc	s9,0x1
ffffffffc020030c:	458c8c93          	addi	s9,s9,1112 # ffffffffc0201760 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00001997          	auipc	s3,0x1
ffffffffc0200314:	4e898993          	addi	s3,s3,1256 # ffffffffc02017f8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00001917          	auipc	s2,0x1
ffffffffc020031c:	4e890913          	addi	s2,s2,1256 # ffffffffc0201800 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00001b17          	auipc	s6,0x1
ffffffffc0200326:	4e6b0b13          	addi	s6,s6,1254 # ffffffffc0201808 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00001a97          	auipc	s5,0x1
ffffffffc020032e:	536a8a93          	addi	s5,s5,1334 # ffffffffc0201860 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	1d2010ef          	jal	ra,ffffffffc0201508 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	599000ef          	jal	ra,ffffffffc02010e0 <strchr>
ffffffffc020034c:	c925                	beqz	a0,ffffffffc02003bc <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
ffffffffc0200352:	00040023          	sb	zero,0(s0)
ffffffffc0200356:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	f5fd                	bnez	a1,ffffffffc0200346 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020035a:	dce9                	beqz	s1,ffffffffc0200334 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	6582                	ld	a1,0(sp)
ffffffffc020035e:	00001d17          	auipc	s10,0x1
ffffffffc0200362:	402d0d13          	addi	s10,s10,1026 # ffffffffc0201760 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	54b000ef          	jal	ra,ffffffffc02010b6 <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	537000ef          	jal	ra,ffffffffc02010b6 <strcmp>
ffffffffc0200384:	f57d                	bnez	a0,ffffffffc0200372 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200386:	00141793          	slli	a5,s0,0x1
ffffffffc020038a:	97a2                	add	a5,a5,s0
ffffffffc020038c:	078e                	slli	a5,a5,0x3
ffffffffc020038e:	97e6                	add	a5,a5,s9
ffffffffc0200390:	6b9c                	ld	a5,16(a5)
ffffffffc0200392:	8662                	mv	a2,s8
ffffffffc0200394:	002c                	addi	a1,sp,8
ffffffffc0200396:	fff4851b          	addiw	a0,s1,-1
ffffffffc020039a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020039c:	f8055ce3          	bgez	a0,ffffffffc0200334 <kmonitor+0x6a>
}
ffffffffc02003a0:	60ee                	ld	ra,216(sp)
ffffffffc02003a2:	644e                	ld	s0,208(sp)
ffffffffc02003a4:	64ae                	ld	s1,200(sp)
ffffffffc02003a6:	690e                	ld	s2,192(sp)
ffffffffc02003a8:	79ea                	ld	s3,184(sp)
ffffffffc02003aa:	7a4a                	ld	s4,176(sp)
ffffffffc02003ac:	7aaa                	ld	s5,168(sp)
ffffffffc02003ae:	7b0a                	ld	s6,160(sp)
ffffffffc02003b0:	6bea                	ld	s7,152(sp)
ffffffffc02003b2:	6c4a                	ld	s8,144(sp)
ffffffffc02003b4:	6caa                	ld	s9,136(sp)
ffffffffc02003b6:	6d0a                	ld	s10,128(sp)
ffffffffc02003b8:	612d                	addi	sp,sp,224
ffffffffc02003ba:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003bc:	00044783          	lbu	a5,0(s0)
ffffffffc02003c0:	dfc9                	beqz	a5,ffffffffc020035a <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003c2:	03448863          	beq	s1,s4,ffffffffc02003f2 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003c6:	00349793          	slli	a5,s1,0x3
ffffffffc02003ca:	0118                	addi	a4,sp,128
ffffffffc02003cc:	97ba                	add	a5,a5,a4
ffffffffc02003ce:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d6:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d8:	e591                	bnez	a1,ffffffffc02003e4 <kmonitor+0x11a>
ffffffffc02003da:	b749                	j	ffffffffc020035c <kmonitor+0x92>
            buf ++;
ffffffffc02003dc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003de:	00044583          	lbu	a1,0(s0)
ffffffffc02003e2:	ddad                	beqz	a1,ffffffffc020035c <kmonitor+0x92>
ffffffffc02003e4:	854a                	mv	a0,s2
ffffffffc02003e6:	4fb000ef          	jal	ra,ffffffffc02010e0 <strchr>
ffffffffc02003ea:	d96d                	beqz	a0,ffffffffc02003dc <kmonitor+0x112>
ffffffffc02003ec:	00044583          	lbu	a1,0(s0)
ffffffffc02003f0:	bf91                	j	ffffffffc0200344 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003f2:	45c1                	li	a1,16
ffffffffc02003f4:	855a                	mv	a0,s6
ffffffffc02003f6:	cc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003fa:	b7f1                	j	ffffffffc02003c6 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00001517          	auipc	a0,0x1
ffffffffc0200402:	42a50513          	addi	a0,a0,1066 # ffffffffc0201828 <commands+0xc8>
ffffffffc0200406:	cb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc020040a:	b72d                	j	ffffffffc0200334 <kmonitor+0x6a>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	1be010ef          	jal	ra,ffffffffc02015e2 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00005797          	auipc	a5,0x5
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0205430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	4ae50513          	addi	a0,a0,1198 # ffffffffc02018e0 <commands+0x180>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	1960106f          	j	ffffffffc02015e2 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	1700106f          	j	ffffffffc02015c6 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	1a40106f          	j	ffffffffc02015fe <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	07278793          	addi	a5,a5,114 # ffffffffc02004e0 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_trapframe>:
    // print_regs(&tf->gpr);
    // cprintf("  status   0x%08x\n", tf->status);
    // cprintf("  epc      0x%08x\n", tf->epc);
    // cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    // cprintf("  cause    0x%08x\n", tf->cause);
}
ffffffffc020047c:	8082                	ret

ffffffffc020047e <interrupt_handler>:
    // cprintf("  t5       0x%08x\n", gpr->t5);
    // cprintf("  t6       0x%08x\n", gpr->t6);
}

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020047e:	11853783          	ld	a5,280(a0)
ffffffffc0200482:	577d                	li	a4,-1
ffffffffc0200484:	8305                	srli	a4,a4,0x1
ffffffffc0200486:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc0200488:	4715                	li	a4,5
ffffffffc020048a:	00e78363          	beq	a5,a4,ffffffffc0200490 <interrupt_handler+0x12>
ffffffffc020048e:	8082                	ret
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200490:	1141                	addi	sp,sp,-16
ffffffffc0200492:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200494:	fadff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200498:	00005797          	auipc	a5,0x5
ffffffffc020049c:	f9878793          	addi	a5,a5,-104 # ffffffffc0205430 <ticks>
ffffffffc02004a0:	639c                	ld	a5,0(a5)
ffffffffc02004a2:	06400713          	li	a4,100
ffffffffc02004a6:	0785                	addi	a5,a5,1
ffffffffc02004a8:	02e7f733          	remu	a4,a5,a4
ffffffffc02004ac:	00005697          	auipc	a3,0x5
ffffffffc02004b0:	f8f6b223          	sd	a5,-124(a3) # ffffffffc0205430 <ticks>
ffffffffc02004b4:	c701                	beqz	a4,ffffffffc02004bc <interrupt_handler+0x3e>
            break;
        default:
            //print_trapframe(tf);
            break;
    }
}
ffffffffc02004b6:	60a2                	ld	ra,8(sp)
ffffffffc02004b8:	0141                	addi	sp,sp,16
ffffffffc02004ba:	8082                	ret
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02004be:	06400593          	li	a1,100
ffffffffc02004c2:	00001517          	auipc	a0,0x1
ffffffffc02004c6:	43e50513          	addi	a0,a0,1086 # ffffffffc0201900 <commands+0x1a0>
}
ffffffffc02004ca:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02004cc:	bebff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02004d0 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02004d0:	11853783          	ld	a5,280(a0)
ffffffffc02004d4:	0007c363          	bltz	a5,ffffffffc02004da <trap+0xa>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc02004d8:	8082                	ret
        interrupt_handler(tf);
ffffffffc02004da:	fa5ff06f          	j	ffffffffc020047e <interrupt_handler>
	...

ffffffffc02004e0 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02004e0:	14011073          	csrw	sscratch,sp
ffffffffc02004e4:	712d                	addi	sp,sp,-288
ffffffffc02004e6:	e002                	sd	zero,0(sp)
ffffffffc02004e8:	e406                	sd	ra,8(sp)
ffffffffc02004ea:	ec0e                	sd	gp,24(sp)
ffffffffc02004ec:	f012                	sd	tp,32(sp)
ffffffffc02004ee:	f416                	sd	t0,40(sp)
ffffffffc02004f0:	f81a                	sd	t1,48(sp)
ffffffffc02004f2:	fc1e                	sd	t2,56(sp)
ffffffffc02004f4:	e0a2                	sd	s0,64(sp)
ffffffffc02004f6:	e4a6                	sd	s1,72(sp)
ffffffffc02004f8:	e8aa                	sd	a0,80(sp)
ffffffffc02004fa:	ecae                	sd	a1,88(sp)
ffffffffc02004fc:	f0b2                	sd	a2,96(sp)
ffffffffc02004fe:	f4b6                	sd	a3,104(sp)
ffffffffc0200500:	f8ba                	sd	a4,112(sp)
ffffffffc0200502:	fcbe                	sd	a5,120(sp)
ffffffffc0200504:	e142                	sd	a6,128(sp)
ffffffffc0200506:	e546                	sd	a7,136(sp)
ffffffffc0200508:	e94a                	sd	s2,144(sp)
ffffffffc020050a:	ed4e                	sd	s3,152(sp)
ffffffffc020050c:	f152                	sd	s4,160(sp)
ffffffffc020050e:	f556                	sd	s5,168(sp)
ffffffffc0200510:	f95a                	sd	s6,176(sp)
ffffffffc0200512:	fd5e                	sd	s7,184(sp)
ffffffffc0200514:	e1e2                	sd	s8,192(sp)
ffffffffc0200516:	e5e6                	sd	s9,200(sp)
ffffffffc0200518:	e9ea                	sd	s10,208(sp)
ffffffffc020051a:	edee                	sd	s11,216(sp)
ffffffffc020051c:	f1f2                	sd	t3,224(sp)
ffffffffc020051e:	f5f6                	sd	t4,232(sp)
ffffffffc0200520:	f9fa                	sd	t5,240(sp)
ffffffffc0200522:	fdfe                	sd	t6,248(sp)
ffffffffc0200524:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200528:	100024f3          	csrr	s1,sstatus
ffffffffc020052c:	14102973          	csrr	s2,sepc
ffffffffc0200530:	143029f3          	csrr	s3,stval
ffffffffc0200534:	14202a73          	csrr	s4,scause
ffffffffc0200538:	e822                	sd	s0,16(sp)
ffffffffc020053a:	e226                	sd	s1,256(sp)
ffffffffc020053c:	e64a                	sd	s2,264(sp)
ffffffffc020053e:	ea4e                	sd	s3,272(sp)
ffffffffc0200540:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200542:	850a                	mv	a0,sp
    jal trap
ffffffffc0200544:	f8dff0ef          	jal	ra,ffffffffc02004d0 <trap>

ffffffffc0200548 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200548:	6492                	ld	s1,256(sp)
ffffffffc020054a:	6932                	ld	s2,264(sp)
ffffffffc020054c:	10049073          	csrw	sstatus,s1
ffffffffc0200550:	14191073          	csrw	sepc,s2
ffffffffc0200554:	60a2                	ld	ra,8(sp)
ffffffffc0200556:	61e2                	ld	gp,24(sp)
ffffffffc0200558:	7202                	ld	tp,32(sp)
ffffffffc020055a:	72a2                	ld	t0,40(sp)
ffffffffc020055c:	7342                	ld	t1,48(sp)
ffffffffc020055e:	73e2                	ld	t2,56(sp)
ffffffffc0200560:	6406                	ld	s0,64(sp)
ffffffffc0200562:	64a6                	ld	s1,72(sp)
ffffffffc0200564:	6546                	ld	a0,80(sp)
ffffffffc0200566:	65e6                	ld	a1,88(sp)
ffffffffc0200568:	7606                	ld	a2,96(sp)
ffffffffc020056a:	76a6                	ld	a3,104(sp)
ffffffffc020056c:	7746                	ld	a4,112(sp)
ffffffffc020056e:	77e6                	ld	a5,120(sp)
ffffffffc0200570:	680a                	ld	a6,128(sp)
ffffffffc0200572:	68aa                	ld	a7,136(sp)
ffffffffc0200574:	694a                	ld	s2,144(sp)
ffffffffc0200576:	69ea                	ld	s3,152(sp)
ffffffffc0200578:	7a0a                	ld	s4,160(sp)
ffffffffc020057a:	7aaa                	ld	s5,168(sp)
ffffffffc020057c:	7b4a                	ld	s6,176(sp)
ffffffffc020057e:	7bea                	ld	s7,184(sp)
ffffffffc0200580:	6c0e                	ld	s8,192(sp)
ffffffffc0200582:	6cae                	ld	s9,200(sp)
ffffffffc0200584:	6d4e                	ld	s10,208(sp)
ffffffffc0200586:	6dee                	ld	s11,216(sp)
ffffffffc0200588:	7e0e                	ld	t3,224(sp)
ffffffffc020058a:	7eae                	ld	t4,232(sp)
ffffffffc020058c:	7f4e                	ld	t5,240(sp)
ffffffffc020058e:	7fee                	ld	t6,248(sp)
ffffffffc0200590:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200592:	10200073          	sret

ffffffffc0200596 <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200596:	000a1797          	auipc	a5,0xa1
ffffffffc020059a:	2aa78793          	addi	a5,a5,682 # ffffffffc02a1840 <free_area>
ffffffffc020059e:	e79c                	sd	a5,8(a5)
ffffffffc02005a0:	e39c                	sd	a5,0(a5)
    return;
}
static void buddy_init()
{
    list_init(&free_list);
    nr_free=0;//
ffffffffc02005a2:	0007a823          	sw	zero,16(a5)
    //cprintf("init_succeed");
}
ffffffffc02005a6:	8082                	ret

ffffffffc02005a8 <buddy_system_nr_free_pages>:
  cprintf("free_page succeed\n");
}
static size_t
buddy_system_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02005a8:	000a1517          	auipc	a0,0xa1
ffffffffc02005ac:	2a856503          	lwu	a0,680(a0) # ffffffffc02a1850 <free_area+0x10>
ffffffffc02005b0:	8082                	ret

ffffffffc02005b2 <buddy_free_pages>:
void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc02005b2:	1101                	addi	sp,sp,-32
ffffffffc02005b4:	e426                	sd	s1,8(sp)
ffffffffc02005b6:	84aa                	mv	s1,a0
  cprintf("free_page\n");
ffffffffc02005b8:	00001517          	auipc	a0,0x1
ffffffffc02005bc:	56850513          	addi	a0,a0,1384 # ffffffffc0201b20 <commands+0x3c0>
void buddy_free_pages(struct Page* base, size_t n) {
ffffffffc02005c0:	e822                	sd	s0,16(sp)
ffffffffc02005c2:	ec06                	sd	ra,24(sp)
ffffffffc02005c4:	842e                	mv	s0,a1
  cprintf("free_page\n");
ffffffffc02005c6:	af1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
  for(i=0;i<blockNum;i++)  //blockNum是已分配的块数
ffffffffc02005ca:	00005897          	auipc	a7,0x5
ffffffffc02005ce:	e6e88893          	addi	a7,a7,-402 # ffffffffc0205438 <blockNum>
ffffffffc02005d2:	0008a803          	lw	a6,0(a7)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02005d6:	000a1597          	auipc	a1,0xa1
ffffffffc02005da:	26a58593          	addi	a1,a1,618 # ffffffffc02a1840 <free_area>
ffffffffc02005de:	6598                	ld	a4,8(a1)
ffffffffc02005e0:	19005c63          	blez	a6,ffffffffc0200778 <buddy_free_pages+0x1c6>
    if(rec[i].base==base)  
ffffffffc02005e4:	000a1517          	auipc	a0,0xa1
ffffffffc02005e8:	27450513          	addi	a0,a0,628 # ffffffffc02a1858 <rec>
ffffffffc02005ec:	611c                	ld	a5,0(a0)
ffffffffc02005ee:	18f48b63          	beq	s1,a5,ffffffffc0200784 <buddy_free_pages+0x1d2>
ffffffffc02005f2:	000a1697          	auipc	a3,0xa1
ffffffffc02005f6:	27e68693          	addi	a3,a3,638 # ffffffffc02a1870 <rec+0x18>
  for(i=0;i<blockNum;i++)  //blockNum是已分配的块数
ffffffffc02005fa:	4781                	li	a5,0
ffffffffc02005fc:	a029                	j	ffffffffc0200606 <buddy_free_pages+0x54>
    if(rec[i].base==base)  
ffffffffc02005fe:	fe86b603          	ld	a2,-24(a3)
ffffffffc0200602:	16960963          	beq	a2,s1,ffffffffc0200774 <buddy_free_pages+0x1c2>
  for(i=0;i<blockNum;i++)  //blockNum是已分配的块数
ffffffffc0200606:	2785                	addiw	a5,a5,1
ffffffffc0200608:	06e1                	addi	a3,a3,24
ffffffffc020060a:	ff079ae3          	bne	a5,a6,ffffffffc02005fe <buddy_free_pages+0x4c>
  int offset=rec[i].offset;
ffffffffc020060e:	00181693          	slli	a3,a6,0x1
ffffffffc0200612:	010687b3          	add	a5,a3,a6
ffffffffc0200616:	078e                	slli	a5,a5,0x3
ffffffffc0200618:	97aa                	add	a5,a5,a0
ffffffffc020061a:	0087ae03          	lw	t3,8(a5)
  while(i<offset)
ffffffffc020061e:	01c05763          	blez	t3,ffffffffc020062c <buddy_free_pages+0x7a>
  i=0;
ffffffffc0200622:	4601                	li	a2,0
    i++;     //根据该分配块的偏移记录信息，可以找到双链表中对应的page
ffffffffc0200624:	2605                	addiw	a2,a2,1
ffffffffc0200626:	6718                	ld	a4,8(a4)
  while(i<offset)
ffffffffc0200628:	fece1ee3          	bne	t3,a2,ffffffffc0200624 <buddy_free_pages+0x72>
  if(!IS_POWER_OF_2(n))
ffffffffc020062c:	499c                	lw	a5,16(a1)
ffffffffc020062e:	10041763          	bnez	s0,ffffffffc020073c <buddy_free_pages+0x18a>
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200632:	2785                	addiw	a5,a5,1
ffffffffc0200634:	000a1617          	auipc	a2,0xa1
ffffffffc0200638:	20f62e23          	sw	a5,540(a2) # ffffffffc02a1850 <free_area+0x10>
  int i=1;
ffffffffc020063c:	4605                	li	a2,1
ffffffffc020063e:	4581                	li	a1,0
     p->property=1;
ffffffffc0200640:	4305                	li	t1,1
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200642:	4789                	li	a5,2
     p->flags=0;
ffffffffc0200644:	fe073823          	sd	zero,-16(a4)
     p->property=1;
ffffffffc0200648:	fe672c23          	sw	t1,-8(a4)
ffffffffc020064c:	ff070413          	addi	s0,a4,-16
ffffffffc0200650:	40f4302f          	amoor.d	zero,a5,(s0)
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc0200654:	2585                	addiw	a1,a1,1
ffffffffc0200656:	6718                	ld	a4,8(a4)
ffffffffc0200658:	fec5c6e3          	blt	a1,a2,ffffffffc0200644 <buddy_free_pages+0x92>
  index = offset + buddy[0].size - 1;   //从原始的分配节点的最底节点开始改变longest
ffffffffc020065c:	00005597          	auipc	a1,0x5
ffffffffc0200660:	de458593          	addi	a1,a1,-540 # ffffffffc0205440 <buddy>
ffffffffc0200664:	419c                	lw	a5,0(a1)
  buddy[index].longest[0] = node_size;   //这里应该是node_size，也就是从1那层开始改变
ffffffffc0200666:	4605                	li	a2,1
  node_size = 1;
ffffffffc0200668:	4305                	li	t1,1
  index = offset + buddy[0].size - 1;   //从原始的分配节点的最底节点开始改变longest
ffffffffc020066a:	37fd                	addiw	a5,a5,-1
ffffffffc020066c:	01c787bb          	addw	a5,a5,t3
  buddy[index].longest[0] = node_size;   //这里应该是node_size，也就是从1那层开始改变
ffffffffc0200670:	02079713          	slli	a4,a5,0x20
ffffffffc0200674:	8375                	srli	a4,a4,0x1d
ffffffffc0200676:	972e                	add	a4,a4,a1
ffffffffc0200678:	c350                	sw	a2,4(a4)
  while (index) {//向上合并，修改父节点的记录值
ffffffffc020067a:	cba1                	beqz	a5,ffffffffc02006ca <buddy_free_pages+0x118>
    index = PARENT(index);
ffffffffc020067c:	2785                	addiw	a5,a5,1
ffffffffc020067e:	0017d61b          	srliw	a2,a5,0x1
ffffffffc0200682:	367d                	addiw	a2,a2,-1
    left_longest = buddy[LEFT_LEAF(index)].longest[0];
ffffffffc0200684:	0016171b          	slliw	a4,a2,0x1
ffffffffc0200688:	2705                	addiw	a4,a4,1
    right_longest = buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc020068a:	9bf9                	andi	a5,a5,-2
    left_longest = buddy[LEFT_LEAF(index)].longest[0];
ffffffffc020068c:	1702                	slli	a4,a4,0x20
    right_longest = buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc020068e:	1782                	slli	a5,a5,0x20
    left_longest = buddy[LEFT_LEAF(index)].longest[0];
ffffffffc0200690:	9301                	srli	a4,a4,0x20
    right_longest = buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc0200692:	9381                	srli	a5,a5,0x20
    left_longest = buddy[LEFT_LEAF(index)].longest[0];
ffffffffc0200694:	070e                	slli	a4,a4,0x3
    right_longest = buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc0200696:	078e                	slli	a5,a5,0x3
    left_longest = buddy[LEFT_LEAF(index)].longest[0];
ffffffffc0200698:	972e                	add	a4,a4,a1
    right_longest = buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc020069a:	97ae                	add	a5,a5,a1
    left_longest = buddy[LEFT_LEAF(index)].longest[0];
ffffffffc020069c:	00472e03          	lw	t3,4(a4)
    right_longest = buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc02006a0:	0047ae83          	lw	t4,4(a5)
      buddy[index].longest[0] = MAX(left_longest, right_longest);
ffffffffc02006a4:	02061713          	slli	a4,a2,0x20
ffffffffc02006a8:	9301                	srli	a4,a4,0x20
    node_size *= 2;
ffffffffc02006aa:	0013131b          	slliw	t1,t1,0x1
    if (left_longest + right_longest == node_size) 
ffffffffc02006ae:	01de0fbb          	addw	t6,t3,t4
      buddy[index].longest[0] = MAX(left_longest, right_longest);
ffffffffc02006b2:	070e                	slli	a4,a4,0x3
    index = PARENT(index);
ffffffffc02006b4:	0006079b          	sext.w	a5,a2
    if (left_longest + right_longest == node_size) 
ffffffffc02006b8:	066f8c63          	beq	t6,t1,ffffffffc0200730 <buddy_free_pages+0x17e>
      buddy[index].longest[0] = MAX(left_longest, right_longest);
ffffffffc02006bc:	8672                	mv	a2,t3
ffffffffc02006be:	972e                	add	a4,a4,a1
ffffffffc02006c0:	01de7363          	bleu	t4,t3,ffffffffc02006c6 <buddy_free_pages+0x114>
ffffffffc02006c4:	8676                	mv	a2,t4
ffffffffc02006c6:	c350                	sw	a2,4(a4)
  while (index) {//向上合并，修改父节点的记录值
ffffffffc02006c8:	fbd5                	bnez	a5,ffffffffc020067c <buddy_free_pages+0xca>
  for(i=pos;i<blockNum-1;i++)//清除此次的分配记录，即从分配数组里面把后面的数据往前挪
ffffffffc02006ca:	0008a783          	lw	a5,0(a7)
ffffffffc02006ce:	fff7871b          	addiw	a4,a5,-1
ffffffffc02006d2:	88ba                	mv	a7,a4
ffffffffc02006d4:	04e85063          	ble	a4,a6,ffffffffc0200714 <buddy_free_pages+0x162>
ffffffffc02006d8:	ffe7859b          	addiw	a1,a5,-2
ffffffffc02006dc:	410585bb          	subw	a1,a1,a6
ffffffffc02006e0:	1582                	slli	a1,a1,0x20
ffffffffc02006e2:	9181                	srli	a1,a1,0x20
ffffffffc02006e4:	01058733          	add	a4,a1,a6
ffffffffc02006e8:	00171593          	slli	a1,a4,0x1
ffffffffc02006ec:	95ba                	add	a1,a1,a4
ffffffffc02006ee:	010687b3          	add	a5,a3,a6
ffffffffc02006f2:	078e                	slli	a5,a5,0x3
ffffffffc02006f4:	058e                	slli	a1,a1,0x3
ffffffffc02006f6:	000a1717          	auipc	a4,0xa1
ffffffffc02006fa:	17a70713          	addi	a4,a4,378 # ffffffffc02a1870 <rec+0x18>
ffffffffc02006fe:	97aa                	add	a5,a5,a0
ffffffffc0200700:	95ba                	add	a1,a1,a4
    rec[i]=rec[i+1];
ffffffffc0200702:	6f90                	ld	a2,24(a5)
ffffffffc0200704:	7394                	ld	a3,32(a5)
ffffffffc0200706:	7798                	ld	a4,40(a5)
ffffffffc0200708:	e390                	sd	a2,0(a5)
ffffffffc020070a:	e794                	sd	a3,8(a5)
ffffffffc020070c:	eb98                	sd	a4,16(a5)
ffffffffc020070e:	07e1                	addi	a5,a5,24
  for(i=pos;i<blockNum-1;i++)//清除此次的分配记录，即从分配数组里面把后面的数据往前挪
ffffffffc0200710:	fef599e3          	bne	a1,a5,ffffffffc0200702 <buddy_free_pages+0x150>
}
ffffffffc0200714:	6442                	ld	s0,16(sp)
ffffffffc0200716:	60e2                	ld	ra,24(sp)
ffffffffc0200718:	64a2                	ld	s1,8(sp)
  blockNum--;//更新分配块数的值
ffffffffc020071a:	00005797          	auipc	a5,0x5
ffffffffc020071e:	d117af23          	sw	a7,-738(a5) # ffffffffc0205438 <blockNum>
  cprintf("free_page succeed\n");
ffffffffc0200722:	00001517          	auipc	a0,0x1
ffffffffc0200726:	40e50513          	addi	a0,a0,1038 # ffffffffc0201b30 <commands+0x3d0>
}
ffffffffc020072a:	6105                	addi	sp,sp,32
  cprintf("free_page succeed\n");
ffffffffc020072c:	98bff06f          	j	ffffffffc02000b6 <cprintf>
      buddy[index].longest[0] = node_size;
ffffffffc0200730:	00e58633          	add	a2,a1,a4
ffffffffc0200734:	00662223          	sw	t1,4(a2)
  while (index) {//向上合并，修改父节点的记录值
ffffffffc0200738:	f3b1                	bnez	a5,ffffffffc020067c <buddy_free_pages+0xca>
ffffffffc020073a:	bf41                	j	ffffffffc02006ca <buddy_free_pages+0x118>
  if(!IS_POWER_OF_2(n))
ffffffffc020073c:	fff40613          	addi	a2,s0,-1
ffffffffc0200740:	8e61                	and	a2,a2,s0
ffffffffc0200742:	0004059b          	sext.w	a1,s0
ffffffffc0200746:	ce11                	beqz	a2,ffffffffc0200762 <buddy_free_pages+0x1b0>
  int i=1;
ffffffffc0200748:	4605                	li	a2,1
  for(;i<size;i*=2);
ffffffffc020074a:	eeb674e3          	bleu	a1,a2,ffffffffc0200632 <buddy_free_pages+0x80>
ffffffffc020074e:	0016161b          	slliw	a2,a2,0x1
ffffffffc0200752:	feb66ee3          	bltu	a2,a1,ffffffffc020074e <buddy_free_pages+0x19c>
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200756:	9fb1                	addw	a5,a5,a2
ffffffffc0200758:	000a1597          	auipc	a1,0xa1
ffffffffc020075c:	0ef5ac23          	sw	a5,248(a1) # ffffffffc02a1850 <free_area+0x10>
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc0200760:	bdf9                	j	ffffffffc020063e <buddy_free_pages+0x8c>
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200762:	9fad                	addw	a5,a5,a1
     allocpages=n;
ffffffffc0200764:	862e                	mv	a2,a1
  nr_free+=allocpages;//更新空闲页的数量
ffffffffc0200766:	000a1597          	auipc	a1,0xa1
ffffffffc020076a:	0ef5a523          	sw	a5,234(a1) # ffffffffc02a1850 <free_area+0x10>
  for(i=0;i<allocpages;i++)//回收已分配的页
ffffffffc020076e:	ecc048e3          	bgtz	a2,ffffffffc020063e <buddy_free_pages+0x8c>
ffffffffc0200772:	b5ed                	j	ffffffffc020065c <buddy_free_pages+0xaa>
  for(i=0;i<blockNum;i++)  //blockNum是已分配的块数
ffffffffc0200774:	883e                	mv	a6,a5
ffffffffc0200776:	bd61                	j	ffffffffc020060e <buddy_free_pages+0x5c>
ffffffffc0200778:	4801                	li	a6,0
ffffffffc020077a:	000a1517          	auipc	a0,0xa1
ffffffffc020077e:	0de50513          	addi	a0,a0,222 # ffffffffc02a1858 <rec>
ffffffffc0200782:	b571                	j	ffffffffc020060e <buddy_free_pages+0x5c>
ffffffffc0200784:	4801                	li	a6,0
ffffffffc0200786:	b561                	j	ffffffffc020060e <buddy_free_pages+0x5c>

ffffffffc0200788 <show_buddy_array.constprop.4>:
show_buddy_array(int total_mem) {
ffffffffc0200788:	715d                	addi	sp,sp,-80
    cprintf("Print buddy:\n");
ffffffffc020078a:	00001517          	auipc	a0,0x1
ffffffffc020078e:	47650513          	addi	a0,a0,1142 # ffffffffc0201c00 <buddy_system_pmm_manager+0x38>
show_buddy_array(int total_mem) {
ffffffffc0200792:	f84a                	sd	s2,48(sp)
ffffffffc0200794:	f052                	sd	s4,32(sp)
ffffffffc0200796:	ec56                	sd	s5,24(sp)
ffffffffc0200798:	e85a                	sd	s6,16(sp)
ffffffffc020079a:	e45e                	sd	s7,8(sp)
ffffffffc020079c:	e062                	sd	s8,0(sp)
ffffffffc020079e:	e486                	sd	ra,72(sp)
ffffffffc02007a0:	e0a2                	sd	s0,64(sp)
ffffffffc02007a2:	fc26                	sd	s1,56(sp)
ffffffffc02007a4:	f44e                	sd	s3,40(sp)
    int i=0;
ffffffffc02007a6:	4c01                	li	s8,0
    cprintf("Print buddy:\n");
ffffffffc02007a8:	90fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while ((i<total_mem*2-1))
ffffffffc02007ac:	00005b97          	auipc	s7,0x5
ffffffffc02007b0:	c94b8b93          	addi	s7,s7,-876 # ffffffffc0205440 <buddy>
ffffffffc02007b4:	00005b17          	auipc	s6,0x5
ffffffffc02007b8:	c98b0b13          	addi	s6,s6,-872 # ffffffffc020544c <buddy+0xc>
        cprintf("%u ",buddy[i].longest[0]);
ffffffffc02007bc:	00001917          	auipc	s2,0x1
ffffffffc02007c0:	45490913          	addi	s2,s2,1108 # ffffffffc0201c10 <buddy_system_pmm_manager+0x48>
      cprintf("\n");
ffffffffc02007c4:	00001a97          	auipc	s5,0x1
ffffffffc02007c8:	f94a8a93          	addi	s5,s5,-108 # ffffffffc0201758 <etext+0x13c>
    while ((i<total_mem*2-1))
ffffffffc02007cc:	4a79                	li	s4,30
      int temp=2*i+1;
ffffffffc02007ce:	001c179b          	slliw	a5,s8,0x1
ffffffffc02007d2:	89be                	mv	s3,a5
      for(;i<temp;i++)
ffffffffc02007d4:	0387c663          	blt	a5,s8,ffffffffc0200800 <show_buddy_array.constprop.4+0x78>
ffffffffc02007d8:	418784bb          	subw	s1,a5,s8
ffffffffc02007dc:	1482                	slli	s1,s1,0x20
ffffffffc02007de:	9081                	srli	s1,s1,0x20
ffffffffc02007e0:	003c1413          	slli	s0,s8,0x3
ffffffffc02007e4:	94e2                	add	s1,s1,s8
ffffffffc02007e6:	0411                	addi	s0,s0,4
ffffffffc02007e8:	048e                	slli	s1,s1,0x3
ffffffffc02007ea:	945e                	add	s0,s0,s7
ffffffffc02007ec:	94da                	add	s1,s1,s6
        cprintf("%u ",buddy[i].longest[0]);
ffffffffc02007ee:	400c                	lw	a1,0(s0)
ffffffffc02007f0:	854a                	mv	a0,s2
ffffffffc02007f2:	0421                	addi	s0,s0,8
ffffffffc02007f4:	8c3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
      for(;i<temp;i++)
ffffffffc02007f8:	fe941be3          	bne	s0,s1,ffffffffc02007ee <show_buddy_array.constprop.4+0x66>
ffffffffc02007fc:	00198c1b          	addiw	s8,s3,1
      cprintf("\n");
ffffffffc0200800:	8556                	mv	a0,s5
ffffffffc0200802:	8b5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while ((i<total_mem*2-1))
ffffffffc0200806:	fd8a54e3          	ble	s8,s4,ffffffffc02007ce <show_buddy_array.constprop.4+0x46>
}
ffffffffc020080a:	6406                	ld	s0,64(sp)
ffffffffc020080c:	60a6                	ld	ra,72(sp)
ffffffffc020080e:	74e2                	ld	s1,56(sp)
ffffffffc0200810:	7942                	ld	s2,48(sp)
ffffffffc0200812:	79a2                	ld	s3,40(sp)
ffffffffc0200814:	7a02                	ld	s4,32(sp)
ffffffffc0200816:	6ae2                	ld	s5,24(sp)
ffffffffc0200818:	6b42                	ld	s6,16(sp)
ffffffffc020081a:	6ba2                	ld	s7,8(sp)
ffffffffc020081c:	6c02                	ld	s8,0(sp)
    cprintf("---------------------------\n");
ffffffffc020081e:	00001517          	auipc	a0,0x1
ffffffffc0200822:	3fa50513          	addi	a0,a0,1018 # ffffffffc0201c18 <buddy_system_pmm_manager+0x50>
}
ffffffffc0200826:	6161                	addi	sp,sp,80
    cprintf("---------------------------\n");
ffffffffc0200828:	88fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020082c <buddy_check>:
//    //show_buddy_array(16);
// }


static void
buddy_check(void) {
ffffffffc020082c:	7179                	addi	sp,sp,-48
  
    struct Page  *A, *B, *C , *D;
    A = B =C = D =NULL;

    assert((A = alloc_page()) != NULL);
ffffffffc020082e:	4505                	li	a0,1
buddy_check(void) {
ffffffffc0200830:	f406                	sd	ra,40(sp)
ffffffffc0200832:	f022                	sd	s0,32(sp)
ffffffffc0200834:	ec26                	sd	s1,24(sp)
ffffffffc0200836:	e84a                	sd	s2,16(sp)
ffffffffc0200838:	e44e                	sd	s3,8(sp)
    assert((A = alloc_page()) != NULL);
ffffffffc020083a:	620000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020083e:	12050e63          	beqz	a0,ffffffffc020097a <buddy_check+0x14e>
ffffffffc0200842:	842a                	mv	s0,a0
    assert((B = alloc_page()) != NULL);
ffffffffc0200844:	4505                	li	a0,1
ffffffffc0200846:	614000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020084a:	84aa                	mv	s1,a0
ffffffffc020084c:	14050763          	beqz	a0,ffffffffc020099a <buddy_check+0x16e>
    assert((C = alloc_page()) != NULL);
ffffffffc0200850:	4505                	li	a0,1
ffffffffc0200852:	608000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0200856:	892a                	mv	s2,a0
ffffffffc0200858:	16050163          	beqz	a0,ffffffffc02009ba <buddy_check+0x18e>
    assert((D = alloc_page()) != NULL);
ffffffffc020085c:	4505                	li	a0,1
ffffffffc020085e:	5fc000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0200862:	89aa                	mv	s3,a0
ffffffffc0200864:	16050b63          	beqz	a0,ffffffffc02009da <buddy_check+0x1ae>

    assert( A != B && B!= C && C!=D && D!=A);
ffffffffc0200868:	0c940963          	beq	s0,s1,ffffffffc020093a <buddy_check+0x10e>
ffffffffc020086c:	0d248763          	beq	s1,s2,ffffffffc020093a <buddy_check+0x10e>
ffffffffc0200870:	0ca90563          	beq	s2,a0,ffffffffc020093a <buddy_check+0x10e>
ffffffffc0200874:	0ca40363          	beq	s0,a0,ffffffffc020093a <buddy_check+0x10e>
    assert(page_ref(A) == 0 && page_ref(B) == 0 && page_ref(C) == 0 && page_ref(D) == 0);
ffffffffc0200878:	401c                	lw	a5,0(s0)
ffffffffc020087a:	0e079063          	bnez	a5,ffffffffc020095a <buddy_check+0x12e>
ffffffffc020087e:	409c                	lw	a5,0(s1)
ffffffffc0200880:	0c079d63          	bnez	a5,ffffffffc020095a <buddy_check+0x12e>
ffffffffc0200884:	00092783          	lw	a5,0(s2)
ffffffffc0200888:	0c079963          	bnez	a5,ffffffffc020095a <buddy_check+0x12e>
ffffffffc020088c:	411c                	lw	a5,0(a0)
ffffffffc020088e:	0c079663          	bnez	a5,ffffffffc020095a <buddy_check+0x12e>
  
    free_page(A);
ffffffffc0200892:	8522                	mv	a0,s0
ffffffffc0200894:	4585                	li	a1,1
ffffffffc0200896:	608000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    free_page(B);
ffffffffc020089a:	8526                	mv	a0,s1
ffffffffc020089c:	4585                	li	a1,1
ffffffffc020089e:	600000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    free_page(C);
ffffffffc02008a2:	854a                	mv	a0,s2
ffffffffc02008a4:	4585                	li	a1,1
ffffffffc02008a6:	5f8000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    free_page(D);
ffffffffc02008aa:	4585                	li	a1,1
ffffffffc02008ac:	854e                	mv	a0,s3
ffffffffc02008ae:	5f0000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    
    
    cprintf("*******************************Check begin***************************\n");
ffffffffc02008b2:	00001517          	auipc	a0,0x1
ffffffffc02008b6:	1de50513          	addi	a0,a0,478 # ffffffffc0201a90 <commands+0x330>
ffffffffc02008ba:	ffcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    show_buddy_array(16);
ffffffffc02008be:	ecbff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    A=alloc_pages(3);
ffffffffc02008c2:	450d                	li	a0,3
ffffffffc02008c4:	596000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02008c8:	84aa                	mv	s1,a0
    show_buddy_array(16);
ffffffffc02008ca:	ebfff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    B=alloc_pages(5);
ffffffffc02008ce:	4515                	li	a0,5
ffffffffc02008d0:	58a000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02008d4:	842a                	mv	s0,a0
    show_buddy_array(16);
ffffffffc02008d6:	eb3ff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    C=alloc_pages(1);
ffffffffc02008da:	4505                	li	a0,1
ffffffffc02008dc:	57e000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02008e0:	89aa                	mv	s3,a0
    show_buddy_array(16);
ffffffffc02008e2:	ea7ff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    D=alloc_pages(2);
ffffffffc02008e6:	4509                	li	a0,2
ffffffffc02008e8:	572000ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02008ec:	892a                	mv	s2,a0
    show_buddy_array(16);
ffffffffc02008ee:	e9bff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
   // C=alloc_pages(8);
    //show_buddy_array(16);
    //cprintf("A %p\n",A);
    //cprintf("B %p\n",B);
    free_page(C);
ffffffffc02008f2:	854e                	mv	a0,s3
ffffffffc02008f4:	4585                	li	a1,1
ffffffffc02008f6:	5a8000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    show_buddy_array(16);
ffffffffc02008fa:	e8fff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    free_page(D);
ffffffffc02008fe:	854a                	mv	a0,s2
ffffffffc0200900:	4585                	li	a1,1
ffffffffc0200902:	59c000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    show_buddy_array(16);
ffffffffc0200906:	e83ff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    free_page(A);
ffffffffc020090a:	8526                	mv	a0,s1
ffffffffc020090c:	4585                	li	a1,1
ffffffffc020090e:	590000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    show_buddy_array(16);
ffffffffc0200912:	e77ff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    free_page(B);
ffffffffc0200916:	8522                	mv	a0,s0
ffffffffc0200918:	4585                	li	a1,1
ffffffffc020091a:	584000ef          	jal	ra,ffffffffc0200e9e <free_pages>
    show_buddy_array(16);
ffffffffc020091e:	e6bff0ef          	jal	ra,ffffffffc0200788 <show_buddy_array.constprop.4>
    cprintf("********************************Check End****************************\n");
}
ffffffffc0200922:	7402                	ld	s0,32(sp)
ffffffffc0200924:	70a2                	ld	ra,40(sp)
ffffffffc0200926:	64e2                	ld	s1,24(sp)
ffffffffc0200928:	6942                	ld	s2,16(sp)
ffffffffc020092a:	69a2                	ld	s3,8(sp)
    cprintf("********************************Check End****************************\n");
ffffffffc020092c:	00001517          	auipc	a0,0x1
ffffffffc0200930:	1ac50513          	addi	a0,a0,428 # ffffffffc0201ad8 <commands+0x378>
}
ffffffffc0200934:	6145                	addi	sp,sp,48
    cprintf("********************************Check End****************************\n");
ffffffffc0200936:	f80ff06f          	j	ffffffffc02000b6 <cprintf>
    assert( A != B && B!= C && C!=D && D!=A);
ffffffffc020093a:	00001697          	auipc	a3,0x1
ffffffffc020093e:	0e668693          	addi	a3,a3,230 # ffffffffc0201a20 <commands+0x2c0>
ffffffffc0200942:	00001617          	auipc	a2,0x1
ffffffffc0200946:	04660613          	addi	a2,a2,70 # ffffffffc0201988 <commands+0x228>
ffffffffc020094a:	14a00593          	li	a1,330
ffffffffc020094e:	00001517          	auipc	a0,0x1
ffffffffc0200952:	05250513          	addi	a0,a0,82 # ffffffffc02019a0 <commands+0x240>
ffffffffc0200956:	fe8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page_ref(A) == 0 && page_ref(B) == 0 && page_ref(C) == 0 && page_ref(D) == 0);
ffffffffc020095a:	00001697          	auipc	a3,0x1
ffffffffc020095e:	0e668693          	addi	a3,a3,230 # ffffffffc0201a40 <commands+0x2e0>
ffffffffc0200962:	00001617          	auipc	a2,0x1
ffffffffc0200966:	02660613          	addi	a2,a2,38 # ffffffffc0201988 <commands+0x228>
ffffffffc020096a:	14b00593          	li	a1,331
ffffffffc020096e:	00001517          	auipc	a0,0x1
ffffffffc0200972:	03250513          	addi	a0,a0,50 # ffffffffc02019a0 <commands+0x240>
ffffffffc0200976:	fc8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((A = alloc_page()) != NULL);
ffffffffc020097a:	00001697          	auipc	a3,0x1
ffffffffc020097e:	fee68693          	addi	a3,a3,-18 # ffffffffc0201968 <commands+0x208>
ffffffffc0200982:	00001617          	auipc	a2,0x1
ffffffffc0200986:	00660613          	addi	a2,a2,6 # ffffffffc0201988 <commands+0x228>
ffffffffc020098a:	14500593          	li	a1,325
ffffffffc020098e:	00001517          	auipc	a0,0x1
ffffffffc0200992:	01250513          	addi	a0,a0,18 # ffffffffc02019a0 <commands+0x240>
ffffffffc0200996:	fa8ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((B = alloc_page()) != NULL);
ffffffffc020099a:	00001697          	auipc	a3,0x1
ffffffffc020099e:	02668693          	addi	a3,a3,38 # ffffffffc02019c0 <commands+0x260>
ffffffffc02009a2:	00001617          	auipc	a2,0x1
ffffffffc02009a6:	fe660613          	addi	a2,a2,-26 # ffffffffc0201988 <commands+0x228>
ffffffffc02009aa:	14600593          	li	a1,326
ffffffffc02009ae:	00001517          	auipc	a0,0x1
ffffffffc02009b2:	ff250513          	addi	a0,a0,-14 # ffffffffc02019a0 <commands+0x240>
ffffffffc02009b6:	f88ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((C = alloc_page()) != NULL);
ffffffffc02009ba:	00001697          	auipc	a3,0x1
ffffffffc02009be:	02668693          	addi	a3,a3,38 # ffffffffc02019e0 <commands+0x280>
ffffffffc02009c2:	00001617          	auipc	a2,0x1
ffffffffc02009c6:	fc660613          	addi	a2,a2,-58 # ffffffffc0201988 <commands+0x228>
ffffffffc02009ca:	14700593          	li	a1,327
ffffffffc02009ce:	00001517          	auipc	a0,0x1
ffffffffc02009d2:	fd250513          	addi	a0,a0,-46 # ffffffffc02019a0 <commands+0x240>
ffffffffc02009d6:	f68ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((D = alloc_page()) != NULL);
ffffffffc02009da:	00001697          	auipc	a3,0x1
ffffffffc02009de:	02668693          	addi	a3,a3,38 # ffffffffc0201a00 <commands+0x2a0>
ffffffffc02009e2:	00001617          	auipc	a2,0x1
ffffffffc02009e6:	fa660613          	addi	a2,a2,-90 # ffffffffc0201988 <commands+0x228>
ffffffffc02009ea:	14800593          	li	a1,328
ffffffffc02009ee:	00001517          	auipc	a0,0x1
ffffffffc02009f2:	fb250513          	addi	a0,a0,-78 # ffffffffc02019a0 <commands+0x240>
ffffffffc02009f6:	f48ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02009fa <buddy_new_tree>:
{
ffffffffc02009fa:	1101                	addi	sp,sp,-32
ffffffffc02009fc:	e426                	sd	s1,8(sp)
ffffffffc02009fe:	84aa                	mv	s1,a0
   cprintf("new_tree\n");
ffffffffc0200a00:	00001517          	auipc	a0,0x1
ffffffffc0200a04:	19850513          	addi	a0,a0,408 # ffffffffc0201b98 <commands+0x438>
{
ffffffffc0200a08:	ec06                	sd	ra,24(sp)
ffffffffc0200a0a:	e822                	sd	s0,16(sp)
   cprintf("new_tree\n");
ffffffffc0200a0c:	eaaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if(size<1||!IS_POWER_OF_2(size))
ffffffffc0200a10:	00905763          	blez	s1,ffffffffc0200a1e <buddy_new_tree+0x24>
ffffffffc0200a14:	fff4841b          	addiw	s0,s1,-1
ffffffffc0200a18:	8c65                	and	s0,s0,s1
ffffffffc0200a1a:	2401                	sext.w	s0,s0
ffffffffc0200a1c:	c411                	beqz	s0,ffffffffc0200a28 <buddy_new_tree+0x2e>
}
ffffffffc0200a1e:	60e2                	ld	ra,24(sp)
ffffffffc0200a20:	6442                	ld	s0,16(sp)
ffffffffc0200a22:	64a2                	ld	s1,8(sp)
ffffffffc0200a24:	6105                	addi	sp,sp,32
ffffffffc0200a26:	8082                	ret
    cprintf("%d\n",size);
ffffffffc0200a28:	85a6                	mv	a1,s1
ffffffffc0200a2a:	00001517          	auipc	a0,0x1
ffffffffc0200a2e:	17e50513          	addi	a0,a0,382 # ffffffffc0201ba8 <commands+0x448>
ffffffffc0200a32:	e84ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    node_size=size*2;
ffffffffc0200a36:	0014969b          	slliw	a3,s1,0x1
    buddy[0].size=size;
ffffffffc0200a3a:	00005797          	auipc	a5,0x5
ffffffffc0200a3e:	a097a323          	sw	s1,-1530(a5) # ffffffffc0205440 <buddy>
    for(int i=0;i<2*size-1;++i)
ffffffffc0200a42:	00005797          	auipc	a5,0x5
ffffffffc0200a46:	a0278793          	addi	a5,a5,-1534 # ffffffffc0205444 <buddy+0x4>
ffffffffc0200a4a:	fff6861b          	addiw	a2,a3,-1
        if(IS_POWER_OF_2(i+1))
ffffffffc0200a4e:	0014071b          	addiw	a4,s0,1
ffffffffc0200a52:	8c79                	and	s0,s0,a4
ffffffffc0200a54:	e019                	bnez	s0,ffffffffc0200a5a <buddy_new_tree+0x60>
            node_size/=2;
ffffffffc0200a56:	0016d69b          	srliw	a3,a3,0x1
        buddy[i].longest[0]=node_size;// 初始化咧
ffffffffc0200a5a:	c394                	sw	a3,0(a5)
ffffffffc0200a5c:	843a                	mv	s0,a4
ffffffffc0200a5e:	07a1                	addi	a5,a5,8
    for(int i=0;i<2*size-1;++i)
ffffffffc0200a60:	fec717e3          	bne	a4,a2,ffffffffc0200a4e <buddy_new_tree+0x54>
}
ffffffffc0200a64:	6442                	ld	s0,16(sp)
ffffffffc0200a66:	60e2                	ld	ra,24(sp)
ffffffffc0200a68:	64a2                	ld	s1,8(sp)
   cprintf("new_tree succeed\n");
ffffffffc0200a6a:	00001517          	auipc	a0,0x1
ffffffffc0200a6e:	14650513          	addi	a0,a0,326 # ffffffffc0201bb0 <commands+0x450>
}
ffffffffc0200a72:	6105                	addi	sp,sp,32
   cprintf("new_tree succeed\n");
ffffffffc0200a74:	e42ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200a78 <buddy_init_memmap>:
{
ffffffffc0200a78:	1101                	addi	sp,sp,-32
ffffffffc0200a7a:	e822                	sd	s0,16(sp)
ffffffffc0200a7c:	e04a                	sd	s2,0(sp)
ffffffffc0200a7e:	842a                	mv	s0,a0
ffffffffc0200a80:	892e                	mv	s2,a1
    cprintf("initmmp\n");
ffffffffc0200a82:	00001517          	auipc	a0,0x1
ffffffffc0200a86:	0c650513          	addi	a0,a0,198 # ffffffffc0201b48 <commands+0x3e8>
{
ffffffffc0200a8a:	ec06                	sd	ra,24(sp)
ffffffffc0200a8c:	e426                	sd	s1,8(sp)
    cprintf("initmmp\n");
ffffffffc0200a8e:	e28ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(n>0);
ffffffffc0200a92:	0e090263          	beqz	s2,ffffffffc0200b76 <buddy_init_memmap+0xfe>
    for(;p!=base+n;p++)
ffffffffc0200a96:	00291613          	slli	a2,s2,0x2
ffffffffc0200a9a:	964a                	add	a2,a2,s2
ffffffffc0200a9c:	060e                	slli	a2,a2,0x3
     blockNum=0;//分配块数设置为0
ffffffffc0200a9e:	00005797          	auipc	a5,0x5
ffffffffc0200aa2:	9807ad23          	sw	zero,-1638(a5) # ffffffffc0205438 <blockNum>
    for(;p!=base+n;p++)
ffffffffc0200aa6:	9622                	add	a2,a2,s0
ffffffffc0200aa8:	0ac40263          	beq	s0,a2,ffffffffc0200b4c <buddy_init_memmap+0xd4>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200aac:	641c                	ld	a5,8(s0)
        assert(PageReserved(p));//检查是否被引用过
ffffffffc0200aae:	8b85                	andi	a5,a5,1
ffffffffc0200ab0:	c3dd                	beqz	a5,ffffffffc0200b56 <buddy_init_memmap+0xde>
ffffffffc0200ab2:	000a1697          	auipc	a3,0xa1
ffffffffc0200ab6:	d8e68693          	addi	a3,a3,-626 # ffffffffc02a1840 <free_area>
        p->property=1;
ffffffffc0200aba:	4805                	li	a6,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200abc:	4509                	li	a0,2
ffffffffc0200abe:	a021                	j	ffffffffc0200ac6 <buddy_init_memmap+0x4e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ac0:	641c                	ld	a5,8(s0)
        assert(PageReserved(p));//检查是否被引用过
ffffffffc0200ac2:	8b85                	andi	a5,a5,1
ffffffffc0200ac4:	cbc9                	beqz	a5,ffffffffc0200b56 <buddy_init_memmap+0xde>
        p->flags=0;
ffffffffc0200ac6:	00043423          	sd	zero,8(s0)
        p->property=1;
ffffffffc0200aca:	01042823          	sw	a6,16(s0)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200ace:	00042023          	sw	zero,0(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ad2:	00840793          	addi	a5,s0,8
ffffffffc0200ad6:	40a7b02f          	amoor.d	zero,a0,(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200ada:	629c                	ld	a5,0(a3)
ffffffffc0200adc:	01840713          	addi	a4,s0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200ae0:	000a1597          	auipc	a1,0xa1
ffffffffc0200ae4:	d6e5b023          	sd	a4,-672(a1) # ffffffffc02a1840 <free_area>
ffffffffc0200ae8:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200aea:	f014                	sd	a3,32(s0)
    elm->prev = prev;
ffffffffc0200aec:	ec1c                	sd	a5,24(s0)
    for(;p!=base+n;p++)
ffffffffc0200aee:	02840413          	addi	s0,s0,40
ffffffffc0200af2:	fcc417e3          	bne	s0,a2,ffffffffc0200ac0 <buddy_init_memmap+0x48>
    nr_free+=n;//空闲页数+n
ffffffffc0200af6:	4a9c                	lw	a5,16(a3)
ffffffffc0200af8:	0009049b          	sext.w	s1,s2
  int i=1;
ffffffffc0200afc:	4405                	li	s0,1
    nr_free+=n;//空闲页数+n
ffffffffc0200afe:	9fa5                	addw	a5,a5,s1
    cprintf("n=%d\n",n);
ffffffffc0200b00:	85ca                	mv	a1,s2
ffffffffc0200b02:	00001517          	auipc	a0,0x1
ffffffffc0200b06:	05e50513          	addi	a0,a0,94 # ffffffffc0201b60 <commands+0x400>
    nr_free+=n;//空闲页数+n
ffffffffc0200b0a:	000a1717          	auipc	a4,0xa1
ffffffffc0200b0e:	d4f72323          	sw	a5,-698(a4) # ffffffffc02a1850 <free_area+0x10>
    cprintf("n=%d\n",n);
ffffffffc0200b12:	da4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
  for(;i<size;i*=2);
ffffffffc0200b16:	00947663          	bleu	s1,s0,ffffffffc0200b22 <buddy_init_memmap+0xaa>
ffffffffc0200b1a:	0014141b          	slliw	s0,s0,0x1
ffffffffc0200b1e:	fe946ee3          	bltu	s0,s1,ffffffffc0200b1a <buddy_init_memmap+0xa2>
    cprintf("fix=%d\n",allocpages);
ffffffffc0200b22:	85a2                	mv	a1,s0
ffffffffc0200b24:	00001517          	auipc	a0,0x1
ffffffffc0200b28:	05450513          	addi	a0,a0,84 # ffffffffc0201b78 <commands+0x418>
ffffffffc0200b2c:	d8aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    buddy_new_tree(allocpages);
ffffffffc0200b30:	8522                	mv	a0,s0
ffffffffc0200b32:	ec9ff0ef          	jal	ra,ffffffffc02009fa <buddy_new_tree>
}
ffffffffc0200b36:	6442                	ld	s0,16(sp)
ffffffffc0200b38:	60e2                	ld	ra,24(sp)
ffffffffc0200b3a:	64a2                	ld	s1,8(sp)
ffffffffc0200b3c:	6902                	ld	s2,0(sp)
    cprintf("init_mmp_succeed\n");
ffffffffc0200b3e:	00001517          	auipc	a0,0x1
ffffffffc0200b42:	04250513          	addi	a0,a0,66 # ffffffffc0201b80 <commands+0x420>
}
ffffffffc0200b46:	6105                	addi	sp,sp,32
    cprintf("init_mmp_succeed\n");
ffffffffc0200b48:	d6eff06f          	j	ffffffffc02000b6 <cprintf>
ffffffffc0200b4c:	000a1697          	auipc	a3,0xa1
ffffffffc0200b50:	cf468693          	addi	a3,a3,-780 # ffffffffc02a1840 <free_area>
ffffffffc0200b54:	b74d                	j	ffffffffc0200af6 <buddy_init_memmap+0x7e>
        assert(PageReserved(p));//检查是否被引用过
ffffffffc0200b56:	00001697          	auipc	a3,0x1
ffffffffc0200b5a:	01268693          	addi	a3,a3,18 # ffffffffc0201b68 <commands+0x408>
ffffffffc0200b5e:	00001617          	auipc	a2,0x1
ffffffffc0200b62:	e2a60613          	addi	a2,a2,-470 # ffffffffc0201988 <commands+0x228>
ffffffffc0200b66:	06500593          	li	a1,101
ffffffffc0200b6a:	00001517          	auipc	a0,0x1
ffffffffc0200b6e:	e3650513          	addi	a0,a0,-458 # ffffffffc02019a0 <commands+0x240>
ffffffffc0200b72:	dccff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n>0);
ffffffffc0200b76:	00001697          	auipc	a3,0x1
ffffffffc0200b7a:	fe268693          	addi	a3,a3,-30 # ffffffffc0201b58 <commands+0x3f8>
ffffffffc0200b7e:	00001617          	auipc	a2,0x1
ffffffffc0200b82:	e0a60613          	addi	a2,a2,-502 # ffffffffc0201988 <commands+0x228>
ffffffffc0200b86:	06000593          	li	a1,96
ffffffffc0200b8a:	00001517          	auipc	a0,0x1
ffffffffc0200b8e:	e1650513          	addi	a0,a0,-490 # ffffffffc02019a0 <commands+0x240>
ffffffffc0200b92:	dacff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200b96 <buddy_alloc>:
{
ffffffffc0200b96:	7139                	addi	sp,sp,-64
ffffffffc0200b98:	e05a                	sd	s6,0(sp)
ffffffffc0200b9a:	8b2a                	mv	s6,a0
  cprintf("buddy_alloc\n");
ffffffffc0200b9c:	00001517          	auipc	a0,0x1
ffffffffc0200ba0:	d7450513          	addi	a0,a0,-652 # ffffffffc0201910 <commands+0x1b0>
{
ffffffffc0200ba4:	f426                	sd	s1,40(sp)
ffffffffc0200ba6:	f04a                	sd	s2,32(sp)
ffffffffc0200ba8:	fc06                	sd	ra,56(sp)
ffffffffc0200baa:	f822                	sd	s0,48(sp)
ffffffffc0200bac:	ec4e                	sd	s3,24(sp)
ffffffffc0200bae:	e852                	sd	s4,16(sp)
ffffffffc0200bb0:	e456                	sd	s5,8(sp)
  if (buddy[index].longest[0]<size)
ffffffffc0200bb2:	00005497          	auipc	s1,0x5
ffffffffc0200bb6:	88e48493          	addi	s1,s1,-1906 # ffffffffc0205440 <buddy>
  cprintf("buddy_alloc\n");
ffffffffc0200bba:	cfcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
  if (buddy[index].longest[0]<size)
ffffffffc0200bbe:	40cc                	lw	a1,4(s1)
ffffffffc0200bc0:	000b091b          	sext.w	s2,s6
ffffffffc0200bc4:	1325e363          	bltu	a1,s2,ffffffffc0200cea <buddy_alloc+0x154>
  if (size <= 0)//分配不合理
ffffffffc0200bc8:	11605e63          	blez	s6,ffffffffc0200ce4 <buddy_alloc+0x14e>
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
ffffffffc0200bcc:	fffb079b          	addiw	a5,s6,-1
ffffffffc0200bd0:	00fb77b3          	and	a5,s6,a5
ffffffffc0200bd4:	2781                	sext.w	a5,a5
ffffffffc0200bd6:	efe9                	bnez	a5,ffffffffc0200cb0 <buddy_alloc+0x11a>
 cprintf("%d\n",size);
ffffffffc0200bd8:	85da                	mv	a1,s6
ffffffffc0200bda:	00001517          	auipc	a0,0x1
ffffffffc0200bde:	fce50513          	addi	a0,a0,-50 # ffffffffc0201ba8 <commands+0x448>
ffffffffc0200be2:	cd4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
 for (node_size=buddy[0].size; node_size!=size;node_size/=2)
ffffffffc0200be6:	0004aa83          	lw	s5,0(s1)
ffffffffc0200bea:	0f2a8763          	beq	s5,s2,ffffffffc0200cd8 <buddy_alloc+0x142>
    unsigned index=0;//
ffffffffc0200bee:	4401                	li	s0,0
     cprintf("buddy_alloc succeed\n");
ffffffffc0200bf0:	00001997          	auipc	s3,0x1
ffffffffc0200bf4:	d3898993          	addi	s3,s3,-712 # ffffffffc0201928 <commands+0x1c8>
     int left_longest=buddy[LEFT_LEAF(index)].longest[0];
ffffffffc0200bf8:	0014171b          	slliw	a4,s0,0x1
ffffffffc0200bfc:	0017041b          	addiw	s0,a4,1
ffffffffc0200c00:	02041793          	slli	a5,s0,0x20
ffffffffc0200c04:	83f5                	srli	a5,a5,0x1d
     int right_longest=buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc0200c06:	0027051b          	addiw	a0,a4,2
     int left_longest=buddy[LEFT_LEAF(index)].longest[0];
ffffffffc0200c0a:	97a6                	add	a5,a5,s1
ffffffffc0200c0c:	43d4                	lw	a3,4(a5)
     int right_longest=buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc0200c0e:	02051793          	slli	a5,a0,0x20
ffffffffc0200c12:	83f5                	srli	a5,a5,0x1d
ffffffffc0200c14:	97a6                	add	a5,a5,s1
ffffffffc0200c16:	00050a1b          	sext.w	s4,a0
ffffffffc0200c1a:	43dc                	lw	a5,4(a5)
     if(left_longest>=size)
ffffffffc0200c1c:	0166c763          	blt	a3,s6,ffffffffc0200c2a <buddy_alloc+0x94>
     int right_longest=buddy[RIGHT_LEAF(index)].longest[0];
ffffffffc0200c20:	2781                	sext.w	a5,a5
        if(right_longest>=size)
ffffffffc0200c22:	0167c763          	blt	a5,s6,ffffffffc0200c30 <buddy_alloc+0x9a>
            index=left_longest<=right_longest?LEFT_LEAF(index):RIGHT_LEAF(index);
ffffffffc0200c26:	00d7d563          	ble	a3,a5,ffffffffc0200c30 <buddy_alloc+0x9a>
ffffffffc0200c2a:	8452                	mv	s0,s4
ffffffffc0200c2c:	00370a1b          	addiw	s4,a4,3
 for (node_size=buddy[0].size; node_size!=size;node_size/=2)
ffffffffc0200c30:	001ada9b          	srliw	s5,s5,0x1
     cprintf("buddy_alloc succeed\n");
ffffffffc0200c34:	854e                	mv	a0,s3
ffffffffc0200c36:	c80ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
 for (node_size=buddy[0].size; node_size!=size;node_size/=2)
ffffffffc0200c3a:	fb2a9fe3          	bne	s5,s2,ffffffffc0200bf8 <buddy_alloc+0x62>
 offset=(index+1)*node_size-buddy[0].size;
ffffffffc0200c3e:	034a853b          	mulw	a0,s5,s4
 buddy[index].longest[0]=0;
ffffffffc0200c42:	02041793          	slli	a5,s0,0x20
ffffffffc0200c46:	83f5                	srli	a5,a5,0x1d
 offset=(index+1)*node_size-buddy[0].size;
ffffffffc0200c48:	0004aa03          	lw	s4,0(s1)
 buddy[index].longest[0]=0;
ffffffffc0200c4c:	97a6                	add	a5,a5,s1
ffffffffc0200c4e:	0007a223          	sw	zero,4(a5)
 while (index)
ffffffffc0200c52:	4145053b          	subw	a0,a0,s4
ffffffffc0200c56:	c039                	beqz	s0,ffffffffc0200c9c <buddy_alloc+0x106>
    index=PARENT(index);
ffffffffc0200c58:	2405                	addiw	s0,s0,1
ffffffffc0200c5a:	0014569b          	srliw	a3,s0,0x1
ffffffffc0200c5e:	36fd                	addiw	a3,a3,-1
    buddy[index].longest[0]=MAX(buddy[LEFT_LEAF(index)].longest[0], buddy[RIGHT_LEAF(index)].longest[0]);
ffffffffc0200c60:	0016971b          	slliw	a4,a3,0x1
ffffffffc0200c64:	ffe47793          	andi	a5,s0,-2
ffffffffc0200c68:	2705                	addiw	a4,a4,1
ffffffffc0200c6a:	1702                	slli	a4,a4,0x20
ffffffffc0200c6c:	1782                	slli	a5,a5,0x20
ffffffffc0200c6e:	9301                	srli	a4,a4,0x20
ffffffffc0200c70:	9381                	srli	a5,a5,0x20
ffffffffc0200c72:	070e                	slli	a4,a4,0x3
ffffffffc0200c74:	078e                	slli	a5,a5,0x3
ffffffffc0200c76:	97a6                	add	a5,a5,s1
ffffffffc0200c78:	9726                	add	a4,a4,s1
ffffffffc0200c7a:	43d0                	lw	a2,4(a5)
ffffffffc0200c7c:	4358                	lw	a4,4(a4)
ffffffffc0200c7e:	02069793          	slli	a5,a3,0x20
ffffffffc0200c82:	83f5                	srli	a5,a5,0x1d
ffffffffc0200c84:	0007081b          	sext.w	a6,a4
ffffffffc0200c88:	0006059b          	sext.w	a1,a2
    index=PARENT(index);
ffffffffc0200c8c:	0006841b          	sext.w	s0,a3
    buddy[index].longest[0]=MAX(buddy[LEFT_LEAF(index)].longest[0], buddy[RIGHT_LEAF(index)].longest[0]);
ffffffffc0200c90:	97a6                	add	a5,a5,s1
ffffffffc0200c92:	00b87363          	bleu	a1,a6,ffffffffc0200c98 <buddy_alloc+0x102>
ffffffffc0200c96:	8732                	mv	a4,a2
ffffffffc0200c98:	c3d8                	sw	a4,4(a5)
 while (index)
ffffffffc0200c9a:	fc5d                	bnez	s0,ffffffffc0200c58 <buddy_alloc+0xc2>
}
ffffffffc0200c9c:	70e2                	ld	ra,56(sp)
ffffffffc0200c9e:	7442                	ld	s0,48(sp)
ffffffffc0200ca0:	74a2                	ld	s1,40(sp)
ffffffffc0200ca2:	7902                	ld	s2,32(sp)
ffffffffc0200ca4:	69e2                	ld	s3,24(sp)
ffffffffc0200ca6:	6a42                	ld	s4,16(sp)
ffffffffc0200ca8:	6aa2                	ld	s5,8(sp)
ffffffffc0200caa:	6b02                	ld	s6,0(sp)
ffffffffc0200cac:	6121                	addi	sp,sp,64
ffffffffc0200cae:	8082                	ret
  for(;i<size;i*=2);
ffffffffc0200cb0:	4785                	li	a5,1
ffffffffc0200cb2:	0327f963          	bleu	s2,a5,ffffffffc0200ce4 <buddy_alloc+0x14e>
  int i=1;
ffffffffc0200cb6:	4b05                	li	s6,1
  for(;i<size;i*=2);
ffffffffc0200cb8:	001b1b1b          	slliw	s6,s6,0x1
ffffffffc0200cbc:	ff2b6ee3          	bltu	s6,s2,ffffffffc0200cb8 <buddy_alloc+0x122>
 cprintf("%d\n",size);
ffffffffc0200cc0:	85da                	mv	a1,s6
ffffffffc0200cc2:	00001517          	auipc	a0,0x1
ffffffffc0200cc6:	ee650513          	addi	a0,a0,-282 # ffffffffc0201ba8 <commands+0x448>
ffffffffc0200cca:	becff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
 for (node_size=buddy[0].size; node_size!=size;node_size/=2)
ffffffffc0200cce:	0004aa83          	lw	s5,0(s1)
  for(;i<size;i*=2);
ffffffffc0200cd2:	895a                	mv	s2,s6
 for (node_size=buddy[0].size; node_size!=size;node_size/=2)
ffffffffc0200cd4:	f12a9de3          	bne	s5,s2,ffffffffc0200bee <buddy_alloc+0x58>
 buddy[index].longest[0]=0;
ffffffffc0200cd8:	00004797          	auipc	a5,0x4
ffffffffc0200cdc:	7607a623          	sw	zero,1900(a5) # ffffffffc0205444 <buddy+0x4>
ffffffffc0200ce0:	4501                	li	a0,0
ffffffffc0200ce2:	bf6d                	j	ffffffffc0200c9c <buddy_alloc+0x106>
  for(;i<size;i*=2);
ffffffffc0200ce4:	4905                	li	s2,1
    size = 1;
ffffffffc0200ce6:	4b05                	li	s6,1
ffffffffc0200ce8:	bdc5                	j	ffffffffc0200bd8 <buddy_alloc+0x42>
    cprintf("%d",buddy[index].longest[0]);
ffffffffc0200cea:	00001517          	auipc	a0,0x1
ffffffffc0200cee:	c3650513          	addi	a0,a0,-970 # ffffffffc0201920 <commands+0x1c0>
ffffffffc0200cf2:	bc4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return -1;
ffffffffc0200cf6:	557d                	li	a0,-1
ffffffffc0200cf8:	b755                	j	ffffffffc0200c9c <buddy_alloc+0x106>

ffffffffc0200cfa <buddy_alloc_pages>:
buddy_alloc_pages(size_t n){
ffffffffc0200cfa:	7179                	addi	sp,sp,-48
ffffffffc0200cfc:	ec26                	sd	s1,24(sp)
ffffffffc0200cfe:	84aa                	mv	s1,a0
  cprintf("alloc_pages\n");
ffffffffc0200d00:	00001517          	auipc	a0,0x1
ffffffffc0200d04:	c4050513          	addi	a0,a0,-960 # ffffffffc0201940 <commands+0x1e0>
buddy_alloc_pages(size_t n){
ffffffffc0200d08:	f406                	sd	ra,40(sp)
ffffffffc0200d0a:	f022                	sd	s0,32(sp)
ffffffffc0200d0c:	e84a                	sd	s2,16(sp)
ffffffffc0200d0e:	e44e                	sd	s3,8(sp)
ffffffffc0200d10:	e052                	sd	s4,0(sp)
  cprintf("alloc_pages\n");
ffffffffc0200d12:	ba4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
  assert(n>0);
ffffffffc0200d16:	12048263          	beqz	s1,ffffffffc0200e3a <buddy_alloc_pages+0x140>
  if(n>nr_free)
ffffffffc0200d1a:	000a1797          	auipc	a5,0xa1
ffffffffc0200d1e:	b367e783          	lwu	a5,-1226(a5) # ffffffffc02a1850 <free_area+0x10>
ffffffffc0200d22:	000a1917          	auipc	s2,0xa1
ffffffffc0200d26:	b1e90913          	addi	s2,s2,-1250 # ffffffffc02a1840 <free_area>
   return NULL;//请求大于空闲
ffffffffc0200d2a:	4981                	li	s3,0
  if(n>nr_free)
ffffffffc0200d2c:	0a97eb63          	bltu	a5,s1,ffffffffc0200de2 <buddy_alloc_pages+0xe8>
  rec[blockNum].offset=buddy_alloc(n);//记录偏移量 
ffffffffc0200d30:	0004841b          	sext.w	s0,s1
ffffffffc0200d34:	00004a17          	auipc	s4,0x4
ffffffffc0200d38:	704a0a13          	addi	s4,s4,1796 # ffffffffc0205438 <blockNum>
ffffffffc0200d3c:	8522                	mv	a0,s0
ffffffffc0200d3e:	000a2983          	lw	s3,0(s4)
ffffffffc0200d42:	e55ff0ef          	jal	ra,ffffffffc0200b96 <buddy_alloc>
  for(i=0;i<rec[blockNum].offset+1;i++)
ffffffffc0200d46:	000a2303          	lw	t1,0(s4)
  rec[blockNum].offset=buddy_alloc(n);//记录偏移量 
ffffffffc0200d4a:	00199793          	slli	a5,s3,0x1
ffffffffc0200d4e:	97ce                	add	a5,a5,s3
  for(i=0;i<rec[blockNum].offset+1;i++)
ffffffffc0200d50:	00131593          	slli	a1,t1,0x1
  rec[blockNum].offset=buddy_alloc(n);//记录偏移量 
ffffffffc0200d54:	000a1897          	auipc	a7,0xa1
ffffffffc0200d58:	b0488893          	addi	a7,a7,-1276 # ffffffffc02a1858 <rec>
ffffffffc0200d5c:	078e                	slli	a5,a5,0x3
  for(i=0;i<rec[blockNum].offset+1;i++)
ffffffffc0200d5e:	006586b3          	add	a3,a1,t1
  rec[blockNum].offset=buddy_alloc(n);//记录偏移量 
ffffffffc0200d62:	97c6                	add	a5,a5,a7
  for(i=0;i<rec[blockNum].offset+1;i++)
ffffffffc0200d64:	068e                	slli	a3,a3,0x3
  rec[blockNum].offset=buddy_alloc(n);//记录偏移量 
ffffffffc0200d66:	c788                	sw	a0,8(a5)
  for(i=0;i<rec[blockNum].offset+1;i++)
ffffffffc0200d68:	96c6                	add	a3,a3,a7
ffffffffc0200d6a:	4694                	lw	a3,8(a3)
  rec[blockNum].offset=buddy_alloc(n);//记录偏移量 
ffffffffc0200d6c:	87a2                	mv	a5,s0
  for(i=0;i<rec[blockNum].offset+1;i++)
ffffffffc0200d6e:	0a06c663          	bltz	a3,ffffffffc0200e1a <buddy_alloc_pages+0x120>
ffffffffc0200d72:	2685                	addiw	a3,a3,1
ffffffffc0200d74:	4701                	li	a4,0
  list_entry_t *le=&free_list,*len;
ffffffffc0200d76:	864a                	mv	a2,s2
  for(i=0;i<rec[blockNum].offset+1;i++)
ffffffffc0200d78:	2705                	addiw	a4,a4,1
    return listelm->next;
ffffffffc0200d7a:	6610                	ld	a2,8(a2)
ffffffffc0200d7c:	fee69ee3          	bne	a3,a4,ffffffffc0200d78 <buddy_alloc_pages+0x7e>
  if(!IS_POWER_OF_2(n))
ffffffffc0200d80:	fff48713          	addi	a4,s1,-1
ffffffffc0200d84:	8f65                	and	a4,a4,s1
  page=le2page(le,page_link);
ffffffffc0200d86:	fe860993          	addi	s3,a2,-24
  if(!IS_POWER_OF_2(n))
ffffffffc0200d8a:	0013069b          	addiw	a3,t1,1
ffffffffc0200d8e:	e33d                	bnez	a4,ffffffffc0200df4 <buddy_alloc_pages+0xfa>
  rec[blockNum].base=page;//记录分配块首页
ffffffffc0200d90:	00658733          	add	a4,a1,t1
ffffffffc0200d94:	070e                	slli	a4,a4,0x3
ffffffffc0200d96:	9746                	add	a4,a4,a7
ffffffffc0200d98:	01373023          	sd	s3,0(a4)
  rec[blockNum].pageNum=pagenum;//记录分配的页数
ffffffffc0200d9c:	eb00                	sd	s0,16(a4)
  blockNum++;
ffffffffc0200d9e:	00004717          	auipc	a4,0x4
ffffffffc0200da2:	68d72d23          	sw	a3,1690(a4) # ffffffffc0205438 <blockNum>
  for(i=0;i<pagenum;i++)
ffffffffc0200da6:	8822                	mv	a6,s0
ffffffffc0200da8:	00805d63          	blez	s0,ffffffffc0200dc2 <buddy_alloc_pages+0xc8>
  int i=1;
ffffffffc0200dac:	8732                	mv	a4,a2
ffffffffc0200dae:	4681                	li	a3,0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200db0:	5575                	li	a0,-3
ffffffffc0200db2:	670c                	ld	a1,8(a4)
ffffffffc0200db4:	1741                	addi	a4,a4,-16
ffffffffc0200db6:	60a7302f          	amoand.d	zero,a0,(a4)
  for(i=0;i<pagenum;i++)
ffffffffc0200dba:	2685                	addiw	a3,a3,1
    le=len;
ffffffffc0200dbc:	872e                	mv	a4,a1
  for(i=0;i<pagenum;i++)
ffffffffc0200dbe:	fef6cae3          	blt	a3,a5,ffffffffc0200db2 <buddy_alloc_pages+0xb8>
  nr_free-=pagenum;//减去已被分配的页数
ffffffffc0200dc2:	01092783          	lw	a5,16(s2)
  cprintf("alloc_pages succeed\n");
ffffffffc0200dc6:	00001517          	auipc	a0,0x1
ffffffffc0200dca:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0201950 <commands+0x1f0>
  nr_free-=pagenum;//减去已被分配的页数
ffffffffc0200dce:	410787bb          	subw	a5,a5,a6
ffffffffc0200dd2:	000a1717          	auipc	a4,0xa1
ffffffffc0200dd6:	a6f72f23          	sw	a5,-1410(a4) # ffffffffc02a1850 <free_area+0x10>
  page->property=pagenum;//合成一整页
ffffffffc0200dda:	ff062c23          	sw	a6,-8(a2)
  cprintf("alloc_pages succeed\n");
ffffffffc0200dde:	ad8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0200de2:	70a2                	ld	ra,40(sp)
ffffffffc0200de4:	7402                	ld	s0,32(sp)
ffffffffc0200de6:	854e                	mv	a0,s3
ffffffffc0200de8:	64e2                	ld	s1,24(sp)
ffffffffc0200dea:	6942                	ld	s2,16(sp)
ffffffffc0200dec:	69a2                	ld	s3,8(sp)
ffffffffc0200dee:	6a02                	ld	s4,0(sp)
ffffffffc0200df0:	6145                	addi	sp,sp,48
ffffffffc0200df2:	8082                	ret
  for(;i<size;i*=2);
ffffffffc0200df4:	4785                	li	a5,1
ffffffffc0200df6:	02f48463          	beq	s1,a5,ffffffffc0200e1e <buddy_alloc_pages+0x124>
ffffffffc0200dfa:	0017979b          	slliw	a5,a5,0x1
ffffffffc0200dfe:	883e                	mv	a6,a5
ffffffffc0200e00:	fe87ede3          	bltu	a5,s0,ffffffffc0200dfa <buddy_alloc_pages+0x100>
  rec[blockNum].base=page;//记录分配块首页
ffffffffc0200e04:	959a                	add	a1,a1,t1
ffffffffc0200e06:	058e                	slli	a1,a1,0x3
ffffffffc0200e08:	95c6                	add	a1,a1,a7
ffffffffc0200e0a:	0135b023          	sd	s3,0(a1)
  rec[blockNum].pageNum=pagenum;//记录分配的页数
ffffffffc0200e0e:	e99c                	sd	a5,16(a1)
  blockNum++;
ffffffffc0200e10:	00004717          	auipc	a4,0x4
ffffffffc0200e14:	62d72423          	sw	a3,1576(a4) # ffffffffc0205438 <blockNum>
  for(i=0;i<pagenum;i++)
ffffffffc0200e18:	bf51                	j	ffffffffc0200dac <buddy_alloc_pages+0xb2>
  list_entry_t *le=&free_list,*len;
ffffffffc0200e1a:	864a                	mv	a2,s2
ffffffffc0200e1c:	b795                	j	ffffffffc0200d80 <buddy_alloc_pages+0x86>
  rec[blockNum].base=page;//记录分配块首页
ffffffffc0200e1e:	006587b3          	add	a5,a1,t1
ffffffffc0200e22:	078e                	slli	a5,a5,0x3
ffffffffc0200e24:	97c6                	add	a5,a5,a7
ffffffffc0200e26:	0137b023          	sd	s3,0(a5)
  rec[blockNum].pageNum=pagenum;//记录分配的页数
ffffffffc0200e2a:	eb84                	sd	s1,16(a5)
  blockNum++;
ffffffffc0200e2c:	00004797          	auipc	a5,0x4
ffffffffc0200e30:	60d7a623          	sw	a3,1548(a5) # ffffffffc0205438 <blockNum>
ffffffffc0200e34:	4805                	li	a6,1
  int i=1;
ffffffffc0200e36:	4785                	li	a5,1
ffffffffc0200e38:	bf95                	j	ffffffffc0200dac <buddy_alloc_pages+0xb2>
  assert(n>0);
ffffffffc0200e3a:	00001697          	auipc	a3,0x1
ffffffffc0200e3e:	d1e68693          	addi	a3,a3,-738 # ffffffffc0201b58 <commands+0x3f8>
ffffffffc0200e42:	00001617          	auipc	a2,0x1
ffffffffc0200e46:	b4660613          	addi	a2,a2,-1210 # ffffffffc0201988 <commands+0x228>
ffffffffc0200e4a:	0b700593          	li	a1,183
ffffffffc0200e4e:	00001517          	auipc	a0,0x1
ffffffffc0200e52:	b5250513          	addi	a0,a0,-1198 # ffffffffc02019a0 <commands+0x240>
ffffffffc0200e56:	ae8ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200e5a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e5a:	100027f3          	csrr	a5,sstatus
ffffffffc0200e5e:	8b89                	andi	a5,a5,2
ffffffffc0200e60:	eb89                	bnez	a5,ffffffffc0200e72 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e62:	000a6797          	auipc	a5,0xa6
ffffffffc0200e66:	7be78793          	addi	a5,a5,1982 # ffffffffc02a7620 <pmm_manager>
ffffffffc0200e6a:	639c                	ld	a5,0(a5)
ffffffffc0200e6c:	0187b303          	ld	t1,24(a5)
ffffffffc0200e70:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200e72:	1141                	addi	sp,sp,-16
ffffffffc0200e74:	e406                	sd	ra,8(sp)
ffffffffc0200e76:	e022                	sd	s0,0(sp)
ffffffffc0200e78:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e7a:	deaff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e7e:	000a6797          	auipc	a5,0xa6
ffffffffc0200e82:	7a278793          	addi	a5,a5,1954 # ffffffffc02a7620 <pmm_manager>
ffffffffc0200e86:	639c                	ld	a5,0(a5)
ffffffffc0200e88:	8522                	mv	a0,s0
ffffffffc0200e8a:	6f9c                	ld	a5,24(a5)
ffffffffc0200e8c:	9782                	jalr	a5
ffffffffc0200e8e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e90:	dceff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e94:	8522                	mv	a0,s0
ffffffffc0200e96:	60a2                	ld	ra,8(sp)
ffffffffc0200e98:	6402                	ld	s0,0(sp)
ffffffffc0200e9a:	0141                	addi	sp,sp,16
ffffffffc0200e9c:	8082                	ret

ffffffffc0200e9e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e9e:	100027f3          	csrr	a5,sstatus
ffffffffc0200ea2:	8b89                	andi	a5,a5,2
ffffffffc0200ea4:	eb89                	bnez	a5,ffffffffc0200eb6 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200ea6:	000a6797          	auipc	a5,0xa6
ffffffffc0200eaa:	77a78793          	addi	a5,a5,1914 # ffffffffc02a7620 <pmm_manager>
ffffffffc0200eae:	639c                	ld	a5,0(a5)
ffffffffc0200eb0:	0207b303          	ld	t1,32(a5)
ffffffffc0200eb4:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200eb6:	1101                	addi	sp,sp,-32
ffffffffc0200eb8:	ec06                	sd	ra,24(sp)
ffffffffc0200eba:	e822                	sd	s0,16(sp)
ffffffffc0200ebc:	e426                	sd	s1,8(sp)
ffffffffc0200ebe:	842a                	mv	s0,a0
ffffffffc0200ec0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200ec2:	da2ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200ec6:	000a6797          	auipc	a5,0xa6
ffffffffc0200eca:	75a78793          	addi	a5,a5,1882 # ffffffffc02a7620 <pmm_manager>
ffffffffc0200ece:	639c                	ld	a5,0(a5)
ffffffffc0200ed0:	85a6                	mv	a1,s1
ffffffffc0200ed2:	8522                	mv	a0,s0
ffffffffc0200ed4:	739c                	ld	a5,32(a5)
ffffffffc0200ed6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200ed8:	6442                	ld	s0,16(sp)
ffffffffc0200eda:	60e2                	ld	ra,24(sp)
ffffffffc0200edc:	64a2                	ld	s1,8(sp)
ffffffffc0200ede:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200ee0:	d7eff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0200ee4 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200ee4:	00001797          	auipc	a5,0x1
ffffffffc0200ee8:	ce478793          	addi	a5,a5,-796 # ffffffffc0201bc8 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200eec:	638c                	ld	a1,0(a5)
        
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200eee:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ef0:	00001517          	auipc	a0,0x1
ffffffffc0200ef4:	d6850513          	addi	a0,a0,-664 # ffffffffc0201c58 <buddy_system_pmm_manager+0x90>
void pmm_init(void) {
ffffffffc0200ef8:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200efa:	000a6717          	auipc	a4,0xa6
ffffffffc0200efe:	72f73323          	sd	a5,1830(a4) # ffffffffc02a7620 <pmm_manager>
void pmm_init(void) {
ffffffffc0200f02:	e822                	sd	s0,16(sp)
ffffffffc0200f04:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f06:	000a6417          	auipc	s0,0xa6
ffffffffc0200f0a:	71a40413          	addi	s0,s0,1818 # ffffffffc02a7620 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f0e:	9a8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200f12:	601c                	ld	a5,0(s0)
ffffffffc0200f14:	679c                	ld	a5,8(a5)
ffffffffc0200f16:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f18:	57f5                	li	a5,-3
ffffffffc0200f1a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200f1c:	00001517          	auipc	a0,0x1
ffffffffc0200f20:	d5450513          	addi	a0,a0,-684 # ffffffffc0201c70 <buddy_system_pmm_manager+0xa8>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f24:	000a6717          	auipc	a4,0xa6
ffffffffc0200f28:	70f73223          	sd	a5,1796(a4) # ffffffffc02a7628 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200f2c:	98aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200f30:	46c5                	li	a3,17
ffffffffc0200f32:	06ee                	slli	a3,a3,0x1b
ffffffffc0200f34:	40100613          	li	a2,1025
ffffffffc0200f38:	16fd                	addi	a3,a3,-1
ffffffffc0200f3a:	0656                	slli	a2,a2,0x15
ffffffffc0200f3c:	07e005b7          	lui	a1,0x7e00
ffffffffc0200f40:	00001517          	auipc	a0,0x1
ffffffffc0200f44:	d4850513          	addi	a0,a0,-696 # ffffffffc0201c88 <buddy_system_pmm_manager+0xc0>
ffffffffc0200f48:	96eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f4c:	777d                	lui	a4,0xfffff
ffffffffc0200f4e:	000a7797          	auipc	a5,0xa7
ffffffffc0200f52:	6e978793          	addi	a5,a5,1769 # ffffffffc02a8637 <end+0xfff>
ffffffffc0200f56:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200f58:	00088737          	lui	a4,0x88
ffffffffc0200f5c:	00004697          	auipc	a3,0x4
ffffffffc0200f60:	4ae6be23          	sd	a4,1212(a3) # ffffffffc0205418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f64:	4581                	li	a1,0
ffffffffc0200f66:	000a6717          	auipc	a4,0xa6
ffffffffc0200f6a:	6cf73523          	sd	a5,1738(a4) # ffffffffc02a7630 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f6e:	4601                	li	a2,0
ffffffffc0200f70:	00004897          	auipc	a7,0x4
ffffffffc0200f74:	4a888893          	addi	a7,a7,1192 # ffffffffc0205418 <npage>
ffffffffc0200f78:	000a6817          	auipc	a6,0xa6
ffffffffc0200f7c:	6b880813          	addi	a6,a6,1720 # ffffffffc02a7630 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f80:	4685                	li	a3,1
ffffffffc0200f82:	fff80537          	lui	a0,0xfff80
ffffffffc0200f86:	a019                	j	ffffffffc0200f8c <pmm_init+0xa8>
ffffffffc0200f88:	00083783          	ld	a5,0(a6)
        SetPageReserved(pages + i);
ffffffffc0200f8c:	97ae                	add	a5,a5,a1
ffffffffc0200f8e:	07a1                	addi	a5,a5,8
ffffffffc0200f90:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200f94:	0008b703          	ld	a4,0(a7)
ffffffffc0200f98:	0605                	addi	a2,a2,1
ffffffffc0200f9a:	02858593          	addi	a1,a1,40 # 7e00028 <BASE_ADDRESS-0xffffffffb83fffd8>
ffffffffc0200f9e:	00a707b3          	add	a5,a4,a0
ffffffffc0200fa2:	fef663e3          	bltu	a2,a5,ffffffffc0200f88 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fa6:	00083603          	ld	a2,0(a6)
ffffffffc0200faa:	00271793          	slli	a5,a4,0x2
ffffffffc0200fae:	97ba                	add	a5,a5,a4
ffffffffc0200fb0:	fec006b7          	lui	a3,0xfec00
ffffffffc0200fb4:	078e                	slli	a5,a5,0x3
ffffffffc0200fb6:	96b2                	add	a3,a3,a2
ffffffffc0200fb8:	96be                	add	a3,a3,a5
ffffffffc0200fba:	c02007b7          	lui	a5,0xc0200
ffffffffc0200fbe:	08f6e563          	bltu	a3,a5,ffffffffc0201048 <pmm_init+0x164>
ffffffffc0200fc2:	000a6497          	auipc	s1,0xa6
ffffffffc0200fc6:	66648493          	addi	s1,s1,1638 # ffffffffc02a7628 <va_pa_offset>
ffffffffc0200fca:	608c                	ld	a1,0(s1)
    if (freemem < mem_end) {
ffffffffc0200fcc:	47c5                	li	a5,17
ffffffffc0200fce:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fd0:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0200fd2:	04f6e963          	bltu	a3,a5,ffffffffc0201024 <pmm_init+0x140>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200fd6:	601c                	ld	a5,0(s0)
ffffffffc0200fd8:	7b9c                	ld	a5,48(a5)
ffffffffc0200fda:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200fdc:	00001517          	auipc	a0,0x1
ffffffffc0200fe0:	d4450513          	addi	a0,a0,-700 # ffffffffc0201d20 <buddy_system_pmm_manager+0x158>
ffffffffc0200fe4:	8d2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200fe8:	00003697          	auipc	a3,0x3
ffffffffc0200fec:	01868693          	addi	a3,a3,24 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc0200ff0:	00004797          	auipc	a5,0x4
ffffffffc0200ff4:	42d7b823          	sd	a3,1072(a5) # ffffffffc0205420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ff8:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ffc:	06f6e263          	bltu	a3,a5,ffffffffc0201060 <pmm_init+0x17c>
ffffffffc0201000:	609c                	ld	a5,0(s1)
}
ffffffffc0201002:	6442                	ld	s0,16(sp)
ffffffffc0201004:	60e2                	ld	ra,24(sp)
ffffffffc0201006:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201008:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020100a:	8e9d                	sub	a3,a3,a5
ffffffffc020100c:	000a6797          	auipc	a5,0xa6
ffffffffc0201010:	60d7b623          	sd	a3,1548(a5) # ffffffffc02a7618 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201014:	00001517          	auipc	a0,0x1
ffffffffc0201018:	d2c50513          	addi	a0,a0,-724 # ffffffffc0201d40 <buddy_system_pmm_manager+0x178>
ffffffffc020101c:	8636                	mv	a2,a3
}
ffffffffc020101e:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201020:	896ff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201024:	6785                	lui	a5,0x1
ffffffffc0201026:	17fd                	addi	a5,a5,-1
ffffffffc0201028:	96be                	add	a3,a3,a5
ffffffffc020102a:	82b1                	srli	a3,a3,0xc
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020102c:	04e6f663          	bleu	a4,a3,ffffffffc0201078 <pmm_init+0x194>
    pmm_manager->init_memmap(base, n);
ffffffffc0201030:	601c                	ld	a5,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201032:	96aa                	add	a3,a3,a0
ffffffffc0201034:	00269513          	slli	a0,a3,0x2
ffffffffc0201038:	96aa                	add	a3,a3,a0
ffffffffc020103a:	6b9c                	ld	a5,16(a5)
ffffffffc020103c:	00369513          	slli	a0,a3,0x3
ffffffffc0201040:	45c1                	li	a1,16
ffffffffc0201042:	9532                	add	a0,a0,a2
ffffffffc0201044:	9782                	jalr	a5
ffffffffc0201046:	bf41                	j	ffffffffc0200fd6 <pmm_init+0xf2>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201048:	00001617          	auipc	a2,0x1
ffffffffc020104c:	c7060613          	addi	a2,a2,-912 # ffffffffc0201cb8 <buddy_system_pmm_manager+0xf0>
ffffffffc0201050:	06f00593          	li	a1,111
ffffffffc0201054:	00001517          	auipc	a0,0x1
ffffffffc0201058:	c8c50513          	addi	a0,a0,-884 # ffffffffc0201ce0 <buddy_system_pmm_manager+0x118>
ffffffffc020105c:	8e2ff0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	c5860613          	addi	a2,a2,-936 # ffffffffc0201cb8 <buddy_system_pmm_manager+0xf0>
ffffffffc0201068:	08c00593          	li	a1,140
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	c7450513          	addi	a0,a0,-908 # ffffffffc0201ce0 <buddy_system_pmm_manager+0x118>
ffffffffc0201074:	8caff0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201078:	00001617          	auipc	a2,0x1
ffffffffc020107c:	c7860613          	addi	a2,a2,-904 # ffffffffc0201cf0 <buddy_system_pmm_manager+0x128>
ffffffffc0201080:	06f00593          	li	a1,111
ffffffffc0201084:	00001517          	auipc	a0,0x1
ffffffffc0201088:	c8c50513          	addi	a0,a0,-884 # ffffffffc0201d10 <buddy_system_pmm_manager+0x148>
ffffffffc020108c:	8b2ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0201090 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201090:	c185                	beqz	a1,ffffffffc02010b0 <strnlen+0x20>
ffffffffc0201092:	00054783          	lbu	a5,0(a0)
ffffffffc0201096:	cf89                	beqz	a5,ffffffffc02010b0 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201098:	4781                	li	a5,0
ffffffffc020109a:	a021                	j	ffffffffc02010a2 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020109c:	00074703          	lbu	a4,0(a4)
ffffffffc02010a0:	c711                	beqz	a4,ffffffffc02010ac <strnlen+0x1c>
        cnt ++;
ffffffffc02010a2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02010a4:	00f50733          	add	a4,a0,a5
ffffffffc02010a8:	fef59ae3          	bne	a1,a5,ffffffffc020109c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02010ac:	853e                	mv	a0,a5
ffffffffc02010ae:	8082                	ret
    size_t cnt = 0;
ffffffffc02010b0:	4781                	li	a5,0
}
ffffffffc02010b2:	853e                	mv	a0,a5
ffffffffc02010b4:	8082                	ret

ffffffffc02010b6 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02010b6:	00054783          	lbu	a5,0(a0)
ffffffffc02010ba:	0005c703          	lbu	a4,0(a1)
ffffffffc02010be:	cb91                	beqz	a5,ffffffffc02010d2 <strcmp+0x1c>
ffffffffc02010c0:	00e79c63          	bne	a5,a4,ffffffffc02010d8 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02010c4:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02010c6:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02010ca:	0585                	addi	a1,a1,1
ffffffffc02010cc:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02010d0:	fbe5                	bnez	a5,ffffffffc02010c0 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02010d2:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02010d4:	9d19                	subw	a0,a0,a4
ffffffffc02010d6:	8082                	ret
ffffffffc02010d8:	0007851b          	sext.w	a0,a5
ffffffffc02010dc:	9d19                	subw	a0,a0,a4
ffffffffc02010de:	8082                	ret

ffffffffc02010e0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02010e0:	00054783          	lbu	a5,0(a0)
ffffffffc02010e4:	cb91                	beqz	a5,ffffffffc02010f8 <strchr+0x18>
        if (*s == c) {
ffffffffc02010e6:	00b79563          	bne	a5,a1,ffffffffc02010f0 <strchr+0x10>
ffffffffc02010ea:	a809                	j	ffffffffc02010fc <strchr+0x1c>
ffffffffc02010ec:	00b78763          	beq	a5,a1,ffffffffc02010fa <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02010f0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02010f2:	00054783          	lbu	a5,0(a0)
ffffffffc02010f6:	fbfd                	bnez	a5,ffffffffc02010ec <strchr+0xc>
    }
    return NULL;
ffffffffc02010f8:	4501                	li	a0,0
}
ffffffffc02010fa:	8082                	ret
ffffffffc02010fc:	8082                	ret

ffffffffc02010fe <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02010fe:	ca01                	beqz	a2,ffffffffc020110e <memset+0x10>
ffffffffc0201100:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201102:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201104:	0785                	addi	a5,a5,1
ffffffffc0201106:	feb78fa3          	sb	a1,-1(a5) # fff <BASE_ADDRESS-0xffffffffc01ff001>
    while (n -- > 0) {
ffffffffc020110a:	fec79de3          	bne	a5,a2,ffffffffc0201104 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020110e:	8082                	ret

ffffffffc0201110 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201110:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201114:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201116:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020111a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020111c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201120:	f022                	sd	s0,32(sp)
ffffffffc0201122:	ec26                	sd	s1,24(sp)
ffffffffc0201124:	e84a                	sd	s2,16(sp)
ffffffffc0201126:	f406                	sd	ra,40(sp)
ffffffffc0201128:	e44e                	sd	s3,8(sp)
ffffffffc020112a:	84aa                	mv	s1,a0
ffffffffc020112c:	892e                	mv	s2,a1
ffffffffc020112e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201132:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201134:	03067e63          	bleu	a6,a2,ffffffffc0201170 <printnum+0x60>
ffffffffc0201138:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020113a:	00805763          	blez	s0,ffffffffc0201148 <printnum+0x38>
ffffffffc020113e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201140:	85ca                	mv	a1,s2
ffffffffc0201142:	854e                	mv	a0,s3
ffffffffc0201144:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201146:	fc65                	bnez	s0,ffffffffc020113e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201148:	1a02                	slli	s4,s4,0x20
ffffffffc020114a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020114e:	00001797          	auipc	a5,0x1
ffffffffc0201152:	dc278793          	addi	a5,a5,-574 # ffffffffc0201f10 <error_string+0x38>
ffffffffc0201156:	9a3e                	add	s4,s4,a5
}
ffffffffc0201158:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020115a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020115e:	70a2                	ld	ra,40(sp)
ffffffffc0201160:	69a2                	ld	s3,8(sp)
ffffffffc0201162:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201164:	85ca                	mv	a1,s2
ffffffffc0201166:	8326                	mv	t1,s1
}
ffffffffc0201168:	6942                	ld	s2,16(sp)
ffffffffc020116a:	64e2                	ld	s1,24(sp)
ffffffffc020116c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020116e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201170:	03065633          	divu	a2,a2,a6
ffffffffc0201174:	8722                	mv	a4,s0
ffffffffc0201176:	f9bff0ef          	jal	ra,ffffffffc0201110 <printnum>
ffffffffc020117a:	b7f9                	j	ffffffffc0201148 <printnum+0x38>

ffffffffc020117c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020117c:	7119                	addi	sp,sp,-128
ffffffffc020117e:	f4a6                	sd	s1,104(sp)
ffffffffc0201180:	f0ca                	sd	s2,96(sp)
ffffffffc0201182:	e8d2                	sd	s4,80(sp)
ffffffffc0201184:	e4d6                	sd	s5,72(sp)
ffffffffc0201186:	e0da                	sd	s6,64(sp)
ffffffffc0201188:	fc5e                	sd	s7,56(sp)
ffffffffc020118a:	f862                	sd	s8,48(sp)
ffffffffc020118c:	f06a                	sd	s10,32(sp)
ffffffffc020118e:	fc86                	sd	ra,120(sp)
ffffffffc0201190:	f8a2                	sd	s0,112(sp)
ffffffffc0201192:	ecce                	sd	s3,88(sp)
ffffffffc0201194:	f466                	sd	s9,40(sp)
ffffffffc0201196:	ec6e                	sd	s11,24(sp)
ffffffffc0201198:	892a                	mv	s2,a0
ffffffffc020119a:	84ae                	mv	s1,a1
ffffffffc020119c:	8d32                	mv	s10,a2
ffffffffc020119e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011a0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a2:	00001a17          	auipc	s4,0x1
ffffffffc02011a6:	bdea0a13          	addi	s4,s4,-1058 # ffffffffc0201d80 <buddy_system_pmm_manager+0x1b8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011aa:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011ae:	00001c17          	auipc	s8,0x1
ffffffffc02011b2:	d2ac0c13          	addi	s8,s8,-726 # ffffffffc0201ed8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011b6:	000d4503          	lbu	a0,0(s10)
ffffffffc02011ba:	02500793          	li	a5,37
ffffffffc02011be:	001d0413          	addi	s0,s10,1
ffffffffc02011c2:	00f50e63          	beq	a0,a5,ffffffffc02011de <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02011c6:	c521                	beqz	a0,ffffffffc020120e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011c8:	02500993          	li	s3,37
ffffffffc02011cc:	a011                	j	ffffffffc02011d0 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02011ce:	c121                	beqz	a0,ffffffffc020120e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02011d0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011d2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02011d4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011d6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02011da:	ff351ae3          	bne	a0,s3,ffffffffc02011ce <vprintfmt+0x52>
ffffffffc02011de:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02011e2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02011e6:	4981                	li	s3,0
ffffffffc02011e8:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02011ea:	5cfd                	li	s9,-1
ffffffffc02011ec:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011ee:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02011f2:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011f4:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02011f8:	0ff6f693          	andi	a3,a3,255
ffffffffc02011fc:	00140d13          	addi	s10,s0,1
ffffffffc0201200:	20d5e563          	bltu	a1,a3,ffffffffc020140a <vprintfmt+0x28e>
ffffffffc0201204:	068a                	slli	a3,a3,0x2
ffffffffc0201206:	96d2                	add	a3,a3,s4
ffffffffc0201208:	4294                	lw	a3,0(a3)
ffffffffc020120a:	96d2                	add	a3,a3,s4
ffffffffc020120c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020120e:	70e6                	ld	ra,120(sp)
ffffffffc0201210:	7446                	ld	s0,112(sp)
ffffffffc0201212:	74a6                	ld	s1,104(sp)
ffffffffc0201214:	7906                	ld	s2,96(sp)
ffffffffc0201216:	69e6                	ld	s3,88(sp)
ffffffffc0201218:	6a46                	ld	s4,80(sp)
ffffffffc020121a:	6aa6                	ld	s5,72(sp)
ffffffffc020121c:	6b06                	ld	s6,64(sp)
ffffffffc020121e:	7be2                	ld	s7,56(sp)
ffffffffc0201220:	7c42                	ld	s8,48(sp)
ffffffffc0201222:	7ca2                	ld	s9,40(sp)
ffffffffc0201224:	7d02                	ld	s10,32(sp)
ffffffffc0201226:	6de2                	ld	s11,24(sp)
ffffffffc0201228:	6109                	addi	sp,sp,128
ffffffffc020122a:	8082                	ret
    if (lflag >= 2) {
ffffffffc020122c:	4705                	li	a4,1
ffffffffc020122e:	008a8593          	addi	a1,s5,8
ffffffffc0201232:	01074463          	blt	a4,a6,ffffffffc020123a <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201236:	26080363          	beqz	a6,ffffffffc020149c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020123a:	000ab603          	ld	a2,0(s5)
ffffffffc020123e:	46c1                	li	a3,16
ffffffffc0201240:	8aae                	mv	s5,a1
ffffffffc0201242:	a06d                	j	ffffffffc02012ec <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201244:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201248:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020124a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020124c:	b765                	j	ffffffffc02011f4 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020124e:	000aa503          	lw	a0,0(s5)
ffffffffc0201252:	85a6                	mv	a1,s1
ffffffffc0201254:	0aa1                	addi	s5,s5,8
ffffffffc0201256:	9902                	jalr	s2
            break;
ffffffffc0201258:	bfb9                	j	ffffffffc02011b6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020125a:	4705                	li	a4,1
ffffffffc020125c:	008a8993          	addi	s3,s5,8
ffffffffc0201260:	01074463          	blt	a4,a6,ffffffffc0201268 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201264:	22080463          	beqz	a6,ffffffffc020148c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201268:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020126c:	24044463          	bltz	s0,ffffffffc02014b4 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201270:	8622                	mv	a2,s0
ffffffffc0201272:	8ace                	mv	s5,s3
ffffffffc0201274:	46a9                	li	a3,10
ffffffffc0201276:	a89d                	j	ffffffffc02012ec <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201278:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020127c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020127e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201280:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201284:	8fb5                	xor	a5,a5,a3
ffffffffc0201286:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020128a:	1ad74363          	blt	a4,a3,ffffffffc0201430 <vprintfmt+0x2b4>
ffffffffc020128e:	00369793          	slli	a5,a3,0x3
ffffffffc0201292:	97e2                	add	a5,a5,s8
ffffffffc0201294:	639c                	ld	a5,0(a5)
ffffffffc0201296:	18078d63          	beqz	a5,ffffffffc0201430 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020129a:	86be                	mv	a3,a5
ffffffffc020129c:	00001617          	auipc	a2,0x1
ffffffffc02012a0:	d2460613          	addi	a2,a2,-732 # ffffffffc0201fc0 <error_string+0xe8>
ffffffffc02012a4:	85a6                	mv	a1,s1
ffffffffc02012a6:	854a                	mv	a0,s2
ffffffffc02012a8:	240000ef          	jal	ra,ffffffffc02014e8 <printfmt>
ffffffffc02012ac:	b729                	j	ffffffffc02011b6 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02012ae:	00144603          	lbu	a2,1(s0)
ffffffffc02012b2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012b4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012b6:	bf3d                	j	ffffffffc02011f4 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02012b8:	4705                	li	a4,1
ffffffffc02012ba:	008a8593          	addi	a1,s5,8
ffffffffc02012be:	01074463          	blt	a4,a6,ffffffffc02012c6 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02012c2:	1e080263          	beqz	a6,ffffffffc02014a6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02012c6:	000ab603          	ld	a2,0(s5)
ffffffffc02012ca:	46a1                	li	a3,8
ffffffffc02012cc:	8aae                	mv	s5,a1
ffffffffc02012ce:	a839                	j	ffffffffc02012ec <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02012d0:	03000513          	li	a0,48
ffffffffc02012d4:	85a6                	mv	a1,s1
ffffffffc02012d6:	e03e                	sd	a5,0(sp)
ffffffffc02012d8:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02012da:	85a6                	mv	a1,s1
ffffffffc02012dc:	07800513          	li	a0,120
ffffffffc02012e0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02012e2:	0aa1                	addi	s5,s5,8
ffffffffc02012e4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02012e8:	6782                	ld	a5,0(sp)
ffffffffc02012ea:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02012ec:	876e                	mv	a4,s11
ffffffffc02012ee:	85a6                	mv	a1,s1
ffffffffc02012f0:	854a                	mv	a0,s2
ffffffffc02012f2:	e1fff0ef          	jal	ra,ffffffffc0201110 <printnum>
            break;
ffffffffc02012f6:	b5c1                	j	ffffffffc02011b6 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012f8:	000ab603          	ld	a2,0(s5)
ffffffffc02012fc:	0aa1                	addi	s5,s5,8
ffffffffc02012fe:	1c060663          	beqz	a2,ffffffffc02014ca <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201302:	00160413          	addi	s0,a2,1
ffffffffc0201306:	17b05c63          	blez	s11,ffffffffc020147e <vprintfmt+0x302>
ffffffffc020130a:	02d00593          	li	a1,45
ffffffffc020130e:	14b79263          	bne	a5,a1,ffffffffc0201452 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201312:	00064783          	lbu	a5,0(a2)
ffffffffc0201316:	0007851b          	sext.w	a0,a5
ffffffffc020131a:	c905                	beqz	a0,ffffffffc020134a <vprintfmt+0x1ce>
ffffffffc020131c:	000cc563          	bltz	s9,ffffffffc0201326 <vprintfmt+0x1aa>
ffffffffc0201320:	3cfd                	addiw	s9,s9,-1
ffffffffc0201322:	036c8263          	beq	s9,s6,ffffffffc0201346 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201326:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201328:	18098463          	beqz	s3,ffffffffc02014b0 <vprintfmt+0x334>
ffffffffc020132c:	3781                	addiw	a5,a5,-32
ffffffffc020132e:	18fbf163          	bleu	a5,s7,ffffffffc02014b0 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201332:	03f00513          	li	a0,63
ffffffffc0201336:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201338:	0405                	addi	s0,s0,1
ffffffffc020133a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020133e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201340:	0007851b          	sext.w	a0,a5
ffffffffc0201344:	fd61                	bnez	a0,ffffffffc020131c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201346:	e7b058e3          	blez	s11,ffffffffc02011b6 <vprintfmt+0x3a>
ffffffffc020134a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020134c:	85a6                	mv	a1,s1
ffffffffc020134e:	02000513          	li	a0,32
ffffffffc0201352:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201354:	e60d81e3          	beqz	s11,ffffffffc02011b6 <vprintfmt+0x3a>
ffffffffc0201358:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020135a:	85a6                	mv	a1,s1
ffffffffc020135c:	02000513          	li	a0,32
ffffffffc0201360:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201362:	fe0d94e3          	bnez	s11,ffffffffc020134a <vprintfmt+0x1ce>
ffffffffc0201366:	bd81                	j	ffffffffc02011b6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201368:	4705                	li	a4,1
ffffffffc020136a:	008a8593          	addi	a1,s5,8
ffffffffc020136e:	01074463          	blt	a4,a6,ffffffffc0201376 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201372:	12080063          	beqz	a6,ffffffffc0201492 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201376:	000ab603          	ld	a2,0(s5)
ffffffffc020137a:	46a9                	li	a3,10
ffffffffc020137c:	8aae                	mv	s5,a1
ffffffffc020137e:	b7bd                	j	ffffffffc02012ec <vprintfmt+0x170>
ffffffffc0201380:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201384:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201388:	846a                	mv	s0,s10
ffffffffc020138a:	b5ad                	j	ffffffffc02011f4 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020138c:	85a6                	mv	a1,s1
ffffffffc020138e:	02500513          	li	a0,37
ffffffffc0201392:	9902                	jalr	s2
            break;
ffffffffc0201394:	b50d                	j	ffffffffc02011b6 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201396:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020139a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020139e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013a0:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02013a2:	e40dd9e3          	bgez	s11,ffffffffc02011f4 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02013a6:	8de6                	mv	s11,s9
ffffffffc02013a8:	5cfd                	li	s9,-1
ffffffffc02013aa:	b5a9                	j	ffffffffc02011f4 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02013ac:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02013b0:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013b4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013b6:	bd3d                	j	ffffffffc02011f4 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02013b8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02013bc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013c0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02013c2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02013c6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013ca:	fcd56ce3          	bltu	a0,a3,ffffffffc02013a2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02013ce:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02013d0:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02013d4:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02013d8:	0196873b          	addw	a4,a3,s9
ffffffffc02013dc:	0017171b          	slliw	a4,a4,0x1
ffffffffc02013e0:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02013e4:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02013e8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02013ec:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013f0:	fcd57fe3          	bleu	a3,a0,ffffffffc02013ce <vprintfmt+0x252>
ffffffffc02013f4:	b77d                	j	ffffffffc02013a2 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02013f6:	fffdc693          	not	a3,s11
ffffffffc02013fa:	96fd                	srai	a3,a3,0x3f
ffffffffc02013fc:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201400:	00144603          	lbu	a2,1(s0)
ffffffffc0201404:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201406:	846a                	mv	s0,s10
ffffffffc0201408:	b3f5                	j	ffffffffc02011f4 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020140a:	85a6                	mv	a1,s1
ffffffffc020140c:	02500513          	li	a0,37
ffffffffc0201410:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201412:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201416:	02500793          	li	a5,37
ffffffffc020141a:	8d22                	mv	s10,s0
ffffffffc020141c:	d8f70de3          	beq	a4,a5,ffffffffc02011b6 <vprintfmt+0x3a>
ffffffffc0201420:	02500713          	li	a4,37
ffffffffc0201424:	1d7d                	addi	s10,s10,-1
ffffffffc0201426:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020142a:	fee79de3          	bne	a5,a4,ffffffffc0201424 <vprintfmt+0x2a8>
ffffffffc020142e:	b361                	j	ffffffffc02011b6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201430:	00001617          	auipc	a2,0x1
ffffffffc0201434:	b8060613          	addi	a2,a2,-1152 # ffffffffc0201fb0 <error_string+0xd8>
ffffffffc0201438:	85a6                	mv	a1,s1
ffffffffc020143a:	854a                	mv	a0,s2
ffffffffc020143c:	0ac000ef          	jal	ra,ffffffffc02014e8 <printfmt>
ffffffffc0201440:	bb9d                	j	ffffffffc02011b6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201442:	00001617          	auipc	a2,0x1
ffffffffc0201446:	b6660613          	addi	a2,a2,-1178 # ffffffffc0201fa8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020144a:	00001417          	auipc	s0,0x1
ffffffffc020144e:	b5f40413          	addi	s0,s0,-1185 # ffffffffc0201fa9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201452:	8532                	mv	a0,a2
ffffffffc0201454:	85e6                	mv	a1,s9
ffffffffc0201456:	e032                	sd	a2,0(sp)
ffffffffc0201458:	e43e                	sd	a5,8(sp)
ffffffffc020145a:	c37ff0ef          	jal	ra,ffffffffc0201090 <strnlen>
ffffffffc020145e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201462:	6602                	ld	a2,0(sp)
ffffffffc0201464:	01b05d63          	blez	s11,ffffffffc020147e <vprintfmt+0x302>
ffffffffc0201468:	67a2                	ld	a5,8(sp)
ffffffffc020146a:	2781                	sext.w	a5,a5
ffffffffc020146c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020146e:	6522                	ld	a0,8(sp)
ffffffffc0201470:	85a6                	mv	a1,s1
ffffffffc0201472:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201474:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201476:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201478:	6602                	ld	a2,0(sp)
ffffffffc020147a:	fe0d9ae3          	bnez	s11,ffffffffc020146e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020147e:	00064783          	lbu	a5,0(a2)
ffffffffc0201482:	0007851b          	sext.w	a0,a5
ffffffffc0201486:	e8051be3          	bnez	a0,ffffffffc020131c <vprintfmt+0x1a0>
ffffffffc020148a:	b335                	j	ffffffffc02011b6 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020148c:	000aa403          	lw	s0,0(s5)
ffffffffc0201490:	bbf1                	j	ffffffffc020126c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201492:	000ae603          	lwu	a2,0(s5)
ffffffffc0201496:	46a9                	li	a3,10
ffffffffc0201498:	8aae                	mv	s5,a1
ffffffffc020149a:	bd89                	j	ffffffffc02012ec <vprintfmt+0x170>
ffffffffc020149c:	000ae603          	lwu	a2,0(s5)
ffffffffc02014a0:	46c1                	li	a3,16
ffffffffc02014a2:	8aae                	mv	s5,a1
ffffffffc02014a4:	b5a1                	j	ffffffffc02012ec <vprintfmt+0x170>
ffffffffc02014a6:	000ae603          	lwu	a2,0(s5)
ffffffffc02014aa:	46a1                	li	a3,8
ffffffffc02014ac:	8aae                	mv	s5,a1
ffffffffc02014ae:	bd3d                	j	ffffffffc02012ec <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02014b0:	9902                	jalr	s2
ffffffffc02014b2:	b559                	j	ffffffffc0201338 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02014b4:	85a6                	mv	a1,s1
ffffffffc02014b6:	02d00513          	li	a0,45
ffffffffc02014ba:	e03e                	sd	a5,0(sp)
ffffffffc02014bc:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02014be:	8ace                	mv	s5,s3
ffffffffc02014c0:	40800633          	neg	a2,s0
ffffffffc02014c4:	46a9                	li	a3,10
ffffffffc02014c6:	6782                	ld	a5,0(sp)
ffffffffc02014c8:	b515                	j	ffffffffc02012ec <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02014ca:	01b05663          	blez	s11,ffffffffc02014d6 <vprintfmt+0x35a>
ffffffffc02014ce:	02d00693          	li	a3,45
ffffffffc02014d2:	f6d798e3          	bne	a5,a3,ffffffffc0201442 <vprintfmt+0x2c6>
ffffffffc02014d6:	00001417          	auipc	s0,0x1
ffffffffc02014da:	ad340413          	addi	s0,s0,-1325 # ffffffffc0201fa9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014de:	02800513          	li	a0,40
ffffffffc02014e2:	02800793          	li	a5,40
ffffffffc02014e6:	bd1d                	j	ffffffffc020131c <vprintfmt+0x1a0>

ffffffffc02014e8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014e8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02014ea:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014ee:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014f0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014f2:	ec06                	sd	ra,24(sp)
ffffffffc02014f4:	f83a                	sd	a4,48(sp)
ffffffffc02014f6:	fc3e                	sd	a5,56(sp)
ffffffffc02014f8:	e0c2                	sd	a6,64(sp)
ffffffffc02014fa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02014fc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014fe:	c7fff0ef          	jal	ra,ffffffffc020117c <vprintfmt>
}
ffffffffc0201502:	60e2                	ld	ra,24(sp)
ffffffffc0201504:	6161                	addi	sp,sp,80
ffffffffc0201506:	8082                	ret

ffffffffc0201508 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201508:	715d                	addi	sp,sp,-80
ffffffffc020150a:	e486                	sd	ra,72(sp)
ffffffffc020150c:	e0a2                	sd	s0,64(sp)
ffffffffc020150e:	fc26                	sd	s1,56(sp)
ffffffffc0201510:	f84a                	sd	s2,48(sp)
ffffffffc0201512:	f44e                	sd	s3,40(sp)
ffffffffc0201514:	f052                	sd	s4,32(sp)
ffffffffc0201516:	ec56                	sd	s5,24(sp)
ffffffffc0201518:	e85a                	sd	s6,16(sp)
ffffffffc020151a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020151c:	c901                	beqz	a0,ffffffffc020152c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020151e:	85aa                	mv	a1,a0
ffffffffc0201520:	00001517          	auipc	a0,0x1
ffffffffc0201524:	aa050513          	addi	a0,a0,-1376 # ffffffffc0201fc0 <error_string+0xe8>
ffffffffc0201528:	b8ffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc020152c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020152e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201530:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201532:	4aa9                	li	s5,10
ffffffffc0201534:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201536:	00004b97          	auipc	s7,0x4
ffffffffc020153a:	adab8b93          	addi	s7,s7,-1318 # ffffffffc0205010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020153e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201542:	bedfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201546:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201548:	00054b63          	bltz	a0,ffffffffc020155e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020154c:	00a95b63          	ble	a0,s2,ffffffffc0201562 <readline+0x5a>
ffffffffc0201550:	029a5463          	ble	s1,s4,ffffffffc0201578 <readline+0x70>
        c = getchar();
ffffffffc0201554:	bdbfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201558:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020155a:	fe0559e3          	bgez	a0,ffffffffc020154c <readline+0x44>
            return NULL;
ffffffffc020155e:	4501                	li	a0,0
ffffffffc0201560:	a099                	j	ffffffffc02015a6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201562:	03341463          	bne	s0,s3,ffffffffc020158a <readline+0x82>
ffffffffc0201566:	e8b9                	bnez	s1,ffffffffc02015bc <readline+0xb4>
        c = getchar();
ffffffffc0201568:	bc7fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020156c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020156e:	fe0548e3          	bltz	a0,ffffffffc020155e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201572:	fea958e3          	ble	a0,s2,ffffffffc0201562 <readline+0x5a>
ffffffffc0201576:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201578:	8522                	mv	a0,s0
ffffffffc020157a:	b71fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc020157e:	009b87b3          	add	a5,s7,s1
ffffffffc0201582:	00878023          	sb	s0,0(a5)
ffffffffc0201586:	2485                	addiw	s1,s1,1
ffffffffc0201588:	bf6d                	j	ffffffffc0201542 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020158a:	01540463          	beq	s0,s5,ffffffffc0201592 <readline+0x8a>
ffffffffc020158e:	fb641ae3          	bne	s0,s6,ffffffffc0201542 <readline+0x3a>
            cputchar(c);
ffffffffc0201592:	8522                	mv	a0,s0
ffffffffc0201594:	b57fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201598:	00004517          	auipc	a0,0x4
ffffffffc020159c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0205010 <edata>
ffffffffc02015a0:	94aa                	add	s1,s1,a0
ffffffffc02015a2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02015a6:	60a6                	ld	ra,72(sp)
ffffffffc02015a8:	6406                	ld	s0,64(sp)
ffffffffc02015aa:	74e2                	ld	s1,56(sp)
ffffffffc02015ac:	7942                	ld	s2,48(sp)
ffffffffc02015ae:	79a2                	ld	s3,40(sp)
ffffffffc02015b0:	7a02                	ld	s4,32(sp)
ffffffffc02015b2:	6ae2                	ld	s5,24(sp)
ffffffffc02015b4:	6b42                	ld	s6,16(sp)
ffffffffc02015b6:	6ba2                	ld	s7,8(sp)
ffffffffc02015b8:	6161                	addi	sp,sp,80
ffffffffc02015ba:	8082                	ret
            cputchar(c);
ffffffffc02015bc:	4521                	li	a0,8
ffffffffc02015be:	b2dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02015c2:	34fd                	addiw	s1,s1,-1
ffffffffc02015c4:	bfbd                	j	ffffffffc0201542 <readline+0x3a>

ffffffffc02015c6 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02015c6:	00004797          	auipc	a5,0x4
ffffffffc02015ca:	a4278793          	addi	a5,a5,-1470 # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02015ce:	6398                	ld	a4,0(a5)
ffffffffc02015d0:	4781                	li	a5,0
ffffffffc02015d2:	88ba                	mv	a7,a4
ffffffffc02015d4:	852a                	mv	a0,a0
ffffffffc02015d6:	85be                	mv	a1,a5
ffffffffc02015d8:	863e                	mv	a2,a5
ffffffffc02015da:	00000073          	ecall
ffffffffc02015de:	87aa                	mv	a5,a0
}
ffffffffc02015e0:	8082                	ret

ffffffffc02015e2 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02015e2:	00004797          	auipc	a5,0x4
ffffffffc02015e6:	e4678793          	addi	a5,a5,-442 # ffffffffc0205428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02015ea:	6398                	ld	a4,0(a5)
ffffffffc02015ec:	4781                	li	a5,0
ffffffffc02015ee:	88ba                	mv	a7,a4
ffffffffc02015f0:	852a                	mv	a0,a0
ffffffffc02015f2:	85be                	mv	a1,a5
ffffffffc02015f4:	863e                	mv	a2,a5
ffffffffc02015f6:	00000073          	ecall
ffffffffc02015fa:	87aa                	mv	a5,a0
}
ffffffffc02015fc:	8082                	ret

ffffffffc02015fe <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02015fe:	00004797          	auipc	a5,0x4
ffffffffc0201602:	a0278793          	addi	a5,a5,-1534 # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201606:	639c                	ld	a5,0(a5)
ffffffffc0201608:	4501                	li	a0,0
ffffffffc020160a:	88be                	mv	a7,a5
ffffffffc020160c:	852a                	mv	a0,a0
ffffffffc020160e:	85aa                	mv	a1,a0
ffffffffc0201610:	862a                	mv	a2,a0
ffffffffc0201612:	00000073          	ecall
ffffffffc0201616:	852a                	mv	a0,a0
ffffffffc0201618:	2501                	sext.w	a0,a0
ffffffffc020161a:	8082                	ret
