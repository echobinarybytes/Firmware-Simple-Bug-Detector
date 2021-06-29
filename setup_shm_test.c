#include <sys/shm.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
//#include "alloc-inl.h"

#include <unistd.h>

#define SHM_ENV_VAR "__AFL_SHM_ID"
#define MAP_SIZE_POW2       16
#define MAP_SIZE            (1 << MAP_SIZE_POW2)

#define alloc_printf(_str...) ({ \
    u8* _tmp; \
    s32 _len = snprintf(NULL, 0, _str); \
    if (_len < 0) printf("Whoa, snprintf() fails?!"); \
    _tmp = malloc(_len + 1); \
    snprintf((char*)_tmp, _len + 1, _str); \
    _tmp; \
  })
#define ck_alloc         alloc 
#define ck_free          free 


typedef int32_t s32;
typedef uint8_t u8;

static u8* trace_bits;        /* 8bits width. SHM with 插桩instrumentation bitmap   */
static s32 shm_id;            /* ID of the SHM region              */
static u8  *prog_in;          /* Targeted program input file       */
/* Allocate a buffer, explicitly not zeroing it. Returns NULL for zero-sized
   requests. */




static void remove_shm(void) {

  unlink(prog_in); /* Ignore errors */
  shmctl(shm_id, IPC_RMID, NULL);

}
/* Configure shared memory. */
/* 设置共享内存 */
static void setup_shm(void) {

  u8* shm_str;
/* 获得共享内存, 返回标识符*/
/* int shmget(key_t key, size_t size, int shmflg) 
 *  
 *  shm_id = 688184
*/
  shm_id = shmget(IPC_PRIVATE, MAP_SIZE, IPC_CREAT | IPC_EXCL | 0600);

  if (shm_id < 0) printf("shmget() failed");

  atexit(remove_shm);
/* 这个shm_str表示的是什么？？

int snprintf(char *s, size_t n, const char *format, ...);
write formatted output to sized buffer
s   result store in buffer s
n   maximum number of bytes to be used in the buffer
format, ...  input formatted string
ret the number of characters that have been written. return negatve when encoding error happend


#define alloc_printf(_str...) ({ 
u8* _tmp; 
    s32 _len = snprintf(NULL, 0, _str);  // 检测_string的编码是否正确？？？　这里又是如何获取_str长度的
    if (_len < 0) printf("Whoa, snprintf() fails?!"); 
    _tmp = ck_alloc(_len + 1);  // 分配_len+1长的内存给_tmp变量
    snprintf((char*)_tmp, _len + 1, _str); 
    _tmp; // 返回_tmp指针，指向shm_id的字符串表示
  })

*/

  /* shm_str = "688184" , shm_id变为字符串
   */
  shm_str = alloc_printf("%d", shm_id);


/* int setenv(const char* name, const char *value, int overwrite) 
 * 
 * #define SHM_ENV_VAR "__AFL_SHM_ID"
 * shm_str 
 * overwrite=1,　表示更改已存在的环境变量 
 */
  setenv(SHM_ENV_VAR, shm_str, 1);
  /*
   * shm_str = ""
   */
  free(shm_str);

  /*
   * void *shmat(int shmid, const void *shmaddr, int shmflg);
   * trace_bits = 0x0000 0000
   */
  /* 
   * void *shamt(int shmid, const void *shmaddr, int shmflg);
   * attach share memory identified by shmid to the calling process.
   *  
   * shmid = shm_id, identify is 688184
   * shmaddr = NULL, the system choose a suitable address to attach the segment.
   * shmflg = 0, means what? 
   * 
   * if success, return the address of the attached shared memory segment. if error, return -1 ??
   *
   * trace_bits = 0x7ffff7fe8000
   */
  trace_bits = shmat(shm_id, NULL, 0);
  
  if (!trace_bits) printf("shmat() failed");

}

int main(void) {
    setup_shm();
    return 0;
}
