use core::ffi::c_void;

#[repr(C)]
pub struct TCB_Handle {
    pub sptr: *mut u32,
    pub function: extern "C" fn(*mut c_void),
    pub prio: u32,
    pub next: *mut TCB_Handle,
}

pub struct kernelState {
    pub current_task: *mut TCB_Handle,
    pub systick_ctr: u32,
}

impl kernelState {
    pub const fn new() -> Self {
        Self {
            current_task: core::ptr::null_mut(),
            systick_ctr: 0,
        }
    }
}
