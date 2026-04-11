#include "main.h"
#include <stdint.h>
TCB_Handle tcb1;
uint32_t stack1[128] __attribute__((aligned(8)));

void task_code(void *arg) {
  while (1)
    ;
}

void SystemInit(void) {}
void __libc_init_array(void) {}

__attribute__((noreturn)) int main() {

  tcb1.sptr = &stack1[127];
  tcb1.function = task_code;
  tcb1.prio = Normal;

  init_kernel(&tcb1, (void *)0x1234);
  kernel_add_new_task(&tcb1);

  os_kernel_launch();
  while (1)
    ;
}
