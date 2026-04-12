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
    #[unsafe(no_mangle)]
    pub unsafe extern "C" fn lock(mutexptr: *mut Mutex) {
        let mutex = &mut *mutexptr;

        unsafe {
            core::arch::asm!("cpsid i");
            let state = &mut *core::ptr::addr_of_mut!(crate::kernel);
            let current = state.current_task;

            if mutex.lock == 0 {
                mutex.lock = 1;
                mutex.owner = current;
                core::arch::asm!("cpsie i");
            } else {
                (*current).next = mutex.waitlist;
                mutex.waitlist = current;
                core::arch::asm!("cpsie i");
                crate::scheduler::pended_service_ready();
            }
        }
    }

    #[unsafe(no_mangle)]
    pub unsafe extern "C" fn unlock(mutexptr: *mut Mutex) {
        let mutex = &mut *mutexptr;

        unsafe {
            core::arch::asm!("cpsid i");
            let state = &mut *core::ptr::addr_of_mut!(crate::kernel);
            if mutex.waitlist.is_null() {
                mutex.lock = 0;
                mutex.waitlist == null_mut();
            } else {
                let next = mutex.waitlist;
                mutex.waitlist = (*next).next;

                mutex.owner = next;

                let head = state.ready_queue[3];
                (*next).next = head;
                state.ready_queue[3] = next;

                crate::scheduler::pended_service_ready();
            }
            core::arch::asm!("cpsie i");
        }
    }
}

pub struct MutexGuard<'a> {
    mutex: &'a mut Mutex,
}

impl<'a> MutexGuard<'a> {
    pub fn new(mutex: &'a mut Mutex) -> Self {
        unsafe {
            Mutex::lock(mutex as *mut Mutex);
        }
        Self { mutex }
    }
}

impl<'a> Drop for MutexGuard<'a> {
    fn drop(&mut self) {
        unsafe {
            Mutex::unlock(self.mutex as *mut Mutex);
        }
    }
}
