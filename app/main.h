#ifndef MAIN_H
#define MAIN_H

#include <stdint.h>

typedef enum {
  ISRNonyieldable = 0,
  Critical = 1,
  High = 2,
  Normal = 3,
  Low = 4,
  Idle = 5
} Priority;

typedef struct TCB_Handle {
  uint32_t *sptr;
  void (*function)(void *);
  Priority prio;
  struct TCB_Handle *next;
} TCB_Handle;

extern void init_kernel(TCB_Handle *tcb, void *arg);
extern void kernel_add_new_task(TCB_Handle *tcb);
extern void os_kernel_launch(void);

#endif