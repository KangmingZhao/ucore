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

### 设计过程：
do_fork函数执行逻辑：
--
- do_fork函数调用copy_mm函数实现进程mm的复制，后者根据clone_flags & CLONE_VM的取值调用了dup_mmap函数。
- dup_mmap函数在两个进程之间复制内存映射关系。具体来说，该函数的两个参数分别表示目标进程和源进程的内存管理结构mm。然后通过循环迭代，每次创建一个新的内存映射区域（vma），然后将其插入到目标进程的mm中，之后调用copy_range函数将源进程的内存映射区域的内容复制到目标进程中。
- copy_range函数：

        1.函数首先通过断言确保start和end是页面对齐且属于用户地址空间的。然后通过循环每次处理一页数据。在每次迭代中，函数调用 get_pte 函数查找源进程 A 的页表项（pte），如果不存在，则跳过当前页并继续下一个页面。如果 pte 存在，则再调用 get_pte 函数查找目标进程 B 的页表项（nptep）。如果 nptep 不存在，则分配一个新的页表并建立映射。

        2.函数调用 alloc_page 函数为进程 B 分配一个新的物理页面（npage）。然后，函数将源进程 A的物理页面（page）中的内容复制到新的物理页面中。具体实现上，就是通过page2kva函数获取到目标进程和源进程各自页面的虚拟地址，然后使用memcpy函数实现复制。页面复制完成后，函数再调用page_insert 函数将新的物理页面与目标进程 B 的线性地址建立映射。
        接下来将给出实验代码完成部分的步骤：
            (1)首先找到待拷贝的源地址和目的地址，
            (2)然后使用memcpy函数复制一个页（每次一个页）的内容至的地址
            (3) 最后建立虚拟地址到物理地址的映射。
    ```c
    void * kva_src = page2kva(page);
    void * kva_dst = page2kva(npage);
    memcpy(kva_dst, kva_src, PGSIZE);
    ret = page_insert(to, npage, start, perm);
    assert(ret == 0);
    ```
### Copy on Write实现机制
- 在父进程执行do_fork函数创建子进程时进行浅拷贝：在进行内存复制的部分，比如copy_range函数内部，不实际进行内存的复制，而是将子进程和父进程的虚拟页映射上同一个物理页面，然后在分别在这两个进程的虚拟页对应的PTE部分将这个页置成是只读，在任一进程中尝试写入都会触发page fault。

- 当子进程尝试写入共享的只读页面时，会触发页错误。在页错误处理中，执行深拷贝：
    - 为子进程额外申请分配一个新的物理页面。
    - 将共享页面的内容复制到新的物理页面。
    - 建立子进程出错的线性地址与新创建的物理页面的映射关系。
    - 将子进程的页表项的写标志位设置，使得这个新页面成为子进程私有的。
    - 查询原先共享的物理页面是否仍然由多个其他进程共享。如果没有其他进程共享，就修改对应的虚地址的PTE，去除共享标记，并恢复写标志位。
## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）
请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

- 请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？
- 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）

### 代码中有的系统调用
```c
#define SYS_exit            1
#define SYS_fork            2
#define SYS_wait            3
#define SYS_exec            4
#define SYS_clone           5
#define SYS_yield           10
#define SYS_sleep           11
#define SYS_kill            12
#define SYS_gettime         17
#define SYS_getpid          18
#define SYS_brk             19
#define SYS_mmap            20
#define SYS_munmap          21
#define SYS_shmem           22
#define SYS_putc            30
#define SYS_pgdir           31
```

这些东西存在的意义是，为了避免程序员进行一些有意或无意的危险或者复杂的操作导致整个机器出现问题，操作系统会对用户态的应用程序能执行的指令进行一系列的限制。比如说对于磁盘之类的慢操作或者是需要给当前进程的时间片进行更新的高权限操作，在ring3级别的用户态下cpu是不能执行的，虽然中断可以提高cpu的权限去处理中断事件，但是等待时钟中断才能进行一个都磁盘之类的操作是不可忍受的，于是有了这一系列的syscall来实现可以手动呼叫更高权限的情况。

