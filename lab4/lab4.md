# Lab4实验报告

## 练习

对实验报告的要求：
- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点
 
## 练习0：填写已有实验
本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

## 练习1：分配并初始化一个进程控制块（需要编码）
alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

完善代码如下：
```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {  
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
    	proc->pid = -1;
    	proc->runs = 0;
    	proc->kstack = NULL;
    	proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN);

    }
    return proc;
}

```
**设计思路**：
  实现内核线程首先需要给线程创建一个进程，于是我们需要给进程控制块指针（struct proc_struct* proc）初始化分配内存空间，而进程控制块指针中包含如下变量：
- state：进程状态，proc.h中定义了四种状态：创建（UNINIT）、睡眠（SLEEPING）、就绪（RUNNABLE）、退出（ZOMBIE，等待父进程回收其资源）
- pid：进程ID，调用本函数时尚未指定，默认值设为-1
- runs：线程运行总数，默认值0
- need_resched：标志位，表示该进程是否需要重新参与调度以释放CPU，初值0（false，表示不需要）
- parent：父进程控制块指针，初值NULL
- mm：用户进程虚拟内存管理单元指针，由于系统进程没有虚存，其值为NULL
- context：进程上下文，默认值全零
- tf：中断帧指针，默认值NULL
- cr3：该进程页目录表的基址寄存器，初值为ucore启动时建立好的内核虚拟空间的页目录表首地址boot_cr3（在kern/mm/pmm.c的pmm_init函数中初始化）
- flags：进程标志位，默认值0
- name：进程名数组

**问题回答**：
- context是上下文，用于保存进程切换时父进程的一些寄存器值：     ra;sp;s0;s1;s2;s3; s4; s5;s6;s7;s8;s9;s10;s11;
- tf是中断帧的指针，总是指向内核栈的某个位置：当进程从用户态转移到内核态时，中断帧tf记录了进程在被中断前的状态,比如部分寄存器的值。当内核需要跳回用户态时，需要调整中断帧以恢复让进程继续执行的各寄存器值。
 

## 练习2：为新创建的内核线程分配资源（需要编码）
创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要"fork"的东西就是stack和trapframe。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 返回新进程号- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程


请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

完善代码如下：
```c
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    if ((proc = alloc_proc()) == NULL)
        goto fork_out;
    if (setup_kstack(proc) == -E_NO_MEM)
        goto bad_fork_cleanup_proc;
    if (copy_mm(clone_flags, proc) != 0)
        goto bad_fork_cleanup_kstack;
    proc->parent = current;
    //好好研究一下为什么这个机掰stack是esp。
    //这里的是父进程的stack pointer（上方注释），也就是栈指针，我们大致是可以把它当作esp使的。
    copy_thread(proc, stack, tf);
    //local_intr_save 的作用是保护一段关键代码，确保它在执行时不会被中断打断。芝士操作系统内核和多任务环境中的常用诡计
    //我们知道，hash_proc函数因为涉及到对公共链表的修改，所以可能会导致所有被并行殴打过的人产生的ptsd：竞争问题。
    // 这里的多进程似乎只是多个进程在不断地切换，但是每次都只有一个进程在工作（实验手册：然后在通过调度器（scheduler）
    // 来让不同的内核线程在不同的时间段占用CPU执行，实现对CPU的分时共享）。这个算法叫做优先级轮转调度
    // 所以如果当有一个进程插链表插到一半突然被打断，下个进程说：兄弟该我了！那么就尴尬了
    // 
    // 这里调用local_intr_save禁止中断可以避免竞争的发生。
    /*
    看看它的关联部分：
    void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); } //这个操作是禁止中断

    static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
    }
    这里判断当前是否禁止了中断，如果没禁止，那么禁止中断然后返回1，如果已经禁止了那么直接返回0.
    #define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
    这里的do-while似乎只是一种可以帮助减少错误的高级技巧。
    */
    //于是，可以这么写：
    bool interrupt_forbidden;
    local_intr_save(interrupt_forbidden);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list, &proc->list_link);
        nr_process++;
    }
    //local_intr_restore就很明了了，如果原来是关着的那么就重新关着，如果本来是开着的那么就打开
    local_intr_restore(interrupt_forbidden);

    wakeup_proc(proc);

    ret = proc->pid;
fork_out:
    return ret;
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

```
**设计思路**：
  为了保证正确性，需要先进性多种判断。同时也要注意对数据冲突的处理。
