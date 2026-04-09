CC      = arm-none-eabi-gcc
AS      = arm-none-eabi-as
LD      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16

CFLAGS  = $(CPU_FLAGS) -Wall -O2 -ffunction-sections -fdata-sections -Itest
ASFLAGS = $(CPU_FLAGS)
LDFLAGS = $(CPU_FLAGS) -Tlinker.ld -Wl,--gc-sections -nostartfiles

ASM_SOURCES = src/startup.s src/context.s lib/delay.s lib/gpio.s
C_SOURCES   = test/main.c
RUST_LIB    = kernel-rs/target/thumbv7em-none-eabihf/release/libkernel_rs.a

OBJECTS = $(ASM_SOURCES:.s=.o) $(C_SOURCES:.c=.o)

all: rtos.bin

$(RUST_LIB):
	@echo "Building Rust Kernel..."
	cd kernel-rs && cargo build --release --target thumbv7em-none-eabihf

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

rtos.elf: $(OBJECTS) $(RUST_LIB)
	$(LD) $(LDFLAGS) $(OBJECTS) $(RUST_LIB) -o $@

rtos.bin: rtos.elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJECTS) *.elf *.bin
	cd kernel-rs && cargo clean

.PHONY: all clean $(RUST_LIB)