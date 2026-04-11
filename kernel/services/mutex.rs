use core::ptr::{null, null_mut};

use crate::kernel::{KernelState, Priority, TCB_Handle};

pub struct Mutex {
    lock: u32,
    owner: *mut TCB_Handle,
    waitlist: *mut TCB_Handle,
}

impl Mutex {
    pub fn new() -> Self {
        Self {
            lock: 0,
            owner: null_mut(),
            waitlist: null_mut(),
        }
    }
}
