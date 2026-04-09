#[repr(C)]
pub struct Tcb { ... }

#[no_mangle]
pub extern "C" fn kernel_next_task() -> *mut Tcb { 

 }