
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	00c60613          	addi	a2,a2,12 # 80204020 <end>
    8020001c:	1141                	addi	sp,sp,-16
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
    80200022:	e406                	sd	ra,8(sp)
    80200024:	235000ef          	jal	ra,80200a58 <memset>
    80200028:	14c000ef          	jal	ra,80200174 <cons_init>
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a4458593          	addi	a1,a1,-1468 # 80200a70 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a5c50513          	addi	a0,a0,-1444 # 80200a90 <etext+0x26>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>
    80200044:	140000ef          	jal	ra,80200184 <idt_init>
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>
    8020004c:	132000ef          	jal	ra,8020017e <intr_enable>
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    8020005a:	11c000ef          	jal	ra,80200176 <cons_putc>
    8020005e:	401c                	lw	a5,0(s0)
    80200060:	60a2                	ld	ra,8(sp)
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
    8020006c:	711d                	addi	sp,sp,-96
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end+0x8>
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    80200090:	e41a                	sd	t1,8(sp)
    80200092:	c202                	sw	zero,4(sp)
    80200094:	5be000ef          	jal	ra,80200652 <vprintfmt>
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
    802000a0:	1141                	addi	sp,sp,-16
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9f650513          	addi	a0,a0,-1546 # 80200a98 <etext+0x2e>
    802000aa:	e406                	sd	ra,8(sp)
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	a0050513          	addi	a0,a0,-1536 # 80200ab8 <etext+0x4e>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	9a658593          	addi	a1,a1,-1626 # 80200a6a <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	a0c50513          	addi	a0,a0,-1524 # 80200ad8 <etext+0x6e>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	a1850513          	addi	a0,a0,-1512 # 80200af8 <etext+0x8e>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3458593          	addi	a1,a1,-204 # 80204020 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	a2450513          	addi	a0,a0,-1500 # 80200b18 <etext+0xae>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    80200100:	00004597          	auipc	a1,0x4
    80200104:	31f58593          	addi	a1,a1,799 # 8020441f <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    80200114:	43f7d593          	srai	a1,a5,0x3f
    80200118:	60a2                	ld	ra,8(sp)
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	a1650513          	addi	a0,a0,-1514 # 80200b38 <etext+0xce>
    8020012a:	0141                	addi	sp,sp,16
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    8020013c:	c0102573          	rdtime	a0
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	0b3000ef          	jal	ra,802009fa <sbi_set_timer>
    8020014c:	60a2                	ld	ra,8(sp)
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b523          	sd	zero,-310(a5) # 80204018 <ticks>
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	a1250513          	addi	a0,a0,-1518 # 80200b68 <etext+0xfe>
    8020015e:	0141                	addi	sp,sp,16
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <clock_set_next_event>:
    80200164:	c0102573          	rdtime	a0
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	08b0006f          	j	802009fa <sbi_set_timer>

0000000080200174 <cons_init>:
    80200174:	8082                	ret

0000000080200176 <cons_putc>:
    80200176:	0ff57513          	andi	a0,a0,255
    8020017a:	0650006f          	j	802009de <sbi_console_putchar>

