@blocking delay 
.syntax unified
.thumb
.global b_delay


.thumb_func
b_delay:
    @ r0 = delay in ms

ms:
    movs r1, #4000                       

cnt:
    subs r1, r1, #1                     
    bne cnt                            

    subs r0, r0, #1
    bne ms       

    bx lr