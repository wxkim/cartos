$(shell mkdir -p build)

CC      = arm-none-eabi-gcc
AS      = arm-none-eabi-gcc
LD      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

BUILD_DIR = build
APP_DIR   = app
CORE_DIR  = core
HAL_DIR   = hal

CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS    = $(CPU_FLAGS) -Wall -O2 -ffunction-sections -fdata-sections -Iinclude -I$(APP_DIR)
ASFLAGS   = $(CPU_FLAGS) -c
LDFLAGS   = $(CPU_FLAGS) -Tlink.ld -Wl,--gc-sections -nostartfiles -nostdlib

VPATH = $(APP_DIR):$(CORE_DIR):$(HAL_DIR)

ASM_SOURCES = startup.s context.s delay.s gpio.s
C_SOURCES   = main.c syscalls.c

OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCES:.s=.o)))
OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCES:.c=.o)))

RUST_TARGET = thumbv7em-none-eabihf
RUST_LIB = target/$(RUST_TARGET)/release/libkernel.a

all: $(BUILD_DIR)/rtos.bin

$(BUILD_DIR):
	mkdir -p $@

$(RUST_LIB):
	rustup run nightly cargo build --release -Z build-std=core --target $(RUST_TARGET)
	@cp target/$(RUST_TARGET)/release/deps/libkernel-*.a $(RUST_LIB) 2>/dev/null || :

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/rtos.elf: build/startup.o $(OBJECTS) $(RUST_LIB)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS) $(RUST_LIB)

$(BUILD_DIR)/rtos.bin: $(BUILD_DIR)/rtos.elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILD_DIR)
	cargo clean

.PHONY: all clean $(RUST_LIB)