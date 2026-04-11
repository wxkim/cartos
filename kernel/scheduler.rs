use crate::kernel::TCB_Handle;
use core::sync::atomic::{AtomicUsize, Ordering};

static counter: AtomicUsize = AtomicUsize::new(0);
const icsr: *mut u32 = 0xE000ED04 as *mut u32;
const PENDSV: u32 = 1 << 28;

#[unsafe(no_mangle)]
pub unsafe extern "C" fn kernel_next_task() -> *mut TCB_Handle {
    let state = unsafe { &mut *core::ptr::addr_of_mut!(super::kernel) };

    if state.current_task.is_null() {
        return core::ptr::null_mut();
    }

    let current = state.current_task;
    let next = (*current).next;

    if next.is_null() {
        return current;
    }

    state.current_task = next;

    next
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn tick_handler() {
    let increment = unsafe { (*core::ptr::addr_of_mut!(super::kernel)).systick_ctr };
    counter.fetch_add(increment as usize, Ordering::SeqCst);
    unsafe {
        set_PendSV();
    }
}

#[inline(always)]
unsafe fn set_PendSV() {
    unsafe {
        core::ptr::write_volatile(icsr, PENDSV);
    }
}
