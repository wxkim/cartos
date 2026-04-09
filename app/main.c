#include "../include/stm32g474xx.h"

void delay(volatile int count) {
  while (count--)
    __asm("nop");
}

int main(void) {
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;

  GPIOA->MODER &= ~(3 << (5 * 2));
  GPIOA->MODER |= (1 << (5 * 2));

  while (1) {

    delay(100000);
  }
}