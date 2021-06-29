#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <ctype.h>

typedef uint8_t u8;
typedef int32_t s32;
typedef uint32_t u32;

#define MAP_SIZE_POW2       16
#define MAP_SIZE            (1 << MAP_SIZE_POW2)
#define R(x) (random() % (x))
#define MAX_LINE            8192

int use_64bit = 1;
int inst_ratio = 100;
static u8 pass_thru = 0;
static const u8* trampoline_fmt_64 =
  "\n"
  "/* --- AFL TRAMPOLINE (64-BIT) --- */\n"
  "movq $0x%08x, %%rcx\n"
  "call __afl_maybe_log\n"
  "/* --- END --- */\n"
  "\n";

static const u8* main_payload_64 = 

  "/* --- AFL MAIN PAYLOAD (64-BIT) --- */\n"
  "/* --- END --- */\n"
  "\n";



static void add_instrumentation(void) {
  static u8 line[MAX_LINE];
  char *input_file = "/home/huang/afl-analysis/number-range.s";
  char *modified_file = "/home/huang/afl-analysis/number-range_modified.s";
  
  FILE* inf = fopen(input_file, "r"); /* input file */
  FILE* outf; /* output file */
  s32 outfd;
  u32 ins_lines = 0;
    int instr_ok = 0;

    int skip_next_label = 0;
   int  instrument_next = 0;


/* 插桩后的文件，modified_file具体是什么，即文件的存储位置。*/
  outfd = open(modified_file, O_WRONLY | O_EXCL | O_CREAT, 0600);
  outf = fopen(modified_file, "w");

  while (fgets(line, MAX_LINE, inf)) {
    /* 函数开头*/
    if (instrument_next && line[0] == '\t' && isalpha(line[1])) {

        instrument_next = 0;
      fprintf(outf,  trampoline_fmt_64, random() % MAP_SIZE); 
      ins_lines++; // 插桩的数量
    }

    fputs(line, outf);

    if (line[0] == '\t' && line[1] == '.') {

      if (!strncmp(line + 2, "text\n", 5) ||
          !strncmp(line + 2, "section\t.text", 13) ||
          !strncmp(line + 2, "section\t__TEXT,__text", 21) ||
          !strncmp(line + 2, "section __TEXT,__text", 21)) {
        instr_ok = 1;
        /* 判断 */
        continue; 
      }

      if (!strncmp(line + 2, "section\t", 8) ||
          !strncmp(line + 2, "section ", 8) ||
          !strncmp(line + 2, "bss\n", 4) ||
          !strncmp(line + 2, "data\n", 5)) {
        instr_ok = 0;
        continue;
      }

    }


    /* If we're in the right mood for instrumenting, check for function
       names or conditional labels. This is a bit messy, but in essence,
       we want to catch:

         ^main:      - function entry point (always instrumented)
         ^.L0:       - GCC branch label
         ^\tjnz foo  - conditional branches

       ...but not:

         ^# BB#0:    - clang comments
         ^ # BB#0:   - ditto
         ^.LC0       - GCC non-branch labels
         ^.LBB0_0:   - ditto (when in GCC mode)
         ^\tjmp foo  - non-conditional jumps
     */

    /*首行为#->注释，为空格->? */
    if (line[0] == '#' || line[0] == ' ') continue;

    /* Conditional branch instruction (jnz, etc). We append the instrumentation
       right after the branch (to instrument the not-taken path) and at the
       branch destination label (handled later on). */

    /* 为^\tjnz foo 类型*/
    if (line[0] == '\t' && instr_ok) {

      if (line[1] == 'j' && line[2] != 'm') {

        fprintf(outf, trampoline_fmt_64, R(MAP_SIZE));

        ins_lines++;

      }

      continue;

    }

   /* 类型：.L<whatever>: */
    if (strstr(line, ":") && instr_ok) {
      if (line[0] == '.') {
        /* Apple: .L<num> / .LBB<num> */

        if ((isdigit(line[2]) || (!strncmp(line + 1, "LBB", 3)))) {

            /* 为什么要skip_next_label */
          if (!skip_next_label) instrument_next = 1; else skip_next_label = 0;

        }

      } else {
        /* Function label (always instrumented, deferred mode). */
        instrument_next = 1;
    
      }

    }

  }

   //写ｍain_payload_xx到outf stream中
  fputs(main_payload_64, outf);

  fclose(inf);
  fclose(outf);
}

int main(void) {
    add_instrumentation();
    return 0;
}
