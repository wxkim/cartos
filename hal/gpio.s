.syntax unified
.thumb

.equ RCC_BASE,       0x40021000    
.equ RCC_AHB2ENR,     RCC_BASE + 0x4C    
.equ MODER_OFFSET,   0x00
.equ ODR_OFFSET,     0x14           
.equ BSRR_OFFSET,    0x18

.global gpio_init
.global gpio_toggle


.thumb_func
gpio_init:
    @ r0: port base, r1: pin, r2: mode
    ldr r3, =RCC_AHBENR                        
    ldr r4, [r3]
    orr r4, r4, 1                       
    str r4, [r3]

    lsl r3, r1, #1
    mov r4, #3
    lsl r4, r4, r3

    ldr r5, [r0, #MODER_OFFSET]                  
    bic r5, r5, r4                      
    lsl r6, r2, r3
    orr r5, r5, r6
    str r5, [r0, #MODER_OFFSET]                  

    bx lr                                

.thumb_func
gpio_toggle:
    @ r0 = port base
    @ r1 = pin number

    ldr r2, [r0, #ODR_OFFSET]                
    movs r3, #1               
    lsl r3, r3, r1                    
    eor r2, r2, r3                    
    str r2, [r0, #ODR_OFFSET]         

    bx lr           


.thumb_func
gpio_toggle_atomic:         @uses BSRR instead of ODR for atomic set and reset
    @ r0 = port base
    @ r1 = pin number
    
    ldr r2, [r0, #ODR_OFFSET]
    movs r3, #1
    lsl r3, r3, r1         
    
    tst r2, r3             
    ite eq                 
    moveq r2, r3           
    lslne r2, r3, #16      
    str r2, [r0, #BSRR_OFFSET] 
    
    bx lr


