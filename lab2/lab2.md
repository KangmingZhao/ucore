

## 扩展练习 Challenge：buddy system（伙伴系统）分配算法（需要编程）

Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...

 -  参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

### 一、伙伴系统
伙伴系统(buddy system)是一种内存分配算法，将物理内存按照2的幂进行划分为若干空闲块，每次分配选择合适且最小的内存块进行分配。其优点是快速搜索合并(O(logN)时间复杂度)、低外部碎片(最佳适配best-fit)，其缺点是内部碎片，因为空闲块一定是按照2的幂划分的。

### 二、数据结构

伙伴系统采用完全二叉树来管理连续内存页，如下图buddy system共管理16个连续内存页，每一结点记录与管理若干连续内存页，如结点0管理连续的16个页，结点1管理其下连续的8个页，结点15管理连续内存的第一个页，每个结点存储一个longest，记录该结点所管理的所有页中最大可连续分配页数目。

<img src="https://whileskies-pic.oss-cn-beijing.aliyuncs.com/20201009172121.png" alt="image-20201009172121474" style="zoom:80%;" />

于是，我们定义了一个buddy结构体，size表示所管理的连续内存页的大小，longest为上面说所的数组。但是在后续完善的过程中，我们定义了一个buddy数组，然后将longest作为了一个属性，实际上这里并不需要定义为数组。定义代码如下：

```c
struct buddy_system {
    unsigned size;
    unsigned longest[1];
 
};
//struct buddy_system buddy[NUM_BUDDY];
struct buddy_system buddy[80000];
```
### 三、分配块信息数据结构
定义一个结构体来记录已经分配的块的信息，便于在释放时提升速率
```c
//记录已经分配的块信息
struct block_info
{
    struct Page *base;
    int offset;//在longest数组中的便宜
    size_t pageNum;//块的大小
};

struct block_info rec[NUM_BUDDY];
int blockNum;//分配的块的数

```

### 四、相关宏定义及函数
打印buddy数组
```c

static void
show_buddy_array(int total_mem) {
    cprintf("Print buddy:\n");
    int i=0;
    // for(int i=0;i<total_mem*2-1;i++)
    // {
      
    // }
    while ((i<total_mem*2-1))
    {
      int temp=2*i+1;
      for(;i<temp;i++)
      {
        cprintf("%u ",buddy[i].longest[0]);
      }
      cprintf("\n");
    }
    cprintf("---------------------------\n");
    return;
}
```
一些宏定义
```c
#ifndef __KERN_MM_BUDDY_SYSTEM_PMM_H__
#define  __KERN_MM_BUDDY_SYSTEM_PMM_H__

#include <pmm.h>

extern const struct pmm_manager buddy_system_pmm_manager;



#define LEFT_LEAF(index)((index)*2+1) 
#define RIGHT_LEAF(index)((index)*2+2)
#define  PARENT(index)((index+1)/2-1)
// 2的幂次计算 x不为0且x和x-1二进制表示与运算之后应该是0的
#define IS_POWER_OF_2(x) (((x) != 0) && (((x) & ((x) - 1)) == 0))

// 定义用来回溯父节点的比较大小的宏
#define MAX(a,b)((a)>(b)?(a):(b))
#define NUM_BUDDY 1000

#endif /* ! __KERN_MM_BUDDY_SYSTEM_PMM_H__ */
```
找到比n大的最小的2的幂数
```c
static unsigned fixsize(unsigned size) {
  int i=1;
  for(;i<size;i*=2);
  return i;  
}
```
### 五、功能函数
#### 初始化内存映射
```c

//init mmp
static void
buddy_init_memmap(struct Page*base,size_t n)
{
    cprintf("initmmp\n");
    assert(n>0);
     blockNum=0;//分配块数设置为0
    struct Page *p=base;
    for(;p!=base+n;p++)
    {
        assert(PageReserved(p));//检查是否被引用过
        p->flags=0;
        p->property=1;
        set_page_ref(p,0);//设置其属性
        SetPageProperty(p);
        list_add_before(&free_list,&(p->page_link));

    }
    //cprintf("hehe");
    nr_free+=n;//空闲页数+n
    //要计算一下这个空闲空间对应二叉树的大小、、、
    cprintf("n=%d\n",n);
    int allocpages=fixsize(n);
    cprintf("fix=%d\n",allocpages);
    buddy_new_tree(allocpages);
    cprintf("init_mmp_succeed\n");
    /*
            8
        4       4
    2    2    2    2
1     1 1  1 1 1  1  1
    
    */
}
```
#### 完全二叉树的初始化
整个分配器的大小为满二叉树节点树木，则为管理内存单元数量的两倍,longest记录了节点所对应的内存块大小
```c
void buddy_new_tree(int size)
{
   cprintf("new_tree\n");
    //cprintf("%d",size);
    unsigned node_size;
    //struct buddy_system* self;

    //检查错误输入 排除0和非2的n次幂
    if(size<1||!IS_POWER_OF_2(size))
    {
        return  ;
    }
    cprintf("%d\n",size);
    buddy[0].size=size;
    node_size=size*2;
    for(int i=0;i<2*size-1;++i)
    {
        if(IS_POWER_OF_2(i+1))
        {
            node_size/=2;
        }
        buddy[i].longest[0]=node_size;// 初始化咧
    }
   cprintf("new_tree succeed\n");
    return ;
}
```
#### Alloc函数
- buddy_alloc 
这个函数首先是要在树中找到需要使用的节点，并且进行回溯将父节点的longest调整为左右孩子节点中比较大的，并且返回偏移量，偏移量为节点数组中的位置。而offset 的计算原理推导如下：
```c
(index-2^layer+1) * node_size = (index+1)node_size –-node_size2^layer。
又node_size的计算为2^(max_depth-layer)
因此node_size * 2^layer = 2^max_depth = size。
所以offset=(index+1)*node_size – size。 
```
```c

// 内存分配-1 算在数组中便宜+回溯父节点
int buddy_alloc(int size)
{
  cprintf("buddy_alloc\n");
    unsigned index=0;//
    unsigned node_size;
    unsigned offset=0;

  if (buddy[index].longest[0]<size)
  {
    cprintf("%d",buddy[index].longest[0]);
    return -1;
  }
  if (size <= 0)//分配不合理
    size = 1;
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
    size = fixsize(size);
 cprintf("%d\n",size);
 for (node_size=buddy[0].size; node_size!=size;node_size/=2)
 {
     int left_longest=buddy[LEFT_LEAF(index)].longest[0];
     int right_longest=buddy[RIGHT_LEAF(index)].longest[0];
     if(left_longest>=size)
     {
        //左右节点都符合
        if(right_longest>=size)
        {
            //找小的那个3111

            index=left_longest<=right_longest?LEFT_LEAF(index):RIGHT_LEAF(index);
        }
        else{
            index=LEFT_LEAF(index);
        }
     }
     else
     {
        index=RIGHT_LEAF(index);
     }
     cprintf("buddy_alloc succeed\n");
 }
 //找到你想用的了
 buddy[index].longest[0]=0;
 offset=(index+1)*node_size-buddy[0].size;
 //回溯
 while (index)
 {
    index=PARENT(index);
    buddy[index].longest[0]=MAX(buddy[LEFT_LEAF(index)].longest[0], buddy[RIGHT_LEAF(index)].longest[0]);
 }

 return offset;//返回物理页在链表中的位置
}

```
- buddy_alloc_pages

