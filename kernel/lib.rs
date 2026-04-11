#![no_std]
use crate::kernel::{TCB_Handle, kernelState};
use core::ffi::c_void;

pub mod kernel;
pub mod scheduler;

#[unsafe(no_mangle)]
pub static mut kernel: kernelState = kernelState::new();

#[unsafe(no_mangle)]
pub unsafe extern "C" fn init_kernel(T: *mut TCB_Handle, arg: *mut core::ffi::c_void) {
    let mut sp = (*T).sptr;
    let mut sphw = preemption_stack(sp, (*T).function as u32, arg as u32);

    let mut sp = sphw;
    for _ in 0..8 {
        sp = sp.offset(-1);
        *sp = 0; // Initial values for R4-R11
    }

    (*T).sptr = sp;
}

/*
https://developer.arm.com/documentation/ddi0337/e/Exceptions/Pre-emption/Stacking
*/
unsafe fn preemption_stack(mut sp: *mut u32, address: u32, arg: u32) -> *mut u32 {
    unsafe {
        sp = sp.offset(-1);
        *sp = 1 << 24;

        sp = sp.offset(-1);
        *sp = address;

        sp = sp.offset(-1);
        *sp = 0xFFFFFFFD;

        sp = sp.offset(-1);
        *sp = 0; // R12
        sp = sp.offset(-1);
        *sp = 0; // R3
        sp = sp.offset(-1);
        *sp = 0; // R2
        sp = sp.offset(-1);
        *sp = 0; // R1
        sp = sp.offset(-1);
        *sp = arg; // R0
    }
    sp
}

#[cfg(not(test))]
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {
        // todo: toggle led
    }
}
