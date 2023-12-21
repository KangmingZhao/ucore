# Lab8实验报告

## 练习
对实验报告的要求：

- 基于markdown格式来完成，以文本方式为主
- 填写各个基本练习中要求完成的报告内容
- 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
- 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

## 练习0：填写已有实验
本实验依赖实验2/3/4/5/6/7。请把你做的实验2/3/4/5/6/7的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”/“LAB5”/“LAB6” /“LAB7”的注释相应部分。并确保编译通过。注意：为了能够正确执行lab8的测试应用程序，可能需对已完成的实验2/3/4/5/6/7的代码进行进一步改进。

## 练习1: 完成读文件操作的实现（需要编码）
首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c中 的sfs_io_nolock()函数，实现读文件中数据的代码。

## 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）
改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行”ls”,”hello”等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。

在 proc.c 中，我们需要先先初始化 fs 中的进程控制结构，也就是得操作一下 alloc_proc 函数

需要加的就是这一句：
```proc->filesp = NULL;```
这是因为一个文件需要在 VFS 中变为一个进程才能被执行。

至于说注释里还有一些关于lab6的操作，其实不用管，因为注释里也说了，加的那些东西只有lab6会用，所以不用管，直接在lab5的基础上做就行。

更改后的alloc_proc函数如下：
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
     //LAB5 YOUR CODE : (update LAB4 steps)
    /*
     * below fields(add in LAB5) in proc_struct need to be initialized
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    //LAB6 YOUR CODE : (update LAB5 steps)
    /*
     * below fields(add in LAB6) in proc_struct need to be initialized
     *     struct run_queue *rq;                       // running queue contains Process
     *     list_entry_t run_link;                      // the entry linked in run queue
     *     int time_slice;                             // time slice for occupying the CPU
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */

     //LAB8 YOUR CODE : (update LAB6 steps)
      /*
     * below fields(add in LAB6) in proc_struct need to be initialized
     *       struct files_struct * filesp;                file struct point        
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
        proc->wait_state = 0; //PCB新增的条目，初始化进程等待状态
        proc->cptr = proc->optr = proc->yptr = NULL;//设置指针
        proc->filesp = NULL;
    }

    return proc;
}
```
然后就是要实现 `load_icode` 函数，实现后的函数如下所示：
```c
// load_icode -  called by sys_exec-->do_execve
static int
load_icode(int fd, int argc, char **kargv) {
    /* LAB8:EXERCISE2 YOUR CODE  HINT:how to load the file with handler fd  in to process's memory? how to setup argc/argv?
     * MACROs or Functions:
     *  mm_create        - create a mm
     *  setup_pgdir      - setup pgdir in mm
     *  load_icode_read  - read raw data content of program file
     *  mm_map           - build new vma
     *  pgdir_alloc_page - allocate new memory for  TEXT/DATA/BSS/stack parts
     *  lcr3             - update Page Directory Addr Register -- CR3
     */
  /* (1) create a new mm for current process
     * (2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
     * (3) copy TEXT/DATA/BSS parts in binary to memory space of process
     *    (3.1) read raw data content in file and resolve elfhdr
     *    (3.2) read raw data content in file and resolve proghdr based on info in elfhdr
     *    (3.3) call mm_map to build vma related to TEXT/DATA
     *    (3.4) callpgdir_alloc_page to allocate page for TEXT/DATA, read contents in file
     *          and copy them into the new allocated pages
     *    (3.5) callpgdir_alloc_page to allocate pages for BSS, memset zero in these pages
     * (4) call mm_map to setup user stack, and put parameters into user stack
     * (5) setup current process's mm, cr3, reset pgidr (using lcr3 MARCO)
     * (6) setup uargc and uargv in user stacks
     * (7) setup trapframe for user environment
     * (8) if up steps failed, you should cleanup the env.
     */
    assert(argc >= 0 && argc <= EXEC_MAX_ARG_NUM);
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr __elf;
    struct elfhdr *elf = &__elf;
    if((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0)
        goto bad_elf_cleanup_pgdir;
    // struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    //struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    struct proghdr __ph, *ph = &__ph;
    uint32_t vm_flags, perm, phnum;
    for (phnum = 0; phnum < elf->e_phnum; phnum ++) {
        off_t phoff = elf->e_phoff + sizeof(struct proghdr) * phnum;
        if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), phoff)) != 0) {
            goto bad_cleanup_mmap;
        }
        //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            continue ;
            // do nothing here since static variables may not occupy any space
        }
        //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        off_t offset = ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

        //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
        //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            if ((ret = load_icode_read(fd, page2kva(page) + off, size, offset)) != 0) {
                goto bad_cleanup_mmap;
            }
            start += size, offset += size;
        }
        //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;

        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    //(6) setup trapframe for user environment
    uint32_t argv_size=0, i;
    for (i = 0; i < argc; i ++) {
        argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }

    uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
    char** uargv=(char **)(stacktop  - argc * sizeof(char *));
    
    argv_size = 0;
    for (i = 0; i < argc; i ++) {
        uargv[i] = strcpy((char *)(stacktop + argv_size ), kargv[i]);
        argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }
    
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int *)stacktop = argc;
    
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
    tf->gpr.sp=stacktop;
    //tf->gpr.sp = USTACKTOP; // 设置tf->gpr.sp为用户栈的顶部地址
    tf->epc = elf->e_entry; // 设置tf->epc为用户程序的入口地址
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE); // 根据需要设置 tf->status 的值，清除 SSTATUS_SPP 和 SSTATUS_SPIE 位
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}
```
load_icode 主要是将文件加载到内存中执行，具体步骤如下：

- 1、建立内存管理器，创建一个新的mm（内存管理）结构体来管理当前进程的内存。

- 2、建立页目录，创建一个新的页目录表（PDT），并将mm的pgdir字段设置为页目录表的内核虚拟地址。

- 3、将程序文件的TEXT（代码）、DATA（数据）和BSS（未初始化数据）部分复制到进程的内存空间中：
    - 读取程序文件的原始数据内容，并解析ELF头部信息。
    - 根据ELF头部信息，在程序文件中读取原始数据内容，并根据ELF头部中的程序头部信息进行解析。
    - 调用mm_map函数来创建与TEXT和DATA相关的虚拟内存区域（VMA）。
    - 调用pgdir_alloc_page函数为TEXT和DATA部分分配内存页面，并将文件内容复制到新分配的页面中。
    - 调用pgdir_alloc_page函数为BSS部分分配内存页面，并将页面中的内容清零。

- 4、调用mm_map函数设置用户栈，并将参数放入用户栈中，建立并初始化用户堆栈

- 5、设置当前进程的mm结构、页目录表（使用lcr3宏定义）。

- 6、在用户栈中设置uargc和uargv参数，并且处理用户栈中传入的参数，

- 7、最后很关键的一步是设置用户进程的中断帧（trapframe）。

- 8、如果在上述步骤中出现错误，需要清理环境。

主要和lab5中不一样，需要修改的地方有：

读取ELF文件需把原来lab5中的实现改为通过已经实现好的文件系统的`read`操作进行硬盘文件读取，这个改动主要体现在第三步中，具体如下：
```c
//lab5中
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