000000008020017e <intr_enable>:
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	3a878793          	addi	a5,a5,936 # 80200530 <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	b5250513          	addi	a0,a0,-1198 # 80200cf0 <etext+0x286>
void print_regs(struct pushregs *gpr) {
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	b5a50513          	addi	a0,a0,-1190 # 80200d08 <etext+0x29e>
    802001b6:	eb7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	b6450513          	addi	a0,a0,-1180 # 80200d20 <etext+0x2b6>
    802001c4:	ea9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	b6e50513          	addi	a0,a0,-1170 # 80200d38 <etext+0x2ce>
    802001d2:	e9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	b7850513          	addi	a0,a0,-1160 # 80200d50 <etext+0x2e6>
    802001e0:	e8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	b8250513          	addi	a0,a0,-1150 # 80200d68 <etext+0x2fe>
    802001ee:	e7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	b8c50513          	addi	a0,a0,-1140 # 80200d80 <etext+0x316>
    802001fc:	e71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	b9650513          	addi	a0,a0,-1130 # 80200d98 <etext+0x32e>
    8020020a:	e63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	ba050513          	addi	a0,a0,-1120 # 80200db0 <etext+0x346>
    80200218:	e55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	baa50513          	addi	a0,a0,-1110 # 80200dc8 <etext+0x35e>
    80200226:	e47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	bb450513          	addi	a0,a0,-1100 # 80200de0 <etext+0x376>
    80200234:	e39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	bbe50513          	addi	a0,a0,-1090 # 80200df8 <etext+0x38e>
    80200242:	e2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	bc850513          	addi	a0,a0,-1080 # 80200e10 <etext+0x3a6>
    80200250:	e1dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	bd250513          	addi	a0,a0,-1070 # 80200e28 <etext+0x3be>
    8020025e:	e0fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	bdc50513          	addi	a0,a0,-1060 # 80200e40 <etext+0x3d6>
    8020026c:	e01ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	be650513          	addi	a0,a0,-1050 # 80200e58 <etext+0x3ee>
    8020027a:	df3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	bf050513          	addi	a0,a0,-1040 # 80200e70 <etext+0x406>
    80200288:	de5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	bfa50513          	addi	a0,a0,-1030 # 80200e88 <etext+0x41e>
    80200296:	dd7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	c0450513          	addi	a0,a0,-1020 # 80200ea0 <etext+0x436>
    802002a4:	dc9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	c0e50513          	addi	a0,a0,-1010 # 80200eb8 <etext+0x44e>
    802002b2:	dbbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	c1850513          	addi	a0,a0,-1000 # 80200ed0 <etext+0x466>
    802002c0:	dadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	c2250513          	addi	a0,a0,-990 # 80200ee8 <etext+0x47e>
    802002ce:	d9fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	c2c50513          	addi	a0,a0,-980 # 80200f00 <etext+0x496>
    802002dc:	d91ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	c3650513          	addi	a0,a0,-970 # 80200f18 <etext+0x4ae>
    802002ea:	d83ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	c4050513          	addi	a0,a0,-960 # 80200f30 <etext+0x4c6>
    802002f8:	d75ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	c4a50513          	addi	a0,a0,-950 # 80200f48 <etext+0x4de>
    80200306:	d67ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	c5450513          	addi	a0,a0,-940 # 80200f60 <etext+0x4f6>
    80200314:	d59ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	c5e50513          	addi	a0,a0,-930 # 80200f78 <etext+0x50e>
    80200322:	d4bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	c6850513          	addi	a0,a0,-920 # 80200f90 <etext+0x526>
    80200330:	d3dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	c7250513          	addi	a0,a0,-910 # 80200fa8 <etext+0x53e>
    8020033e:	d2fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	c7c50513          	addi	a0,a0,-900 # 80200fc0 <etext+0x556>
    8020034c:	d21ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	c8250513          	addi	a0,a0,-894 # 80200fd8 <etext+0x56e>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	d0dff06f          	j	8020006c <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	c8450513          	addi	a0,a0,-892 # 80200ff0 <etext+0x586>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cf7ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1bff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	c8450513          	addi	a0,a0,-892 # 80201008 <etext+0x59e>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	c8c50513          	addi	a0,a0,-884 # 80201020 <etext+0x5b6>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	c9450513          	addi	a0,a0,-876 # 80201038 <etext+0x5ce>
    802003ac:	cc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	c9850513          	addi	a0,a0,-872 # 80201050 <etext+0x5e6>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	cabff06f          	j	8020006c <cprintf>

00000000802003c6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c6:	11853783          	ld	a5,280(a0)
    802003ca:	577d                	li	a4,-1
    802003cc:	8305                	srli	a4,a4,0x1
    802003ce:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d0:	472d                	li	a4,11
    802003d2:	08f76663          	bltu	a4,a5,8020045e <interrupt_handler+0x98>
    802003d6:	00000717          	auipc	a4,0x0
    802003da:	7ae70713          	addi	a4,a4,1966 # 80200b84 <etext+0x11a>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	8b850513          	addi	a0,a0,-1864 # 80200ca0 <etext+0x236>
    802003f0:	c7dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f4:	00001517          	auipc	a0,0x1
    802003f8:	88c50513          	addi	a0,a0,-1908 # 80200c80 <etext+0x216>
    802003fc:	c71ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200400:	00001517          	auipc	a0,0x1
    80200404:	84050513          	addi	a0,a0,-1984 # 80200c40 <etext+0x1d6>
    80200408:	c65ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040c:	00001517          	auipc	a0,0x1
    80200410:	85450513          	addi	a0,a0,-1964 # 80200c60 <etext+0x1f6>
    80200414:	c59ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200418:	00001517          	auipc	a0,0x1
    8020041c:	8b850513          	addi	a0,a0,-1864 # 80200cd0 <etext+0x266>
    80200420:	c4dff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200424:	1141                	addi	sp,sp,-16
    80200426:	e022                	sd	s0,0(sp)
    80200428:	e406                	sd	ra,8(sp)
            if (++ticks % TICK_NUM == 0) {
    8020042a:	00004417          	auipc	s0,0x4
    8020042e:	bee40413          	addi	s0,s0,-1042 # 80204018 <ticks>
            clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
    80200432:	d33ff0ef          	jal	ra,80200164 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
    80200436:	601c                	ld	a5,0(s0)
    80200438:	06400713          	li	a4,100
    8020043c:	0785                	addi	a5,a5,1
    8020043e:	02e7f733          	remu	a4,a5,a4
    80200442:	00004697          	auipc	a3,0x4
    80200446:	bcf6bb23          	sd	a5,-1066(a3) # 80204018 <ticks>
    8020044a:	cf01                	beqz	a4,80200462 <interrupt_handler+0x9c>
            if (ticks == 1000) {  // 打印次数为10时             
    8020044c:	6018                	ld	a4,0(s0)
    8020044e:	3e800793          	li	a5,1000
    80200452:	02f70663          	beq	a4,a5,8020047e <interrupt_handler+0xb8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200456:	60a2                	ld	ra,8(sp)
    80200458:	6402                	ld	s0,0(sp)
    8020045a:	0141                	addi	sp,sp,16
    8020045c:	8082                	ret
            print_trapframe(tf);
    8020045e:	f07ff06f          	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200462:	06400593          	li	a1,100
    80200466:	00001517          	auipc	a0,0x1
    8020046a:	85a50513          	addi	a0,a0,-1958 # 80200cc0 <etext+0x256>
    8020046e:	bffff0ef          	jal	ra,8020006c <cprintf>
                __asm("ebreak");
    80200472:	9002                	ebreak
                __asm("ecall");
    80200474:	00000073          	ecall
                __asm("mret");
    80200478:	30200073          	mret
    8020047c:	bfc1                	j	8020044c <interrupt_handler+0x86>
}
    8020047e:	6402                	ld	s0,0(sp)
    80200480:	60a2                	ld	ra,8(sp)
    80200482:	0141                	addi	sp,sp,16
                sbi_shutdown();  // 调用shut_down()函数关机
    80200484:	5920006f          	j	80200a16 <sbi_shutdown>

0000000080200488 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200488:	11853783          	ld	a5,280(a0)
    8020048c:	472d                	li	a4,11
    8020048e:	02f76863          	bltu	a4,a5,802004be <exception_handler+0x36>
    80200492:	4705                	li	a4,1
    80200494:	00f71733          	sll	a4,a4,a5
    80200498:	6785                	lui	a5,0x1
    8020049a:	17cd                	addi	a5,a5,-13
    8020049c:	8ff9                	and	a5,a5,a4
    8020049e:	ef99                	bnez	a5,802004bc <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004a0:	1141                	addi	sp,sp,-16
    802004a2:	e022                	sd	s0,0(sp)
    802004a4:	e406                	sd	ra,8(sp)
    802004a6:	00877793          	andi	a5,a4,8
    802004aa:	842a                	mv	s0,a0
    802004ac:	e3b1                	bnez	a5,802004f0 <exception_handler+0x68>
    802004ae:	8b11                	andi	a4,a4,4
    802004b0:	eb09                	bnez	a4,802004c2 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004b2:	6402                	ld	s0,0(sp)
    802004b4:	60a2                	ld	ra,8(sp)
    802004b6:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004b8:	eadff06f          	j	80200364 <print_trapframe>
    802004bc:	8082                	ret
    802004be:	ea7ff06f          	j	80200364 <print_trapframe>
            cprintf("Illegal instruction caught at 0x%x\n", tf->epc);
    802004c2:	10853583          	ld	a1,264(a0)
    802004c6:	00000517          	auipc	a0,0x0
    802004ca:	6f250513          	addi	a0,a0,1778 # 80200bb8 <etext+0x14e>
    802004ce:	b9fff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Exception type: Illegal instruction\n");
    802004d2:	00000517          	auipc	a0,0x0
    802004d6:	70e50513          	addi	a0,a0,1806 # 80200be0 <etext+0x176>
    802004da:	b93ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 4; // 更新 tf->epc 寄存器
    802004de:	10843783          	ld	a5,264(s0)
}
    802004e2:	60a2                	ld	ra,8(sp)
            tf->epc += 4; // 更新 tf->epc 寄存器
    802004e4:	0791                	addi	a5,a5,4
    802004e6:	10f43423          	sd	a5,264(s0)
}
    802004ea:	6402                	ld	s0,0(sp)
    802004ec:	0141                	addi	sp,sp,16
    802004ee:	8082                	ret
            cprintf("ebreak caught at 0x%x\n", tf->epc);
    802004f0:	10853583          	ld	a1,264(a0)
    802004f4:	00000517          	auipc	a0,0x0
    802004f8:	71450513          	addi	a0,a0,1812 # 80200c08 <etext+0x19e>
    802004fc:	b71ff0ef          	jal	ra,8020006c <cprintf>
            cprintf("Exception type: breakpoint\n");
    80200500:	00000517          	auipc	a0,0x0
    80200504:	72050513          	addi	a0,a0,1824 # 80200c20 <etext+0x1b6>
    80200508:	b65ff0ef          	jal	ra,8020006c <cprintf>
            tf->epc += 4; // 更新 tf->epc 寄存器
    8020050c:	10843783          	ld	a5,264(s0)
}
    80200510:	60a2                	ld	ra,8(sp)
            tf->epc += 4; // 更新 tf->epc 寄存器
    80200512:	0791                	addi	a5,a5,4
    80200514:	10f43423          	sd	a5,264(s0)
}
    80200518:	6402                	ld	s0,0(sp)
    8020051a:	0141                	addi	sp,sp,16
    8020051c:	8082                	ret

