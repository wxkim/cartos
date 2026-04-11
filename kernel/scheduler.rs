use crate::kernel::TCB_Handle;

const ICSR: *mut u32 = 0xE000ED04 as *mut u32;
const PENDSV: u32 = 1 << 28;

#[unsafe(no_mangle)]
pub unsafe extern "C" fn kernel_next_task() -> *mut TCB_Handle {
    unsafe { schedule_next() }
}

unsafe fn schedule_next() -> *mut TCB_Handle {
    let state = &mut *core::ptr::addr_of_mut!(crate::kernel);
    unsafe {
        for i in 0..6 {
            let head = state.ready_queue[i];

            if !head.is_null() {
                let next_in_line = (*head).next;

                if !next_in_line.is_null() {
                    let mut tail = next_in_line;
                    while !(*tail).next.is_null() {
                        tail = (*tail).next;
                    }

                    (*tail).next = head;

                    (*head).next = core::ptr::null_mut();

                    state.ready_queue[i] = next_in_line;

                    state.current_task = head;
                    return head;
                }

                state.current_task = head;
                return head;
            }
        }
    }

    state.current_task
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn tick_handler() {
    unsafe {
        let state = &mut *core::ptr::addr_of_mut!(crate::kernel);
        state.systick_ctr = state.systick_ctr.wrapping_add(1);
    }
    pended_service_ready();
}

#[inline(always)]
fn pended_service_ready() {
    unsafe {
        core::ptr::write_volatile(ICSR, PENDSV);
    }
}