这个为分配内存函数，调用上面的buddy_alloc函数之后得到需要分配节点在数组中的位置，同时也记录在`alloc_block`当中，方便后续释放。

之后根据所得的偏移量进行定位，从基址开始进行连续分配，并将信息也储存在`alloc_block`当中。

```c

static struct Page*
buddy_alloc_pages(size_t n){
  cprintf("alloc_pages\n");
  assert(n>0);
  if(n>nr_free)
   return NULL;//请求大于空闲
  struct Page* page=NULL;
  struct Page* p;
  list_entry_t *le=&free_list,*len;
  rec[blockNum].offset=buddy_alloc(n);//记录偏移量 
  int i;
  for(i=0;i<rec[blockNum].offset+1;i++)
  {
    le=list_next(le);
  }//找到空闲页表的开始
  page=le2page(le,page_link);
  int pagenum;
  if(!IS_POWER_OF_2(n))
   pagenum=fixsize(n);
  else
  {
     pagenum=n;
  }
  //根据需求n得到块大小
  rec[blockNum].base=page;//记录分配块首页
  rec[blockNum].pageNum=pagenum;//记录分配的页数
  blockNum++;
  for(i=0;i<pagenum;i++)
  {
    len=list_next(le);
    p=le2page(le,page_link);
    ClearPageProperty(p);//说明是头或者被分配了
    le=len;
  }//修改每一页的状态
  nr_free-=pagenum;//减去已被分配的页数
  page->property=pagenum;//合成一整页
  cprintf("alloc_pages succeed\n");
  return page;   
}

```
#### 页的释放
页的释放分为以下几块：
- 根据base在已经分配块的结构体中找到要分配的块，然后获取其偏移量以及页的大小
```c
 cprintf("free_page\n");
  unsigned node_size, index = 0;
  unsigned left_longest, right_longest;
  //struct buddy_system * self=buddy;
  
  list_entry_t *le=list_next(&free_list);
  int i=0;
  for(i=0;i<blockNum;i++)  //blockNum是已分配的块数
  {
    if(rec[i].base==base)  
     break;
  }
  //找到对应的块
  int offset=rec[i].offset;
  int pos=i;//暂存i
  i=0;
  while(i<offset)
  {
    le=list_next(le);
    i++;     //根据该分配块的偏移记录信息，可以找到双链表中对应的page
  }
  int allocpages;
  if(!IS_POWER_OF_2(n))
   allocpages=fixsize(n);
  else
  {
     allocpages=n;
  }
```
- 接下来回收对应的页
```c
  nr_free+=allocpages;//更新空闲页的数量
  struct Page* p;
  for(i=0;i<allocpages;i++)//回收已分配的页
  {
     p=le2page(le,page_link);
     p->flags=0;
     p->property=1;
     SetPageProperty(p);
     le=list_next(le);
  }
```
- 向上回溯修改祖先节点
从叶子节点开始向上回溯，每层的node_size变为当前的两倍。当左右子树的值等于原空闲块满状态的大小时，将该节点的`longest`恢复为满状态的值；否则，该节点的`longest`设置为左右子树中值更大的那个。
处理完之后将被回收块的信息进行删除，即将块数组后面的内容往前移动，更新块的大小。
```c
 //回收父节点

  while (index) {//向上合并，修改父节点的记录值
    index = PARENT(index);
    node_size *= 2;
    
    left_longest = buddy[LEFT_LEAF(index)].longest[0];
    right_longest = buddy[RIGHT_LEAF(index)].longest[0];
    
    if (left_longest + right_longest == node_size) 
      buddy[index].longest[0] = node_size;
    else
      buddy[index].longest[0] = MAX(left_longest, right_longest);
  }
  for(i=pos;i<blockNum-1;i++)//清除此次的分配记录，即从分配数组里面把后面的数据往前挪
  {
    rec[i]=rec[i+1];
  }
  blockNum--;//更新分配块数的值
  cprintf("free_page succeed\n");
```