对于这些系统调用，在用户的syscall.h库预留了一些接口可以方便的进行相关的系统调用，虽然让我们分析的并不主要是sys_getpid，但是因为它在这显示的体现了这个关系所以用来举例（注意在内核中的syscall.h和这个是不一样的。这里是用户层的syscall，它能做到只是发出syscall，而内核中的则是响应这些对应的syscall的类似中断向量表的东西。）

```c
int
sys_getpid(void) {
    return syscall(SYS_getpid);
}

static inline int
syscall(int64_t num, ...) {
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
    }
    va_end(ap);

    asm volatile (
        "ld a0, %1\n"
        "ld a1, %2\n"
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
    	"ld a5, %6\n"
        "ecall\n"
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
```
这里顺带分析一下这个系统调用函数。它的num是反映了现在是哪个系统调用，因为有些系统调用是要传入错误号之类的所以用边长的参数。再汇编代码中，将系统调用号和最多五个参数存放进对应的寄存器，然后使用ecall呼叫系统调用，并在结束后把这次调用的返回值存在ret中。

而在我们的hello.c中显示的出现了：
```c
cprintf("I am process %d.\n", getpid());
```
在ulib的库函数中找到了这个的定义：
```c
int
getpid(void) {
    return sys_getpid();
}
```
这个过程简化来说就是用户调用了一个c库中的函数，这个函数总之就会在用户态的syscall库中调用系统调用，等着进入了ring0后的cpu根据呼叫高权限时存入的上下文来处理对应的系统调用，接着再回到用户态。

这些库函数实际上在这个过程中要做的只是给我们提供了一个可以方便的调用处理复杂的系统调用的过程，简化编程，因为并不是所有人都可以自如地在代码中完美的编写复杂的各种int和把上下文挪来挪去。

### 那么现在就可以来分析一下需要这四个主要关注的系统调用了。

根据课上的内容，我们的代码编译出来的程序在执行时应该是由内核态的操作系统的进程fork出来然后exec之后得以执行，但是这里似乎只是在问用户态的进程如何fork出子进程。

- 首先是fork
	- 首先不管在什么地方fork的返回值都是大差不差的，0表示这个是子进程，父进程得到的则是它的子进程的pid。
	- 在用户态调用fork时，会先调用ulib库里的sys_fork函数，它会调用syscall库里的sys_fork。到此为止都是在用户态发生的事情。（而且这些函数的返回值都是int，所以一层层返回回去就可以得到pid或者0.）
	- 在用户态系统调用sys_fork后就由内核态接手了。由于在用户态调用了ecall后系统就中断了，这是后内核态就会看看发生了啥事，在trap.c中如果发现当前中断的原因是CAUSE_USER_ECALL，那么就说明这个是人为的系统调用，接着会调用内核态的syscall函数来接收调用syscall时的上下文（其实CAUSE_SUPERVISOR_ECALL和CAUSE_BREAKPOINT也会触发系统调用。关于特权态的系统调用CAUSE_SUPERVISOR_ECALL，暂时理解为即使处于特权态也有些操作需要系统调用才能完成。而断点的CAUSE_BREAKPOINT应该是为了方便程序员在调试的时候对系统调用进行检查。在实验指导书中，说到这个东西是因为在内核态创建第一个用户态进程时不能通过ecall来系统中断，于是搞了这个东西。）。接着通过syscalls函数进入对应的系统调用处理函数，把处理结果通过写入寄存器等着返回用户态后接收上下文。这里的sys_fork函数对应的是内核态的do_fork，也就是上节课写的把当前进程fork一个的函数。fork完事后事实上当前已经是有两个进程了，于是一个返回0一个返回pid，作为新的上下文返回给到触发系统调用的用户态的位置。
	
