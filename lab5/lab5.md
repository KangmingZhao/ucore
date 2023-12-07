# Lab5实验报告

## 练习
对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 练习0：填写已有实验
本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

## 练习1: 加载应用程序并执行（需要编码）
do_execv函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充load_icode的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

- 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。
### 实现过程
load_icode函数被do_execv函数调用，来加载并解析一个处于内存中的ELF执行文件格式的应用程序，所以我们首先来看do_execv函数：
```c
// 主要目的在于清理原来进程的内存空间，为新进程执行准备好空间和资源
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size)
{
struct mm_struct *mm = current->mm;

// 检查传入的进程名是否合法
if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
    return -E_INVAL;  // 返回无效参数错误码
}

// 若进程名长度超过最大长度，则截断为最大长度
if (len > PROC_NAME_LEN) {
    len = PROC_NAME_LEN;
}

// 将进程名复制到本地字符数组local_name中
char local_name[PROC_NAME_LEN + 1];
memset(local_name, 0, sizeof(local_name));
memcpy(local_name, name, len);

// 如果当前进程具有内存管理结构体mm，则进行清理操作
if (mm != NULL) 
{
    // 将CR3页表基址指向boot_cr3，即内核页表，切换到内核态
    lcr3(boot_cr3);
    
    // 如果当前进程的内存管理结构引用计数减为0，则清空相关内存管理区域和页表
    if (mm_count_dec(mm) == 0) 
    {  
        exit_mmap(mm);  // 清空内存管理部分和对应页表
        put_pgdir(mm);  // 清空页表
        mm_destroy(mm); // 清空内存
    }
    
    current->mm = NULL;  // 将当前进程的内存管理结构指针设为NULL，表示没有有效的内存管理结构
}

int ret;

// 加载新的可执行程序并建立新的内存映射关系，这里用到了我们要写的load_icode函数！！！
if ((ret = load_icode(binary, size)) != 0) {
    goto execve_exit;  // 发生错误则跳转到execve_exit标签处进行处理
}

// 给新进程设置进程名
set_proc_name(current, local_name);

return 0;
execve_exit:
do_exit(ret);  // 执行出错，退出当前进程，并传递错误码ret
panic("already exit: %e.\n", ret);  // 引发内核恐慌，输出错误信息
}
```
这个函数的作用是执行一个新的可执行程序，它的具体过程如下：
- 检查传入的进程名是否合法。
- 如果当前进程存在内存管理结构体mm，则进行清理操作，包括清空内存管理部分和对应页表。
- 将CR3页表基址指向内核的页表，切换到内核态。
- 加载新的可执行程序并建立新的内存映射关系。
- 给新进程设置进程名。
- 返回0表示成功执行新程序；如果发生错误，则退出当前进程，并传递相应的错误码。

接下来再进入我们要完成的load_icode函数分析:

load_icode函数的主要工作就是给用户进程建立一个能够让用户进程正常运行的用户环境，它的具体步骤解释如下：
- 创建一个新的mm结构体，用于管理用户进程的内存空间。
- 创建页目录表，将mm结构体的pgdir指向页目录表的内核虚拟地址。
- 校验ELF文件的魔数是否正确，确保ELF文件的格式正确。
- 遍历ELF文件的program section headers，对每个类型为ELF_PT_LOAD的section进行处理：
  - 调用mm_map函数，将ELF文件中该section所描述的虚拟地址空间映射到当前用户进程的内存空间中。
  - 为虚拟地址空间分配内存，并将ELF文件中该section的内容拷贝到虚拟地址空间中。
  - 如果该section是BSS section，则需要额外进行初始化为全0。
- 分配用户栈内存空间，用于用户进程的栈操作。
- 设置当前用户进程的mm结构体、页目录表的地址及将页目录表的物理地址加载到cr3寄存器中，用于进程切换时的地址空间切换。
- 设置当前用户进程的trapframe结构体，包括：
  - 将tf->gpr.sp设置为用户栈的顶部地址，用于在用户模式下正确操作栈。
  - 将tf->epc设置为用户程序的入口地址，用于执行用户程序。
  - 将tf->status设置为适当的值，清除SSTATUS_SPP和SSTATUS_SPIE位，用于确保特权级别被正确设置为用户模式，并且中断被禁用，以便用户程序在预期的环境中执行。

