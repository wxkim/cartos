.syntax unified
.cpu cortex-m4
.thumb

.extern kernel
.extern kernel_get_task

PendSV_Handler:
    cpsid I         @ change processor state, interrupt disable; globally disables interrupts

    mrs r0, psp     @ move special register; move process stack ptr to r0

    tst lr, #0x10   @ "test" a masking of the link register. bit 4 is 0 if the FPU was used

    it eq           @ if-then if previous instruction has state "equal"

    vstmdbeq r0!, {s16-s31} @ vector store multiple decrememnt descending
    @ skip_fpu_cs:

    ldr r0, =current_task @
    ldr r1, [r0]

    stmdbeq r0!, {r1-r11}

    