000000008020051e <trap>:
/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    8020051e:	11853783          	ld	a5,280(a0)
    80200522:	0007c463          	bltz	a5,8020052a <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200526:	f63ff06f          	j	80200488 <exception_handler>
        interrupt_handler(tf);
    8020052a:	e9dff06f          	j	802003c6 <interrupt_handler>
	...

0000000080200530 <__alltraps>:
    80200530:	14011073          	csrw	sscratch,sp
    80200534:	712d                	addi	sp,sp,-288
    80200536:	e002                	sd	zero,0(sp)
    80200538:	e406                	sd	ra,8(sp)
    8020053a:	ec0e                	sd	gp,24(sp)
    8020053c:	f012                	sd	tp,32(sp)
    8020053e:	f416                	sd	t0,40(sp)
    80200540:	f81a                	sd	t1,48(sp)
    80200542:	fc1e                	sd	t2,56(sp)
    80200544:	e0a2                	sd	s0,64(sp)
    80200546:	e4a6                	sd	s1,72(sp)
    80200548:	e8aa                	sd	a0,80(sp)
    8020054a:	ecae                	sd	a1,88(sp)
    8020054c:	f0b2                	sd	a2,96(sp)
    8020054e:	f4b6                	sd	a3,104(sp)
    80200550:	f8ba                	sd	a4,112(sp)
    80200552:	fcbe                	sd	a5,120(sp)
    80200554:	e142                	sd	a6,128(sp)
    80200556:	e546                	sd	a7,136(sp)
    80200558:	e94a                	sd	s2,144(sp)
    8020055a:	ed4e                	sd	s3,152(sp)
    8020055c:	f152                	sd	s4,160(sp)
    8020055e:	f556                	sd	s5,168(sp)
    80200560:	f95a                	sd	s6,176(sp)
    80200562:	fd5e                	sd	s7,184(sp)
    80200564:	e1e2                	sd	s8,192(sp)
    80200566:	e5e6                	sd	s9,200(sp)
    80200568:	e9ea                	sd	s10,208(sp)
    8020056a:	edee                	sd	s11,216(sp)
    8020056c:	f1f2                	sd	t3,224(sp)
    8020056e:	f5f6                	sd	t4,232(sp)
    80200570:	f9fa                	sd	t5,240(sp)
    80200572:	fdfe                	sd	t6,248(sp)
    80200574:	14001473          	csrrw	s0,sscratch,zero
    80200578:	100024f3          	csrr	s1,sstatus
    8020057c:	14102973          	csrr	s2,sepc
    80200580:	143029f3          	csrr	s3,stval
    80200584:	14202a73          	csrr	s4,scause
    80200588:	e822                	sd	s0,16(sp)
    8020058a:	e226                	sd	s1,256(sp)
    8020058c:	e64a                	sd	s2,264(sp)
    8020058e:	ea4e                	sd	s3,272(sp)
    80200590:	ee52                	sd	s4,280(sp)
    80200592:	850a                	mv	a0,sp
    80200594:	f8bff0ef          	jal	ra,8020051e <trap>