- 首先调用 alloc_proc为proc分配一个进程。如果分配失败，那么直接返回“没有空闲进程”的错误代码。
- 然后调用setup_kstack分配内核栈。如果分配失败，那么首先把刚刚分配的proc释放掉，然后再返回“没有空闲进程”的错误代码。
- 接着调用copy_mm来复制mm_struct。目前这个函数暂时用不上。至此基本的有效性判断结束，可以开始正式处理了。
- 将当前子进程的parent指针指向current进程。
- 调用copy_thread复制线程。这里传入当前进程的stack作为esp，因为stack是栈指针。
- 比较复杂的地方来了。使用一个bool型变量interrupt_forbidden来记录当前是否禁止中断。调用local_intr_save来禁止中断，同时记录当前中断状态：如果允许中断，那么interrupt_forbidden记为1.方便在这里结束后恢复成原来的那种状态。这里使用local_intr_save和local_intr_restore之间的禁止中断的部分来保护获取pid、hash_proc和添加链表的操作。因为这些操作都是对共享的数据空间进行操作，需要防止进程间的数据冲突。这里中断就可以防止冲突是因为目前的多进程并不是真正意义上的并行执行，而是采取一种优先级轮转调度的算法，每次选取一个进程执行。如果一个进程在操作共享内存时，需要另一个进程进行了然后触发了中断，那么会产生数据冲突。
- 可以将proc的状态设为PROC_RUNNABLE
- 最后返回proc的pid。

**问题回答**：
- 也许这里问的是唯一的pid？：首先我们使用保护区将分配id的部分保护了起来，这样就保证了不会出现在分配id、插入链表时出现异常。而get_pid事实上也足够严谨。首先我们直到pid的存量是线程数的两倍，然后线程在链表中并非按照pid的大小顺序存放的。于是我们用last_pid来记录上一个可用的pid，next_safe来记录比last_pid大但仍是可分配的安全pid。在遍历链表的途中，如果遇到last_pid等于当前已有的进程的pid，那么就++。如果++完后的last_pid大于next_safe，那么从头遍历，同时因为last_pid也增大了所以不会再因为这次导致从头的pid而再次出现这个问题。最终得到的是唯一的pid。





## 练习3：编写proc_run 函数（需要编码）
proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用/kern/sync/sync.h中定义好的宏local_intr_save(x)和local_intr_restore(x)来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
- 允许中断。

请回答如下问题：
- 在本实验的执行过程中，创建且运行了几个内核线程？

完成代码编写后，编译并运行代码：make qemu

如果可以得到如 附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。

补充后的`proc_run`函数如下：
```c
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);
        current = proc;
        lcr3(next->cr3);
        switch_to(&(prev->context), &(next->context));
        local_intr_restore(intr_flag);
    }
}
```
根据注释中的提示，我的代码实现思路如下：
- 首先在进行上下文切换之前，定义一个bool类型的变量`intr_flag`，用于保存中断状态。

- 然后需要调用`local_intr_save`函数关闭中断，使得在上下文切换之前，中断将被禁止。这可以确保在切换到新进程之前，不会被激活的中断干扰原有进程的执行。并将禁用前的中断状态保存在`intr_flag`变量中。

- 接着将全局变量`current`更新为要切换的进程指针`proc`，表示将当前进程换为要切换到的进程。

- 之后重新加载`CR3`寄存器的值为要切换到的进程（线程）的页目录表的起始地址，完成进程间的页表切换。

- 再然后调用`switch_to`函数完成具体的两个进程（线程）的执行现场切换，即切换各个寄存器，将控制权转移到新的进程（线程）。

- 最后调用`local_intr_restore`函数，将中断状态恢复。

在本实验的执行过程中，创建且运行了几个内核线程？

答：总共创建了两个内核线程，分别为：

- `idle_proc`，为第 0 个内核线程，在一开始时使用，在完成新的内核线程的创建以及各种初始化工作之后，进入死循环，用于调度其他进程或线程。
- `init_proc`，被创建用于打印 "Hello World" 的线程，在调度后使用，是本次实验的内核线程，只用来打印目标字符串。
## 扩展练习 Challenge：
说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？

在进行进程切换的时候，需要避免出现中断干扰这个过程，所以需要在上下文切换期间清除 IF 位屏蔽中断，并且在进程恢复执行后恢复 IF 位。

- 该语句的左右是关闭中断，使得在这个语句块内的内容不会被中断打断，是一个原子操作；

- 这就使得某些关键的代码不会被打断，从而不会一起不必要的错误；

- 比如说在 proc_run 函数中，将 current 指向了要切换到的线程，但是此时还没有真正将控制权转移过去，如果在这个时候出现中断打断这些操作，就会出现 current 中保存的并不是正在运行的线程的中断控制块，从而出现错误；