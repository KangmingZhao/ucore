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