0000000080200598 <__trapret>:
    80200598:	6492                	ld	s1,256(sp)
    8020059a:	6932                	ld	s2,264(sp)
    8020059c:	10049073          	csrw	sstatus,s1
    802005a0:	14191073          	csrw	sepc,s2
    802005a4:	60a2                	ld	ra,8(sp)
    802005a6:	61e2                	ld	gp,24(sp)
    802005a8:	7202                	ld	tp,32(sp)
    802005aa:	72a2                	ld	t0,40(sp)
    802005ac:	7342                	ld	t1,48(sp)
    802005ae:	73e2                	ld	t2,56(sp)
    802005b0:	6406                	ld	s0,64(sp)
    802005b2:	64a6                	ld	s1,72(sp)
    802005b4:	6546                	ld	a0,80(sp)
    802005b6:	65e6                	ld	a1,88(sp)
    802005b8:	7606                	ld	a2,96(sp)
    802005ba:	76a6                	ld	a3,104(sp)
    802005bc:	7746                	ld	a4,112(sp)
    802005be:	77e6                	ld	a5,120(sp)
    802005c0:	680a                	ld	a6,128(sp)
    802005c2:	68aa                	ld	a7,136(sp)
    802005c4:	694a                	ld	s2,144(sp)
    802005c6:	69ea                	ld	s3,152(sp)
    802005c8:	7a0a                	ld	s4,160(sp)
    802005ca:	7aaa                	ld	s5,168(sp)
    802005cc:	7b4a                	ld	s6,176(sp)
    802005ce:	7bea                	ld	s7,184(sp)
    802005d0:	6c0e                	ld	s8,192(sp)
    802005d2:	6cae                	ld	s9,200(sp)
    802005d4:	6d4e                	ld	s10,208(sp)
    802005d6:	6dee                	ld	s11,216(sp)
    802005d8:	7e0e                	ld	t3,224(sp)
    802005da:	7eae                	ld	t4,232(sp)
    802005dc:	7f4e                	ld	t5,240(sp)
    802005de:	7fee                	ld	t6,248(sp)
    802005e0:	6142                	ld	sp,16(sp)
    802005e2:	10200073          	sret

00000000802005e6 <printnum>:
    802005e6:	02069813          	slli	a6,a3,0x20
    802005ea:	7179                	addi	sp,sp,-48
    802005ec:	02085813          	srli	a6,a6,0x20
    802005f0:	e052                	sd	s4,0(sp)
    802005f2:	03067a33          	remu	s4,a2,a6
    802005f6:	f022                	sd	s0,32(sp)
    802005f8:	ec26                	sd	s1,24(sp)
    802005fa:	e84a                	sd	s2,16(sp)
    802005fc:	f406                	sd	ra,40(sp)
    802005fe:	e44e                	sd	s3,8(sp)
    80200600:	84aa                	mv	s1,a0
    80200602:	892e                	mv	s2,a1
    80200604:	fff7041b          	addiw	s0,a4,-1
    80200608:	2a01                	sext.w	s4,s4
    8020060a:	03067e63          	bleu	a6,a2,80200646 <printnum+0x60>
    8020060e:	89be                	mv	s3,a5
    80200610:	00805763          	blez	s0,8020061e <printnum+0x38>
    80200614:	347d                	addiw	s0,s0,-1
    80200616:	85ca                	mv	a1,s2
    80200618:	854e                	mv	a0,s3
    8020061a:	9482                	jalr	s1
    8020061c:	fc65                	bnez	s0,80200614 <printnum+0x2e>
    8020061e:	1a02                	slli	s4,s4,0x20
    80200620:	020a5a13          	srli	s4,s4,0x20
    80200624:	00001797          	auipc	a5,0x1
    80200628:	bd478793          	addi	a5,a5,-1068 # 802011f8 <error_string+0x38>
    8020062c:	9a3e                	add	s4,s4,a5
    8020062e:	7402                	ld	s0,32(sp)
    80200630:	000a4503          	lbu	a0,0(s4)
    80200634:	70a2                	ld	ra,40(sp)
    80200636:	69a2                	ld	s3,8(sp)
    80200638:	6a02                	ld	s4,0(sp)
    8020063a:	85ca                	mv	a1,s2
    8020063c:	8326                	mv	t1,s1
    8020063e:	6942                	ld	s2,16(sp)
    80200640:	64e2                	ld	s1,24(sp)
    80200642:	6145                	addi	sp,sp,48
    80200644:	8302                	jr	t1
    80200646:	03065633          	divu	a2,a2,a6
    8020064a:	8722                	mv	a4,s0
    8020064c:	f9bff0ef          	jal	ra,802005e6 <printnum>
    80200650:	b7f9                	j	8020061e <printnum+0x38>

