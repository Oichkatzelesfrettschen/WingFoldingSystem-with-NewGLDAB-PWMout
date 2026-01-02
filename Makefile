# Wing Folding System - Build System
# Modern Makefile for Arduino-based ornithopter control system

# Variables
PROJECT_NAME = WingFoldingSystem
SKETCH_DIR = sketch250209PWMoutAGLDABFoldWingiVtail2S
SKETCH = $(SKETCH_DIR)/$(SKETCH_DIR).ino
ARDUINO_CLI = arduino-cli
PIO = pio

# Board configurations
BOARD_UNO = arduino:avr:uno
BOARD_MEGA = arduino:avr:mega
BOARD_NANO = arduino:avr:nano

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Wing Folding System - Build System"
	@echo "==================================="
	@echo ""
	@echo "Available targets:"
	@echo "  build-pio          - Build with PlatformIO (recommended)"
	@echo "  upload-pio         - Upload with PlatformIO"
	@echo "  monitor-pio        - Start serial monitor"
	@echo "  clean-pio          - Clean PlatformIO build artifacts"
	@echo "  test               - Run verification tests"
	@echo "  docs               - Generate documentation"
	@echo "  verify             - Run formal verification (TLA+/Z3)"
	@echo "  format             - Format code"
	@echo "  check              - Run static analysis"
	@echo "  install-deps       - Install build dependencies"
	@echo "  clean              - Clean all build artifacts"
	@echo ""

# PlatformIO targets
.PHONY: build-pio
build-pio:
	@echo "Building with PlatformIO..."
	@$(PIO) run -e uno

.PHONY: upload-pio
upload-pio:
	@echo "Uploading with PlatformIO..."
	@$(PIO) run -e uno -t upload

.PHONY: monitor-pio
monitor-pio:
	@echo "Starting serial monitor..."
	@$(PIO) device monitor

.PHONY: clean-pio
clean-pio:
	@echo "Cleaning PlatformIO build..."
	@$(PIO) run -t clean

# Testing targets
.PHONY: test
test:
	@echo "Running verification tests..."
	@if [ -d "tests" ]; then \
		$(PIO) test; \
	else \
		echo "No tests directory found. Skipping tests."; \
	fi

# Documentation
.PHONY: docs
docs:
	@echo "Generating documentation..."
	@echo "Documentation available in docs/ directory"

# Formal verification
.PHONY: verify
verify:
	@echo "Running formal verification..."
	@if [ -d "formal_verification" ]; then \
		cd formal_verification && make verify; \
	else \
		echo "No formal verification directory found."; \
	fi

# Code formatting
.PHONY: format
format:
	@echo "Formatting code..."
	@find $(SKETCH_DIR) -name "*.ino" -o -name "*.cpp" -o -name "*.h" | \
		xargs -I {} sh -c 'if command -v clang-format >/dev/null; then clang-format -i {}; fi'

# Static analysis
.PHONY: check
check:
	@echo "Running static analysis..."
	@$(PIO) check

# Install dependencies
.PHONY: install-deps
install-deps:
	@echo "Installing dependencies..."
	@if ! command -v $(PIO) >/dev/null; then \
		echo "Installing PlatformIO..."; \
		pip install -U platformio; \
	fi
	@echo "Dependencies installed."

# Clean all
.PHONY: clean
clean: clean-pio
	@echo "Cleaning all build artifacts..."
	@rm -rf build/
	@rm -rf dist/
	@find . -name "*.o" -delete
	@find . -name "*.elf" -delete
	@find . -name "*.hex" -delete
	@echo "Clean complete."

# Phony targets
.PHONY: all help build-pio upload-pio monitor-pio clean-pio test docs verify format check install-deps clean
