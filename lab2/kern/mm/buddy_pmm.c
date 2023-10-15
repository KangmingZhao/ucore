#include <pmm.h>
#include <list.h>
#include <string.h>
#include <best_fit_pmm.h>
#include <stdio.h>

// 最大深度不应超过32
#define BUDDY_MAX_DEPTH 30
static unsigned int* buddy_longest;                   // 指向记录每个节点最长空闲页数的数组
static unsigned int buddy_max_pages;                  // 可分配的最大页数
static struct Page* buddy_allocatable_base;           // 分配的页的基地址

#define IS_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)      // 判断一个数是否是2的幂次方
#define LEFT_LEAF(index) ((index) * 2 + 1)             // 左子叶节点索引
#define RIGHT_LEAF(index) ((index) * 2 + 2)            // 右子叶节点索引
#define PARENT(index) ( ((index) + 1) / 2 - 1)         // 父节点索引
#define MAX(a, b) ((a) > (b) ? (a) : (b))              // 求两者中的较大值

static unsigned int
buddy_find_first_zero(unsigned int bit_array) {
    // 找到bit_array中第一个为0的位的位置
    unsigned pos = 0;
    while (bit_array >>= 1) ++pos;
    return pos;
}

static struct Page*
buddy_node_index_to_page(unsigned int index, unsigned int node_size) {
    // 根据节点索引和节点大小计算出对应的页地址
    return buddy_allocatable_base + ((index + 1) * node_size - buddy_max_pages);
}

static void
buddy_init(void) {
    // 初始化函数，无需实现任何操作
}

static void buddy_init_memmap(struct Page* base, size_t n) {
    assert(n > 0);
    // 计算可管理的最大内存区域
    unsigned int max_pages = 1;
    for (unsigned int i = 1; i < BUDDY_MAX_DEPTH; ++i) {
        // 需要考虑存储'longest'数组的页面
        if (max_pages + max_pages / 512 >= n) {
            max_pages /= 2;
            break;
        }
        max_pages *= 2;
    }
    unsigned int longest_array_pages = max_pages / 512 + 1;
    cprintf("BUDDY: 最大可管理页面数 = %d，用于存储longest的页面数 = %d\n",
            max_pages, longest_array_pages);
            
    // 将buddy_longest指针指向页面数组的物理地址
    buddy_longest = (unsigned int*)KADDR(page2pa(base));
    buddy_max_pages = max_pages;

    unsigned int node_size = max_pages * 2;
    for (unsigned int i = 0; i < 2 * max_pages - 1; ++i) {
        // 如果是2的幂次方，则将节点大小除以2
        if (IS_POWER_OF_2(i + 1)) 
            node_size /= 2;
        buddy_longest[i] = node_size;
    }

    // 将前longest_array_pages个页面设置为保留状态
    for (int i = 0; i < longest_array_pages; ++i) {
        struct Page* p = base + i;
        SetPageReserved(p);                 // 将页面设置为保留状态
    }

    // 从第longest_array_pages个页面开始，将页面设置为非保留状态并进行初始化
    struct Page* p = base + longest_array_pages;
    buddy_allocatable_base = p;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        ClearPageReserved(p);               // 清除页面的保留状态
        SetPageProperty(p);                 // 将页面设置为非空闲状态
        set_page_ref(p, 0);                 // 设置页面引用计数为0
    }
}

static size_t
buddy_fix_size(size_t before) {
    // 将传入的数修正为最近的2的幂次方
    unsigned int ffz = buddy_find_first_zero(before) + 1;
    return (1 << ffz);
}

static struct Page*
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (!IS_POWER_OF_2(n)) {
        n = buddy_fix_size(n);              // 如果传入的数量不是2的幂次方，则修正为最近的2的幂次方
    }
    if (n > buddy_longest[0]) {
        return NULL;                        // 如果要分配的页面数超过最大可分配页面数，则分配失败，返回NULL
    }

    // 找到顶部节点以进行分配
    unsigned int index = 0;                  
    unsigned int node_size;

    // 从根节点开始找到最合适的位置
    for (node_size = buddy_max_pages; node_size != n; node_size /= 2) {
        if (buddy_longest[LEFT_LEAF(index)] >= n) {
            index = LEFT_LEAF(index);       // 左子叶节点的最长空闲页数大于等于n，则分配在左子树
        } else {
            index = RIGHT_LEAF(index);      // 否则分配在右子树
        }
    }

    // 分配该节点下的所有页面
    buddy_longest[index] = 0;
    struct Page* new_page = buddy_node_index_to_page(index, node_size);
    for (struct Page* p = new_page; p != (new_page + node_size); ++p) {
        set_page_ref(p, 0);                 // 设置新分配的页面引用计数为0
        ClearPageProperty(p);               // 将页面设置为非空闲状态
    }

    // 更新父节点的最长空闲页数，因为当前节点已被使用
    while (index) {
        index = PARENT(index);
        buddy_longest[index] =
            MAX(buddy_longest[LEFT_LEAF(index)], buddy_longest[RIGHT_LEAF(index)]);
    }
    return new_page;
}