0000000080200652 <vprintfmt>:
    80200652:	7119                	addi	sp,sp,-128
    80200654:	f4a6                	sd	s1,104(sp)
    80200656:	f0ca                	sd	s2,96(sp)
    80200658:	e8d2                	sd	s4,80(sp)
    8020065a:	e4d6                	sd	s5,72(sp)
    8020065c:	e0da                	sd	s6,64(sp)
    8020065e:	fc5e                	sd	s7,56(sp)
    80200660:	f862                	sd	s8,48(sp)
    80200662:	f06a                	sd	s10,32(sp)
    80200664:	fc86                	sd	ra,120(sp)
    80200666:	f8a2                	sd	s0,112(sp)
    80200668:	ecce                	sd	s3,88(sp)
    8020066a:	f466                	sd	s9,40(sp)
    8020066c:	ec6e                	sd	s11,24(sp)
    8020066e:	892a                	mv	s2,a0
    80200670:	84ae                	mv	s1,a1
    80200672:	8d32                	mv	s10,a2
    80200674:	8ab6                	mv	s5,a3
    80200676:	5b7d                	li	s6,-1
    80200678:	00001a17          	auipc	s4,0x1
    8020067c:	9eca0a13          	addi	s4,s4,-1556 # 80201064 <etext+0x5fa>
    80200680:	05e00b93          	li	s7,94
    80200684:	00001c17          	auipc	s8,0x1
    80200688:	b3cc0c13          	addi	s8,s8,-1220 # 802011c0 <error_string>
    8020068c:	000d4503          	lbu	a0,0(s10)
    80200690:	02500793          	li	a5,37
    80200694:	001d0413          	addi	s0,s10,1
    80200698:	00f50e63          	beq	a0,a5,802006b4 <vprintfmt+0x62>
    8020069c:	c521                	beqz	a0,802006e4 <vprintfmt+0x92>
    8020069e:	02500993          	li	s3,37
    802006a2:	a011                	j	802006a6 <vprintfmt+0x54>
    802006a4:	c121                	beqz	a0,802006e4 <vprintfmt+0x92>
    802006a6:	85a6                	mv	a1,s1
    802006a8:	0405                	addi	s0,s0,1
    802006aa:	9902                	jalr	s2
    802006ac:	fff44503          	lbu	a0,-1(s0)
    802006b0:	ff351ae3          	bne	a0,s3,802006a4 <vprintfmt+0x52>
    802006b4:	00044603          	lbu	a2,0(s0)
    802006b8:	02000793          	li	a5,32
    802006bc:	4981                	li	s3,0
    802006be:	4801                	li	a6,0
    802006c0:	5cfd                	li	s9,-1
    802006c2:	5dfd                	li	s11,-1
    802006c4:	05500593          	li	a1,85
    802006c8:	4525                	li	a0,9
    802006ca:	fdd6069b          	addiw	a3,a2,-35
    802006ce:	0ff6f693          	andi	a3,a3,255
    802006d2:	00140d13          	addi	s10,s0,1
    802006d6:	20d5e563          	bltu	a1,a3,802008e0 <vprintfmt+0x28e>
    802006da:	068a                	slli	a3,a3,0x2
    802006dc:	96d2                	add	a3,a3,s4
    802006de:	4294                	lw	a3,0(a3)
    802006e0:	96d2                	add	a3,a3,s4
    802006e2:	8682                	jr	a3
    802006e4:	70e6                	ld	ra,120(sp)
    802006e6:	7446                	ld	s0,112(sp)
    802006e8:	74a6                	ld	s1,104(sp)
    802006ea:	7906                	ld	s2,96(sp)
    802006ec:	69e6                	ld	s3,88(sp)
    802006ee:	6a46                	ld	s4,80(sp)
    802006f0:	6aa6                	ld	s5,72(sp)
    802006f2:	6b06                	ld	s6,64(sp)
    802006f4:	7be2                	ld	s7,56(sp)
    802006f6:	7c42                	ld	s8,48(sp)
    802006f8:	7ca2                	ld	s9,40(sp)
    802006fa:	7d02                	ld	s10,32(sp)
    802006fc:	6de2                	ld	s11,24(sp)
    802006fe:	6109                	addi	sp,sp,128
    80200700:	8082                	ret
    80200702:	4705                	li	a4,1
    80200704:	008a8593          	addi	a1,s5,8
    80200708:	01074463          	blt	a4,a6,80200710 <vprintfmt+0xbe>
    8020070c:	26080363          	beqz	a6,80200972 <vprintfmt+0x320>
    80200710:	000ab603          	ld	a2,0(s5)
    80200714:	46c1                	li	a3,16
    80200716:	8aae                	mv	s5,a1
    80200718:	a06d                	j	802007c2 <vprintfmt+0x170>
    8020071a:	00144603          	lbu	a2,1(s0)
    8020071e:	4985                	li	s3,1
    80200720:	846a                	mv	s0,s10
    80200722:	b765                	j	802006ca <vprintfmt+0x78>
    80200724:	000aa503          	lw	a0,0(s5)
    80200728:	85a6                	mv	a1,s1
    8020072a:	0aa1                	addi	s5,s5,8
    8020072c:	9902                	jalr	s2
    8020072e:	bfb9                	j	8020068c <vprintfmt+0x3a>
    80200730:	4705                	li	a4,1
    80200732:	008a8993          	addi	s3,s5,8
    80200736:	01074463          	blt	a4,a6,8020073e <vprintfmt+0xec>
    8020073a:	22080463          	beqz	a6,80200962 <vprintfmt+0x310>
    8020073e:	000ab403          	ld	s0,0(s5)
    80200742:	24044463          	bltz	s0,8020098a <vprintfmt+0x338>
    80200746:	8622                	mv	a2,s0
    80200748:	8ace                	mv	s5,s3
    8020074a:	46a9                	li	a3,10
    8020074c:	a89d                	j	802007c2 <vprintfmt+0x170>
    8020074e:	000aa783          	lw	a5,0(s5)
    80200752:	4719                	li	a4,6
    80200754:	0aa1                	addi	s5,s5,8
    80200756:	41f7d69b          	sraiw	a3,a5,0x1f
    8020075a:	8fb5                	xor	a5,a5,a3
    8020075c:	40d786bb          	subw	a3,a5,a3
    80200760:	1ad74363          	blt	a4,a3,80200906 <vprintfmt+0x2b4>
    80200764:	00369793          	slli	a5,a3,0x3
    80200768:	97e2                	add	a5,a5,s8
    8020076a:	639c                	ld	a5,0(a5)
    8020076c:	18078d63          	beqz	a5,80200906 <vprintfmt+0x2b4>
    80200770:	86be                	mv	a3,a5
    80200772:	00001617          	auipc	a2,0x1
    80200776:	b3660613          	addi	a2,a2,-1226 # 802012a8 <error_string+0xe8>
    8020077a:	85a6                	mv	a1,s1
    8020077c:	854a                	mv	a0,s2
    8020077e:	240000ef          	jal	ra,802009be <printfmt>
    80200782:	b729                	j	8020068c <vprintfmt+0x3a>
    80200784:	00144603          	lbu	a2,1(s0)
    80200788:	2805                	addiw	a6,a6,1
    8020078a:	846a                	mv	s0,s10
    8020078c:	bf3d                	j	802006ca <vprintfmt+0x78>
    8020078e:	4705                	li	a4,1
    80200790:	008a8593          	addi	a1,s5,8
    80200794:	01074463          	blt	a4,a6,8020079c <vprintfmt+0x14a>
    80200798:	1e080263          	beqz	a6,8020097c <vprintfmt+0x32a>
    8020079c:	000ab603          	ld	a2,0(s5)
    802007a0:	46a1                	li	a3,8
    802007a2:	8aae                	mv	s5,a1
    802007a4:	a839                	j	802007c2 <vprintfmt+0x170>
    802007a6:	03000513          	li	a0,48
    802007aa:	85a6                	mv	a1,s1
    802007ac:	e03e                	sd	a5,0(sp)
    802007ae:	9902                	jalr	s2
    802007b0:	85a6                	mv	a1,s1
    802007b2:	07800513          	li	a0,120
    802007b6:	9902                	jalr	s2
    802007b8:	0aa1                	addi	s5,s5,8
    802007ba:	ff8ab603          	ld	a2,-8(s5)
    802007be:	6782                	ld	a5,0(sp)
    802007c0:	46c1                	li	a3,16
    802007c2:	876e                	mv	a4,s11
    802007c4:	85a6                	mv	a1,s1
    802007c6:	854a                	mv	a0,s2
    802007c8:	e1fff0ef          	jal	ra,802005e6 <printnum>
    802007cc:	b5c1                	j	8020068c <vprintfmt+0x3a>
    802007ce:	000ab603          	ld	a2,0(s5)
    802007d2:	0aa1                	addi	s5,s5,8
    802007d4:	1c060663          	beqz	a2,802009a0 <vprintfmt+0x34e>
    802007d8:	00160413          	addi	s0,a2,1
    802007dc:	17b05c63          	blez	s11,80200954 <vprintfmt+0x302>
    802007e0:	02d00593          	li	a1,45
    802007e4:	14b79263          	bne	a5,a1,80200928 <vprintfmt+0x2d6>
    802007e8:	00064783          	lbu	a5,0(a2)
    802007ec:	0007851b          	sext.w	a0,a5
    802007f0:	c905                	beqz	a0,80200820 <vprintfmt+0x1ce>
    802007f2:	000cc563          	bltz	s9,802007fc <vprintfmt+0x1aa>
    802007f6:	3cfd                	addiw	s9,s9,-1
    802007f8:	036c8263          	beq	s9,s6,8020081c <vprintfmt+0x1ca>
    802007fc:	85a6                	mv	a1,s1
    802007fe:	18098463          	beqz	s3,80200986 <vprintfmt+0x334>
    80200802:	3781                	addiw	a5,a5,-32
    80200804:	18fbf163          	bleu	a5,s7,80200986 <vprintfmt+0x334>
    80200808:	03f00513          	li	a0,63
    8020080c:	9902                	jalr	s2
    8020080e:	0405                	addi	s0,s0,1
    80200810:	fff44783          	lbu	a5,-1(s0)
    80200814:	3dfd                	addiw	s11,s11,-1
    80200816:	0007851b          	sext.w	a0,a5
    8020081a:	fd61                	bnez	a0,802007f2 <vprintfmt+0x1a0>
    8020081c:	e7b058e3          	blez	s11,8020068c <vprintfmt+0x3a>
    80200820:	3dfd                	addiw	s11,s11,-1
    80200822:	85a6                	mv	a1,s1
    80200824:	02000513          	li	a0,32
    80200828:	9902                	jalr	s2
    8020082a:	e60d81e3          	beqz	s11,8020068c <vprintfmt+0x3a>
    8020082e:	3dfd                	addiw	s11,s11,-1
    80200830:	85a6                	mv	a1,s1
    80200832:	02000513          	li	a0,32
    80200836:	9902                	jalr	s2
    80200838:	fe0d94e3          	bnez	s11,80200820 <vprintfmt+0x1ce>
    8020083c:	bd81                	j	8020068c <vprintfmt+0x3a>
    8020083e:	4705                	li	a4,1
    80200840:	008a8593          	addi	a1,s5,8
    80200844:	01074463          	blt	a4,a6,8020084c <vprintfmt+0x1fa>
    80200848:	12080063          	beqz	a6,80200968 <vprintfmt+0x316>
    8020084c:	000ab603          	ld	a2,0(s5)
    80200850:	46a9                	li	a3,10
    80200852:	8aae                	mv	s5,a1
    80200854:	b7bd                	j	802007c2 <vprintfmt+0x170>
    80200856:	00144603          	lbu	a2,1(s0)
    8020085a:	02d00793          	li	a5,45
    8020085e:	846a                	mv	s0,s10
    80200860:	b5ad                	j	802006ca <vprintfmt+0x78>
    80200862:	85a6                	mv	a1,s1
    80200864:	02500513          	li	a0,37
    80200868:	9902                	jalr	s2
    8020086a:	b50d                	j	8020068c <vprintfmt+0x3a>
    8020086c:	000aac83          	lw	s9,0(s5)
    80200870:	00144603          	lbu	a2,1(s0)
    80200874:	0aa1                	addi	s5,s5,8
    80200876:	846a                	mv	s0,s10
    80200878:	e40dd9e3          	bgez	s11,802006ca <vprintfmt+0x78>
    8020087c:	8de6                	mv	s11,s9
    8020087e:	5cfd                	li	s9,-1
    80200880:	b5a9                	j	802006ca <vprintfmt+0x78>
    80200882:	00144603          	lbu	a2,1(s0)
    80200886:	03000793          	li	a5,48
    8020088a:	846a                	mv	s0,s10
    8020088c:	bd3d                	j	802006ca <vprintfmt+0x78>
    8020088e:	fd060c9b          	addiw	s9,a2,-48
    80200892:	00144603          	lbu	a2,1(s0)
    80200896:	846a                	mv	s0,s10
    80200898:	fd06069b          	addiw	a3,a2,-48
    8020089c:	0006089b          	sext.w	a7,a2
    802008a0:	fcd56ce3          	bltu	a0,a3,80200878 <vprintfmt+0x226>
    802008a4:	0405                	addi	s0,s0,1
    802008a6:	002c969b          	slliw	a3,s9,0x2
    802008aa:	00044603          	lbu	a2,0(s0)
    802008ae:	0196873b          	addw	a4,a3,s9
    802008b2:	0017171b          	slliw	a4,a4,0x1
    802008b6:	0117073b          	addw	a4,a4,a7
    802008ba:	fd06069b          	addiw	a3,a2,-48
    802008be:	fd070c9b          	addiw	s9,a4,-48
    802008c2:	0006089b          	sext.w	a7,a2
    802008c6:	fcd57fe3          	bleu	a3,a0,802008a4 <vprintfmt+0x252>
    802008ca:	b77d                	j	80200878 <vprintfmt+0x226>
    802008cc:	fffdc693          	not	a3,s11
    802008d0:	96fd                	srai	a3,a3,0x3f
    802008d2:	00ddfdb3          	and	s11,s11,a3
    802008d6:	00144603          	lbu	a2,1(s0)
    802008da:	2d81                	sext.w	s11,s11
    802008dc:	846a                	mv	s0,s10
    802008de:	b3f5                	j	802006ca <vprintfmt+0x78>
    802008e0:	85a6                	mv	a1,s1
    802008e2:	02500513          	li	a0,37
    802008e6:	9902                	jalr	s2
    802008e8:	fff44703          	lbu	a4,-1(s0)
    802008ec:	02500793          	li	a5,37
    802008f0:	8d22                	mv	s10,s0
    802008f2:	d8f70de3          	beq	a4,a5,8020068c <vprintfmt+0x3a>
    802008f6:	02500713          	li	a4,37
    802008fa:	1d7d                	addi	s10,s10,-1
    802008fc:	fffd4783          	lbu	a5,-1(s10)
    80200900:	fee79de3          	bne	a5,a4,802008fa <vprintfmt+0x2a8>
    80200904:	b361                	j	8020068c <vprintfmt+0x3a>
    80200906:	00001617          	auipc	a2,0x1
    8020090a:	99260613          	addi	a2,a2,-1646 # 80201298 <error_string+0xd8>
    8020090e:	85a6                	mv	a1,s1
    80200910:	854a                	mv	a0,s2
    80200912:	0ac000ef          	jal	ra,802009be <printfmt>
    80200916:	bb9d                	j	8020068c <vprintfmt+0x3a>
    80200918:	00001617          	auipc	a2,0x1
    8020091c:	97860613          	addi	a2,a2,-1672 # 80201290 <error_string+0xd0>
    80200920:	00001417          	auipc	s0,0x1
    80200924:	97140413          	addi	s0,s0,-1679 # 80201291 <error_string+0xd1>
    80200928:	8532                	mv	a0,a2
    8020092a:	85e6                	mv	a1,s9
    8020092c:	e032                	sd	a2,0(sp)
    8020092e:	e43e                	sd	a5,8(sp)
    80200930:	102000ef          	jal	ra,80200a32 <strnlen>
    80200934:	40ad8dbb          	subw	s11,s11,a0
    80200938:	6602                	ld	a2,0(sp)
    8020093a:	01b05d63          	blez	s11,80200954 <vprintfmt+0x302>
    8020093e:	67a2                	ld	a5,8(sp)
    80200940:	2781                	sext.w	a5,a5
    80200942:	e43e                	sd	a5,8(sp)
    80200944:	6522                	ld	a0,8(sp)
    80200946:	85a6                	mv	a1,s1
    80200948:	e032                	sd	a2,0(sp)
    8020094a:	3dfd                	addiw	s11,s11,-1
    8020094c:	9902                	jalr	s2
    8020094e:	6602                	ld	a2,0(sp)
    80200950:	fe0d9ae3          	bnez	s11,80200944 <vprintfmt+0x2f2>
    80200954:	00064783          	lbu	a5,0(a2)
    80200958:	0007851b          	sext.w	a0,a5
    8020095c:	e8051be3          	bnez	a0,802007f2 <vprintfmt+0x1a0>
    80200960:	b335                	j	8020068c <vprintfmt+0x3a>
    80200962:	000aa403          	lw	s0,0(s5)
    80200966:	bbf1                	j	80200742 <vprintfmt+0xf0>
    80200968:	000ae603          	lwu	a2,0(s5)
    8020096c:	46a9                	li	a3,10
    8020096e:	8aae                	mv	s5,a1
    80200970:	bd89                	j	802007c2 <vprintfmt+0x170>
    80200972:	000ae603          	lwu	a2,0(s5)
    80200976:	46c1                	li	a3,16
    80200978:	8aae                	mv	s5,a1
    8020097a:	b5a1                	j	802007c2 <vprintfmt+0x170>
    8020097c:	000ae603          	lwu	a2,0(s5)
    80200980:	46a1                	li	a3,8
    80200982:	8aae                	mv	s5,a1
    80200984:	bd3d                	j	802007c2 <vprintfmt+0x170>
    80200986:	9902                	jalr	s2
    80200988:	b559                	j	8020080e <vprintfmt+0x1bc>
    8020098a:	85a6                	mv	a1,s1
    8020098c:	02d00513          	li	a0,45
    80200990:	e03e                	sd	a5,0(sp)
    80200992:	9902                	jalr	s2
    80200994:	8ace                	mv	s5,s3
    80200996:	40800633          	neg	a2,s0
    8020099a:	46a9                	li	a3,10
    8020099c:	6782                	ld	a5,0(sp)
    8020099e:	b515                	j	802007c2 <vprintfmt+0x170>
    802009a0:	01b05663          	blez	s11,802009ac <vprintfmt+0x35a>
    802009a4:	02d00693          	li	a3,45
    802009a8:	f6d798e3          	bne	a5,a3,80200918 <vprintfmt+0x2c6>
    802009ac:	00001417          	auipc	s0,0x1
    802009b0:	8e540413          	addi	s0,s0,-1819 # 80201291 <error_string+0xd1>
    802009b4:	02800513          	li	a0,40
    802009b8:	02800793          	li	a5,40
    802009bc:	bd1d                	j	802007f2 <vprintfmt+0x1a0>

