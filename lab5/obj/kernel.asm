
bin/kernel：     文件格式 elf64-littleriscv


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
ffffffffc020003a:	06250513          	addi	a0,a0,98 # ffffffffc02a1098 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	5e260613          	addi	a2,a2,1506 # ffffffffc02ac620 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	51a060ef          	jal	ra,ffffffffc0206568 <memset>
    cons_init();                // init the console
ffffffffc0200052:	536000ef          	jal	ra,ffffffffc0200588 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	54258593          	addi	a1,a1,1346 # ffffffffc0206598 <etext+0x6>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	55a50513          	addi	a0,a0,1370 # ffffffffc02065b8 <etext+0x26>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ac000ef          	jal	ra,ffffffffc0200216 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	758020ef          	jal	ra,ffffffffc02027c6 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5ee000ef          	jal	ra,ffffffffc0200660 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	346040ef          	jal	ra,ffffffffc02043c0 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	47b050ef          	jal	ra,ffffffffc0205cf8 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	57a000ef          	jal	ra,ffffffffc02005fc <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	264030ef          	jal	ra,ffffffffc02032ea <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a8000ef          	jal	ra,ffffffffc0200532 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c6000ef          	jal	ra,ffffffffc0200654 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	5b3050ef          	jal	ra,ffffffffc0205e44 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	51250513          	addi	a0,a0,1298 # ffffffffc02065c0 <etext+0x2e>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	fd4b8b93          	addi	s7,s7,-44 # ffffffffc02a1098 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	136000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	124000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	110000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	f7250513          	addi	a0,a0,-142 # ffffffffc02a1098 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	42e000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	7bd050ef          	jal	ra,ffffffffc020613e <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	789050ef          	jal	ra,ffffffffc020613e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3c80006f          	j	ffffffffc020058a <cons_putc>

ffffffffc02001c6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c6:	1101                	addi	sp,sp,-32
ffffffffc02001c8:	e822                	sd	s0,16(sp)
ffffffffc02001ca:	ec06                	sd	ra,24(sp)
ffffffffc02001cc:	e426                	sd	s1,8(sp)
ffffffffc02001ce:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00054503          	lbu	a0,0(a0)
ffffffffc02001d4:	c51d                	beqz	a0,ffffffffc0200202 <cputs+0x3c>
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	4485                	li	s1,1
ffffffffc02001da:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001dc:	3ae000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc02001e0:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e4:	0405                	addi	s0,s0,1
ffffffffc02001e6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ea:	f96d                	bnez	a0,ffffffffc02001dc <cputs+0x16>
ffffffffc02001ec:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f0:	4529                	li	a0,10
ffffffffc02001f2:	398000ef          	jal	ra,ffffffffc020058a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f6:	8522                	mv	a0,s0
ffffffffc02001f8:	60e2                	ld	ra,24(sp)
ffffffffc02001fa:	6442                	ld	s0,16(sp)
ffffffffc02001fc:	64a2                	ld	s1,8(sp)
ffffffffc02001fe:	6105                	addi	sp,sp,32
ffffffffc0200200:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200202:	4405                	li	s0,1
ffffffffc0200204:	b7f5                	j	ffffffffc02001f0 <cputs+0x2a>

ffffffffc0200206 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200206:	1141                	addi	sp,sp,-16
ffffffffc0200208:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020a:	3b6000ef          	jal	ra,ffffffffc02005c0 <cons_getc>
ffffffffc020020e:	dd75                	beqz	a0,ffffffffc020020a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	0141                	addi	sp,sp,16
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200216:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200218:	00006517          	auipc	a0,0x6
ffffffffc020021c:	3e050513          	addi	a0,a0,992 # ffffffffc02065f8 <etext+0x66>
void print_kerninfo(void) {
ffffffffc0200220:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	f6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200226:	00000597          	auipc	a1,0x0
ffffffffc020022a:	e1058593          	addi	a1,a1,-496 # ffffffffc0200036 <kern_init>
ffffffffc020022e:	00006517          	auipc	a0,0x6
ffffffffc0200232:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206618 <etext+0x86>
ffffffffc0200236:	f59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	35858593          	addi	a1,a1,856 # ffffffffc0206592 <etext>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	3f650513          	addi	a0,a0,1014 # ffffffffc0206638 <etext+0xa6>
ffffffffc020024a:	f45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024e:	000a1597          	auipc	a1,0xa1
ffffffffc0200252:	e4a58593          	addi	a1,a1,-438 # ffffffffc02a1098 <edata>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	40250513          	addi	a0,a0,1026 # ffffffffc0206658 <etext+0xc6>
ffffffffc020025e:	f31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200262:	000ac597          	auipc	a1,0xac
ffffffffc0200266:	3be58593          	addi	a1,a1,958 # ffffffffc02ac620 <end>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	40e50513          	addi	a0,a0,1038 # ffffffffc0206678 <etext+0xe6>
ffffffffc0200272:	f1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200276:	000ac597          	auipc	a1,0xac
ffffffffc020027a:	7a958593          	addi	a1,a1,1961 # ffffffffc02aca1f <end+0x3ff>
ffffffffc020027e:	00000797          	auipc	a5,0x0
ffffffffc0200282:	db878793          	addi	a5,a5,-584 # ffffffffc0200036 <kern_init>
ffffffffc0200286:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200294:	95be                	add	a1,a1,a5
ffffffffc0200296:	85a9                	srai	a1,a1,0xa
ffffffffc0200298:	00006517          	auipc	a0,0x6
ffffffffc020029c:	40050513          	addi	a0,a0,1024 # ffffffffc0206698 <etext+0x106>
}
ffffffffc02002a0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	eedff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02002a6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a8:	00006617          	auipc	a2,0x6
ffffffffc02002ac:	32060613          	addi	a2,a2,800 # ffffffffc02065c8 <etext+0x36>
ffffffffc02002b0:	04d00593          	li	a1,77
ffffffffc02002b4:	00006517          	auipc	a0,0x6
ffffffffc02002b8:	32c50513          	addi	a0,a0,812 # ffffffffc02065e0 <etext+0x4e>
void print_stackframe(void) {
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002be:	1c6000ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02002c2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c4:	00006617          	auipc	a2,0x6
ffffffffc02002c8:	4e460613          	addi	a2,a2,1252 # ffffffffc02067a8 <commands+0xe0>
ffffffffc02002cc:	00006597          	auipc	a1,0x6
ffffffffc02002d0:	4fc58593          	addi	a1,a1,1276 # ffffffffc02067c8 <commands+0x100>
ffffffffc02002d4:	00006517          	auipc	a0,0x6
ffffffffc02002d8:	4fc50513          	addi	a0,a0,1276 # ffffffffc02067d0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002de:	eb1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002e2:	00006617          	auipc	a2,0x6
ffffffffc02002e6:	4fe60613          	addi	a2,a2,1278 # ffffffffc02067e0 <commands+0x118>
ffffffffc02002ea:	00006597          	auipc	a1,0x6
ffffffffc02002ee:	51e58593          	addi	a1,a1,1310 # ffffffffc0206808 <commands+0x140>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	4de50513          	addi	a0,a0,1246 # ffffffffc02067d0 <commands+0x108>
ffffffffc02002fa:	e95ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fe:	00006617          	auipc	a2,0x6
ffffffffc0200302:	51a60613          	addi	a2,a2,1306 # ffffffffc0206818 <commands+0x150>
ffffffffc0200306:	00006597          	auipc	a1,0x6
ffffffffc020030a:	53258593          	addi	a1,a1,1330 # ffffffffc0206838 <commands+0x170>
ffffffffc020030e:	00006517          	auipc	a0,0x6
ffffffffc0200312:	4c250513          	addi	a0,a0,1218 # ffffffffc02067d0 <commands+0x108>
ffffffffc0200316:	e79ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200326:	ef1ff0ef          	jal	ra,ffffffffc0200216 <print_kerninfo>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200332:	1141                	addi	sp,sp,-16
ffffffffc0200334:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200336:	f71ff0ef          	jal	ra,ffffffffc02002a6 <print_stackframe>
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200342:	7115                	addi	sp,sp,-224
ffffffffc0200344:	e962                	sd	s8,144(sp)
ffffffffc0200346:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200348:	00006517          	auipc	a0,0x6
ffffffffc020034c:	3c850513          	addi	a0,a0,968 # ffffffffc0206710 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200350:	ed86                	sd	ra,216(sp)
ffffffffc0200352:	e9a2                	sd	s0,208(sp)
ffffffffc0200354:	e5a6                	sd	s1,200(sp)
ffffffffc0200356:	e1ca                	sd	s2,192(sp)
ffffffffc0200358:	fd4e                	sd	s3,184(sp)
ffffffffc020035a:	f952                	sd	s4,176(sp)
ffffffffc020035c:	f556                	sd	s5,168(sp)
ffffffffc020035e:	f15a                	sd	s6,160(sp)
ffffffffc0200360:	ed5e                	sd	s7,152(sp)
ffffffffc0200362:	e566                	sd	s9,136(sp)
ffffffffc0200364:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200366:	e29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	3ce50513          	addi	a0,a0,974 # ffffffffc0206738 <commands+0x70>
ffffffffc0200372:	e1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200376:	000c0563          	beqz	s8,ffffffffc0200380 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037a:	8562                	mv	a0,s8
ffffffffc020037c:	4ce000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc0200380:	00006c97          	auipc	s9,0x6
ffffffffc0200384:	348c8c93          	addi	s9,s9,840 # ffffffffc02066c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200388:	00006997          	auipc	s3,0x6
ffffffffc020038c:	3d898993          	addi	s3,s3,984 # ffffffffc0206760 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	3d890913          	addi	s2,s2,984 # ffffffffc0206768 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200398:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	00006b17          	auipc	s6,0x6
ffffffffc020039e:	3d6b0b13          	addi	s6,s6,982 # ffffffffc0206770 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a2:	00006a97          	auipc	s5,0x6
ffffffffc02003a6:	426a8a93          	addi	s5,s5,1062 # ffffffffc02067c8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003aa:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003ac:	854e                	mv	a0,s3
ffffffffc02003ae:	ce9ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003b2:	842a                	mv	s0,a0
ffffffffc02003b4:	dd65                	beqz	a0,ffffffffc02003ac <kmonitor+0x6a>
ffffffffc02003b6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003ba:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	c999                	beqz	a1,ffffffffc02003d2 <kmonitor+0x90>
ffffffffc02003be:	854a                	mv	a0,s2
ffffffffc02003c0:	18a060ef          	jal	ra,ffffffffc020654a <strchr>
ffffffffc02003c4:	c925                	beqz	a0,ffffffffc0200434 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ca:	00040023          	sb	zero,0(s0)
ffffffffc02003ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d0:	f5fd                	bnez	a1,ffffffffc02003be <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d2:	dce9                	beqz	s1,ffffffffc02003ac <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d4:	6582                	ld	a1,0(sp)
ffffffffc02003d6:	00006d17          	auipc	s10,0x6
ffffffffc02003da:	2f2d0d13          	addi	s10,s10,754 # ffffffffc02066c8 <commands>
    if (argc == 0) {
ffffffffc02003de:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e2:	0d61                	addi	s10,s10,24
ffffffffc02003e4:	13c060ef          	jal	ra,ffffffffc0206520 <strcmp>
ffffffffc02003e8:	c919                	beqz	a0,ffffffffc02003fe <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ea:	2405                	addiw	s0,s0,1
ffffffffc02003ec:	09740463          	beq	s0,s7,ffffffffc0200474 <kmonitor+0x132>
ffffffffc02003f0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	0d61                	addi	s10,s10,24
ffffffffc02003f8:	128060ef          	jal	ra,ffffffffc0206520 <strcmp>
ffffffffc02003fc:	f57d                	bnez	a0,ffffffffc02003ea <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fe:	00141793          	slli	a5,s0,0x1
ffffffffc0200402:	97a2                	add	a5,a5,s0
ffffffffc0200404:	078e                	slli	a5,a5,0x3
ffffffffc0200406:	97e6                	add	a5,a5,s9
ffffffffc0200408:	6b9c                	ld	a5,16(a5)
ffffffffc020040a:	8662                	mv	a2,s8
ffffffffc020040c:	002c                	addi	a1,sp,8
ffffffffc020040e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200412:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200414:	f8055ce3          	bgez	a0,ffffffffc02003ac <kmonitor+0x6a>
}
ffffffffc0200418:	60ee                	ld	ra,216(sp)
ffffffffc020041a:	644e                	ld	s0,208(sp)
ffffffffc020041c:	64ae                	ld	s1,200(sp)
ffffffffc020041e:	690e                	ld	s2,192(sp)
ffffffffc0200420:	79ea                	ld	s3,184(sp)
ffffffffc0200422:	7a4a                	ld	s4,176(sp)
ffffffffc0200424:	7aaa                	ld	s5,168(sp)
ffffffffc0200426:	7b0a                	ld	s6,160(sp)
ffffffffc0200428:	6bea                	ld	s7,152(sp)
ffffffffc020042a:	6c4a                	ld	s8,144(sp)
ffffffffc020042c:	6caa                	ld	s9,136(sp)
ffffffffc020042e:	6d0a                	ld	s10,128(sp)
ffffffffc0200430:	612d                	addi	sp,sp,224
ffffffffc0200432:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200434:	00044783          	lbu	a5,0(s0)
ffffffffc0200438:	dfc9                	beqz	a5,ffffffffc02003d2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043a:	03448863          	beq	s1,s4,ffffffffc020046a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043e:	00349793          	slli	a5,s1,0x3
ffffffffc0200442:	0118                	addi	a4,sp,128
ffffffffc0200444:	97ba                	add	a5,a5,a4
ffffffffc0200446:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200450:	e591                	bnez	a1,ffffffffc020045c <kmonitor+0x11a>
ffffffffc0200452:	b749                	j	ffffffffc02003d4 <kmonitor+0x92>
            buf ++;
ffffffffc0200454:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200456:	00044583          	lbu	a1,0(s0)
ffffffffc020045a:	ddad                	beqz	a1,ffffffffc02003d4 <kmonitor+0x92>
ffffffffc020045c:	854a                	mv	a0,s2
ffffffffc020045e:	0ec060ef          	jal	ra,ffffffffc020654a <strchr>
ffffffffc0200462:	d96d                	beqz	a0,ffffffffc0200454 <kmonitor+0x112>
ffffffffc0200464:	00044583          	lbu	a1,0(s0)
ffffffffc0200468:	bf91                	j	ffffffffc02003bc <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046a:	45c1                	li	a1,16
ffffffffc020046c:	855a                	mv	a0,s6
ffffffffc020046e:	d21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200472:	b7f1                	j	ffffffffc020043e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00006517          	auipc	a0,0x6
ffffffffc020047a:	31a50513          	addi	a0,a0,794 # ffffffffc0206790 <commands+0xc8>
ffffffffc020047e:	d11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc0200482:	b72d                	j	ffffffffc02003ac <kmonitor+0x6a>

ffffffffc0200484 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200484:	000ac317          	auipc	t1,0xac
ffffffffc0200488:	01430313          	addi	t1,t1,20 # ffffffffc02ac498 <is_panic>
ffffffffc020048c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200490:	715d                	addi	sp,sp,-80
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e822                	sd	s0,16(sp)
ffffffffc0200496:	f436                	sd	a3,40(sp)
ffffffffc0200498:	f83a                	sd	a4,48(sp)
ffffffffc020049a:	fc3e                	sd	a5,56(sp)
ffffffffc020049c:	e0c2                	sd	a6,64(sp)
ffffffffc020049e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a0:	02031c63          	bnez	t1,ffffffffc02004d8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a4:	4785                	li	a5,1
ffffffffc02004a6:	8432                	mv	s0,a2
ffffffffc02004a8:	000ac717          	auipc	a4,0xac
ffffffffc02004ac:	fef73823          	sd	a5,-16(a4) # ffffffffc02ac498 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	85aa                	mv	a1,a0
ffffffffc02004b6:	00006517          	auipc	a0,0x6
ffffffffc02004ba:	39250513          	addi	a0,a0,914 # ffffffffc0206848 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004be:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c0:	ccfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c4:	65a2                	ld	a1,8(sp)
ffffffffc02004c6:	8522                	mv	a0,s0
ffffffffc02004c8:	ca7ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004cc:	00007517          	auipc	a0,0x7
ffffffffc02004d0:	32450513          	addi	a0,a0,804 # ffffffffc02077f0 <default_pmm_manager+0x520>
ffffffffc02004d4:	cbbff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	48a1                	li	a7,8
ffffffffc02004e0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e4:	176000ef          	jal	ra,ffffffffc020065a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e8:	4501                	li	a0,0
ffffffffc02004ea:	e59ff0ef          	jal	ra,ffffffffc0200342 <kmonitor>
ffffffffc02004ee:	bfed                	j	ffffffffc02004e8 <__panic+0x64>

ffffffffc02004f0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f0:	715d                	addi	sp,sp,-80
ffffffffc02004f2:	e822                	sd	s0,16(sp)
ffffffffc02004f4:	fc3e                	sd	a5,56(sp)
ffffffffc02004f6:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f8:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fa:	862e                	mv	a2,a1
ffffffffc02004fc:	85aa                	mv	a1,a0
ffffffffc02004fe:	00006517          	auipc	a0,0x6
ffffffffc0200502:	36a50513          	addi	a0,a0,874 # ffffffffc0206868 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200506:	ec06                	sd	ra,24(sp)
ffffffffc0200508:	f436                	sd	a3,40(sp)
ffffffffc020050a:	f83a                	sd	a4,48(sp)
ffffffffc020050c:	e0c2                	sd	a6,64(sp)
ffffffffc020050e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200510:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200512:	c7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200516:	65a2                	ld	a1,8(sp)
ffffffffc0200518:	8522                	mv	a0,s0
ffffffffc020051a:	c55ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051e:	00007517          	auipc	a0,0x7
ffffffffc0200522:	2d250513          	addi	a0,a0,722 # ffffffffc02077f0 <default_pmm_manager+0x520>
ffffffffc0200526:	c69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc020052a:	60e2                	ld	ra,24(sp)
ffffffffc020052c:	6442                	ld	s0,16(sp)
ffffffffc020052e:	6161                	addi	sp,sp,80
ffffffffc0200530:	8082                	ret

ffffffffc0200532 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200532:	67e1                	lui	a5,0x18
ffffffffc0200534:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc20>
ffffffffc0200538:	000ac717          	auipc	a4,0xac
ffffffffc020053c:	f6f73423          	sd	a5,-152(a4) # ffffffffc02ac4a0 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200540:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200544:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	953e                	add	a0,a0,a5
ffffffffc0200548:	4601                	li	a2,0
ffffffffc020054a:	4881                	li	a7,0
ffffffffc020054c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200550:	02000793          	li	a5,32
ffffffffc0200554:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200558:	00006517          	auipc	a0,0x6
ffffffffc020055c:	33050513          	addi	a0,a0,816 # ffffffffc0206888 <commands+0x1c0>
    ticks = 0;
ffffffffc0200560:	000ac797          	auipc	a5,0xac
ffffffffc0200564:	f807b823          	sd	zero,-112(a5) # ffffffffc02ac4f0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200568:	c27ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020056c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020056c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200570:	000ac797          	auipc	a5,0xac
ffffffffc0200574:	f3078793          	addi	a5,a5,-208 # ffffffffc02ac4a0 <timebase>
ffffffffc0200578:	639c                	ld	a5,0(a5)
ffffffffc020057a:	4581                	li	a1,0
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4881                	li	a7,0
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200588:	8082                	ret

ffffffffc020058a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058a:	100027f3          	csrr	a5,sstatus
ffffffffc020058e:	8b89                	andi	a5,a5,2
ffffffffc0200590:	0ff57513          	andi	a0,a0,255
ffffffffc0200594:	e799                	bnez	a5,ffffffffc02005a2 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200596:	4581                	li	a1,0
ffffffffc0200598:	4601                	li	a2,0
ffffffffc020059a:	4885                	li	a7,1
ffffffffc020059c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005a0:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a2:	1101                	addi	sp,sp,-32
ffffffffc02005a4:	ec06                	sd	ra,24(sp)
ffffffffc02005a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a8:	0b2000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005ac:	6522                	ld	a0,8(sp)
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	4885                	li	a7,1
ffffffffc02005b4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b8:	60e2                	ld	ra,24(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005bc:	0980006f          	j	ffffffffc0200654 <intr_enable>

ffffffffc02005c0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005c0:	100027f3          	csrr	a5,sstatus
ffffffffc02005c4:	8b89                	andi	a5,a5,2
ffffffffc02005c6:	eb89                	bnez	a5,ffffffffc02005d8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d6:	8082                	ret
int cons_getc(void) {
ffffffffc02005d8:	1101                	addi	sp,sp,-32
ffffffffc02005da:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005dc:	07e000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005e0:	4501                	li	a0,0
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	4601                	li	a2,0
ffffffffc02005e6:	4889                	li	a7,2
ffffffffc02005e8:	00000073          	ecall
ffffffffc02005ec:	2501                	sext.w	a0,a0
ffffffffc02005ee:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f0:	064000ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc02005f4:	60e2                	ld	ra,24(sp)
ffffffffc02005f6:	6522                	ld	a0,8(sp)
ffffffffc02005f8:	6105                	addi	sp,sp,32
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005fe:	00253513          	sltiu	a0,a0,2
ffffffffc0200602:	8082                	ret

ffffffffc0200604 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200604:	03800513          	li	a0,56
ffffffffc0200608:	8082                	ret

ffffffffc020060a <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	000a1797          	auipc	a5,0xa1
ffffffffc020060e:	e8e78793          	addi	a5,a5,-370 # ffffffffc02a1498 <ide>
ffffffffc0200612:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200616:	1141                	addi	sp,sp,-16
ffffffffc0200618:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	95be                	add	a1,a1,a5
ffffffffc020061c:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200620:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200622:	759050ef          	jal	ra,ffffffffc020657a <memcpy>
    return 0;
}
ffffffffc0200626:	60a2                	ld	ra,8(sp)
ffffffffc0200628:	4501                	li	a0,0
ffffffffc020062a:	0141                	addi	sp,sp,16
ffffffffc020062c:	8082                	ret

ffffffffc020062e <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc020062e:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200630:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200634:	000a1517          	auipc	a0,0xa1
ffffffffc0200638:	e6450513          	addi	a0,a0,-412 # ffffffffc02a1498 <ide>
                   size_t nsecs) {
ffffffffc020063c:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020063e:	00969613          	slli	a2,a3,0x9
ffffffffc0200642:	85ba                	mv	a1,a4
ffffffffc0200644:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200646:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200648:	733050ef          	jal	ra,ffffffffc020657a <memcpy>
    return 0;
}
ffffffffc020064c:	60a2                	ld	ra,8(sp)
ffffffffc020064e:	4501                	li	a0,0
ffffffffc0200650:	0141                	addi	sp,sp,16
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200654:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200658:	8082                	ret

ffffffffc020065a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020065e:	8082                	ret

ffffffffc0200660 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	54c50513          	addi	a0,a0,1356 # ffffffffc0206bd0 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	b01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	55450513          	addi	a0,a0,1364 # ffffffffc0206be8 <commands+0x520>
ffffffffc020069c:	af3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	55e50513          	addi	a0,a0,1374 # ffffffffc0206c00 <commands+0x538>
ffffffffc02006aa:	ae5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	56850513          	addi	a0,a0,1384 # ffffffffc0206c18 <commands+0x550>
ffffffffc02006b8:	ad7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	57250513          	addi	a0,a0,1394 # ffffffffc0206c30 <commands+0x568>
ffffffffc02006c6:	ac9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	57c50513          	addi	a0,a0,1404 # ffffffffc0206c48 <commands+0x580>
ffffffffc02006d4:	abbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	58650513          	addi	a0,a0,1414 # ffffffffc0206c60 <commands+0x598>
ffffffffc02006e2:	aadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	59050513          	addi	a0,a0,1424 # ffffffffc0206c78 <commands+0x5b0>
ffffffffc02006f0:	a9fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	59a50513          	addi	a0,a0,1434 # ffffffffc0206c90 <commands+0x5c8>
ffffffffc02006fe:	a91ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	5a450513          	addi	a0,a0,1444 # ffffffffc0206ca8 <commands+0x5e0>
ffffffffc020070c:	a83ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	5ae50513          	addi	a0,a0,1454 # ffffffffc0206cc0 <commands+0x5f8>
ffffffffc020071a:	a75ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	5b850513          	addi	a0,a0,1464 # ffffffffc0206cd8 <commands+0x610>
ffffffffc0200728:	a67ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	5c250513          	addi	a0,a0,1474 # ffffffffc0206cf0 <commands+0x628>
ffffffffc0200736:	a59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206d08 <commands+0x640>
ffffffffc0200744:	a4bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	5d650513          	addi	a0,a0,1494 # ffffffffc0206d20 <commands+0x658>
ffffffffc0200752:	a3dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	5e050513          	addi	a0,a0,1504 # ffffffffc0206d38 <commands+0x670>
ffffffffc0200760:	a2fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	5ea50513          	addi	a0,a0,1514 # ffffffffc0206d50 <commands+0x688>
ffffffffc020076e:	a21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	5f450513          	addi	a0,a0,1524 # ffffffffc0206d68 <commands+0x6a0>
ffffffffc020077c:	a13ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	5fe50513          	addi	a0,a0,1534 # ffffffffc0206d80 <commands+0x6b8>
ffffffffc020078a:	a05ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00006517          	auipc	a0,0x6
ffffffffc0200794:	60850513          	addi	a0,a0,1544 # ffffffffc0206d98 <commands+0x6d0>
ffffffffc0200798:	9f7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00006517          	auipc	a0,0x6
ffffffffc02007a2:	61250513          	addi	a0,a0,1554 # ffffffffc0206db0 <commands+0x6e8>
ffffffffc02007a6:	9e9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00006517          	auipc	a0,0x6
ffffffffc02007b0:	61c50513          	addi	a0,a0,1564 # ffffffffc0206dc8 <commands+0x700>
ffffffffc02007b4:	9dbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00006517          	auipc	a0,0x6
ffffffffc02007be:	62650513          	addi	a0,a0,1574 # ffffffffc0206de0 <commands+0x718>
ffffffffc02007c2:	9cdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00006517          	auipc	a0,0x6
ffffffffc02007cc:	63050513          	addi	a0,a0,1584 # ffffffffc0206df8 <commands+0x730>
ffffffffc02007d0:	9bfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	63a50513          	addi	a0,a0,1594 # ffffffffc0206e10 <commands+0x748>
ffffffffc02007de:	9b1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00006517          	auipc	a0,0x6
ffffffffc02007e8:	64450513          	addi	a0,a0,1604 # ffffffffc0206e28 <commands+0x760>
ffffffffc02007ec:	9a3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00006517          	auipc	a0,0x6
ffffffffc02007f6:	64e50513          	addi	a0,a0,1614 # ffffffffc0206e40 <commands+0x778>
ffffffffc02007fa:	995ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00006517          	auipc	a0,0x6
ffffffffc0200804:	65850513          	addi	a0,a0,1624 # ffffffffc0206e58 <commands+0x790>
ffffffffc0200808:	987ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00006517          	auipc	a0,0x6
ffffffffc0200812:	66250513          	addi	a0,a0,1634 # ffffffffc0206e70 <commands+0x7a8>
ffffffffc0200816:	979ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	66c50513          	addi	a0,a0,1644 # ffffffffc0206e88 <commands+0x7c0>
ffffffffc0200824:	96bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00006517          	auipc	a0,0x6
ffffffffc020082e:	67650513          	addi	a0,a0,1654 # ffffffffc0206ea0 <commands+0x7d8>
ffffffffc0200832:	95dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	67c50513          	addi	a0,a0,1660 # ffffffffc0206eb8 <commands+0x7f0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	949ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00006517          	auipc	a0,0x6
ffffffffc0200856:	67e50513          	addi	a0,a0,1662 # ffffffffc0206ed0 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	933ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00006517          	auipc	a0,0x6
ffffffffc020086e:	67e50513          	addi	a0,a0,1662 # ffffffffc0206ee8 <commands+0x820>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	68650513          	addi	a0,a0,1670 # ffffffffc0206f00 <commands+0x838>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00006517          	auipc	a0,0x6
ffffffffc020088e:	68e50513          	addi	a0,a0,1678 # ffffffffc0206f18 <commands+0x850>
ffffffffc0200892:	8fdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00006517          	auipc	a0,0x6
ffffffffc02008a2:	68a50513          	addi	a0,a0,1674 # ffffffffc0206f28 <commands+0x860>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	8e7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	d5848493          	addi	s1,s1,-680 # ffffffffc02ac608 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	26a50513          	addi	a0,a0,618 # ffffffffc0206b50 <commands+0x488>
ffffffffc02008ee:	8a1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	bda78793          	addi	a5,a5,-1062 # ffffffffc02ac4d0 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	bd878793          	addi	a5,a5,-1064 # ffffffffc02ac4d8 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	7e90306f          	j	ffffffffc0204906 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	b9a78793          	addi	a5,a5,-1126 # ffffffffc02ac4d0 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	7b30306f          	j	ffffffffc0204906 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	21868693          	addi	a3,a3,536 # ffffffffc0206b70 <commands+0x4a8>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	22860613          	addi	a2,a2,552 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	23450513          	addi	a0,a0,564 # ffffffffc0206ba0 <commands+0x4d8>
ffffffffc0200974:	b11ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	1ae50513          	addi	a0,a0,430 # ffffffffc0206b50 <commands+0x488>
ffffffffc02009aa:	fe4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	20a60613          	addi	a2,a2,522 # ffffffffc0206bb8 <commands+0x4f0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	1e650513          	addi	a0,a0,486 # ffffffffc0206ba0 <commands+0x4d8>
ffffffffc02009c2:	ac3ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	ec870713          	addi	a4,a4,-312 # ffffffffc02068a4 <commands+0x1dc>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	12250513          	addi	a0,a0,290 # ffffffffc0206b10 <commands+0x448>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	0f650513          	addi	a0,a0,246 # ffffffffc0206af0 <commands+0x428>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	0aa50513          	addi	a0,a0,170 # ffffffffc0206ab0 <commands+0x3e8>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	0be50513          	addi	a0,a0,190 # ffffffffc0206ad0 <commands+0x408>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	11250513          	addi	a0,a0,274 # ffffffffc0206b30 <commands+0x468>
ffffffffc0200a26:	f68ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b3fff0ef          	jal	ra,ffffffffc020056c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	abe78793          	addi	a5,a5,-1346 # ffffffffc02ac4f0 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	aaf6b523          	sd	a5,-1366(a3) # ffffffffc02ac4f0 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	a8078793          	addi	a5,a5,-1408 # ffffffffc02ac4d0 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	e6070713          	addi	a4,a4,-416 # ffffffffc02068d4 <commands+0x20c>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	f7850513          	addi	a0,a0,-136 # ffffffffc0206a08 <commands+0x340>
ffffffffc0200a98:	ef6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	58c0506f          	j	ffffffffc020603a <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	f7650513          	addi	a0,a0,-138 # ffffffffc0206a28 <commands+0x360>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	eccff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	f8250513          	addi	a0,a0,-126 # ffffffffc0206a48 <commands+0x380>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	f9850513          	addi	a0,a0,-104 # ffffffffc0206a68 <commands+0x3a0>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	fa650513          	addi	a0,a0,-90 # ffffffffc0206a80 <commands+0x3b8>
ffffffffc0200ae2:	eacff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	f9c50513          	addi	a0,a0,-100 # ffffffffc0206a98 <commands+0x3d0>
ffffffffc0200b04:	e8aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	e9e60613          	addi	a2,a2,-354 # ffffffffc02069b8 <commands+0x2f0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	07a50513          	addi	a0,a0,122 # ffffffffc0206ba0 <commands+0x4d8>
ffffffffc0200b2e:	957ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	de650513          	addi	a0,a0,-538 # ffffffffc0206918 <commands+0x250>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	dfc50513          	addi	a0,a0,-516 # ffffffffc0206938 <commands+0x270>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	e1250513          	addi	a0,a0,-494 # ffffffffc0206958 <commands+0x290>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	e2050513          	addi	a0,a0,-480 # ffffffffc0206970 <commands+0x2a8>
ffffffffc0200b58:	e36ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	4cc050ef          	jal	ra,ffffffffc020603a <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	95e78793          	addi	a5,a5,-1698 # ffffffffc02ac4d0 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	df050513          	addi	a0,a0,-528 # ffffffffc0206980 <commands+0x2b8>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	e0650513          	addi	a0,a0,-506 # ffffffffc02069a0 <commands+0x2d8>
ffffffffc0200ba2:	decff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	e0060613          	addi	a2,a2,-512 # ffffffffc02069b8 <commands+0x2f0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206ba0 <commands+0x4d8>
ffffffffc0200bcc:	8b9ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	e2050513          	addi	a0,a0,-480 # ffffffffc02069f0 <commands+0x328>
ffffffffc0200bd8:	db6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	dc860613          	addi	a2,a2,-568 # ffffffffc02069b8 <commands+0x2f0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	fa450513          	addi	a0,a0,-92 # ffffffffc0206ba0 <commands+0x4d8>
ffffffffc0200c04:	881ff0ef          	jal	ra,ffffffffc0200484 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	dc460613          	addi	a2,a2,-572 # ffffffffc02069d8 <commands+0x310>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	f8050513          	addi	a0,a0,-128 # ffffffffc0206ba0 <commands+0x4d8>
ffffffffc0200c28:	85dff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	d8060613          	addi	a2,a2,-640 # ffffffffc02069b8 <commands+0x2f0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	f5c50513          	addi	a0,a0,-164 # ffffffffc0206ba0 <commands+0x4d8>
ffffffffc0200c4c:	839ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ac417          	auipc	s0,0xac
ffffffffc0200c58:	87c40413          	addi	s0,s0,-1924 # ffffffffc02ac4d0 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	2740506f          	j	ffffffffc0205f44 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	66c040ef          	jal	ra,ffffffffc0205342 <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e56:	000ab797          	auipc	a5,0xab
ffffffffc0200e5a:	6a278793          	addi	a5,a5,1698 # ffffffffc02ac4f8 <free_area>
ffffffffc0200e5e:	e79c                	sd	a5,8(a5)
ffffffffc0200e60:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e62:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e66:	8082                	ret

ffffffffc0200e68 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e68:	000ab517          	auipc	a0,0xab
ffffffffc0200e6c:	6a056503          	lwu	a0,1696(a0) # ffffffffc02ac508 <free_area+0x10>
ffffffffc0200e70:	8082                	ret

ffffffffc0200e72 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e72:	715d                	addi	sp,sp,-80
ffffffffc0200e74:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e76:	000ab917          	auipc	s2,0xab
ffffffffc0200e7a:	68290913          	addi	s2,s2,1666 # ffffffffc02ac4f8 <free_area>
ffffffffc0200e7e:	00893783          	ld	a5,8(s2)
ffffffffc0200e82:	e486                	sd	ra,72(sp)
ffffffffc0200e84:	e0a2                	sd	s0,64(sp)
ffffffffc0200e86:	fc26                	sd	s1,56(sp)
ffffffffc0200e88:	f44e                	sd	s3,40(sp)
ffffffffc0200e8a:	f052                	sd	s4,32(sp)
ffffffffc0200e8c:	ec56                	sd	s5,24(sp)
ffffffffc0200e8e:	e85a                	sd	s6,16(sp)
ffffffffc0200e90:	e45e                	sd	s7,8(sp)
ffffffffc0200e92:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e94:	31278463          	beq	a5,s2,ffffffffc020119c <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e98:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e9c:	8305                	srli	a4,a4,0x1
ffffffffc0200e9e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ea0:	30070263          	beqz	a4,ffffffffc02011a4 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200ea4:	4401                	li	s0,0
ffffffffc0200ea6:	4481                	li	s1,0
ffffffffc0200ea8:	a031                	j	ffffffffc0200eb4 <default_check+0x42>
ffffffffc0200eaa:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200eae:	8b09                	andi	a4,a4,2
ffffffffc0200eb0:	2e070a63          	beqz	a4,ffffffffc02011a4 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200eb4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200eb8:	679c                	ld	a5,8(a5)
ffffffffc0200eba:	2485                	addiw	s1,s1,1
ffffffffc0200ebc:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ebe:	ff2796e3          	bne	a5,s2,ffffffffc0200eaa <default_check+0x38>
ffffffffc0200ec2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200ec4:	05c010ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc0200ec8:	73351e63          	bne	a0,s3,ffffffffc0201604 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ecc:	4505                	li	a0,1
ffffffffc0200ece:	785000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ed2:	8a2a                	mv	s4,a0
ffffffffc0200ed4:	46050863          	beqz	a0,ffffffffc0201344 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ed8:	4505                	li	a0,1
ffffffffc0200eda:	779000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ede:	89aa                	mv	s3,a0
ffffffffc0200ee0:	74050263          	beqz	a0,ffffffffc0201624 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ee4:	4505                	li	a0,1
ffffffffc0200ee6:	76d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200eea:	8aaa                	mv	s5,a0
ffffffffc0200eec:	4c050c63          	beqz	a0,ffffffffc02013c4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ef0:	2d3a0a63          	beq	s4,s3,ffffffffc02011c4 <default_check+0x352>
ffffffffc0200ef4:	2caa0863          	beq	s4,a0,ffffffffc02011c4 <default_check+0x352>
ffffffffc0200ef8:	2ca98663          	beq	s3,a0,ffffffffc02011c4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200efc:	000a2783          	lw	a5,0(s4)
ffffffffc0200f00:	2e079263          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
ffffffffc0200f04:	0009a783          	lw	a5,0(s3)
ffffffffc0200f08:	2c079e63          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
ffffffffc0200f0c:	411c                	lw	a5,0(a0)
ffffffffc0200f0e:	2c079b63          	bnez	a5,ffffffffc02011e4 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f12:	000ab797          	auipc	a5,0xab
ffffffffc0200f16:	61678793          	addi	a5,a5,1558 # ffffffffc02ac528 <pages>
ffffffffc0200f1a:	639c                	ld	a5,0(a5)
ffffffffc0200f1c:	00008717          	auipc	a4,0x8
ffffffffc0200f20:	d8c70713          	addi	a4,a4,-628 # ffffffffc0208ca8 <nbase>
ffffffffc0200f24:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f26:	000ab717          	auipc	a4,0xab
ffffffffc0200f2a:	59270713          	addi	a4,a4,1426 # ffffffffc02ac4b8 <npage>
ffffffffc0200f2e:	6314                	ld	a3,0(a4)
ffffffffc0200f30:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f34:	8719                	srai	a4,a4,0x6
ffffffffc0200f36:	9732                	add	a4,a4,a2
ffffffffc0200f38:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f3a:	0732                	slli	a4,a4,0xc
ffffffffc0200f3c:	2cd77463          	bleu	a3,a4,ffffffffc0201204 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f40:	40f98733          	sub	a4,s3,a5
ffffffffc0200f44:	8719                	srai	a4,a4,0x6
ffffffffc0200f46:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f48:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f4a:	4ed77d63          	bleu	a3,a4,ffffffffc0201444 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f4e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f52:	8799                	srai	a5,a5,0x6
ffffffffc0200f54:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f56:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f58:	34d7f663          	bleu	a3,a5,ffffffffc02012a4 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f5c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f5e:	00093c03          	ld	s8,0(s2)
ffffffffc0200f62:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f66:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f6a:	000ab797          	auipc	a5,0xab
ffffffffc0200f6e:	5927bb23          	sd	s2,1430(a5) # ffffffffc02ac500 <free_area+0x8>
ffffffffc0200f72:	000ab797          	auipc	a5,0xab
ffffffffc0200f76:	5927b323          	sd	s2,1414(a5) # ffffffffc02ac4f8 <free_area>
    nr_free = 0;
ffffffffc0200f7a:	000ab797          	auipc	a5,0xab
ffffffffc0200f7e:	5807a723          	sw	zero,1422(a5) # ffffffffc02ac508 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	6d1000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200f86:	2e051f63          	bnez	a0,ffffffffc0201284 <default_check+0x412>
    free_page(p0);
ffffffffc0200f8a:	4585                	li	a1,1
ffffffffc0200f8c:	8552                	mv	a0,s4
ffffffffc0200f8e:	74d000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p1);
ffffffffc0200f92:	4585                	li	a1,1
ffffffffc0200f94:	854e                	mv	a0,s3
ffffffffc0200f96:	745000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc0200f9a:	4585                	li	a1,1
ffffffffc0200f9c:	8556                	mv	a0,s5
ffffffffc0200f9e:	73d000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(nr_free == 3);
ffffffffc0200fa2:	01092703          	lw	a4,16(s2)
ffffffffc0200fa6:	478d                	li	a5,3
ffffffffc0200fa8:	2af71e63          	bne	a4,a5,ffffffffc0201264 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fac:	4505                	li	a0,1
ffffffffc0200fae:	6a5000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fb2:	89aa                	mv	s3,a0
ffffffffc0200fb4:	28050863          	beqz	a0,ffffffffc0201244 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	699000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fbe:	8aaa                	mv	s5,a0
ffffffffc0200fc0:	3e050263          	beqz	a0,ffffffffc02013a4 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fc4:	4505                	li	a0,1
ffffffffc0200fc6:	68d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fca:	8a2a                	mv	s4,a0
ffffffffc0200fcc:	3a050c63          	beqz	a0,ffffffffc0201384 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	681000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200fd6:	38051763          	bnez	a0,ffffffffc0201364 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fda:	4585                	li	a1,1
ffffffffc0200fdc:	854e                	mv	a0,s3
ffffffffc0200fde:	6fd000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fe2:	00893783          	ld	a5,8(s2)
ffffffffc0200fe6:	23278f63          	beq	a5,s2,ffffffffc0201224 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fea:	4505                	li	a0,1
ffffffffc0200fec:	667000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ff0:	32a99a63          	bne	s3,a0,ffffffffc0201324 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200ff4:	4505                	li	a0,1
ffffffffc0200ff6:	65d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0200ffa:	30051563          	bnez	a0,ffffffffc0201304 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200ffe:	01092783          	lw	a5,16(s2)
ffffffffc0201002:	2e079163          	bnez	a5,ffffffffc02012e4 <default_check+0x472>
    free_page(p);
ffffffffc0201006:	854e                	mv	a0,s3
ffffffffc0201008:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020100a:	000ab797          	auipc	a5,0xab
ffffffffc020100e:	4f87b723          	sd	s8,1262(a5) # ffffffffc02ac4f8 <free_area>
ffffffffc0201012:	000ab797          	auipc	a5,0xab
ffffffffc0201016:	4f77b723          	sd	s7,1262(a5) # ffffffffc02ac500 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020101a:	000ab797          	auipc	a5,0xab
ffffffffc020101e:	4f67a723          	sw	s6,1262(a5) # ffffffffc02ac508 <free_area+0x10>
    free_page(p);
ffffffffc0201022:	6b9000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p1);
ffffffffc0201026:	4585                	li	a1,1
ffffffffc0201028:	8556                	mv	a0,s5
ffffffffc020102a:	6b1000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc020102e:	4585                	li	a1,1
ffffffffc0201030:	8552                	mv	a0,s4
ffffffffc0201032:	6a9000ef          	jal	ra,ffffffffc0201eda <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201036:	4515                	li	a0,5
ffffffffc0201038:	61b000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020103c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020103e:	28050363          	beqz	a0,ffffffffc02012c4 <default_check+0x452>
ffffffffc0201042:	651c                	ld	a5,8(a0)
ffffffffc0201044:	8385                	srli	a5,a5,0x1
ffffffffc0201046:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201048:	54079e63          	bnez	a5,ffffffffc02015a4 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020104c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020104e:	00093b03          	ld	s6,0(s2)
ffffffffc0201052:	00893a83          	ld	s5,8(s2)
ffffffffc0201056:	000ab797          	auipc	a5,0xab
ffffffffc020105a:	4b27b123          	sd	s2,1186(a5) # ffffffffc02ac4f8 <free_area>
ffffffffc020105e:	000ab797          	auipc	a5,0xab
ffffffffc0201062:	4b27b123          	sd	s2,1186(a5) # ffffffffc02ac500 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201066:	5ed000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020106a:	50051d63          	bnez	a0,ffffffffc0201584 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020106e:	08098a13          	addi	s4,s3,128
ffffffffc0201072:	8552                	mv	a0,s4
ffffffffc0201074:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201076:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020107a:	000ab797          	auipc	a5,0xab
ffffffffc020107e:	4807a723          	sw	zero,1166(a5) # ffffffffc02ac508 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201082:	659000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201086:	4511                	li	a0,4
ffffffffc0201088:	5cb000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020108c:	4c051c63          	bnez	a0,ffffffffc0201564 <default_check+0x6f2>
ffffffffc0201090:	0889b783          	ld	a5,136(s3)
ffffffffc0201094:	8385                	srli	a5,a5,0x1
ffffffffc0201096:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201098:	4a078663          	beqz	a5,ffffffffc0201544 <default_check+0x6d2>
ffffffffc020109c:	0909a703          	lw	a4,144(s3)
ffffffffc02010a0:	478d                	li	a5,3
ffffffffc02010a2:	4af71163          	bne	a4,a5,ffffffffc0201544 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02010a6:	450d                	li	a0,3
ffffffffc02010a8:	5ab000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02010ac:	8c2a                	mv	s8,a0
ffffffffc02010ae:	46050b63          	beqz	a0,ffffffffc0201524 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010b2:	4505                	li	a0,1
ffffffffc02010b4:	59f000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02010b8:	44051663          	bnez	a0,ffffffffc0201504 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010bc:	438a1463          	bne	s4,s8,ffffffffc02014e4 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010c0:	4585                	li	a1,1
ffffffffc02010c2:	854e                	mv	a0,s3
ffffffffc02010c4:	617000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_pages(p1, 3);
ffffffffc02010c8:	458d                	li	a1,3
ffffffffc02010ca:	8552                	mv	a0,s4
ffffffffc02010cc:	60f000ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc02010d0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010d4:	04098c13          	addi	s8,s3,64
ffffffffc02010d8:	8385                	srli	a5,a5,0x1
ffffffffc02010da:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010dc:	3e078463          	beqz	a5,ffffffffc02014c4 <default_check+0x652>
ffffffffc02010e0:	0109a703          	lw	a4,16(s3)
ffffffffc02010e4:	4785                	li	a5,1
ffffffffc02010e6:	3cf71f63          	bne	a4,a5,ffffffffc02014c4 <default_check+0x652>
ffffffffc02010ea:	008a3783          	ld	a5,8(s4)
ffffffffc02010ee:	8385                	srli	a5,a5,0x1
ffffffffc02010f0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010f2:	3a078963          	beqz	a5,ffffffffc02014a4 <default_check+0x632>
ffffffffc02010f6:	010a2703          	lw	a4,16(s4)
ffffffffc02010fa:	478d                	li	a5,3
ffffffffc02010fc:	3af71463          	bne	a4,a5,ffffffffc02014a4 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201100:	4505                	li	a0,1
ffffffffc0201102:	551000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201106:	36a99f63          	bne	s3,a0,ffffffffc0201484 <default_check+0x612>
    free_page(p0);
ffffffffc020110a:	4585                	li	a1,1
ffffffffc020110c:	5cf000ef          	jal	ra,ffffffffc0201eda <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201110:	4509                	li	a0,2
ffffffffc0201112:	541000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201116:	34aa1763          	bne	s4,a0,ffffffffc0201464 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020111a:	4589                	li	a1,2
ffffffffc020111c:	5bf000ef          	jal	ra,ffffffffc0201eda <free_pages>
    free_page(p2);
ffffffffc0201120:	4585                	li	a1,1
ffffffffc0201122:	8562                	mv	a0,s8
ffffffffc0201124:	5b7000ef          	jal	ra,ffffffffc0201eda <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201128:	4515                	li	a0,5
ffffffffc020112a:	529000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020112e:	89aa                	mv	s3,a0
ffffffffc0201130:	48050a63          	beqz	a0,ffffffffc02015c4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201134:	4505                	li	a0,1
ffffffffc0201136:	51d000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020113a:	2e051563          	bnez	a0,ffffffffc0201424 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020113e:	01092783          	lw	a5,16(s2)
ffffffffc0201142:	2c079163          	bnez	a5,ffffffffc0201404 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201146:	4595                	li	a1,5
ffffffffc0201148:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020114a:	000ab797          	auipc	a5,0xab
ffffffffc020114e:	3b77af23          	sw	s7,958(a5) # ffffffffc02ac508 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201152:	000ab797          	auipc	a5,0xab
ffffffffc0201156:	3b67b323          	sd	s6,934(a5) # ffffffffc02ac4f8 <free_area>
ffffffffc020115a:	000ab797          	auipc	a5,0xab
ffffffffc020115e:	3b57b323          	sd	s5,934(a5) # ffffffffc02ac500 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201162:	579000ef          	jal	ra,ffffffffc0201eda <free_pages>
    return listelm->next;
ffffffffc0201166:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020116a:	01278963          	beq	a5,s2,ffffffffc020117c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020116e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201172:	679c                	ld	a5,8(a5)
ffffffffc0201174:	34fd                	addiw	s1,s1,-1
ffffffffc0201176:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201178:	ff279be3          	bne	a5,s2,ffffffffc020116e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020117c:	26049463          	bnez	s1,ffffffffc02013e4 <default_check+0x572>
    assert(total == 0);
ffffffffc0201180:	46041263          	bnez	s0,ffffffffc02015e4 <default_check+0x772>
}
ffffffffc0201184:	60a6                	ld	ra,72(sp)
ffffffffc0201186:	6406                	ld	s0,64(sp)
ffffffffc0201188:	74e2                	ld	s1,56(sp)
ffffffffc020118a:	7942                	ld	s2,48(sp)
ffffffffc020118c:	79a2                	ld	s3,40(sp)
ffffffffc020118e:	7a02                	ld	s4,32(sp)
ffffffffc0201190:	6ae2                	ld	s5,24(sp)
ffffffffc0201192:	6b42                	ld	s6,16(sp)
ffffffffc0201194:	6ba2                	ld	s7,8(sp)
ffffffffc0201196:	6c02                	ld	s8,0(sp)
ffffffffc0201198:	6161                	addi	sp,sp,80
ffffffffc020119a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020119c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020119e:	4401                	li	s0,0
ffffffffc02011a0:	4481                	li	s1,0
ffffffffc02011a2:	b30d                	j	ffffffffc0200ec4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02011a4:	00006697          	auipc	a3,0x6
ffffffffc02011a8:	d9c68693          	addi	a3,a3,-612 # ffffffffc0206f40 <commands+0x878>
ffffffffc02011ac:	00006617          	auipc	a2,0x6
ffffffffc02011b0:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02011b4:	0f000593          	li	a1,240
ffffffffc02011b8:	00006517          	auipc	a0,0x6
ffffffffc02011bc:	d9850513          	addi	a0,a0,-616 # ffffffffc0206f50 <commands+0x888>
ffffffffc02011c0:	ac4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011c4:	00006697          	auipc	a3,0x6
ffffffffc02011c8:	e2468693          	addi	a3,a3,-476 # ffffffffc0206fe8 <commands+0x920>
ffffffffc02011cc:	00006617          	auipc	a2,0x6
ffffffffc02011d0:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02011d4:	0bd00593          	li	a1,189
ffffffffc02011d8:	00006517          	auipc	a0,0x6
ffffffffc02011dc:	d7850513          	addi	a0,a0,-648 # ffffffffc0206f50 <commands+0x888>
ffffffffc02011e0:	aa4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011e4:	00006697          	auipc	a3,0x6
ffffffffc02011e8:	e2c68693          	addi	a3,a3,-468 # ffffffffc0207010 <commands+0x948>
ffffffffc02011ec:	00006617          	auipc	a2,0x6
ffffffffc02011f0:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02011f4:	0be00593          	li	a1,190
ffffffffc02011f8:	00006517          	auipc	a0,0x6
ffffffffc02011fc:	d5850513          	addi	a0,a0,-680 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201200:	a84ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201204:	00006697          	auipc	a3,0x6
ffffffffc0201208:	e4c68693          	addi	a3,a3,-436 # ffffffffc0207050 <commands+0x988>
ffffffffc020120c:	00006617          	auipc	a2,0x6
ffffffffc0201210:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201214:	0c000593          	li	a1,192
ffffffffc0201218:	00006517          	auipc	a0,0x6
ffffffffc020121c:	d3850513          	addi	a0,a0,-712 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201220:	a64ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201224:	00006697          	auipc	a3,0x6
ffffffffc0201228:	eb468693          	addi	a3,a3,-332 # ffffffffc02070d8 <commands+0xa10>
ffffffffc020122c:	00006617          	auipc	a2,0x6
ffffffffc0201230:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201234:	0d900593          	li	a1,217
ffffffffc0201238:	00006517          	auipc	a0,0x6
ffffffffc020123c:	d1850513          	addi	a0,a0,-744 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201240:	a44ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201244:	00006697          	auipc	a3,0x6
ffffffffc0201248:	d4468693          	addi	a3,a3,-700 # ffffffffc0206f88 <commands+0x8c0>
ffffffffc020124c:	00006617          	auipc	a2,0x6
ffffffffc0201250:	93c60613          	addi	a2,a2,-1732 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201254:	0d200593          	li	a1,210
ffffffffc0201258:	00006517          	auipc	a0,0x6
ffffffffc020125c:	cf850513          	addi	a0,a0,-776 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201260:	a24ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 3);
ffffffffc0201264:	00006697          	auipc	a3,0x6
ffffffffc0201268:	e6468693          	addi	a3,a3,-412 # ffffffffc02070c8 <commands+0xa00>
ffffffffc020126c:	00006617          	auipc	a2,0x6
ffffffffc0201270:	91c60613          	addi	a2,a2,-1764 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201274:	0d000593          	li	a1,208
ffffffffc0201278:	00006517          	auipc	a0,0x6
ffffffffc020127c:	cd850513          	addi	a0,a0,-808 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201280:	a04ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201284:	00006697          	auipc	a3,0x6
ffffffffc0201288:	e2c68693          	addi	a3,a3,-468 # ffffffffc02070b0 <commands+0x9e8>
ffffffffc020128c:	00006617          	auipc	a2,0x6
ffffffffc0201290:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201294:	0cb00593          	li	a1,203
ffffffffc0201298:	00006517          	auipc	a0,0x6
ffffffffc020129c:	cb850513          	addi	a0,a0,-840 # ffffffffc0206f50 <commands+0x888>
ffffffffc02012a0:	9e4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012a4:	00006697          	auipc	a3,0x6
ffffffffc02012a8:	dec68693          	addi	a3,a3,-532 # ffffffffc0207090 <commands+0x9c8>
ffffffffc02012ac:	00006617          	auipc	a2,0x6
ffffffffc02012b0:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02012b4:	0c200593          	li	a1,194
ffffffffc02012b8:	00006517          	auipc	a0,0x6
ffffffffc02012bc:	c9850513          	addi	a0,a0,-872 # ffffffffc0206f50 <commands+0x888>
ffffffffc02012c0:	9c4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != NULL);
ffffffffc02012c4:	00006697          	auipc	a3,0x6
ffffffffc02012c8:	e5c68693          	addi	a3,a3,-420 # ffffffffc0207120 <commands+0xa58>
ffffffffc02012cc:	00006617          	auipc	a2,0x6
ffffffffc02012d0:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02012d4:	0f800593          	li	a1,248
ffffffffc02012d8:	00006517          	auipc	a0,0x6
ffffffffc02012dc:	c7850513          	addi	a0,a0,-904 # ffffffffc0206f50 <commands+0x888>
ffffffffc02012e0:	9a4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc02012e4:	00006697          	auipc	a3,0x6
ffffffffc02012e8:	e2c68693          	addi	a3,a3,-468 # ffffffffc0207110 <commands+0xa48>
ffffffffc02012ec:	00006617          	auipc	a2,0x6
ffffffffc02012f0:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02012f4:	0df00593          	li	a1,223
ffffffffc02012f8:	00006517          	auipc	a0,0x6
ffffffffc02012fc:	c5850513          	addi	a0,a0,-936 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201300:	984ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201304:	00006697          	auipc	a3,0x6
ffffffffc0201308:	dac68693          	addi	a3,a3,-596 # ffffffffc02070b0 <commands+0x9e8>
ffffffffc020130c:	00006617          	auipc	a2,0x6
ffffffffc0201310:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201314:	0dd00593          	li	a1,221
ffffffffc0201318:	00006517          	auipc	a0,0x6
ffffffffc020131c:	c3850513          	addi	a0,a0,-968 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201320:	964ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201324:	00006697          	auipc	a3,0x6
ffffffffc0201328:	dcc68693          	addi	a3,a3,-564 # ffffffffc02070f0 <commands+0xa28>
ffffffffc020132c:	00006617          	auipc	a2,0x6
ffffffffc0201330:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201334:	0dc00593          	li	a1,220
ffffffffc0201338:	00006517          	auipc	a0,0x6
ffffffffc020133c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201340:	944ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201344:	00006697          	auipc	a3,0x6
ffffffffc0201348:	c4468693          	addi	a3,a3,-956 # ffffffffc0206f88 <commands+0x8c0>
ffffffffc020134c:	00006617          	auipc	a2,0x6
ffffffffc0201350:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201354:	0b900593          	li	a1,185
ffffffffc0201358:	00006517          	auipc	a0,0x6
ffffffffc020135c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201360:	924ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201364:	00006697          	auipc	a3,0x6
ffffffffc0201368:	d4c68693          	addi	a3,a3,-692 # ffffffffc02070b0 <commands+0x9e8>
ffffffffc020136c:	00006617          	auipc	a2,0x6
ffffffffc0201370:	81c60613          	addi	a2,a2,-2020 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201374:	0d600593          	li	a1,214
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201380:	904ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201384:	00006697          	auipc	a3,0x6
ffffffffc0201388:	c4468693          	addi	a3,a3,-956 # ffffffffc0206fc8 <commands+0x900>
ffffffffc020138c:	00005617          	auipc	a2,0x5
ffffffffc0201390:	7fc60613          	addi	a2,a2,2044 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201394:	0d400593          	li	a1,212
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	bb850513          	addi	a0,a0,-1096 # ffffffffc0206f50 <commands+0x888>
ffffffffc02013a0:	8e4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013a4:	00006697          	auipc	a3,0x6
ffffffffc02013a8:	c0468693          	addi	a3,a3,-1020 # ffffffffc0206fa8 <commands+0x8e0>
ffffffffc02013ac:	00005617          	auipc	a2,0x5
ffffffffc02013b0:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02013b4:	0d300593          	li	a1,211
ffffffffc02013b8:	00006517          	auipc	a0,0x6
ffffffffc02013bc:	b9850513          	addi	a0,a0,-1128 # ffffffffc0206f50 <commands+0x888>
ffffffffc02013c0:	8c4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013c4:	00006697          	auipc	a3,0x6
ffffffffc02013c8:	c0468693          	addi	a3,a3,-1020 # ffffffffc0206fc8 <commands+0x900>
ffffffffc02013cc:	00005617          	auipc	a2,0x5
ffffffffc02013d0:	7bc60613          	addi	a2,a2,1980 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02013d4:	0bb00593          	li	a1,187
ffffffffc02013d8:	00006517          	auipc	a0,0x6
ffffffffc02013dc:	b7850513          	addi	a0,a0,-1160 # ffffffffc0206f50 <commands+0x888>
ffffffffc02013e0:	8a4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(count == 0);
ffffffffc02013e4:	00006697          	auipc	a3,0x6
ffffffffc02013e8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0207270 <commands+0xba8>
ffffffffc02013ec:	00005617          	auipc	a2,0x5
ffffffffc02013f0:	79c60613          	addi	a2,a2,1948 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02013f4:	12500593          	li	a1,293
ffffffffc02013f8:	00006517          	auipc	a0,0x6
ffffffffc02013fc:	b5850513          	addi	a0,a0,-1192 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201400:	884ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc0201404:	00006697          	auipc	a3,0x6
ffffffffc0201408:	d0c68693          	addi	a3,a3,-756 # ffffffffc0207110 <commands+0xa48>
ffffffffc020140c:	00005617          	auipc	a2,0x5
ffffffffc0201410:	77c60613          	addi	a2,a2,1916 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201414:	11a00593          	li	a1,282
ffffffffc0201418:	00006517          	auipc	a0,0x6
ffffffffc020141c:	b3850513          	addi	a0,a0,-1224 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201420:	864ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201424:	00006697          	auipc	a3,0x6
ffffffffc0201428:	c8c68693          	addi	a3,a3,-884 # ffffffffc02070b0 <commands+0x9e8>
ffffffffc020142c:	00005617          	auipc	a2,0x5
ffffffffc0201430:	75c60613          	addi	a2,a2,1884 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201434:	11800593          	li	a1,280
ffffffffc0201438:	00006517          	auipc	a0,0x6
ffffffffc020143c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201440:	844ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201444:	00006697          	auipc	a3,0x6
ffffffffc0201448:	c2c68693          	addi	a3,a3,-980 # ffffffffc0207070 <commands+0x9a8>
ffffffffc020144c:	00005617          	auipc	a2,0x5
ffffffffc0201450:	73c60613          	addi	a2,a2,1852 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201454:	0c100593          	li	a1,193
ffffffffc0201458:	00006517          	auipc	a0,0x6
ffffffffc020145c:	af850513          	addi	a0,a0,-1288 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201460:	824ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201464:	00006697          	auipc	a3,0x6
ffffffffc0201468:	dcc68693          	addi	a3,a3,-564 # ffffffffc0207230 <commands+0xb68>
ffffffffc020146c:	00005617          	auipc	a2,0x5
ffffffffc0201470:	71c60613          	addi	a2,a2,1820 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201474:	11200593          	li	a1,274
ffffffffc0201478:	00006517          	auipc	a0,0x6
ffffffffc020147c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201480:	804ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201484:	00006697          	auipc	a3,0x6
ffffffffc0201488:	d8c68693          	addi	a3,a3,-628 # ffffffffc0207210 <commands+0xb48>
ffffffffc020148c:	00005617          	auipc	a2,0x5
ffffffffc0201490:	6fc60613          	addi	a2,a2,1788 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201494:	11000593          	li	a1,272
ffffffffc0201498:	00006517          	auipc	a0,0x6
ffffffffc020149c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0206f50 <commands+0x888>
ffffffffc02014a0:	fe5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014a4:	00006697          	auipc	a3,0x6
ffffffffc02014a8:	d4468693          	addi	a3,a3,-700 # ffffffffc02071e8 <commands+0xb20>
ffffffffc02014ac:	00005617          	auipc	a2,0x5
ffffffffc02014b0:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02014b4:	10e00593          	li	a1,270
ffffffffc02014b8:	00006517          	auipc	a0,0x6
ffffffffc02014bc:	a9850513          	addi	a0,a0,-1384 # ffffffffc0206f50 <commands+0x888>
ffffffffc02014c0:	fc5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014c4:	00006697          	auipc	a3,0x6
ffffffffc02014c8:	cfc68693          	addi	a3,a3,-772 # ffffffffc02071c0 <commands+0xaf8>
ffffffffc02014cc:	00005617          	auipc	a2,0x5
ffffffffc02014d0:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02014d4:	10d00593          	li	a1,269
ffffffffc02014d8:	00006517          	auipc	a0,0x6
ffffffffc02014dc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0206f50 <commands+0x888>
ffffffffc02014e0:	fa5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014e4:	00006697          	auipc	a3,0x6
ffffffffc02014e8:	ccc68693          	addi	a3,a3,-820 # ffffffffc02071b0 <commands+0xae8>
ffffffffc02014ec:	00005617          	auipc	a2,0x5
ffffffffc02014f0:	69c60613          	addi	a2,a2,1692 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02014f4:	10800593          	li	a1,264
ffffffffc02014f8:	00006517          	auipc	a0,0x6
ffffffffc02014fc:	a5850513          	addi	a0,a0,-1448 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201500:	f85fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201504:	00006697          	auipc	a3,0x6
ffffffffc0201508:	bac68693          	addi	a3,a3,-1108 # ffffffffc02070b0 <commands+0x9e8>
ffffffffc020150c:	00005617          	auipc	a2,0x5
ffffffffc0201510:	67c60613          	addi	a2,a2,1660 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201514:	10700593          	li	a1,263
ffffffffc0201518:	00006517          	auipc	a0,0x6
ffffffffc020151c:	a3850513          	addi	a0,a0,-1480 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201520:	f65fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201524:	00006697          	auipc	a3,0x6
ffffffffc0201528:	c6c68693          	addi	a3,a3,-916 # ffffffffc0207190 <commands+0xac8>
ffffffffc020152c:	00005617          	auipc	a2,0x5
ffffffffc0201530:	65c60613          	addi	a2,a2,1628 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201534:	10600593          	li	a1,262
ffffffffc0201538:	00006517          	auipc	a0,0x6
ffffffffc020153c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201540:	f45fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201544:	00006697          	auipc	a3,0x6
ffffffffc0201548:	c1c68693          	addi	a3,a3,-996 # ffffffffc0207160 <commands+0xa98>
ffffffffc020154c:	00005617          	auipc	a2,0x5
ffffffffc0201550:	63c60613          	addi	a2,a2,1596 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201554:	10500593          	li	a1,261
ffffffffc0201558:	00006517          	auipc	a0,0x6
ffffffffc020155c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201560:	f25fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201564:	00006697          	auipc	a3,0x6
ffffffffc0201568:	be468693          	addi	a3,a3,-1052 # ffffffffc0207148 <commands+0xa80>
ffffffffc020156c:	00005617          	auipc	a2,0x5
ffffffffc0201570:	61c60613          	addi	a2,a2,1564 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201574:	10400593          	li	a1,260
ffffffffc0201578:	00006517          	auipc	a0,0x6
ffffffffc020157c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201580:	f05fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201584:	00006697          	auipc	a3,0x6
ffffffffc0201588:	b2c68693          	addi	a3,a3,-1236 # ffffffffc02070b0 <commands+0x9e8>
ffffffffc020158c:	00005617          	auipc	a2,0x5
ffffffffc0201590:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201594:	0fe00593          	li	a1,254
ffffffffc0201598:	00006517          	auipc	a0,0x6
ffffffffc020159c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0206f50 <commands+0x888>
ffffffffc02015a0:	ee5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!PageProperty(p0));
ffffffffc02015a4:	00006697          	auipc	a3,0x6
ffffffffc02015a8:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0207130 <commands+0xa68>
ffffffffc02015ac:	00005617          	auipc	a2,0x5
ffffffffc02015b0:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02015b4:	0f900593          	li	a1,249
ffffffffc02015b8:	00006517          	auipc	a0,0x6
ffffffffc02015bc:	99850513          	addi	a0,a0,-1640 # ffffffffc0206f50 <commands+0x888>
ffffffffc02015c0:	ec5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015c4:	00006697          	auipc	a3,0x6
ffffffffc02015c8:	c8c68693          	addi	a3,a3,-884 # ffffffffc0207250 <commands+0xb88>
ffffffffc02015cc:	00005617          	auipc	a2,0x5
ffffffffc02015d0:	5bc60613          	addi	a2,a2,1468 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02015d4:	11700593          	li	a1,279
ffffffffc02015d8:	00006517          	auipc	a0,0x6
ffffffffc02015dc:	97850513          	addi	a0,a0,-1672 # ffffffffc0206f50 <commands+0x888>
ffffffffc02015e0:	ea5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == 0);
ffffffffc02015e4:	00006697          	auipc	a3,0x6
ffffffffc02015e8:	c9c68693          	addi	a3,a3,-868 # ffffffffc0207280 <commands+0xbb8>
ffffffffc02015ec:	00005617          	auipc	a2,0x5
ffffffffc02015f0:	59c60613          	addi	a2,a2,1436 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02015f4:	12600593          	li	a1,294
ffffffffc02015f8:	00006517          	auipc	a0,0x6
ffffffffc02015fc:	95850513          	addi	a0,a0,-1704 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201600:	e85fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201604:	00006697          	auipc	a3,0x6
ffffffffc0201608:	96468693          	addi	a3,a3,-1692 # ffffffffc0206f68 <commands+0x8a0>
ffffffffc020160c:	00005617          	auipc	a2,0x5
ffffffffc0201610:	57c60613          	addi	a2,a2,1404 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201614:	0f300593          	li	a1,243
ffffffffc0201618:	00006517          	auipc	a0,0x6
ffffffffc020161c:	93850513          	addi	a0,a0,-1736 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201620:	e65fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201624:	00006697          	auipc	a3,0x6
ffffffffc0201628:	98468693          	addi	a3,a3,-1660 # ffffffffc0206fa8 <commands+0x8e0>
ffffffffc020162c:	00005617          	auipc	a2,0x5
ffffffffc0201630:	55c60613          	addi	a2,a2,1372 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201634:	0ba00593          	li	a1,186
ffffffffc0201638:	00006517          	auipc	a0,0x6
ffffffffc020163c:	91850513          	addi	a0,a0,-1768 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201640:	e45fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201644 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201644:	1141                	addi	sp,sp,-16
ffffffffc0201646:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201648:	16058e63          	beqz	a1,ffffffffc02017c4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020164c:	00659693          	slli	a3,a1,0x6
ffffffffc0201650:	96aa                	add	a3,a3,a0
ffffffffc0201652:	02d50d63          	beq	a0,a3,ffffffffc020168c <default_free_pages+0x48>
ffffffffc0201656:	651c                	ld	a5,8(a0)
ffffffffc0201658:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020165a:	14079563          	bnez	a5,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc020165e:	651c                	ld	a5,8(a0)
ffffffffc0201660:	8385                	srli	a5,a5,0x1
ffffffffc0201662:	8b85                	andi	a5,a5,1
ffffffffc0201664:	14079063          	bnez	a5,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc0201668:	87aa                	mv	a5,a0
ffffffffc020166a:	a809                	j	ffffffffc020167c <default_free_pages+0x38>
ffffffffc020166c:	6798                	ld	a4,8(a5)
ffffffffc020166e:	8b05                	andi	a4,a4,1
ffffffffc0201670:	12071a63          	bnez	a4,ffffffffc02017a4 <default_free_pages+0x160>
ffffffffc0201674:	6798                	ld	a4,8(a5)
ffffffffc0201676:	8b09                	andi	a4,a4,2
ffffffffc0201678:	12071663          	bnez	a4,ffffffffc02017a4 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020167c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201680:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201684:	04078793          	addi	a5,a5,64
ffffffffc0201688:	fed792e3          	bne	a5,a3,ffffffffc020166c <default_free_pages+0x28>
    base->property = n;
ffffffffc020168c:	2581                	sext.w	a1,a1
ffffffffc020168e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201690:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201694:	4789                	li	a5,2
ffffffffc0201696:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020169a:	000ab697          	auipc	a3,0xab
ffffffffc020169e:	e5e68693          	addi	a3,a3,-418 # ffffffffc02ac4f8 <free_area>
ffffffffc02016a2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02016a4:	669c                	ld	a5,8(a3)
ffffffffc02016a6:	9db9                	addw	a1,a1,a4
ffffffffc02016a8:	000ab717          	auipc	a4,0xab
ffffffffc02016ac:	e6b72023          	sw	a1,-416(a4) # ffffffffc02ac508 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016b0:	0cd78163          	beq	a5,a3,ffffffffc0201772 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016b4:	fe878713          	addi	a4,a5,-24
ffffffffc02016b8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016ba:	4801                	li	a6,0
ffffffffc02016bc:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016c0:	00e56a63          	bltu	a0,a4,ffffffffc02016d4 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016c4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016c6:	04d70f63          	beq	a4,a3,ffffffffc0201724 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ca:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016cc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016d0:	fee57ae3          	bleu	a4,a0,ffffffffc02016c4 <default_free_pages+0x80>
ffffffffc02016d4:	00080663          	beqz	a6,ffffffffc02016e0 <default_free_pages+0x9c>
ffffffffc02016d8:	000ab817          	auipc	a6,0xab
ffffffffc02016dc:	e2b83023          	sd	a1,-480(a6) # ffffffffc02ac4f8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016e0:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016e2:	e390                	sd	a2,0(a5)
ffffffffc02016e4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016e6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016e8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016ea:	06d58a63          	beq	a1,a3,ffffffffc020175e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016ee:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016f2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016f6:	02061793          	slli	a5,a2,0x20
ffffffffc02016fa:	83e9                	srli	a5,a5,0x1a
ffffffffc02016fc:	97ba                	add	a5,a5,a4
ffffffffc02016fe:	04f51b63          	bne	a0,a5,ffffffffc0201754 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201702:	491c                	lw	a5,16(a0)
ffffffffc0201704:	9e3d                	addw	a2,a2,a5
ffffffffc0201706:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020170a:	57f5                	li	a5,-3
ffffffffc020170c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201710:	01853803          	ld	a6,24(a0)
ffffffffc0201714:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201716:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201718:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020171c:	659c                	ld	a5,8(a1)
ffffffffc020171e:	01063023          	sd	a6,0(a2)
ffffffffc0201722:	a815                	j	ffffffffc0201756 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201724:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201726:	f114                	sd	a3,32(a0)
ffffffffc0201728:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020172a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020172c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020172e:	00d70563          	beq	a4,a3,ffffffffc0201738 <default_free_pages+0xf4>
ffffffffc0201732:	4805                	li	a6,1
ffffffffc0201734:	87ba                	mv	a5,a4
ffffffffc0201736:	bf59                	j	ffffffffc02016cc <default_free_pages+0x88>
ffffffffc0201738:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020173a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020173c:	00d78d63          	beq	a5,a3,ffffffffc0201756 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201740:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201744:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201748:	02061793          	slli	a5,a2,0x20
ffffffffc020174c:	83e9                	srli	a5,a5,0x1a
ffffffffc020174e:	97ba                	add	a5,a5,a4
ffffffffc0201750:	faf509e3          	beq	a0,a5,ffffffffc0201702 <default_free_pages+0xbe>
ffffffffc0201754:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201756:	fe878713          	addi	a4,a5,-24
ffffffffc020175a:	00d78963          	beq	a5,a3,ffffffffc020176c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020175e:	4910                	lw	a2,16(a0)
ffffffffc0201760:	02061693          	slli	a3,a2,0x20
ffffffffc0201764:	82e9                	srli	a3,a3,0x1a
ffffffffc0201766:	96aa                	add	a3,a3,a0
ffffffffc0201768:	00d70e63          	beq	a4,a3,ffffffffc0201784 <default_free_pages+0x140>
}
ffffffffc020176c:	60a2                	ld	ra,8(sp)
ffffffffc020176e:	0141                	addi	sp,sp,16
ffffffffc0201770:	8082                	ret
ffffffffc0201772:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201774:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201778:	e398                	sd	a4,0(a5)
ffffffffc020177a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020177c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020177e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201780:	0141                	addi	sp,sp,16
ffffffffc0201782:	8082                	ret
            base->property += p->property;
ffffffffc0201784:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201788:	ff078693          	addi	a3,a5,-16
ffffffffc020178c:	9e39                	addw	a2,a2,a4
ffffffffc020178e:	c910                	sw	a2,16(a0)
ffffffffc0201790:	5775                	li	a4,-3
ffffffffc0201792:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201796:	6398                	ld	a4,0(a5)
ffffffffc0201798:	679c                	ld	a5,8(a5)
}
ffffffffc020179a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020179c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020179e:	e398                	sd	a4,0(a5)
ffffffffc02017a0:	0141                	addi	sp,sp,16
ffffffffc02017a2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017a4:	00006697          	auipc	a3,0x6
ffffffffc02017a8:	aec68693          	addi	a3,a3,-1300 # ffffffffc0207290 <commands+0xbc8>
ffffffffc02017ac:	00005617          	auipc	a2,0x5
ffffffffc02017b0:	3dc60613          	addi	a2,a2,988 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02017b4:	08300593          	li	a1,131
ffffffffc02017b8:	00005517          	auipc	a0,0x5
ffffffffc02017bc:	79850513          	addi	a0,a0,1944 # ffffffffc0206f50 <commands+0x888>
ffffffffc02017c0:	cc5fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc02017c4:	00006697          	auipc	a3,0x6
ffffffffc02017c8:	af468693          	addi	a3,a3,-1292 # ffffffffc02072b8 <commands+0xbf0>
ffffffffc02017cc:	00005617          	auipc	a2,0x5
ffffffffc02017d0:	3bc60613          	addi	a2,a2,956 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02017d4:	08000593          	li	a1,128
ffffffffc02017d8:	00005517          	auipc	a0,0x5
ffffffffc02017dc:	77850513          	addi	a0,a0,1912 # ffffffffc0206f50 <commands+0x888>
ffffffffc02017e0:	ca5fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02017e4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017e4:	c959                	beqz	a0,ffffffffc020187a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017e6:	000ab597          	auipc	a1,0xab
ffffffffc02017ea:	d1258593          	addi	a1,a1,-750 # ffffffffc02ac4f8 <free_area>
ffffffffc02017ee:	0105a803          	lw	a6,16(a1)
ffffffffc02017f2:	862a                	mv	a2,a0
ffffffffc02017f4:	02081793          	slli	a5,a6,0x20
ffffffffc02017f8:	9381                	srli	a5,a5,0x20
ffffffffc02017fa:	00a7ee63          	bltu	a5,a0,ffffffffc0201816 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017fe:	87ae                	mv	a5,a1
ffffffffc0201800:	a801                	j	ffffffffc0201810 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201802:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201806:	02071693          	slli	a3,a4,0x20
ffffffffc020180a:	9281                	srli	a3,a3,0x20
ffffffffc020180c:	00c6f763          	bleu	a2,a3,ffffffffc020181a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201810:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201812:	feb798e3          	bne	a5,a1,ffffffffc0201802 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201816:	4501                	li	a0,0
}
ffffffffc0201818:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020181a:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020181e:	dd6d                	beqz	a0,ffffffffc0201818 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201820:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201824:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201828:	00060e1b          	sext.w	t3,a2
ffffffffc020182c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201830:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201834:	02d67863          	bleu	a3,a2,ffffffffc0201864 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201838:	061a                	slli	a2,a2,0x6
ffffffffc020183a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020183c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201840:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201842:	00860693          	addi	a3,a2,8
ffffffffc0201846:	4709                	li	a4,2
ffffffffc0201848:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020184c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201850:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201854:	0105a803          	lw	a6,16(a1)
ffffffffc0201858:	e314                	sd	a3,0(a4)
ffffffffc020185a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020185e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201860:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201864:	41c8083b          	subw	a6,a6,t3
ffffffffc0201868:	000ab717          	auipc	a4,0xab
ffffffffc020186c:	cb072023          	sw	a6,-864(a4) # ffffffffc02ac508 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201870:	5775                	li	a4,-3
ffffffffc0201872:	17c1                	addi	a5,a5,-16
ffffffffc0201874:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201878:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020187a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020187c:	00006697          	auipc	a3,0x6
ffffffffc0201880:	a3c68693          	addi	a3,a3,-1476 # ffffffffc02072b8 <commands+0xbf0>
ffffffffc0201884:	00005617          	auipc	a2,0x5
ffffffffc0201888:	30460613          	addi	a2,a2,772 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020188c:	06200593          	li	a1,98
ffffffffc0201890:	00005517          	auipc	a0,0x5
ffffffffc0201894:	6c050513          	addi	a0,a0,1728 # ffffffffc0206f50 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201898:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020189a:	bebfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020189e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020189e:	1141                	addi	sp,sp,-16
ffffffffc02018a0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018a2:	c1ed                	beqz	a1,ffffffffc0201984 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02018a4:	00659693          	slli	a3,a1,0x6
ffffffffc02018a8:	96aa                	add	a3,a3,a0
ffffffffc02018aa:	02d50463          	beq	a0,a3,ffffffffc02018d2 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018ae:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018b0:	87aa                	mv	a5,a0
ffffffffc02018b2:	8b05                	andi	a4,a4,1
ffffffffc02018b4:	e709                	bnez	a4,ffffffffc02018be <default_init_memmap+0x20>
ffffffffc02018b6:	a07d                	j	ffffffffc0201964 <default_init_memmap+0xc6>
ffffffffc02018b8:	6798                	ld	a4,8(a5)
ffffffffc02018ba:	8b05                	andi	a4,a4,1
ffffffffc02018bc:	c745                	beqz	a4,ffffffffc0201964 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018be:	0007a823          	sw	zero,16(a5)
ffffffffc02018c2:	0007b423          	sd	zero,8(a5)
ffffffffc02018c6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018ca:	04078793          	addi	a5,a5,64
ffffffffc02018ce:	fed795e3          	bne	a5,a3,ffffffffc02018b8 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018d2:	2581                	sext.w	a1,a1
ffffffffc02018d4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018d6:	4789                	li	a5,2
ffffffffc02018d8:	00850713          	addi	a4,a0,8
ffffffffc02018dc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018e0:	000ab697          	auipc	a3,0xab
ffffffffc02018e4:	c1868693          	addi	a3,a3,-1000 # ffffffffc02ac4f8 <free_area>
ffffffffc02018e8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018ea:	669c                	ld	a5,8(a3)
ffffffffc02018ec:	9db9                	addw	a1,a1,a4
ffffffffc02018ee:	000ab717          	auipc	a4,0xab
ffffffffc02018f2:	c0b72d23          	sw	a1,-998(a4) # ffffffffc02ac508 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018f6:	04d78a63          	beq	a5,a3,ffffffffc020194a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018fa:	fe878713          	addi	a4,a5,-24
ffffffffc02018fe:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201900:	4801                	li	a6,0
ffffffffc0201902:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201906:	00e56a63          	bltu	a0,a4,ffffffffc020191a <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020190a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020190c:	02d70563          	beq	a4,a3,ffffffffc0201936 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201910:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201912:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201916:	fee57ae3          	bleu	a4,a0,ffffffffc020190a <default_init_memmap+0x6c>
ffffffffc020191a:	00080663          	beqz	a6,ffffffffc0201926 <default_init_memmap+0x88>
ffffffffc020191e:	000ab717          	auipc	a4,0xab
ffffffffc0201922:	bcb73d23          	sd	a1,-1062(a4) # ffffffffc02ac4f8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201926:	6398                	ld	a4,0(a5)
}
ffffffffc0201928:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020192a:	e390                	sd	a2,0(a5)
ffffffffc020192c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020192e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201930:	ed18                	sd	a4,24(a0)
ffffffffc0201932:	0141                	addi	sp,sp,16
ffffffffc0201934:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201936:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201938:	f114                	sd	a3,32(a0)
ffffffffc020193a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020193c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020193e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201940:	00d70e63          	beq	a4,a3,ffffffffc020195c <default_init_memmap+0xbe>
ffffffffc0201944:	4805                	li	a6,1
ffffffffc0201946:	87ba                	mv	a5,a4
ffffffffc0201948:	b7e9                	j	ffffffffc0201912 <default_init_memmap+0x74>
}
ffffffffc020194a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020194c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201950:	e398                	sd	a4,0(a5)
ffffffffc0201952:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201954:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201956:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201958:	0141                	addi	sp,sp,16
ffffffffc020195a:	8082                	ret
ffffffffc020195c:	60a2                	ld	ra,8(sp)
ffffffffc020195e:	e290                	sd	a2,0(a3)
ffffffffc0201960:	0141                	addi	sp,sp,16
ffffffffc0201962:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201964:	00006697          	auipc	a3,0x6
ffffffffc0201968:	95c68693          	addi	a3,a3,-1700 # ffffffffc02072c0 <commands+0xbf8>
ffffffffc020196c:	00005617          	auipc	a2,0x5
ffffffffc0201970:	21c60613          	addi	a2,a2,540 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201974:	04900593          	li	a1,73
ffffffffc0201978:	00005517          	auipc	a0,0x5
ffffffffc020197c:	5d850513          	addi	a0,a0,1496 # ffffffffc0206f50 <commands+0x888>
ffffffffc0201980:	b05fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc0201984:	00006697          	auipc	a3,0x6
ffffffffc0201988:	93468693          	addi	a3,a3,-1740 # ffffffffc02072b8 <commands+0xbf0>
ffffffffc020198c:	00005617          	auipc	a2,0x5
ffffffffc0201990:	1fc60613          	addi	a2,a2,508 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201994:	04600593          	li	a1,70
ffffffffc0201998:	00005517          	auipc	a0,0x5
ffffffffc020199c:	5b850513          	addi	a0,a0,1464 # ffffffffc0206f50 <commands+0x888>
ffffffffc02019a0:	ae5fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02019a4 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019a4:	c125                	beqz	a0,ffffffffc0201a04 <slob_free+0x60>
		return;

	if (size)
ffffffffc02019a6:	e1a5                	bnez	a1,ffffffffc0201a06 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019a8:	100027f3          	csrr	a5,sstatus
ffffffffc02019ac:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019ae:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b0:	e3bd                	bnez	a5,ffffffffc0201a16 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019b2:	0009f797          	auipc	a5,0x9f
ffffffffc02019b6:	6d678793          	addi	a5,a5,1750 # ffffffffc02a1088 <slobfree>
ffffffffc02019ba:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019be:	00a7fa63          	bleu	a0,a5,ffffffffc02019d2 <slob_free+0x2e>
ffffffffc02019c2:	00e56c63          	bltu	a0,a4,ffffffffc02019da <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c6:	00e7fa63          	bleu	a4,a5,ffffffffc02019da <slob_free+0x36>
    return 0;
ffffffffc02019ca:	87ba                	mv	a5,a4
ffffffffc02019cc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ce:	fea7eae3          	bltu	a5,a0,ffffffffc02019c2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019d2:	fee7ece3          	bltu	a5,a4,ffffffffc02019ca <slob_free+0x26>
ffffffffc02019d6:	fee57ae3          	bleu	a4,a0,ffffffffc02019ca <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019da:	4110                	lw	a2,0(a0)
ffffffffc02019dc:	00461693          	slli	a3,a2,0x4
ffffffffc02019e0:	96aa                	add	a3,a3,a0
ffffffffc02019e2:	08d70b63          	beq	a4,a3,ffffffffc0201a78 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019e6:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019e8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019ea:	00469713          	slli	a4,a3,0x4
ffffffffc02019ee:	973e                	add	a4,a4,a5
ffffffffc02019f0:	08e50f63          	beq	a0,a4,ffffffffc0201a8e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019f4:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019f6:	0009f717          	auipc	a4,0x9f
ffffffffc02019fa:	68f73923          	sd	a5,1682(a4) # ffffffffc02a1088 <slobfree>
    if (flag) {
ffffffffc02019fe:	c199                	beqz	a1,ffffffffc0201a04 <slob_free+0x60>
        intr_enable();
ffffffffc0201a00:	c55fe06f          	j	ffffffffc0200654 <intr_enable>
ffffffffc0201a04:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201a06:	05bd                	addi	a1,a1,15
ffffffffc0201a08:	8191                	srli	a1,a1,0x4
ffffffffc0201a0a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a0c:	100027f3          	csrr	a5,sstatus
ffffffffc0201a10:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a12:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a14:	dfd9                	beqz	a5,ffffffffc02019b2 <slob_free+0xe>
{
ffffffffc0201a16:	1101                	addi	sp,sp,-32
ffffffffc0201a18:	e42a                	sd	a0,8(sp)
ffffffffc0201a1a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a1c:	c3ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	0009f797          	auipc	a5,0x9f
ffffffffc0201a24:	66878793          	addi	a5,a5,1640 # ffffffffc02a1088 <slobfree>
ffffffffc0201a28:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a2a:	6522                	ld	a0,8(sp)
ffffffffc0201a2c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a30:	00a7fa63          	bleu	a0,a5,ffffffffc0201a44 <slob_free+0xa0>
ffffffffc0201a34:	00e56c63          	bltu	a0,a4,ffffffffc0201a4c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a38:	00e7fa63          	bleu	a4,a5,ffffffffc0201a4c <slob_free+0xa8>
    return 0;
ffffffffc0201a3c:	87ba                	mv	a5,a4
ffffffffc0201a3e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a40:	fea7eae3          	bltu	a5,a0,ffffffffc0201a34 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a44:	fee7ece3          	bltu	a5,a4,ffffffffc0201a3c <slob_free+0x98>
ffffffffc0201a48:	fee57ae3          	bleu	a4,a0,ffffffffc0201a3c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a4c:	4110                	lw	a2,0(a0)
ffffffffc0201a4e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a52:	96aa                	add	a3,a3,a0
ffffffffc0201a54:	04d70763          	beq	a4,a3,ffffffffc0201aa2 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a58:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a5a:	4394                	lw	a3,0(a5)
ffffffffc0201a5c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a60:	973e                	add	a4,a4,a5
ffffffffc0201a62:	04e50663          	beq	a0,a4,ffffffffc0201aae <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a66:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a68:	0009f717          	auipc	a4,0x9f
ffffffffc0201a6c:	62f73023          	sd	a5,1568(a4) # ffffffffc02a1088 <slobfree>
    if (flag) {
ffffffffc0201a70:	e58d                	bnez	a1,ffffffffc0201a9a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a72:	60e2                	ld	ra,24(sp)
ffffffffc0201a74:	6105                	addi	sp,sp,32
ffffffffc0201a76:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a78:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a7a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a7c:	9e35                	addw	a2,a2,a3
ffffffffc0201a7e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a80:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a82:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a84:	00469713          	slli	a4,a3,0x4
ffffffffc0201a88:	973e                	add	a4,a4,a5
ffffffffc0201a8a:	f6e515e3          	bne	a0,a4,ffffffffc02019f4 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a8e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a90:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a92:	9eb9                	addw	a3,a3,a4
ffffffffc0201a94:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a96:	e790                	sd	a2,8(a5)
ffffffffc0201a98:	bfb9                	j	ffffffffc02019f6 <slob_free+0x52>
}
ffffffffc0201a9a:	60e2                	ld	ra,24(sp)
ffffffffc0201a9c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a9e:	bb7fe06f          	j	ffffffffc0200654 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201aa2:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201aa4:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201aa6:	9e35                	addw	a2,a2,a3
ffffffffc0201aa8:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201aaa:	e518                	sd	a4,8(a0)
ffffffffc0201aac:	b77d                	j	ffffffffc0201a5a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201aae:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201ab0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201ab2:	9eb9                	addw	a3,a3,a4
ffffffffc0201ab4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201ab6:	e790                	sd	a2,8(a5)
ffffffffc0201ab8:	bf45                	j	ffffffffc0201a68 <slob_free+0xc4>

ffffffffc0201aba <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aba:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201abc:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201abe:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ac2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ac4:	38e000ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
  if(!page)
ffffffffc0201ac8:	c139                	beqz	a0,ffffffffc0201b0e <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aca:	000ab797          	auipc	a5,0xab
ffffffffc0201ace:	a5e78793          	addi	a5,a5,-1442 # ffffffffc02ac528 <pages>
ffffffffc0201ad2:	6394                	ld	a3,0(a5)
ffffffffc0201ad4:	00007797          	auipc	a5,0x7
ffffffffc0201ad8:	1d478793          	addi	a5,a5,468 # ffffffffc0208ca8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201adc:	000ab717          	auipc	a4,0xab
ffffffffc0201ae0:	9dc70713          	addi	a4,a4,-1572 # ffffffffc02ac4b8 <npage>
    return page - pages + nbase;
ffffffffc0201ae4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ae8:	6388                	ld	a0,0(a5)
ffffffffc0201aea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201aec:	57fd                	li	a5,-1
ffffffffc0201aee:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201af0:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201af2:	83b1                	srli	a5,a5,0xc
ffffffffc0201af4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201af6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201af8:	00e7ff63          	bleu	a4,a5,ffffffffc0201b16 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201afc:	000ab797          	auipc	a5,0xab
ffffffffc0201b00:	a1c78793          	addi	a5,a5,-1508 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0201b04:	6388                	ld	a0,0(a5)
}
ffffffffc0201b06:	60a2                	ld	ra,8(sp)
ffffffffc0201b08:	9536                	add	a0,a0,a3
ffffffffc0201b0a:	0141                	addi	sp,sp,16
ffffffffc0201b0c:	8082                	ret
ffffffffc0201b0e:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b10:	4501                	li	a0,0
}
ffffffffc0201b12:	0141                	addi	sp,sp,16
ffffffffc0201b14:	8082                	ret
ffffffffc0201b16:	00006617          	auipc	a2,0x6
ffffffffc0201b1a:	80a60613          	addi	a2,a2,-2038 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0201b1e:	06900593          	li	a1,105
ffffffffc0201b22:	00006517          	auipc	a0,0x6
ffffffffc0201b26:	82650513          	addi	a0,a0,-2010 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0201b2a:	95bfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b2e:	7179                	addi	sp,sp,-48
ffffffffc0201b30:	f406                	sd	ra,40(sp)
ffffffffc0201b32:	f022                	sd	s0,32(sp)
ffffffffc0201b34:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b36:	01050713          	addi	a4,a0,16
ffffffffc0201b3a:	6785                	lui	a5,0x1
ffffffffc0201b3c:	0cf77b63          	bleu	a5,a4,ffffffffc0201c12 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b40:	00f50413          	addi	s0,a0,15
ffffffffc0201b44:	8011                	srli	s0,s0,0x4
ffffffffc0201b46:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b48:	10002673          	csrr	a2,sstatus
ffffffffc0201b4c:	8a09                	andi	a2,a2,2
ffffffffc0201b4e:	ea5d                	bnez	a2,ffffffffc0201c04 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b50:	0009f497          	auipc	s1,0x9f
ffffffffc0201b54:	53848493          	addi	s1,s1,1336 # ffffffffc02a1088 <slobfree>
ffffffffc0201b58:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b5a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b5c:	4398                	lw	a4,0(a5)
ffffffffc0201b5e:	0a875763          	ble	s0,a4,ffffffffc0201c0c <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b62:	00f68a63          	beq	a3,a5,ffffffffc0201b76 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b66:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b68:	4118                	lw	a4,0(a0)
ffffffffc0201b6a:	02875763          	ble	s0,a4,ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b6e:	6094                	ld	a3,0(s1)
ffffffffc0201b70:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b72:	fef69ae3          	bne	a3,a5,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b76:	ea39                	bnez	a2,ffffffffc0201bcc <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b78:	4501                	li	a0,0
ffffffffc0201b7a:	f41ff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b7e:	cd29                	beqz	a0,ffffffffc0201bd8 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b80:	6585                	lui	a1,0x1
ffffffffc0201b82:	e23ff0ef          	jal	ra,ffffffffc02019a4 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b86:	10002673          	csrr	a2,sstatus
ffffffffc0201b8a:	8a09                	andi	a2,a2,2
ffffffffc0201b8c:	ea1d                	bnez	a2,ffffffffc0201bc2 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b8e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b90:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b92:	4118                	lw	a4,0(a0)
ffffffffc0201b94:	fc874de3          	blt	a4,s0,ffffffffc0201b6e <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b98:	04e40663          	beq	s0,a4,ffffffffc0201be4 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b9c:	00441693          	slli	a3,s0,0x4
ffffffffc0201ba0:	96aa                	add	a3,a3,a0
ffffffffc0201ba2:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201ba4:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201ba6:	9f01                	subw	a4,a4,s0
ffffffffc0201ba8:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201baa:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201bac:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201bae:	0009f717          	auipc	a4,0x9f
ffffffffc0201bb2:	4cf73d23          	sd	a5,1242(a4) # ffffffffc02a1088 <slobfree>
    if (flag) {
ffffffffc0201bb6:	ee15                	bnez	a2,ffffffffc0201bf2 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201bb8:	70a2                	ld	ra,40(sp)
ffffffffc0201bba:	7402                	ld	s0,32(sp)
ffffffffc0201bbc:	64e2                	ld	s1,24(sp)
ffffffffc0201bbe:	6145                	addi	sp,sp,48
ffffffffc0201bc0:	8082                	ret
        intr_disable();
ffffffffc0201bc2:	a99fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201bc6:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bc8:	609c                	ld	a5,0(s1)
ffffffffc0201bca:	b7d9                	j	ffffffffc0201b90 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bcc:	a89fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bd0:	4501                	li	a0,0
ffffffffc0201bd2:	ee9ff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bd6:	f54d                	bnez	a0,ffffffffc0201b80 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bd8:	70a2                	ld	ra,40(sp)
ffffffffc0201bda:	7402                	ld	s0,32(sp)
ffffffffc0201bdc:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bde:	4501                	li	a0,0
}
ffffffffc0201be0:	6145                	addi	sp,sp,48
ffffffffc0201be2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201be4:	6518                	ld	a4,8(a0)
ffffffffc0201be6:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201be8:	0009f717          	auipc	a4,0x9f
ffffffffc0201bec:	4af73023          	sd	a5,1184(a4) # ffffffffc02a1088 <slobfree>
    if (flag) {
ffffffffc0201bf0:	d661                	beqz	a2,ffffffffc0201bb8 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201bf2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bf4:	a61fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc0201bf8:	70a2                	ld	ra,40(sp)
ffffffffc0201bfa:	7402                	ld	s0,32(sp)
ffffffffc0201bfc:	6522                	ld	a0,8(sp)
ffffffffc0201bfe:	64e2                	ld	s1,24(sp)
ffffffffc0201c00:	6145                	addi	sp,sp,48
ffffffffc0201c02:	8082                	ret
        intr_disable();
ffffffffc0201c04:	a57fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201c08:	4605                	li	a2,1
ffffffffc0201c0a:	b799                	j	ffffffffc0201b50 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201c0c:	853e                	mv	a0,a5
ffffffffc0201c0e:	87b6                	mv	a5,a3
ffffffffc0201c10:	b761                	j	ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c12:	00005697          	auipc	a3,0x5
ffffffffc0201c16:	7ae68693          	addi	a3,a3,1966 # ffffffffc02073c0 <default_pmm_manager+0xf0>
ffffffffc0201c1a:	00005617          	auipc	a2,0x5
ffffffffc0201c1e:	f6e60613          	addi	a2,a2,-146 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0201c22:	06400593          	li	a1,100
ffffffffc0201c26:	00005517          	auipc	a0,0x5
ffffffffc0201c2a:	7ba50513          	addi	a0,a0,1978 # ffffffffc02073e0 <default_pmm_manager+0x110>
ffffffffc0201c2e:	857fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201c32 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c32:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c34:	00005517          	auipc	a0,0x5
ffffffffc0201c38:	7c450513          	addi	a0,a0,1988 # ffffffffc02073f8 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c3c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c3e:	d50fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c42:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c44:	00005517          	auipc	a0,0x5
ffffffffc0201c48:	75c50513          	addi	a0,a0,1884 # ffffffffc02073a0 <default_pmm_manager+0xd0>
}
ffffffffc0201c4c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c4e:	d40fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c52 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c52:	4501                	li	a0,0
ffffffffc0201c54:	8082                	ret

ffffffffc0201c56 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c56:	1101                	addi	sp,sp,-32
ffffffffc0201c58:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c5a:	6905                	lui	s2,0x1
{
ffffffffc0201c5c:	e822                	sd	s0,16(sp)
ffffffffc0201c5e:	ec06                	sd	ra,24(sp)
ffffffffc0201c60:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c62:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8589>
{
ffffffffc0201c66:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c68:	04a7fc63          	bleu	a0,a5,ffffffffc0201cc0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c6c:	4561                	li	a0,24
ffffffffc0201c6e:	ec1ff0ef          	jal	ra,ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c72:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c74:	cd21                	beqz	a0,ffffffffc0201ccc <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c76:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c7a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c7c:	00f95763          	ble	a5,s2,ffffffffc0201c8a <kmalloc+0x34>
ffffffffc0201c80:	6705                	lui	a4,0x1
ffffffffc0201c82:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c84:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c86:	fef74ee3          	blt	a4,a5,ffffffffc0201c82 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c8a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c8c:	e2fff0ef          	jal	ra,ffffffffc0201aba <__slob_get_free_pages.isra.0>
ffffffffc0201c90:	e488                	sd	a0,8(s1)
ffffffffc0201c92:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c94:	c935                	beqz	a0,ffffffffc0201d08 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c96:	100027f3          	csrr	a5,sstatus
ffffffffc0201c9a:	8b89                	andi	a5,a5,2
ffffffffc0201c9c:	e3a1                	bnez	a5,ffffffffc0201cdc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c9e:	000ab797          	auipc	a5,0xab
ffffffffc0201ca2:	80a78793          	addi	a5,a5,-2038 # ffffffffc02ac4a8 <bigblocks>
ffffffffc0201ca6:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201ca8:	000ab717          	auipc	a4,0xab
ffffffffc0201cac:	80973023          	sd	s1,-2048(a4) # ffffffffc02ac4a8 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cb0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201cb2:	8522                	mv	a0,s0
ffffffffc0201cb4:	60e2                	ld	ra,24(sp)
ffffffffc0201cb6:	6442                	ld	s0,16(sp)
ffffffffc0201cb8:	64a2                	ld	s1,8(sp)
ffffffffc0201cba:	6902                	ld	s2,0(sp)
ffffffffc0201cbc:	6105                	addi	sp,sp,32
ffffffffc0201cbe:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cc0:	0541                	addi	a0,a0,16
ffffffffc0201cc2:	e6dff0ef          	jal	ra,ffffffffc0201b2e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cc6:	01050413          	addi	s0,a0,16
ffffffffc0201cca:	f565                	bnez	a0,ffffffffc0201cb2 <kmalloc+0x5c>
ffffffffc0201ccc:	4401                	li	s0,0
}
ffffffffc0201cce:	8522                	mv	a0,s0
ffffffffc0201cd0:	60e2                	ld	ra,24(sp)
ffffffffc0201cd2:	6442                	ld	s0,16(sp)
ffffffffc0201cd4:	64a2                	ld	s1,8(sp)
ffffffffc0201cd6:	6902                	ld	s2,0(sp)
ffffffffc0201cd8:	6105                	addi	sp,sp,32
ffffffffc0201cda:	8082                	ret
        intr_disable();
ffffffffc0201cdc:	97ffe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ce0:	000aa797          	auipc	a5,0xaa
ffffffffc0201ce4:	7c878793          	addi	a5,a5,1992 # ffffffffc02ac4a8 <bigblocks>
ffffffffc0201ce8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cea:	000aa717          	auipc	a4,0xaa
ffffffffc0201cee:	7a973f23          	sd	s1,1982(a4) # ffffffffc02ac4a8 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cf2:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cf4:	961fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201cf8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cfa:	60e2                	ld	ra,24(sp)
ffffffffc0201cfc:	64a2                	ld	s1,8(sp)
ffffffffc0201cfe:	8522                	mv	a0,s0
ffffffffc0201d00:	6442                	ld	s0,16(sp)
ffffffffc0201d02:	6902                	ld	s2,0(sp)
ffffffffc0201d04:	6105                	addi	sp,sp,32
ffffffffc0201d06:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d08:	45e1                	li	a1,24
ffffffffc0201d0a:	8526                	mv	a0,s1
ffffffffc0201d0c:	c99ff0ef          	jal	ra,ffffffffc02019a4 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d10:	b74d                	j	ffffffffc0201cb2 <kmalloc+0x5c>

ffffffffc0201d12 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d12:	c175                	beqz	a0,ffffffffc0201df6 <kfree+0xe4>
{
ffffffffc0201d14:	1101                	addi	sp,sp,-32
ffffffffc0201d16:	e426                	sd	s1,8(sp)
ffffffffc0201d18:	ec06                	sd	ra,24(sp)
ffffffffc0201d1a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d1c:	03451793          	slli	a5,a0,0x34
ffffffffc0201d20:	84aa                	mv	s1,a0
ffffffffc0201d22:	eb8d                	bnez	a5,ffffffffc0201d54 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d24:	100027f3          	csrr	a5,sstatus
ffffffffc0201d28:	8b89                	andi	a5,a5,2
ffffffffc0201d2a:	efc9                	bnez	a5,ffffffffc0201dc4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d2c:	000aa797          	auipc	a5,0xaa
ffffffffc0201d30:	77c78793          	addi	a5,a5,1916 # ffffffffc02ac4a8 <bigblocks>
ffffffffc0201d34:	6394                	ld	a3,0(a5)
ffffffffc0201d36:	ce99                	beqz	a3,ffffffffc0201d54 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d38:	669c                	ld	a5,8(a3)
ffffffffc0201d3a:	6a80                	ld	s0,16(a3)
ffffffffc0201d3c:	0af50e63          	beq	a0,a5,ffffffffc0201df8 <kfree+0xe6>
    return 0;
ffffffffc0201d40:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d42:	c801                	beqz	s0,ffffffffc0201d52 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d44:	6418                	ld	a4,8(s0)
ffffffffc0201d46:	681c                	ld	a5,16(s0)
ffffffffc0201d48:	00970f63          	beq	a4,s1,ffffffffc0201d66 <kfree+0x54>
ffffffffc0201d4c:	86a2                	mv	a3,s0
ffffffffc0201d4e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d50:	f875                	bnez	s0,ffffffffc0201d44 <kfree+0x32>
    if (flag) {
ffffffffc0201d52:	e659                	bnez	a2,ffffffffc0201de0 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d54:	6442                	ld	s0,16(sp)
ffffffffc0201d56:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d58:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d5c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d5e:	4581                	li	a1,0
}
ffffffffc0201d60:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d62:	c43ff06f          	j	ffffffffc02019a4 <slob_free>
				*last = bb->next;
ffffffffc0201d66:	ea9c                	sd	a5,16(a3)
ffffffffc0201d68:	e641                	bnez	a2,ffffffffc0201df0 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d6a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d6e:	4018                	lw	a4,0(s0)
ffffffffc0201d70:	08f4ea63          	bltu	s1,a5,ffffffffc0201e04 <kfree+0xf2>
ffffffffc0201d74:	000aa797          	auipc	a5,0xaa
ffffffffc0201d78:	7a478793          	addi	a5,a5,1956 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0201d7c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d7e:	000aa797          	auipc	a5,0xaa
ffffffffc0201d82:	73a78793          	addi	a5,a5,1850 # ffffffffc02ac4b8 <npage>
ffffffffc0201d86:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d88:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d8a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d8c:	08f4f963          	bleu	a5,s1,ffffffffc0201e1e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d90:	00007797          	auipc	a5,0x7
ffffffffc0201d94:	f1878793          	addi	a5,a5,-232 # ffffffffc0208ca8 <nbase>
ffffffffc0201d98:	639c                	ld	a5,0(a5)
ffffffffc0201d9a:	000aa697          	auipc	a3,0xaa
ffffffffc0201d9e:	78e68693          	addi	a3,a3,1934 # ffffffffc02ac528 <pages>
ffffffffc0201da2:	6288                	ld	a0,0(a3)
ffffffffc0201da4:	8c9d                	sub	s1,s1,a5
ffffffffc0201da6:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201da8:	4585                	li	a1,1
ffffffffc0201daa:	9526                	add	a0,a0,s1
ffffffffc0201dac:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201db0:	12a000ef          	jal	ra,ffffffffc0201eda <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201db4:	8522                	mv	a0,s0
}
ffffffffc0201db6:	6442                	ld	s0,16(sp)
ffffffffc0201db8:	60e2                	ld	ra,24(sp)
ffffffffc0201dba:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dbc:	45e1                	li	a1,24
}
ffffffffc0201dbe:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201dc0:	be5ff06f          	j	ffffffffc02019a4 <slob_free>
        intr_disable();
ffffffffc0201dc4:	897fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201dc8:	000aa797          	auipc	a5,0xaa
ffffffffc0201dcc:	6e078793          	addi	a5,a5,1760 # ffffffffc02ac4a8 <bigblocks>
ffffffffc0201dd0:	6394                	ld	a3,0(a5)
ffffffffc0201dd2:	c699                	beqz	a3,ffffffffc0201de0 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201dd4:	669c                	ld	a5,8(a3)
ffffffffc0201dd6:	6a80                	ld	s0,16(a3)
ffffffffc0201dd8:	00f48763          	beq	s1,a5,ffffffffc0201de6 <kfree+0xd4>
        return 1;
ffffffffc0201ddc:	4605                	li	a2,1
ffffffffc0201dde:	b795                	j	ffffffffc0201d42 <kfree+0x30>
        intr_enable();
ffffffffc0201de0:	875fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201de4:	bf85                	j	ffffffffc0201d54 <kfree+0x42>
				*last = bb->next;
ffffffffc0201de6:	000aa797          	auipc	a5,0xaa
ffffffffc0201dea:	6c87b123          	sd	s0,1730(a5) # ffffffffc02ac4a8 <bigblocks>
ffffffffc0201dee:	8436                	mv	s0,a3
ffffffffc0201df0:	865fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201df4:	bf9d                	j	ffffffffc0201d6a <kfree+0x58>
ffffffffc0201df6:	8082                	ret
ffffffffc0201df8:	000aa797          	auipc	a5,0xaa
ffffffffc0201dfc:	6a87b823          	sd	s0,1712(a5) # ffffffffc02ac4a8 <bigblocks>
ffffffffc0201e00:	8436                	mv	s0,a3
ffffffffc0201e02:	b7a5                	j	ffffffffc0201d6a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201e04:	86a6                	mv	a3,s1
ffffffffc0201e06:	00005617          	auipc	a2,0x5
ffffffffc0201e0a:	55260613          	addi	a2,a2,1362 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc0201e0e:	06e00593          	li	a1,110
ffffffffc0201e12:	00005517          	auipc	a0,0x5
ffffffffc0201e16:	53650513          	addi	a0,a0,1334 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0201e1a:	e6afe0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e1e:	00005617          	auipc	a2,0x5
ffffffffc0201e22:	56260613          	addi	a2,a2,1378 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc0201e26:	06200593          	li	a1,98
ffffffffc0201e2a:	00005517          	auipc	a0,0x5
ffffffffc0201e2e:	51e50513          	addi	a0,a0,1310 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0201e32:	e52fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e36 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e36:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e38:	00005617          	auipc	a2,0x5
ffffffffc0201e3c:	54860613          	addi	a2,a2,1352 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc0201e40:	06200593          	li	a1,98
ffffffffc0201e44:	00005517          	auipc	a0,0x5
ffffffffc0201e48:	50450513          	addi	a0,a0,1284 # ffffffffc0207348 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e4c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e4e:	e36fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e52 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e52:	715d                	addi	sp,sp,-80
ffffffffc0201e54:	e0a2                	sd	s0,64(sp)
ffffffffc0201e56:	fc26                	sd	s1,56(sp)
ffffffffc0201e58:	f84a                	sd	s2,48(sp)
ffffffffc0201e5a:	f44e                	sd	s3,40(sp)
ffffffffc0201e5c:	f052                	sd	s4,32(sp)
ffffffffc0201e5e:	ec56                	sd	s5,24(sp)
ffffffffc0201e60:	e486                	sd	ra,72(sp)
ffffffffc0201e62:	842a                	mv	s0,a0
ffffffffc0201e64:	000aa497          	auipc	s1,0xaa
ffffffffc0201e68:	6ac48493          	addi	s1,s1,1708 # ffffffffc02ac510 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e6c:	4985                	li	s3,1
ffffffffc0201e6e:	000aaa17          	auipc	s4,0xaa
ffffffffc0201e72:	65aa0a13          	addi	s4,s4,1626 # ffffffffc02ac4c8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e76:	0005091b          	sext.w	s2,a0
ffffffffc0201e7a:	000aaa97          	auipc	s5,0xaa
ffffffffc0201e7e:	78ea8a93          	addi	s5,s5,1934 # ffffffffc02ac608 <check_mm_struct>
ffffffffc0201e82:	a00d                	j	ffffffffc0201ea4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e84:	609c                	ld	a5,0(s1)
ffffffffc0201e86:	6f9c                	ld	a5,24(a5)
ffffffffc0201e88:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e8a:	4601                	li	a2,0
ffffffffc0201e8c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e8e:	ed0d                	bnez	a0,ffffffffc0201ec8 <alloc_pages+0x76>
ffffffffc0201e90:	0289ec63          	bltu	s3,s0,ffffffffc0201ec8 <alloc_pages+0x76>
ffffffffc0201e94:	000a2783          	lw	a5,0(s4)
ffffffffc0201e98:	2781                	sext.w	a5,a5
ffffffffc0201e9a:	c79d                	beqz	a5,ffffffffc0201ec8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e9c:	000ab503          	ld	a0,0(s5)
ffffffffc0201ea0:	3eb010ef          	jal	ra,ffffffffc0203a8a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ea4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ea8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201eaa:	8522                	mv	a0,s0
ffffffffc0201eac:	dfe1                	beqz	a5,ffffffffc0201e84 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201eae:	facfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0201eb2:	609c                	ld	a5,0(s1)
ffffffffc0201eb4:	8522                	mv	a0,s0
ffffffffc0201eb6:	6f9c                	ld	a5,24(a5)
ffffffffc0201eb8:	9782                	jalr	a5
ffffffffc0201eba:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201ebc:	f98fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0201ec0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ec2:	4601                	li	a2,0
ffffffffc0201ec4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ec6:	d569                	beqz	a0,ffffffffc0201e90 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ec8:	60a6                	ld	ra,72(sp)
ffffffffc0201eca:	6406                	ld	s0,64(sp)
ffffffffc0201ecc:	74e2                	ld	s1,56(sp)
ffffffffc0201ece:	7942                	ld	s2,48(sp)
ffffffffc0201ed0:	79a2                	ld	s3,40(sp)
ffffffffc0201ed2:	7a02                	ld	s4,32(sp)
ffffffffc0201ed4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ed6:	6161                	addi	sp,sp,80
ffffffffc0201ed8:	8082                	ret

ffffffffc0201eda <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eda:	100027f3          	csrr	a5,sstatus
ffffffffc0201ede:	8b89                	andi	a5,a5,2
ffffffffc0201ee0:	eb89                	bnez	a5,ffffffffc0201ef2 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ee2:	000aa797          	auipc	a5,0xaa
ffffffffc0201ee6:	62e78793          	addi	a5,a5,1582 # ffffffffc02ac510 <pmm_manager>
ffffffffc0201eea:	639c                	ld	a5,0(a5)
ffffffffc0201eec:	0207b303          	ld	t1,32(a5)
ffffffffc0201ef0:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ef2:	1101                	addi	sp,sp,-32
ffffffffc0201ef4:	ec06                	sd	ra,24(sp)
ffffffffc0201ef6:	e822                	sd	s0,16(sp)
ffffffffc0201ef8:	e426                	sd	s1,8(sp)
ffffffffc0201efa:	842a                	mv	s0,a0
ffffffffc0201efc:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201efe:	f5cfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f02:	000aa797          	auipc	a5,0xaa
ffffffffc0201f06:	60e78793          	addi	a5,a5,1550 # ffffffffc02ac510 <pmm_manager>
ffffffffc0201f0a:	639c                	ld	a5,0(a5)
ffffffffc0201f0c:	85a6                	mv	a1,s1
ffffffffc0201f0e:	8522                	mv	a0,s0
ffffffffc0201f10:	739c                	ld	a5,32(a5)
ffffffffc0201f12:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f14:	6442                	ld	s0,16(sp)
ffffffffc0201f16:	60e2                	ld	ra,24(sp)
ffffffffc0201f18:	64a2                	ld	s1,8(sp)
ffffffffc0201f1a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f1c:	f38fe06f          	j	ffffffffc0200654 <intr_enable>

ffffffffc0201f20 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f20:	100027f3          	csrr	a5,sstatus
ffffffffc0201f24:	8b89                	andi	a5,a5,2
ffffffffc0201f26:	eb89                	bnez	a5,ffffffffc0201f38 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f28:	000aa797          	auipc	a5,0xaa
ffffffffc0201f2c:	5e878793          	addi	a5,a5,1512 # ffffffffc02ac510 <pmm_manager>
ffffffffc0201f30:	639c                	ld	a5,0(a5)
ffffffffc0201f32:	0287b303          	ld	t1,40(a5)
ffffffffc0201f36:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f38:	1141                	addi	sp,sp,-16
ffffffffc0201f3a:	e406                	sd	ra,8(sp)
ffffffffc0201f3c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f3e:	f1cfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f42:	000aa797          	auipc	a5,0xaa
ffffffffc0201f46:	5ce78793          	addi	a5,a5,1486 # ffffffffc02ac510 <pmm_manager>
ffffffffc0201f4a:	639c                	ld	a5,0(a5)
ffffffffc0201f4c:	779c                	ld	a5,40(a5)
ffffffffc0201f4e:	9782                	jalr	a5
ffffffffc0201f50:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f52:	f02fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f56:	8522                	mv	a0,s0
ffffffffc0201f58:	60a2                	ld	ra,8(sp)
ffffffffc0201f5a:	6402                	ld	s0,0(sp)
ffffffffc0201f5c:	0141                	addi	sp,sp,16
ffffffffc0201f5e:	8082                	ret

ffffffffc0201f60 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f60:	7139                	addi	sp,sp,-64
ffffffffc0201f62:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f64:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f68:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f6c:	048e                	slli	s1,s1,0x3
ffffffffc0201f6e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f70:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f72:	f04a                	sd	s2,32(sp)
ffffffffc0201f74:	ec4e                	sd	s3,24(sp)
ffffffffc0201f76:	e852                	sd	s4,16(sp)
ffffffffc0201f78:	fc06                	sd	ra,56(sp)
ffffffffc0201f7a:	f822                	sd	s0,48(sp)
ffffffffc0201f7c:	e456                	sd	s5,8(sp)
ffffffffc0201f7e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f80:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f84:	892e                	mv	s2,a1
ffffffffc0201f86:	8a32                	mv	s4,a2
ffffffffc0201f88:	000aa997          	auipc	s3,0xaa
ffffffffc0201f8c:	53098993          	addi	s3,s3,1328 # ffffffffc02ac4b8 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f90:	e7bd                	bnez	a5,ffffffffc0201ffe <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f92:	12060c63          	beqz	a2,ffffffffc02020ca <get_pte+0x16a>
ffffffffc0201f96:	4505                	li	a0,1
ffffffffc0201f98:	ebbff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0201f9c:	842a                	mv	s0,a0
ffffffffc0201f9e:	12050663          	beqz	a0,ffffffffc02020ca <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201fa2:	000aab17          	auipc	s6,0xaa
ffffffffc0201fa6:	586b0b13          	addi	s6,s6,1414 # ffffffffc02ac528 <pages>
ffffffffc0201faa:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201fae:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fb0:	000aa997          	auipc	s3,0xaa
ffffffffc0201fb4:	50898993          	addi	s3,s3,1288 # ffffffffc02ac4b8 <npage>
    return page - pages + nbase;
ffffffffc0201fb8:	40a40533          	sub	a0,s0,a0
ffffffffc0201fbc:	00080ab7          	lui	s5,0x80
ffffffffc0201fc0:	8519                	srai	a0,a0,0x6
ffffffffc0201fc2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fc6:	c01c                	sw	a5,0(s0)
ffffffffc0201fc8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fca:	9556                	add	a0,a0,s5
ffffffffc0201fcc:	83b1                	srli	a5,a5,0xc
ffffffffc0201fce:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd0:	0532                	slli	a0,a0,0xc
ffffffffc0201fd2:	14e7f363          	bleu	a4,a5,ffffffffc0202118 <get_pte+0x1b8>
ffffffffc0201fd6:	000aa797          	auipc	a5,0xaa
ffffffffc0201fda:	54278793          	addi	a5,a5,1346 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0201fde:	639c                	ld	a5,0(a5)
ffffffffc0201fe0:	6605                	lui	a2,0x1
ffffffffc0201fe2:	4581                	li	a1,0
ffffffffc0201fe4:	953e                	add	a0,a0,a5
ffffffffc0201fe6:	582040ef          	jal	ra,ffffffffc0206568 <memset>
    return page - pages + nbase;
ffffffffc0201fea:	000b3683          	ld	a3,0(s6)
ffffffffc0201fee:	40d406b3          	sub	a3,s0,a3
ffffffffc0201ff2:	8699                	srai	a3,a3,0x6
ffffffffc0201ff4:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ff6:	06aa                	slli	a3,a3,0xa
ffffffffc0201ff8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ffc:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201ffe:	77fd                	lui	a5,0xfffff
ffffffffc0202000:	068a                	slli	a3,a3,0x2
ffffffffc0202002:	0009b703          	ld	a4,0(s3)
ffffffffc0202006:	8efd                	and	a3,a3,a5
ffffffffc0202008:	00c6d793          	srli	a5,a3,0xc
ffffffffc020200c:	0ce7f163          	bleu	a4,a5,ffffffffc02020ce <get_pte+0x16e>
ffffffffc0202010:	000aaa97          	auipc	s5,0xaa
ffffffffc0202014:	508a8a93          	addi	s5,s5,1288 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0202018:	000ab403          	ld	s0,0(s5)
ffffffffc020201c:	01595793          	srli	a5,s2,0x15
ffffffffc0202020:	1ff7f793          	andi	a5,a5,511
ffffffffc0202024:	96a2                	add	a3,a3,s0
ffffffffc0202026:	00379413          	slli	s0,a5,0x3
ffffffffc020202a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020202c:	6014                	ld	a3,0(s0)
ffffffffc020202e:	0016f793          	andi	a5,a3,1
ffffffffc0202032:	e3ad                	bnez	a5,ffffffffc0202094 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202034:	080a0b63          	beqz	s4,ffffffffc02020ca <get_pte+0x16a>
ffffffffc0202038:	4505                	li	a0,1
ffffffffc020203a:	e19ff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020203e:	84aa                	mv	s1,a0
ffffffffc0202040:	c549                	beqz	a0,ffffffffc02020ca <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202042:	000aab17          	auipc	s6,0xaa
ffffffffc0202046:	4e6b0b13          	addi	s6,s6,1254 # ffffffffc02ac528 <pages>
ffffffffc020204a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020204e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202050:	00080a37          	lui	s4,0x80
ffffffffc0202054:	40a48533          	sub	a0,s1,a0
ffffffffc0202058:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020205a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020205e:	c09c                	sw	a5,0(s1)
ffffffffc0202060:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202062:	9552                	add	a0,a0,s4
ffffffffc0202064:	83b1                	srli	a5,a5,0xc
ffffffffc0202066:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202068:	0532                	slli	a0,a0,0xc
ffffffffc020206a:	08e7fa63          	bleu	a4,a5,ffffffffc02020fe <get_pte+0x19e>
ffffffffc020206e:	000ab783          	ld	a5,0(s5)
ffffffffc0202072:	6605                	lui	a2,0x1
ffffffffc0202074:	4581                	li	a1,0
ffffffffc0202076:	953e                	add	a0,a0,a5
ffffffffc0202078:	4f0040ef          	jal	ra,ffffffffc0206568 <memset>
    return page - pages + nbase;
ffffffffc020207c:	000b3683          	ld	a3,0(s6)
ffffffffc0202080:	40d486b3          	sub	a3,s1,a3
ffffffffc0202084:	8699                	srai	a3,a3,0x6
ffffffffc0202086:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202088:	06aa                	slli	a3,a3,0xa
ffffffffc020208a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020208e:	e014                	sd	a3,0(s0)
ffffffffc0202090:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202094:	068a                	slli	a3,a3,0x2
ffffffffc0202096:	757d                	lui	a0,0xfffff
ffffffffc0202098:	8ee9                	and	a3,a3,a0
ffffffffc020209a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020209e:	04e7f463          	bleu	a4,a5,ffffffffc02020e6 <get_pte+0x186>
ffffffffc02020a2:	000ab503          	ld	a0,0(s5)
ffffffffc02020a6:	00c95793          	srli	a5,s2,0xc
ffffffffc02020aa:	1ff7f793          	andi	a5,a5,511
ffffffffc02020ae:	96aa                	add	a3,a3,a0
ffffffffc02020b0:	00379513          	slli	a0,a5,0x3
ffffffffc02020b4:	9536                	add	a0,a0,a3
}
ffffffffc02020b6:	70e2                	ld	ra,56(sp)
ffffffffc02020b8:	7442                	ld	s0,48(sp)
ffffffffc02020ba:	74a2                	ld	s1,40(sp)
ffffffffc02020bc:	7902                	ld	s2,32(sp)
ffffffffc02020be:	69e2                	ld	s3,24(sp)
ffffffffc02020c0:	6a42                	ld	s4,16(sp)
ffffffffc02020c2:	6aa2                	ld	s5,8(sp)
ffffffffc02020c4:	6b02                	ld	s6,0(sp)
ffffffffc02020c6:	6121                	addi	sp,sp,64
ffffffffc02020c8:	8082                	ret
            return NULL;
ffffffffc02020ca:	4501                	li	a0,0
ffffffffc02020cc:	b7ed                	j	ffffffffc02020b6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020ce:	00005617          	auipc	a2,0x5
ffffffffc02020d2:	25260613          	addi	a2,a2,594 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc02020d6:	0e300593          	li	a1,227
ffffffffc02020da:	00005517          	auipc	a0,0x5
ffffffffc02020de:	37e50513          	addi	a0,a0,894 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02020e2:	ba2fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020e6:	00005617          	auipc	a2,0x5
ffffffffc02020ea:	23a60613          	addi	a2,a2,570 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc02020ee:	0ee00593          	li	a1,238
ffffffffc02020f2:	00005517          	auipc	a0,0x5
ffffffffc02020f6:	36650513          	addi	a0,a0,870 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02020fa:	b8afe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020fe:	86aa                	mv	a3,a0
ffffffffc0202100:	00005617          	auipc	a2,0x5
ffffffffc0202104:	22060613          	addi	a2,a2,544 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0202108:	0eb00593          	li	a1,235
ffffffffc020210c:	00005517          	auipc	a0,0x5
ffffffffc0202110:	34c50513          	addi	a0,a0,844 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202114:	b70fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202118:	86aa                	mv	a3,a0
ffffffffc020211a:	00005617          	auipc	a2,0x5
ffffffffc020211e:	20660613          	addi	a2,a2,518 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0202122:	0df00593          	li	a1,223
ffffffffc0202126:	00005517          	auipc	a0,0x5
ffffffffc020212a:	33250513          	addi	a0,a0,818 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc020212e:	b56fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202132 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202132:	1141                	addi	sp,sp,-16
ffffffffc0202134:	e022                	sd	s0,0(sp)
ffffffffc0202136:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202138:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020213a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020213c:	e25ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202140:	c011                	beqz	s0,ffffffffc0202144 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202142:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202144:	c129                	beqz	a0,ffffffffc0202186 <get_page+0x54>
ffffffffc0202146:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202148:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020214a:	0017f713          	andi	a4,a5,1
ffffffffc020214e:	e709                	bnez	a4,ffffffffc0202158 <get_page+0x26>
}
ffffffffc0202150:	60a2                	ld	ra,8(sp)
ffffffffc0202152:	6402                	ld	s0,0(sp)
ffffffffc0202154:	0141                	addi	sp,sp,16
ffffffffc0202156:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202158:	000aa717          	auipc	a4,0xaa
ffffffffc020215c:	36070713          	addi	a4,a4,864 # ffffffffc02ac4b8 <npage>
ffffffffc0202160:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202162:	078a                	slli	a5,a5,0x2
ffffffffc0202164:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202166:	02e7f563          	bleu	a4,a5,ffffffffc0202190 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020216a:	000aa717          	auipc	a4,0xaa
ffffffffc020216e:	3be70713          	addi	a4,a4,958 # ffffffffc02ac528 <pages>
ffffffffc0202172:	6308                	ld	a0,0(a4)
ffffffffc0202174:	60a2                	ld	ra,8(sp)
ffffffffc0202176:	6402                	ld	s0,0(sp)
ffffffffc0202178:	fff80737          	lui	a4,0xfff80
ffffffffc020217c:	97ba                	add	a5,a5,a4
ffffffffc020217e:	079a                	slli	a5,a5,0x6
ffffffffc0202180:	953e                	add	a0,a0,a5
ffffffffc0202182:	0141                	addi	sp,sp,16
ffffffffc0202184:	8082                	ret
ffffffffc0202186:	60a2                	ld	ra,8(sp)
ffffffffc0202188:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020218a:	4501                	li	a0,0
}
ffffffffc020218c:	0141                	addi	sp,sp,16
ffffffffc020218e:	8082                	ret
ffffffffc0202190:	ca7ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202194 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202194:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202196:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020219a:	ec86                	sd	ra,88(sp)
ffffffffc020219c:	e8a2                	sd	s0,80(sp)
ffffffffc020219e:	e4a6                	sd	s1,72(sp)
ffffffffc02021a0:	e0ca                	sd	s2,64(sp)
ffffffffc02021a2:	fc4e                	sd	s3,56(sp)
ffffffffc02021a4:	f852                	sd	s4,48(sp)
ffffffffc02021a6:	f456                	sd	s5,40(sp)
ffffffffc02021a8:	f05a                	sd	s6,32(sp)
ffffffffc02021aa:	ec5e                	sd	s7,24(sp)
ffffffffc02021ac:	e862                	sd	s8,16(sp)
ffffffffc02021ae:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021b0:	03479713          	slli	a4,a5,0x34
ffffffffc02021b4:	eb71                	bnez	a4,ffffffffc0202288 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021b6:	002007b7          	lui	a5,0x200
ffffffffc02021ba:	842e                	mv	s0,a1
ffffffffc02021bc:	0af5e663          	bltu	a1,a5,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021c0:	8932                	mv	s2,a2
ffffffffc02021c2:	0ac5f363          	bleu	a2,a1,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021c6:	4785                	li	a5,1
ffffffffc02021c8:	07fe                	slli	a5,a5,0x1f
ffffffffc02021ca:	08c7ef63          	bltu	a5,a2,ffffffffc0202268 <unmap_range+0xd4>
ffffffffc02021ce:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021d0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021d2:	000aac97          	auipc	s9,0xaa
ffffffffc02021d6:	2e6c8c93          	addi	s9,s9,742 # ffffffffc02ac4b8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021da:	000aac17          	auipc	s8,0xaa
ffffffffc02021de:	34ec0c13          	addi	s8,s8,846 # ffffffffc02ac528 <pages>
ffffffffc02021e2:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021e6:	00200b37          	lui	s6,0x200
ffffffffc02021ea:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021ee:	4601                	li	a2,0
ffffffffc02021f0:	85a2                	mv	a1,s0
ffffffffc02021f2:	854e                	mv	a0,s3
ffffffffc02021f4:	d6dff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02021f8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021fa:	cd21                	beqz	a0,ffffffffc0202252 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021fc:	611c                	ld	a5,0(a0)
ffffffffc02021fe:	e38d                	bnez	a5,ffffffffc0202220 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0202200:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202202:	ff2466e3          	bltu	s0,s2,ffffffffc02021ee <unmap_range+0x5a>
}
ffffffffc0202206:	60e6                	ld	ra,88(sp)
ffffffffc0202208:	6446                	ld	s0,80(sp)
ffffffffc020220a:	64a6                	ld	s1,72(sp)
ffffffffc020220c:	6906                	ld	s2,64(sp)
ffffffffc020220e:	79e2                	ld	s3,56(sp)
ffffffffc0202210:	7a42                	ld	s4,48(sp)
ffffffffc0202212:	7aa2                	ld	s5,40(sp)
ffffffffc0202214:	7b02                	ld	s6,32(sp)
ffffffffc0202216:	6be2                	ld	s7,24(sp)
ffffffffc0202218:	6c42                	ld	s8,16(sp)
ffffffffc020221a:	6ca2                	ld	s9,8(sp)
ffffffffc020221c:	6125                	addi	sp,sp,96
ffffffffc020221e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202220:	0017f713          	andi	a4,a5,1
ffffffffc0202224:	df71                	beqz	a4,ffffffffc0202200 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202226:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020222a:	078a                	slli	a5,a5,0x2
ffffffffc020222c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020222e:	06e7fd63          	bleu	a4,a5,ffffffffc02022a8 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202232:	000c3503          	ld	a0,0(s8)
ffffffffc0202236:	97de                	add	a5,a5,s7
ffffffffc0202238:	079a                	slli	a5,a5,0x6
ffffffffc020223a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020223c:	411c                	lw	a5,0(a0)
ffffffffc020223e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202242:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202244:	cf11                	beqz	a4,ffffffffc0202260 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202246:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020224a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020224e:	9452                	add	s0,s0,s4
ffffffffc0202250:	bf4d                	j	ffffffffc0202202 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202252:	945a                	add	s0,s0,s6
ffffffffc0202254:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202258:	d45d                	beqz	s0,ffffffffc0202206 <unmap_range+0x72>
ffffffffc020225a:	f9246ae3          	bltu	s0,s2,ffffffffc02021ee <unmap_range+0x5a>
ffffffffc020225e:	b765                	j	ffffffffc0202206 <unmap_range+0x72>
            free_page(page);
ffffffffc0202260:	4585                	li	a1,1
ffffffffc0202262:	c79ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202266:	b7c5                	j	ffffffffc0202246 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202268:	00005697          	auipc	a3,0x5
ffffffffc020226c:	77068693          	addi	a3,a3,1904 # ffffffffc02079d8 <default_pmm_manager+0x708>
ffffffffc0202270:	00005617          	auipc	a2,0x5
ffffffffc0202274:	91860613          	addi	a2,a2,-1768 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202278:	11000593          	li	a1,272
ffffffffc020227c:	00005517          	auipc	a0,0x5
ffffffffc0202280:	1dc50513          	addi	a0,a0,476 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202284:	a00fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202288:	00005697          	auipc	a3,0x5
ffffffffc020228c:	72068693          	addi	a3,a3,1824 # ffffffffc02079a8 <default_pmm_manager+0x6d8>
ffffffffc0202290:	00005617          	auipc	a2,0x5
ffffffffc0202294:	8f860613          	addi	a2,a2,-1800 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202298:	10f00593          	li	a1,271
ffffffffc020229c:	00005517          	auipc	a0,0x5
ffffffffc02022a0:	1bc50513          	addi	a0,a0,444 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02022a4:	9e0fe0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02022a8:	b8fff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc02022ac <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022ac:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022ae:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022b2:	fc86                	sd	ra,120(sp)
ffffffffc02022b4:	f8a2                	sd	s0,112(sp)
ffffffffc02022b6:	f4a6                	sd	s1,104(sp)
ffffffffc02022b8:	f0ca                	sd	s2,96(sp)
ffffffffc02022ba:	ecce                	sd	s3,88(sp)
ffffffffc02022bc:	e8d2                	sd	s4,80(sp)
ffffffffc02022be:	e4d6                	sd	s5,72(sp)
ffffffffc02022c0:	e0da                	sd	s6,64(sp)
ffffffffc02022c2:	fc5e                	sd	s7,56(sp)
ffffffffc02022c4:	f862                	sd	s8,48(sp)
ffffffffc02022c6:	f466                	sd	s9,40(sp)
ffffffffc02022c8:	f06a                	sd	s10,32(sp)
ffffffffc02022ca:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022cc:	03479713          	slli	a4,a5,0x34
ffffffffc02022d0:	1c071163          	bnez	a4,ffffffffc0202492 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022d4:	002007b7          	lui	a5,0x200
ffffffffc02022d8:	20f5e563          	bltu	a1,a5,ffffffffc02024e2 <exit_range+0x236>
ffffffffc02022dc:	8b32                	mv	s6,a2
ffffffffc02022de:	20c5f263          	bleu	a2,a1,ffffffffc02024e2 <exit_range+0x236>
ffffffffc02022e2:	4785                	li	a5,1
ffffffffc02022e4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022e6:	1ec7ee63          	bltu	a5,a2,ffffffffc02024e2 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022ea:	c00009b7          	lui	s3,0xc0000
ffffffffc02022ee:	400007b7          	lui	a5,0x40000
ffffffffc02022f2:	0135f9b3          	and	s3,a1,s3
ffffffffc02022f6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022f8:	c0000337          	lui	t1,0xc0000
ffffffffc02022fc:	00698933          	add	s2,s3,t1
ffffffffc0202300:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202304:	1ff97913          	andi	s2,s2,511
ffffffffc0202308:	8e2a                	mv	t3,a0
ffffffffc020230a:	090e                	slli	s2,s2,0x3
ffffffffc020230c:	9972                	add	s2,s2,t3
ffffffffc020230e:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202312:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202316:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0202318:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020231c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020231e:	000aad17          	auipc	s10,0xaa
ffffffffc0202322:	19ad0d13          	addi	s10,s10,410 # ffffffffc02ac4b8 <npage>
    return KADDR(page2pa(page));
ffffffffc0202326:	00cddd93          	srli	s11,s11,0xc
ffffffffc020232a:	000aa717          	auipc	a4,0xaa
ffffffffc020232e:	1ee70713          	addi	a4,a4,494 # ffffffffc02ac518 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202332:	000aae97          	auipc	t4,0xaa
ffffffffc0202336:	1f6e8e93          	addi	t4,t4,502 # ffffffffc02ac528 <pages>
        if (pde1&PTE_V){
ffffffffc020233a:	e79d                	bnez	a5,ffffffffc0202368 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020233c:	12098963          	beqz	s3,ffffffffc020246e <exit_range+0x1c2>
ffffffffc0202340:	400007b7          	lui	a5,0x40000
ffffffffc0202344:	84ce                	mv	s1,s3
ffffffffc0202346:	97ce                	add	a5,a5,s3
ffffffffc0202348:	1369f363          	bleu	s6,s3,ffffffffc020246e <exit_range+0x1c2>
ffffffffc020234c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020234e:	00698933          	add	s2,s3,t1
ffffffffc0202352:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202356:	1ff97913          	andi	s2,s2,511
ffffffffc020235a:	090e                	slli	s2,s2,0x3
ffffffffc020235c:	9972                	add	s2,s2,t3
ffffffffc020235e:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0202362:	001bf793          	andi	a5,s7,1
ffffffffc0202366:	dbf9                	beqz	a5,ffffffffc020233c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202368:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020236c:	0b8a                	slli	s7,s7,0x2
ffffffffc020236e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202372:	14fbfc63          	bleu	a5,s7,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202376:	fff80ab7          	lui	s5,0xfff80
ffffffffc020237a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020237c:	000806b7          	lui	a3,0x80
ffffffffc0202380:	96d6                	add	a3,a3,s5
ffffffffc0202382:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202386:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020238a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020238c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020238e:	12f67263          	bleu	a5,a2,ffffffffc02024b2 <exit_range+0x206>
ffffffffc0202392:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202396:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202398:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020239c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020239e:	00080837          	lui	a6,0x80
ffffffffc02023a2:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02023a4:	00200c37          	lui	s8,0x200
ffffffffc02023a8:	a801                	j	ffffffffc02023b8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02023aa:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02023ac:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023ae:	c0d9                	beqz	s1,ffffffffc0202434 <exit_range+0x188>
ffffffffc02023b0:	0934f263          	bleu	s3,s1,ffffffffc0202434 <exit_range+0x188>
ffffffffc02023b4:	0d64fc63          	bleu	s6,s1,ffffffffc020248c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023b8:	0154d413          	srli	s0,s1,0x15
ffffffffc02023bc:	1ff47413          	andi	s0,s0,511
ffffffffc02023c0:	040e                	slli	s0,s0,0x3
ffffffffc02023c2:	9452                	add	s0,s0,s4
ffffffffc02023c4:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023c6:	0017f693          	andi	a3,a5,1
ffffffffc02023ca:	d2e5                	beqz	a3,ffffffffc02023aa <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023cc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023d0:	00279513          	slli	a0,a5,0x2
ffffffffc02023d4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023d6:	0eb57a63          	bleu	a1,a0,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023da:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023dc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023e0:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023e4:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023e6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023e8:	0cb7f563          	bleu	a1,a5,ffffffffc02024b2 <exit_range+0x206>
ffffffffc02023ec:	631c                	ld	a5,0(a4)
ffffffffc02023ee:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023f0:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023f4:	629c                	ld	a5,0(a3)
ffffffffc02023f6:	8b85                	andi	a5,a5,1
ffffffffc02023f8:	fbd5                	bnez	a5,ffffffffc02023ac <exit_range+0x100>
ffffffffc02023fa:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023fc:	fed59ce3          	bne	a1,a3,ffffffffc02023f4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0202400:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0202404:	4585                	li	a1,1
ffffffffc0202406:	e072                	sd	t3,0(sp)
ffffffffc0202408:	953e                	add	a0,a0,a5
ffffffffc020240a:	ad1ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
                d0start += PTSIZE;
ffffffffc020240e:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202410:	00043023          	sd	zero,0(s0)
ffffffffc0202414:	000aae97          	auipc	t4,0xaa
ffffffffc0202418:	114e8e93          	addi	t4,t4,276 # ffffffffc02ac528 <pages>
ffffffffc020241c:	6e02                	ld	t3,0(sp)
ffffffffc020241e:	c0000337          	lui	t1,0xc0000
ffffffffc0202422:	fff808b7          	lui	a7,0xfff80
ffffffffc0202426:	00080837          	lui	a6,0x80
ffffffffc020242a:	000aa717          	auipc	a4,0xaa
ffffffffc020242e:	0ee70713          	addi	a4,a4,238 # ffffffffc02ac518 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202432:	fcbd                	bnez	s1,ffffffffc02023b0 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202434:	f00c84e3          	beqz	s9,ffffffffc020233c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202438:	000d3783          	ld	a5,0(s10)
ffffffffc020243c:	e072                	sd	t3,0(sp)
ffffffffc020243e:	08fbf663          	bleu	a5,s7,ffffffffc02024ca <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202442:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202446:	67a2                	ld	a5,8(sp)
ffffffffc0202448:	4585                	li	a1,1
ffffffffc020244a:	953e                	add	a0,a0,a5
ffffffffc020244c:	a8fff0ef          	jal	ra,ffffffffc0201eda <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202450:	00093023          	sd	zero,0(s2)
ffffffffc0202454:	000aa717          	auipc	a4,0xaa
ffffffffc0202458:	0c470713          	addi	a4,a4,196 # ffffffffc02ac518 <va_pa_offset>
ffffffffc020245c:	c0000337          	lui	t1,0xc0000
ffffffffc0202460:	6e02                	ld	t3,0(sp)
ffffffffc0202462:	000aae97          	auipc	t4,0xaa
ffffffffc0202466:	0c6e8e93          	addi	t4,t4,198 # ffffffffc02ac528 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020246a:	ec099be3          	bnez	s3,ffffffffc0202340 <exit_range+0x94>
}
ffffffffc020246e:	70e6                	ld	ra,120(sp)
ffffffffc0202470:	7446                	ld	s0,112(sp)
ffffffffc0202472:	74a6                	ld	s1,104(sp)
ffffffffc0202474:	7906                	ld	s2,96(sp)
ffffffffc0202476:	69e6                	ld	s3,88(sp)
ffffffffc0202478:	6a46                	ld	s4,80(sp)
ffffffffc020247a:	6aa6                	ld	s5,72(sp)
ffffffffc020247c:	6b06                	ld	s6,64(sp)
ffffffffc020247e:	7be2                	ld	s7,56(sp)
ffffffffc0202480:	7c42                	ld	s8,48(sp)
ffffffffc0202482:	7ca2                	ld	s9,40(sp)
ffffffffc0202484:	7d02                	ld	s10,32(sp)
ffffffffc0202486:	6de2                	ld	s11,24(sp)
ffffffffc0202488:	6109                	addi	sp,sp,128
ffffffffc020248a:	8082                	ret
            if (free_pd0) {
ffffffffc020248c:	ea0c8ae3          	beqz	s9,ffffffffc0202340 <exit_range+0x94>
ffffffffc0202490:	b765                	j	ffffffffc0202438 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202492:	00005697          	auipc	a3,0x5
ffffffffc0202496:	51668693          	addi	a3,a3,1302 # ffffffffc02079a8 <default_pmm_manager+0x6d8>
ffffffffc020249a:	00004617          	auipc	a2,0x4
ffffffffc020249e:	6ee60613          	addi	a2,a2,1774 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02024a2:	12000593          	li	a1,288
ffffffffc02024a6:	00005517          	auipc	a0,0x5
ffffffffc02024aa:	fb250513          	addi	a0,a0,-78 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02024ae:	fd7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024b2:	00005617          	auipc	a2,0x5
ffffffffc02024b6:	e6e60613          	addi	a2,a2,-402 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc02024ba:	06900593          	li	a1,105
ffffffffc02024be:	00005517          	auipc	a0,0x5
ffffffffc02024c2:	e8a50513          	addi	a0,a0,-374 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc02024c6:	fbffd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024ca:	00005617          	auipc	a2,0x5
ffffffffc02024ce:	eb660613          	addi	a2,a2,-330 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc02024d2:	06200593          	li	a1,98
ffffffffc02024d6:	00005517          	auipc	a0,0x5
ffffffffc02024da:	e7250513          	addi	a0,a0,-398 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc02024de:	fa7fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024e2:	00005697          	auipc	a3,0x5
ffffffffc02024e6:	4f668693          	addi	a3,a3,1270 # ffffffffc02079d8 <default_pmm_manager+0x708>
ffffffffc02024ea:	00004617          	auipc	a2,0x4
ffffffffc02024ee:	69e60613          	addi	a2,a2,1694 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02024f2:	12100593          	li	a1,289
ffffffffc02024f6:	00005517          	auipc	a0,0x5
ffffffffc02024fa:	f6250513          	addi	a0,a0,-158 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02024fe:	f87fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202502 <copy_range>:
               bool share) {
ffffffffc0202502:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202504:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0202508:	ec86                	sd	ra,88(sp)
ffffffffc020250a:	e8a2                	sd	s0,80(sp)
ffffffffc020250c:	e4a6                	sd	s1,72(sp)
ffffffffc020250e:	e0ca                	sd	s2,64(sp)
ffffffffc0202510:	fc4e                	sd	s3,56(sp)
ffffffffc0202512:	f852                	sd	s4,48(sp)
ffffffffc0202514:	f456                	sd	s5,40(sp)
ffffffffc0202516:	f05a                	sd	s6,32(sp)
ffffffffc0202518:	ec5e                	sd	s7,24(sp)
ffffffffc020251a:	e862                	sd	s8,16(sp)
ffffffffc020251c:	e466                	sd	s9,8(sp)
ffffffffc020251e:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202520:	03479713          	slli	a4,a5,0x34
ffffffffc0202524:	14071863          	bnez	a4,ffffffffc0202674 <copy_range+0x172>
    assert(USER_ACCESS(start, end));
ffffffffc0202528:	002007b7          	lui	a5,0x200
ffffffffc020252c:	8432                	mv	s0,a2
ffffffffc020252e:	10f66763          	bltu	a2,a5,ffffffffc020263c <copy_range+0x13a>
ffffffffc0202532:	84b6                	mv	s1,a3
ffffffffc0202534:	10d67463          	bleu	a3,a2,ffffffffc020263c <copy_range+0x13a>
ffffffffc0202538:	4785                	li	a5,1
ffffffffc020253a:	07fe                	slli	a5,a5,0x1f
ffffffffc020253c:	10d7e063          	bltu	a5,a3,ffffffffc020263c <copy_range+0x13a>
ffffffffc0202540:	8a2a                	mv	s4,a0
ffffffffc0202542:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc0202544:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202546:	000aab97          	auipc	s7,0xaa
ffffffffc020254a:	f72b8b93          	addi	s7,s7,-142 # ffffffffc02ac4b8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020254e:	000aab17          	auipc	s6,0xaa
ffffffffc0202552:	fdab0b13          	addi	s6,s6,-38 # ffffffffc02ac528 <pages>
ffffffffc0202556:	fff80ab7          	lui	s5,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020255a:	00200cb7          	lui	s9,0x200
ffffffffc020255e:	ffe00c37          	lui	s8,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202562:	4601                	li	a2,0
ffffffffc0202564:	85a2                	mv	a1,s0
ffffffffc0202566:	854a                	mv	a0,s2
ffffffffc0202568:	9f9ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc020256c:	8d2a                	mv	s10,a0
        if (ptep == NULL) {
ffffffffc020256e:	c151                	beqz	a0,ffffffffc02025f2 <copy_range+0xf0>
        if (*ptep & PTE_V) {
ffffffffc0202570:	611c                	ld	a5,0(a0)
ffffffffc0202572:	8b85                	andi	a5,a5,1
ffffffffc0202574:	e39d                	bnez	a5,ffffffffc020259a <copy_range+0x98>
        start += PGSIZE;
ffffffffc0202576:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202578:	fe9465e3          	bltu	s0,s1,ffffffffc0202562 <copy_range+0x60>
    return 0;
ffffffffc020257c:	4501                	li	a0,0
}
ffffffffc020257e:	60e6                	ld	ra,88(sp)
ffffffffc0202580:	6446                	ld	s0,80(sp)
ffffffffc0202582:	64a6                	ld	s1,72(sp)
ffffffffc0202584:	6906                	ld	s2,64(sp)
ffffffffc0202586:	79e2                	ld	s3,56(sp)
ffffffffc0202588:	7a42                	ld	s4,48(sp)
ffffffffc020258a:	7aa2                	ld	s5,40(sp)
ffffffffc020258c:	7b02                	ld	s6,32(sp)
ffffffffc020258e:	6be2                	ld	s7,24(sp)
ffffffffc0202590:	6c42                	ld	s8,16(sp)
ffffffffc0202592:	6ca2                	ld	s9,8(sp)
ffffffffc0202594:	6d02                	ld	s10,0(sp)
ffffffffc0202596:	6125                	addi	sp,sp,96
ffffffffc0202598:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020259a:	4605                	li	a2,1
ffffffffc020259c:	85a2                	mv	a1,s0
ffffffffc020259e:	8552                	mv	a0,s4
ffffffffc02025a0:	9c1ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02025a4:	cd31                	beqz	a0,ffffffffc0202600 <copy_range+0xfe>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02025a6:	000d3783          	ld	a5,0(s10)
    if (!(pte & PTE_V)) {
ffffffffc02025aa:	0017f713          	andi	a4,a5,1
ffffffffc02025ae:	c75d                	beqz	a4,ffffffffc020265c <copy_range+0x15a>
    if (PPN(pa) >= npage) {
ffffffffc02025b0:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025b4:	078a                	slli	a5,a5,0x2
ffffffffc02025b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025b8:	06e7f663          	bleu	a4,a5,ffffffffc0202624 <copy_range+0x122>
    return &pages[PPN(pa) - nbase];
ffffffffc02025bc:	000b3d03          	ld	s10,0(s6)
ffffffffc02025c0:	97d6                	add	a5,a5,s5
ffffffffc02025c2:	079a                	slli	a5,a5,0x6
ffffffffc02025c4:	9d3e                	add	s10,s10,a5
            struct Page *npage = alloc_page();
ffffffffc02025c6:	4505                	li	a0,1
ffffffffc02025c8:	88bff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
            assert(page != NULL);
ffffffffc02025cc:	020d0c63          	beqz	s10,ffffffffc0202604 <copy_range+0x102>
            assert(npage != NULL);
ffffffffc02025d0:	f15d                	bnez	a0,ffffffffc0202576 <copy_range+0x74>
ffffffffc02025d2:	00005697          	auipc	a3,0x5
ffffffffc02025d6:	e7668693          	addi	a3,a3,-394 # ffffffffc0207448 <default_pmm_manager+0x178>
ffffffffc02025da:	00004617          	auipc	a2,0x4
ffffffffc02025de:	5ae60613          	addi	a2,a2,1454 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02025e2:	17300593          	li	a1,371
ffffffffc02025e6:	00005517          	auipc	a0,0x5
ffffffffc02025ea:	e7250513          	addi	a0,a0,-398 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02025ee:	e97fd0ef          	jal	ra,ffffffffc0200484 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02025f2:	9466                	add	s0,s0,s9
ffffffffc02025f4:	01847433          	and	s0,s0,s8
    } while (start != 0 && start < end);
ffffffffc02025f8:	d051                	beqz	s0,ffffffffc020257c <copy_range+0x7a>
ffffffffc02025fa:	f69464e3          	bltu	s0,s1,ffffffffc0202562 <copy_range+0x60>
ffffffffc02025fe:	bfbd                	j	ffffffffc020257c <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0202600:	5571                	li	a0,-4
ffffffffc0202602:	bfb5                	j	ffffffffc020257e <copy_range+0x7c>
            assert(page != NULL);
ffffffffc0202604:	00005697          	auipc	a3,0x5
ffffffffc0202608:	e3468693          	addi	a3,a3,-460 # ffffffffc0207438 <default_pmm_manager+0x168>
ffffffffc020260c:	00004617          	auipc	a2,0x4
ffffffffc0202610:	57c60613          	addi	a2,a2,1404 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202614:	17200593          	li	a1,370
ffffffffc0202618:	00005517          	auipc	a0,0x5
ffffffffc020261c:	e4050513          	addi	a0,a0,-448 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202620:	e65fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202624:	00005617          	auipc	a2,0x5
ffffffffc0202628:	d5c60613          	addi	a2,a2,-676 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc020262c:	06200593          	li	a1,98
ffffffffc0202630:	00005517          	auipc	a0,0x5
ffffffffc0202634:	d1850513          	addi	a0,a0,-744 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0202638:	e4dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020263c:	00005697          	auipc	a3,0x5
ffffffffc0202640:	39c68693          	addi	a3,a3,924 # ffffffffc02079d8 <default_pmm_manager+0x708>
ffffffffc0202644:	00004617          	auipc	a2,0x4
ffffffffc0202648:	54460613          	addi	a2,a2,1348 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020264c:	15e00593          	li	a1,350
ffffffffc0202650:	00005517          	auipc	a0,0x5
ffffffffc0202654:	e0850513          	addi	a0,a0,-504 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202658:	e2dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020265c:	00005617          	auipc	a2,0x5
ffffffffc0202660:	db460613          	addi	a2,a2,-588 # ffffffffc0207410 <default_pmm_manager+0x140>
ffffffffc0202664:	07400593          	li	a1,116
ffffffffc0202668:	00005517          	auipc	a0,0x5
ffffffffc020266c:	ce050513          	addi	a0,a0,-800 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0202670:	e15fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202674:	00005697          	auipc	a3,0x5
ffffffffc0202678:	33468693          	addi	a3,a3,820 # ffffffffc02079a8 <default_pmm_manager+0x6d8>
ffffffffc020267c:	00004617          	auipc	a2,0x4
ffffffffc0202680:	50c60613          	addi	a2,a2,1292 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202684:	15d00593          	li	a1,349
ffffffffc0202688:	00005517          	auipc	a0,0x5
ffffffffc020268c:	dd050513          	addi	a0,a0,-560 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202690:	df5fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202694 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202694:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202696:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202698:	e426                	sd	s1,8(sp)
ffffffffc020269a:	ec06                	sd	ra,24(sp)
ffffffffc020269c:	e822                	sd	s0,16(sp)
ffffffffc020269e:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026a0:	8c1ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep != NULL) {
ffffffffc02026a4:	c511                	beqz	a0,ffffffffc02026b0 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02026a6:	611c                	ld	a5,0(a0)
ffffffffc02026a8:	842a                	mv	s0,a0
ffffffffc02026aa:	0017f713          	andi	a4,a5,1
ffffffffc02026ae:	e711                	bnez	a4,ffffffffc02026ba <page_remove+0x26>
}
ffffffffc02026b0:	60e2                	ld	ra,24(sp)
ffffffffc02026b2:	6442                	ld	s0,16(sp)
ffffffffc02026b4:	64a2                	ld	s1,8(sp)
ffffffffc02026b6:	6105                	addi	sp,sp,32
ffffffffc02026b8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02026ba:	000aa717          	auipc	a4,0xaa
ffffffffc02026be:	dfe70713          	addi	a4,a4,-514 # ffffffffc02ac4b8 <npage>
ffffffffc02026c2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02026c4:	078a                	slli	a5,a5,0x2
ffffffffc02026c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026c8:	02e7fe63          	bleu	a4,a5,ffffffffc0202704 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc02026cc:	000aa717          	auipc	a4,0xaa
ffffffffc02026d0:	e5c70713          	addi	a4,a4,-420 # ffffffffc02ac528 <pages>
ffffffffc02026d4:	6308                	ld	a0,0(a4)
ffffffffc02026d6:	fff80737          	lui	a4,0xfff80
ffffffffc02026da:	97ba                	add	a5,a5,a4
ffffffffc02026dc:	079a                	slli	a5,a5,0x6
ffffffffc02026de:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02026e0:	411c                	lw	a5,0(a0)
ffffffffc02026e2:	fff7871b          	addiw	a4,a5,-1
ffffffffc02026e6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02026e8:	cb11                	beqz	a4,ffffffffc02026fc <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02026ea:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026ee:	12048073          	sfence.vma	s1
}
ffffffffc02026f2:	60e2                	ld	ra,24(sp)
ffffffffc02026f4:	6442                	ld	s0,16(sp)
ffffffffc02026f6:	64a2                	ld	s1,8(sp)
ffffffffc02026f8:	6105                	addi	sp,sp,32
ffffffffc02026fa:	8082                	ret
            free_page(page);
ffffffffc02026fc:	4585                	li	a1,1
ffffffffc02026fe:	fdcff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc0202702:	b7e5                	j	ffffffffc02026ea <page_remove+0x56>
ffffffffc0202704:	f32ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc0202708 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202708:	7179                	addi	sp,sp,-48
ffffffffc020270a:	e44e                	sd	s3,8(sp)
ffffffffc020270c:	89b2                	mv	s3,a2
ffffffffc020270e:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202710:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202712:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202714:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202716:	ec26                	sd	s1,24(sp)
ffffffffc0202718:	f406                	sd	ra,40(sp)
ffffffffc020271a:	e84a                	sd	s2,16(sp)
ffffffffc020271c:	e052                	sd	s4,0(sp)
ffffffffc020271e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202720:	841ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    if (ptep == NULL) {
ffffffffc0202724:	cd49                	beqz	a0,ffffffffc02027be <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202726:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202728:	611c                	ld	a5,0(a0)
ffffffffc020272a:	892a                	mv	s2,a0
ffffffffc020272c:	0016871b          	addiw	a4,a3,1
ffffffffc0202730:	c018                	sw	a4,0(s0)
ffffffffc0202732:	0017f713          	andi	a4,a5,1
ffffffffc0202736:	ef05                	bnez	a4,ffffffffc020276e <page_insert+0x66>
ffffffffc0202738:	000aa797          	auipc	a5,0xaa
ffffffffc020273c:	df078793          	addi	a5,a5,-528 # ffffffffc02ac528 <pages>
ffffffffc0202740:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0202742:	8c19                	sub	s0,s0,a4
ffffffffc0202744:	000806b7          	lui	a3,0x80
ffffffffc0202748:	8419                	srai	s0,s0,0x6
ffffffffc020274a:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020274c:	042a                	slli	s0,s0,0xa
ffffffffc020274e:	8c45                	or	s0,s0,s1
ffffffffc0202750:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202754:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202758:	12098073          	sfence.vma	s3
    return 0;
ffffffffc020275c:	4501                	li	a0,0
}
ffffffffc020275e:	70a2                	ld	ra,40(sp)
ffffffffc0202760:	7402                	ld	s0,32(sp)
ffffffffc0202762:	64e2                	ld	s1,24(sp)
ffffffffc0202764:	6942                	ld	s2,16(sp)
ffffffffc0202766:	69a2                	ld	s3,8(sp)
ffffffffc0202768:	6a02                	ld	s4,0(sp)
ffffffffc020276a:	6145                	addi	sp,sp,48
ffffffffc020276c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020276e:	000aa717          	auipc	a4,0xaa
ffffffffc0202772:	d4a70713          	addi	a4,a4,-694 # ffffffffc02ac4b8 <npage>
ffffffffc0202776:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202778:	078a                	slli	a5,a5,0x2
ffffffffc020277a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020277c:	04e7f363          	bleu	a4,a5,ffffffffc02027c2 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202780:	000aaa17          	auipc	s4,0xaa
ffffffffc0202784:	da8a0a13          	addi	s4,s4,-600 # ffffffffc02ac528 <pages>
ffffffffc0202788:	000a3703          	ld	a4,0(s4)
ffffffffc020278c:	fff80537          	lui	a0,0xfff80
ffffffffc0202790:	953e                	add	a0,a0,a5
ffffffffc0202792:	051a                	slli	a0,a0,0x6
ffffffffc0202794:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0202796:	00a40a63          	beq	s0,a0,ffffffffc02027aa <page_insert+0xa2>
    page->ref -= 1;
ffffffffc020279a:	411c                	lw	a5,0(a0)
ffffffffc020279c:	fff7869b          	addiw	a3,a5,-1
ffffffffc02027a0:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02027a2:	c691                	beqz	a3,ffffffffc02027ae <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027a4:	12098073          	sfence.vma	s3
ffffffffc02027a8:	bf69                	j	ffffffffc0202742 <page_insert+0x3a>
ffffffffc02027aa:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02027ac:	bf59                	j	ffffffffc0202742 <page_insert+0x3a>
            free_page(page);
ffffffffc02027ae:	4585                	li	a1,1
ffffffffc02027b0:	f2aff0ef          	jal	ra,ffffffffc0201eda <free_pages>
ffffffffc02027b4:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027b8:	12098073          	sfence.vma	s3
ffffffffc02027bc:	b759                	j	ffffffffc0202742 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02027be:	5571                	li	a0,-4
ffffffffc02027c0:	bf79                	j	ffffffffc020275e <page_insert+0x56>
ffffffffc02027c2:	e74ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>

ffffffffc02027c6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02027c6:	00005797          	auipc	a5,0x5
ffffffffc02027ca:	b0a78793          	addi	a5,a5,-1270 # ffffffffc02072d0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027ce:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02027d0:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027d2:	00005517          	auipc	a0,0x5
ffffffffc02027d6:	cae50513          	addi	a0,a0,-850 # ffffffffc0207480 <default_pmm_manager+0x1b0>
void pmm_init(void) {
ffffffffc02027da:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02027dc:	000aa717          	auipc	a4,0xaa
ffffffffc02027e0:	d2f73a23          	sd	a5,-716(a4) # ffffffffc02ac510 <pmm_manager>
void pmm_init(void) {
ffffffffc02027e4:	e0a2                	sd	s0,64(sp)
ffffffffc02027e6:	fc26                	sd	s1,56(sp)
ffffffffc02027e8:	f84a                	sd	s2,48(sp)
ffffffffc02027ea:	f44e                	sd	s3,40(sp)
ffffffffc02027ec:	f052                	sd	s4,32(sp)
ffffffffc02027ee:	ec56                	sd	s5,24(sp)
ffffffffc02027f0:	e85a                	sd	s6,16(sp)
ffffffffc02027f2:	e45e                	sd	s7,8(sp)
ffffffffc02027f4:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02027f6:	000aa417          	auipc	s0,0xaa
ffffffffc02027fa:	d1a40413          	addi	s0,s0,-742 # ffffffffc02ac510 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02027fe:	991fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202802:	601c                	ld	a5,0(s0)
ffffffffc0202804:	000aa497          	auipc	s1,0xaa
ffffffffc0202808:	cb448493          	addi	s1,s1,-844 # ffffffffc02ac4b8 <npage>
ffffffffc020280c:	000aa917          	auipc	s2,0xaa
ffffffffc0202810:	d1c90913          	addi	s2,s2,-740 # ffffffffc02ac528 <pages>
ffffffffc0202814:	679c                	ld	a5,8(a5)
ffffffffc0202816:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202818:	57f5                	li	a5,-3
ffffffffc020281a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020281c:	00005517          	auipc	a0,0x5
ffffffffc0202820:	c7c50513          	addi	a0,a0,-900 # ffffffffc0207498 <default_pmm_manager+0x1c8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202824:	000aa717          	auipc	a4,0xaa
ffffffffc0202828:	cef73a23          	sd	a5,-780(a4) # ffffffffc02ac518 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020282c:	963fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202830:	46c5                	li	a3,17
ffffffffc0202832:	06ee                	slli	a3,a3,0x1b
ffffffffc0202834:	40100613          	li	a2,1025
ffffffffc0202838:	16fd                	addi	a3,a3,-1
ffffffffc020283a:	0656                	slli	a2,a2,0x15
ffffffffc020283c:	07e005b7          	lui	a1,0x7e00
ffffffffc0202840:	00005517          	auipc	a0,0x5
ffffffffc0202844:	c7050513          	addi	a0,a0,-912 # ffffffffc02074b0 <default_pmm_manager+0x1e0>
ffffffffc0202848:	947fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020284c:	777d                	lui	a4,0xfffff
ffffffffc020284e:	000ab797          	auipc	a5,0xab
ffffffffc0202852:	dd178793          	addi	a5,a5,-559 # ffffffffc02ad61f <end+0xfff>
ffffffffc0202856:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202858:	00088737          	lui	a4,0x88
ffffffffc020285c:	000aa697          	auipc	a3,0xaa
ffffffffc0202860:	c4e6be23          	sd	a4,-932(a3) # ffffffffc02ac4b8 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202864:	000aa717          	auipc	a4,0xaa
ffffffffc0202868:	ccf73223          	sd	a5,-828(a4) # ffffffffc02ac528 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020286c:	4701                	li	a4,0
ffffffffc020286e:	4685                	li	a3,1
ffffffffc0202870:	fff80837          	lui	a6,0xfff80
ffffffffc0202874:	a019                	j	ffffffffc020287a <pmm_init+0xb4>
ffffffffc0202876:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc020287a:	00671613          	slli	a2,a4,0x6
ffffffffc020287e:	97b2                	add	a5,a5,a2
ffffffffc0202880:	07a1                	addi	a5,a5,8
ffffffffc0202882:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202886:	6090                	ld	a2,0(s1)
ffffffffc0202888:	0705                	addi	a4,a4,1
ffffffffc020288a:	010607b3          	add	a5,a2,a6
ffffffffc020288e:	fef764e3          	bltu	a4,a5,ffffffffc0202876 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202892:	00093503          	ld	a0,0(s2)
ffffffffc0202896:	fe0007b7          	lui	a5,0xfe000
ffffffffc020289a:	00661693          	slli	a3,a2,0x6
ffffffffc020289e:	97aa                	add	a5,a5,a0
ffffffffc02028a0:	96be                	add	a3,a3,a5
ffffffffc02028a2:	c02007b7          	lui	a5,0xc0200
ffffffffc02028a6:	7af6ed63          	bltu	a3,a5,ffffffffc0203060 <pmm_init+0x89a>
ffffffffc02028aa:	000aa997          	auipc	s3,0xaa
ffffffffc02028ae:	c6e98993          	addi	s3,s3,-914 # ffffffffc02ac518 <va_pa_offset>
ffffffffc02028b2:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02028b6:	47c5                	li	a5,17
ffffffffc02028b8:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028ba:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02028bc:	02f6f763          	bleu	a5,a3,ffffffffc02028ea <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02028c0:	6585                	lui	a1,0x1
ffffffffc02028c2:	15fd                	addi	a1,a1,-1
ffffffffc02028c4:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02028c6:	00c6d713          	srli	a4,a3,0xc
ffffffffc02028ca:	48c77a63          	bleu	a2,a4,ffffffffc0202d5e <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc02028ce:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02028d0:	75fd                	lui	a1,0xfffff
ffffffffc02028d2:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02028d4:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc02028d6:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02028d8:	40d786b3          	sub	a3,a5,a3
ffffffffc02028dc:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02028de:	00c6d593          	srli	a1,a3,0xc
ffffffffc02028e2:	953a                	add	a0,a0,a4
ffffffffc02028e4:	9602                	jalr	a2
ffffffffc02028e6:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02028ea:	00005517          	auipc	a0,0x5
ffffffffc02028ee:	bee50513          	addi	a0,a0,-1042 # ffffffffc02074d8 <default_pmm_manager+0x208>
ffffffffc02028f2:	89dfd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02028f6:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02028f8:	000aa417          	auipc	s0,0xaa
ffffffffc02028fc:	bb840413          	addi	s0,s0,-1096 # ffffffffc02ac4b0 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202900:	7b9c                	ld	a5,48(a5)
ffffffffc0202902:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202904:	00005517          	auipc	a0,0x5
ffffffffc0202908:	bec50513          	addi	a0,a0,-1044 # ffffffffc02074f0 <default_pmm_manager+0x220>
ffffffffc020290c:	883fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202910:	00008697          	auipc	a3,0x8
ffffffffc0202914:	6f068693          	addi	a3,a3,1776 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202918:	000aa797          	auipc	a5,0xaa
ffffffffc020291c:	b8d7bc23          	sd	a3,-1128(a5) # ffffffffc02ac4b0 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202920:	c02007b7          	lui	a5,0xc0200
ffffffffc0202924:	10f6eae3          	bltu	a3,a5,ffffffffc0203238 <pmm_init+0xa72>
ffffffffc0202928:	0009b783          	ld	a5,0(s3)
ffffffffc020292c:	8e9d                	sub	a3,a3,a5
ffffffffc020292e:	000aa797          	auipc	a5,0xaa
ffffffffc0202932:	bed7b923          	sd	a3,-1038(a5) # ffffffffc02ac520 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202936:	deaff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020293a:	6098                	ld	a4,0(s1)
ffffffffc020293c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202940:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202942:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202944:	0ce7eae3          	bltu	a5,a4,ffffffffc0203218 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202948:	6008                	ld	a0,0(s0)
ffffffffc020294a:	44050463          	beqz	a0,ffffffffc0202d92 <pmm_init+0x5cc>
ffffffffc020294e:	6785                	lui	a5,0x1
ffffffffc0202950:	17fd                	addi	a5,a5,-1
ffffffffc0202952:	8fe9                	and	a5,a5,a0
ffffffffc0202954:	2781                	sext.w	a5,a5
ffffffffc0202956:	42079e63          	bnez	a5,ffffffffc0202d92 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020295a:	4601                	li	a2,0
ffffffffc020295c:	4581                	li	a1,0
ffffffffc020295e:	fd4ff0ef          	jal	ra,ffffffffc0202132 <get_page>
ffffffffc0202962:	78051b63          	bnez	a0,ffffffffc02030f8 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202966:	4505                	li	a0,1
ffffffffc0202968:	ceaff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020296c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020296e:	6008                	ld	a0,0(s0)
ffffffffc0202970:	4681                	li	a3,0
ffffffffc0202972:	4601                	li	a2,0
ffffffffc0202974:	85d6                	mv	a1,s5
ffffffffc0202976:	d93ff0ef          	jal	ra,ffffffffc0202708 <page_insert>
ffffffffc020297a:	7a051f63          	bnez	a0,ffffffffc0203138 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020297e:	6008                	ld	a0,0(s0)
ffffffffc0202980:	4601                	li	a2,0
ffffffffc0202982:	4581                	li	a1,0
ffffffffc0202984:	ddcff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202988:	78050863          	beqz	a0,ffffffffc0203118 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc020298c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020298e:	0017f713          	andi	a4,a5,1
ffffffffc0202992:	3e070463          	beqz	a4,ffffffffc0202d7a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202996:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202998:	078a                	slli	a5,a5,0x2
ffffffffc020299a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020299c:	3ce7f163          	bleu	a4,a5,ffffffffc0202d5e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02029a0:	00093683          	ld	a3,0(s2)
ffffffffc02029a4:	fff80637          	lui	a2,0xfff80
ffffffffc02029a8:	97b2                	add	a5,a5,a2
ffffffffc02029aa:	079a                	slli	a5,a5,0x6
ffffffffc02029ac:	97b6                	add	a5,a5,a3
ffffffffc02029ae:	72fa9563          	bne	s5,a5,ffffffffc02030d8 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc02029b2:	000aab83          	lw	s7,0(s5) # fffffffffff80000 <end+0x3fcd39e0>
ffffffffc02029b6:	4785                	li	a5,1
ffffffffc02029b8:	70fb9063          	bne	s7,a5,ffffffffc02030b8 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02029bc:	6008                	ld	a0,0(s0)
ffffffffc02029be:	76fd                	lui	a3,0xfffff
ffffffffc02029c0:	611c                	ld	a5,0(a0)
ffffffffc02029c2:	078a                	slli	a5,a5,0x2
ffffffffc02029c4:	8ff5                	and	a5,a5,a3
ffffffffc02029c6:	00c7d613          	srli	a2,a5,0xc
ffffffffc02029ca:	66e67e63          	bleu	a4,a2,ffffffffc0203046 <pmm_init+0x880>
ffffffffc02029ce:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029d2:	97e2                	add	a5,a5,s8
ffffffffc02029d4:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc02029d8:	0b0a                	slli	s6,s6,0x2
ffffffffc02029da:	00db7b33          	and	s6,s6,a3
ffffffffc02029de:	00cb5793          	srli	a5,s6,0xc
ffffffffc02029e2:	56e7f863          	bleu	a4,a5,ffffffffc0202f52 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02029e6:	4601                	li	a2,0
ffffffffc02029e8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029ea:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02029ec:	d74ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02029f0:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02029f2:	55651063          	bne	a0,s6,ffffffffc0202f32 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc02029f6:	4505                	li	a0,1
ffffffffc02029f8:	c5aff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc02029fc:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02029fe:	6008                	ld	a0,0(s0)
ffffffffc0202a00:	46d1                	li	a3,20
ffffffffc0202a02:	6605                	lui	a2,0x1
ffffffffc0202a04:	85da                	mv	a1,s6
ffffffffc0202a06:	d03ff0ef          	jal	ra,ffffffffc0202708 <page_insert>
ffffffffc0202a0a:	50051463          	bnez	a0,ffffffffc0202f12 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202a0e:	6008                	ld	a0,0(s0)
ffffffffc0202a10:	4601                	li	a2,0
ffffffffc0202a12:	6585                	lui	a1,0x1
ffffffffc0202a14:	d4cff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202a18:	4c050d63          	beqz	a0,ffffffffc0202ef2 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0202a1c:	611c                	ld	a5,0(a0)
ffffffffc0202a1e:	0107f713          	andi	a4,a5,16
ffffffffc0202a22:	4a070863          	beqz	a4,ffffffffc0202ed2 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202a26:	8b91                	andi	a5,a5,4
ffffffffc0202a28:	48078563          	beqz	a5,ffffffffc0202eb2 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202a2c:	6008                	ld	a0,0(s0)
ffffffffc0202a2e:	611c                	ld	a5,0(a0)
ffffffffc0202a30:	8bc1                	andi	a5,a5,16
ffffffffc0202a32:	46078063          	beqz	a5,ffffffffc0202e92 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202a36:	000b2783          	lw	a5,0(s6)
ffffffffc0202a3a:	43779c63          	bne	a5,s7,ffffffffc0202e72 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202a3e:	4681                	li	a3,0
ffffffffc0202a40:	6605                	lui	a2,0x1
ffffffffc0202a42:	85d6                	mv	a1,s5
ffffffffc0202a44:	cc5ff0ef          	jal	ra,ffffffffc0202708 <page_insert>
ffffffffc0202a48:	40051563          	bnez	a0,ffffffffc0202e52 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0202a4c:	000aa703          	lw	a4,0(s5)
ffffffffc0202a50:	4789                	li	a5,2
ffffffffc0202a52:	3ef71063          	bne	a4,a5,ffffffffc0202e32 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0202a56:	000b2783          	lw	a5,0(s6)
ffffffffc0202a5a:	3a079c63          	bnez	a5,ffffffffc0202e12 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202a5e:	6008                	ld	a0,0(s0)
ffffffffc0202a60:	4601                	li	a2,0
ffffffffc0202a62:	6585                	lui	a1,0x1
ffffffffc0202a64:	cfcff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202a68:	38050563          	beqz	a0,ffffffffc0202df2 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a6c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202a6e:	00177793          	andi	a5,a4,1
ffffffffc0202a72:	30078463          	beqz	a5,ffffffffc0202d7a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202a76:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a78:	00271793          	slli	a5,a4,0x2
ffffffffc0202a7c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a7e:	2ed7f063          	bleu	a3,a5,ffffffffc0202d5e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a82:	00093683          	ld	a3,0(s2)
ffffffffc0202a86:	fff80637          	lui	a2,0xfff80
ffffffffc0202a8a:	97b2                	add	a5,a5,a2
ffffffffc0202a8c:	079a                	slli	a5,a5,0x6
ffffffffc0202a8e:	97b6                	add	a5,a5,a3
ffffffffc0202a90:	32fa9163          	bne	s5,a5,ffffffffc0202db2 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202a94:	8b41                	andi	a4,a4,16
ffffffffc0202a96:	70071163          	bnez	a4,ffffffffc0203198 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202a9a:	6008                	ld	a0,0(s0)
ffffffffc0202a9c:	4581                	li	a1,0
ffffffffc0202a9e:	bf7ff0ef          	jal	ra,ffffffffc0202694 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202aa2:	000aa703          	lw	a4,0(s5)
ffffffffc0202aa6:	4785                	li	a5,1
ffffffffc0202aa8:	6cf71863          	bne	a4,a5,ffffffffc0203178 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0202aac:	000b2783          	lw	a5,0(s6)
ffffffffc0202ab0:	6a079463          	bnez	a5,ffffffffc0203158 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202ab4:	6008                	ld	a0,0(s0)
ffffffffc0202ab6:	6585                	lui	a1,0x1
ffffffffc0202ab8:	bddff0ef          	jal	ra,ffffffffc0202694 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202abc:	000aa783          	lw	a5,0(s5)
ffffffffc0202ac0:	50079363          	bnez	a5,ffffffffc0202fc6 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202ac4:	000b2783          	lw	a5,0(s6)
ffffffffc0202ac8:	4c079f63          	bnez	a5,ffffffffc0202fa6 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202acc:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ad0:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ad2:	000ab783          	ld	a5,0(s5)
ffffffffc0202ad6:	078a                	slli	a5,a5,0x2
ffffffffc0202ad8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ada:	28c7f263          	bleu	a2,a5,ffffffffc0202d5e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ade:	fff80737          	lui	a4,0xfff80
ffffffffc0202ae2:	00093503          	ld	a0,0(s2)
ffffffffc0202ae6:	97ba                	add	a5,a5,a4
ffffffffc0202ae8:	079a                	slli	a5,a5,0x6
ffffffffc0202aea:	00f50733          	add	a4,a0,a5
ffffffffc0202aee:	4314                	lw	a3,0(a4)
ffffffffc0202af0:	4705                	li	a4,1
ffffffffc0202af2:	48e69a63          	bne	a3,a4,ffffffffc0202f86 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202af6:	8799                	srai	a5,a5,0x6
ffffffffc0202af8:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202afc:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0202afe:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202b00:	8331                	srli	a4,a4,0xc
ffffffffc0202b02:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b04:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202b06:	46c77363          	bleu	a2,a4,ffffffffc0202f6c <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202b0a:	0009b683          	ld	a3,0(s3)
ffffffffc0202b0e:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b10:	639c                	ld	a5,0(a5)
ffffffffc0202b12:	078a                	slli	a5,a5,0x2
ffffffffc0202b14:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b16:	24c7f463          	bleu	a2,a5,ffffffffc0202d5e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b1a:	416787b3          	sub	a5,a5,s6
ffffffffc0202b1e:	079a                	slli	a5,a5,0x6
ffffffffc0202b20:	953e                	add	a0,a0,a5
ffffffffc0202b22:	4585                	li	a1,1
ffffffffc0202b24:	bb6ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b28:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0202b2c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b2e:	078a                	slli	a5,a5,0x2
ffffffffc0202b30:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b32:	22e7f663          	bleu	a4,a5,ffffffffc0202d5e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b36:	00093503          	ld	a0,0(s2)
ffffffffc0202b3a:	416787b3          	sub	a5,a5,s6
ffffffffc0202b3e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b40:	953e                	add	a0,a0,a5
ffffffffc0202b42:	4585                	li	a1,1
ffffffffc0202b44:	b96ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b48:	601c                	ld	a5,0(s0)
ffffffffc0202b4a:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202b4e:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b52:	bceff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc0202b56:	68aa1163          	bne	s4,a0,ffffffffc02031d8 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202b5a:	00005517          	auipc	a0,0x5
ffffffffc0202b5e:	c7e50513          	addi	a0,a0,-898 # ffffffffc02077d8 <default_pmm_manager+0x508>
ffffffffc0202b62:	e2cfd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202b66:	bbaff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202b6a:	6098                	ld	a4,0(s1)
ffffffffc0202b6c:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0202b70:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202b72:	00c71693          	slli	a3,a4,0xc
ffffffffc0202b76:	18d7f563          	bleu	a3,a5,ffffffffc0202d00 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b7a:	83b1                	srli	a5,a5,0xc
ffffffffc0202b7c:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202b7e:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b82:	1ae7f163          	bleu	a4,a5,ffffffffc0202d24 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b86:	7bfd                	lui	s7,0xfffff
ffffffffc0202b88:	6b05                	lui	s6,0x1
ffffffffc0202b8a:	a029                	j	ffffffffc0202b94 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b8c:	00cad713          	srli	a4,s5,0xc
ffffffffc0202b90:	18f77a63          	bleu	a5,a4,ffffffffc0202d24 <pmm_init+0x55e>
ffffffffc0202b94:	0009b583          	ld	a1,0(s3)
ffffffffc0202b98:	4601                	li	a2,0
ffffffffc0202b9a:	95d6                	add	a1,a1,s5
ffffffffc0202b9c:	bc4ff0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0202ba0:	16050263          	beqz	a0,ffffffffc0202d04 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202ba4:	611c                	ld	a5,0(a0)
ffffffffc0202ba6:	078a                	slli	a5,a5,0x2
ffffffffc0202ba8:	0177f7b3          	and	a5,a5,s7
ffffffffc0202bac:	19579963          	bne	a5,s5,ffffffffc0202d3e <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202bb0:	609c                	ld	a5,0(s1)
ffffffffc0202bb2:	9ada                	add	s5,s5,s6
ffffffffc0202bb4:	6008                	ld	a0,0(s0)
ffffffffc0202bb6:	00c79713          	slli	a4,a5,0xc
ffffffffc0202bba:	fceae9e3          	bltu	s5,a4,ffffffffc0202b8c <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202bbe:	611c                	ld	a5,0(a0)
ffffffffc0202bc0:	62079c63          	bnez	a5,ffffffffc02031f8 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202bc4:	4505                	li	a0,1
ffffffffc0202bc6:	a8cff0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0202bca:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202bcc:	6008                	ld	a0,0(s0)
ffffffffc0202bce:	4699                	li	a3,6
ffffffffc0202bd0:	10000613          	li	a2,256
ffffffffc0202bd4:	85d6                	mv	a1,s5
ffffffffc0202bd6:	b33ff0ef          	jal	ra,ffffffffc0202708 <page_insert>
ffffffffc0202bda:	1e051c63          	bnez	a0,ffffffffc0202dd2 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202bde:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202be2:	4785                	li	a5,1
ffffffffc0202be4:	44f71163          	bne	a4,a5,ffffffffc0203026 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202be8:	6008                	ld	a0,0(s0)
ffffffffc0202bea:	6b05                	lui	s6,0x1
ffffffffc0202bec:	4699                	li	a3,6
ffffffffc0202bee:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8478>
ffffffffc0202bf2:	85d6                	mv	a1,s5
ffffffffc0202bf4:	b15ff0ef          	jal	ra,ffffffffc0202708 <page_insert>
ffffffffc0202bf8:	40051763          	bnez	a0,ffffffffc0203006 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202bfc:	000aa703          	lw	a4,0(s5)
ffffffffc0202c00:	4789                	li	a5,2
ffffffffc0202c02:	3ef71263          	bne	a4,a5,ffffffffc0202fe6 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202c06:	00005597          	auipc	a1,0x5
ffffffffc0202c0a:	d0a58593          	addi	a1,a1,-758 # ffffffffc0207910 <default_pmm_manager+0x640>
ffffffffc0202c0e:	10000513          	li	a0,256
ffffffffc0202c12:	0fd030ef          	jal	ra,ffffffffc020650e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202c16:	100b0593          	addi	a1,s6,256
ffffffffc0202c1a:	10000513          	li	a0,256
ffffffffc0202c1e:	103030ef          	jal	ra,ffffffffc0206520 <strcmp>
ffffffffc0202c22:	44051b63          	bnez	a0,ffffffffc0203078 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202c26:	00093683          	ld	a3,0(s2)
ffffffffc0202c2a:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202c2e:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202c30:	40da86b3          	sub	a3,s5,a3
ffffffffc0202c34:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202c36:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202c38:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202c3a:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202c3e:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c42:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c44:	10f77f63          	bleu	a5,a4,ffffffffc0202d62 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c48:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202c4c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202c50:	96be                	add	a3,a3,a5
ffffffffc0202c52:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52ae0>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202c56:	075030ef          	jal	ra,ffffffffc02064ca <strlen>
ffffffffc0202c5a:	54051f63          	bnez	a0,ffffffffc02031b8 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202c5e:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202c62:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c64:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd529e0>
ffffffffc0202c68:	068a                	slli	a3,a3,0x2
ffffffffc0202c6a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c6c:	0ef6f963          	bleu	a5,a3,ffffffffc0202d5e <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202c70:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202c76:	0efb7663          	bleu	a5,s6,ffffffffc0202d62 <pmm_init+0x59c>
ffffffffc0202c7a:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202c7e:	4585                	li	a1,1
ffffffffc0202c80:	8556                	mv	a0,s5
ffffffffc0202c82:	99b6                	add	s3,s3,a3
ffffffffc0202c84:	a56ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c88:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202c8c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c8e:	078a                	slli	a5,a5,0x2
ffffffffc0202c90:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c92:	0ce7f663          	bleu	a4,a5,ffffffffc0202d5e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c96:	00093503          	ld	a0,0(s2)
ffffffffc0202c9a:	fff809b7          	lui	s3,0xfff80
ffffffffc0202c9e:	97ce                	add	a5,a5,s3
ffffffffc0202ca0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202ca2:	953e                	add	a0,a0,a5
ffffffffc0202ca4:	4585                	li	a1,1
ffffffffc0202ca6:	a34ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202caa:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202cae:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cb0:	078a                	slli	a5,a5,0x2
ffffffffc0202cb2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202cb4:	0ae7f563          	bleu	a4,a5,ffffffffc0202d5e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cb8:	00093503          	ld	a0,0(s2)
ffffffffc0202cbc:	97ce                	add	a5,a5,s3
ffffffffc0202cbe:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202cc0:	953e                	add	a0,a0,a5
ffffffffc0202cc2:	4585                	li	a1,1
ffffffffc0202cc4:	a16ff0ef          	jal	ra,ffffffffc0201eda <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202cc8:	601c                	ld	a5,0(s0)
ffffffffc0202cca:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202cce:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202cd2:	a4eff0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc0202cd6:	3caa1163          	bne	s4,a0,ffffffffc0203098 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202cda:	00005517          	auipc	a0,0x5
ffffffffc0202cde:	cae50513          	addi	a0,a0,-850 # ffffffffc0207988 <default_pmm_manager+0x6b8>
ffffffffc0202ce2:	cacfd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202ce6:	6406                	ld	s0,64(sp)
ffffffffc0202ce8:	60a6                	ld	ra,72(sp)
ffffffffc0202cea:	74e2                	ld	s1,56(sp)
ffffffffc0202cec:	7942                	ld	s2,48(sp)
ffffffffc0202cee:	79a2                	ld	s3,40(sp)
ffffffffc0202cf0:	7a02                	ld	s4,32(sp)
ffffffffc0202cf2:	6ae2                	ld	s5,24(sp)
ffffffffc0202cf4:	6b42                	ld	s6,16(sp)
ffffffffc0202cf6:	6ba2                	ld	s7,8(sp)
ffffffffc0202cf8:	6c02                	ld	s8,0(sp)
ffffffffc0202cfa:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202cfc:	f37fe06f          	j	ffffffffc0201c32 <kmalloc_init>
ffffffffc0202d00:	6008                	ld	a0,0(s0)
ffffffffc0202d02:	bd75                	j	ffffffffc0202bbe <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d04:	00005697          	auipc	a3,0x5
ffffffffc0202d08:	af468693          	addi	a3,a3,-1292 # ffffffffc02077f8 <default_pmm_manager+0x528>
ffffffffc0202d0c:	00004617          	auipc	a2,0x4
ffffffffc0202d10:	e7c60613          	addi	a2,a2,-388 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202d14:	22400593          	li	a1,548
ffffffffc0202d18:	00004517          	auipc	a0,0x4
ffffffffc0202d1c:	74050513          	addi	a0,a0,1856 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202d20:	f64fd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202d24:	86d6                	mv	a3,s5
ffffffffc0202d26:	00004617          	auipc	a2,0x4
ffffffffc0202d2a:	5fa60613          	addi	a2,a2,1530 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0202d2e:	22400593          	li	a1,548
ffffffffc0202d32:	00004517          	auipc	a0,0x4
ffffffffc0202d36:	72650513          	addi	a0,a0,1830 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202d3a:	f4afd0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d3e:	00005697          	auipc	a3,0x5
ffffffffc0202d42:	afa68693          	addi	a3,a3,-1286 # ffffffffc0207838 <default_pmm_manager+0x568>
ffffffffc0202d46:	00004617          	auipc	a2,0x4
ffffffffc0202d4a:	e4260613          	addi	a2,a2,-446 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202d4e:	22500593          	li	a1,549
ffffffffc0202d52:	00004517          	auipc	a0,0x4
ffffffffc0202d56:	70650513          	addi	a0,a0,1798 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202d5a:	f2afd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202d5e:	8d8ff0ef          	jal	ra,ffffffffc0201e36 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202d62:	00004617          	auipc	a2,0x4
ffffffffc0202d66:	5be60613          	addi	a2,a2,1470 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0202d6a:	06900593          	li	a1,105
ffffffffc0202d6e:	00004517          	auipc	a0,0x4
ffffffffc0202d72:	5da50513          	addi	a0,a0,1498 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0202d76:	f0efd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202d7a:	00004617          	auipc	a2,0x4
ffffffffc0202d7e:	69660613          	addi	a2,a2,1686 # ffffffffc0207410 <default_pmm_manager+0x140>
ffffffffc0202d82:	07400593          	li	a1,116
ffffffffc0202d86:	00004517          	auipc	a0,0x4
ffffffffc0202d8a:	5c250513          	addi	a0,a0,1474 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0202d8e:	ef6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202d92:	00004697          	auipc	a3,0x4
ffffffffc0202d96:	79e68693          	addi	a3,a3,1950 # ffffffffc0207530 <default_pmm_manager+0x260>
ffffffffc0202d9a:	00004617          	auipc	a2,0x4
ffffffffc0202d9e:	dee60613          	addi	a2,a2,-530 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202da2:	1e800593          	li	a1,488
ffffffffc0202da6:	00004517          	auipc	a0,0x4
ffffffffc0202daa:	6b250513          	addi	a0,a0,1714 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202dae:	ed6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202db2:	00005697          	auipc	a3,0x5
ffffffffc0202db6:	83e68693          	addi	a3,a3,-1986 # ffffffffc02075f0 <default_pmm_manager+0x320>
ffffffffc0202dba:	00004617          	auipc	a2,0x4
ffffffffc0202dbe:	dce60613          	addi	a2,a2,-562 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202dc2:	20400593          	li	a1,516
ffffffffc0202dc6:	00004517          	auipc	a0,0x4
ffffffffc0202dca:	69250513          	addi	a0,a0,1682 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202dce:	eb6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202dd2:	00005697          	auipc	a3,0x5
ffffffffc0202dd6:	a9668693          	addi	a3,a3,-1386 # ffffffffc0207868 <default_pmm_manager+0x598>
ffffffffc0202dda:	00004617          	auipc	a2,0x4
ffffffffc0202dde:	dae60613          	addi	a2,a2,-594 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202de2:	22d00593          	li	a1,557
ffffffffc0202de6:	00004517          	auipc	a0,0x4
ffffffffc0202dea:	67250513          	addi	a0,a0,1650 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202dee:	e96fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202df2:	00005697          	auipc	a3,0x5
ffffffffc0202df6:	88e68693          	addi	a3,a3,-1906 # ffffffffc0207680 <default_pmm_manager+0x3b0>
ffffffffc0202dfa:	00004617          	auipc	a2,0x4
ffffffffc0202dfe:	d8e60613          	addi	a2,a2,-626 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202e02:	20300593          	li	a1,515
ffffffffc0202e06:	00004517          	auipc	a0,0x4
ffffffffc0202e0a:	65250513          	addi	a0,a0,1618 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202e0e:	e76fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e12:	00005697          	auipc	a3,0x5
ffffffffc0202e16:	93668693          	addi	a3,a3,-1738 # ffffffffc0207748 <default_pmm_manager+0x478>
ffffffffc0202e1a:	00004617          	auipc	a2,0x4
ffffffffc0202e1e:	d6e60613          	addi	a2,a2,-658 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202e22:	20200593          	li	a1,514
ffffffffc0202e26:	00004517          	auipc	a0,0x4
ffffffffc0202e2a:	63250513          	addi	a0,a0,1586 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202e2e:	e56fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202e32:	00005697          	auipc	a3,0x5
ffffffffc0202e36:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0207730 <default_pmm_manager+0x460>
ffffffffc0202e3a:	00004617          	auipc	a2,0x4
ffffffffc0202e3e:	d4e60613          	addi	a2,a2,-690 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202e42:	20100593          	li	a1,513
ffffffffc0202e46:	00004517          	auipc	a0,0x4
ffffffffc0202e4a:	61250513          	addi	a0,a0,1554 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202e4e:	e36fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202e52:	00005697          	auipc	a3,0x5
ffffffffc0202e56:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0207700 <default_pmm_manager+0x430>
ffffffffc0202e5a:	00004617          	auipc	a2,0x4
ffffffffc0202e5e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202e62:	20000593          	li	a1,512
ffffffffc0202e66:	00004517          	auipc	a0,0x4
ffffffffc0202e6a:	5f250513          	addi	a0,a0,1522 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202e6e:	e16fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202e72:	00005697          	auipc	a3,0x5
ffffffffc0202e76:	87668693          	addi	a3,a3,-1930 # ffffffffc02076e8 <default_pmm_manager+0x418>
ffffffffc0202e7a:	00004617          	auipc	a2,0x4
ffffffffc0202e7e:	d0e60613          	addi	a2,a2,-754 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202e82:	1fe00593          	li	a1,510
ffffffffc0202e86:	00004517          	auipc	a0,0x4
ffffffffc0202e8a:	5d250513          	addi	a0,a0,1490 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202e8e:	df6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e92:	00005697          	auipc	a3,0x5
ffffffffc0202e96:	83e68693          	addi	a3,a3,-1986 # ffffffffc02076d0 <default_pmm_manager+0x400>
ffffffffc0202e9a:	00004617          	auipc	a2,0x4
ffffffffc0202e9e:	cee60613          	addi	a2,a2,-786 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202ea2:	1fd00593          	li	a1,509
ffffffffc0202ea6:	00004517          	auipc	a0,0x4
ffffffffc0202eaa:	5b250513          	addi	a0,a0,1458 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202eae:	dd6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202eb2:	00005697          	auipc	a3,0x5
ffffffffc0202eb6:	80e68693          	addi	a3,a3,-2034 # ffffffffc02076c0 <default_pmm_manager+0x3f0>
ffffffffc0202eba:	00004617          	auipc	a2,0x4
ffffffffc0202ebe:	cce60613          	addi	a2,a2,-818 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202ec2:	1fc00593          	li	a1,508
ffffffffc0202ec6:	00004517          	auipc	a0,0x4
ffffffffc0202eca:	59250513          	addi	a0,a0,1426 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202ece:	db6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202ed2:	00004697          	auipc	a3,0x4
ffffffffc0202ed6:	7de68693          	addi	a3,a3,2014 # ffffffffc02076b0 <default_pmm_manager+0x3e0>
ffffffffc0202eda:	00004617          	auipc	a2,0x4
ffffffffc0202ede:	cae60613          	addi	a2,a2,-850 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202ee2:	1fb00593          	li	a1,507
ffffffffc0202ee6:	00004517          	auipc	a0,0x4
ffffffffc0202eea:	57250513          	addi	a0,a0,1394 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202eee:	d96fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202ef2:	00004697          	auipc	a3,0x4
ffffffffc0202ef6:	78e68693          	addi	a3,a3,1934 # ffffffffc0207680 <default_pmm_manager+0x3b0>
ffffffffc0202efa:	00004617          	auipc	a2,0x4
ffffffffc0202efe:	c8e60613          	addi	a2,a2,-882 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202f02:	1fa00593          	li	a1,506
ffffffffc0202f06:	00004517          	auipc	a0,0x4
ffffffffc0202f0a:	55250513          	addi	a0,a0,1362 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202f0e:	d76fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202f12:	00004697          	auipc	a3,0x4
ffffffffc0202f16:	73668693          	addi	a3,a3,1846 # ffffffffc0207648 <default_pmm_manager+0x378>
ffffffffc0202f1a:	00004617          	auipc	a2,0x4
ffffffffc0202f1e:	c6e60613          	addi	a2,a2,-914 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202f22:	1f900593          	li	a1,505
ffffffffc0202f26:	00004517          	auipc	a0,0x4
ffffffffc0202f2a:	53250513          	addi	a0,a0,1330 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202f2e:	d56fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202f32:	00004697          	auipc	a3,0x4
ffffffffc0202f36:	6ee68693          	addi	a3,a3,1774 # ffffffffc0207620 <default_pmm_manager+0x350>
ffffffffc0202f3a:	00004617          	auipc	a2,0x4
ffffffffc0202f3e:	c4e60613          	addi	a2,a2,-946 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202f42:	1f600593          	li	a1,502
ffffffffc0202f46:	00004517          	auipc	a0,0x4
ffffffffc0202f4a:	51250513          	addi	a0,a0,1298 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202f4e:	d36fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202f52:	86da                	mv	a3,s6
ffffffffc0202f54:	00004617          	auipc	a2,0x4
ffffffffc0202f58:	3cc60613          	addi	a2,a2,972 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0202f5c:	1f500593          	li	a1,501
ffffffffc0202f60:	00004517          	auipc	a0,0x4
ffffffffc0202f64:	4f850513          	addi	a0,a0,1272 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202f68:	d1cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f6c:	86be                	mv	a3,a5
ffffffffc0202f6e:	00004617          	auipc	a2,0x4
ffffffffc0202f72:	3b260613          	addi	a2,a2,946 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0202f76:	06900593          	li	a1,105
ffffffffc0202f7a:	00004517          	auipc	a0,0x4
ffffffffc0202f7e:	3ce50513          	addi	a0,a0,974 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0202f82:	d02fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f86:	00005697          	auipc	a3,0x5
ffffffffc0202f8a:	80a68693          	addi	a3,a3,-2038 # ffffffffc0207790 <default_pmm_manager+0x4c0>
ffffffffc0202f8e:	00004617          	auipc	a2,0x4
ffffffffc0202f92:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202f96:	20f00593          	li	a1,527
ffffffffc0202f9a:	00004517          	auipc	a0,0x4
ffffffffc0202f9e:	4be50513          	addi	a0,a0,1214 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202fa2:	ce2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fa6:	00004697          	auipc	a3,0x4
ffffffffc0202faa:	7a268693          	addi	a3,a3,1954 # ffffffffc0207748 <default_pmm_manager+0x478>
ffffffffc0202fae:	00004617          	auipc	a2,0x4
ffffffffc0202fb2:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202fb6:	20d00593          	li	a1,525
ffffffffc0202fba:	00004517          	auipc	a0,0x4
ffffffffc0202fbe:	49e50513          	addi	a0,a0,1182 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202fc2:	cc2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202fc6:	00004697          	auipc	a3,0x4
ffffffffc0202fca:	7b268693          	addi	a3,a3,1970 # ffffffffc0207778 <default_pmm_manager+0x4a8>
ffffffffc0202fce:	00004617          	auipc	a2,0x4
ffffffffc0202fd2:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202fd6:	20c00593          	li	a1,524
ffffffffc0202fda:	00004517          	auipc	a0,0x4
ffffffffc0202fde:	47e50513          	addi	a0,a0,1150 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0202fe2:	ca2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202fe6:	00005697          	auipc	a3,0x5
ffffffffc0202fea:	91268693          	addi	a3,a3,-1774 # ffffffffc02078f8 <default_pmm_manager+0x628>
ffffffffc0202fee:	00004617          	auipc	a2,0x4
ffffffffc0202ff2:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0202ff6:	23000593          	li	a1,560
ffffffffc0202ffa:	00004517          	auipc	a0,0x4
ffffffffc0202ffe:	45e50513          	addi	a0,a0,1118 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203002:	c82fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203006:	00005697          	auipc	a3,0x5
ffffffffc020300a:	8b268693          	addi	a3,a3,-1870 # ffffffffc02078b8 <default_pmm_manager+0x5e8>
ffffffffc020300e:	00004617          	auipc	a2,0x4
ffffffffc0203012:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203016:	22f00593          	li	a1,559
ffffffffc020301a:	00004517          	auipc	a0,0x4
ffffffffc020301e:	43e50513          	addi	a0,a0,1086 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203022:	c62fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203026:	00005697          	auipc	a3,0x5
ffffffffc020302a:	87a68693          	addi	a3,a3,-1926 # ffffffffc02078a0 <default_pmm_manager+0x5d0>
ffffffffc020302e:	00004617          	auipc	a2,0x4
ffffffffc0203032:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203036:	22e00593          	li	a1,558
ffffffffc020303a:	00004517          	auipc	a0,0x4
ffffffffc020303e:	41e50513          	addi	a0,a0,1054 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203042:	c42fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203046:	86be                	mv	a3,a5
ffffffffc0203048:	00004617          	auipc	a2,0x4
ffffffffc020304c:	2d860613          	addi	a2,a2,728 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0203050:	1f400593          	li	a1,500
ffffffffc0203054:	00004517          	auipc	a0,0x4
ffffffffc0203058:	40450513          	addi	a0,a0,1028 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc020305c:	c28fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203060:	00004617          	auipc	a2,0x4
ffffffffc0203064:	2f860613          	addi	a2,a2,760 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc0203068:	07f00593          	li	a1,127
ffffffffc020306c:	00004517          	auipc	a0,0x4
ffffffffc0203070:	3ec50513          	addi	a0,a0,1004 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203074:	c10fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203078:	00005697          	auipc	a3,0x5
ffffffffc020307c:	8b068693          	addi	a3,a3,-1872 # ffffffffc0207928 <default_pmm_manager+0x658>
ffffffffc0203080:	00004617          	auipc	a2,0x4
ffffffffc0203084:	b0860613          	addi	a2,a2,-1272 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203088:	23400593          	li	a1,564
ffffffffc020308c:	00004517          	auipc	a0,0x4
ffffffffc0203090:	3cc50513          	addi	a0,a0,972 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203094:	bf0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203098:	00004697          	auipc	a3,0x4
ffffffffc020309c:	72068693          	addi	a3,a3,1824 # ffffffffc02077b8 <default_pmm_manager+0x4e8>
ffffffffc02030a0:	00004617          	auipc	a2,0x4
ffffffffc02030a4:	ae860613          	addi	a2,a2,-1304 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02030a8:	24000593          	li	a1,576
ffffffffc02030ac:	00004517          	auipc	a0,0x4
ffffffffc02030b0:	3ac50513          	addi	a0,a0,940 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02030b4:	bd0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02030b8:	00004697          	auipc	a3,0x4
ffffffffc02030bc:	55068693          	addi	a3,a3,1360 # ffffffffc0207608 <default_pmm_manager+0x338>
ffffffffc02030c0:	00004617          	auipc	a2,0x4
ffffffffc02030c4:	ac860613          	addi	a2,a2,-1336 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02030c8:	1f200593          	li	a1,498
ffffffffc02030cc:	00004517          	auipc	a0,0x4
ffffffffc02030d0:	38c50513          	addi	a0,a0,908 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02030d4:	bb0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02030d8:	00004697          	auipc	a3,0x4
ffffffffc02030dc:	51868693          	addi	a3,a3,1304 # ffffffffc02075f0 <default_pmm_manager+0x320>
ffffffffc02030e0:	00004617          	auipc	a2,0x4
ffffffffc02030e4:	aa860613          	addi	a2,a2,-1368 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02030e8:	1f100593          	li	a1,497
ffffffffc02030ec:	00004517          	auipc	a0,0x4
ffffffffc02030f0:	36c50513          	addi	a0,a0,876 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02030f4:	b90fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02030f8:	00004697          	auipc	a3,0x4
ffffffffc02030fc:	47068693          	addi	a3,a3,1136 # ffffffffc0207568 <default_pmm_manager+0x298>
ffffffffc0203100:	00004617          	auipc	a2,0x4
ffffffffc0203104:	a8860613          	addi	a2,a2,-1400 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203108:	1e900593          	li	a1,489
ffffffffc020310c:	00004517          	auipc	a0,0x4
ffffffffc0203110:	34c50513          	addi	a0,a0,844 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203114:	b70fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203118:	00004697          	auipc	a3,0x4
ffffffffc020311c:	4a868693          	addi	a3,a3,1192 # ffffffffc02075c0 <default_pmm_manager+0x2f0>
ffffffffc0203120:	00004617          	auipc	a2,0x4
ffffffffc0203124:	a6860613          	addi	a2,a2,-1432 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203128:	1f000593          	li	a1,496
ffffffffc020312c:	00004517          	auipc	a0,0x4
ffffffffc0203130:	32c50513          	addi	a0,a0,812 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203134:	b50fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203138:	00004697          	auipc	a3,0x4
ffffffffc020313c:	45868693          	addi	a3,a3,1112 # ffffffffc0207590 <default_pmm_manager+0x2c0>
ffffffffc0203140:	00004617          	auipc	a2,0x4
ffffffffc0203144:	a4860613          	addi	a2,a2,-1464 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203148:	1ed00593          	li	a1,493
ffffffffc020314c:	00004517          	auipc	a0,0x4
ffffffffc0203150:	30c50513          	addi	a0,a0,780 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203154:	b30fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203158:	00004697          	auipc	a3,0x4
ffffffffc020315c:	5f068693          	addi	a3,a3,1520 # ffffffffc0207748 <default_pmm_manager+0x478>
ffffffffc0203160:	00004617          	auipc	a2,0x4
ffffffffc0203164:	a2860613          	addi	a2,a2,-1496 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203168:	20900593          	li	a1,521
ffffffffc020316c:	00004517          	auipc	a0,0x4
ffffffffc0203170:	2ec50513          	addi	a0,a0,748 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203174:	b10fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203178:	00004697          	auipc	a3,0x4
ffffffffc020317c:	49068693          	addi	a3,a3,1168 # ffffffffc0207608 <default_pmm_manager+0x338>
ffffffffc0203180:	00004617          	auipc	a2,0x4
ffffffffc0203184:	a0860613          	addi	a2,a2,-1528 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203188:	20800593          	li	a1,520
ffffffffc020318c:	00004517          	auipc	a0,0x4
ffffffffc0203190:	2cc50513          	addi	a0,a0,716 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203194:	af0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203198:	00004697          	auipc	a3,0x4
ffffffffc020319c:	5c868693          	addi	a3,a3,1480 # ffffffffc0207760 <default_pmm_manager+0x490>
ffffffffc02031a0:	00004617          	auipc	a2,0x4
ffffffffc02031a4:	9e860613          	addi	a2,a2,-1560 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02031a8:	20500593          	li	a1,517
ffffffffc02031ac:	00004517          	auipc	a0,0x4
ffffffffc02031b0:	2ac50513          	addi	a0,a0,684 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02031b4:	ad0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02031b8:	00004697          	auipc	a3,0x4
ffffffffc02031bc:	7a868693          	addi	a3,a3,1960 # ffffffffc0207960 <default_pmm_manager+0x690>
ffffffffc02031c0:	00004617          	auipc	a2,0x4
ffffffffc02031c4:	9c860613          	addi	a2,a2,-1592 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02031c8:	23700593          	li	a1,567
ffffffffc02031cc:	00004517          	auipc	a0,0x4
ffffffffc02031d0:	28c50513          	addi	a0,a0,652 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02031d4:	ab0fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02031d8:	00004697          	auipc	a3,0x4
ffffffffc02031dc:	5e068693          	addi	a3,a3,1504 # ffffffffc02077b8 <default_pmm_manager+0x4e8>
ffffffffc02031e0:	00004617          	auipc	a2,0x4
ffffffffc02031e4:	9a860613          	addi	a2,a2,-1624 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02031e8:	21700593          	li	a1,535
ffffffffc02031ec:	00004517          	auipc	a0,0x4
ffffffffc02031f0:	26c50513          	addi	a0,a0,620 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02031f4:	a90fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02031f8:	00004697          	auipc	a3,0x4
ffffffffc02031fc:	65868693          	addi	a3,a3,1624 # ffffffffc0207850 <default_pmm_manager+0x580>
ffffffffc0203200:	00004617          	auipc	a2,0x4
ffffffffc0203204:	98860613          	addi	a2,a2,-1656 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203208:	22900593          	li	a1,553
ffffffffc020320c:	00004517          	auipc	a0,0x4
ffffffffc0203210:	24c50513          	addi	a0,a0,588 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203214:	a70fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203218:	00004697          	auipc	a3,0x4
ffffffffc020321c:	2f868693          	addi	a3,a3,760 # ffffffffc0207510 <default_pmm_manager+0x240>
ffffffffc0203220:	00004617          	auipc	a2,0x4
ffffffffc0203224:	96860613          	addi	a2,a2,-1688 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203228:	1e700593          	li	a1,487
ffffffffc020322c:	00004517          	auipc	a0,0x4
ffffffffc0203230:	22c50513          	addi	a0,a0,556 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc0203234:	a50fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203238:	00004617          	auipc	a2,0x4
ffffffffc020323c:	12060613          	addi	a2,a2,288 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc0203240:	0c100593          	li	a1,193
ffffffffc0203244:	00004517          	auipc	a0,0x4
ffffffffc0203248:	21450513          	addi	a0,a0,532 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc020324c:	a38fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203250 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203250:	12058073          	sfence.vma	a1
}
ffffffffc0203254:	8082                	ret

ffffffffc0203256 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203256:	7179                	addi	sp,sp,-48
ffffffffc0203258:	e84a                	sd	s2,16(sp)
ffffffffc020325a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020325c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020325e:	f022                	sd	s0,32(sp)
ffffffffc0203260:	ec26                	sd	s1,24(sp)
ffffffffc0203262:	e44e                	sd	s3,8(sp)
ffffffffc0203264:	f406                	sd	ra,40(sp)
ffffffffc0203266:	84ae                	mv	s1,a1
ffffffffc0203268:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020326a:	be9fe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020326e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203270:	cd1d                	beqz	a0,ffffffffc02032ae <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203272:	85aa                	mv	a1,a0
ffffffffc0203274:	86ce                	mv	a3,s3
ffffffffc0203276:	8626                	mv	a2,s1
ffffffffc0203278:	854a                	mv	a0,s2
ffffffffc020327a:	c8eff0ef          	jal	ra,ffffffffc0202708 <page_insert>
ffffffffc020327e:	e121                	bnez	a0,ffffffffc02032be <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0203280:	000a9797          	auipc	a5,0xa9
ffffffffc0203284:	24878793          	addi	a5,a5,584 # ffffffffc02ac4c8 <swap_init_ok>
ffffffffc0203288:	439c                	lw	a5,0(a5)
ffffffffc020328a:	2781                	sext.w	a5,a5
ffffffffc020328c:	c38d                	beqz	a5,ffffffffc02032ae <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc020328e:	000a9797          	auipc	a5,0xa9
ffffffffc0203292:	37a78793          	addi	a5,a5,890 # ffffffffc02ac608 <check_mm_struct>
ffffffffc0203296:	6388                	ld	a0,0(a5)
ffffffffc0203298:	c919                	beqz	a0,ffffffffc02032ae <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020329a:	4681                	li	a3,0
ffffffffc020329c:	8622                	mv	a2,s0
ffffffffc020329e:	85a6                	mv	a1,s1
ffffffffc02032a0:	7da000ef          	jal	ra,ffffffffc0203a7a <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02032a4:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02032a6:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02032a8:	4785                	li	a5,1
ffffffffc02032aa:	02f71063          	bne	a4,a5,ffffffffc02032ca <pgdir_alloc_page+0x74>
}
ffffffffc02032ae:	8522                	mv	a0,s0
ffffffffc02032b0:	70a2                	ld	ra,40(sp)
ffffffffc02032b2:	7402                	ld	s0,32(sp)
ffffffffc02032b4:	64e2                	ld	s1,24(sp)
ffffffffc02032b6:	6942                	ld	s2,16(sp)
ffffffffc02032b8:	69a2                	ld	s3,8(sp)
ffffffffc02032ba:	6145                	addi	sp,sp,48
ffffffffc02032bc:	8082                	ret
            free_page(page);
ffffffffc02032be:	8522                	mv	a0,s0
ffffffffc02032c0:	4585                	li	a1,1
ffffffffc02032c2:	c19fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
            return NULL;
ffffffffc02032c6:	4401                	li	s0,0
ffffffffc02032c8:	b7dd                	j	ffffffffc02032ae <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc02032ca:	00004697          	auipc	a3,0x4
ffffffffc02032ce:	19e68693          	addi	a3,a3,414 # ffffffffc0207468 <default_pmm_manager+0x198>
ffffffffc02032d2:	00004617          	auipc	a2,0x4
ffffffffc02032d6:	8b660613          	addi	a2,a2,-1866 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02032da:	1c800593          	li	a1,456
ffffffffc02032de:	00004517          	auipc	a0,0x4
ffffffffc02032e2:	17a50513          	addi	a0,a0,378 # ffffffffc0207458 <default_pmm_manager+0x188>
ffffffffc02032e6:	99efd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02032ea <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02032ea:	7135                	addi	sp,sp,-160
ffffffffc02032ec:	ed06                	sd	ra,152(sp)
ffffffffc02032ee:	e922                	sd	s0,144(sp)
ffffffffc02032f0:	e526                	sd	s1,136(sp)
ffffffffc02032f2:	e14a                	sd	s2,128(sp)
ffffffffc02032f4:	fcce                	sd	s3,120(sp)
ffffffffc02032f6:	f8d2                	sd	s4,112(sp)
ffffffffc02032f8:	f4d6                	sd	s5,104(sp)
ffffffffc02032fa:	f0da                	sd	s6,96(sp)
ffffffffc02032fc:	ecde                	sd	s7,88(sp)
ffffffffc02032fe:	e8e2                	sd	s8,80(sp)
ffffffffc0203300:	e4e6                	sd	s9,72(sp)
ffffffffc0203302:	e0ea                	sd	s10,64(sp)
ffffffffc0203304:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203306:	79e010ef          	jal	ra,ffffffffc0204aa4 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020330a:	000a9797          	auipc	a5,0xa9
ffffffffc020330e:	2ae78793          	addi	a5,a5,686 # ffffffffc02ac5b8 <max_swap_offset>
ffffffffc0203312:	6394                	ld	a3,0(a5)
ffffffffc0203314:	010007b7          	lui	a5,0x1000
ffffffffc0203318:	17e1                	addi	a5,a5,-8
ffffffffc020331a:	ff968713          	addi	a4,a3,-7
ffffffffc020331e:	4ae7ee63          	bltu	a5,a4,ffffffffc02037da <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203322:	0009e797          	auipc	a5,0x9e
ffffffffc0203326:	d2678793          	addi	a5,a5,-730 # ffffffffc02a1048 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020332a:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020332c:	000a9697          	auipc	a3,0xa9
ffffffffc0203330:	18f6ba23          	sd	a5,404(a3) # ffffffffc02ac4c0 <sm>
     int r = sm->init();
ffffffffc0203334:	9702                	jalr	a4
ffffffffc0203336:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0203338:	c10d                	beqz	a0,ffffffffc020335a <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020333a:	60ea                	ld	ra,152(sp)
ffffffffc020333c:	644a                	ld	s0,144(sp)
ffffffffc020333e:	8556                	mv	a0,s5
ffffffffc0203340:	64aa                	ld	s1,136(sp)
ffffffffc0203342:	690a                	ld	s2,128(sp)
ffffffffc0203344:	79e6                	ld	s3,120(sp)
ffffffffc0203346:	7a46                	ld	s4,112(sp)
ffffffffc0203348:	7aa6                	ld	s5,104(sp)
ffffffffc020334a:	7b06                	ld	s6,96(sp)
ffffffffc020334c:	6be6                	ld	s7,88(sp)
ffffffffc020334e:	6c46                	ld	s8,80(sp)
ffffffffc0203350:	6ca6                	ld	s9,72(sp)
ffffffffc0203352:	6d06                	ld	s10,64(sp)
ffffffffc0203354:	7de2                	ld	s11,56(sp)
ffffffffc0203356:	610d                	addi	sp,sp,160
ffffffffc0203358:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020335a:	000a9797          	auipc	a5,0xa9
ffffffffc020335e:	16678793          	addi	a5,a5,358 # ffffffffc02ac4c0 <sm>
ffffffffc0203362:	639c                	ld	a5,0(a5)
ffffffffc0203364:	00004517          	auipc	a0,0x4
ffffffffc0203368:	70c50513          	addi	a0,a0,1804 # ffffffffc0207a70 <default_pmm_manager+0x7a0>
    return listelm->next;
ffffffffc020336c:	000a9417          	auipc	s0,0xa9
ffffffffc0203370:	18c40413          	addi	s0,s0,396 # ffffffffc02ac4f8 <free_area>
ffffffffc0203374:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203376:	4785                	li	a5,1
ffffffffc0203378:	000a9717          	auipc	a4,0xa9
ffffffffc020337c:	14f72823          	sw	a5,336(a4) # ffffffffc02ac4c8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203380:	e0ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203384:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203386:	36878e63          	beq	a5,s0,ffffffffc0203702 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020338a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020338e:	8305                	srli	a4,a4,0x1
ffffffffc0203390:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203392:	36070c63          	beqz	a4,ffffffffc020370a <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203396:	4481                	li	s1,0
ffffffffc0203398:	4901                	li	s2,0
ffffffffc020339a:	a031                	j	ffffffffc02033a6 <swap_init+0xbc>
ffffffffc020339c:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02033a0:	8b09                	andi	a4,a4,2
ffffffffc02033a2:	36070463          	beqz	a4,ffffffffc020370a <swap_init+0x420>
        count ++, total += p->property;
ffffffffc02033a6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033aa:	679c                	ld	a5,8(a5)
ffffffffc02033ac:	2905                	addiw	s2,s2,1
ffffffffc02033ae:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02033b0:	fe8796e3          	bne	a5,s0,ffffffffc020339c <swap_init+0xb2>
ffffffffc02033b4:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02033b6:	b6bfe0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc02033ba:	69351863          	bne	a0,s3,ffffffffc0203a4a <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02033be:	8626                	mv	a2,s1
ffffffffc02033c0:	85ca                	mv	a1,s2
ffffffffc02033c2:	00004517          	auipc	a0,0x4
ffffffffc02033c6:	6c650513          	addi	a0,a0,1734 # ffffffffc0207a88 <default_pmm_manager+0x7b8>
ffffffffc02033ca:	dc5fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02033ce:	457000ef          	jal	ra,ffffffffc0204024 <mm_create>
ffffffffc02033d2:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02033d4:	60050b63          	beqz	a0,ffffffffc02039ea <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02033d8:	000a9797          	auipc	a5,0xa9
ffffffffc02033dc:	23078793          	addi	a5,a5,560 # ffffffffc02ac608 <check_mm_struct>
ffffffffc02033e0:	639c                	ld	a5,0(a5)
ffffffffc02033e2:	62079463          	bnez	a5,ffffffffc0203a0a <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02033e6:	000a9797          	auipc	a5,0xa9
ffffffffc02033ea:	0ca78793          	addi	a5,a5,202 # ffffffffc02ac4b0 <boot_pgdir>
ffffffffc02033ee:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02033f2:	000a9797          	auipc	a5,0xa9
ffffffffc02033f6:	20a7bb23          	sd	a0,534(a5) # ffffffffc02ac608 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02033fa:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02033fe:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203402:	4e079863          	bnez	a5,ffffffffc02038f2 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203406:	6599                	lui	a1,0x6
ffffffffc0203408:	460d                	li	a2,3
ffffffffc020340a:	6505                	lui	a0,0x1
ffffffffc020340c:	465000ef          	jal	ra,ffffffffc0204070 <vma_create>
ffffffffc0203410:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203412:	50050063          	beqz	a0,ffffffffc0203912 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0203416:	855e                	mv	a0,s7
ffffffffc0203418:	4c5000ef          	jal	ra,ffffffffc02040dc <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020341c:	00004517          	auipc	a0,0x4
ffffffffc0203420:	6dc50513          	addi	a0,a0,1756 # ffffffffc0207af8 <default_pmm_manager+0x828>
ffffffffc0203424:	d6bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203428:	018bb503          	ld	a0,24(s7)
ffffffffc020342c:	4605                	li	a2,1
ffffffffc020342e:	6585                	lui	a1,0x1
ffffffffc0203430:	b31fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203434:	4e050f63          	beqz	a0,ffffffffc0203932 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203438:	00004517          	auipc	a0,0x4
ffffffffc020343c:	71050513          	addi	a0,a0,1808 # ffffffffc0207b48 <default_pmm_manager+0x878>
ffffffffc0203440:	000a9997          	auipc	s3,0xa9
ffffffffc0203444:	0f098993          	addi	s3,s3,240 # ffffffffc02ac530 <check_rp>
ffffffffc0203448:	d47fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020344c:	000a9a17          	auipc	s4,0xa9
ffffffffc0203450:	104a0a13          	addi	s4,s4,260 # ffffffffc02ac550 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203454:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0203456:	4505                	li	a0,1
ffffffffc0203458:	9fbfe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc020345c:	00ac3023          	sd	a0,0(s8) # ffffffffffe00000 <end+0x3fb539e0>
          assert(check_rp[i] != NULL );
ffffffffc0203460:	32050d63          	beqz	a0,ffffffffc020379a <swap_init+0x4b0>
ffffffffc0203464:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203466:	8b89                	andi	a5,a5,2
ffffffffc0203468:	30079963          	bnez	a5,ffffffffc020377a <swap_init+0x490>
ffffffffc020346c:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020346e:	ff4c14e3          	bne	s8,s4,ffffffffc0203456 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203472:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203474:	000a9c17          	auipc	s8,0xa9
ffffffffc0203478:	0bcc0c13          	addi	s8,s8,188 # ffffffffc02ac530 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020347c:	ec3e                	sd	a5,24(sp)
ffffffffc020347e:	641c                	ld	a5,8(s0)
ffffffffc0203480:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203482:	481c                	lw	a5,16(s0)
ffffffffc0203484:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203486:	000a9797          	auipc	a5,0xa9
ffffffffc020348a:	0687bd23          	sd	s0,122(a5) # ffffffffc02ac500 <free_area+0x8>
ffffffffc020348e:	000a9797          	auipc	a5,0xa9
ffffffffc0203492:	0687b523          	sd	s0,106(a5) # ffffffffc02ac4f8 <free_area>
     nr_free = 0;
ffffffffc0203496:	000a9797          	auipc	a5,0xa9
ffffffffc020349a:	0607a923          	sw	zero,114(a5) # ffffffffc02ac508 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020349e:	000c3503          	ld	a0,0(s8)
ffffffffc02034a2:	4585                	li	a1,1
ffffffffc02034a4:	0c21                	addi	s8,s8,8
ffffffffc02034a6:	a35fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034aa:	ff4c1ae3          	bne	s8,s4,ffffffffc020349e <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02034ae:	01042c03          	lw	s8,16(s0)
ffffffffc02034b2:	4791                	li	a5,4
ffffffffc02034b4:	50fc1b63          	bne	s8,a5,ffffffffc02039ca <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02034b8:	00004517          	auipc	a0,0x4
ffffffffc02034bc:	71850513          	addi	a0,a0,1816 # ffffffffc0207bd0 <default_pmm_manager+0x900>
ffffffffc02034c0:	ccffc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034c4:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02034c6:	000a9797          	auipc	a5,0xa9
ffffffffc02034ca:	0007a323          	sw	zero,6(a5) # ffffffffc02ac4cc <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034ce:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02034d0:	000a9797          	auipc	a5,0xa9
ffffffffc02034d4:	ffc78793          	addi	a5,a5,-4 # ffffffffc02ac4cc <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034d8:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
     assert(pgfault_num==1);
ffffffffc02034dc:	4398                	lw	a4,0(a5)
ffffffffc02034de:	4585                	li	a1,1
ffffffffc02034e0:	2701                	sext.w	a4,a4
ffffffffc02034e2:	38b71863          	bne	a4,a1,ffffffffc0203872 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02034e6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02034ea:	4394                	lw	a3,0(a5)
ffffffffc02034ec:	2681                	sext.w	a3,a3
ffffffffc02034ee:	3ae69263          	bne	a3,a4,ffffffffc0203892 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034f2:	6689                	lui	a3,0x2
ffffffffc02034f4:	462d                	li	a2,11
ffffffffc02034f6:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
     assert(pgfault_num==2);
ffffffffc02034fa:	4398                	lw	a4,0(a5)
ffffffffc02034fc:	4589                	li	a1,2
ffffffffc02034fe:	2701                	sext.w	a4,a4
ffffffffc0203500:	2eb71963          	bne	a4,a1,ffffffffc02037f2 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203504:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0203508:	4394                	lw	a3,0(a5)
ffffffffc020350a:	2681                	sext.w	a3,a3
ffffffffc020350c:	30e69363          	bne	a3,a4,ffffffffc0203812 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203510:	668d                	lui	a3,0x3
ffffffffc0203512:	4631                	li	a2,12
ffffffffc0203514:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
     assert(pgfault_num==3);
ffffffffc0203518:	4398                	lw	a4,0(a5)
ffffffffc020351a:	458d                	li	a1,3
ffffffffc020351c:	2701                	sext.w	a4,a4
ffffffffc020351e:	30b71a63          	bne	a4,a1,ffffffffc0203832 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203522:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203526:	4394                	lw	a3,0(a5)
ffffffffc0203528:	2681                	sext.w	a3,a3
ffffffffc020352a:	32e69463          	bne	a3,a4,ffffffffc0203852 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020352e:	6691                	lui	a3,0x4
ffffffffc0203530:	4635                	li	a2,13
ffffffffc0203532:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
     assert(pgfault_num==4);
ffffffffc0203536:	4398                	lw	a4,0(a5)
ffffffffc0203538:	2701                	sext.w	a4,a4
ffffffffc020353a:	37871c63          	bne	a4,s8,ffffffffc02038b2 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020353e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203542:	439c                	lw	a5,0(a5)
ffffffffc0203544:	2781                	sext.w	a5,a5
ffffffffc0203546:	38e79663          	bne	a5,a4,ffffffffc02038d2 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020354a:	481c                	lw	a5,16(s0)
ffffffffc020354c:	40079363          	bnez	a5,ffffffffc0203952 <swap_init+0x668>
ffffffffc0203550:	000a9797          	auipc	a5,0xa9
ffffffffc0203554:	00078793          	mv	a5,a5
ffffffffc0203558:	000a9717          	auipc	a4,0xa9
ffffffffc020355c:	02070713          	addi	a4,a4,32 # ffffffffc02ac578 <swap_out_seq_no>
ffffffffc0203560:	000a9617          	auipc	a2,0xa9
ffffffffc0203564:	01860613          	addi	a2,a2,24 # ffffffffc02ac578 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203568:	56fd                	li	a3,-1
ffffffffc020356a:	c394                	sw	a3,0(a5)
ffffffffc020356c:	c314                	sw	a3,0(a4)
ffffffffc020356e:	0791                	addi	a5,a5,4
ffffffffc0203570:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203572:	fef61ce3          	bne	a2,a5,ffffffffc020356a <swap_init+0x280>
ffffffffc0203576:	000a9697          	auipc	a3,0xa9
ffffffffc020357a:	06268693          	addi	a3,a3,98 # ffffffffc02ac5d8 <check_ptep>
ffffffffc020357e:	000a9817          	auipc	a6,0xa9
ffffffffc0203582:	fb280813          	addi	a6,a6,-78 # ffffffffc02ac530 <check_rp>
ffffffffc0203586:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203588:	000a9c97          	auipc	s9,0xa9
ffffffffc020358c:	f30c8c93          	addi	s9,s9,-208 # ffffffffc02ac4b8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203590:	00005d97          	auipc	s11,0x5
ffffffffc0203594:	718d8d93          	addi	s11,s11,1816 # ffffffffc0208ca8 <nbase>
ffffffffc0203598:	000a9c17          	auipc	s8,0xa9
ffffffffc020359c:	f90c0c13          	addi	s8,s8,-112 # ffffffffc02ac528 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02035a0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035a4:	4601                	li	a2,0
ffffffffc02035a6:	85ea                	mv	a1,s10
ffffffffc02035a8:	855a                	mv	a0,s6
ffffffffc02035aa:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc02035ac:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035ae:	9b3fe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc02035b2:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02035b4:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02035b6:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02035b8:	20050163          	beqz	a0,ffffffffc02037ba <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02035bc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02035be:	0017f613          	andi	a2,a5,1
ffffffffc02035c2:	1a060063          	beqz	a2,ffffffffc0203762 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc02035c6:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02035ca:	078a                	slli	a5,a5,0x2
ffffffffc02035cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02035ce:	14c7fe63          	bleu	a2,a5,ffffffffc020372a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02035d2:	000db703          	ld	a4,0(s11)
ffffffffc02035d6:	000c3603          	ld	a2,0(s8)
ffffffffc02035da:	00083583          	ld	a1,0(a6)
ffffffffc02035de:	8f99                	sub	a5,a5,a4
ffffffffc02035e0:	079a                	slli	a5,a5,0x6
ffffffffc02035e2:	e43a                	sd	a4,8(sp)
ffffffffc02035e4:	97b2                	add	a5,a5,a2
ffffffffc02035e6:	14f59e63          	bne	a1,a5,ffffffffc0203742 <swap_init+0x458>
ffffffffc02035ea:	6785                	lui	a5,0x1
ffffffffc02035ec:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035ee:	6795                	lui	a5,0x5
ffffffffc02035f0:	06a1                	addi	a3,a3,8
ffffffffc02035f2:	0821                	addi	a6,a6,8
ffffffffc02035f4:	fafd16e3          	bne	s10,a5,ffffffffc02035a0 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02035f8:	00004517          	auipc	a0,0x4
ffffffffc02035fc:	68050513          	addi	a0,a0,1664 # ffffffffc0207c78 <default_pmm_manager+0x9a8>
ffffffffc0203600:	b8ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0203604:	000a9797          	auipc	a5,0xa9
ffffffffc0203608:	ebc78793          	addi	a5,a5,-324 # ffffffffc02ac4c0 <sm>
ffffffffc020360c:	639c                	ld	a5,0(a5)
ffffffffc020360e:	7f9c                	ld	a5,56(a5)
ffffffffc0203610:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203612:	40051c63          	bnez	a0,ffffffffc0203a2a <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0203616:	77a2                	ld	a5,40(sp)
ffffffffc0203618:	000a9717          	auipc	a4,0xa9
ffffffffc020361c:	eef72823          	sw	a5,-272(a4) # ffffffffc02ac508 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0203620:	67e2                	ld	a5,24(sp)
ffffffffc0203622:	000a9717          	auipc	a4,0xa9
ffffffffc0203626:	ecf73b23          	sd	a5,-298(a4) # ffffffffc02ac4f8 <free_area>
ffffffffc020362a:	7782                	ld	a5,32(sp)
ffffffffc020362c:	000a9717          	auipc	a4,0xa9
ffffffffc0203630:	ecf73a23          	sd	a5,-300(a4) # ffffffffc02ac500 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203634:	0009b503          	ld	a0,0(s3)
ffffffffc0203638:	4585                	li	a1,1
ffffffffc020363a:	09a1                	addi	s3,s3,8
ffffffffc020363c:	89ffe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203640:	ff499ae3          	bne	s3,s4,ffffffffc0203634 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203644:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc0203648:	855e                	mv	a0,s7
ffffffffc020364a:	361000ef          	jal	ra,ffffffffc02041aa <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020364e:	000a9797          	auipc	a5,0xa9
ffffffffc0203652:	e6278793          	addi	a5,a5,-414 # ffffffffc02ac4b0 <boot_pgdir>
ffffffffc0203656:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0203658:	000a9697          	auipc	a3,0xa9
ffffffffc020365c:	fa06b823          	sd	zero,-80(a3) # ffffffffc02ac608 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0203660:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203664:	6394                	ld	a3,0(a5)
ffffffffc0203666:	068a                	slli	a3,a3,0x2
ffffffffc0203668:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020366a:	0ce6f063          	bleu	a4,a3,ffffffffc020372a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020366e:	67a2                	ld	a5,8(sp)
ffffffffc0203670:	000c3503          	ld	a0,0(s8)
ffffffffc0203674:	8e9d                	sub	a3,a3,a5
ffffffffc0203676:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203678:	8699                	srai	a3,a3,0x6
ffffffffc020367a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020367c:	57fd                	li	a5,-1
ffffffffc020367e:	83b1                	srli	a5,a5,0xc
ffffffffc0203680:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203682:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203684:	2ee7f763          	bleu	a4,a5,ffffffffc0203972 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0203688:	000a9797          	auipc	a5,0xa9
ffffffffc020368c:	e9078793          	addi	a5,a5,-368 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0203690:	639c                	ld	a5,0(a5)
ffffffffc0203692:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203694:	629c                	ld	a5,0(a3)
ffffffffc0203696:	078a                	slli	a5,a5,0x2
ffffffffc0203698:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020369a:	08e7f863          	bleu	a4,a5,ffffffffc020372a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020369e:	69a2                	ld	s3,8(sp)
ffffffffc02036a0:	4585                	li	a1,1
ffffffffc02036a2:	413787b3          	sub	a5,a5,s3
ffffffffc02036a6:	079a                	slli	a5,a5,0x6
ffffffffc02036a8:	953e                	add	a0,a0,a5
ffffffffc02036aa:	831fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02036ae:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02036b2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036b6:	078a                	slli	a5,a5,0x2
ffffffffc02036b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036ba:	06e7f863          	bleu	a4,a5,ffffffffc020372a <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02036be:	000c3503          	ld	a0,0(s8)
ffffffffc02036c2:	413787b3          	sub	a5,a5,s3
ffffffffc02036c6:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02036c8:	4585                	li	a1,1
ffffffffc02036ca:	953e                	add	a0,a0,a5
ffffffffc02036cc:	80ffe0ef          	jal	ra,ffffffffc0201eda <free_pages>
     pgdir[0] = 0;
ffffffffc02036d0:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02036d4:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02036d8:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02036da:	00878963          	beq	a5,s0,ffffffffc02036ec <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02036de:	ff87a703          	lw	a4,-8(a5)
ffffffffc02036e2:	679c                	ld	a5,8(a5)
ffffffffc02036e4:	397d                	addiw	s2,s2,-1
ffffffffc02036e6:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02036e8:	fe879be3          	bne	a5,s0,ffffffffc02036de <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc02036ec:	28091f63          	bnez	s2,ffffffffc020398a <swap_init+0x6a0>
     assert(total==0);
ffffffffc02036f0:	2a049d63          	bnez	s1,ffffffffc02039aa <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc02036f4:	00004517          	auipc	a0,0x4
ffffffffc02036f8:	5d450513          	addi	a0,a0,1492 # ffffffffc0207cc8 <default_pmm_manager+0x9f8>
ffffffffc02036fc:	a93fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203700:	b92d                	j	ffffffffc020333a <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203702:	4481                	li	s1,0
ffffffffc0203704:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203706:	4981                	li	s3,0
ffffffffc0203708:	b17d                	j	ffffffffc02033b6 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020370a:	00004697          	auipc	a3,0x4
ffffffffc020370e:	83668693          	addi	a3,a3,-1994 # ffffffffc0206f40 <commands+0x878>
ffffffffc0203712:	00003617          	auipc	a2,0x3
ffffffffc0203716:	47660613          	addi	a2,a2,1142 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020371a:	0bc00593          	li	a1,188
ffffffffc020371e:	00004517          	auipc	a0,0x4
ffffffffc0203722:	34250513          	addi	a0,a0,834 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203726:	d5ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020372a:	00004617          	auipc	a2,0x4
ffffffffc020372e:	c5660613          	addi	a2,a2,-938 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc0203732:	06200593          	li	a1,98
ffffffffc0203736:	00004517          	auipc	a0,0x4
ffffffffc020373a:	c1250513          	addi	a0,a0,-1006 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc020373e:	d47fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203742:	00004697          	auipc	a3,0x4
ffffffffc0203746:	50e68693          	addi	a3,a3,1294 # ffffffffc0207c50 <default_pmm_manager+0x980>
ffffffffc020374a:	00003617          	auipc	a2,0x3
ffffffffc020374e:	43e60613          	addi	a2,a2,1086 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203752:	0fc00593          	li	a1,252
ffffffffc0203756:	00004517          	auipc	a0,0x4
ffffffffc020375a:	30a50513          	addi	a0,a0,778 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020375e:	d27fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203762:	00004617          	auipc	a2,0x4
ffffffffc0203766:	cae60613          	addi	a2,a2,-850 # ffffffffc0207410 <default_pmm_manager+0x140>
ffffffffc020376a:	07400593          	li	a1,116
ffffffffc020376e:	00004517          	auipc	a0,0x4
ffffffffc0203772:	bda50513          	addi	a0,a0,-1062 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0203776:	d0ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020377a:	00004697          	auipc	a3,0x4
ffffffffc020377e:	40e68693          	addi	a3,a3,1038 # ffffffffc0207b88 <default_pmm_manager+0x8b8>
ffffffffc0203782:	00003617          	auipc	a2,0x3
ffffffffc0203786:	40660613          	addi	a2,a2,1030 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020378a:	0dd00593          	li	a1,221
ffffffffc020378e:	00004517          	auipc	a0,0x4
ffffffffc0203792:	2d250513          	addi	a0,a0,722 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203796:	ceffc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020379a:	00004697          	auipc	a3,0x4
ffffffffc020379e:	3d668693          	addi	a3,a3,982 # ffffffffc0207b70 <default_pmm_manager+0x8a0>
ffffffffc02037a2:	00003617          	auipc	a2,0x3
ffffffffc02037a6:	3e660613          	addi	a2,a2,998 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02037aa:	0dc00593          	li	a1,220
ffffffffc02037ae:	00004517          	auipc	a0,0x4
ffffffffc02037b2:	2b250513          	addi	a0,a0,690 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02037b6:	ccffc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02037ba:	00004697          	auipc	a3,0x4
ffffffffc02037be:	47e68693          	addi	a3,a3,1150 # ffffffffc0207c38 <default_pmm_manager+0x968>
ffffffffc02037c2:	00003617          	auipc	a2,0x3
ffffffffc02037c6:	3c660613          	addi	a2,a2,966 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02037ca:	0fb00593          	li	a1,251
ffffffffc02037ce:	00004517          	auipc	a0,0x4
ffffffffc02037d2:	29250513          	addi	a0,a0,658 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02037d6:	caffc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02037da:	00004617          	auipc	a2,0x4
ffffffffc02037de:	26660613          	addi	a2,a2,614 # ffffffffc0207a40 <default_pmm_manager+0x770>
ffffffffc02037e2:	02800593          	li	a1,40
ffffffffc02037e6:	00004517          	auipc	a0,0x4
ffffffffc02037ea:	27a50513          	addi	a0,a0,634 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02037ee:	c97fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc02037f2:	00004697          	auipc	a3,0x4
ffffffffc02037f6:	41668693          	addi	a3,a3,1046 # ffffffffc0207c08 <default_pmm_manager+0x938>
ffffffffc02037fa:	00003617          	auipc	a2,0x3
ffffffffc02037fe:	38e60613          	addi	a2,a2,910 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203802:	09700593          	li	a1,151
ffffffffc0203806:	00004517          	auipc	a0,0x4
ffffffffc020380a:	25a50513          	addi	a0,a0,602 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020380e:	c77fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203812:	00004697          	auipc	a3,0x4
ffffffffc0203816:	3f668693          	addi	a3,a3,1014 # ffffffffc0207c08 <default_pmm_manager+0x938>
ffffffffc020381a:	00003617          	auipc	a2,0x3
ffffffffc020381e:	36e60613          	addi	a2,a2,878 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203822:	09900593          	li	a1,153
ffffffffc0203826:	00004517          	auipc	a0,0x4
ffffffffc020382a:	23a50513          	addi	a0,a0,570 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020382e:	c57fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203832:	00004697          	auipc	a3,0x4
ffffffffc0203836:	3e668693          	addi	a3,a3,998 # ffffffffc0207c18 <default_pmm_manager+0x948>
ffffffffc020383a:	00003617          	auipc	a2,0x3
ffffffffc020383e:	34e60613          	addi	a2,a2,846 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203842:	09b00593          	li	a1,155
ffffffffc0203846:	00004517          	auipc	a0,0x4
ffffffffc020384a:	21a50513          	addi	a0,a0,538 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020384e:	c37fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203852:	00004697          	auipc	a3,0x4
ffffffffc0203856:	3c668693          	addi	a3,a3,966 # ffffffffc0207c18 <default_pmm_manager+0x948>
ffffffffc020385a:	00003617          	auipc	a2,0x3
ffffffffc020385e:	32e60613          	addi	a2,a2,814 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203862:	09d00593          	li	a1,157
ffffffffc0203866:	00004517          	auipc	a0,0x4
ffffffffc020386a:	1fa50513          	addi	a0,a0,506 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020386e:	c17fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203872:	00004697          	auipc	a3,0x4
ffffffffc0203876:	38668693          	addi	a3,a3,902 # ffffffffc0207bf8 <default_pmm_manager+0x928>
ffffffffc020387a:	00003617          	auipc	a2,0x3
ffffffffc020387e:	30e60613          	addi	a2,a2,782 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203882:	09300593          	li	a1,147
ffffffffc0203886:	00004517          	auipc	a0,0x4
ffffffffc020388a:	1da50513          	addi	a0,a0,474 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020388e:	bf7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203892:	00004697          	auipc	a3,0x4
ffffffffc0203896:	36668693          	addi	a3,a3,870 # ffffffffc0207bf8 <default_pmm_manager+0x928>
ffffffffc020389a:	00003617          	auipc	a2,0x3
ffffffffc020389e:	2ee60613          	addi	a2,a2,750 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02038a2:	09500593          	li	a1,149
ffffffffc02038a6:	00004517          	auipc	a0,0x4
ffffffffc02038aa:	1ba50513          	addi	a0,a0,442 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02038ae:	bd7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc02038b2:	00004697          	auipc	a3,0x4
ffffffffc02038b6:	37668693          	addi	a3,a3,886 # ffffffffc0207c28 <default_pmm_manager+0x958>
ffffffffc02038ba:	00003617          	auipc	a2,0x3
ffffffffc02038be:	2ce60613          	addi	a2,a2,718 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02038c2:	09f00593          	li	a1,159
ffffffffc02038c6:	00004517          	auipc	a0,0x4
ffffffffc02038ca:	19a50513          	addi	a0,a0,410 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02038ce:	bb7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc02038d2:	00004697          	auipc	a3,0x4
ffffffffc02038d6:	35668693          	addi	a3,a3,854 # ffffffffc0207c28 <default_pmm_manager+0x958>
ffffffffc02038da:	00003617          	auipc	a2,0x3
ffffffffc02038de:	2ae60613          	addi	a2,a2,686 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02038e2:	0a100593          	li	a1,161
ffffffffc02038e6:	00004517          	auipc	a0,0x4
ffffffffc02038ea:	17a50513          	addi	a0,a0,378 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02038ee:	b97fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02038f2:	00004697          	auipc	a3,0x4
ffffffffc02038f6:	1e668693          	addi	a3,a3,486 # ffffffffc0207ad8 <default_pmm_manager+0x808>
ffffffffc02038fa:	00003617          	auipc	a2,0x3
ffffffffc02038fe:	28e60613          	addi	a2,a2,654 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203902:	0cc00593          	li	a1,204
ffffffffc0203906:	00004517          	auipc	a0,0x4
ffffffffc020390a:	15a50513          	addi	a0,a0,346 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020390e:	b77fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(vma != NULL);
ffffffffc0203912:	00004697          	auipc	a3,0x4
ffffffffc0203916:	1d668693          	addi	a3,a3,470 # ffffffffc0207ae8 <default_pmm_manager+0x818>
ffffffffc020391a:	00003617          	auipc	a2,0x3
ffffffffc020391e:	26e60613          	addi	a2,a2,622 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203922:	0cf00593          	li	a1,207
ffffffffc0203926:	00004517          	auipc	a0,0x4
ffffffffc020392a:	13a50513          	addi	a0,a0,314 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020392e:	b57fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203932:	00004697          	auipc	a3,0x4
ffffffffc0203936:	1fe68693          	addi	a3,a3,510 # ffffffffc0207b30 <default_pmm_manager+0x860>
ffffffffc020393a:	00003617          	auipc	a2,0x3
ffffffffc020393e:	24e60613          	addi	a2,a2,590 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203942:	0d700593          	li	a1,215
ffffffffc0203946:	00004517          	auipc	a0,0x4
ffffffffc020394a:	11a50513          	addi	a0,a0,282 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020394e:	b37fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert( nr_free == 0);         
ffffffffc0203952:	00003697          	auipc	a3,0x3
ffffffffc0203956:	7be68693          	addi	a3,a3,1982 # ffffffffc0207110 <commands+0xa48>
ffffffffc020395a:	00003617          	auipc	a2,0x3
ffffffffc020395e:	22e60613          	addi	a2,a2,558 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203962:	0f300593          	li	a1,243
ffffffffc0203966:	00004517          	auipc	a0,0x4
ffffffffc020396a:	0fa50513          	addi	a0,a0,250 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc020396e:	b17fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203972:	00004617          	auipc	a2,0x4
ffffffffc0203976:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc020397a:	06900593          	li	a1,105
ffffffffc020397e:	00004517          	auipc	a0,0x4
ffffffffc0203982:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0203986:	afffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(count==0);
ffffffffc020398a:	00004697          	auipc	a3,0x4
ffffffffc020398e:	31e68693          	addi	a3,a3,798 # ffffffffc0207ca8 <default_pmm_manager+0x9d8>
ffffffffc0203992:	00003617          	auipc	a2,0x3
ffffffffc0203996:	1f660613          	addi	a2,a2,502 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020399a:	11d00593          	li	a1,285
ffffffffc020399e:	00004517          	auipc	a0,0x4
ffffffffc02039a2:	0c250513          	addi	a0,a0,194 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02039a6:	adffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total==0);
ffffffffc02039aa:	00004697          	auipc	a3,0x4
ffffffffc02039ae:	30e68693          	addi	a3,a3,782 # ffffffffc0207cb8 <default_pmm_manager+0x9e8>
ffffffffc02039b2:	00003617          	auipc	a2,0x3
ffffffffc02039b6:	1d660613          	addi	a2,a2,470 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02039ba:	11e00593          	li	a1,286
ffffffffc02039be:	00004517          	auipc	a0,0x4
ffffffffc02039c2:	0a250513          	addi	a0,a0,162 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02039c6:	abffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02039ca:	00004697          	auipc	a3,0x4
ffffffffc02039ce:	1de68693          	addi	a3,a3,478 # ffffffffc0207ba8 <default_pmm_manager+0x8d8>
ffffffffc02039d2:	00003617          	auipc	a2,0x3
ffffffffc02039d6:	1b660613          	addi	a2,a2,438 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02039da:	0ea00593          	li	a1,234
ffffffffc02039de:	00004517          	auipc	a0,0x4
ffffffffc02039e2:	08250513          	addi	a0,a0,130 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc02039e6:	a9ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(mm != NULL);
ffffffffc02039ea:	00004697          	auipc	a3,0x4
ffffffffc02039ee:	0c668693          	addi	a3,a3,198 # ffffffffc0207ab0 <default_pmm_manager+0x7e0>
ffffffffc02039f2:	00003617          	auipc	a2,0x3
ffffffffc02039f6:	19660613          	addi	a2,a2,406 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02039fa:	0c400593          	li	a1,196
ffffffffc02039fe:	00004517          	auipc	a0,0x4
ffffffffc0203a02:	06250513          	addi	a0,a0,98 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203a06:	a7ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a0a:	00004697          	auipc	a3,0x4
ffffffffc0203a0e:	0b668693          	addi	a3,a3,182 # ffffffffc0207ac0 <default_pmm_manager+0x7f0>
ffffffffc0203a12:	00003617          	auipc	a2,0x3
ffffffffc0203a16:	17660613          	addi	a2,a2,374 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203a1a:	0c700593          	li	a1,199
ffffffffc0203a1e:	00004517          	auipc	a0,0x4
ffffffffc0203a22:	04250513          	addi	a0,a0,66 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203a26:	a5ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(ret==0);
ffffffffc0203a2a:	00004697          	auipc	a3,0x4
ffffffffc0203a2e:	27668693          	addi	a3,a3,630 # ffffffffc0207ca0 <default_pmm_manager+0x9d0>
ffffffffc0203a32:	00003617          	auipc	a2,0x3
ffffffffc0203a36:	15660613          	addi	a2,a2,342 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203a3a:	10200593          	li	a1,258
ffffffffc0203a3e:	00004517          	auipc	a0,0x4
ffffffffc0203a42:	02250513          	addi	a0,a0,34 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203a46:	a3ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203a4a:	00003697          	auipc	a3,0x3
ffffffffc0203a4e:	51e68693          	addi	a3,a3,1310 # ffffffffc0206f68 <commands+0x8a0>
ffffffffc0203a52:	00003617          	auipc	a2,0x3
ffffffffc0203a56:	13660613          	addi	a2,a2,310 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203a5a:	0bf00593          	li	a1,191
ffffffffc0203a5e:	00004517          	auipc	a0,0x4
ffffffffc0203a62:	00250513          	addi	a0,a0,2 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203a66:	a1ffc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203a6a <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203a6a:	000a9797          	auipc	a5,0xa9
ffffffffc0203a6e:	a5678793          	addi	a5,a5,-1450 # ffffffffc02ac4c0 <sm>
ffffffffc0203a72:	639c                	ld	a5,0(a5)
ffffffffc0203a74:	0107b303          	ld	t1,16(a5)
ffffffffc0203a78:	8302                	jr	t1

ffffffffc0203a7a <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203a7a:	000a9797          	auipc	a5,0xa9
ffffffffc0203a7e:	a4678793          	addi	a5,a5,-1466 # ffffffffc02ac4c0 <sm>
ffffffffc0203a82:	639c                	ld	a5,0(a5)
ffffffffc0203a84:	0207b303          	ld	t1,32(a5)
ffffffffc0203a88:	8302                	jr	t1

ffffffffc0203a8a <swap_out>:
{
ffffffffc0203a8a:	711d                	addi	sp,sp,-96
ffffffffc0203a8c:	ec86                	sd	ra,88(sp)
ffffffffc0203a8e:	e8a2                	sd	s0,80(sp)
ffffffffc0203a90:	e4a6                	sd	s1,72(sp)
ffffffffc0203a92:	e0ca                	sd	s2,64(sp)
ffffffffc0203a94:	fc4e                	sd	s3,56(sp)
ffffffffc0203a96:	f852                	sd	s4,48(sp)
ffffffffc0203a98:	f456                	sd	s5,40(sp)
ffffffffc0203a9a:	f05a                	sd	s6,32(sp)
ffffffffc0203a9c:	ec5e                	sd	s7,24(sp)
ffffffffc0203a9e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203aa0:	cde9                	beqz	a1,ffffffffc0203b7a <swap_out+0xf0>
ffffffffc0203aa2:	8ab2                	mv	s5,a2
ffffffffc0203aa4:	892a                	mv	s2,a0
ffffffffc0203aa6:	8a2e                	mv	s4,a1
ffffffffc0203aa8:	4401                	li	s0,0
ffffffffc0203aaa:	000a9997          	auipc	s3,0xa9
ffffffffc0203aae:	a1698993          	addi	s3,s3,-1514 # ffffffffc02ac4c0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203ab2:	00004b17          	auipc	s6,0x4
ffffffffc0203ab6:	296b0b13          	addi	s6,s6,662 # ffffffffc0207d48 <default_pmm_manager+0xa78>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203aba:	00004b97          	auipc	s7,0x4
ffffffffc0203abe:	276b8b93          	addi	s7,s7,630 # ffffffffc0207d30 <default_pmm_manager+0xa60>
ffffffffc0203ac2:	a825                	j	ffffffffc0203afa <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203ac4:	67a2                	ld	a5,8(sp)
ffffffffc0203ac6:	8626                	mv	a2,s1
ffffffffc0203ac8:	85a2                	mv	a1,s0
ffffffffc0203aca:	7f94                	ld	a3,56(a5)
ffffffffc0203acc:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203ace:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203ad0:	82b1                	srli	a3,a3,0xc
ffffffffc0203ad2:	0685                	addi	a3,a3,1
ffffffffc0203ad4:	ebafc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203ad8:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203ada:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203adc:	7d1c                	ld	a5,56(a0)
ffffffffc0203ade:	83b1                	srli	a5,a5,0xc
ffffffffc0203ae0:	0785                	addi	a5,a5,1
ffffffffc0203ae2:	07a2                	slli	a5,a5,0x8
ffffffffc0203ae4:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203ae8:	bf2fe0ef          	jal	ra,ffffffffc0201eda <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203aec:	01893503          	ld	a0,24(s2)
ffffffffc0203af0:	85a6                	mv	a1,s1
ffffffffc0203af2:	f5eff0ef          	jal	ra,ffffffffc0203250 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203af6:	048a0d63          	beq	s4,s0,ffffffffc0203b50 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203afa:	0009b783          	ld	a5,0(s3)
ffffffffc0203afe:	8656                	mv	a2,s5
ffffffffc0203b00:	002c                	addi	a1,sp,8
ffffffffc0203b02:	7b9c                	ld	a5,48(a5)
ffffffffc0203b04:	854a                	mv	a0,s2
ffffffffc0203b06:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b08:	e12d                	bnez	a0,ffffffffc0203b6a <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b0a:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b0c:	01893503          	ld	a0,24(s2)
ffffffffc0203b10:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203b12:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b14:	85a6                	mv	a1,s1
ffffffffc0203b16:	c4afe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b1a:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b1c:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b1e:	8b85                	andi	a5,a5,1
ffffffffc0203b20:	cfb9                	beqz	a5,ffffffffc0203b7e <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203b22:	65a2                	ld	a1,8(sp)
ffffffffc0203b24:	7d9c                	ld	a5,56(a1)
ffffffffc0203b26:	83b1                	srli	a5,a5,0xc
ffffffffc0203b28:	00178513          	addi	a0,a5,1
ffffffffc0203b2c:	0522                	slli	a0,a0,0x8
ffffffffc0203b2e:	046010ef          	jal	ra,ffffffffc0204b74 <swapfs_write>
ffffffffc0203b32:	d949                	beqz	a0,ffffffffc0203ac4 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b34:	855e                	mv	a0,s7
ffffffffc0203b36:	e58fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203b3a:	0009b783          	ld	a5,0(s3)
ffffffffc0203b3e:	6622                	ld	a2,8(sp)
ffffffffc0203b40:	4681                	li	a3,0
ffffffffc0203b42:	739c                	ld	a5,32(a5)
ffffffffc0203b44:	85a6                	mv	a1,s1
ffffffffc0203b46:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203b48:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203b4a:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203b4c:	fa8a17e3          	bne	s4,s0,ffffffffc0203afa <swap_out+0x70>
}
ffffffffc0203b50:	8522                	mv	a0,s0
ffffffffc0203b52:	60e6                	ld	ra,88(sp)
ffffffffc0203b54:	6446                	ld	s0,80(sp)
ffffffffc0203b56:	64a6                	ld	s1,72(sp)
ffffffffc0203b58:	6906                	ld	s2,64(sp)
ffffffffc0203b5a:	79e2                	ld	s3,56(sp)
ffffffffc0203b5c:	7a42                	ld	s4,48(sp)
ffffffffc0203b5e:	7aa2                	ld	s5,40(sp)
ffffffffc0203b60:	7b02                	ld	s6,32(sp)
ffffffffc0203b62:	6be2                	ld	s7,24(sp)
ffffffffc0203b64:	6c42                	ld	s8,16(sp)
ffffffffc0203b66:	6125                	addi	sp,sp,96
ffffffffc0203b68:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203b6a:	85a2                	mv	a1,s0
ffffffffc0203b6c:	00004517          	auipc	a0,0x4
ffffffffc0203b70:	17c50513          	addi	a0,a0,380 # ffffffffc0207ce8 <default_pmm_manager+0xa18>
ffffffffc0203b74:	e1afc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203b78:	bfe1                	j	ffffffffc0203b50 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203b7a:	4401                	li	s0,0
ffffffffc0203b7c:	bfd1                	j	ffffffffc0203b50 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b7e:	00004697          	auipc	a3,0x4
ffffffffc0203b82:	19a68693          	addi	a3,a3,410 # ffffffffc0207d18 <default_pmm_manager+0xa48>
ffffffffc0203b86:	00003617          	auipc	a2,0x3
ffffffffc0203b8a:	00260613          	addi	a2,a2,2 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203b8e:	06800593          	li	a1,104
ffffffffc0203b92:	00004517          	auipc	a0,0x4
ffffffffc0203b96:	ece50513          	addi	a0,a0,-306 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203b9a:	8ebfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203b9e <swap_in>:
{
ffffffffc0203b9e:	7179                	addi	sp,sp,-48
ffffffffc0203ba0:	e84a                	sd	s2,16(sp)
ffffffffc0203ba2:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203ba4:	4505                	li	a0,1
{
ffffffffc0203ba6:	ec26                	sd	s1,24(sp)
ffffffffc0203ba8:	e44e                	sd	s3,8(sp)
ffffffffc0203baa:	f406                	sd	ra,40(sp)
ffffffffc0203bac:	f022                	sd	s0,32(sp)
ffffffffc0203bae:	84ae                	mv	s1,a1
ffffffffc0203bb0:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203bb2:	aa0fe0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203bb6:	c129                	beqz	a0,ffffffffc0203bf8 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203bb8:	842a                	mv	s0,a0
ffffffffc0203bba:	01893503          	ld	a0,24(s2)
ffffffffc0203bbe:	4601                	li	a2,0
ffffffffc0203bc0:	85a6                	mv	a1,s1
ffffffffc0203bc2:	b9efe0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc0203bc6:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203bc8:	6108                	ld	a0,0(a0)
ffffffffc0203bca:	85a2                	mv	a1,s0
ffffffffc0203bcc:	711000ef          	jal	ra,ffffffffc0204adc <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203bd0:	00093583          	ld	a1,0(s2)
ffffffffc0203bd4:	8626                	mv	a2,s1
ffffffffc0203bd6:	00004517          	auipc	a0,0x4
ffffffffc0203bda:	e2a50513          	addi	a0,a0,-470 # ffffffffc0207a00 <default_pmm_manager+0x730>
ffffffffc0203bde:	81a1                	srli	a1,a1,0x8
ffffffffc0203be0:	daefc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203be4:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203be6:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203bea:	7402                	ld	s0,32(sp)
ffffffffc0203bec:	64e2                	ld	s1,24(sp)
ffffffffc0203bee:	6942                	ld	s2,16(sp)
ffffffffc0203bf0:	69a2                	ld	s3,8(sp)
ffffffffc0203bf2:	4501                	li	a0,0
ffffffffc0203bf4:	6145                	addi	sp,sp,48
ffffffffc0203bf6:	8082                	ret
     assert(result!=NULL);
ffffffffc0203bf8:	00004697          	auipc	a3,0x4
ffffffffc0203bfc:	df868693          	addi	a3,a3,-520 # ffffffffc02079f0 <default_pmm_manager+0x720>
ffffffffc0203c00:	00003617          	auipc	a2,0x3
ffffffffc0203c04:	f8860613          	addi	a2,a2,-120 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203c08:	07e00593          	li	a1,126
ffffffffc0203c0c:	00004517          	auipc	a0,0x4
ffffffffc0203c10:	e5450513          	addi	a0,a0,-428 # ffffffffc0207a60 <default_pmm_manager+0x790>
ffffffffc0203c14:	871fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203c18 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203c18:	000a9797          	auipc	a5,0xa9
ffffffffc0203c1c:	9e078793          	addi	a5,a5,-1568 # ffffffffc02ac5f8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203c20:	f51c                	sd	a5,40(a0)
ffffffffc0203c22:	e79c                	sd	a5,8(a5)
ffffffffc0203c24:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203c26:	4501                	li	a0,0
ffffffffc0203c28:	8082                	ret

ffffffffc0203c2a <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203c2a:	4501                	li	a0,0
ffffffffc0203c2c:	8082                	ret

ffffffffc0203c2e <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203c2e:	4501                	li	a0,0
ffffffffc0203c30:	8082                	ret

ffffffffc0203c32 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203c32:	4501                	li	a0,0
ffffffffc0203c34:	8082                	ret

ffffffffc0203c36 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203c36:	711d                	addi	sp,sp,-96
ffffffffc0203c38:	fc4e                	sd	s3,56(sp)
ffffffffc0203c3a:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c3c:	00004517          	auipc	a0,0x4
ffffffffc0203c40:	14c50513          	addi	a0,a0,332 # ffffffffc0207d88 <default_pmm_manager+0xab8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c44:	698d                	lui	s3,0x3
ffffffffc0203c46:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203c48:	e8a2                	sd	s0,80(sp)
ffffffffc0203c4a:	e4a6                	sd	s1,72(sp)
ffffffffc0203c4c:	ec86                	sd	ra,88(sp)
ffffffffc0203c4e:	e0ca                	sd	s2,64(sp)
ffffffffc0203c50:	f456                	sd	s5,40(sp)
ffffffffc0203c52:	f05a                	sd	s6,32(sp)
ffffffffc0203c54:	ec5e                	sd	s7,24(sp)
ffffffffc0203c56:	e862                	sd	s8,16(sp)
ffffffffc0203c58:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203c5a:	000a9417          	auipc	s0,0xa9
ffffffffc0203c5e:	87240413          	addi	s0,s0,-1934 # ffffffffc02ac4cc <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c62:	d2cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c66:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6578>
    assert(pgfault_num==4);
ffffffffc0203c6a:	4004                	lw	s1,0(s0)
ffffffffc0203c6c:	4791                	li	a5,4
ffffffffc0203c6e:	2481                	sext.w	s1,s1
ffffffffc0203c70:	14f49963          	bne	s1,a5,ffffffffc0203dc2 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c74:	00004517          	auipc	a0,0x4
ffffffffc0203c78:	15450513          	addi	a0,a0,340 # ffffffffc0207dc8 <default_pmm_manager+0xaf8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c7c:	6a85                	lui	s5,0x1
ffffffffc0203c7e:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c80:	d0efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c84:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
    assert(pgfault_num==4);
ffffffffc0203c88:	00042903          	lw	s2,0(s0)
ffffffffc0203c8c:	2901                	sext.w	s2,s2
ffffffffc0203c8e:	2a991a63          	bne	s2,s1,ffffffffc0203f42 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c92:	00004517          	auipc	a0,0x4
ffffffffc0203c96:	15e50513          	addi	a0,a0,350 # ffffffffc0207df0 <default_pmm_manager+0xb20>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c9a:	6b91                	lui	s7,0x4
ffffffffc0203c9c:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c9e:	cf0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ca2:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5578>
    assert(pgfault_num==4);
ffffffffc0203ca6:	4004                	lw	s1,0(s0)
ffffffffc0203ca8:	2481                	sext.w	s1,s1
ffffffffc0203caa:	27249c63          	bne	s1,s2,ffffffffc0203f22 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cae:	00004517          	auipc	a0,0x4
ffffffffc0203cb2:	16a50513          	addi	a0,a0,362 # ffffffffc0207e18 <default_pmm_manager+0xb48>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cb6:	6909                	lui	s2,0x2
ffffffffc0203cb8:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cba:	cd4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cbe:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7578>
    assert(pgfault_num==4);
ffffffffc0203cc2:	401c                	lw	a5,0(s0)
ffffffffc0203cc4:	2781                	sext.w	a5,a5
ffffffffc0203cc6:	22979e63          	bne	a5,s1,ffffffffc0203f02 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203cca:	00004517          	auipc	a0,0x4
ffffffffc0203cce:	17650513          	addi	a0,a0,374 # ffffffffc0207e40 <default_pmm_manager+0xb70>
ffffffffc0203cd2:	cbcfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203cd6:	6795                	lui	a5,0x5
ffffffffc0203cd8:	4739                	li	a4,14
ffffffffc0203cda:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==5);
ffffffffc0203cde:	4004                	lw	s1,0(s0)
ffffffffc0203ce0:	4795                	li	a5,5
ffffffffc0203ce2:	2481                	sext.w	s1,s1
ffffffffc0203ce4:	1ef49f63          	bne	s1,a5,ffffffffc0203ee2 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ce8:	00004517          	auipc	a0,0x4
ffffffffc0203cec:	13050513          	addi	a0,a0,304 # ffffffffc0207e18 <default_pmm_manager+0xb48>
ffffffffc0203cf0:	c9efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cf4:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203cf8:	401c                	lw	a5,0(s0)
ffffffffc0203cfa:	2781                	sext.w	a5,a5
ffffffffc0203cfc:	1c979363          	bne	a5,s1,ffffffffc0203ec2 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d00:	00004517          	auipc	a0,0x4
ffffffffc0203d04:	0c850513          	addi	a0,a0,200 # ffffffffc0207dc8 <default_pmm_manager+0xaf8>
ffffffffc0203d08:	c86fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d0c:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203d10:	401c                	lw	a5,0(s0)
ffffffffc0203d12:	4719                	li	a4,6
ffffffffc0203d14:	2781                	sext.w	a5,a5
ffffffffc0203d16:	18e79663          	bne	a5,a4,ffffffffc0203ea2 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d1a:	00004517          	auipc	a0,0x4
ffffffffc0203d1e:	0fe50513          	addi	a0,a0,254 # ffffffffc0207e18 <default_pmm_manager+0xb48>
ffffffffc0203d22:	c6cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d26:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203d2a:	401c                	lw	a5,0(s0)
ffffffffc0203d2c:	471d                	li	a4,7
ffffffffc0203d2e:	2781                	sext.w	a5,a5
ffffffffc0203d30:	14e79963          	bne	a5,a4,ffffffffc0203e82 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d34:	00004517          	auipc	a0,0x4
ffffffffc0203d38:	05450513          	addi	a0,a0,84 # ffffffffc0207d88 <default_pmm_manager+0xab8>
ffffffffc0203d3c:	c52fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d40:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203d44:	401c                	lw	a5,0(s0)
ffffffffc0203d46:	4721                	li	a4,8
ffffffffc0203d48:	2781                	sext.w	a5,a5
ffffffffc0203d4a:	10e79c63          	bne	a5,a4,ffffffffc0203e62 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d4e:	00004517          	auipc	a0,0x4
ffffffffc0203d52:	0a250513          	addi	a0,a0,162 # ffffffffc0207df0 <default_pmm_manager+0xb20>
ffffffffc0203d56:	c38fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d5a:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d5e:	401c                	lw	a5,0(s0)
ffffffffc0203d60:	4725                	li	a4,9
ffffffffc0203d62:	2781                	sext.w	a5,a5
ffffffffc0203d64:	0ce79f63          	bne	a5,a4,ffffffffc0203e42 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d68:	00004517          	auipc	a0,0x4
ffffffffc0203d6c:	0d850513          	addi	a0,a0,216 # ffffffffc0207e40 <default_pmm_manager+0xb70>
ffffffffc0203d70:	c1efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d74:	6795                	lui	a5,0x5
ffffffffc0203d76:	4739                	li	a4,14
ffffffffc0203d78:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4578>
    assert(pgfault_num==10);
ffffffffc0203d7c:	4004                	lw	s1,0(s0)
ffffffffc0203d7e:	47a9                	li	a5,10
ffffffffc0203d80:	2481                	sext.w	s1,s1
ffffffffc0203d82:	0af49063          	bne	s1,a5,ffffffffc0203e22 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d86:	00004517          	auipc	a0,0x4
ffffffffc0203d8a:	04250513          	addi	a0,a0,66 # ffffffffc0207dc8 <default_pmm_manager+0xaf8>
ffffffffc0203d8e:	c00fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d92:	6785                	lui	a5,0x1
ffffffffc0203d94:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc0203d98:	06979563          	bne	a5,s1,ffffffffc0203e02 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203d9c:	401c                	lw	a5,0(s0)
ffffffffc0203d9e:	472d                	li	a4,11
ffffffffc0203da0:	2781                	sext.w	a5,a5
ffffffffc0203da2:	04e79063          	bne	a5,a4,ffffffffc0203de2 <_fifo_check_swap+0x1ac>
}
ffffffffc0203da6:	60e6                	ld	ra,88(sp)
ffffffffc0203da8:	6446                	ld	s0,80(sp)
ffffffffc0203daa:	64a6                	ld	s1,72(sp)
ffffffffc0203dac:	6906                	ld	s2,64(sp)
ffffffffc0203dae:	79e2                	ld	s3,56(sp)
ffffffffc0203db0:	7a42                	ld	s4,48(sp)
ffffffffc0203db2:	7aa2                	ld	s5,40(sp)
ffffffffc0203db4:	7b02                	ld	s6,32(sp)
ffffffffc0203db6:	6be2                	ld	s7,24(sp)
ffffffffc0203db8:	6c42                	ld	s8,16(sp)
ffffffffc0203dba:	6ca2                	ld	s9,8(sp)
ffffffffc0203dbc:	4501                	li	a0,0
ffffffffc0203dbe:	6125                	addi	sp,sp,96
ffffffffc0203dc0:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203dc2:	00004697          	auipc	a3,0x4
ffffffffc0203dc6:	e6668693          	addi	a3,a3,-410 # ffffffffc0207c28 <default_pmm_manager+0x958>
ffffffffc0203dca:	00003617          	auipc	a2,0x3
ffffffffc0203dce:	dbe60613          	addi	a2,a2,-578 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203dd2:	05100593          	li	a1,81
ffffffffc0203dd6:	00004517          	auipc	a0,0x4
ffffffffc0203dda:	fda50513          	addi	a0,a0,-38 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203dde:	ea6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==11);
ffffffffc0203de2:	00004697          	auipc	a3,0x4
ffffffffc0203de6:	10e68693          	addi	a3,a3,270 # ffffffffc0207ef0 <default_pmm_manager+0xc20>
ffffffffc0203dea:	00003617          	auipc	a2,0x3
ffffffffc0203dee:	d9e60613          	addi	a2,a2,-610 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203df2:	07300593          	li	a1,115
ffffffffc0203df6:	00004517          	auipc	a0,0x4
ffffffffc0203dfa:	fba50513          	addi	a0,a0,-70 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203dfe:	e86fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e02:	00004697          	auipc	a3,0x4
ffffffffc0203e06:	0c668693          	addi	a3,a3,198 # ffffffffc0207ec8 <default_pmm_manager+0xbf8>
ffffffffc0203e0a:	00003617          	auipc	a2,0x3
ffffffffc0203e0e:	d7e60613          	addi	a2,a2,-642 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203e12:	07100593          	li	a1,113
ffffffffc0203e16:	00004517          	auipc	a0,0x4
ffffffffc0203e1a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203e1e:	e66fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==10);
ffffffffc0203e22:	00004697          	auipc	a3,0x4
ffffffffc0203e26:	09668693          	addi	a3,a3,150 # ffffffffc0207eb8 <default_pmm_manager+0xbe8>
ffffffffc0203e2a:	00003617          	auipc	a2,0x3
ffffffffc0203e2e:	d5e60613          	addi	a2,a2,-674 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203e32:	06f00593          	li	a1,111
ffffffffc0203e36:	00004517          	auipc	a0,0x4
ffffffffc0203e3a:	f7a50513          	addi	a0,a0,-134 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203e3e:	e46fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==9);
ffffffffc0203e42:	00004697          	auipc	a3,0x4
ffffffffc0203e46:	06668693          	addi	a3,a3,102 # ffffffffc0207ea8 <default_pmm_manager+0xbd8>
ffffffffc0203e4a:	00003617          	auipc	a2,0x3
ffffffffc0203e4e:	d3e60613          	addi	a2,a2,-706 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203e52:	06c00593          	li	a1,108
ffffffffc0203e56:	00004517          	auipc	a0,0x4
ffffffffc0203e5a:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203e5e:	e26fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==8);
ffffffffc0203e62:	00004697          	auipc	a3,0x4
ffffffffc0203e66:	03668693          	addi	a3,a3,54 # ffffffffc0207e98 <default_pmm_manager+0xbc8>
ffffffffc0203e6a:	00003617          	auipc	a2,0x3
ffffffffc0203e6e:	d1e60613          	addi	a2,a2,-738 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203e72:	06900593          	li	a1,105
ffffffffc0203e76:	00004517          	auipc	a0,0x4
ffffffffc0203e7a:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203e7e:	e06fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==7);
ffffffffc0203e82:	00004697          	auipc	a3,0x4
ffffffffc0203e86:	00668693          	addi	a3,a3,6 # ffffffffc0207e88 <default_pmm_manager+0xbb8>
ffffffffc0203e8a:	00003617          	auipc	a2,0x3
ffffffffc0203e8e:	cfe60613          	addi	a2,a2,-770 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203e92:	06600593          	li	a1,102
ffffffffc0203e96:	00004517          	auipc	a0,0x4
ffffffffc0203e9a:	f1a50513          	addi	a0,a0,-230 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203e9e:	de6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==6);
ffffffffc0203ea2:	00004697          	auipc	a3,0x4
ffffffffc0203ea6:	fd668693          	addi	a3,a3,-42 # ffffffffc0207e78 <default_pmm_manager+0xba8>
ffffffffc0203eaa:	00003617          	auipc	a2,0x3
ffffffffc0203eae:	cde60613          	addi	a2,a2,-802 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203eb2:	06300593          	li	a1,99
ffffffffc0203eb6:	00004517          	auipc	a0,0x4
ffffffffc0203eba:	efa50513          	addi	a0,a0,-262 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203ebe:	dc6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ec2:	00004697          	auipc	a3,0x4
ffffffffc0203ec6:	fa668693          	addi	a3,a3,-90 # ffffffffc0207e68 <default_pmm_manager+0xb98>
ffffffffc0203eca:	00003617          	auipc	a2,0x3
ffffffffc0203ece:	cbe60613          	addi	a2,a2,-834 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203ed2:	06000593          	li	a1,96
ffffffffc0203ed6:	00004517          	auipc	a0,0x4
ffffffffc0203eda:	eda50513          	addi	a0,a0,-294 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203ede:	da6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ee2:	00004697          	auipc	a3,0x4
ffffffffc0203ee6:	f8668693          	addi	a3,a3,-122 # ffffffffc0207e68 <default_pmm_manager+0xb98>
ffffffffc0203eea:	00003617          	auipc	a2,0x3
ffffffffc0203eee:	c9e60613          	addi	a2,a2,-866 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203ef2:	05d00593          	li	a1,93
ffffffffc0203ef6:	00004517          	auipc	a0,0x4
ffffffffc0203efa:	eba50513          	addi	a0,a0,-326 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203efe:	d86fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f02:	00004697          	auipc	a3,0x4
ffffffffc0203f06:	d2668693          	addi	a3,a3,-730 # ffffffffc0207c28 <default_pmm_manager+0x958>
ffffffffc0203f0a:	00003617          	auipc	a2,0x3
ffffffffc0203f0e:	c7e60613          	addi	a2,a2,-898 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203f12:	05a00593          	li	a1,90
ffffffffc0203f16:	00004517          	auipc	a0,0x4
ffffffffc0203f1a:	e9a50513          	addi	a0,a0,-358 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203f1e:	d66fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f22:	00004697          	auipc	a3,0x4
ffffffffc0203f26:	d0668693          	addi	a3,a3,-762 # ffffffffc0207c28 <default_pmm_manager+0x958>
ffffffffc0203f2a:	00003617          	auipc	a2,0x3
ffffffffc0203f2e:	c5e60613          	addi	a2,a2,-930 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203f32:	05700593          	li	a1,87
ffffffffc0203f36:	00004517          	auipc	a0,0x4
ffffffffc0203f3a:	e7a50513          	addi	a0,a0,-390 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203f3e:	d46fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f42:	00004697          	auipc	a3,0x4
ffffffffc0203f46:	ce668693          	addi	a3,a3,-794 # ffffffffc0207c28 <default_pmm_manager+0x958>
ffffffffc0203f4a:	00003617          	auipc	a2,0x3
ffffffffc0203f4e:	c3e60613          	addi	a2,a2,-962 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203f52:	05400593          	li	a1,84
ffffffffc0203f56:	00004517          	auipc	a0,0x4
ffffffffc0203f5a:	e5a50513          	addi	a0,a0,-422 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203f5e:	d26fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203f62 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f62:	751c                	ld	a5,40(a0)
{
ffffffffc0203f64:	1141                	addi	sp,sp,-16
ffffffffc0203f66:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f68:	cf91                	beqz	a5,ffffffffc0203f84 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f6a:	ee0d                	bnez	a2,ffffffffc0203fa4 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f6c:	679c                	ld	a5,8(a5)
}
ffffffffc0203f6e:	60a2                	ld	ra,8(sp)
ffffffffc0203f70:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f72:	6394                	ld	a3,0(a5)
ffffffffc0203f74:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f76:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f7a:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f7c:	e314                	sd	a3,0(a4)
ffffffffc0203f7e:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f80:	0141                	addi	sp,sp,16
ffffffffc0203f82:	8082                	ret
         assert(head != NULL);
ffffffffc0203f84:	00004697          	auipc	a3,0x4
ffffffffc0203f88:	f9c68693          	addi	a3,a3,-100 # ffffffffc0207f20 <default_pmm_manager+0xc50>
ffffffffc0203f8c:	00003617          	auipc	a2,0x3
ffffffffc0203f90:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203f94:	04100593          	li	a1,65
ffffffffc0203f98:	00004517          	auipc	a0,0x4
ffffffffc0203f9c:	e1850513          	addi	a0,a0,-488 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203fa0:	ce4fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(in_tick==0);
ffffffffc0203fa4:	00004697          	auipc	a3,0x4
ffffffffc0203fa8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0207f30 <default_pmm_manager+0xc60>
ffffffffc0203fac:	00003617          	auipc	a2,0x3
ffffffffc0203fb0:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203fb4:	04200593          	li	a1,66
ffffffffc0203fb8:	00004517          	auipc	a0,0x4
ffffffffc0203fbc:	df850513          	addi	a0,a0,-520 # ffffffffc0207db0 <default_pmm_manager+0xae0>
ffffffffc0203fc0:	cc4fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203fc4 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203fc4:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203fc8:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203fca:	cb09                	beqz	a4,ffffffffc0203fdc <_fifo_map_swappable+0x18>
ffffffffc0203fcc:	cb81                	beqz	a5,ffffffffc0203fdc <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203fce:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203fd0:	e398                	sd	a4,0(a5)
}
ffffffffc0203fd2:	4501                	li	a0,0
ffffffffc0203fd4:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203fd6:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203fd8:	f614                	sd	a3,40(a2)
ffffffffc0203fda:	8082                	ret
{
ffffffffc0203fdc:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203fde:	00004697          	auipc	a3,0x4
ffffffffc0203fe2:	f2268693          	addi	a3,a3,-222 # ffffffffc0207f00 <default_pmm_manager+0xc30>
ffffffffc0203fe6:	00003617          	auipc	a2,0x3
ffffffffc0203fea:	ba260613          	addi	a2,a2,-1118 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0203fee:	03200593          	li	a1,50
ffffffffc0203ff2:	00004517          	auipc	a0,0x4
ffffffffc0203ff6:	dbe50513          	addi	a0,a0,-578 # ffffffffc0207db0 <default_pmm_manager+0xae0>
{
ffffffffc0203ffa:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203ffc:	c88fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204000 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204000:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204002:	00004697          	auipc	a3,0x4
ffffffffc0204006:	f5668693          	addi	a3,a3,-170 # ffffffffc0207f58 <default_pmm_manager+0xc88>
ffffffffc020400a:	00003617          	auipc	a2,0x3
ffffffffc020400e:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204012:	06d00593          	li	a1,109
ffffffffc0204016:	00004517          	auipc	a0,0x4
ffffffffc020401a:	f6250513          	addi	a0,a0,-158 # ffffffffc0207f78 <default_pmm_manager+0xca8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020401e:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204020:	c64fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204024 <mm_create>:
mm_create(void) {
ffffffffc0204024:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204026:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020402a:	e022                	sd	s0,0(sp)
ffffffffc020402c:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020402e:	c29fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204032:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204034:	c515                	beqz	a0,ffffffffc0204060 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204036:	000a8797          	auipc	a5,0xa8
ffffffffc020403a:	49278793          	addi	a5,a5,1170 # ffffffffc02ac4c8 <swap_init_ok>
ffffffffc020403e:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0204040:	e408                	sd	a0,8(s0)
ffffffffc0204042:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204044:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204048:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020404c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204050:	2781                	sext.w	a5,a5
ffffffffc0204052:	ef81                	bnez	a5,ffffffffc020406a <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0204054:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0204058:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020405c:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204060:	8522                	mv	a0,s0
ffffffffc0204062:	60a2                	ld	ra,8(sp)
ffffffffc0204064:	6402                	ld	s0,0(sp)
ffffffffc0204066:	0141                	addi	sp,sp,16
ffffffffc0204068:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020406a:	a01ff0ef          	jal	ra,ffffffffc0203a6a <swap_init_mm>
ffffffffc020406e:	b7ed                	j	ffffffffc0204058 <mm_create+0x34>

ffffffffc0204070 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204070:	1101                	addi	sp,sp,-32
ffffffffc0204072:	e04a                	sd	s2,0(sp)
ffffffffc0204074:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204076:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020407a:	e822                	sd	s0,16(sp)
ffffffffc020407c:	e426                	sd	s1,8(sp)
ffffffffc020407e:	ec06                	sd	ra,24(sp)
ffffffffc0204080:	84ae                	mv	s1,a1
ffffffffc0204082:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204084:	bd3fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
    if (vma != NULL) {
ffffffffc0204088:	c509                	beqz	a0,ffffffffc0204092 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020408a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020408e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204090:	cd00                	sw	s0,24(a0)
}
ffffffffc0204092:	60e2                	ld	ra,24(sp)
ffffffffc0204094:	6442                	ld	s0,16(sp)
ffffffffc0204096:	64a2                	ld	s1,8(sp)
ffffffffc0204098:	6902                	ld	s2,0(sp)
ffffffffc020409a:	6105                	addi	sp,sp,32
ffffffffc020409c:	8082                	ret

ffffffffc020409e <find_vma>:
    if (mm != NULL) {
ffffffffc020409e:	c51d                	beqz	a0,ffffffffc02040cc <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02040a0:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02040a2:	c781                	beqz	a5,ffffffffc02040aa <find_vma+0xc>
ffffffffc02040a4:	6798                	ld	a4,8(a5)
ffffffffc02040a6:	02e5f663          	bleu	a4,a1,ffffffffc02040d2 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02040aa:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02040ac:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02040ae:	00f50f63          	beq	a0,a5,ffffffffc02040cc <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02040b2:	fe87b703          	ld	a4,-24(a5)
ffffffffc02040b6:	fee5ebe3          	bltu	a1,a4,ffffffffc02040ac <find_vma+0xe>
ffffffffc02040ba:	ff07b703          	ld	a4,-16(a5)
ffffffffc02040be:	fee5f7e3          	bleu	a4,a1,ffffffffc02040ac <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02040c2:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02040c4:	c781                	beqz	a5,ffffffffc02040cc <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02040c6:	e91c                	sd	a5,16(a0)
}
ffffffffc02040c8:	853e                	mv	a0,a5
ffffffffc02040ca:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02040cc:	4781                	li	a5,0
}
ffffffffc02040ce:	853e                	mv	a0,a5
ffffffffc02040d0:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02040d2:	6b98                	ld	a4,16(a5)
ffffffffc02040d4:	fce5fbe3          	bleu	a4,a1,ffffffffc02040aa <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02040d8:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02040da:	b7fd                	j	ffffffffc02040c8 <find_vma+0x2a>

ffffffffc02040dc <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02040dc:	6590                	ld	a2,8(a1)
ffffffffc02040de:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8568>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02040e2:	1141                	addi	sp,sp,-16
ffffffffc02040e4:	e406                	sd	ra,8(sp)
ffffffffc02040e6:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02040e8:	01066863          	bltu	a2,a6,ffffffffc02040f8 <insert_vma_struct+0x1c>
ffffffffc02040ec:	a8b9                	j	ffffffffc020414a <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02040ee:	fe87b683          	ld	a3,-24(a5)
ffffffffc02040f2:	04d66763          	bltu	a2,a3,ffffffffc0204140 <insert_vma_struct+0x64>
ffffffffc02040f6:	873e                	mv	a4,a5
ffffffffc02040f8:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02040fa:	fef51ae3          	bne	a0,a5,ffffffffc02040ee <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02040fe:	02a70463          	beq	a4,a0,ffffffffc0204126 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204102:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204106:	fe873883          	ld	a7,-24(a4)
ffffffffc020410a:	08d8f063          	bleu	a3,a7,ffffffffc020418a <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020410e:	04d66e63          	bltu	a2,a3,ffffffffc020416a <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0204112:	00f50a63          	beq	a0,a5,ffffffffc0204126 <insert_vma_struct+0x4a>
ffffffffc0204116:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020411a:	0506e863          	bltu	a3,a6,ffffffffc020416a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020411e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204122:	02c6f263          	bleu	a2,a3,ffffffffc0204146 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0204126:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0204128:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020412a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020412e:	e390                	sd	a2,0(a5)
ffffffffc0204130:	e710                	sd	a2,8(a4)
}
ffffffffc0204132:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204134:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0204136:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0204138:	2685                	addiw	a3,a3,1
ffffffffc020413a:	d114                	sw	a3,32(a0)
}
ffffffffc020413c:	0141                	addi	sp,sp,16
ffffffffc020413e:	8082                	ret
    if (le_prev != list) {
ffffffffc0204140:	fca711e3          	bne	a4,a0,ffffffffc0204102 <insert_vma_struct+0x26>
ffffffffc0204144:	bfd9                	j	ffffffffc020411a <insert_vma_struct+0x3e>
ffffffffc0204146:	ebbff0ef          	jal	ra,ffffffffc0204000 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020414a:	00004697          	auipc	a3,0x4
ffffffffc020414e:	f6668693          	addi	a3,a3,-154 # ffffffffc02080b0 <default_pmm_manager+0xde0>
ffffffffc0204152:	00003617          	auipc	a2,0x3
ffffffffc0204156:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020415a:	07400593          	li	a1,116
ffffffffc020415e:	00004517          	auipc	a0,0x4
ffffffffc0204162:	e1a50513          	addi	a0,a0,-486 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204166:	b1efc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020416a:	00004697          	auipc	a3,0x4
ffffffffc020416e:	f8668693          	addi	a3,a3,-122 # ffffffffc02080f0 <default_pmm_manager+0xe20>
ffffffffc0204172:	00003617          	auipc	a2,0x3
ffffffffc0204176:	a1660613          	addi	a2,a2,-1514 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020417a:	06c00593          	li	a1,108
ffffffffc020417e:	00004517          	auipc	a0,0x4
ffffffffc0204182:	dfa50513          	addi	a0,a0,-518 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204186:	afefc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020418a:	00004697          	auipc	a3,0x4
ffffffffc020418e:	f4668693          	addi	a3,a3,-186 # ffffffffc02080d0 <default_pmm_manager+0xe00>
ffffffffc0204192:	00003617          	auipc	a2,0x3
ffffffffc0204196:	9f660613          	addi	a2,a2,-1546 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020419a:	06b00593          	li	a1,107
ffffffffc020419e:	00004517          	auipc	a0,0x4
ffffffffc02041a2:	dda50513          	addi	a0,a0,-550 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02041a6:	adefc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02041aa <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02041aa:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02041ac:	1141                	addi	sp,sp,-16
ffffffffc02041ae:	e406                	sd	ra,8(sp)
ffffffffc02041b0:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02041b2:	e78d                	bnez	a5,ffffffffc02041dc <mm_destroy+0x32>
ffffffffc02041b4:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02041b6:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02041b8:	00a40c63          	beq	s0,a0,ffffffffc02041d0 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02041bc:	6118                	ld	a4,0(a0)
ffffffffc02041be:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02041c0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02041c2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02041c4:	e398                	sd	a4,0(a5)
ffffffffc02041c6:	b4dfd0ef          	jal	ra,ffffffffc0201d12 <kfree>
    return listelm->next;
ffffffffc02041ca:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02041cc:	fea418e3          	bne	s0,a0,ffffffffc02041bc <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02041d0:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02041d2:	6402                	ld	s0,0(sp)
ffffffffc02041d4:	60a2                	ld	ra,8(sp)
ffffffffc02041d6:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02041d8:	b3bfd06f          	j	ffffffffc0201d12 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02041dc:	00004697          	auipc	a3,0x4
ffffffffc02041e0:	f3468693          	addi	a3,a3,-204 # ffffffffc0208110 <default_pmm_manager+0xe40>
ffffffffc02041e4:	00003617          	auipc	a2,0x3
ffffffffc02041e8:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02041ec:	09400593          	li	a1,148
ffffffffc02041f0:	00004517          	auipc	a0,0x4
ffffffffc02041f4:	d8850513          	addi	a0,a0,-632 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02041f8:	a8cfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02041fc <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041fc:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02041fe:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204200:	17fd                	addi	a5,a5,-1
ffffffffc0204202:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc0204204:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204206:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc020420a:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020420c:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc020420e:	fc06                	sd	ra,56(sp)
ffffffffc0204210:	f04a                	sd	s2,32(sp)
ffffffffc0204212:	ec4e                	sd	s3,24(sp)
ffffffffc0204214:	e852                	sd	s4,16(sp)
ffffffffc0204216:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204218:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc020421c:	002007b7          	lui	a5,0x200
ffffffffc0204220:	01047433          	and	s0,s0,a6
ffffffffc0204224:	06f4e363          	bltu	s1,a5,ffffffffc020428a <mm_map+0x8e>
ffffffffc0204228:	0684f163          	bleu	s0,s1,ffffffffc020428a <mm_map+0x8e>
ffffffffc020422c:	4785                	li	a5,1
ffffffffc020422e:	07fe                	slli	a5,a5,0x1f
ffffffffc0204230:	0487ed63          	bltu	a5,s0,ffffffffc020428a <mm_map+0x8e>
ffffffffc0204234:	89aa                	mv	s3,a0
ffffffffc0204236:	8a3a                	mv	s4,a4
ffffffffc0204238:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020423a:	c931                	beqz	a0,ffffffffc020428e <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc020423c:	85a6                	mv	a1,s1
ffffffffc020423e:	e61ff0ef          	jal	ra,ffffffffc020409e <find_vma>
ffffffffc0204242:	c501                	beqz	a0,ffffffffc020424a <mm_map+0x4e>
ffffffffc0204244:	651c                	ld	a5,8(a0)
ffffffffc0204246:	0487e263          	bltu	a5,s0,ffffffffc020428a <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020424a:	03000513          	li	a0,48
ffffffffc020424e:	a09fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204252:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204254:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204256:	02090163          	beqz	s2,ffffffffc0204278 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020425a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020425c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204260:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204264:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204268:	85ca                	mv	a1,s2
ffffffffc020426a:	e73ff0ef          	jal	ra,ffffffffc02040dc <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020426e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204270:	000a0463          	beqz	s4,ffffffffc0204278 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204274:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204278:	70e2                	ld	ra,56(sp)
ffffffffc020427a:	7442                	ld	s0,48(sp)
ffffffffc020427c:	74a2                	ld	s1,40(sp)
ffffffffc020427e:	7902                	ld	s2,32(sp)
ffffffffc0204280:	69e2                	ld	s3,24(sp)
ffffffffc0204282:	6a42                	ld	s4,16(sp)
ffffffffc0204284:	6aa2                	ld	s5,8(sp)
ffffffffc0204286:	6121                	addi	sp,sp,64
ffffffffc0204288:	8082                	ret
        return -E_INVAL;
ffffffffc020428a:	5575                	li	a0,-3
ffffffffc020428c:	b7f5                	j	ffffffffc0204278 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc020428e:	00004697          	auipc	a3,0x4
ffffffffc0204292:	82268693          	addi	a3,a3,-2014 # ffffffffc0207ab0 <default_pmm_manager+0x7e0>
ffffffffc0204296:	00003617          	auipc	a2,0x3
ffffffffc020429a:	8f260613          	addi	a2,a2,-1806 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020429e:	0a700593          	li	a1,167
ffffffffc02042a2:	00004517          	auipc	a0,0x4
ffffffffc02042a6:	cd650513          	addi	a0,a0,-810 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02042aa:	9dafc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02042ae <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02042ae:	7139                	addi	sp,sp,-64
ffffffffc02042b0:	fc06                	sd	ra,56(sp)
ffffffffc02042b2:	f822                	sd	s0,48(sp)
ffffffffc02042b4:	f426                	sd	s1,40(sp)
ffffffffc02042b6:	f04a                	sd	s2,32(sp)
ffffffffc02042b8:	ec4e                	sd	s3,24(sp)
ffffffffc02042ba:	e852                	sd	s4,16(sp)
ffffffffc02042bc:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02042be:	c535                	beqz	a0,ffffffffc020432a <dup_mmap+0x7c>
ffffffffc02042c0:	892a                	mv	s2,a0
ffffffffc02042c2:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02042c4:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02042c6:	e59d                	bnez	a1,ffffffffc02042f4 <dup_mmap+0x46>
ffffffffc02042c8:	a08d                	j	ffffffffc020432a <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02042ca:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02042cc:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5588>
        insert_vma_struct(to, nvma);
ffffffffc02042d0:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc02042d2:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc02042d6:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02042da:	e03ff0ef          	jal	ra,ffffffffc02040dc <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02042de:	ff043683          	ld	a3,-16(s0)
ffffffffc02042e2:	fe843603          	ld	a2,-24(s0)
ffffffffc02042e6:	6c8c                	ld	a1,24(s1)
ffffffffc02042e8:	01893503          	ld	a0,24(s2)
ffffffffc02042ec:	4701                	li	a4,0
ffffffffc02042ee:	a14fe0ef          	jal	ra,ffffffffc0202502 <copy_range>
ffffffffc02042f2:	e105                	bnez	a0,ffffffffc0204312 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02042f4:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02042f6:	02848863          	beq	s1,s0,ffffffffc0204326 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042fa:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02042fe:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204302:	ff043a03          	ld	s4,-16(s0)
ffffffffc0204306:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020430a:	94dfd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc020430e:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0204310:	fd4d                	bnez	a0,ffffffffc02042ca <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0204312:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0204314:	70e2                	ld	ra,56(sp)
ffffffffc0204316:	7442                	ld	s0,48(sp)
ffffffffc0204318:	74a2                	ld	s1,40(sp)
ffffffffc020431a:	7902                	ld	s2,32(sp)
ffffffffc020431c:	69e2                	ld	s3,24(sp)
ffffffffc020431e:	6a42                	ld	s4,16(sp)
ffffffffc0204320:	6aa2                	ld	s5,8(sp)
ffffffffc0204322:	6121                	addi	sp,sp,64
ffffffffc0204324:	8082                	ret
    return 0;
ffffffffc0204326:	4501                	li	a0,0
ffffffffc0204328:	b7f5                	j	ffffffffc0204314 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc020432a:	00004697          	auipc	a3,0x4
ffffffffc020432e:	d4668693          	addi	a3,a3,-698 # ffffffffc0208070 <default_pmm_manager+0xda0>
ffffffffc0204332:	00003617          	auipc	a2,0x3
ffffffffc0204336:	85660613          	addi	a2,a2,-1962 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020433a:	0c000593          	li	a1,192
ffffffffc020433e:	00004517          	auipc	a0,0x4
ffffffffc0204342:	c3a50513          	addi	a0,a0,-966 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204346:	93efc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020434a <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020434a:	1101                	addi	sp,sp,-32
ffffffffc020434c:	ec06                	sd	ra,24(sp)
ffffffffc020434e:	e822                	sd	s0,16(sp)
ffffffffc0204350:	e426                	sd	s1,8(sp)
ffffffffc0204352:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204354:	c531                	beqz	a0,ffffffffc02043a0 <exit_mmap+0x56>
ffffffffc0204356:	591c                	lw	a5,48(a0)
ffffffffc0204358:	84aa                	mv	s1,a0
ffffffffc020435a:	e3b9                	bnez	a5,ffffffffc02043a0 <exit_mmap+0x56>
    return listelm->next;
ffffffffc020435c:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020435e:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204362:	02850663          	beq	a0,s0,ffffffffc020438e <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204366:	ff043603          	ld	a2,-16(s0)
ffffffffc020436a:	fe843583          	ld	a1,-24(s0)
ffffffffc020436e:	854a                	mv	a0,s2
ffffffffc0204370:	e25fd0ef          	jal	ra,ffffffffc0202194 <unmap_range>
ffffffffc0204374:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204376:	fe8498e3          	bne	s1,s0,ffffffffc0204366 <exit_mmap+0x1c>
ffffffffc020437a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020437c:	00848c63          	beq	s1,s0,ffffffffc0204394 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204380:	ff043603          	ld	a2,-16(s0)
ffffffffc0204384:	fe843583          	ld	a1,-24(s0)
ffffffffc0204388:	854a                	mv	a0,s2
ffffffffc020438a:	f23fd0ef          	jal	ra,ffffffffc02022ac <exit_range>
ffffffffc020438e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204390:	fe8498e3          	bne	s1,s0,ffffffffc0204380 <exit_mmap+0x36>
    }
}
ffffffffc0204394:	60e2                	ld	ra,24(sp)
ffffffffc0204396:	6442                	ld	s0,16(sp)
ffffffffc0204398:	64a2                	ld	s1,8(sp)
ffffffffc020439a:	6902                	ld	s2,0(sp)
ffffffffc020439c:	6105                	addi	sp,sp,32
ffffffffc020439e:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043a0:	00004697          	auipc	a3,0x4
ffffffffc02043a4:	cf068693          	addi	a3,a3,-784 # ffffffffc0208090 <default_pmm_manager+0xdc0>
ffffffffc02043a8:	00002617          	auipc	a2,0x2
ffffffffc02043ac:	7e060613          	addi	a2,a2,2016 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02043b0:	0d600593          	li	a1,214
ffffffffc02043b4:	00004517          	auipc	a0,0x4
ffffffffc02043b8:	bc450513          	addi	a0,a0,-1084 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02043bc:	8c8fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02043c0 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02043c0:	7139                	addi	sp,sp,-64
ffffffffc02043c2:	f822                	sd	s0,48(sp)
ffffffffc02043c4:	f426                	sd	s1,40(sp)
ffffffffc02043c6:	fc06                	sd	ra,56(sp)
ffffffffc02043c8:	f04a                	sd	s2,32(sp)
ffffffffc02043ca:	ec4e                	sd	s3,24(sp)
ffffffffc02043cc:	e852                	sd	s4,16(sp)
ffffffffc02043ce:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02043d0:	c55ff0ef          	jal	ra,ffffffffc0204024 <mm_create>
    assert(mm != NULL);
ffffffffc02043d4:	842a                	mv	s0,a0
ffffffffc02043d6:	03200493          	li	s1,50
ffffffffc02043da:	e919                	bnez	a0,ffffffffc02043f0 <vmm_init+0x30>
ffffffffc02043dc:	a989                	j	ffffffffc020482e <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc02043de:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02043e0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02043e2:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02043e6:	14ed                	addi	s1,s1,-5
ffffffffc02043e8:	8522                	mv	a0,s0
ffffffffc02043ea:	cf3ff0ef          	jal	ra,ffffffffc02040dc <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02043ee:	c88d                	beqz	s1,ffffffffc0204420 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043f0:	03000513          	li	a0,48
ffffffffc02043f4:	863fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc02043f8:	85aa                	mv	a1,a0
ffffffffc02043fa:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02043fe:	f165                	bnez	a0,ffffffffc02043de <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204400:	00003697          	auipc	a3,0x3
ffffffffc0204404:	6e868693          	addi	a3,a3,1768 # ffffffffc0207ae8 <default_pmm_manager+0x818>
ffffffffc0204408:	00002617          	auipc	a2,0x2
ffffffffc020440c:	78060613          	addi	a2,a2,1920 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204410:	11300593          	li	a1,275
ffffffffc0204414:	00004517          	auipc	a0,0x4
ffffffffc0204418:	b6450513          	addi	a0,a0,-1180 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc020441c:	868fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0204420:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204424:	1f900913          	li	s2,505
ffffffffc0204428:	a819                	j	ffffffffc020443e <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020442a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020442c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020442e:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204432:	0495                	addi	s1,s1,5
ffffffffc0204434:	8522                	mv	a0,s0
ffffffffc0204436:	ca7ff0ef          	jal	ra,ffffffffc02040dc <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020443a:	03248a63          	beq	s1,s2,ffffffffc020446e <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020443e:	03000513          	li	a0,48
ffffffffc0204442:	815fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204446:	85aa                	mv	a1,a0
ffffffffc0204448:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020444c:	fd79                	bnez	a0,ffffffffc020442a <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020444e:	00003697          	auipc	a3,0x3
ffffffffc0204452:	69a68693          	addi	a3,a3,1690 # ffffffffc0207ae8 <default_pmm_manager+0x818>
ffffffffc0204456:	00002617          	auipc	a2,0x2
ffffffffc020445a:	73260613          	addi	a2,a2,1842 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020445e:	11900593          	li	a1,281
ffffffffc0204462:	00004517          	auipc	a0,0x4
ffffffffc0204466:	b1650513          	addi	a0,a0,-1258 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc020446a:	81afc0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc020446e:	6418                	ld	a4,8(s0)
ffffffffc0204470:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204472:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204476:	2ee40063          	beq	s0,a4,ffffffffc0204756 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020447a:	fe873603          	ld	a2,-24(a4)
ffffffffc020447e:	ffe78693          	addi	a3,a5,-2
ffffffffc0204482:	24d61a63          	bne	a2,a3,ffffffffc02046d6 <vmm_init+0x316>
ffffffffc0204486:	ff073683          	ld	a3,-16(a4)
ffffffffc020448a:	24f69663          	bne	a3,a5,ffffffffc02046d6 <vmm_init+0x316>
ffffffffc020448e:	0795                	addi	a5,a5,5
ffffffffc0204490:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204492:	feb792e3          	bne	a5,a1,ffffffffc0204476 <vmm_init+0xb6>
ffffffffc0204496:	491d                	li	s2,7
ffffffffc0204498:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020449a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020449e:	85a6                	mv	a1,s1
ffffffffc02044a0:	8522                	mv	a0,s0
ffffffffc02044a2:	bfdff0ef          	jal	ra,ffffffffc020409e <find_vma>
ffffffffc02044a6:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02044a8:	30050763          	beqz	a0,ffffffffc02047b6 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02044ac:	00148593          	addi	a1,s1,1
ffffffffc02044b0:	8522                	mv	a0,s0
ffffffffc02044b2:	bedff0ef          	jal	ra,ffffffffc020409e <find_vma>
ffffffffc02044b6:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02044b8:	2c050f63          	beqz	a0,ffffffffc0204796 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02044bc:	85ca                	mv	a1,s2
ffffffffc02044be:	8522                	mv	a0,s0
ffffffffc02044c0:	bdfff0ef          	jal	ra,ffffffffc020409e <find_vma>
        assert(vma3 == NULL);
ffffffffc02044c4:	2a051963          	bnez	a0,ffffffffc0204776 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02044c8:	00348593          	addi	a1,s1,3
ffffffffc02044cc:	8522                	mv	a0,s0
ffffffffc02044ce:	bd1ff0ef          	jal	ra,ffffffffc020409e <find_vma>
        assert(vma4 == NULL);
ffffffffc02044d2:	32051263          	bnez	a0,ffffffffc02047f6 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02044d6:	00448593          	addi	a1,s1,4
ffffffffc02044da:	8522                	mv	a0,s0
ffffffffc02044dc:	bc3ff0ef          	jal	ra,ffffffffc020409e <find_vma>
        assert(vma5 == NULL);
ffffffffc02044e0:	2e051b63          	bnez	a0,ffffffffc02047d6 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02044e4:	008a3783          	ld	a5,8(s4)
ffffffffc02044e8:	20979763          	bne	a5,s1,ffffffffc02046f6 <vmm_init+0x336>
ffffffffc02044ec:	010a3783          	ld	a5,16(s4)
ffffffffc02044f0:	21279363          	bne	a5,s2,ffffffffc02046f6 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02044f4:	0089b783          	ld	a5,8(s3)
ffffffffc02044f8:	20979f63          	bne	a5,s1,ffffffffc0204716 <vmm_init+0x356>
ffffffffc02044fc:	0109b783          	ld	a5,16(s3)
ffffffffc0204500:	21279b63          	bne	a5,s2,ffffffffc0204716 <vmm_init+0x356>
ffffffffc0204504:	0495                	addi	s1,s1,5
ffffffffc0204506:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204508:	f9549be3          	bne	s1,s5,ffffffffc020449e <vmm_init+0xde>
ffffffffc020450c:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020450e:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204510:	85a6                	mv	a1,s1
ffffffffc0204512:	8522                	mv	a0,s0
ffffffffc0204514:	b8bff0ef          	jal	ra,ffffffffc020409e <find_vma>
ffffffffc0204518:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020451c:	c90d                	beqz	a0,ffffffffc020454e <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020451e:	6914                	ld	a3,16(a0)
ffffffffc0204520:	6510                	ld	a2,8(a0)
ffffffffc0204522:	00004517          	auipc	a0,0x4
ffffffffc0204526:	d0650513          	addi	a0,a0,-762 # ffffffffc0208228 <default_pmm_manager+0xf58>
ffffffffc020452a:	c65fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020452e:	00004697          	auipc	a3,0x4
ffffffffc0204532:	d2268693          	addi	a3,a3,-734 # ffffffffc0208250 <default_pmm_manager+0xf80>
ffffffffc0204536:	00002617          	auipc	a2,0x2
ffffffffc020453a:	65260613          	addi	a2,a2,1618 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020453e:	13b00593          	li	a1,315
ffffffffc0204542:	00004517          	auipc	a0,0x4
ffffffffc0204546:	a3650513          	addi	a0,a0,-1482 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc020454a:	f3bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc020454e:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0204550:	fd2490e3          	bne	s1,s2,ffffffffc0204510 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204554:	8522                	mv	a0,s0
ffffffffc0204556:	c55ff0ef          	jal	ra,ffffffffc02041aa <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020455a:	00004517          	auipc	a0,0x4
ffffffffc020455e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0208268 <default_pmm_manager+0xf98>
ffffffffc0204562:	c2dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204566:	9bbfd0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc020456a:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020456c:	ab9ff0ef          	jal	ra,ffffffffc0204024 <mm_create>
ffffffffc0204570:	000a8797          	auipc	a5,0xa8
ffffffffc0204574:	08a7bc23          	sd	a0,152(a5) # ffffffffc02ac608 <check_mm_struct>
ffffffffc0204578:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020457a:	36050663          	beqz	a0,ffffffffc02048e6 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020457e:	000a8797          	auipc	a5,0xa8
ffffffffc0204582:	f3278793          	addi	a5,a5,-206 # ffffffffc02ac4b0 <boot_pgdir>
ffffffffc0204586:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020458a:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020458e:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204592:	2c079e63          	bnez	a5,ffffffffc020486e <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204596:	03000513          	li	a0,48
ffffffffc020459a:	ebcfd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc020459e:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc02045a0:	18050b63          	beqz	a0,ffffffffc0204736 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc02045a4:	002007b7          	lui	a5,0x200
ffffffffc02045a8:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc02045aa:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02045ac:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02045ae:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc02045b0:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc02045b2:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc02045b6:	b27ff0ef          	jal	ra,ffffffffc02040dc <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02045ba:	10000593          	li	a1,256
ffffffffc02045be:	8526                	mv	a0,s1
ffffffffc02045c0:	adfff0ef          	jal	ra,ffffffffc020409e <find_vma>
ffffffffc02045c4:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02045c8:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02045cc:	2ca41163          	bne	s0,a0,ffffffffc020488e <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc02045d0:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
        sum += i;
ffffffffc02045d4:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02045d6:	fee79de3          	bne	a5,a4,ffffffffc02045d0 <vmm_init+0x210>
        sum += i;
ffffffffc02045da:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02045dc:	10000793          	li	a5,256
        sum += i;
ffffffffc02045e0:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8222>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02045e4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02045e8:	0007c683          	lbu	a3,0(a5)
ffffffffc02045ec:	0785                	addi	a5,a5,1
ffffffffc02045ee:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02045f0:	fec79ce3          	bne	a5,a2,ffffffffc02045e8 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02045f4:	2c071963          	bnez	a4,ffffffffc02048c6 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc02045f8:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02045fc:	000a8a97          	auipc	s5,0xa8
ffffffffc0204600:	ebca8a93          	addi	s5,s5,-324 # ffffffffc02ac4b8 <npage>
ffffffffc0204604:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204608:	078a                	slli	a5,a5,0x2
ffffffffc020460a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020460c:	20e7f563          	bleu	a4,a5,ffffffffc0204816 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204610:	00004697          	auipc	a3,0x4
ffffffffc0204614:	69868693          	addi	a3,a3,1688 # ffffffffc0208ca8 <nbase>
ffffffffc0204618:	0006ba03          	ld	s4,0(a3)
ffffffffc020461c:	414786b3          	sub	a3,a5,s4
ffffffffc0204620:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204622:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204624:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0204626:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0204628:	83b1                	srli	a5,a5,0xc
ffffffffc020462a:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020462c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020462e:	28e7f063          	bleu	a4,a5,ffffffffc02048ae <vmm_init+0x4ee>
ffffffffc0204632:	000a8797          	auipc	a5,0xa8
ffffffffc0204636:	ee678793          	addi	a5,a5,-282 # ffffffffc02ac518 <va_pa_offset>
ffffffffc020463a:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020463c:	4581                	li	a1,0
ffffffffc020463e:	854a                	mv	a0,s2
ffffffffc0204640:	9436                	add	s0,s0,a3
ffffffffc0204642:	852fe0ef          	jal	ra,ffffffffc0202694 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204646:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0204648:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020464c:	078a                	slli	a5,a5,0x2
ffffffffc020464e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204650:	1ce7f363          	bleu	a4,a5,ffffffffc0204816 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204654:	000a8417          	auipc	s0,0xa8
ffffffffc0204658:	ed440413          	addi	s0,s0,-300 # ffffffffc02ac528 <pages>
ffffffffc020465c:	6008                	ld	a0,0(s0)
ffffffffc020465e:	414787b3          	sub	a5,a5,s4
ffffffffc0204662:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204664:	953e                	add	a0,a0,a5
ffffffffc0204666:	4585                	li	a1,1
ffffffffc0204668:	873fd0ef          	jal	ra,ffffffffc0201eda <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020466c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204670:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204674:	078a                	slli	a5,a5,0x2
ffffffffc0204676:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204678:	18e7ff63          	bleu	a4,a5,ffffffffc0204816 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020467c:	6008                	ld	a0,0(s0)
ffffffffc020467e:	414787b3          	sub	a5,a5,s4
ffffffffc0204682:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204684:	4585                	li	a1,1
ffffffffc0204686:	953e                	add	a0,a0,a5
ffffffffc0204688:	853fd0ef          	jal	ra,ffffffffc0201eda <free_pages>
    pgdir[0] = 0;
ffffffffc020468c:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204690:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204694:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0204698:	8526                	mv	a0,s1
ffffffffc020469a:	b11ff0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020469e:	000a8797          	auipc	a5,0xa8
ffffffffc02046a2:	f607b523          	sd	zero,-150(a5) # ffffffffc02ac608 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02046a6:	87bfd0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
ffffffffc02046aa:	1aa99263          	bne	s3,a0,ffffffffc020484e <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02046ae:	00004517          	auipc	a0,0x4
ffffffffc02046b2:	c4a50513          	addi	a0,a0,-950 # ffffffffc02082f8 <default_pmm_manager+0x1028>
ffffffffc02046b6:	ad9fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc02046ba:	7442                	ld	s0,48(sp)
ffffffffc02046bc:	70e2                	ld	ra,56(sp)
ffffffffc02046be:	74a2                	ld	s1,40(sp)
ffffffffc02046c0:	7902                	ld	s2,32(sp)
ffffffffc02046c2:	69e2                	ld	s3,24(sp)
ffffffffc02046c4:	6a42                	ld	s4,16(sp)
ffffffffc02046c6:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02046c8:	00004517          	auipc	a0,0x4
ffffffffc02046cc:	c5050513          	addi	a0,a0,-944 # ffffffffc0208318 <default_pmm_manager+0x1048>
}
ffffffffc02046d0:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02046d2:	abdfb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02046d6:	00004697          	auipc	a3,0x4
ffffffffc02046da:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0208140 <default_pmm_manager+0xe70>
ffffffffc02046de:	00002617          	auipc	a2,0x2
ffffffffc02046e2:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02046e6:	12200593          	li	a1,290
ffffffffc02046ea:	00004517          	auipc	a0,0x4
ffffffffc02046ee:	88e50513          	addi	a0,a0,-1906 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02046f2:	d93fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02046f6:	00004697          	auipc	a3,0x4
ffffffffc02046fa:	ad268693          	addi	a3,a3,-1326 # ffffffffc02081c8 <default_pmm_manager+0xef8>
ffffffffc02046fe:	00002617          	auipc	a2,0x2
ffffffffc0204702:	48a60613          	addi	a2,a2,1162 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204706:	13200593          	li	a1,306
ffffffffc020470a:	00004517          	auipc	a0,0x4
ffffffffc020470e:	86e50513          	addi	a0,a0,-1938 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204712:	d73fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204716:	00004697          	auipc	a3,0x4
ffffffffc020471a:	ae268693          	addi	a3,a3,-1310 # ffffffffc02081f8 <default_pmm_manager+0xf28>
ffffffffc020471e:	00002617          	auipc	a2,0x2
ffffffffc0204722:	46a60613          	addi	a2,a2,1130 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204726:	13300593          	li	a1,307
ffffffffc020472a:	00004517          	auipc	a0,0x4
ffffffffc020472e:	84e50513          	addi	a0,a0,-1970 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204732:	d53fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(vma != NULL);
ffffffffc0204736:	00003697          	auipc	a3,0x3
ffffffffc020473a:	3b268693          	addi	a3,a3,946 # ffffffffc0207ae8 <default_pmm_manager+0x818>
ffffffffc020473e:	00002617          	auipc	a2,0x2
ffffffffc0204742:	44a60613          	addi	a2,a2,1098 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204746:	15200593          	li	a1,338
ffffffffc020474a:	00004517          	auipc	a0,0x4
ffffffffc020474e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204752:	d33fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204756:	00004697          	auipc	a3,0x4
ffffffffc020475a:	9d268693          	addi	a3,a3,-1582 # ffffffffc0208128 <default_pmm_manager+0xe58>
ffffffffc020475e:	00002617          	auipc	a2,0x2
ffffffffc0204762:	42a60613          	addi	a2,a2,1066 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204766:	12000593          	li	a1,288
ffffffffc020476a:	00004517          	auipc	a0,0x4
ffffffffc020476e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204772:	d13fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma3 == NULL);
ffffffffc0204776:	00004697          	auipc	a3,0x4
ffffffffc020477a:	a2268693          	addi	a3,a3,-1502 # ffffffffc0208198 <default_pmm_manager+0xec8>
ffffffffc020477e:	00002617          	auipc	a2,0x2
ffffffffc0204782:	40a60613          	addi	a2,a2,1034 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204786:	12c00593          	li	a1,300
ffffffffc020478a:	00003517          	auipc	a0,0x3
ffffffffc020478e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204792:	cf3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2 != NULL);
ffffffffc0204796:	00004697          	auipc	a3,0x4
ffffffffc020479a:	9f268693          	addi	a3,a3,-1550 # ffffffffc0208188 <default_pmm_manager+0xeb8>
ffffffffc020479e:	00002617          	auipc	a2,0x2
ffffffffc02047a2:	3ea60613          	addi	a2,a2,1002 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02047a6:	12a00593          	li	a1,298
ffffffffc02047aa:	00003517          	auipc	a0,0x3
ffffffffc02047ae:	7ce50513          	addi	a0,a0,1998 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02047b2:	cd3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1 != NULL);
ffffffffc02047b6:	00004697          	auipc	a3,0x4
ffffffffc02047ba:	9c268693          	addi	a3,a3,-1598 # ffffffffc0208178 <default_pmm_manager+0xea8>
ffffffffc02047be:	00002617          	auipc	a2,0x2
ffffffffc02047c2:	3ca60613          	addi	a2,a2,970 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02047c6:	12800593          	li	a1,296
ffffffffc02047ca:	00003517          	auipc	a0,0x3
ffffffffc02047ce:	7ae50513          	addi	a0,a0,1966 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02047d2:	cb3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma5 == NULL);
ffffffffc02047d6:	00004697          	auipc	a3,0x4
ffffffffc02047da:	9e268693          	addi	a3,a3,-1566 # ffffffffc02081b8 <default_pmm_manager+0xee8>
ffffffffc02047de:	00002617          	auipc	a2,0x2
ffffffffc02047e2:	3aa60613          	addi	a2,a2,938 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02047e6:	13000593          	li	a1,304
ffffffffc02047ea:	00003517          	auipc	a0,0x3
ffffffffc02047ee:	78e50513          	addi	a0,a0,1934 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02047f2:	c93fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma4 == NULL);
ffffffffc02047f6:	00004697          	auipc	a3,0x4
ffffffffc02047fa:	9b268693          	addi	a3,a3,-1614 # ffffffffc02081a8 <default_pmm_manager+0xed8>
ffffffffc02047fe:	00002617          	auipc	a2,0x2
ffffffffc0204802:	38a60613          	addi	a2,a2,906 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0204806:	12e00593          	li	a1,302
ffffffffc020480a:	00003517          	auipc	a0,0x3
ffffffffc020480e:	76e50513          	addi	a0,a0,1902 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204812:	c73fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204816:	00003617          	auipc	a2,0x3
ffffffffc020481a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc020481e:	06200593          	li	a1,98
ffffffffc0204822:	00003517          	auipc	a0,0x3
ffffffffc0204826:	b2650513          	addi	a0,a0,-1242 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc020482a:	c5bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(mm != NULL);
ffffffffc020482e:	00003697          	auipc	a3,0x3
ffffffffc0204832:	28268693          	addi	a3,a3,642 # ffffffffc0207ab0 <default_pmm_manager+0x7e0>
ffffffffc0204836:	00002617          	auipc	a2,0x2
ffffffffc020483a:	35260613          	addi	a2,a2,850 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020483e:	10c00593          	li	a1,268
ffffffffc0204842:	00003517          	auipc	a0,0x3
ffffffffc0204846:	73650513          	addi	a0,a0,1846 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc020484a:	c3bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020484e:	00004697          	auipc	a3,0x4
ffffffffc0204852:	a8268693          	addi	a3,a3,-1406 # ffffffffc02082d0 <default_pmm_manager+0x1000>
ffffffffc0204856:	00002617          	auipc	a2,0x2
ffffffffc020485a:	33260613          	addi	a2,a2,818 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020485e:	17000593          	li	a1,368
ffffffffc0204862:	00003517          	auipc	a0,0x3
ffffffffc0204866:	71650513          	addi	a0,a0,1814 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc020486a:	c1bfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir[0] == 0);
ffffffffc020486e:	00003697          	auipc	a3,0x3
ffffffffc0204872:	26a68693          	addi	a3,a3,618 # ffffffffc0207ad8 <default_pmm_manager+0x808>
ffffffffc0204876:	00002617          	auipc	a2,0x2
ffffffffc020487a:	31260613          	addi	a2,a2,786 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020487e:	14f00593          	li	a1,335
ffffffffc0204882:	00003517          	auipc	a0,0x3
ffffffffc0204886:	6f650513          	addi	a0,a0,1782 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc020488a:	bfbfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020488e:	00004697          	auipc	a3,0x4
ffffffffc0204892:	a1268693          	addi	a3,a3,-1518 # ffffffffc02082a0 <default_pmm_manager+0xfd0>
ffffffffc0204896:	00002617          	auipc	a2,0x2
ffffffffc020489a:	2f260613          	addi	a2,a2,754 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc020489e:	15700593          	li	a1,343
ffffffffc02048a2:	00003517          	auipc	a0,0x3
ffffffffc02048a6:	6d650513          	addi	a0,a0,1750 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02048aa:	bdbfb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02048ae:	00003617          	auipc	a2,0x3
ffffffffc02048b2:	a7260613          	addi	a2,a2,-1422 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc02048b6:	06900593          	li	a1,105
ffffffffc02048ba:	00003517          	auipc	a0,0x3
ffffffffc02048be:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc02048c2:	bc3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(sum == 0);
ffffffffc02048c6:	00004697          	auipc	a3,0x4
ffffffffc02048ca:	9fa68693          	addi	a3,a3,-1542 # ffffffffc02082c0 <default_pmm_manager+0xff0>
ffffffffc02048ce:	00002617          	auipc	a2,0x2
ffffffffc02048d2:	2ba60613          	addi	a2,a2,698 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02048d6:	16300593          	li	a1,355
ffffffffc02048da:	00003517          	auipc	a0,0x3
ffffffffc02048de:	69e50513          	addi	a0,a0,1694 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc02048e2:	ba3fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02048e6:	00004697          	auipc	a3,0x4
ffffffffc02048ea:	9a268693          	addi	a3,a3,-1630 # ffffffffc0208288 <default_pmm_manager+0xfb8>
ffffffffc02048ee:	00002617          	auipc	a2,0x2
ffffffffc02048f2:	29a60613          	addi	a2,a2,666 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02048f6:	14b00593          	li	a1,331
ffffffffc02048fa:	00003517          	auipc	a0,0x3
ffffffffc02048fe:	67e50513          	addi	a0,a0,1662 # ffffffffc0207f78 <default_pmm_manager+0xca8>
ffffffffc0204902:	b83fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204906 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204906:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204908:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020490a:	f022                	sd	s0,32(sp)
ffffffffc020490c:	ec26                	sd	s1,24(sp)
ffffffffc020490e:	f406                	sd	ra,40(sp)
ffffffffc0204910:	e84a                	sd	s2,16(sp)
ffffffffc0204912:	8432                	mv	s0,a2
ffffffffc0204914:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204916:	f88ff0ef          	jal	ra,ffffffffc020409e <find_vma>

    pgfault_num++;
ffffffffc020491a:	000a8797          	auipc	a5,0xa8
ffffffffc020491e:	bb278793          	addi	a5,a5,-1102 # ffffffffc02ac4cc <pgfault_num>
ffffffffc0204922:	439c                	lw	a5,0(a5)
ffffffffc0204924:	2785                	addiw	a5,a5,1
ffffffffc0204926:	000a8717          	auipc	a4,0xa8
ffffffffc020492a:	baf72323          	sw	a5,-1114(a4) # ffffffffc02ac4cc <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020492e:	c941                	beqz	a0,ffffffffc02049be <do_pgfault+0xb8>
ffffffffc0204930:	651c                	ld	a5,8(a0)
ffffffffc0204932:	08f46663          	bltu	s0,a5,ffffffffc02049be <do_pgfault+0xb8>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204936:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204938:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020493a:	8b89                	andi	a5,a5,2
ffffffffc020493c:	e3a5                	bnez	a5,ffffffffc020499c <do_pgfault+0x96>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020493e:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204940:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204942:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204944:	85a2                	mv	a1,s0
ffffffffc0204946:	4605                	li	a2,1
ffffffffc0204948:	e18fd0ef          	jal	ra,ffffffffc0201f60 <get_pte>
ffffffffc020494c:	c955                	beqz	a0,ffffffffc0204a00 <do_pgfault+0xfa>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc020494e:	610c                	ld	a1,0(a0)
ffffffffc0204950:	c9a1                	beqz	a1,ffffffffc02049a0 <do_pgfault+0x9a>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
       if (swap_init_ok) {
ffffffffc0204952:	000a8797          	auipc	a5,0xa8
ffffffffc0204956:	b7678793          	addi	a5,a5,-1162 # ffffffffc02ac4c8 <swap_init_ok>
ffffffffc020495a:	439c                	lw	a5,0(a5)
ffffffffc020495c:	2781                	sext.w	a5,a5
ffffffffc020495e:	cbad                	beqz	a5,ffffffffc02049d0 <do_pgfault+0xca>
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            // swap_in(mm, addr, &page);
            // 根据 mm 和 addr，将适当的磁盘页的内容加载到由 page 管理的内存中
            if (swap_in(mm, addr, &page) != 0) {
ffffffffc0204960:	0030                	addi	a2,sp,8
ffffffffc0204962:	85a2                	mv	a1,s0
ffffffffc0204964:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204966:	e402                	sd	zero,8(sp)
            if (swap_in(mm, addr, &page) != 0) {
ffffffffc0204968:	a36ff0ef          	jal	ra,ffffffffc0203b9e <swap_in>
ffffffffc020496c:	e935                	bnez	a0,ffffffffc02049e0 <do_pgfault+0xda>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            // page_insert(mm->pgdir, page, addr, perm);
            // 建立物理地址（page->phy_addr）与逻辑地址（addr）的映射关系
            if (page_insert(mm->pgdir, page, addr, perm) != 0) {
ffffffffc020496e:	65a2                	ld	a1,8(sp)
ffffffffc0204970:	6c88                	ld	a0,24(s1)
ffffffffc0204972:	86ca                	mv	a3,s2
ffffffffc0204974:	8622                	mv	a2,s0
ffffffffc0204976:	d93fd0ef          	jal	ra,ffffffffc0202708 <page_insert>
ffffffffc020497a:	892a                	mv	s2,a0
ffffffffc020497c:	e935                	bnez	a0,ffffffffc02049f0 <do_pgfault+0xea>
                cprintf("page_insert in do_pgfault failed\n");
                goto failed;
            }
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc020497e:	6622                	ld	a2,8(sp)
ffffffffc0204980:	4685                	li	a3,1
ffffffffc0204982:	85a2                	mv	a1,s0
ffffffffc0204984:	8526                	mv	a0,s1
ffffffffc0204986:	8f4ff0ef          	jal	ra,ffffffffc0203a7a <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc020498a:	67a2                	ld	a5,8(sp)
ffffffffc020498c:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc020498e:	70a2                	ld	ra,40(sp)
ffffffffc0204990:	7402                	ld	s0,32(sp)
ffffffffc0204992:	854a                	mv	a0,s2
ffffffffc0204994:	64e2                	ld	s1,24(sp)
ffffffffc0204996:	6942                	ld	s2,16(sp)
ffffffffc0204998:	6145                	addi	sp,sp,48
ffffffffc020499a:	8082                	ret
        perm |= READ_WRITE;
ffffffffc020499c:	495d                	li	s2,23
ffffffffc020499e:	b745                	j	ffffffffc020493e <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02049a0:	6c88                	ld	a0,24(s1)
ffffffffc02049a2:	864a                	mv	a2,s2
ffffffffc02049a4:	85a2                	mv	a1,s0
ffffffffc02049a6:	8b1fe0ef          	jal	ra,ffffffffc0203256 <pgdir_alloc_page>
   ret = 0;
ffffffffc02049aa:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02049ac:	f16d                	bnez	a0,ffffffffc020498e <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02049ae:	00003517          	auipc	a0,0x3
ffffffffc02049b2:	62a50513          	addi	a0,a0,1578 # ffffffffc0207fd8 <default_pmm_manager+0xd08>
ffffffffc02049b6:	fd8fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02049ba:	5971                	li	s2,-4
            goto failed;
ffffffffc02049bc:	bfc9                	j	ffffffffc020498e <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02049be:	85a2                	mv	a1,s0
ffffffffc02049c0:	00003517          	auipc	a0,0x3
ffffffffc02049c4:	5c850513          	addi	a0,a0,1480 # ffffffffc0207f88 <default_pmm_manager+0xcb8>
ffffffffc02049c8:	fc6fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc02049cc:	5975                	li	s2,-3
        goto failed;
ffffffffc02049ce:	b7c1                	j	ffffffffc020498e <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02049d0:	00003517          	auipc	a0,0x3
ffffffffc02049d4:	67850513          	addi	a0,a0,1656 # ffffffffc0208048 <default_pmm_manager+0xd78>
ffffffffc02049d8:	fb6fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02049dc:	5971                	li	s2,-4
            goto failed;
ffffffffc02049de:	bf45                	j	ffffffffc020498e <do_pgfault+0x88>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc02049e0:	00003517          	auipc	a0,0x3
ffffffffc02049e4:	62050513          	addi	a0,a0,1568 # ffffffffc0208000 <default_pmm_manager+0xd30>
ffffffffc02049e8:	fa6fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02049ec:	5971                	li	s2,-4
ffffffffc02049ee:	b745                	j	ffffffffc020498e <do_pgfault+0x88>
                cprintf("page_insert in do_pgfault failed\n");
ffffffffc02049f0:	00003517          	auipc	a0,0x3
ffffffffc02049f4:	63050513          	addi	a0,a0,1584 # ffffffffc0208020 <default_pmm_manager+0xd50>
ffffffffc02049f8:	f96fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02049fc:	5971                	li	s2,-4
ffffffffc02049fe:	bf41                	j	ffffffffc020498e <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204a00:	00003517          	auipc	a0,0x3
ffffffffc0204a04:	5b850513          	addi	a0,a0,1464 # ffffffffc0207fb8 <default_pmm_manager+0xce8>
ffffffffc0204a08:	f86fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a0c:	5971                	li	s2,-4
        goto failed;
ffffffffc0204a0e:	b741                	j	ffffffffc020498e <do_pgfault+0x88>

ffffffffc0204a10 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204a10:	7179                	addi	sp,sp,-48
ffffffffc0204a12:	f022                	sd	s0,32(sp)
ffffffffc0204a14:	f406                	sd	ra,40(sp)
ffffffffc0204a16:	ec26                	sd	s1,24(sp)
ffffffffc0204a18:	e84a                	sd	s2,16(sp)
ffffffffc0204a1a:	e44e                	sd	s3,8(sp)
ffffffffc0204a1c:	e052                	sd	s4,0(sp)
ffffffffc0204a1e:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204a20:	c135                	beqz	a0,ffffffffc0204a84 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204a22:	002007b7          	lui	a5,0x200
ffffffffc0204a26:	04f5e663          	bltu	a1,a5,ffffffffc0204a72 <user_mem_check+0x62>
ffffffffc0204a2a:	00c584b3          	add	s1,a1,a2
ffffffffc0204a2e:	0495f263          	bleu	s1,a1,ffffffffc0204a72 <user_mem_check+0x62>
ffffffffc0204a32:	4785                	li	a5,1
ffffffffc0204a34:	07fe                	slli	a5,a5,0x1f
ffffffffc0204a36:	0297ee63          	bltu	a5,s1,ffffffffc0204a72 <user_mem_check+0x62>
ffffffffc0204a3a:	892a                	mv	s2,a0
ffffffffc0204a3c:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204a3e:	6a05                	lui	s4,0x1
ffffffffc0204a40:	a821                	j	ffffffffc0204a58 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204a42:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204a46:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204a48:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204a4a:	c685                	beqz	a3,ffffffffc0204a72 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204a4c:	c399                	beqz	a5,ffffffffc0204a52 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204a4e:	02e46263          	bltu	s0,a4,ffffffffc0204a72 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204a52:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204a54:	04947663          	bleu	s1,s0,ffffffffc0204aa0 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204a58:	85a2                	mv	a1,s0
ffffffffc0204a5a:	854a                	mv	a0,s2
ffffffffc0204a5c:	e42ff0ef          	jal	ra,ffffffffc020409e <find_vma>
ffffffffc0204a60:	c909                	beqz	a0,ffffffffc0204a72 <user_mem_check+0x62>
ffffffffc0204a62:	6518                	ld	a4,8(a0)
ffffffffc0204a64:	00e46763          	bltu	s0,a4,ffffffffc0204a72 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204a68:	4d1c                	lw	a5,24(a0)
ffffffffc0204a6a:	fc099ce3          	bnez	s3,ffffffffc0204a42 <user_mem_check+0x32>
ffffffffc0204a6e:	8b85                	andi	a5,a5,1
ffffffffc0204a70:	f3ed                	bnez	a5,ffffffffc0204a52 <user_mem_check+0x42>
            return 0;
ffffffffc0204a72:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204a74:	70a2                	ld	ra,40(sp)
ffffffffc0204a76:	7402                	ld	s0,32(sp)
ffffffffc0204a78:	64e2                	ld	s1,24(sp)
ffffffffc0204a7a:	6942                	ld	s2,16(sp)
ffffffffc0204a7c:	69a2                	ld	s3,8(sp)
ffffffffc0204a7e:	6a02                	ld	s4,0(sp)
ffffffffc0204a80:	6145                	addi	sp,sp,48
ffffffffc0204a82:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204a84:	c02007b7          	lui	a5,0xc0200
ffffffffc0204a88:	4501                	li	a0,0
ffffffffc0204a8a:	fef5e5e3          	bltu	a1,a5,ffffffffc0204a74 <user_mem_check+0x64>
ffffffffc0204a8e:	962e                	add	a2,a2,a1
ffffffffc0204a90:	fec5f2e3          	bleu	a2,a1,ffffffffc0204a74 <user_mem_check+0x64>
ffffffffc0204a94:	c8000537          	lui	a0,0xc8000
ffffffffc0204a98:	0505                	addi	a0,a0,1
ffffffffc0204a9a:	00a63533          	sltu	a0,a2,a0
ffffffffc0204a9e:	bfd9                	j	ffffffffc0204a74 <user_mem_check+0x64>
        return 1;
ffffffffc0204aa0:	4505                	li	a0,1
ffffffffc0204aa2:	bfc9                	j	ffffffffc0204a74 <user_mem_check+0x64>

ffffffffc0204aa4 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204aa4:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204aa6:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204aa8:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204aaa:	b55fb0ef          	jal	ra,ffffffffc02005fe <ide_device_valid>
ffffffffc0204aae:	cd01                	beqz	a0,ffffffffc0204ac6 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ab0:	4505                	li	a0,1
ffffffffc0204ab2:	b53fb0ef          	jal	ra,ffffffffc0200604 <ide_device_size>
}
ffffffffc0204ab6:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204ab8:	810d                	srli	a0,a0,0x3
ffffffffc0204aba:	000a8797          	auipc	a5,0xa8
ffffffffc0204abe:	aea7bf23          	sd	a0,-1282(a5) # ffffffffc02ac5b8 <max_swap_offset>
}
ffffffffc0204ac2:	0141                	addi	sp,sp,16
ffffffffc0204ac4:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204ac6:	00004617          	auipc	a2,0x4
ffffffffc0204aca:	86a60613          	addi	a2,a2,-1942 # ffffffffc0208330 <default_pmm_manager+0x1060>
ffffffffc0204ace:	45b5                	li	a1,13
ffffffffc0204ad0:	00004517          	auipc	a0,0x4
ffffffffc0204ad4:	88050513          	addi	a0,a0,-1920 # ffffffffc0208350 <default_pmm_manager+0x1080>
ffffffffc0204ad8:	9adfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204adc <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204adc:	1141                	addi	sp,sp,-16
ffffffffc0204ade:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ae0:	00855793          	srli	a5,a0,0x8
ffffffffc0204ae4:	cfb9                	beqz	a5,ffffffffc0204b42 <swapfs_read+0x66>
ffffffffc0204ae6:	000a8717          	auipc	a4,0xa8
ffffffffc0204aea:	ad270713          	addi	a4,a4,-1326 # ffffffffc02ac5b8 <max_swap_offset>
ffffffffc0204aee:	6318                	ld	a4,0(a4)
ffffffffc0204af0:	04e7f963          	bleu	a4,a5,ffffffffc0204b42 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204af4:	000a8717          	auipc	a4,0xa8
ffffffffc0204af8:	a3470713          	addi	a4,a4,-1484 # ffffffffc02ac528 <pages>
ffffffffc0204afc:	6310                	ld	a2,0(a4)
ffffffffc0204afe:	00004717          	auipc	a4,0x4
ffffffffc0204b02:	1aa70713          	addi	a4,a4,426 # ffffffffc0208ca8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b06:	000a8697          	auipc	a3,0xa8
ffffffffc0204b0a:	9b268693          	addi	a3,a3,-1614 # ffffffffc02ac4b8 <npage>
    return page - pages + nbase;
ffffffffc0204b0e:	40c58633          	sub	a2,a1,a2
ffffffffc0204b12:	630c                	ld	a1,0(a4)
ffffffffc0204b14:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b16:	577d                	li	a4,-1
ffffffffc0204b18:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204b1a:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b1c:	8331                	srli	a4,a4,0xc
ffffffffc0204b1e:	8f71                	and	a4,a4,a2
ffffffffc0204b20:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b24:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b26:	02d77a63          	bleu	a3,a4,ffffffffc0204b5a <swapfs_read+0x7e>
ffffffffc0204b2a:	000a8797          	auipc	a5,0xa8
ffffffffc0204b2e:	9ee78793          	addi	a5,a5,-1554 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0204b32:	639c                	ld	a5,0(a5)
}
ffffffffc0204b34:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b36:	46a1                	li	a3,8
ffffffffc0204b38:	963e                	add	a2,a2,a5
ffffffffc0204b3a:	4505                	li	a0,1
}
ffffffffc0204b3c:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b3e:	acdfb06f          	j	ffffffffc020060a <ide_read_secs>
ffffffffc0204b42:	86aa                	mv	a3,a0
ffffffffc0204b44:	00004617          	auipc	a2,0x4
ffffffffc0204b48:	82460613          	addi	a2,a2,-2012 # ffffffffc0208368 <default_pmm_manager+0x1098>
ffffffffc0204b4c:	45d1                	li	a1,20
ffffffffc0204b4e:	00004517          	auipc	a0,0x4
ffffffffc0204b52:	80250513          	addi	a0,a0,-2046 # ffffffffc0208350 <default_pmm_manager+0x1080>
ffffffffc0204b56:	92ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204b5a:	86b2                	mv	a3,a2
ffffffffc0204b5c:	06900593          	li	a1,105
ffffffffc0204b60:	00002617          	auipc	a2,0x2
ffffffffc0204b64:	7c060613          	addi	a2,a2,1984 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0204b68:	00002517          	auipc	a0,0x2
ffffffffc0204b6c:	7e050513          	addi	a0,a0,2016 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0204b70:	915fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204b74 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204b74:	1141                	addi	sp,sp,-16
ffffffffc0204b76:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b78:	00855793          	srli	a5,a0,0x8
ffffffffc0204b7c:	cfb9                	beqz	a5,ffffffffc0204bda <swapfs_write+0x66>
ffffffffc0204b7e:	000a8717          	auipc	a4,0xa8
ffffffffc0204b82:	a3a70713          	addi	a4,a4,-1478 # ffffffffc02ac5b8 <max_swap_offset>
ffffffffc0204b86:	6318                	ld	a4,0(a4)
ffffffffc0204b88:	04e7f963          	bleu	a4,a5,ffffffffc0204bda <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204b8c:	000a8717          	auipc	a4,0xa8
ffffffffc0204b90:	99c70713          	addi	a4,a4,-1636 # ffffffffc02ac528 <pages>
ffffffffc0204b94:	6310                	ld	a2,0(a4)
ffffffffc0204b96:	00004717          	auipc	a4,0x4
ffffffffc0204b9a:	11270713          	addi	a4,a4,274 # ffffffffc0208ca8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b9e:	000a8697          	auipc	a3,0xa8
ffffffffc0204ba2:	91a68693          	addi	a3,a3,-1766 # ffffffffc02ac4b8 <npage>
    return page - pages + nbase;
ffffffffc0204ba6:	40c58633          	sub	a2,a1,a2
ffffffffc0204baa:	630c                	ld	a1,0(a4)
ffffffffc0204bac:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204bae:	577d                	li	a4,-1
ffffffffc0204bb0:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204bb2:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bb4:	8331                	srli	a4,a4,0xc
ffffffffc0204bb6:	8f71                	and	a4,a4,a2
ffffffffc0204bb8:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bbc:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bbe:	02d77a63          	bleu	a3,a4,ffffffffc0204bf2 <swapfs_write+0x7e>
ffffffffc0204bc2:	000a8797          	auipc	a5,0xa8
ffffffffc0204bc6:	95678793          	addi	a5,a5,-1706 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0204bca:	639c                	ld	a5,0(a5)
}
ffffffffc0204bcc:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bce:	46a1                	li	a3,8
ffffffffc0204bd0:	963e                	add	a2,a2,a5
ffffffffc0204bd2:	4505                	li	a0,1
}
ffffffffc0204bd4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bd6:	a59fb06f          	j	ffffffffc020062e <ide_write_secs>
ffffffffc0204bda:	86aa                	mv	a3,a0
ffffffffc0204bdc:	00003617          	auipc	a2,0x3
ffffffffc0204be0:	78c60613          	addi	a2,a2,1932 # ffffffffc0208368 <default_pmm_manager+0x1098>
ffffffffc0204be4:	45e5                	li	a1,25
ffffffffc0204be6:	00003517          	auipc	a0,0x3
ffffffffc0204bea:	76a50513          	addi	a0,a0,1898 # ffffffffc0208350 <default_pmm_manager+0x1080>
ffffffffc0204bee:	897fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204bf2:	86b2                	mv	a3,a2
ffffffffc0204bf4:	06900593          	li	a1,105
ffffffffc0204bf8:	00002617          	auipc	a2,0x2
ffffffffc0204bfc:	72860613          	addi	a2,a2,1832 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0204c00:	00002517          	auipc	a0,0x2
ffffffffc0204c04:	74850513          	addi	a0,a0,1864 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0204c08:	87dfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204c0c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c0c:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c0e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c10:	732000ef          	jal	ra,ffffffffc0205342 <do_exit>

ffffffffc0204c14 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204c14:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c16:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204c1a:	e022                	sd	s0,0(sp)
ffffffffc0204c1c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c1e:	838fd0ef          	jal	ra,ffffffffc0201c56 <kmalloc>
ffffffffc0204c22:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204c24:	cd29                	beqz	a0,ffffffffc0204c7e <alloc_proc+0x6a>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204c26:	57fd                	li	a5,-1
ffffffffc0204c28:	1782                	slli	a5,a5,0x20
ffffffffc0204c2a:	e11c                	sd	a5,0(a0)
    	proc->runs = 0;
    	proc->kstack = NULL;
    	proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c2c:	07000613          	li	a2,112
ffffffffc0204c30:	4581                	li	a1,0
    	proc->runs = 0;
ffffffffc0204c32:	00052423          	sw	zero,8(a0)
    	proc->kstack = NULL;
ffffffffc0204c36:	00053823          	sd	zero,16(a0)
    	proc->need_resched = 0;
ffffffffc0204c3a:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204c3e:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204c42:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c46:	03050513          	addi	a0,a0,48
ffffffffc0204c4a:	11f010ef          	jal	ra,ffffffffc0206568 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204c4e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c52:	8d278793          	addi	a5,a5,-1838 # ffffffffc02ac520 <boot_cr3>
ffffffffc0204c56:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204c58:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204c5c:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204c60:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204c62:	463d                	li	a2,15
ffffffffc0204c64:	4581                	li	a1,0
ffffffffc0204c66:	0b440513          	addi	a0,s0,180
ffffffffc0204c6a:	0ff010ef          	jal	ra,ffffffffc0206568 <memset>
        proc->wait_state = 0; //PCB新增的条目，初始化进程等待状态
ffffffffc0204c6e:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;//设置指针
ffffffffc0204c72:	0e043c23          	sd	zero,248(s0)
ffffffffc0204c76:	10043023          	sd	zero,256(s0)
ffffffffc0204c7a:	0e043823          	sd	zero,240(s0)

    }
    return proc;
}
ffffffffc0204c7e:	8522                	mv	a0,s0
ffffffffc0204c80:	60a2                	ld	ra,8(sp)
ffffffffc0204c82:	6402                	ld	s0,0(sp)
ffffffffc0204c84:	0141                	addi	sp,sp,16
ffffffffc0204c86:	8082                	ret

ffffffffc0204c88 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204c88:	000a8797          	auipc	a5,0xa8
ffffffffc0204c8c:	84878793          	addi	a5,a5,-1976 # ffffffffc02ac4d0 <current>
ffffffffc0204c90:	639c                	ld	a5,0(a5)
ffffffffc0204c92:	73c8                	ld	a0,160(a5)
ffffffffc0204c94:	916fc06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204c98 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204c98:	000a8797          	auipc	a5,0xa8
ffffffffc0204c9c:	83878793          	addi	a5,a5,-1992 # ffffffffc02ac4d0 <current>
ffffffffc0204ca0:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204ca2:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ca4:	00004617          	auipc	a2,0x4
ffffffffc0204ca8:	ad460613          	addi	a2,a2,-1324 # ffffffffc0208778 <default_pmm_manager+0x14a8>
ffffffffc0204cac:	43cc                	lw	a1,4(a5)
ffffffffc0204cae:	00004517          	auipc	a0,0x4
ffffffffc0204cb2:	ada50513          	addi	a0,a0,-1318 # ffffffffc0208788 <default_pmm_manager+0x14b8>
user_main(void *arg) {
ffffffffc0204cb6:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204cb8:	cd6fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204cbc:	00004797          	auipc	a5,0x4
ffffffffc0204cc0:	abc78793          	addi	a5,a5,-1348 # ffffffffc0208778 <default_pmm_manager+0x14a8>
ffffffffc0204cc4:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204cc8:	61470713          	addi	a4,a4,1556 # a2d8 <_binary_obj___user_forktest_out_size>
ffffffffc0204ccc:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204cce:	853e                	mv	a0,a5
ffffffffc0204cd0:	00043717          	auipc	a4,0x43
ffffffffc0204cd4:	39070713          	addi	a4,a4,912 # ffffffffc0248060 <_binary_obj___user_forktest_out_start>
ffffffffc0204cd8:	f03a                	sd	a4,32(sp)
ffffffffc0204cda:	f43e                	sd	a5,40(sp)
ffffffffc0204cdc:	e802                	sd	zero,16(sp)
ffffffffc0204cde:	7ec010ef          	jal	ra,ffffffffc02064ca <strlen>
ffffffffc0204ce2:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204ce4:	4511                	li	a0,4
ffffffffc0204ce6:	55a2                	lw	a1,40(sp)
ffffffffc0204ce8:	4662                	lw	a2,24(sp)
ffffffffc0204cea:	5682                	lw	a3,32(sp)
ffffffffc0204cec:	4722                	lw	a4,8(sp)
ffffffffc0204cee:	48a9                	li	a7,10
ffffffffc0204cf0:	9002                	ebreak
ffffffffc0204cf2:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204cf4:	65c2                	ld	a1,16(sp)
ffffffffc0204cf6:	00004517          	auipc	a0,0x4
ffffffffc0204cfa:	aba50513          	addi	a0,a0,-1350 # ffffffffc02087b0 <default_pmm_manager+0x14e0>
ffffffffc0204cfe:	c90fb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204d02:	00004617          	auipc	a2,0x4
ffffffffc0204d06:	abe60613          	addi	a2,a2,-1346 # ffffffffc02087c0 <default_pmm_manager+0x14f0>
ffffffffc0204d0a:	34d00593          	li	a1,845
ffffffffc0204d0e:	00004517          	auipc	a0,0x4
ffffffffc0204d12:	ad250513          	addi	a0,a0,-1326 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0204d16:	f6efb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204d1a <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204d1a:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204d1c:	1141                	addi	sp,sp,-16
ffffffffc0204d1e:	e406                	sd	ra,8(sp)
ffffffffc0204d20:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d24:	04f6e263          	bltu	a3,a5,ffffffffc0204d68 <put_pgdir+0x4e>
ffffffffc0204d28:	000a7797          	auipc	a5,0xa7
ffffffffc0204d2c:	7f078793          	addi	a5,a5,2032 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0204d30:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204d32:	000a7797          	auipc	a5,0xa7
ffffffffc0204d36:	78678793          	addi	a5,a5,1926 # ffffffffc02ac4b8 <npage>
ffffffffc0204d3a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204d3c:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204d3e:	82b1                	srli	a3,a3,0xc
ffffffffc0204d40:	04f6f063          	bleu	a5,a3,ffffffffc0204d80 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204d44:	00004797          	auipc	a5,0x4
ffffffffc0204d48:	f6478793          	addi	a5,a5,-156 # ffffffffc0208ca8 <nbase>
ffffffffc0204d4c:	639c                	ld	a5,0(a5)
ffffffffc0204d4e:	000a7717          	auipc	a4,0xa7
ffffffffc0204d52:	7da70713          	addi	a4,a4,2010 # ffffffffc02ac528 <pages>
ffffffffc0204d56:	6308                	ld	a0,0(a4)
}
ffffffffc0204d58:	60a2                	ld	ra,8(sp)
ffffffffc0204d5a:	8e9d                	sub	a3,a3,a5
ffffffffc0204d5c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204d5e:	4585                	li	a1,1
ffffffffc0204d60:	9536                	add	a0,a0,a3
}
ffffffffc0204d62:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204d64:	976fd06f          	j	ffffffffc0201eda <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204d68:	00002617          	auipc	a2,0x2
ffffffffc0204d6c:	5f060613          	addi	a2,a2,1520 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc0204d70:	06e00593          	li	a1,110
ffffffffc0204d74:	00002517          	auipc	a0,0x2
ffffffffc0204d78:	5d450513          	addi	a0,a0,1492 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0204d7c:	f08fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204d80:	00002617          	auipc	a2,0x2
ffffffffc0204d84:	60060613          	addi	a2,a2,1536 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc0204d88:	06200593          	li	a1,98
ffffffffc0204d8c:	00002517          	auipc	a0,0x2
ffffffffc0204d90:	5bc50513          	addi	a0,a0,1468 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0204d94:	ef0fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204d98 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204d98:	1101                	addi	sp,sp,-32
ffffffffc0204d9a:	e426                	sd	s1,8(sp)
ffffffffc0204d9c:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204d9e:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204da0:	ec06                	sd	ra,24(sp)
ffffffffc0204da2:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204da4:	8aefd0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
ffffffffc0204da8:	c125                	beqz	a0,ffffffffc0204e08 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204daa:	000a7797          	auipc	a5,0xa7
ffffffffc0204dae:	77e78793          	addi	a5,a5,1918 # ffffffffc02ac528 <pages>
ffffffffc0204db2:	6394                	ld	a3,0(a5)
ffffffffc0204db4:	00004797          	auipc	a5,0x4
ffffffffc0204db8:	ef478793          	addi	a5,a5,-268 # ffffffffc0208ca8 <nbase>
ffffffffc0204dbc:	6380                	ld	s0,0(a5)
ffffffffc0204dbe:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204dc2:	000a7717          	auipc	a4,0xa7
ffffffffc0204dc6:	6f670713          	addi	a4,a4,1782 # ffffffffc02ac4b8 <npage>
    return page - pages + nbase;
ffffffffc0204dca:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204dcc:	57fd                	li	a5,-1
ffffffffc0204dce:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204dd0:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204dd2:	83b1                	srli	a5,a5,0xc
ffffffffc0204dd4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204dd6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204dd8:	02e7fa63          	bleu	a4,a5,ffffffffc0204e0c <setup_pgdir+0x74>
ffffffffc0204ddc:	000a7797          	auipc	a5,0xa7
ffffffffc0204de0:	73c78793          	addi	a5,a5,1852 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0204de4:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204de6:	000a7797          	auipc	a5,0xa7
ffffffffc0204dea:	6ca78793          	addi	a5,a5,1738 # ffffffffc02ac4b0 <boot_pgdir>
ffffffffc0204dee:	638c                	ld	a1,0(a5)
ffffffffc0204df0:	9436                	add	s0,s0,a3
ffffffffc0204df2:	6605                	lui	a2,0x1
ffffffffc0204df4:	8522                	mv	a0,s0
ffffffffc0204df6:	784010ef          	jal	ra,ffffffffc020657a <memcpy>
    return 0;
ffffffffc0204dfa:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204dfc:	ec80                	sd	s0,24(s1)
}
ffffffffc0204dfe:	60e2                	ld	ra,24(sp)
ffffffffc0204e00:	6442                	ld	s0,16(sp)
ffffffffc0204e02:	64a2                	ld	s1,8(sp)
ffffffffc0204e04:	6105                	addi	sp,sp,32
ffffffffc0204e06:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204e08:	5571                	li	a0,-4
ffffffffc0204e0a:	bfd5                	j	ffffffffc0204dfe <setup_pgdir+0x66>
ffffffffc0204e0c:	00002617          	auipc	a2,0x2
ffffffffc0204e10:	51460613          	addi	a2,a2,1300 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0204e14:	06900593          	li	a1,105
ffffffffc0204e18:	00002517          	auipc	a0,0x2
ffffffffc0204e1c:	53050513          	addi	a0,a0,1328 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0204e20:	e64fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204e24 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e24:	1101                	addi	sp,sp,-32
ffffffffc0204e26:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e28:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e2c:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e2e:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e30:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e32:	8522                	mv	a0,s0
ffffffffc0204e34:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e36:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e38:	730010ef          	jal	ra,ffffffffc0206568 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e3c:	8522                	mv	a0,s0
}
ffffffffc0204e3e:	6442                	ld	s0,16(sp)
ffffffffc0204e40:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e42:	85a6                	mv	a1,s1
}
ffffffffc0204e44:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e46:	463d                	li	a2,15
}
ffffffffc0204e48:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e4a:	7300106f          	j	ffffffffc020657a <memcpy>

ffffffffc0204e4e <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204e4e:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204e50:	000a7797          	auipc	a5,0xa7
ffffffffc0204e54:	68078793          	addi	a5,a5,1664 # ffffffffc02ac4d0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204e58:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204e5a:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204e5c:	ec06                	sd	ra,24(sp)
ffffffffc0204e5e:	e822                	sd	s0,16(sp)
ffffffffc0204e60:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204e62:	02a48b63          	beq	s1,a0,ffffffffc0204e98 <proc_run+0x4a>
ffffffffc0204e66:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204e68:	100027f3          	csrr	a5,sstatus
ffffffffc0204e6c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204e6e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204e70:	e3a9                	bnez	a5,ffffffffc0204eb2 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204e72:	745c                	ld	a5,168(s0)
        current = proc;
ffffffffc0204e74:	000a7717          	auipc	a4,0xa7
ffffffffc0204e78:	64873e23          	sd	s0,1628(a4) # ffffffffc02ac4d0 <current>
ffffffffc0204e7c:	577d                	li	a4,-1
ffffffffc0204e7e:	177e                	slli	a4,a4,0x3f
ffffffffc0204e80:	83b1                	srli	a5,a5,0xc
ffffffffc0204e82:	8fd9                	or	a5,a5,a4
ffffffffc0204e84:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(next->context));
ffffffffc0204e88:	03040593          	addi	a1,s0,48
ffffffffc0204e8c:	03048513          	addi	a0,s1,48
ffffffffc0204e90:	7cf000ef          	jal	ra,ffffffffc0205e5e <switch_to>
    if (flag) {
ffffffffc0204e94:	00091863          	bnez	s2,ffffffffc0204ea4 <proc_run+0x56>
}
ffffffffc0204e98:	60e2                	ld	ra,24(sp)
ffffffffc0204e9a:	6442                	ld	s0,16(sp)
ffffffffc0204e9c:	64a2                	ld	s1,8(sp)
ffffffffc0204e9e:	6902                	ld	s2,0(sp)
ffffffffc0204ea0:	6105                	addi	sp,sp,32
ffffffffc0204ea2:	8082                	ret
ffffffffc0204ea4:	6442                	ld	s0,16(sp)
ffffffffc0204ea6:	60e2                	ld	ra,24(sp)
ffffffffc0204ea8:	64a2                	ld	s1,8(sp)
ffffffffc0204eaa:	6902                	ld	s2,0(sp)
ffffffffc0204eac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204eae:	fa6fb06f          	j	ffffffffc0200654 <intr_enable>
        intr_disable();
ffffffffc0204eb2:	fa8fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0204eb6:	4905                	li	s2,1
ffffffffc0204eb8:	bf6d                	j	ffffffffc0204e72 <proc_run+0x24>

ffffffffc0204eba <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204eba:	0005071b          	sext.w	a4,a0
ffffffffc0204ebe:	6789                	lui	a5,0x2
ffffffffc0204ec0:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204ec4:	17f9                	addi	a5,a5,-2
ffffffffc0204ec6:	04d7e063          	bltu	a5,a3,ffffffffc0204f06 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204eca:	1141                	addi	sp,sp,-16
ffffffffc0204ecc:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204ece:	45a9                	li	a1,10
ffffffffc0204ed0:	842a                	mv	s0,a0
ffffffffc0204ed2:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204ed4:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204ed6:	1e4010ef          	jal	ra,ffffffffc02060ba <hash32>
ffffffffc0204eda:	02051693          	slli	a3,a0,0x20
ffffffffc0204ede:	82f1                	srli	a3,a3,0x1c
ffffffffc0204ee0:	000a3517          	auipc	a0,0xa3
ffffffffc0204ee4:	5b850513          	addi	a0,a0,1464 # ffffffffc02a8498 <hash_list>
ffffffffc0204ee8:	96aa                	add	a3,a3,a0
ffffffffc0204eea:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204eec:	a029                	j	ffffffffc0204ef6 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204eee:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x764c>
ffffffffc0204ef2:	00870c63          	beq	a4,s0,ffffffffc0204f0a <find_proc+0x50>
ffffffffc0204ef6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204ef8:	fef69be3          	bne	a3,a5,ffffffffc0204eee <find_proc+0x34>
}
ffffffffc0204efc:	60a2                	ld	ra,8(sp)
ffffffffc0204efe:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204f00:	4501                	li	a0,0
}
ffffffffc0204f02:	0141                	addi	sp,sp,16
ffffffffc0204f04:	8082                	ret
    return NULL;
ffffffffc0204f06:	4501                	li	a0,0
}
ffffffffc0204f08:	8082                	ret
ffffffffc0204f0a:	60a2                	ld	ra,8(sp)
ffffffffc0204f0c:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204f0e:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204f12:	0141                	addi	sp,sp,16
ffffffffc0204f14:	8082                	ret

ffffffffc0204f16 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f16:	7159                	addi	sp,sp,-112
ffffffffc0204f18:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f1a:	000a7a17          	auipc	s4,0xa7
ffffffffc0204f1e:	5cea0a13          	addi	s4,s4,1486 # ffffffffc02ac4e8 <nr_process>
ffffffffc0204f22:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f26:	f486                	sd	ra,104(sp)
ffffffffc0204f28:	f0a2                	sd	s0,96(sp)
ffffffffc0204f2a:	eca6                	sd	s1,88(sp)
ffffffffc0204f2c:	e8ca                	sd	s2,80(sp)
ffffffffc0204f2e:	e4ce                	sd	s3,72(sp)
ffffffffc0204f30:	fc56                	sd	s5,56(sp)
ffffffffc0204f32:	f85a                	sd	s6,48(sp)
ffffffffc0204f34:	f45e                	sd	s7,40(sp)
ffffffffc0204f36:	f062                	sd	s8,32(sp)
ffffffffc0204f38:	ec66                	sd	s9,24(sp)
ffffffffc0204f3a:	e86a                	sd	s10,16(sp)
ffffffffc0204f3c:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f3e:	6785                	lui	a5,0x1
ffffffffc0204f40:	30f75a63          	ble	a5,a4,ffffffffc0205254 <do_fork+0x33e>
ffffffffc0204f44:	89aa                	mv	s3,a0
ffffffffc0204f46:	892e                	mv	s2,a1
ffffffffc0204f48:	84b2                	mv	s1,a2
     if ((proc = alloc_proc()) == NULL)
ffffffffc0204f4a:	ccbff0ef          	jal	ra,ffffffffc0204c14 <alloc_proc>
ffffffffc0204f4e:	842a                	mv	s0,a0
ffffffffc0204f50:	2e050463          	beqz	a0,ffffffffc0205238 <do_fork+0x322>
    proc->parent = current;
ffffffffc0204f54:	000a7c17          	auipc	s8,0xa7
ffffffffc0204f58:	57cc0c13          	addi	s8,s8,1404 # ffffffffc02ac4d0 <current>
ffffffffc0204f5c:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204f60:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x848c>
    proc->parent = current;
ffffffffc0204f64:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0204f66:	30071563          	bnez	a4,ffffffffc0205270 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204f6a:	4509                	li	a0,2
ffffffffc0204f6c:	ee7fc0ef          	jal	ra,ffffffffc0201e52 <alloc_pages>
    if (page != NULL) {
ffffffffc0204f70:	2c050163          	beqz	a0,ffffffffc0205232 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0204f74:	000a7a97          	auipc	s5,0xa7
ffffffffc0204f78:	5b4a8a93          	addi	s5,s5,1460 # ffffffffc02ac528 <pages>
ffffffffc0204f7c:	000ab683          	ld	a3,0(s5)
ffffffffc0204f80:	00004b17          	auipc	s6,0x4
ffffffffc0204f84:	d28b0b13          	addi	s6,s6,-728 # ffffffffc0208ca8 <nbase>
ffffffffc0204f88:	000b3783          	ld	a5,0(s6)
ffffffffc0204f8c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204f90:	000a7b97          	auipc	s7,0xa7
ffffffffc0204f94:	528b8b93          	addi	s7,s7,1320 # ffffffffc02ac4b8 <npage>
    return page - pages + nbase;
ffffffffc0204f98:	8699                	srai	a3,a3,0x6
ffffffffc0204f9a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204f9c:	000bb703          	ld	a4,0(s7)
ffffffffc0204fa0:	57fd                	li	a5,-1
ffffffffc0204fa2:	83b1                	srli	a5,a5,0xc
ffffffffc0204fa4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fa6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204fa8:	2ae7f863          	bleu	a4,a5,ffffffffc0205258 <do_fork+0x342>
ffffffffc0204fac:	000a7c97          	auipc	s9,0xa7
ffffffffc0204fb0:	56cc8c93          	addi	s9,s9,1388 # ffffffffc02ac518 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204fb4:	000c3703          	ld	a4,0(s8)
ffffffffc0204fb8:	000cb783          	ld	a5,0(s9)
ffffffffc0204fbc:	02873c03          	ld	s8,40(a4)
ffffffffc0204fc0:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204fc2:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0204fc4:	020c0863          	beqz	s8,ffffffffc0204ff4 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0204fc8:	1009f993          	andi	s3,s3,256
ffffffffc0204fcc:	1e098163          	beqz	s3,ffffffffc02051ae <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204fd0:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fd4:	018c3783          	ld	a5,24(s8)
ffffffffc0204fd8:	c02006b7          	lui	a3,0xc0200
ffffffffc0204fdc:	2705                	addiw	a4,a4,1
ffffffffc0204fde:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0204fe2:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204fe6:	2ad7e563          	bltu	a5,a3,ffffffffc0205290 <do_fork+0x37a>
ffffffffc0204fea:	000cb703          	ld	a4,0(s9)
ffffffffc0204fee:	6814                	ld	a3,16(s0)
ffffffffc0204ff0:	8f99                	sub	a5,a5,a4
ffffffffc0204ff2:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204ff4:	6789                	lui	a5,0x2
ffffffffc0204ff6:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7698>
ffffffffc0204ffa:	96be                	add	a3,a3,a5
ffffffffc0204ffc:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204ffe:	87b6                	mv	a5,a3
ffffffffc0205000:	12048813          	addi	a6,s1,288
ffffffffc0205004:	6088                	ld	a0,0(s1)
ffffffffc0205006:	648c                	ld	a1,8(s1)
ffffffffc0205008:	6890                	ld	a2,16(s1)
ffffffffc020500a:	6c98                	ld	a4,24(s1)
ffffffffc020500c:	e388                	sd	a0,0(a5)
ffffffffc020500e:	e78c                	sd	a1,8(a5)
ffffffffc0205010:	eb90                	sd	a2,16(a5)
ffffffffc0205012:	ef98                	sd	a4,24(a5)
ffffffffc0205014:	02048493          	addi	s1,s1,32
ffffffffc0205018:	02078793          	addi	a5,a5,32
ffffffffc020501c:	ff0494e3          	bne	s1,a6,ffffffffc0205004 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc0205020:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205024:	12090e63          	beqz	s2,ffffffffc0205160 <do_fork+0x24a>
ffffffffc0205028:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020502c:	00000797          	auipc	a5,0x0
ffffffffc0205030:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204c88 <forkret>
ffffffffc0205034:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205036:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205038:	100027f3          	csrr	a5,sstatus
ffffffffc020503c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020503e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205040:	12079f63          	bnez	a5,ffffffffc020517e <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205044:	0009c797          	auipc	a5,0x9c
ffffffffc0205048:	04c78793          	addi	a5,a5,76 # ffffffffc02a1090 <last_pid.1691>
ffffffffc020504c:	439c                	lw	a5,0(a5)
ffffffffc020504e:	6709                	lui	a4,0x2
ffffffffc0205050:	0017851b          	addiw	a0,a5,1
ffffffffc0205054:	0009c697          	auipc	a3,0x9c
ffffffffc0205058:	02a6ae23          	sw	a0,60(a3) # ffffffffc02a1090 <last_pid.1691>
ffffffffc020505c:	14e55263          	ble	a4,a0,ffffffffc02051a0 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc0205060:	0009c797          	auipc	a5,0x9c
ffffffffc0205064:	03478793          	addi	a5,a5,52 # ffffffffc02a1094 <next_safe.1690>
ffffffffc0205068:	439c                	lw	a5,0(a5)
ffffffffc020506a:	000a7497          	auipc	s1,0xa7
ffffffffc020506e:	5a648493          	addi	s1,s1,1446 # ffffffffc02ac610 <proc_list>
ffffffffc0205072:	06f54063          	blt	a0,a5,ffffffffc02050d2 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205076:	6789                	lui	a5,0x2
ffffffffc0205078:	0009c717          	auipc	a4,0x9c
ffffffffc020507c:	00f72e23          	sw	a5,28(a4) # ffffffffc02a1094 <next_safe.1690>
ffffffffc0205080:	4581                	li	a1,0
ffffffffc0205082:	87aa                	mv	a5,a0
ffffffffc0205084:	000a7497          	auipc	s1,0xa7
ffffffffc0205088:	58c48493          	addi	s1,s1,1420 # ffffffffc02ac610 <proc_list>
    repeat:
ffffffffc020508c:	6889                	lui	a7,0x2
ffffffffc020508e:	882e                	mv	a6,a1
ffffffffc0205090:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205092:	000a7697          	auipc	a3,0xa7
ffffffffc0205096:	57e68693          	addi	a3,a3,1406 # ffffffffc02ac610 <proc_list>
ffffffffc020509a:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020509c:	00968f63          	beq	a3,s1,ffffffffc02050ba <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc02050a0:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02050a4:	0ae78963          	beq	a5,a4,ffffffffc0205156 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02050a8:	fee7d9e3          	ble	a4,a5,ffffffffc020509a <do_fork+0x184>
ffffffffc02050ac:	fec757e3          	ble	a2,a4,ffffffffc020509a <do_fork+0x184>
ffffffffc02050b0:	6694                	ld	a3,8(a3)
ffffffffc02050b2:	863a                	mv	a2,a4
ffffffffc02050b4:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc02050b6:	fe9695e3          	bne	a3,s1,ffffffffc02050a0 <do_fork+0x18a>
ffffffffc02050ba:	c591                	beqz	a1,ffffffffc02050c6 <do_fork+0x1b0>
ffffffffc02050bc:	0009c717          	auipc	a4,0x9c
ffffffffc02050c0:	fcf72a23          	sw	a5,-44(a4) # ffffffffc02a1090 <last_pid.1691>
ffffffffc02050c4:	853e                	mv	a0,a5
ffffffffc02050c6:	00080663          	beqz	a6,ffffffffc02050d2 <do_fork+0x1bc>
ffffffffc02050ca:	0009c797          	auipc	a5,0x9c
ffffffffc02050ce:	fcc7a523          	sw	a2,-54(a5) # ffffffffc02a1094 <next_safe.1690>
        proc->pid = get_pid();
ffffffffc02050d2:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02050d4:	45a9                	li	a1,10
ffffffffc02050d6:	2501                	sext.w	a0,a0
ffffffffc02050d8:	7e3000ef          	jal	ra,ffffffffc02060ba <hash32>
ffffffffc02050dc:	1502                	slli	a0,a0,0x20
ffffffffc02050de:	000a3797          	auipc	a5,0xa3
ffffffffc02050e2:	3ba78793          	addi	a5,a5,954 # ffffffffc02a8498 <hash_list>
ffffffffc02050e6:	8171                	srli	a0,a0,0x1c
ffffffffc02050e8:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02050ea:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050ec:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02050ee:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02050f2:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02050f4:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02050f6:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02050f8:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02050fa:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02050fe:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0205100:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0205102:	e21c                	sd	a5,0(a2)
ffffffffc0205104:	000a7597          	auipc	a1,0xa7
ffffffffc0205108:	50f5ba23          	sd	a5,1300(a1) # ffffffffc02ac618 <proc_list+0x8>
    elm->next = next;
ffffffffc020510c:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc020510e:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0205110:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205114:	10e43023          	sd	a4,256(s0)
ffffffffc0205118:	c311                	beqz	a4,ffffffffc020511c <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc020511a:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc020511c:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc0205120:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc0205122:	2785                	addiw	a5,a5,1
ffffffffc0205124:	000a7717          	auipc	a4,0xa7
ffffffffc0205128:	3cf72223          	sw	a5,964(a4) # ffffffffc02ac4e8 <nr_process>
    if (flag) {
ffffffffc020512c:	10091863          	bnez	s2,ffffffffc020523c <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc0205130:	8522                	mv	a0,s0
ffffffffc0205132:	597000ef          	jal	ra,ffffffffc0205ec8 <wakeup_proc>
    ret = proc->pid;
ffffffffc0205136:	4048                	lw	a0,4(s0)
}
ffffffffc0205138:	70a6                	ld	ra,104(sp)
ffffffffc020513a:	7406                	ld	s0,96(sp)
ffffffffc020513c:	64e6                	ld	s1,88(sp)
ffffffffc020513e:	6946                	ld	s2,80(sp)
ffffffffc0205140:	69a6                	ld	s3,72(sp)
ffffffffc0205142:	6a06                	ld	s4,64(sp)
ffffffffc0205144:	7ae2                	ld	s5,56(sp)
ffffffffc0205146:	7b42                	ld	s6,48(sp)
ffffffffc0205148:	7ba2                	ld	s7,40(sp)
ffffffffc020514a:	7c02                	ld	s8,32(sp)
ffffffffc020514c:	6ce2                	ld	s9,24(sp)
ffffffffc020514e:	6d42                	ld	s10,16(sp)
ffffffffc0205150:	6da2                	ld	s11,8(sp)
ffffffffc0205152:	6165                	addi	sp,sp,112
ffffffffc0205154:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205156:	2785                	addiw	a5,a5,1
ffffffffc0205158:	0ec7d563          	ble	a2,a5,ffffffffc0205242 <do_fork+0x32c>
ffffffffc020515c:	4585                	li	a1,1
ffffffffc020515e:	bf35                	j	ffffffffc020509a <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205160:	8936                	mv	s2,a3
ffffffffc0205162:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205166:	00000797          	auipc	a5,0x0
ffffffffc020516a:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204c88 <forkret>
ffffffffc020516e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205170:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205172:	100027f3          	csrr	a5,sstatus
ffffffffc0205176:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205178:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020517a:	ec0785e3          	beqz	a5,ffffffffc0205044 <do_fork+0x12e>
        intr_disable();
ffffffffc020517e:	cdcfb0ef          	jal	ra,ffffffffc020065a <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205182:	0009c797          	auipc	a5,0x9c
ffffffffc0205186:	f0e78793          	addi	a5,a5,-242 # ffffffffc02a1090 <last_pid.1691>
ffffffffc020518a:	439c                	lw	a5,0(a5)
ffffffffc020518c:	6709                	lui	a4,0x2
        return 1;
ffffffffc020518e:	4905                	li	s2,1
ffffffffc0205190:	0017851b          	addiw	a0,a5,1
ffffffffc0205194:	0009c697          	auipc	a3,0x9c
ffffffffc0205198:	eea6ae23          	sw	a0,-260(a3) # ffffffffc02a1090 <last_pid.1691>
ffffffffc020519c:	ece542e3          	blt	a0,a4,ffffffffc0205060 <do_fork+0x14a>
        last_pid = 1;
ffffffffc02051a0:	4785                	li	a5,1
ffffffffc02051a2:	0009c717          	auipc	a4,0x9c
ffffffffc02051a6:	eef72723          	sw	a5,-274(a4) # ffffffffc02a1090 <last_pid.1691>
ffffffffc02051aa:	4505                	li	a0,1
ffffffffc02051ac:	b5e9                	j	ffffffffc0205076 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc02051ae:	e77fe0ef          	jal	ra,ffffffffc0204024 <mm_create>
ffffffffc02051b2:	8daa                	mv	s11,a0
ffffffffc02051b4:	c539                	beqz	a0,ffffffffc0205202 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc02051b6:	be3ff0ef          	jal	ra,ffffffffc0204d98 <setup_pgdir>
ffffffffc02051ba:	e949                	bnez	a0,ffffffffc020524c <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02051bc:	038c0993          	addi	s3,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02051c0:	4785                	li	a5,1
ffffffffc02051c2:	40f9b7af          	amoor.d	a5,a5,(s3)
ffffffffc02051c6:	8b85                	andi	a5,a5,1
ffffffffc02051c8:	4d05                	li	s10,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02051ca:	c799                	beqz	a5,ffffffffc02051d8 <do_fork+0x2c2>
        schedule();
ffffffffc02051cc:	579000ef          	jal	ra,ffffffffc0205f44 <schedule>
ffffffffc02051d0:	41a9b7af          	amoor.d	a5,s10,(s3)
ffffffffc02051d4:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02051d6:	fbfd                	bnez	a5,ffffffffc02051cc <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc02051d8:	85e2                	mv	a1,s8
ffffffffc02051da:	856e                	mv	a0,s11
ffffffffc02051dc:	8d2ff0ef          	jal	ra,ffffffffc02042ae <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02051e0:	57f9                	li	a5,-2
ffffffffc02051e2:	60f9b7af          	amoand.d	a5,a5,(s3)
ffffffffc02051e6:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02051e8:	c3e9                	beqz	a5,ffffffffc02052aa <do_fork+0x394>
    if (ret != 0) {
ffffffffc02051ea:	8c6e                	mv	s8,s11
ffffffffc02051ec:	de0502e3          	beqz	a0,ffffffffc0204fd0 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02051f0:	856e                	mv	a0,s11
ffffffffc02051f2:	958ff0ef          	jal	ra,ffffffffc020434a <exit_mmap>
    put_pgdir(mm);
ffffffffc02051f6:	856e                	mv	a0,s11
ffffffffc02051f8:	b23ff0ef          	jal	ra,ffffffffc0204d1a <put_pgdir>
    mm_destroy(mm);
ffffffffc02051fc:	856e                	mv	a0,s11
ffffffffc02051fe:	fadfe0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205202:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205204:	c02007b7          	lui	a5,0xc0200
ffffffffc0205208:	0cf6e963          	bltu	a3,a5,ffffffffc02052da <do_fork+0x3c4>
ffffffffc020520c:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc0205210:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205214:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205218:	83b1                	srli	a5,a5,0xc
ffffffffc020521a:	0ae7f463          	bleu	a4,a5,ffffffffc02052c2 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc020521e:	000b3703          	ld	a4,0(s6)
ffffffffc0205222:	000ab503          	ld	a0,0(s5)
ffffffffc0205226:	4589                	li	a1,2
ffffffffc0205228:	8f99                	sub	a5,a5,a4
ffffffffc020522a:	079a                	slli	a5,a5,0x6
ffffffffc020522c:	953e                	add	a0,a0,a5
ffffffffc020522e:	cadfc0ef          	jal	ra,ffffffffc0201eda <free_pages>
    kfree(proc);
ffffffffc0205232:	8522                	mv	a0,s0
ffffffffc0205234:	adffc0ef          	jal	ra,ffffffffc0201d12 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205238:	5571                	li	a0,-4
    return ret;
ffffffffc020523a:	bdfd                	j	ffffffffc0205138 <do_fork+0x222>
        intr_enable();
ffffffffc020523c:	c18fb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205240:	bdc5                	j	ffffffffc0205130 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc0205242:	0117c363          	blt	a5,a7,ffffffffc0205248 <do_fork+0x332>
                        last_pid = 1;
ffffffffc0205246:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205248:	4585                	li	a1,1
ffffffffc020524a:	b591                	j	ffffffffc020508e <do_fork+0x178>
    mm_destroy(mm);
ffffffffc020524c:	856e                	mv	a0,s11
ffffffffc020524e:	f5dfe0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
ffffffffc0205252:	bf45                	j	ffffffffc0205202 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205254:	556d                	li	a0,-5
ffffffffc0205256:	b5cd                	j	ffffffffc0205138 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc0205258:	00002617          	auipc	a2,0x2
ffffffffc020525c:	0c860613          	addi	a2,a2,200 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0205260:	06900593          	li	a1,105
ffffffffc0205264:	00002517          	auipc	a0,0x2
ffffffffc0205268:	0e450513          	addi	a0,a0,228 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc020526c:	a18fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0205270:	00003697          	auipc	a3,0x3
ffffffffc0205274:	2e068693          	addi	a3,a3,736 # ffffffffc0208550 <default_pmm_manager+0x1280>
ffffffffc0205278:	00002617          	auipc	a2,0x2
ffffffffc020527c:	91060613          	addi	a2,a2,-1776 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205280:	1af00593          	li	a1,431
ffffffffc0205284:	00003517          	auipc	a0,0x3
ffffffffc0205288:	55c50513          	addi	a0,a0,1372 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc020528c:	9f8fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205290:	86be                	mv	a3,a5
ffffffffc0205292:	00002617          	auipc	a2,0x2
ffffffffc0205296:	0c660613          	addi	a2,a2,198 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc020529a:	16300593          	li	a1,355
ffffffffc020529e:	00003517          	auipc	a0,0x3
ffffffffc02052a2:	54250513          	addi	a0,a0,1346 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc02052a6:	9defb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("Unlock failed.\n");
ffffffffc02052aa:	00003617          	auipc	a2,0x3
ffffffffc02052ae:	2c660613          	addi	a2,a2,710 # ffffffffc0208570 <default_pmm_manager+0x12a0>
ffffffffc02052b2:	03100593          	li	a1,49
ffffffffc02052b6:	00003517          	auipc	a0,0x3
ffffffffc02052ba:	2ca50513          	addi	a0,a0,714 # ffffffffc0208580 <default_pmm_manager+0x12b0>
ffffffffc02052be:	9c6fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02052c2:	00002617          	auipc	a2,0x2
ffffffffc02052c6:	0be60613          	addi	a2,a2,190 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc02052ca:	06200593          	li	a1,98
ffffffffc02052ce:	00002517          	auipc	a0,0x2
ffffffffc02052d2:	07a50513          	addi	a0,a0,122 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc02052d6:	9aefb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02052da:	00002617          	auipc	a2,0x2
ffffffffc02052de:	07e60613          	addi	a2,a2,126 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc02052e2:	06e00593          	li	a1,110
ffffffffc02052e6:	00002517          	auipc	a0,0x2
ffffffffc02052ea:	06250513          	addi	a0,a0,98 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc02052ee:	996fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02052f2 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02052f2:	7129                	addi	sp,sp,-320
ffffffffc02052f4:	fa22                	sd	s0,304(sp)
ffffffffc02052f6:	f626                	sd	s1,296(sp)
ffffffffc02052f8:	f24a                	sd	s2,288(sp)
ffffffffc02052fa:	84ae                	mv	s1,a1
ffffffffc02052fc:	892a                	mv	s2,a0
ffffffffc02052fe:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205300:	4581                	li	a1,0
ffffffffc0205302:	12000613          	li	a2,288
ffffffffc0205306:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205308:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020530a:	25e010ef          	jal	ra,ffffffffc0206568 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020530e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205310:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205312:	100027f3          	csrr	a5,sstatus
ffffffffc0205316:	edd7f793          	andi	a5,a5,-291
ffffffffc020531a:	1207e793          	ori	a5,a5,288
ffffffffc020531e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205320:	860a                	mv	a2,sp
ffffffffc0205322:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205326:	00000797          	auipc	a5,0x0
ffffffffc020532a:	8e678793          	addi	a5,a5,-1818 # ffffffffc0204c0c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020532e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205330:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205332:	be5ff0ef          	jal	ra,ffffffffc0204f16 <do_fork>
}
ffffffffc0205336:	70f2                	ld	ra,312(sp)
ffffffffc0205338:	7452                	ld	s0,304(sp)
ffffffffc020533a:	74b2                	ld	s1,296(sp)
ffffffffc020533c:	7912                	ld	s2,288(sp)
ffffffffc020533e:	6131                	addi	sp,sp,320
ffffffffc0205340:	8082                	ret

ffffffffc0205342 <do_exit>:
do_exit(int error_code) {
ffffffffc0205342:	7179                	addi	sp,sp,-48
ffffffffc0205344:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205346:	000a7717          	auipc	a4,0xa7
ffffffffc020534a:	19270713          	addi	a4,a4,402 # ffffffffc02ac4d8 <idleproc>
ffffffffc020534e:	000a7917          	auipc	s2,0xa7
ffffffffc0205352:	18290913          	addi	s2,s2,386 # ffffffffc02ac4d0 <current>
ffffffffc0205356:	00093783          	ld	a5,0(s2)
ffffffffc020535a:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc020535c:	f406                	sd	ra,40(sp)
ffffffffc020535e:	f022                	sd	s0,32(sp)
ffffffffc0205360:	ec26                	sd	s1,24(sp)
ffffffffc0205362:	e44e                	sd	s3,8(sp)
ffffffffc0205364:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205366:	0ce78c63          	beq	a5,a4,ffffffffc020543e <do_exit+0xfc>
    if (current == initproc) {
ffffffffc020536a:	000a7417          	auipc	s0,0xa7
ffffffffc020536e:	17640413          	addi	s0,s0,374 # ffffffffc02ac4e0 <initproc>
ffffffffc0205372:	6018                	ld	a4,0(s0)
ffffffffc0205374:	0ee78b63          	beq	a5,a4,ffffffffc020546a <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205378:	7784                	ld	s1,40(a5)
ffffffffc020537a:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc020537c:	c48d                	beqz	s1,ffffffffc02053a6 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc020537e:	000a7797          	auipc	a5,0xa7
ffffffffc0205382:	1a278793          	addi	a5,a5,418 # ffffffffc02ac520 <boot_cr3>
ffffffffc0205386:	639c                	ld	a5,0(a5)
ffffffffc0205388:	577d                	li	a4,-1
ffffffffc020538a:	177e                	slli	a4,a4,0x3f
ffffffffc020538c:	83b1                	srli	a5,a5,0xc
ffffffffc020538e:	8fd9                	or	a5,a5,a4
ffffffffc0205390:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205394:	589c                	lw	a5,48(s1)
ffffffffc0205396:	fff7871b          	addiw	a4,a5,-1
ffffffffc020539a:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc020539c:	cf4d                	beqz	a4,ffffffffc0205456 <do_exit+0x114>
        current->mm = NULL;
ffffffffc020539e:	00093783          	ld	a5,0(s2)
ffffffffc02053a2:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02053a6:	00093783          	ld	a5,0(s2)
ffffffffc02053aa:	470d                	li	a4,3
ffffffffc02053ac:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02053ae:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053b2:	100027f3          	csrr	a5,sstatus
ffffffffc02053b6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02053b8:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053ba:	e7e1                	bnez	a5,ffffffffc0205482 <do_exit+0x140>
        proc = current->parent;
ffffffffc02053bc:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053c0:	800007b7          	lui	a5,0x80000
ffffffffc02053c4:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02053c6:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02053c8:	0ec52703          	lw	a4,236(a0)
ffffffffc02053cc:	0af70f63          	beq	a4,a5,ffffffffc020548a <do_exit+0x148>
ffffffffc02053d0:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053d4:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053d8:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02053da:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc02053dc:	7afc                	ld	a5,240(a3)
ffffffffc02053de:	cb95                	beqz	a5,ffffffffc0205412 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02053e0:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5680>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053e4:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02053e6:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053e8:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02053ea:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02053ee:	10e7b023          	sd	a4,256(a5)
ffffffffc02053f2:	c311                	beqz	a4,ffffffffc02053f6 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02053f4:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053f6:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02053f8:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02053fa:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02053fc:	fe9710e3          	bne	a4,s1,ffffffffc02053dc <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205400:	0ec52783          	lw	a5,236(a0)
ffffffffc0205404:	fd379ce3          	bne	a5,s3,ffffffffc02053dc <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205408:	2c1000ef          	jal	ra,ffffffffc0205ec8 <wakeup_proc>
ffffffffc020540c:	00093683          	ld	a3,0(s2)
ffffffffc0205410:	b7f1                	j	ffffffffc02053dc <do_exit+0x9a>
    if (flag) {
ffffffffc0205412:	020a1363          	bnez	s4,ffffffffc0205438 <do_exit+0xf6>
    schedule();
ffffffffc0205416:	32f000ef          	jal	ra,ffffffffc0205f44 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020541a:	00093783          	ld	a5,0(s2)
ffffffffc020541e:	00003617          	auipc	a2,0x3
ffffffffc0205422:	11260613          	addi	a2,a2,274 # ffffffffc0208530 <default_pmm_manager+0x1260>
ffffffffc0205426:	20400593          	li	a1,516
ffffffffc020542a:	43d4                	lw	a3,4(a5)
ffffffffc020542c:	00003517          	auipc	a0,0x3
ffffffffc0205430:	3b450513          	addi	a0,a0,948 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205434:	850fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_enable();
ffffffffc0205438:	a1cfb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc020543c:	bfe9                	j	ffffffffc0205416 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc020543e:	00003617          	auipc	a2,0x3
ffffffffc0205442:	0d260613          	addi	a2,a2,210 # ffffffffc0208510 <default_pmm_manager+0x1240>
ffffffffc0205446:	1d800593          	li	a1,472
ffffffffc020544a:	00003517          	auipc	a0,0x3
ffffffffc020544e:	39650513          	addi	a0,a0,918 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205452:	832fb0ef          	jal	ra,ffffffffc0200484 <__panic>
            exit_mmap(mm);
ffffffffc0205456:	8526                	mv	a0,s1
ffffffffc0205458:	ef3fe0ef          	jal	ra,ffffffffc020434a <exit_mmap>
            put_pgdir(mm);
ffffffffc020545c:	8526                	mv	a0,s1
ffffffffc020545e:	8bdff0ef          	jal	ra,ffffffffc0204d1a <put_pgdir>
            mm_destroy(mm);
ffffffffc0205462:	8526                	mv	a0,s1
ffffffffc0205464:	d47fe0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
ffffffffc0205468:	bf1d                	j	ffffffffc020539e <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020546a:	00003617          	auipc	a2,0x3
ffffffffc020546e:	0b660613          	addi	a2,a2,182 # ffffffffc0208520 <default_pmm_manager+0x1250>
ffffffffc0205472:	1db00593          	li	a1,475
ffffffffc0205476:	00003517          	auipc	a0,0x3
ffffffffc020547a:	36a50513          	addi	a0,a0,874 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc020547e:	806fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_disable();
ffffffffc0205482:	9d8fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205486:	4a05                	li	s4,1
ffffffffc0205488:	bf15                	j	ffffffffc02053bc <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc020548a:	23f000ef          	jal	ra,ffffffffc0205ec8 <wakeup_proc>
ffffffffc020548e:	b789                	j	ffffffffc02053d0 <do_exit+0x8e>

ffffffffc0205490 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205490:	7139                	addi	sp,sp,-64
ffffffffc0205492:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205494:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205498:	f426                	sd	s1,40(sp)
ffffffffc020549a:	f04a                	sd	s2,32(sp)
ffffffffc020549c:	ec4e                	sd	s3,24(sp)
ffffffffc020549e:	e456                	sd	s5,8(sp)
ffffffffc02054a0:	e05a                	sd	s6,0(sp)
ffffffffc02054a2:	fc06                	sd	ra,56(sp)
ffffffffc02054a4:	f822                	sd	s0,48(sp)
ffffffffc02054a6:	89aa                	mv	s3,a0
ffffffffc02054a8:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc02054aa:	000a7917          	auipc	s2,0xa7
ffffffffc02054ae:	02690913          	addi	s2,s2,38 # ffffffffc02ac4d0 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054b2:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02054b4:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02054b6:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc02054b8:	02098f63          	beqz	s3,ffffffffc02054f6 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02054bc:	854e                	mv	a0,s3
ffffffffc02054be:	9fdff0ef          	jal	ra,ffffffffc0204eba <find_proc>
ffffffffc02054c2:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02054c4:	12050063          	beqz	a0,ffffffffc02055e4 <do_wait.part.1+0x154>
ffffffffc02054c8:	00093703          	ld	a4,0(s2)
ffffffffc02054cc:	711c                	ld	a5,32(a0)
ffffffffc02054ce:	10e79b63          	bne	a5,a4,ffffffffc02055e4 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054d2:	411c                	lw	a5,0(a0)
ffffffffc02054d4:	02978c63          	beq	a5,s1,ffffffffc020550c <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02054d8:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02054dc:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02054e0:	265000ef          	jal	ra,ffffffffc0205f44 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02054e4:	00093783          	ld	a5,0(s2)
ffffffffc02054e8:	0b07a783          	lw	a5,176(a5)
ffffffffc02054ec:	8b85                	andi	a5,a5,1
ffffffffc02054ee:	d7e9                	beqz	a5,ffffffffc02054b8 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02054f0:	555d                	li	a0,-9
ffffffffc02054f2:	e51ff0ef          	jal	ra,ffffffffc0205342 <do_exit>
        proc = current->cptr;
ffffffffc02054f6:	00093703          	ld	a4,0(s2)
ffffffffc02054fa:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02054fc:	e409                	bnez	s0,ffffffffc0205506 <do_wait.part.1+0x76>
ffffffffc02054fe:	a0dd                	j	ffffffffc02055e4 <do_wait.part.1+0x154>
ffffffffc0205500:	10043403          	ld	s0,256(s0)
ffffffffc0205504:	d871                	beqz	s0,ffffffffc02054d8 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205506:	401c                	lw	a5,0(s0)
ffffffffc0205508:	fe979ce3          	bne	a5,s1,ffffffffc0205500 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc020550c:	000a7797          	auipc	a5,0xa7
ffffffffc0205510:	fcc78793          	addi	a5,a5,-52 # ffffffffc02ac4d8 <idleproc>
ffffffffc0205514:	639c                	ld	a5,0(a5)
ffffffffc0205516:	0c878d63          	beq	a5,s0,ffffffffc02055f0 <do_wait.part.1+0x160>
ffffffffc020551a:	000a7797          	auipc	a5,0xa7
ffffffffc020551e:	fc678793          	addi	a5,a5,-58 # ffffffffc02ac4e0 <initproc>
ffffffffc0205522:	639c                	ld	a5,0(a5)
ffffffffc0205524:	0cf40663          	beq	s0,a5,ffffffffc02055f0 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205528:	000b0663          	beqz	s6,ffffffffc0205534 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc020552c:	0e842783          	lw	a5,232(s0)
ffffffffc0205530:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205534:	100027f3          	csrr	a5,sstatus
ffffffffc0205538:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020553a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020553c:	e7d5                	bnez	a5,ffffffffc02055e8 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc020553e:	6c70                	ld	a2,216(s0)
ffffffffc0205540:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205542:	10043703          	ld	a4,256(s0)
ffffffffc0205546:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205548:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020554a:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020554c:	6470                	ld	a2,200(s0)
ffffffffc020554e:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205550:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205552:	e290                	sd	a2,0(a3)
ffffffffc0205554:	c319                	beqz	a4,ffffffffc020555a <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205556:	ff7c                	sd	a5,248(a4)
ffffffffc0205558:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc020555a:	c3d1                	beqz	a5,ffffffffc02055de <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc020555c:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205560:	000a7797          	auipc	a5,0xa7
ffffffffc0205564:	f8878793          	addi	a5,a5,-120 # ffffffffc02ac4e8 <nr_process>
ffffffffc0205568:	439c                	lw	a5,0(a5)
ffffffffc020556a:	37fd                	addiw	a5,a5,-1
ffffffffc020556c:	000a7717          	auipc	a4,0xa7
ffffffffc0205570:	f6f72e23          	sw	a5,-132(a4) # ffffffffc02ac4e8 <nr_process>
    if (flag) {
ffffffffc0205574:	e1b5                	bnez	a1,ffffffffc02055d8 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205576:	6814                	ld	a3,16(s0)
ffffffffc0205578:	c02007b7          	lui	a5,0xc0200
ffffffffc020557c:	0af6e263          	bltu	a3,a5,ffffffffc0205620 <do_wait.part.1+0x190>
ffffffffc0205580:	000a7797          	auipc	a5,0xa7
ffffffffc0205584:	f9878793          	addi	a5,a5,-104 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0205588:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020558a:	000a7797          	auipc	a5,0xa7
ffffffffc020558e:	f2e78793          	addi	a5,a5,-210 # ffffffffc02ac4b8 <npage>
ffffffffc0205592:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205594:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205596:	82b1                	srli	a3,a3,0xc
ffffffffc0205598:	06f6f863          	bleu	a5,a3,ffffffffc0205608 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc020559c:	00003797          	auipc	a5,0x3
ffffffffc02055a0:	70c78793          	addi	a5,a5,1804 # ffffffffc0208ca8 <nbase>
ffffffffc02055a4:	639c                	ld	a5,0(a5)
ffffffffc02055a6:	000a7717          	auipc	a4,0xa7
ffffffffc02055aa:	f8270713          	addi	a4,a4,-126 # ffffffffc02ac528 <pages>
ffffffffc02055ae:	6308                	ld	a0,0(a4)
ffffffffc02055b0:	8e9d                	sub	a3,a3,a5
ffffffffc02055b2:	069a                	slli	a3,a3,0x6
ffffffffc02055b4:	9536                	add	a0,a0,a3
ffffffffc02055b6:	4589                	li	a1,2
ffffffffc02055b8:	923fc0ef          	jal	ra,ffffffffc0201eda <free_pages>
    kfree(proc);
ffffffffc02055bc:	8522                	mv	a0,s0
ffffffffc02055be:	f54fc0ef          	jal	ra,ffffffffc0201d12 <kfree>
    return 0;
ffffffffc02055c2:	4501                	li	a0,0
}
ffffffffc02055c4:	70e2                	ld	ra,56(sp)
ffffffffc02055c6:	7442                	ld	s0,48(sp)
ffffffffc02055c8:	74a2                	ld	s1,40(sp)
ffffffffc02055ca:	7902                	ld	s2,32(sp)
ffffffffc02055cc:	69e2                	ld	s3,24(sp)
ffffffffc02055ce:	6a42                	ld	s4,16(sp)
ffffffffc02055d0:	6aa2                	ld	s5,8(sp)
ffffffffc02055d2:	6b02                	ld	s6,0(sp)
ffffffffc02055d4:	6121                	addi	sp,sp,64
ffffffffc02055d6:	8082                	ret
        intr_enable();
ffffffffc02055d8:	87cfb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc02055dc:	bf69                	j	ffffffffc0205576 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc02055de:	701c                	ld	a5,32(s0)
ffffffffc02055e0:	fbf8                	sd	a4,240(a5)
ffffffffc02055e2:	bfbd                	j	ffffffffc0205560 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02055e4:	5579                	li	a0,-2
ffffffffc02055e6:	bff9                	j	ffffffffc02055c4 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02055e8:	872fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc02055ec:	4585                	li	a1,1
ffffffffc02055ee:	bf81                	j	ffffffffc020553e <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02055f0:	00003617          	auipc	a2,0x3
ffffffffc02055f4:	fa860613          	addi	a2,a2,-88 # ffffffffc0208598 <default_pmm_manager+0x12c8>
ffffffffc02055f8:	2fb00593          	li	a1,763
ffffffffc02055fc:	00003517          	auipc	a0,0x3
ffffffffc0205600:	1e450513          	addi	a0,a0,484 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205604:	e81fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205608:	00002617          	auipc	a2,0x2
ffffffffc020560c:	d7860613          	addi	a2,a2,-648 # ffffffffc0207380 <default_pmm_manager+0xb0>
ffffffffc0205610:	06200593          	li	a1,98
ffffffffc0205614:	00002517          	auipc	a0,0x2
ffffffffc0205618:	d3450513          	addi	a0,a0,-716 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc020561c:	e69fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205620:	00002617          	auipc	a2,0x2
ffffffffc0205624:	d3860613          	addi	a2,a2,-712 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc0205628:	06e00593          	li	a1,110
ffffffffc020562c:	00002517          	auipc	a0,0x2
ffffffffc0205630:	d1c50513          	addi	a0,a0,-740 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0205634:	e51fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205638 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205638:	1141                	addi	sp,sp,-16
ffffffffc020563a:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020563c:	8e5fc0ef          	jal	ra,ffffffffc0201f20 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205640:	e12fc0ef          	jal	ra,ffffffffc0201c52 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205644:	4601                	li	a2,0
ffffffffc0205646:	4581                	li	a1,0
ffffffffc0205648:	fffff517          	auipc	a0,0xfffff
ffffffffc020564c:	65050513          	addi	a0,a0,1616 # ffffffffc0204c98 <user_main>
ffffffffc0205650:	ca3ff0ef          	jal	ra,ffffffffc02052f2 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205654:	00a04563          	bgtz	a0,ffffffffc020565e <init_main+0x26>
ffffffffc0205658:	a841                	j	ffffffffc02056e8 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc020565a:	0eb000ef          	jal	ra,ffffffffc0205f44 <schedule>
    if (code_store != NULL) {
ffffffffc020565e:	4581                	li	a1,0
ffffffffc0205660:	4501                	li	a0,0
ffffffffc0205662:	e2fff0ef          	jal	ra,ffffffffc0205490 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205666:	d975                	beqz	a0,ffffffffc020565a <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205668:	00003517          	auipc	a0,0x3
ffffffffc020566c:	f7050513          	addi	a0,a0,-144 # ffffffffc02085d8 <default_pmm_manager+0x1308>
ffffffffc0205670:	b1ffa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205674:	000a7797          	auipc	a5,0xa7
ffffffffc0205678:	e6c78793          	addi	a5,a5,-404 # ffffffffc02ac4e0 <initproc>
ffffffffc020567c:	639c                	ld	a5,0(a5)
ffffffffc020567e:	7bf8                	ld	a4,240(a5)
ffffffffc0205680:	e721                	bnez	a4,ffffffffc02056c8 <init_main+0x90>
ffffffffc0205682:	7ff8                	ld	a4,248(a5)
ffffffffc0205684:	e331                	bnez	a4,ffffffffc02056c8 <init_main+0x90>
ffffffffc0205686:	1007b703          	ld	a4,256(a5)
ffffffffc020568a:	ef1d                	bnez	a4,ffffffffc02056c8 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc020568c:	000a7717          	auipc	a4,0xa7
ffffffffc0205690:	e5c70713          	addi	a4,a4,-420 # ffffffffc02ac4e8 <nr_process>
ffffffffc0205694:	4314                	lw	a3,0(a4)
ffffffffc0205696:	4709                	li	a4,2
ffffffffc0205698:	0ae69463          	bne	a3,a4,ffffffffc0205740 <init_main+0x108>
    return listelm->next;
ffffffffc020569c:	000a7697          	auipc	a3,0xa7
ffffffffc02056a0:	f7468693          	addi	a3,a3,-140 # ffffffffc02ac610 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02056a4:	6698                	ld	a4,8(a3)
ffffffffc02056a6:	0c878793          	addi	a5,a5,200
ffffffffc02056aa:	06f71b63          	bne	a4,a5,ffffffffc0205720 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02056ae:	629c                	ld	a5,0(a3)
ffffffffc02056b0:	04f71863          	bne	a4,a5,ffffffffc0205700 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02056b4:	00003517          	auipc	a0,0x3
ffffffffc02056b8:	00c50513          	addi	a0,a0,12 # ffffffffc02086c0 <default_pmm_manager+0x13f0>
ffffffffc02056bc:	ad3fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02056c0:	60a2                	ld	ra,8(sp)
ffffffffc02056c2:	4501                	li	a0,0
ffffffffc02056c4:	0141                	addi	sp,sp,16
ffffffffc02056c6:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056c8:	00003697          	auipc	a3,0x3
ffffffffc02056cc:	f3868693          	addi	a3,a3,-200 # ffffffffc0208600 <default_pmm_manager+0x1330>
ffffffffc02056d0:	00001617          	auipc	a2,0x1
ffffffffc02056d4:	4b860613          	addi	a2,a2,1208 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc02056d8:	36000593          	li	a1,864
ffffffffc02056dc:	00003517          	auipc	a0,0x3
ffffffffc02056e0:	10450513          	addi	a0,a0,260 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc02056e4:	da1fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create user_main failed.\n");
ffffffffc02056e8:	00003617          	auipc	a2,0x3
ffffffffc02056ec:	ed060613          	addi	a2,a2,-304 # ffffffffc02085b8 <default_pmm_manager+0x12e8>
ffffffffc02056f0:	35800593          	li	a1,856
ffffffffc02056f4:	00003517          	auipc	a0,0x3
ffffffffc02056f8:	0ec50513          	addi	a0,a0,236 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc02056fc:	d89fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205700:	00003697          	auipc	a3,0x3
ffffffffc0205704:	f9068693          	addi	a3,a3,-112 # ffffffffc0208690 <default_pmm_manager+0x13c0>
ffffffffc0205708:	00001617          	auipc	a2,0x1
ffffffffc020570c:	48060613          	addi	a2,a2,1152 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205710:	36300593          	li	a1,867
ffffffffc0205714:	00003517          	auipc	a0,0x3
ffffffffc0205718:	0cc50513          	addi	a0,a0,204 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc020571c:	d69fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205720:	00003697          	auipc	a3,0x3
ffffffffc0205724:	f4068693          	addi	a3,a3,-192 # ffffffffc0208660 <default_pmm_manager+0x1390>
ffffffffc0205728:	00001617          	auipc	a2,0x1
ffffffffc020572c:	46060613          	addi	a2,a2,1120 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205730:	36200593          	li	a1,866
ffffffffc0205734:	00003517          	auipc	a0,0x3
ffffffffc0205738:	0ac50513          	addi	a0,a0,172 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc020573c:	d49fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_process == 2);
ffffffffc0205740:	00003697          	auipc	a3,0x3
ffffffffc0205744:	f1068693          	addi	a3,a3,-240 # ffffffffc0208650 <default_pmm_manager+0x1380>
ffffffffc0205748:	00001617          	auipc	a2,0x1
ffffffffc020574c:	44060613          	addi	a2,a2,1088 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205750:	36100593          	li	a1,865
ffffffffc0205754:	00003517          	auipc	a0,0x3
ffffffffc0205758:	08c50513          	addi	a0,a0,140 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc020575c:	d29fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205760 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205760:	7135                	addi	sp,sp,-160
ffffffffc0205762:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205764:	000a7a17          	auipc	s4,0xa7
ffffffffc0205768:	d6ca0a13          	addi	s4,s4,-660 # ffffffffc02ac4d0 <current>
ffffffffc020576c:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205770:	e14a                	sd	s2,128(sp)
ffffffffc0205772:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205774:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205778:	fcce                	sd	s3,120(sp)
ffffffffc020577a:	f0da                	sd	s6,96(sp)
ffffffffc020577c:	89aa                	mv	s3,a0
ffffffffc020577e:	842e                	mv	s0,a1
ffffffffc0205780:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205782:	4681                	li	a3,0
ffffffffc0205784:	862e                	mv	a2,a1
ffffffffc0205786:	85aa                	mv	a1,a0
ffffffffc0205788:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020578a:	ed06                	sd	ra,152(sp)
ffffffffc020578c:	e526                	sd	s1,136(sp)
ffffffffc020578e:	f4d6                	sd	s5,104(sp)
ffffffffc0205790:	ecde                	sd	s7,88(sp)
ffffffffc0205792:	e8e2                	sd	s8,80(sp)
ffffffffc0205794:	e4e6                	sd	s9,72(sp)
ffffffffc0205796:	e0ea                	sd	s10,64(sp)
ffffffffc0205798:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020579a:	a76ff0ef          	jal	ra,ffffffffc0204a10 <user_mem_check>
ffffffffc020579e:	40050463          	beqz	a0,ffffffffc0205ba6 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02057a2:	4641                	li	a2,16
ffffffffc02057a4:	4581                	li	a1,0
ffffffffc02057a6:	1008                	addi	a0,sp,32
ffffffffc02057a8:	5c1000ef          	jal	ra,ffffffffc0206568 <memset>
    memcpy(local_name, name, len);
ffffffffc02057ac:	47bd                	li	a5,15
ffffffffc02057ae:	8622                	mv	a2,s0
ffffffffc02057b0:	0687ee63          	bltu	a5,s0,ffffffffc020582c <do_execve+0xcc>
ffffffffc02057b4:	85ce                	mv	a1,s3
ffffffffc02057b6:	1008                	addi	a0,sp,32
ffffffffc02057b8:	5c3000ef          	jal	ra,ffffffffc020657a <memcpy>
    if (mm != NULL) {
ffffffffc02057bc:	06090f63          	beqz	s2,ffffffffc020583a <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc02057c0:	00002517          	auipc	a0,0x2
ffffffffc02057c4:	2f050513          	addi	a0,a0,752 # ffffffffc0207ab0 <default_pmm_manager+0x7e0>
ffffffffc02057c8:	9fffa0ef          	jal	ra,ffffffffc02001c6 <cputs>
        lcr3(boot_cr3);
ffffffffc02057cc:	000a7797          	auipc	a5,0xa7
ffffffffc02057d0:	d5478793          	addi	a5,a5,-684 # ffffffffc02ac520 <boot_cr3>
ffffffffc02057d4:	639c                	ld	a5,0(a5)
ffffffffc02057d6:	577d                	li	a4,-1
ffffffffc02057d8:	177e                	slli	a4,a4,0x3f
ffffffffc02057da:	83b1                	srli	a5,a5,0xc
ffffffffc02057dc:	8fd9                	or	a5,a5,a4
ffffffffc02057de:	18079073          	csrw	satp,a5
ffffffffc02057e2:	03092783          	lw	a5,48(s2)
ffffffffc02057e6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02057ea:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc02057ee:	28070b63          	beqz	a4,ffffffffc0205a84 <do_execve+0x324>
        current->mm = NULL;
ffffffffc02057f2:	000a3783          	ld	a5,0(s4)
ffffffffc02057f6:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02057fa:	82bfe0ef          	jal	ra,ffffffffc0204024 <mm_create>
ffffffffc02057fe:	892a                	mv	s2,a0
ffffffffc0205800:	c135                	beqz	a0,ffffffffc0205864 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205802:	d96ff0ef          	jal	ra,ffffffffc0204d98 <setup_pgdir>
ffffffffc0205806:	e931                	bnez	a0,ffffffffc020585a <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205808:	000b2703          	lw	a4,0(s6)
ffffffffc020580c:	464c47b7          	lui	a5,0x464c4
ffffffffc0205810:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aff>
ffffffffc0205814:	04f70a63          	beq	a4,a5,ffffffffc0205868 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205818:	854a                	mv	a0,s2
ffffffffc020581a:	d00ff0ef          	jal	ra,ffffffffc0204d1a <put_pgdir>
    mm_destroy(mm);
ffffffffc020581e:	854a                	mv	a0,s2
ffffffffc0205820:	98bfe0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205824:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc0205826:	854e                	mv	a0,s3
ffffffffc0205828:	b1bff0ef          	jal	ra,ffffffffc0205342 <do_exit>
    memcpy(local_name, name, len);
ffffffffc020582c:	463d                	li	a2,15
ffffffffc020582e:	85ce                	mv	a1,s3
ffffffffc0205830:	1008                	addi	a0,sp,32
ffffffffc0205832:	549000ef          	jal	ra,ffffffffc020657a <memcpy>
    if (mm != NULL) {
ffffffffc0205836:	f80915e3          	bnez	s2,ffffffffc02057c0 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc020583a:	000a3783          	ld	a5,0(s4)
ffffffffc020583e:	779c                	ld	a5,40(a5)
ffffffffc0205840:	dfcd                	beqz	a5,ffffffffc02057fa <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205842:	00003617          	auipc	a2,0x3
ffffffffc0205846:	b4660613          	addi	a2,a2,-1210 # ffffffffc0208388 <default_pmm_manager+0x10b8>
ffffffffc020584a:	20e00593          	li	a1,526
ffffffffc020584e:	00003517          	auipc	a0,0x3
ffffffffc0205852:	f9250513          	addi	a0,a0,-110 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205856:	c2ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
    mm_destroy(mm);
ffffffffc020585a:	854a                	mv	a0,s2
ffffffffc020585c:	94ffe0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205860:	59f1                	li	s3,-4
ffffffffc0205862:	b7d1                	j	ffffffffc0205826 <do_execve+0xc6>
ffffffffc0205864:	59f1                	li	s3,-4
ffffffffc0205866:	b7c1                	j	ffffffffc0205826 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205868:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020586c:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205870:	00371793          	slli	a5,a4,0x3
ffffffffc0205874:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205876:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205878:	078e                	slli	a5,a5,0x3
ffffffffc020587a:	97a2                	add	a5,a5,s0
ffffffffc020587c:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020587e:	02f47b63          	bleu	a5,s0,ffffffffc02058b4 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205882:	5bfd                	li	s7,-1
ffffffffc0205884:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc0205888:	000a7d97          	auipc	s11,0xa7
ffffffffc020588c:	ca0d8d93          	addi	s11,s11,-864 # ffffffffc02ac528 <pages>
ffffffffc0205890:	00003d17          	auipc	s10,0x3
ffffffffc0205894:	418d0d13          	addi	s10,s10,1048 # ffffffffc0208ca8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205898:	e43e                	sd	a5,8(sp)
ffffffffc020589a:	000a7c97          	auipc	s9,0xa7
ffffffffc020589e:	c1ec8c93          	addi	s9,s9,-994 # ffffffffc02ac4b8 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02058a2:	4018                	lw	a4,0(s0)
ffffffffc02058a4:	4785                	li	a5,1
ffffffffc02058a6:	0ef70d63          	beq	a4,a5,ffffffffc02059a0 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc02058aa:	67e2                	ld	a5,24(sp)
ffffffffc02058ac:	03840413          	addi	s0,s0,56
ffffffffc02058b0:	fef469e3          	bltu	s0,a5,ffffffffc02058a2 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02058b4:	4701                	li	a4,0
ffffffffc02058b6:	46ad                	li	a3,11
ffffffffc02058b8:	00100637          	lui	a2,0x100
ffffffffc02058bc:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02058c0:	854a                	mv	a0,s2
ffffffffc02058c2:	93bfe0ef          	jal	ra,ffffffffc02041fc <mm_map>
ffffffffc02058c6:	89aa                	mv	s3,a0
ffffffffc02058c8:	1a051463          	bnez	a0,ffffffffc0205a70 <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02058cc:	01893503          	ld	a0,24(s2)
ffffffffc02058d0:	467d                	li	a2,31
ffffffffc02058d2:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02058d6:	981fd0ef          	jal	ra,ffffffffc0203256 <pgdir_alloc_page>
ffffffffc02058da:	36050263          	beqz	a0,ffffffffc0205c3e <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02058de:	01893503          	ld	a0,24(s2)
ffffffffc02058e2:	467d                	li	a2,31
ffffffffc02058e4:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02058e8:	96ffd0ef          	jal	ra,ffffffffc0203256 <pgdir_alloc_page>
ffffffffc02058ec:	32050963          	beqz	a0,ffffffffc0205c1e <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02058f0:	01893503          	ld	a0,24(s2)
ffffffffc02058f4:	467d                	li	a2,31
ffffffffc02058f6:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02058fa:	95dfd0ef          	jal	ra,ffffffffc0203256 <pgdir_alloc_page>
ffffffffc02058fe:	30050063          	beqz	a0,ffffffffc0205bfe <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205902:	01893503          	ld	a0,24(s2)
ffffffffc0205906:	467d                	li	a2,31
ffffffffc0205908:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc020590c:	94bfd0ef          	jal	ra,ffffffffc0203256 <pgdir_alloc_page>
ffffffffc0205910:	2c050763          	beqz	a0,ffffffffc0205bde <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc0205914:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205918:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020591c:	01893683          	ld	a3,24(s2)
ffffffffc0205920:	2785                	addiw	a5,a5,1
ffffffffc0205922:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0205926:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf55a8>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020592a:	c02007b7          	lui	a5,0xc0200
ffffffffc020592e:	28f6ec63          	bltu	a3,a5,ffffffffc0205bc6 <do_execve+0x466>
ffffffffc0205932:	000a7797          	auipc	a5,0xa7
ffffffffc0205936:	be678793          	addi	a5,a5,-1050 # ffffffffc02ac518 <va_pa_offset>
ffffffffc020593a:	639c                	ld	a5,0(a5)
ffffffffc020593c:	577d                	li	a4,-1
ffffffffc020593e:	177e                	slli	a4,a4,0x3f
ffffffffc0205940:	8e9d                	sub	a3,a3,a5
ffffffffc0205942:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205946:	f654                	sd	a3,168(a2)
ffffffffc0205948:	8fd9                	or	a5,a5,a4
ffffffffc020594a:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc020594e:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205950:	4581                	li	a1,0
ffffffffc0205952:	12000613          	li	a2,288
ffffffffc0205956:	8522                	mv	a0,s0
ffffffffc0205958:	411000ef          	jal	ra,ffffffffc0206568 <memset>
    tf->epc=elf->e_entry;
ffffffffc020595c:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp=USTACKTOP;
ffffffffc0205960:	4785                	li	a5,1
ffffffffc0205962:	07fe                	slli	a5,a5,0x1f
ffffffffc0205964:	e81c                	sd	a5,16(s0)
    tf->epc=elf->e_entry;
ffffffffc0205966:	10e43423          	sd	a4,264(s0)
    tf->status=(read_csr(sstatus)&~SSTATUS_SPP&~SSTATUS_SPIE);
ffffffffc020596a:	100027f3          	csrr	a5,sstatus
    set_proc_name(current, local_name);
ffffffffc020596e:	000a3503          	ld	a0,0(s4)
    tf->status=(read_csr(sstatus)&~SSTATUS_SPP&~SSTATUS_SPIE);
ffffffffc0205972:	edf7f793          	andi	a5,a5,-289
ffffffffc0205976:	10f43023          	sd	a5,256(s0)
    set_proc_name(current, local_name);
ffffffffc020597a:	100c                	addi	a1,sp,32
ffffffffc020597c:	ca8ff0ef          	jal	ra,ffffffffc0204e24 <set_proc_name>
}
ffffffffc0205980:	60ea                	ld	ra,152(sp)
ffffffffc0205982:	644a                	ld	s0,144(sp)
ffffffffc0205984:	854e                	mv	a0,s3
ffffffffc0205986:	64aa                	ld	s1,136(sp)
ffffffffc0205988:	690a                	ld	s2,128(sp)
ffffffffc020598a:	79e6                	ld	s3,120(sp)
ffffffffc020598c:	7a46                	ld	s4,112(sp)
ffffffffc020598e:	7aa6                	ld	s5,104(sp)
ffffffffc0205990:	7b06                	ld	s6,96(sp)
ffffffffc0205992:	6be6                	ld	s7,88(sp)
ffffffffc0205994:	6c46                	ld	s8,80(sp)
ffffffffc0205996:	6ca6                	ld	s9,72(sp)
ffffffffc0205998:	6d06                	ld	s10,64(sp)
ffffffffc020599a:	7de2                	ld	s11,56(sp)
ffffffffc020599c:	610d                	addi	sp,sp,160
ffffffffc020599e:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02059a0:	7410                	ld	a2,40(s0)
ffffffffc02059a2:	701c                	ld	a5,32(s0)
ffffffffc02059a4:	20f66363          	bltu	a2,a5,ffffffffc0205baa <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02059a8:	405c                	lw	a5,4(s0)
ffffffffc02059aa:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059ae:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02059b2:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02059b4:	0e071263          	bnez	a4,ffffffffc0205a98 <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc02059b8:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059ba:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc02059bc:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059be:	c789                	beqz	a5,ffffffffc02059c8 <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc02059c0:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02059c2:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc02059c6:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02059c8:	0026f793          	andi	a5,a3,2
ffffffffc02059cc:	efe1                	bnez	a5,ffffffffc0205aa4 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc02059ce:	0046f793          	andi	a5,a3,4
ffffffffc02059d2:	c789                	beqz	a5,ffffffffc02059dc <do_execve+0x27c>
ffffffffc02059d4:	6782                	ld	a5,0(sp)
ffffffffc02059d6:	0087e793          	ori	a5,a5,8
ffffffffc02059da:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc02059dc:	680c                	ld	a1,16(s0)
ffffffffc02059de:	4701                	li	a4,0
ffffffffc02059e0:	854a                	mv	a0,s2
ffffffffc02059e2:	81bfe0ef          	jal	ra,ffffffffc02041fc <mm_map>
ffffffffc02059e6:	89aa                	mv	s3,a0
ffffffffc02059e8:	e541                	bnez	a0,ffffffffc0205a70 <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02059ea:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc02059ee:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02059f2:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02059f6:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02059f8:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc02059fa:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02059fc:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205a00:	053bef63          	bltu	s7,s3,ffffffffc0205a5e <do_execve+0x2fe>
ffffffffc0205a04:	aa79                	j	ffffffffc0205ba2 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a06:	6785                	lui	a5,0x1
ffffffffc0205a08:	418b8533          	sub	a0,s7,s8
ffffffffc0205a0c:	9c3e                	add	s8,s8,a5
ffffffffc0205a0e:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205a12:	0189f463          	bleu	s8,s3,ffffffffc0205a1a <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205a16:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205a1a:	000db683          	ld	a3,0(s11)
ffffffffc0205a1e:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205a22:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205a24:	40d486b3          	sub	a3,s1,a3
ffffffffc0205a28:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205a2a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205a2e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205a30:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a34:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a36:	16c5fc63          	bleu	a2,a1,ffffffffc0205bae <do_execve+0x44e>
ffffffffc0205a3a:	000a7797          	auipc	a5,0xa7
ffffffffc0205a3e:	ade78793          	addi	a5,a5,-1314 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0205a42:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a46:	85d6                	mv	a1,s5
ffffffffc0205a48:	8642                	mv	a2,a6
ffffffffc0205a4a:	96c6                	add	a3,a3,a7
ffffffffc0205a4c:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205a4e:	9bc2                	add	s7,s7,a6
ffffffffc0205a50:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a52:	329000ef          	jal	ra,ffffffffc020657a <memcpy>
            start += size, from += size;
ffffffffc0205a56:	6842                	ld	a6,16(sp)
ffffffffc0205a58:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205a5a:	053bf863          	bleu	s3,s7,ffffffffc0205aaa <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a5e:	01893503          	ld	a0,24(s2)
ffffffffc0205a62:	6602                	ld	a2,0(sp)
ffffffffc0205a64:	85e2                	mv	a1,s8
ffffffffc0205a66:	ff0fd0ef          	jal	ra,ffffffffc0203256 <pgdir_alloc_page>
ffffffffc0205a6a:	84aa                	mv	s1,a0
ffffffffc0205a6c:	fd49                	bnez	a0,ffffffffc0205a06 <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205a6e:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205a70:	854a                	mv	a0,s2
ffffffffc0205a72:	8d9fe0ef          	jal	ra,ffffffffc020434a <exit_mmap>
    put_pgdir(mm);
ffffffffc0205a76:	854a                	mv	a0,s2
ffffffffc0205a78:	aa2ff0ef          	jal	ra,ffffffffc0204d1a <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a7c:	854a                	mv	a0,s2
ffffffffc0205a7e:	f2cfe0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
    return ret;
ffffffffc0205a82:	b355                	j	ffffffffc0205826 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205a84:	854a                	mv	a0,s2
ffffffffc0205a86:	8c5fe0ef          	jal	ra,ffffffffc020434a <exit_mmap>
            put_pgdir(mm);
ffffffffc0205a8a:	854a                	mv	a0,s2
ffffffffc0205a8c:	a8eff0ef          	jal	ra,ffffffffc0204d1a <put_pgdir>
            mm_destroy(mm);
ffffffffc0205a90:	854a                	mv	a0,s2
ffffffffc0205a92:	f18fe0ef          	jal	ra,ffffffffc02041aa <mm_destroy>
ffffffffc0205a96:	bbb1                	j	ffffffffc02057f2 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a98:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a9c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a9e:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205aa0:	f20790e3          	bnez	a5,ffffffffc02059c0 <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205aa4:	47dd                	li	a5,23
ffffffffc0205aa6:	e03e                	sd	a5,0(sp)
ffffffffc0205aa8:	b71d                	j	ffffffffc02059ce <do_execve+0x26e>
ffffffffc0205aaa:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205aae:	7414                	ld	a3,40(s0)
ffffffffc0205ab0:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205ab2:	098bf163          	bleu	s8,s7,ffffffffc0205b34 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205ab6:	df798ae3          	beq	s3,s7,ffffffffc02058aa <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205aba:	6505                	lui	a0,0x1
ffffffffc0205abc:	955e                	add	a0,a0,s7
ffffffffc0205abe:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205ac2:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205ac6:	0d89fb63          	bleu	s8,s3,ffffffffc0205b9c <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205aca:	000db683          	ld	a3,0(s11)
ffffffffc0205ace:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ad2:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ad4:	40d486b3          	sub	a3,s1,a3
ffffffffc0205ad8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205ada:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ade:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205ae0:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ae4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205ae6:	0cc5f463          	bleu	a2,a1,ffffffffc0205bae <do_execve+0x44e>
ffffffffc0205aea:	000a7617          	auipc	a2,0xa7
ffffffffc0205aee:	a2e60613          	addi	a2,a2,-1490 # ffffffffc02ac518 <va_pa_offset>
ffffffffc0205af2:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205af6:	4581                	li	a1,0
ffffffffc0205af8:	8656                	mv	a2,s5
ffffffffc0205afa:	96c2                	add	a3,a3,a6
ffffffffc0205afc:	9536                	add	a0,a0,a3
ffffffffc0205afe:	26b000ef          	jal	ra,ffffffffc0206568 <memset>
            start += size;
ffffffffc0205b02:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b06:	0389f463          	bleu	s8,s3,ffffffffc0205b2e <do_execve+0x3ce>
ffffffffc0205b0a:	dae980e3          	beq	s3,a4,ffffffffc02058aa <do_execve+0x14a>
ffffffffc0205b0e:	00003697          	auipc	a3,0x3
ffffffffc0205b12:	8a268693          	addi	a3,a3,-1886 # ffffffffc02083b0 <default_pmm_manager+0x10e0>
ffffffffc0205b16:	00001617          	auipc	a2,0x1
ffffffffc0205b1a:	07260613          	addi	a2,a2,114 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205b1e:	26300593          	li	a1,611
ffffffffc0205b22:	00003517          	auipc	a0,0x3
ffffffffc0205b26:	cbe50513          	addi	a0,a0,-834 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205b2a:	95bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0205b2e:	ff8710e3          	bne	a4,s8,ffffffffc0205b0e <do_execve+0x3ae>
ffffffffc0205b32:	8be2                	mv	s7,s8
ffffffffc0205b34:	000a7a97          	auipc	s5,0xa7
ffffffffc0205b38:	9e4a8a93          	addi	s5,s5,-1564 # ffffffffc02ac518 <va_pa_offset>
        while (start < end) {
ffffffffc0205b3c:	053be763          	bltu	s7,s3,ffffffffc0205b8a <do_execve+0x42a>
ffffffffc0205b40:	b3ad                	j	ffffffffc02058aa <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b42:	6785                	lui	a5,0x1
ffffffffc0205b44:	418b8533          	sub	a0,s7,s8
ffffffffc0205b48:	9c3e                	add	s8,s8,a5
ffffffffc0205b4a:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205b4e:	0189f463          	bleu	s8,s3,ffffffffc0205b56 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205b52:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205b56:	000db683          	ld	a3,0(s11)
ffffffffc0205b5a:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b5e:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b60:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b64:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b66:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205b6a:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205b6c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b70:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b72:	02b87e63          	bleu	a1,a6,ffffffffc0205bae <do_execve+0x44e>
ffffffffc0205b76:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205b7a:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b7c:	4581                	li	a1,0
ffffffffc0205b7e:	96c2                	add	a3,a3,a6
ffffffffc0205b80:	9536                	add	a0,a0,a3
ffffffffc0205b82:	1e7000ef          	jal	ra,ffffffffc0206568 <memset>
        while (start < end) {
ffffffffc0205b86:	d33bf2e3          	bleu	s3,s7,ffffffffc02058aa <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b8a:	01893503          	ld	a0,24(s2)
ffffffffc0205b8e:	6602                	ld	a2,0(sp)
ffffffffc0205b90:	85e2                	mv	a1,s8
ffffffffc0205b92:	ec4fd0ef          	jal	ra,ffffffffc0203256 <pgdir_alloc_page>
ffffffffc0205b96:	84aa                	mv	s1,a0
ffffffffc0205b98:	f54d                	bnez	a0,ffffffffc0205b42 <do_execve+0x3e2>
ffffffffc0205b9a:	bdd1                	j	ffffffffc0205a6e <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b9c:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205ba0:	b72d                	j	ffffffffc0205aca <do_execve+0x36a>
        while (start < end) {
ffffffffc0205ba2:	89de                	mv	s3,s7
ffffffffc0205ba4:	b729                	j	ffffffffc0205aae <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205ba6:	59f5                	li	s3,-3
ffffffffc0205ba8:	bbe1                	j	ffffffffc0205980 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205baa:	59e1                	li	s3,-8
ffffffffc0205bac:	b5d1                	j	ffffffffc0205a70 <do_execve+0x310>
ffffffffc0205bae:	00001617          	auipc	a2,0x1
ffffffffc0205bb2:	77260613          	addi	a2,a2,1906 # ffffffffc0207320 <default_pmm_manager+0x50>
ffffffffc0205bb6:	06900593          	li	a1,105
ffffffffc0205bba:	00001517          	auipc	a0,0x1
ffffffffc0205bbe:	78e50513          	addi	a0,a0,1934 # ffffffffc0207348 <default_pmm_manager+0x78>
ffffffffc0205bc2:	8c3fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205bc6:	00001617          	auipc	a2,0x1
ffffffffc0205bca:	79260613          	addi	a2,a2,1938 # ffffffffc0207358 <default_pmm_manager+0x88>
ffffffffc0205bce:	27e00593          	li	a1,638
ffffffffc0205bd2:	00003517          	auipc	a0,0x3
ffffffffc0205bd6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205bda:	8abfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bde:	00003697          	auipc	a3,0x3
ffffffffc0205be2:	8ea68693          	addi	a3,a3,-1814 # ffffffffc02084c8 <default_pmm_manager+0x11f8>
ffffffffc0205be6:	00001617          	auipc	a2,0x1
ffffffffc0205bea:	fa260613          	addi	a2,a2,-94 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205bee:	27900593          	li	a1,633
ffffffffc0205bf2:	00003517          	auipc	a0,0x3
ffffffffc0205bf6:	bee50513          	addi	a0,a0,-1042 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205bfa:	88bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bfe:	00003697          	auipc	a3,0x3
ffffffffc0205c02:	88268693          	addi	a3,a3,-1918 # ffffffffc0208480 <default_pmm_manager+0x11b0>
ffffffffc0205c06:	00001617          	auipc	a2,0x1
ffffffffc0205c0a:	f8260613          	addi	a2,a2,-126 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205c0e:	27800593          	li	a1,632
ffffffffc0205c12:	00003517          	auipc	a0,0x3
ffffffffc0205c16:	bce50513          	addi	a0,a0,-1074 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205c1a:	86bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c1e:	00003697          	auipc	a3,0x3
ffffffffc0205c22:	81a68693          	addi	a3,a3,-2022 # ffffffffc0208438 <default_pmm_manager+0x1168>
ffffffffc0205c26:	00001617          	auipc	a2,0x1
ffffffffc0205c2a:	f6260613          	addi	a2,a2,-158 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205c2e:	27700593          	li	a1,631
ffffffffc0205c32:	00003517          	auipc	a0,0x3
ffffffffc0205c36:	bae50513          	addi	a0,a0,-1106 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205c3a:	84bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205c3e:	00002697          	auipc	a3,0x2
ffffffffc0205c42:	7b268693          	addi	a3,a3,1970 # ffffffffc02083f0 <default_pmm_manager+0x1120>
ffffffffc0205c46:	00001617          	auipc	a2,0x1
ffffffffc0205c4a:	f4260613          	addi	a2,a2,-190 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205c4e:	27600593          	li	a1,630
ffffffffc0205c52:	00003517          	auipc	a0,0x3
ffffffffc0205c56:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205c5a:	82bfa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205c5e <do_yield>:
    current->need_resched = 1;
ffffffffc0205c5e:	000a7797          	auipc	a5,0xa7
ffffffffc0205c62:	87278793          	addi	a5,a5,-1934 # ffffffffc02ac4d0 <current>
ffffffffc0205c66:	639c                	ld	a5,0(a5)
ffffffffc0205c68:	4705                	li	a4,1
}
ffffffffc0205c6a:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205c6c:	ef98                	sd	a4,24(a5)
}
ffffffffc0205c6e:	8082                	ret

ffffffffc0205c70 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205c70:	1101                	addi	sp,sp,-32
ffffffffc0205c72:	e822                	sd	s0,16(sp)
ffffffffc0205c74:	e426                	sd	s1,8(sp)
ffffffffc0205c76:	ec06                	sd	ra,24(sp)
ffffffffc0205c78:	842e                	mv	s0,a1
ffffffffc0205c7a:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205c7c:	cd81                	beqz	a1,ffffffffc0205c94 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205c7e:	000a7797          	auipc	a5,0xa7
ffffffffc0205c82:	85278793          	addi	a5,a5,-1966 # ffffffffc02ac4d0 <current>
ffffffffc0205c86:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205c88:	4685                	li	a3,1
ffffffffc0205c8a:	4611                	li	a2,4
ffffffffc0205c8c:	7788                	ld	a0,40(a5)
ffffffffc0205c8e:	d83fe0ef          	jal	ra,ffffffffc0204a10 <user_mem_check>
ffffffffc0205c92:	c909                	beqz	a0,ffffffffc0205ca4 <do_wait+0x34>
ffffffffc0205c94:	85a2                	mv	a1,s0
}
ffffffffc0205c96:	6442                	ld	s0,16(sp)
ffffffffc0205c98:	60e2                	ld	ra,24(sp)
ffffffffc0205c9a:	8526                	mv	a0,s1
ffffffffc0205c9c:	64a2                	ld	s1,8(sp)
ffffffffc0205c9e:	6105                	addi	sp,sp,32
ffffffffc0205ca0:	ff0ff06f          	j	ffffffffc0205490 <do_wait.part.1>
ffffffffc0205ca4:	60e2                	ld	ra,24(sp)
ffffffffc0205ca6:	6442                	ld	s0,16(sp)
ffffffffc0205ca8:	64a2                	ld	s1,8(sp)
ffffffffc0205caa:	5575                	li	a0,-3
ffffffffc0205cac:	6105                	addi	sp,sp,32
ffffffffc0205cae:	8082                	ret

ffffffffc0205cb0 <do_kill>:
do_kill(int pid) {
ffffffffc0205cb0:	1141                	addi	sp,sp,-16
ffffffffc0205cb2:	e406                	sd	ra,8(sp)
ffffffffc0205cb4:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205cb6:	a04ff0ef          	jal	ra,ffffffffc0204eba <find_proc>
ffffffffc0205cba:	cd0d                	beqz	a0,ffffffffc0205cf4 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205cbc:	0b052703          	lw	a4,176(a0)
ffffffffc0205cc0:	00177693          	andi	a3,a4,1
ffffffffc0205cc4:	e695                	bnez	a3,ffffffffc0205cf0 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205cc6:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205cca:	00176713          	ori	a4,a4,1
ffffffffc0205cce:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205cd2:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205cd4:	0006c763          	bltz	a3,ffffffffc0205ce2 <do_kill+0x32>
}
ffffffffc0205cd8:	8522                	mv	a0,s0
ffffffffc0205cda:	60a2                	ld	ra,8(sp)
ffffffffc0205cdc:	6402                	ld	s0,0(sp)
ffffffffc0205cde:	0141                	addi	sp,sp,16
ffffffffc0205ce0:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205ce2:	1e6000ef          	jal	ra,ffffffffc0205ec8 <wakeup_proc>
}
ffffffffc0205ce6:	8522                	mv	a0,s0
ffffffffc0205ce8:	60a2                	ld	ra,8(sp)
ffffffffc0205cea:	6402                	ld	s0,0(sp)
ffffffffc0205cec:	0141                	addi	sp,sp,16
ffffffffc0205cee:	8082                	ret
        return -E_KILLED;
ffffffffc0205cf0:	545d                	li	s0,-9
ffffffffc0205cf2:	b7dd                	j	ffffffffc0205cd8 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205cf4:	5475                	li	s0,-3
ffffffffc0205cf6:	b7cd                	j	ffffffffc0205cd8 <do_kill+0x28>

ffffffffc0205cf8 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205cf8:	000a7797          	auipc	a5,0xa7
ffffffffc0205cfc:	91878793          	addi	a5,a5,-1768 # ffffffffc02ac610 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205d00:	1101                	addi	sp,sp,-32
ffffffffc0205d02:	000a7717          	auipc	a4,0xa7
ffffffffc0205d06:	90f73b23          	sd	a5,-1770(a4) # ffffffffc02ac618 <proc_list+0x8>
ffffffffc0205d0a:	000a7717          	auipc	a4,0xa7
ffffffffc0205d0e:	90f73323          	sd	a5,-1786(a4) # ffffffffc02ac610 <proc_list>
ffffffffc0205d12:	ec06                	sd	ra,24(sp)
ffffffffc0205d14:	e822                	sd	s0,16(sp)
ffffffffc0205d16:	e426                	sd	s1,8(sp)
ffffffffc0205d18:	000a2797          	auipc	a5,0xa2
ffffffffc0205d1c:	78078793          	addi	a5,a5,1920 # ffffffffc02a8498 <hash_list>
ffffffffc0205d20:	000a6717          	auipc	a4,0xa6
ffffffffc0205d24:	77870713          	addi	a4,a4,1912 # ffffffffc02ac498 <is_panic>
ffffffffc0205d28:	e79c                	sd	a5,8(a5)
ffffffffc0205d2a:	e39c                	sd	a5,0(a5)
ffffffffc0205d2c:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205d2e:	fee79de3          	bne	a5,a4,ffffffffc0205d28 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205d32:	ee3fe0ef          	jal	ra,ffffffffc0204c14 <alloc_proc>
ffffffffc0205d36:	000a6717          	auipc	a4,0xa6
ffffffffc0205d3a:	7aa73123          	sd	a0,1954(a4) # ffffffffc02ac4d8 <idleproc>
ffffffffc0205d3e:	000a6497          	auipc	s1,0xa6
ffffffffc0205d42:	79a48493          	addi	s1,s1,1946 # ffffffffc02ac4d8 <idleproc>
ffffffffc0205d46:	c559                	beqz	a0,ffffffffc0205dd4 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205d48:	4709                	li	a4,2
ffffffffc0205d4a:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205d4c:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d4e:	00003717          	auipc	a4,0x3
ffffffffc0205d52:	2b270713          	addi	a4,a4,690 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205d56:	00003597          	auipc	a1,0x3
ffffffffc0205d5a:	9a258593          	addi	a1,a1,-1630 # ffffffffc02086f8 <default_pmm_manager+0x1428>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d5e:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205d60:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205d62:	8c2ff0ef          	jal	ra,ffffffffc0204e24 <set_proc_name>
    nr_process ++;
ffffffffc0205d66:	000a6797          	auipc	a5,0xa6
ffffffffc0205d6a:	78278793          	addi	a5,a5,1922 # ffffffffc02ac4e8 <nr_process>
ffffffffc0205d6e:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205d70:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205d72:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205d74:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205d76:	4581                	li	a1,0
ffffffffc0205d78:	00000517          	auipc	a0,0x0
ffffffffc0205d7c:	8c050513          	addi	a0,a0,-1856 # ffffffffc0205638 <init_main>
    nr_process ++;
ffffffffc0205d80:	000a6697          	auipc	a3,0xa6
ffffffffc0205d84:	76f6a423          	sw	a5,1896(a3) # ffffffffc02ac4e8 <nr_process>
    current = idleproc;
ffffffffc0205d88:	000a6797          	auipc	a5,0xa6
ffffffffc0205d8c:	74e7b423          	sd	a4,1864(a5) # ffffffffc02ac4d0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205d90:	d62ff0ef          	jal	ra,ffffffffc02052f2 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205d94:	08a05c63          	blez	a0,ffffffffc0205e2c <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205d98:	922ff0ef          	jal	ra,ffffffffc0204eba <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205d9c:	00003597          	auipc	a1,0x3
ffffffffc0205da0:	98458593          	addi	a1,a1,-1660 # ffffffffc0208720 <default_pmm_manager+0x1450>
    initproc = find_proc(pid);
ffffffffc0205da4:	000a6797          	auipc	a5,0xa6
ffffffffc0205da8:	72a7be23          	sd	a0,1852(a5) # ffffffffc02ac4e0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205dac:	878ff0ef          	jal	ra,ffffffffc0204e24 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205db0:	609c                	ld	a5,0(s1)
ffffffffc0205db2:	cfa9                	beqz	a5,ffffffffc0205e0c <proc_init+0x114>
ffffffffc0205db4:	43dc                	lw	a5,4(a5)
ffffffffc0205db6:	ebb9                	bnez	a5,ffffffffc0205e0c <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205db8:	000a6797          	auipc	a5,0xa6
ffffffffc0205dbc:	72878793          	addi	a5,a5,1832 # ffffffffc02ac4e0 <initproc>
ffffffffc0205dc0:	639c                	ld	a5,0(a5)
ffffffffc0205dc2:	c78d                	beqz	a5,ffffffffc0205dec <proc_init+0xf4>
ffffffffc0205dc4:	43dc                	lw	a5,4(a5)
ffffffffc0205dc6:	02879363          	bne	a5,s0,ffffffffc0205dec <proc_init+0xf4>
}
ffffffffc0205dca:	60e2                	ld	ra,24(sp)
ffffffffc0205dcc:	6442                	ld	s0,16(sp)
ffffffffc0205dce:	64a2                	ld	s1,8(sp)
ffffffffc0205dd0:	6105                	addi	sp,sp,32
ffffffffc0205dd2:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205dd4:	00003617          	auipc	a2,0x3
ffffffffc0205dd8:	90c60613          	addi	a2,a2,-1780 # ffffffffc02086e0 <default_pmm_manager+0x1410>
ffffffffc0205ddc:	37500593          	li	a1,885
ffffffffc0205de0:	00003517          	auipc	a0,0x3
ffffffffc0205de4:	a0050513          	addi	a0,a0,-1536 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205de8:	e9cfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205dec:	00003697          	auipc	a3,0x3
ffffffffc0205df0:	96468693          	addi	a3,a3,-1692 # ffffffffc0208750 <default_pmm_manager+0x1480>
ffffffffc0205df4:	00001617          	auipc	a2,0x1
ffffffffc0205df8:	d9460613          	addi	a2,a2,-620 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205dfc:	38a00593          	li	a1,906
ffffffffc0205e00:	00003517          	auipc	a0,0x3
ffffffffc0205e04:	9e050513          	addi	a0,a0,-1568 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205e08:	e7cfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e0c:	00003697          	auipc	a3,0x3
ffffffffc0205e10:	91c68693          	addi	a3,a3,-1764 # ffffffffc0208728 <default_pmm_manager+0x1458>
ffffffffc0205e14:	00001617          	auipc	a2,0x1
ffffffffc0205e18:	d7460613          	addi	a2,a2,-652 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205e1c:	38900593          	li	a1,905
ffffffffc0205e20:	00003517          	auipc	a0,0x3
ffffffffc0205e24:	9c050513          	addi	a0,a0,-1600 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205e28:	e5cfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205e2c:	00003617          	auipc	a2,0x3
ffffffffc0205e30:	8d460613          	addi	a2,a2,-1836 # ffffffffc0208700 <default_pmm_manager+0x1430>
ffffffffc0205e34:	38300593          	li	a1,899
ffffffffc0205e38:	00003517          	auipc	a0,0x3
ffffffffc0205e3c:	9a850513          	addi	a0,a0,-1624 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc0205e40:	e44fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205e44 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205e44:	1141                	addi	sp,sp,-16
ffffffffc0205e46:	e022                	sd	s0,0(sp)
ffffffffc0205e48:	e406                	sd	ra,8(sp)
ffffffffc0205e4a:	000a6417          	auipc	s0,0xa6
ffffffffc0205e4e:	68640413          	addi	s0,s0,1670 # ffffffffc02ac4d0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205e52:	6018                	ld	a4,0(s0)
ffffffffc0205e54:	6f1c                	ld	a5,24(a4)
ffffffffc0205e56:	dffd                	beqz	a5,ffffffffc0205e54 <cpu_idle+0x10>
            schedule();
ffffffffc0205e58:	0ec000ef          	jal	ra,ffffffffc0205f44 <schedule>
ffffffffc0205e5c:	bfdd                	j	ffffffffc0205e52 <cpu_idle+0xe>

ffffffffc0205e5e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205e5e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205e62:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205e66:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205e68:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205e6a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205e6e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205e72:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205e76:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205e7a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205e7e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205e82:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205e86:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205e8a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205e8e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205e92:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205e96:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205e9a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205e9c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205e9e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205ea2:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205ea6:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205eaa:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205eae:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205eb2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205eb6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205eba:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205ebe:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205ec2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205ec6:	8082                	ret

ffffffffc0205ec8 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ec8:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205eca:	1101                	addi	sp,sp,-32
ffffffffc0205ecc:	ec06                	sd	ra,24(sp)
ffffffffc0205ece:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ed0:	478d                	li	a5,3
ffffffffc0205ed2:	04f70a63          	beq	a4,a5,ffffffffc0205f26 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ed6:	100027f3          	csrr	a5,sstatus
ffffffffc0205eda:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205edc:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ede:	ef8d                	bnez	a5,ffffffffc0205f18 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205ee0:	4789                	li	a5,2
ffffffffc0205ee2:	00f70f63          	beq	a4,a5,ffffffffc0205f00 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205ee6:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205ee8:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205eec:	e409                	bnez	s0,ffffffffc0205ef6 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205eee:	60e2                	ld	ra,24(sp)
ffffffffc0205ef0:	6442                	ld	s0,16(sp)
ffffffffc0205ef2:	6105                	addi	sp,sp,32
ffffffffc0205ef4:	8082                	ret
ffffffffc0205ef6:	6442                	ld	s0,16(sp)
ffffffffc0205ef8:	60e2                	ld	ra,24(sp)
ffffffffc0205efa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205efc:	f58fa06f          	j	ffffffffc0200654 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f00:	00003617          	auipc	a2,0x3
ffffffffc0205f04:	93060613          	addi	a2,a2,-1744 # ffffffffc0208830 <default_pmm_manager+0x1560>
ffffffffc0205f08:	45c9                	li	a1,18
ffffffffc0205f0a:	00003517          	auipc	a0,0x3
ffffffffc0205f0e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0208818 <default_pmm_manager+0x1548>
ffffffffc0205f12:	ddefa0ef          	jal	ra,ffffffffc02004f0 <__warn>
ffffffffc0205f16:	bfd9                	j	ffffffffc0205eec <wakeup_proc+0x24>
ffffffffc0205f18:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f1a:	f40fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205f1e:	6522                	ld	a0,8(sp)
ffffffffc0205f20:	4405                	li	s0,1
ffffffffc0205f22:	4118                	lw	a4,0(a0)
ffffffffc0205f24:	bf75                	j	ffffffffc0205ee0 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f26:	00003697          	auipc	a3,0x3
ffffffffc0205f2a:	8d268693          	addi	a3,a3,-1838 # ffffffffc02087f8 <default_pmm_manager+0x1528>
ffffffffc0205f2e:	00001617          	auipc	a2,0x1
ffffffffc0205f32:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206b88 <commands+0x4c0>
ffffffffc0205f36:	45a5                	li	a1,9
ffffffffc0205f38:	00003517          	auipc	a0,0x3
ffffffffc0205f3c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0208818 <default_pmm_manager+0x1548>
ffffffffc0205f40:	d44fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205f44 <schedule>:

void
schedule(void) {
ffffffffc0205f44:	1141                	addi	sp,sp,-16
ffffffffc0205f46:	e406                	sd	ra,8(sp)
ffffffffc0205f48:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f4a:	100027f3          	csrr	a5,sstatus
ffffffffc0205f4e:	8b89                	andi	a5,a5,2
ffffffffc0205f50:	4401                	li	s0,0
ffffffffc0205f52:	e3d1                	bnez	a5,ffffffffc0205fd6 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205f54:	000a6797          	auipc	a5,0xa6
ffffffffc0205f58:	57c78793          	addi	a5,a5,1404 # ffffffffc02ac4d0 <current>
ffffffffc0205f5c:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f60:	000a6797          	auipc	a5,0xa6
ffffffffc0205f64:	57878793          	addi	a5,a5,1400 # ffffffffc02ac4d8 <idleproc>
ffffffffc0205f68:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205f6a:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7560>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f6e:	04a88e63          	beq	a7,a0,ffffffffc0205fca <schedule+0x86>
ffffffffc0205f72:	0c888693          	addi	a3,a7,200
ffffffffc0205f76:	000a6617          	auipc	a2,0xa6
ffffffffc0205f7a:	69a60613          	addi	a2,a2,1690 # ffffffffc02ac610 <proc_list>
        le = last;
ffffffffc0205f7e:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205f80:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205f82:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205f84:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205f86:	00c78863          	beq	a5,a2,ffffffffc0205f96 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205f8a:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205f8e:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205f92:	01070463          	beq	a4,a6,ffffffffc0205f9a <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205f96:	fef697e3          	bne	a3,a5,ffffffffc0205f84 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205f9a:	c589                	beqz	a1,ffffffffc0205fa4 <schedule+0x60>
ffffffffc0205f9c:	4198                	lw	a4,0(a1)
ffffffffc0205f9e:	4789                	li	a5,2
ffffffffc0205fa0:	00f70e63          	beq	a4,a5,ffffffffc0205fbc <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205fa4:	451c                	lw	a5,8(a0)
ffffffffc0205fa6:	2785                	addiw	a5,a5,1
ffffffffc0205fa8:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205faa:	00a88463          	beq	a7,a0,ffffffffc0205fb2 <schedule+0x6e>
            proc_run(next);
ffffffffc0205fae:	ea1fe0ef          	jal	ra,ffffffffc0204e4e <proc_run>
    if (flag) {
ffffffffc0205fb2:	e419                	bnez	s0,ffffffffc0205fc0 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205fb4:	60a2                	ld	ra,8(sp)
ffffffffc0205fb6:	6402                	ld	s0,0(sp)
ffffffffc0205fb8:	0141                	addi	sp,sp,16
ffffffffc0205fba:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fbc:	852e                	mv	a0,a1
ffffffffc0205fbe:	b7dd                	j	ffffffffc0205fa4 <schedule+0x60>
}
ffffffffc0205fc0:	6402                	ld	s0,0(sp)
ffffffffc0205fc2:	60a2                	ld	ra,8(sp)
ffffffffc0205fc4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205fc6:	e8efa06f          	j	ffffffffc0200654 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fca:	000a6617          	auipc	a2,0xa6
ffffffffc0205fce:	64660613          	addi	a2,a2,1606 # ffffffffc02ac610 <proc_list>
ffffffffc0205fd2:	86b2                	mv	a3,a2
ffffffffc0205fd4:	b76d                	j	ffffffffc0205f7e <schedule+0x3a>
        intr_disable();
ffffffffc0205fd6:	e84fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205fda:	4405                	li	s0,1
ffffffffc0205fdc:	bfa5                	j	ffffffffc0205f54 <schedule+0x10>

ffffffffc0205fde <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205fde:	000a6797          	auipc	a5,0xa6
ffffffffc0205fe2:	4f278793          	addi	a5,a5,1266 # ffffffffc02ac4d0 <current>
ffffffffc0205fe6:	639c                	ld	a5,0(a5)
}
ffffffffc0205fe8:	43c8                	lw	a0,4(a5)
ffffffffc0205fea:	8082                	ret

ffffffffc0205fec <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205fec:	4501                	li	a0,0
ffffffffc0205fee:	8082                	ret

ffffffffc0205ff0 <sys_putc>:
    cputchar(c);
ffffffffc0205ff0:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205ff2:	1141                	addi	sp,sp,-16
ffffffffc0205ff4:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205ff6:	9ccfa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc0205ffa:	60a2                	ld	ra,8(sp)
ffffffffc0205ffc:	4501                	li	a0,0
ffffffffc0205ffe:	0141                	addi	sp,sp,16
ffffffffc0206000:	8082                	ret

ffffffffc0206002 <sys_kill>:
    return do_kill(pid);
ffffffffc0206002:	4108                	lw	a0,0(a0)
ffffffffc0206004:	cadff06f          	j	ffffffffc0205cb0 <do_kill>

ffffffffc0206008 <sys_yield>:
    return do_yield();
ffffffffc0206008:	c57ff06f          	j	ffffffffc0205c5e <do_yield>

ffffffffc020600c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020600c:	6d14                	ld	a3,24(a0)
ffffffffc020600e:	6910                	ld	a2,16(a0)
ffffffffc0206010:	650c                	ld	a1,8(a0)
ffffffffc0206012:	6108                	ld	a0,0(a0)
ffffffffc0206014:	f4cff06f          	j	ffffffffc0205760 <do_execve>

ffffffffc0206018 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206018:	650c                	ld	a1,8(a0)
ffffffffc020601a:	4108                	lw	a0,0(a0)
ffffffffc020601c:	c55ff06f          	j	ffffffffc0205c70 <do_wait>

ffffffffc0206020 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206020:	000a6797          	auipc	a5,0xa6
ffffffffc0206024:	4b078793          	addi	a5,a5,1200 # ffffffffc02ac4d0 <current>
ffffffffc0206028:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc020602a:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc020602c:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc020602e:	6a0c                	ld	a1,16(a2)
ffffffffc0206030:	ee7fe06f          	j	ffffffffc0204f16 <do_fork>

ffffffffc0206034 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206034:	4108                	lw	a0,0(a0)
ffffffffc0206036:	b0cff06f          	j	ffffffffc0205342 <do_exit>

ffffffffc020603a <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020603a:	715d                	addi	sp,sp,-80
ffffffffc020603c:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc020603e:	000a6497          	auipc	s1,0xa6
ffffffffc0206042:	49248493          	addi	s1,s1,1170 # ffffffffc02ac4d0 <current>
ffffffffc0206046:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206048:	e0a2                	sd	s0,64(sp)
ffffffffc020604a:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc020604c:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020604e:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206050:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0206052:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206056:	0327ee63          	bltu	a5,s2,ffffffffc0206092 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc020605a:	00391713          	slli	a4,s2,0x3
ffffffffc020605e:	00003797          	auipc	a5,0x3
ffffffffc0206062:	83a78793          	addi	a5,a5,-1990 # ffffffffc0208898 <syscalls>
ffffffffc0206066:	97ba                	add	a5,a5,a4
ffffffffc0206068:	639c                	ld	a5,0(a5)
ffffffffc020606a:	c785                	beqz	a5,ffffffffc0206092 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc020606c:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020606e:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206070:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206072:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206074:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206076:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206078:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc020607a:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc020607c:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc020607e:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206080:	0028                	addi	a0,sp,8
ffffffffc0206082:	9782                	jalr	a5
ffffffffc0206084:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206086:	60a6                	ld	ra,72(sp)
ffffffffc0206088:	6406                	ld	s0,64(sp)
ffffffffc020608a:	74e2                	ld	s1,56(sp)
ffffffffc020608c:	7942                	ld	s2,48(sp)
ffffffffc020608e:	6161                	addi	sp,sp,80
ffffffffc0206090:	8082                	ret
    print_trapframe(tf);
ffffffffc0206092:	8522                	mv	a0,s0
ffffffffc0206094:	fb6fa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206098:	609c                	ld	a5,0(s1)
ffffffffc020609a:	86ca                	mv	a3,s2
ffffffffc020609c:	00002617          	auipc	a2,0x2
ffffffffc02060a0:	7b460613          	addi	a2,a2,1972 # ffffffffc0208850 <default_pmm_manager+0x1580>
ffffffffc02060a4:	43d8                	lw	a4,4(a5)
ffffffffc02060a6:	06300593          	li	a1,99
ffffffffc02060aa:	0b478793          	addi	a5,a5,180
ffffffffc02060ae:	00002517          	auipc	a0,0x2
ffffffffc02060b2:	7d250513          	addi	a0,a0,2002 # ffffffffc0208880 <default_pmm_manager+0x15b0>
ffffffffc02060b6:	bcefa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02060ba <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02060ba:	9e3707b7          	lui	a5,0x9e370
ffffffffc02060be:	2785                	addiw	a5,a5,1
ffffffffc02060c0:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02060c4:	02000793          	li	a5,32
ffffffffc02060c8:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02060cc:	00b5553b          	srlw	a0,a0,a1
ffffffffc02060d0:	8082                	ret

ffffffffc02060d2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02060d2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060d6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02060d8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060dc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02060de:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060e2:	f022                	sd	s0,32(sp)
ffffffffc02060e4:	ec26                	sd	s1,24(sp)
ffffffffc02060e6:	e84a                	sd	s2,16(sp)
ffffffffc02060e8:	f406                	sd	ra,40(sp)
ffffffffc02060ea:	e44e                	sd	s3,8(sp)
ffffffffc02060ec:	84aa                	mv	s1,a0
ffffffffc02060ee:	892e                	mv	s2,a1
ffffffffc02060f0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02060f4:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02060f6:	03067e63          	bleu	a6,a2,ffffffffc0206132 <printnum+0x60>
ffffffffc02060fa:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02060fc:	00805763          	blez	s0,ffffffffc020610a <printnum+0x38>
ffffffffc0206100:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206102:	85ca                	mv	a1,s2
ffffffffc0206104:	854e                	mv	a0,s3
ffffffffc0206106:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206108:	fc65                	bnez	s0,ffffffffc0206100 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020610a:	1a02                	slli	s4,s4,0x20
ffffffffc020610c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206110:	00003797          	auipc	a5,0x3
ffffffffc0206114:	aa878793          	addi	a5,a5,-1368 # ffffffffc0208bb8 <error_string+0xc8>
ffffffffc0206118:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020611a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020611c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206120:	70a2                	ld	ra,40(sp)
ffffffffc0206122:	69a2                	ld	s3,8(sp)
ffffffffc0206124:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206126:	85ca                	mv	a1,s2
ffffffffc0206128:	8326                	mv	t1,s1
}
ffffffffc020612a:	6942                	ld	s2,16(sp)
ffffffffc020612c:	64e2                	ld	s1,24(sp)
ffffffffc020612e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206130:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206132:	03065633          	divu	a2,a2,a6
ffffffffc0206136:	8722                	mv	a4,s0
ffffffffc0206138:	f9bff0ef          	jal	ra,ffffffffc02060d2 <printnum>
ffffffffc020613c:	b7f9                	j	ffffffffc020610a <printnum+0x38>

ffffffffc020613e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020613e:	7119                	addi	sp,sp,-128
ffffffffc0206140:	f4a6                	sd	s1,104(sp)
ffffffffc0206142:	f0ca                	sd	s2,96(sp)
ffffffffc0206144:	e8d2                	sd	s4,80(sp)
ffffffffc0206146:	e4d6                	sd	s5,72(sp)
ffffffffc0206148:	e0da                	sd	s6,64(sp)
ffffffffc020614a:	fc5e                	sd	s7,56(sp)
ffffffffc020614c:	f862                	sd	s8,48(sp)
ffffffffc020614e:	f06a                	sd	s10,32(sp)
ffffffffc0206150:	fc86                	sd	ra,120(sp)
ffffffffc0206152:	f8a2                	sd	s0,112(sp)
ffffffffc0206154:	ecce                	sd	s3,88(sp)
ffffffffc0206156:	f466                	sd	s9,40(sp)
ffffffffc0206158:	ec6e                	sd	s11,24(sp)
ffffffffc020615a:	892a                	mv	s2,a0
ffffffffc020615c:	84ae                	mv	s1,a1
ffffffffc020615e:	8d32                	mv	s10,a2
ffffffffc0206160:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0206162:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206164:	00003a17          	auipc	s4,0x3
ffffffffc0206168:	834a0a13          	addi	s4,s4,-1996 # ffffffffc0208998 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020616c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206170:	00003c17          	auipc	s8,0x3
ffffffffc0206174:	980c0c13          	addi	s8,s8,-1664 # ffffffffc0208af0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206178:	000d4503          	lbu	a0,0(s10)
ffffffffc020617c:	02500793          	li	a5,37
ffffffffc0206180:	001d0413          	addi	s0,s10,1
ffffffffc0206184:	00f50e63          	beq	a0,a5,ffffffffc02061a0 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0206188:	c521                	beqz	a0,ffffffffc02061d0 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020618a:	02500993          	li	s3,37
ffffffffc020618e:	a011                	j	ffffffffc0206192 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0206190:	c121                	beqz	a0,ffffffffc02061d0 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0206192:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206194:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206196:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206198:	fff44503          	lbu	a0,-1(s0)
ffffffffc020619c:	ff351ae3          	bne	a0,s3,ffffffffc0206190 <vprintfmt+0x52>
ffffffffc02061a0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02061a4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02061a8:	4981                	li	s3,0
ffffffffc02061aa:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02061ac:	5cfd                	li	s9,-1
ffffffffc02061ae:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061b0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02061b4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061b6:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02061ba:	0ff6f693          	andi	a3,a3,255
ffffffffc02061be:	00140d13          	addi	s10,s0,1
ffffffffc02061c2:	20d5e563          	bltu	a1,a3,ffffffffc02063cc <vprintfmt+0x28e>
ffffffffc02061c6:	068a                	slli	a3,a3,0x2
ffffffffc02061c8:	96d2                	add	a3,a3,s4
ffffffffc02061ca:	4294                	lw	a3,0(a3)
ffffffffc02061cc:	96d2                	add	a3,a3,s4
ffffffffc02061ce:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02061d0:	70e6                	ld	ra,120(sp)
ffffffffc02061d2:	7446                	ld	s0,112(sp)
ffffffffc02061d4:	74a6                	ld	s1,104(sp)
ffffffffc02061d6:	7906                	ld	s2,96(sp)
ffffffffc02061d8:	69e6                	ld	s3,88(sp)
ffffffffc02061da:	6a46                	ld	s4,80(sp)
ffffffffc02061dc:	6aa6                	ld	s5,72(sp)
ffffffffc02061de:	6b06                	ld	s6,64(sp)
ffffffffc02061e0:	7be2                	ld	s7,56(sp)
ffffffffc02061e2:	7c42                	ld	s8,48(sp)
ffffffffc02061e4:	7ca2                	ld	s9,40(sp)
ffffffffc02061e6:	7d02                	ld	s10,32(sp)
ffffffffc02061e8:	6de2                	ld	s11,24(sp)
ffffffffc02061ea:	6109                	addi	sp,sp,128
ffffffffc02061ec:	8082                	ret
    if (lflag >= 2) {
ffffffffc02061ee:	4705                	li	a4,1
ffffffffc02061f0:	008a8593          	addi	a1,s5,8
ffffffffc02061f4:	01074463          	blt	a4,a6,ffffffffc02061fc <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02061f8:	26080363          	beqz	a6,ffffffffc020645e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02061fc:	000ab603          	ld	a2,0(s5)
ffffffffc0206200:	46c1                	li	a3,16
ffffffffc0206202:	8aae                	mv	s5,a1
ffffffffc0206204:	a06d                	j	ffffffffc02062ae <vprintfmt+0x170>
            goto reswitch;
ffffffffc0206206:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020620a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020620c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020620e:	b765                	j	ffffffffc02061b6 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0206210:	000aa503          	lw	a0,0(s5)
ffffffffc0206214:	85a6                	mv	a1,s1
ffffffffc0206216:	0aa1                	addi	s5,s5,8
ffffffffc0206218:	9902                	jalr	s2
            break;
ffffffffc020621a:	bfb9                	j	ffffffffc0206178 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020621c:	4705                	li	a4,1
ffffffffc020621e:	008a8993          	addi	s3,s5,8
ffffffffc0206222:	01074463          	blt	a4,a6,ffffffffc020622a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0206226:	22080463          	beqz	a6,ffffffffc020644e <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020622a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020622e:	24044463          	bltz	s0,ffffffffc0206476 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0206232:	8622                	mv	a2,s0
ffffffffc0206234:	8ace                	mv	s5,s3
ffffffffc0206236:	46a9                	li	a3,10
ffffffffc0206238:	a89d                	j	ffffffffc02062ae <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020623a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020623e:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206240:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0206242:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206246:	8fb5                	xor	a5,a5,a3
ffffffffc0206248:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020624c:	1ad74363          	blt	a4,a3,ffffffffc02063f2 <vprintfmt+0x2b4>
ffffffffc0206250:	00369793          	slli	a5,a3,0x3
ffffffffc0206254:	97e2                	add	a5,a5,s8
ffffffffc0206256:	639c                	ld	a5,0(a5)
ffffffffc0206258:	18078d63          	beqz	a5,ffffffffc02063f2 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020625c:	86be                	mv	a3,a5
ffffffffc020625e:	00000617          	auipc	a2,0x0
ffffffffc0206262:	36260613          	addi	a2,a2,866 # ffffffffc02065c0 <etext+0x2e>
ffffffffc0206266:	85a6                	mv	a1,s1
ffffffffc0206268:	854a                	mv	a0,s2
ffffffffc020626a:	240000ef          	jal	ra,ffffffffc02064aa <printfmt>
ffffffffc020626e:	b729                	j	ffffffffc0206178 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0206270:	00144603          	lbu	a2,1(s0)
ffffffffc0206274:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206276:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206278:	bf3d                	j	ffffffffc02061b6 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020627a:	4705                	li	a4,1
ffffffffc020627c:	008a8593          	addi	a1,s5,8
ffffffffc0206280:	01074463          	blt	a4,a6,ffffffffc0206288 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0206284:	1e080263          	beqz	a6,ffffffffc0206468 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0206288:	000ab603          	ld	a2,0(s5)
ffffffffc020628c:	46a1                	li	a3,8
ffffffffc020628e:	8aae                	mv	s5,a1
ffffffffc0206290:	a839                	j	ffffffffc02062ae <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0206292:	03000513          	li	a0,48
ffffffffc0206296:	85a6                	mv	a1,s1
ffffffffc0206298:	e03e                	sd	a5,0(sp)
ffffffffc020629a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020629c:	85a6                	mv	a1,s1
ffffffffc020629e:	07800513          	li	a0,120
ffffffffc02062a2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02062a4:	0aa1                	addi	s5,s5,8
ffffffffc02062a6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02062aa:	6782                	ld	a5,0(sp)
ffffffffc02062ac:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02062ae:	876e                	mv	a4,s11
ffffffffc02062b0:	85a6                	mv	a1,s1
ffffffffc02062b2:	854a                	mv	a0,s2
ffffffffc02062b4:	e1fff0ef          	jal	ra,ffffffffc02060d2 <printnum>
            break;
ffffffffc02062b8:	b5c1                	j	ffffffffc0206178 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02062ba:	000ab603          	ld	a2,0(s5)
ffffffffc02062be:	0aa1                	addi	s5,s5,8
ffffffffc02062c0:	1c060663          	beqz	a2,ffffffffc020648c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02062c4:	00160413          	addi	s0,a2,1
ffffffffc02062c8:	17b05c63          	blez	s11,ffffffffc0206440 <vprintfmt+0x302>
ffffffffc02062cc:	02d00593          	li	a1,45
ffffffffc02062d0:	14b79263          	bne	a5,a1,ffffffffc0206414 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02062d4:	00064783          	lbu	a5,0(a2)
ffffffffc02062d8:	0007851b          	sext.w	a0,a5
ffffffffc02062dc:	c905                	beqz	a0,ffffffffc020630c <vprintfmt+0x1ce>
ffffffffc02062de:	000cc563          	bltz	s9,ffffffffc02062e8 <vprintfmt+0x1aa>
ffffffffc02062e2:	3cfd                	addiw	s9,s9,-1
ffffffffc02062e4:	036c8263          	beq	s9,s6,ffffffffc0206308 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02062e8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02062ea:	18098463          	beqz	s3,ffffffffc0206472 <vprintfmt+0x334>
ffffffffc02062ee:	3781                	addiw	a5,a5,-32
ffffffffc02062f0:	18fbf163          	bleu	a5,s7,ffffffffc0206472 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02062f4:	03f00513          	li	a0,63
ffffffffc02062f8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02062fa:	0405                	addi	s0,s0,1
ffffffffc02062fc:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206300:	3dfd                	addiw	s11,s11,-1
ffffffffc0206302:	0007851b          	sext.w	a0,a5
ffffffffc0206306:	fd61                	bnez	a0,ffffffffc02062de <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206308:	e7b058e3          	blez	s11,ffffffffc0206178 <vprintfmt+0x3a>
ffffffffc020630c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020630e:	85a6                	mv	a1,s1
ffffffffc0206310:	02000513          	li	a0,32
ffffffffc0206314:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206316:	e60d81e3          	beqz	s11,ffffffffc0206178 <vprintfmt+0x3a>
ffffffffc020631a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020631c:	85a6                	mv	a1,s1
ffffffffc020631e:	02000513          	li	a0,32
ffffffffc0206322:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206324:	fe0d94e3          	bnez	s11,ffffffffc020630c <vprintfmt+0x1ce>
ffffffffc0206328:	bd81                	j	ffffffffc0206178 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020632a:	4705                	li	a4,1
ffffffffc020632c:	008a8593          	addi	a1,s5,8
ffffffffc0206330:	01074463          	blt	a4,a6,ffffffffc0206338 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0206334:	12080063          	beqz	a6,ffffffffc0206454 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206338:	000ab603          	ld	a2,0(s5)
ffffffffc020633c:	46a9                	li	a3,10
ffffffffc020633e:	8aae                	mv	s5,a1
ffffffffc0206340:	b7bd                	j	ffffffffc02062ae <vprintfmt+0x170>
ffffffffc0206342:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0206346:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020634a:	846a                	mv	s0,s10
ffffffffc020634c:	b5ad                	j	ffffffffc02061b6 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020634e:	85a6                	mv	a1,s1
ffffffffc0206350:	02500513          	li	a0,37
ffffffffc0206354:	9902                	jalr	s2
            break;
ffffffffc0206356:	b50d                	j	ffffffffc0206178 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206358:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020635c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206360:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206362:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206364:	e40dd9e3          	bgez	s11,ffffffffc02061b6 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206368:	8de6                	mv	s11,s9
ffffffffc020636a:	5cfd                	li	s9,-1
ffffffffc020636c:	b5a9                	j	ffffffffc02061b6 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020636e:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0206372:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206376:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206378:	bd3d                	j	ffffffffc02061b6 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020637a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020637e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206382:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206384:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206388:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020638c:	fcd56ce3          	bltu	a0,a3,ffffffffc0206364 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206390:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206392:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0206396:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020639a:	0196873b          	addw	a4,a3,s9
ffffffffc020639e:	0017171b          	slliw	a4,a4,0x1
ffffffffc02063a2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02063a6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02063aa:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02063ae:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02063b2:	fcd57fe3          	bleu	a3,a0,ffffffffc0206390 <vprintfmt+0x252>
ffffffffc02063b6:	b77d                	j	ffffffffc0206364 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02063b8:	fffdc693          	not	a3,s11
ffffffffc02063bc:	96fd                	srai	a3,a3,0x3f
ffffffffc02063be:	00ddfdb3          	and	s11,s11,a3
ffffffffc02063c2:	00144603          	lbu	a2,1(s0)
ffffffffc02063c6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063c8:	846a                	mv	s0,s10
ffffffffc02063ca:	b3f5                	j	ffffffffc02061b6 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02063cc:	85a6                	mv	a1,s1
ffffffffc02063ce:	02500513          	li	a0,37
ffffffffc02063d2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02063d4:	fff44703          	lbu	a4,-1(s0)
ffffffffc02063d8:	02500793          	li	a5,37
ffffffffc02063dc:	8d22                	mv	s10,s0
ffffffffc02063de:	d8f70de3          	beq	a4,a5,ffffffffc0206178 <vprintfmt+0x3a>
ffffffffc02063e2:	02500713          	li	a4,37
ffffffffc02063e6:	1d7d                	addi	s10,s10,-1
ffffffffc02063e8:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02063ec:	fee79de3          	bne	a5,a4,ffffffffc02063e6 <vprintfmt+0x2a8>
ffffffffc02063f0:	b361                	j	ffffffffc0206178 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02063f2:	00003617          	auipc	a2,0x3
ffffffffc02063f6:	8a660613          	addi	a2,a2,-1882 # ffffffffc0208c98 <error_string+0x1a8>
ffffffffc02063fa:	85a6                	mv	a1,s1
ffffffffc02063fc:	854a                	mv	a0,s2
ffffffffc02063fe:	0ac000ef          	jal	ra,ffffffffc02064aa <printfmt>
ffffffffc0206402:	bb9d                	j	ffffffffc0206178 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206404:	00003617          	auipc	a2,0x3
ffffffffc0206408:	88c60613          	addi	a2,a2,-1908 # ffffffffc0208c90 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc020640c:	00003417          	auipc	s0,0x3
ffffffffc0206410:	88540413          	addi	s0,s0,-1915 # ffffffffc0208c91 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206414:	8532                	mv	a0,a2
ffffffffc0206416:	85e6                	mv	a1,s9
ffffffffc0206418:	e032                	sd	a2,0(sp)
ffffffffc020641a:	e43e                	sd	a5,8(sp)
ffffffffc020641c:	0cc000ef          	jal	ra,ffffffffc02064e8 <strnlen>
ffffffffc0206420:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206424:	6602                	ld	a2,0(sp)
ffffffffc0206426:	01b05d63          	blez	s11,ffffffffc0206440 <vprintfmt+0x302>
ffffffffc020642a:	67a2                	ld	a5,8(sp)
ffffffffc020642c:	2781                	sext.w	a5,a5
ffffffffc020642e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206430:	6522                	ld	a0,8(sp)
ffffffffc0206432:	85a6                	mv	a1,s1
ffffffffc0206434:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206436:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206438:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020643a:	6602                	ld	a2,0(sp)
ffffffffc020643c:	fe0d9ae3          	bnez	s11,ffffffffc0206430 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206440:	00064783          	lbu	a5,0(a2)
ffffffffc0206444:	0007851b          	sext.w	a0,a5
ffffffffc0206448:	e8051be3          	bnez	a0,ffffffffc02062de <vprintfmt+0x1a0>
ffffffffc020644c:	b335                	j	ffffffffc0206178 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020644e:	000aa403          	lw	s0,0(s5)
ffffffffc0206452:	bbf1                	j	ffffffffc020622e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0206454:	000ae603          	lwu	a2,0(s5)
ffffffffc0206458:	46a9                	li	a3,10
ffffffffc020645a:	8aae                	mv	s5,a1
ffffffffc020645c:	bd89                	j	ffffffffc02062ae <vprintfmt+0x170>
ffffffffc020645e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206462:	46c1                	li	a3,16
ffffffffc0206464:	8aae                	mv	s5,a1
ffffffffc0206466:	b5a1                	j	ffffffffc02062ae <vprintfmt+0x170>
ffffffffc0206468:	000ae603          	lwu	a2,0(s5)
ffffffffc020646c:	46a1                	li	a3,8
ffffffffc020646e:	8aae                	mv	s5,a1
ffffffffc0206470:	bd3d                	j	ffffffffc02062ae <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0206472:	9902                	jalr	s2
ffffffffc0206474:	b559                	j	ffffffffc02062fa <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0206476:	85a6                	mv	a1,s1
ffffffffc0206478:	02d00513          	li	a0,45
ffffffffc020647c:	e03e                	sd	a5,0(sp)
ffffffffc020647e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206480:	8ace                	mv	s5,s3
ffffffffc0206482:	40800633          	neg	a2,s0
ffffffffc0206486:	46a9                	li	a3,10
ffffffffc0206488:	6782                	ld	a5,0(sp)
ffffffffc020648a:	b515                	j	ffffffffc02062ae <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020648c:	01b05663          	blez	s11,ffffffffc0206498 <vprintfmt+0x35a>
ffffffffc0206490:	02d00693          	li	a3,45
ffffffffc0206494:	f6d798e3          	bne	a5,a3,ffffffffc0206404 <vprintfmt+0x2c6>
ffffffffc0206498:	00002417          	auipc	s0,0x2
ffffffffc020649c:	7f940413          	addi	s0,s0,2041 # ffffffffc0208c91 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064a0:	02800513          	li	a0,40
ffffffffc02064a4:	02800793          	li	a5,40
ffffffffc02064a8:	bd1d                	j	ffffffffc02062de <vprintfmt+0x1a0>

ffffffffc02064aa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064aa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02064ac:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064b0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02064b2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064b4:	ec06                	sd	ra,24(sp)
ffffffffc02064b6:	f83a                	sd	a4,48(sp)
ffffffffc02064b8:	fc3e                	sd	a5,56(sp)
ffffffffc02064ba:	e0c2                	sd	a6,64(sp)
ffffffffc02064bc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02064be:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02064c0:	c7fff0ef          	jal	ra,ffffffffc020613e <vprintfmt>
}
ffffffffc02064c4:	60e2                	ld	ra,24(sp)
ffffffffc02064c6:	6161                	addi	sp,sp,80
ffffffffc02064c8:	8082                	ret

ffffffffc02064ca <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02064ca:	00054783          	lbu	a5,0(a0)
ffffffffc02064ce:	cb91                	beqz	a5,ffffffffc02064e2 <strlen+0x18>
    size_t cnt = 0;
ffffffffc02064d0:	4781                	li	a5,0
        cnt ++;
ffffffffc02064d2:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02064d4:	00f50733          	add	a4,a0,a5
ffffffffc02064d8:	00074703          	lbu	a4,0(a4)
ffffffffc02064dc:	fb7d                	bnez	a4,ffffffffc02064d2 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02064de:	853e                	mv	a0,a5
ffffffffc02064e0:	8082                	ret
    size_t cnt = 0;
ffffffffc02064e2:	4781                	li	a5,0
}
ffffffffc02064e4:	853e                	mv	a0,a5
ffffffffc02064e6:	8082                	ret

ffffffffc02064e8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02064e8:	c185                	beqz	a1,ffffffffc0206508 <strnlen+0x20>
ffffffffc02064ea:	00054783          	lbu	a5,0(a0)
ffffffffc02064ee:	cf89                	beqz	a5,ffffffffc0206508 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02064f0:	4781                	li	a5,0
ffffffffc02064f2:	a021                	j	ffffffffc02064fa <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02064f4:	00074703          	lbu	a4,0(a4)
ffffffffc02064f8:	c711                	beqz	a4,ffffffffc0206504 <strnlen+0x1c>
        cnt ++;
ffffffffc02064fa:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02064fc:	00f50733          	add	a4,a0,a5
ffffffffc0206500:	fef59ae3          	bne	a1,a5,ffffffffc02064f4 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206504:	853e                	mv	a0,a5
ffffffffc0206506:	8082                	ret
    size_t cnt = 0;
ffffffffc0206508:	4781                	li	a5,0
}
ffffffffc020650a:	853e                	mv	a0,a5
ffffffffc020650c:	8082                	ret

ffffffffc020650e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020650e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206510:	0585                	addi	a1,a1,1
ffffffffc0206512:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206516:	0785                	addi	a5,a5,1
ffffffffc0206518:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020651c:	fb75                	bnez	a4,ffffffffc0206510 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020651e:	8082                	ret

ffffffffc0206520 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206520:	00054783          	lbu	a5,0(a0)
ffffffffc0206524:	0005c703          	lbu	a4,0(a1)
ffffffffc0206528:	cb91                	beqz	a5,ffffffffc020653c <strcmp+0x1c>
ffffffffc020652a:	00e79c63          	bne	a5,a4,ffffffffc0206542 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020652e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206530:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0206534:	0585                	addi	a1,a1,1
ffffffffc0206536:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020653a:	fbe5                	bnez	a5,ffffffffc020652a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020653c:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020653e:	9d19                	subw	a0,a0,a4
ffffffffc0206540:	8082                	ret
ffffffffc0206542:	0007851b          	sext.w	a0,a5
ffffffffc0206546:	9d19                	subw	a0,a0,a4
ffffffffc0206548:	8082                	ret

ffffffffc020654a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020654a:	00054783          	lbu	a5,0(a0)
ffffffffc020654e:	cb91                	beqz	a5,ffffffffc0206562 <strchr+0x18>
        if (*s == c) {
ffffffffc0206550:	00b79563          	bne	a5,a1,ffffffffc020655a <strchr+0x10>
ffffffffc0206554:	a809                	j	ffffffffc0206566 <strchr+0x1c>
ffffffffc0206556:	00b78763          	beq	a5,a1,ffffffffc0206564 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020655a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020655c:	00054783          	lbu	a5,0(a0)
ffffffffc0206560:	fbfd                	bnez	a5,ffffffffc0206556 <strchr+0xc>
    }
    return NULL;
ffffffffc0206562:	4501                	li	a0,0
}
ffffffffc0206564:	8082                	ret
ffffffffc0206566:	8082                	ret

ffffffffc0206568 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206568:	ca01                	beqz	a2,ffffffffc0206578 <memset+0x10>
ffffffffc020656a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020656c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020656e:	0785                	addi	a5,a5,1
ffffffffc0206570:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206574:	fec79de3          	bne	a5,a2,ffffffffc020656e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206578:	8082                	ret

ffffffffc020657a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020657a:	ca19                	beqz	a2,ffffffffc0206590 <memcpy+0x16>
ffffffffc020657c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020657e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206580:	0585                	addi	a1,a1,1
ffffffffc0206582:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206586:	0785                	addi	a5,a5,1
ffffffffc0206588:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020658c:	fec59ae3          	bne	a1,a2,ffffffffc0206580 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206590:	8082                	ret