static void
buddy_free_pages(struct Page* base, size_t n) {
    assert(n > 0);
    // 找到对应基地址的节点以及其大小
    unsigned int index = (unsigned int)(base - buddy_allocatable_base) + buddy_max_pages - 1;
    unsigned int node_size = 1;

    // 从叶节点开始找到第一个（最低）的节点，该节点的最长空闲页数为0
    while (buddy_longest[index] != 0) {
        node_size *= 2;
        // 如果无法找到对应的节点，则出错
        assert(index != 0);
        index = PARENT(index);
    }

    // 释放页面
    struct Page* p = base;
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面既不是保留页面，也不是非空闲页面
        SetPageProperty(p);             // 将页面设置为非空闲状态
        set_page_ref(p, 0);             // 设置页面引用计数为0
    }

    // 更新最长空闲页数
    buddy_longest[index] = node_size;
    while (index != 0) {
        // 从该节点开始尝试合并到父节点
        // 合并条件为 (left_child + right_child = node_size)
        index = PARENT(index);
        node_size *= 2;
        unsigned int left_longest = buddy_longest[LEFT_LEAF(index)];
        unsigned int right_longest = buddy_longest[RIGHT_LEAF(index)];

        if (left_longest + right_longest == node_size) {
            buddy_longest[index] = node_size;
        } else {
            // 如果子节点有更新，则进行更新
            buddy_longest[index] = MAX(left_longest, right_longest);
        }
    }
}

static size_t
buddy_nr_free_pages(void) {
    return buddy_longest[0];                 // 返回最长空闲页数
}

static void buddy_check(void) {
    int all_pages = nr_free_pages();
    struct Page* p0, *p1, *p2, *p3, *p4;

    // 分配页面测试
    assert(alloc_pages(all_pages + 1) == NULL); // 测试分配超过可用页面数量的情况

    p0 = alloc_pages(1);
    assert(p0 != NULL);

    p1 = alloc_pages(2);
    assert(p1 == p0 + 2);
    assert(!PageReserved(p0) && !PageReserved(p1));
    assert(!PageProperty(p0) && !PageProperty(p1));

    p2 = alloc_pages(1);
    assert(p2 == p0 + 1);

    p3 = alloc_pages(2);
    assert(p3 == p0 + 4);
    assert(!PageProperty(p3) && !PageProperty(p3 + 1) && PageProperty(p3 + 2));

    // 释放页面测试
    free_pages(p1, 2);
    assert(PageProperty(p1) && PageProperty(p1 + 1));
    assert(p1->ref == 0);

    free_pages(p0, 1);
    free_pages(p2, 1);

    // 使用已释放的页面
    p4 = alloc_pages(2);
    assert(p4 == p0);

    free_pages(p4, 2);
    assert((*(p4 + 1)).ref == 0);

    // 空闲页面数测试
    assert(nr_free_pages() == all_pages / 2);

    free_pages(p3, 2);

    // 分配和释放多个页面
    p1 = alloc_pages(33);
    assert(p1 != NULL);

    free_pages(p1, 64);

    // 空闲页面数测试
    assert(nr_free_pages() == all_pages);
}



const struct pmm_manager buddy_pmm_manager = {
	.name = "buddy_pmm_manager",            // 名称为buddy_pmm_manager
	.init = buddy_init,                     // 初始化函数
	.init_memmap = buddy_init_memmap,       // 内存映射初始化函数
	.alloc_pages = buddy_alloc_pages,       // 分配页面函数
	.free_pages = buddy_free_pages,         // 释放页面函数
	.nr_free_pages = buddy_nr_free_pages,   // 返回空闲页面数函数
	.check = buddy_check,                   // 检查函数
};