00000000802009be <printfmt>:
    802009be:	715d                	addi	sp,sp,-80
    802009c0:	02810313          	addi	t1,sp,40
    802009c4:	f436                	sd	a3,40(sp)
    802009c6:	869a                	mv	a3,t1
    802009c8:	ec06                	sd	ra,24(sp)
    802009ca:	f83a                	sd	a4,48(sp)
    802009cc:	fc3e                	sd	a5,56(sp)
    802009ce:	e0c2                	sd	a6,64(sp)
    802009d0:	e4c6                	sd	a7,72(sp)
    802009d2:	e41a                	sd	t1,8(sp)
    802009d4:	c7fff0ef          	jal	ra,80200652 <vprintfmt>
    802009d8:	60e2                	ld	ra,24(sp)
    802009da:	6161                	addi	sp,sp,80
    802009dc:	8082                	ret

00000000802009de <sbi_console_putchar>:
    802009de:	00003797          	auipc	a5,0x3
    802009e2:	62278793          	addi	a5,a5,1570 # 80204000 <bootstacktop>
    802009e6:	6398                	ld	a4,0(a5)
    802009e8:	4781                	li	a5,0
    802009ea:	88ba                	mv	a7,a4
    802009ec:	852a                	mv	a0,a0
    802009ee:	85be                	mv	a1,a5
    802009f0:	863e                	mv	a2,a5
    802009f2:	00000073          	ecall
    802009f6:	87aa                	mv	a5,a0
    802009f8:	8082                	ret

