CC      = arm-none-eabi-gcc
AS      = arm-none-eabi-gcc
LD      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

BUILD_DIR = build
K_DIR     = kernel
APP_DIR   = app
SERV_DIR  = services
LIB_DIR   = lib

CPU_FLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16

CFLAGS  = $(CPU_FLAGS) -Wall -O2 -ffunction-sections -fdata-sections -Iinclude -I$(APP_DIR)
ASFLAGS = $(CPU_FLAGS) -c
LDFLAGS = $(CPU_FLAGS) -Tlink.ld -Wl,--gc-sections -nostartfiles

ASM_SOURCES = $(SERV_DIR)/startup.s $(SERV_DIR)/context.s $(LIB_DIR)/delay.s $(LIB_DIR)/gpio.s
C_SOURCES   = $(APP_DIR)/main.c

RUST_TARGET = thumbv7em-none-eabihf
RUST_LIB    = $(K_DIR)/target/$(RUST_TARGET)/release/libkernel.a

OBJECTS = $(addprefix $(BUILD_DIR)/, $(notdir $(ASM_SOURCES:.s=.o)))
OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCES:.c=.o)))

VPATH = $(SERV_DIR):$(LIB_DIR):$(APP_DIR)

all: $(BUILD_DIR)/rtos.bin

$(BUILD_DIR):
	mkdir -p $@

$(RUST_LIB):
	@echo "Building Rust Kernel"
	cargo build --release --target $(RUST_TARGET)

$(BUILD_DIR)/%.o: %.s | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/rtos.elf: $(OBJECTS) $(RUST_LIB)
	$(LD) $(LDFLAGS) $(OBJECTS) $(RUST_LIB) -o $@

$(BUILD_DIR)/rtos.bin: $(BUILD_DIR)/rtos.elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -rf $(BUILD_DIR)
	cargo clean

.PHONY: all clean $(RUST_LIB)