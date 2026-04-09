#include "main.h"
#include "../lib/delay.s"
#include "../lib/gpio.s"
#include <stdint.h>

extern void gpio_init(uint32_t portbase, uint32_t pin, uint32_t md);
extern void gpio_toggle(uint32_t portbase, uint32_t pin);
extern void gpio_toggle_atomic(uint32_t portbase, uint32_t pin);

extern void b_delay(uint32_t ms);

__attribute((noreturn)) int main() {
  gpio_init(GPIOA_BASE, 5, 1);
  while (1) {
    gpio_toggle_atomic(GPIOA_BASE, 5);
  }
}