00000000802009fa <sbi_set_timer>:
    802009fa:	00003797          	auipc	a5,0x3
    802009fe:	61678793          	addi	a5,a5,1558 # 80204010 <edata>
    80200a02:	6398                	ld	a4,0(a5)
    80200a04:	4781                	li	a5,0
    80200a06:	88ba                	mv	a7,a4
    80200a08:	852a                	mv	a0,a0
    80200a0a:	85be                	mv	a1,a5
    80200a0c:	863e                	mv	a2,a5
    80200a0e:	00000073          	ecall
    80200a12:	87aa                	mv	a5,a0
    80200a14:	8082                	ret

0000000080200a16 <sbi_shutdown>:
    80200a16:	00003797          	auipc	a5,0x3
    80200a1a:	5f278793          	addi	a5,a5,1522 # 80204008 <SBI_SHUTDOWN>
    80200a1e:	6398                	ld	a4,0(a5)
    80200a20:	4781                	li	a5,0
    80200a22:	88ba                	mv	a7,a4
    80200a24:	853e                	mv	a0,a5
    80200a26:	85be                	mv	a1,a5
    80200a28:	863e                	mv	a2,a5
    80200a2a:	00000073          	ecall
    80200a2e:	87aa                	mv	a5,a0
    80200a30:	8082                	ret