我们需要填写的部分只有第六部分，也就是要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。具体补充的代码如下：
```c
//(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 2110697段钧淇
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */
    tf->gpr.sp = USTACKTOP; // 设置f->gpr.sp为用户栈的顶部地址
    tf->epc = elf->e_entry; // 设置tf->epc为用户程序的入口地址
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE); // 根据需要设置 tf->status 的值，清除 SSTATUS_SPP 和 SSTATUS_SPIE 位
    /*tf->gpr.sp = USTACKTOP;：在用户模式下，栈通常从高地址向低地址增长，而 USTACKTOP 是用户栈的顶部地址，
    因此将 tf->gpr.sp 设置为 USTACKTOP 可以确保用户程序在正确的栈空间中运行。
    tf->epc = elf->e_entry;：elf->e_entry 是可执行文件的入口地址，也就是用户程序的起始地址。
    通过将该地址赋值给 tf->epc，在执行 mret 指令后，处理器将会跳转到用户程序的入口开始执行。
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE);：sstatus 寄存器中的 SPP 位表示当前特权级别，SPIE 位表示之前的特权级别是否启用中断。
    通过清除这两个位，可以确保在切换到用户模式时，特权级别被正确设置为用户模式，并且中断被禁用，以便用户程序可以在预期的环境中执行。
    */
    ret = 0;
```
### 用户态进程被选中执行到第一条语句的过程 
用户态进程从被ucore选择到执行第一条指令的过程如下：

- 用户态进程首先由操作系统内核创建。操作系统会为该进程分配所需的资源，包括内存空间和其他必要的数据结构。代码里内核线程initproc创建用户态进程userproc。
- 进程被创建后，它处于就绪态，等待操作系统调度它来执行。在就绪态下，进程被加入到可运行的进程队列中。
- do_wait函数确认存在RUNNABLE的子进程后，调用schedule函数。
- schedule函数通过调用proc_run来运行新线程。
- proc_run做以下三件事：
   - a. 设置userproc的栈指针esp为userproc->kstack + 2 * 4096，即指向userproc申请到的2页栈空间的栈顶。 
   - b. 加载userproc的页目录表。用户态的页目录表与内核态的页目录表不同，因此要重新加载页目录表。 
   - c. 切换进程上下文，然后跳转到forkret。forkret函数直接调用forkrets函数，forkrets将栈指针指向userproc->tf的地址，然后跳到__trapret。
- __trapret函数将userproc->tf的内容pop给相应寄存器，然后通过iret指令，跳转到userproc->tf.epc指向的函数，即kernel_thread_entry。
- kernel_thread_entry先将edx保存的输入参数压栈，然后跳转到user_main。
- user_main打印userproc的pid和name信息，然后调用kernel_execve。
- kernel_execve执行exec系统调用，CPU检测到系统调用后，保存现场信息，然后根据中断号查找中断向量表，进入中断处理例程。
- 经过一系列的函数跳转，最终进入到exec的系统处理函数do_execve中。
- do_execve检查虚拟内存空间的合法性，释放虚拟内存空间，加载应用程序，创建新的mm结构和页目录表。
- do_execve调用load_icode函数，load_icode加载应用程序的各个program section到新申请的内存上，为BSS section分配内存并初始化为全0，分配用户栈内存空间。
- 设置当前用户进程的mm结构、页目录表的地址及加载页目录表地址到cr3寄存器。
设置当前用户进程的tf结构。
- 返回到do_execve函数，设置当前用户进程的名字为“exit”后返回。
- 通过__trapret函数将栈上保存的tf的内容pop给相应的寄存器，然后跳转到epc指向的函数，即应用程序的入口（exit.c文件中的main函数）。
- 执行用户程序。
## 练习2: 父进程复制自己的内存空间给子进程（需要编码）
创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。

请在实验报告中简要说明你的设计实现过程。

- 如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。

Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）
请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

- 请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
- 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）

执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

## 扩展练习 Challenge
1.实现 Copy on Write （COW）机制

给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。

由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。

这是一个big challenge.

2.说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？