### 测试样例

测试函数如下：
```c

    cprintf("*******************************Check begin***************************\n");
    show_buddy_array(16);
    A=alloc_pages(3);
    show_buddy_array(16);
    B=alloc_pages(5);
    show_buddy_array(16);
    C=alloc_pages(1);
    show_buddy_array(16);
    D=alloc_pages(2);
    show_buddy_array(16);
   // C=alloc_pages(8);
    //show_buddy_array(16);
    //cprintf("A %p\n",A);
    //cprintf("B %p\n",B);
    free_page(C);
    show_buddy_array(16);
    free_page(D);
    show_buddy_array(16);
    free_page(A);
    show_buddy_array(16);
    free_page(B);
    show_buddy_array(16);
    cprintf("********************************Check End****************************\n");
```
我们修改传入的块大小为16，
我们按3 5 1 2的顺序进行申请，并按1 2 3 5的顺序进行释放，每次都将buddy数组进行打印观察结果，发现和理论结果一致，验证了函数的正确性。
测试结果
```c
*******************************Check begin***************************
Print buddy:
16 
8 8 
4 4 4 4 
2 2 2 2 2 2 2 2 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
alloc_pages
buddy_alloc
4
buddy_alloc succeed
buddy_alloc succeed
alloc_pages succeed
Print buddy:
8 
4 8 
0 4 4 4 
2 2 2 2 2 2 2 2 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
alloc_pages
buddy_alloc
8
buddy_alloc succeed
alloc_pages succeed
Print buddy:
4 
4 0 
0 4 4 4 
2 2 2 2 2 2 2 2 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
alloc_pages
buddy_alloc
1
buddy_alloc succeed
buddy_alloc succeed
buddy_alloc succeed
buddy_alloc succeed
alloc_pages succeed
Print buddy:
2 
2 0 
0 2 4 4 
2 2 1 2 2 2 2 2 
1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
alloc_pages
buddy_alloc
2
buddy_alloc succeed
buddy_alloc succeed
buddy_alloc succeed
alloc_pages succeed
Print buddy:
1 
1 0 
0 1 4 4 
2 2 1 0 2 2 2 2 
1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
free_page
free_page succeed
Print buddy:
2 
2 0 
0 2 4 4 
2 2 2 0 2 2 2 2 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
free_page
free_page succeed
Print buddy:
4 
4 0 
0 4 4 4 
2 2 2 2 2 2 2 2 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
free_page
free_page succeed
Print buddy:
8 
8 0 
4 4 4 4 
2 2 2 2 2 2 2 2 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
free_page
free_page succeed
Print buddy:
16 
8 8 
4 4 4 4 
2 2 2 2 2 2 2 2 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
---------------------------
********************************Check End****************************
```