//lab8中
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr __elf;
    struct elfhdr *elf = &__elf;
    if((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0)
        goto bad_elf_cleanup_pgdir;
    // struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    //struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }
    struct proghdr __ph, *ph = &__ph;
    uint32_t vm_flags, perm, phnum;
```
上面仅展示了一部分，`load_icode_read`应用第三步里各个对在进行硬盘文件读取部分，涉及到读取就要把原来的代码改成调用它。

此外，加入了任意大小参数`argc`和`argv`的功能，使得应用程序能够接受命令行参数输入，这部分改动加在第六步，具体如下：
```c
    uint32_t argv_size=0, i;
    for (i = 0; i < argc; i ++) {
        argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }

    uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
    char** uargv=(char **)(stacktop  - argc * sizeof(char *));
    
    argv_size = 0;
    for (i = 0; i < argc; i ++) {
        uargv[i] = strcpy((char *)(stacktop + argv_size ), kargv[i]);
        argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
    }
    
    stacktop = (uintptr_t)uargv - sizeof(int);
    *(int *)stacktop = argc;
```
## 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案
如果要在ucore里加入UNIX的管道（Pipe）机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个（或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

为了实现 UNIX 的 PIPE 机制，可以考虑在磁盘上保留一部分空间或者是一个特定的文件来作为 pipe 机制的缓冲区，接下来将说明如何完成对 pipe 机制的支持：
下面是一个基本的设计方案：

### 定义管道数据结构
为了实现管道机制，需要在内核中定义一个管道数据结构来存储进程间传输的数据。该数据结构包括两个缓冲区，一个输入缓冲区和一个输出缓冲区。每个缓冲区都由一个首指针和一个尾指针组成，以便进行读写操作。

### 管道创建与销毁
当进程A需要向进程B发送数据时，它可以调用pipe()系统调用，该调用将创建一个新的管道，并返回一个文件描述符（fd）。进程A将使用该fd来写入数据到输出缓冲区中。进程B将使用相同的fd从输入缓冲区中读取数据。

当不再需要管道时，进程可以使用close()系统调用来关闭读或写端口。当所有相关的fd都被关闭时，管道将被销毁。

### 管道读写操作
进程使用read()系统调用从输入缓冲区中读取数据，并使用write()系统调用将数据写入输出缓冲区中。

如果输入缓冲区为空，则调用read()会被阻塞，直到数据可用为止。同样，如果输出缓冲区已满，则调用write()也会被阻塞，直到有足够的空间可用为止。

### 管道进程同步
由于管道是共享的，因此可能需要使用信号量或互斥锁等机制来保证多个进程之间的同步。例如，当一个进程向管道中写入数据时，应该确保在另一个进程读取数据之前，该数据不会被覆盖或修改。

### 虚拟文件系统实现
为了兼容UNIX的标准I/O接口，可以在虚拟文件系统（VFS）中实现管道机制。这样，管道就可以像其他文件一样使用标准的I/O函数进行读写操作。

在VFS中，每个管道都可以被表示为一个特殊的文件类型，比如“FIFO”文件。当进程打开FIFO文件时，将创建一个新的fd，并将该fd与管道相关联。然后，进程就可以使用标准的I/O函数进行读写操作了。

## 扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案
如果要在ucore里加入UNIX的软连接和硬连接机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个(或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的软连接和硬连接机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

需要定义以下数据结构和接口：

### 数据结构：
    inode：表示文件的元数据，包括文件类型、大小、权限等信息。
    file：表示打开的文件，包括指向inode的指针、读写偏移量等信息。
### 接口：
    int link(const char *oldpath, const char *newpath)：创建一个硬链接，将oldpath指向的文件与newpath指向的文件名关联起来。这个接口会在目标文件夹的控制块中增加一个描述符，并且两个描述符的inode指针相同，同时nlinks数据结构应该相应增加。
    int symlink(const char *target, const char *linkpath)：创建一个软链接，将target指向的地址与linkpath指向的文件名关联起来。这个接口会在文件目录中创建一个特殊的文件，其中包含指向target的地址信息。
    int readlink(const char *pathname, char *buf, size_t bufsiz)：读取软链接文件的内容，将软链接指向的地址信息放入buf中。
    int unlink(const char *pathname)：删除一个链接，如果是硬链接，减少相关nlinks数据结构的计数；如果是软链接，直接删除软链接文件。
对于可能出现的同步互斥问题，可以使用信号量或互斥锁等机制来确保多个进程对链接的访问是同步的，防止并发引起的数据不一致问题。比如，在创建硬链接或软链接时，可以使用互斥锁来保护相关数据结构的访问，确保一次只有一个进程在修改链接信息。在对链接进行删除操作时，也需要考虑并发情况下的同步问题，避免资源泄漏或数据一致性问题。