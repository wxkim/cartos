use crate::kernel::{KernelState, TCB_Handle};

#[unsafe(no_mangle)]
pub unsafe extern "C" fn kernel_add_task(tcb: *mut TCB_Handle) {
    unsafe {
        let state = &mut *core::ptr::addr_of_mut!(crate::kernel);

        let prio_idx = (*tcb).prio as usize;

        if prio_idx >= 6 {
            return;
        }

        (*tcb).next = state.ready_queue[prio_idx];

        state.ready_queue[prio_idx] = tcb;

        if state.current_task.is_null() {
            state.current_task = tcb;
        }
    }
}