- 然后是exec。
	- 首先在内核态有一个关于exec的部分。第一个用户态进程是由内核态进程fork来的。所以在内核态初始化fork出来的这个子进程的时候会在init_main中调用kernel_thread把刚刚fork来的子进程通过系统调用加载应用程序。
	- 然后在这个已经变成用户态的进程执行的程序中，如果调用exec，此时就已经是在用户态调用了。它会通过和上述差不多的各种用户态的库函数的倒腾最终进行真正的系统调用，进入内核态。在内核态中，用户态下系统调用的exec会进入do_execve函数。这个函数写练习一的同学介绍的已经很详细了。

- 然后是wait
	- 这一般是父进程做的事情。父进程会在调用wait后，进入到内核态，此时它会一直阻塞着等它的子进程结束或者出什么问题，负责回收其子进程，一切都结束后重新回到用户态。
	- 具体实现上，这位大体流程和fork差不多。经过一系列给予的接口到达内核态后，它进入内核态的do_wait函数。如果指定了pid，那么会一直等到它变成了僵尸进程后进入WT_CHILD状态，并使用schedule让出cpu的执行权。一旦子进程终止，就负责把他释放了。如果pid是0，那么会干类似的事，但是是找到随便一个僵尸子进程就进行上述操作。
	- 返回0表示成功执行了上述操作。
	
- 最后是exit。
	- 在用户态发生的事基本同上，都是遇到函数后通过库的系统调用进入到内核态的函数调用处理代码。这里是进入do_exit。
	- 首先idleproc和initproc不允许退出。initproc退出了一切都完了。
	- 因为我的进程退出了，所以我这个进程有关的页面引用都要全员-1.（如果-1完后这个mm_struct就没人引用了，那么就可以顺手释放它了）
	- 接着我当前进程就变成PROC_ZOMBIE了。可以告诉父亲进程（如果父亲没了就由initproc来负责）我准备可以回收了。如果进程的父亲正在因为WT_CHILD阻塞，那么就使用wakeup_proc唤醒它。
	- 因为这个进程要被父亲回收，不能让它的子进程断掉变成孤儿进程，于是把子进程全部移到initproc的子进程列表下（这里有点不明白，为什么不直接作为父进程把子进程全部回收了，而是要放到initproc下，至少我能瞬间想到的程序都是一旦把主窗口关了，衍生窗口也瞬间没了。也许是因为有些程序的期望是父进程关了但子进程应该还需要运行一定时间，但是又不能没有东西负责回收它，于是才这么做的。毕竟虽然说initproc能不停的扫描僵尸进程，但是失去父节点的子进程应该很难找到，而且扫描不现实，所以才这么做的吧。）
	- 最后使用schedule 让出cpu使用权。


### 周期图：
	alloc_proc()(状态:PROC_UNINIT) 
	↓
	proc_init()(状态:PROC_RUNNABLE,但不一定在run) 
	↓
	wakeup_proc()(状态：PROC_RUNNABLE，而且可以run)
	↓
	proc_run()(状态：开始run)
	↓
	在遇到类似do_yield（自愿让出运行权）、遇到一个IRQ_S_TIMER（当前进程时间片用完了）、理论上来说应该在写文件等慢操作时也这样但这里还没有文件系统所以没写的慢操作等情况下，状态还是就绪的PROC_RUNNABLE但是不能实际的run了。
	↓
	如果我是个父进程，那么在等待子进程结束前一直处于PROC_SLEEPING。而且我sleep的目的是WT_CHILD。
	↓
	do_exit()(状态：PROC_ZOMBIE)
	↓
	这个流程图的进程的父亲调用do_wait(状态：结束)
										
										

执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。（使用的是qemu-1.0.1）

## 扩展练习 Challenge
1.实现 Copy on Write （COW）机制

给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。

由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。

这是一个big challenge.

2.说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？

- 本次实验中，用户程序是通过```execve``` 系统调用时被预先加载到内存中的。与我们常用的操作系统加载过程的区别主要在于执行上述加载步骤的时机。
在常用的操作系统中，用户程序通常在运行时（才被加载到内存。当用户启动程序或运行可执行文件时，操作系统负责将程序从磁盘加载到内存，然后执行。这么做的原因是简化用户程序执行过程：预先加载用户程序可以简化用户程序的执行过程，使得执行过程更加直接和快速。