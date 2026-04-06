.syntax unified
.cpu cortex-m4
.thumb

.extern kernel
.extern kernel_get_task

PendSV_Handler:
    cpsid I    // change PE State; globally disables interrupts

    ldr r0, =current_task //
    ldr r1, [r0]