0000000080200a32 <strnlen>:
    80200a32:	c185                	beqz	a1,80200a52 <strnlen+0x20>
    80200a34:	00054783          	lbu	a5,0(a0)
    80200a38:	cf89                	beqz	a5,80200a52 <strnlen+0x20>
    80200a3a:	4781                	li	a5,0
    80200a3c:	a021                	j	80200a44 <strnlen+0x12>
    80200a3e:	00074703          	lbu	a4,0(a4)
    80200a42:	c711                	beqz	a4,80200a4e <strnlen+0x1c>
    80200a44:	0785                	addi	a5,a5,1
    80200a46:	00f50733          	add	a4,a0,a5
    80200a4a:	fef59ae3          	bne	a1,a5,80200a3e <strnlen+0xc>
    80200a4e:	853e                	mv	a0,a5
    80200a50:	8082                	ret
    80200a52:	4781                	li	a5,0
    80200a54:	853e                	mv	a0,a5
    80200a56:	8082                	ret

0000000080200a58 <memset>:
    80200a58:	ca01                	beqz	a2,80200a68 <memset+0x10>
    80200a5a:	962a                	add	a2,a2,a0
    80200a5c:	87aa                	mv	a5,a0
    80200a5e:	0785                	addi	a5,a5,1
    80200a60:	feb78fa3          	sb	a1,-1(a5)
    80200a64:	fec79de3          	bne	a5,a2,80200a5e <memset+0x6>
    80200a68:	8082                	ret
