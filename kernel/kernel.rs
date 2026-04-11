use core::ffi::c_void;

#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Priority {
    None = 5,
    Low = 4,
    Normal = 3,
    High = 2,
    Critical = 1,
    ISRNonyieldable = 0,
}

#[repr(C)]
pub struct TCB_Handle {
    pub sptr: *mut u32,
    pub function: extern "C" fn(*mut c_void),
    pub prio: Priority,
    pub next: *mut TCB_Handle,
}

pub struct KernelState {
    pub current_task: *mut TCB_Handle,
    pub systick_ctr: u32,
    pub ready_lists: [*mut TCB_Handle; 6],
}

impl KernelState {
    pub const fn new() -> Self {
        Self {
            current_task: core::ptr::null_mut(),
            systick_ctr: 0,
            ready_lists: [core::ptr::null_mut(); 6],
        }
    }
}
