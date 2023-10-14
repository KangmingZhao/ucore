#include <pmm.h>
#include <buddy_system_pmm.h>
#include<stdio.h>

static unsigned fixsize(unsigned size) {
  int i=1;
  for(;i<size;i*=2);
  return i;  
}
struct buddy_system {
    unsigned size;
    unsigned longest[1];
 
};
//struct buddy_system buddy[NUM_BUDDY];
struct buddy_system buddy[80000];
//双向链表
free_area_t free_area;
//空闲链表 及页数
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
// int IS_POWER_OF_2(int n)
// {
//   int i=1;
//   for(;i<=n;i*=2);
//   return i==n?1:0;
// }
//记录已经分配的块信息
struct block_info
{
    struct Page *base;
    int offset;//在longest数组中的便宜
    size_t pageNum;//块的大小
};

struct block_info rec[NUM_BUDDY];
int blockNum;//分配的块的数
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
static void buddy_init()
{
    list_init(&free_list);
    nr_free=0;//
    //cprintf("init_succeed");
}
//初始化二叉树 size为二叉树大小 也就是内存块大小
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
    ClearPageProperty(p); //改为0，说明是头页或者被分配了
    le=len;
  }//修改每一页的状态
  nr_free-=pagenum;//减去已被分配的页数
  page->property=pagenum;//合成一整页
  cprintf("alloc_pages succeed\n");
  return page;   
}

void buddy_free_pages(struct Page* base, size_t n) {
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
  //assert(self && offset >= 0 && offset < self->size);//是否合法
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
  
  node_size = 1;
  index = offset + buddy[0].size - 1;   //从原始的分配节点的最底节点开始改变longest
  buddy[index].longest[0] = node_size;   //这里应该是node_size，也就是从1那层开始改变

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
}
static size_t
buddy_system_nr_free_pages(void) {
    return nr_free;
}
// static void
// buddy_check(void) {
  
//    struct Page  *A, *B;
//    int total_mem=8;
//    //show_buddy_array(total_mem);
//    cprintf("test!\n") ;
// }

static void
basic_check(void) {
  cprintf("basic check\n");
   
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
// static void
// buddy_check(void) {
//   cprintf("buddy_check\n");
//    buddy_alloc_pages(16);
//    show_buddy_array(16);
//    buddy_alloc_pages(3);
//    show_buddy_array(16);
//     //buddy_free_pages(3);
//    //show_buddy_array(16);
// }


static void
buddy_check(void) {
  
    struct Page  *A, *B, *C , *D;
    A = B =C = D =NULL;

    assert((A = alloc_page()) != NULL);
    assert((B = alloc_page()) != NULL);
    assert((C = alloc_page()) != NULL);
    assert((D = alloc_page()) != NULL);

    assert( A != B && B!= C && C!=D && D!=A);
    assert(page_ref(A) == 0 && page_ref(B) == 0 && page_ref(C) == 0 && page_ref(D) == 0);
  
    free_page(A);
    free_page(B);
    free_page(C);
    free_page(D);
    
    
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
}

const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_check,
};