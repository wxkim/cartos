.syntax unified
.cpu cortex-m4
.thumb

.extern kernel
.extern kernel_get_task

.global PendSV_Handler
.type PendSV_Handler, %function
.thumb_func
PendSV_Handler:
    cpsid i                     @ change processor state, interrupt disable; globally disables interrupts
    mrs r0, psp                 @ move special register; move process stack ptr to r0

    tst lr, #0x10               @ "test" a masking of the link register. bit 4 is 0 if the FPU was used
    it eq                       @ if-then if previous instruction has state "equal"
    vstmdbeq r0!, {s16-s31}     @ vector store multiple decrememnt descending if EQ, for FPU registers
    stmdb r0!, {r4-r11}         @ save the normal registers

    ldr r1, =kernel
    ldr r2, [r1]                @ r2 = kernel.current_task 
    str r0, [r2]                @ TCB->stack_ptr = r0 

    push {lr}                   @ EXC_RETURN is automatically populated into the Link Register on entry to an exception
    bl kernel_get_task          @ call the next task function
    pop {lr}                    @ preserve EXC_RETURN

    ldr r1, =kernel
    str r0, [r1]                @ kernel.current_task = next_tcb
    ldr r0, [r0]                @ r0 = next_tcb->stack_ptr
    
    ldmia r0!, {r4-r11}         @ restore registers
    tst lr, #0x10               
    it eq
    vldmiaeq r0!, {s16-s31}     @ conditional restore fpu
    
    msr psp, r0                 @ update psp
    cpsie i                     @ enable interrupts
    bx lr                       @ ret


.global os_kernel_launch
.type os_kernel_launch, %function
.thumb_func
os_kernel_launch:
    ldr r0, =kernel
    ldr r0, [r0, #0]            @ r0 = rtos.current_task (TCB pointer)
    ldr r0, [r0, #0]            @ r0 = TCB->stack_ptr

    ldmia r0!, {r4-r11}         @ load multiple increment after

    msr psp, r0                 @ move special register
    mov r1, #2                  @ set bit 1 of CONTROL to use the PSP
    msr control, r1
    isb                         @ instruction sync barrier

    pop {r0-r3, r12, lr}
    pop {pc}                    @ ret
