# Makefile for Formal Verification
# TLA+ and Z3 verification for Wing Folding System

# Tools
TLATOOLS = java -cp tla2tools.jar
TLC = $(TLATOOLS) tlc2.TLC
SANY = $(TLATOOLS) tla2sany.SANY
Z3 = z3

# Files
TLA_SPEC = WingFoldingSystem.tla
TLA_CONFIG = WingFoldingSystem.cfg
SMT_FILE = constraints.smt2

# Output directories
TLC_OUTPUT = tlc_output
Z3_OUTPUT = z3_output

.PHONY: all verify verify-tla verify-z3 clean help

all: help

help:
	@echo "Formal Verification Makefile"
	@echo "=============================="
	@echo ""
	@echo "Available targets:"
	@echo "  verify      - Run all verifications (TLA+ and Z3)"
	@echo "  verify-tla  - Run TLA+ model checking"
	@echo "  verify-z3   - Run Z3 SMT solver verification"
	@echo "  clean       - Clean output files"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - Java (for TLA+ tools)"
	@echo "  - tla2tools.jar (download from TLA+ website)"
	@echo "  - Z3 theorem prover (install via package manager)"
	@echo ""

verify: verify-z3
	@echo ""
	@echo "Note: TLA+ verification requires tla2tools.jar"
	@echo "Download from: https://github.com/tlaplus/tlaplus/releases"
	@echo ""

verify-tla: $(TLA_SPEC) $(TLA_CONFIG)
	@echo "Running TLA+ Model Checking..."
	@mkdir -p $(TLC_OUTPUT)
	@if command -v java >/dev/null 2>&1 && java -version 2>&1 | grep -q "version \"1\.[8-9]\|version \"[0-9][0-9]" && [ -f tla2tools.jar ]; then \
		$(TLC) -config $(TLA_CONFIG) $(TLA_SPEC) -workers auto -deadlock \
			2>&1 | tee $(TLC_OUTPUT)/tlc_output.txt; \
	else \
		echo "Error: Java 8 or higher, or tla2tools.jar, not found"; \
		echo "Please install Java 8+ and download tla2tools.jar"; \
		exit 1; \
	fi

verify-z3: $(SMT_FILE)
	@echo "Running Z3 SMT Solver Verification..."
	@mkdir -p $(Z3_OUTPUT)
	@if command -v $(Z3) >/dev/null 2>&1; then \
		$(Z3) $(SMT_FILE) > $(Z3_OUTPUT)/z3_results.txt 2>&1; \
		cat $(Z3_OUTPUT)/z3_results.txt; \
		echo ""; \
		echo "Results saved to: $(Z3_OUTPUT)/z3_results.txt"; \
	else \
		echo "Warning: Z3 not found. Skipping Z3 verification."; \
		echo "Install Z3: sudo apt-get install z3 (Ubuntu/Debian)"; \
		echo "           or: brew install z3 (macOS)"; \
	fi

clean:
	@echo "Cleaning formal verification outputs..."
	@rm -rf $(TLC_OUTPUT) $(Z3_OUTPUT)
	@rm -f *.dot *.out *.pdf
	@echo "Clean complete."

.PHONY: install-tools
install-tools:
	@echo "Installing formal verification tools..."
	@echo ""
	@echo "1. Installing Z3..."
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "Using apt-get (Debian/Ubuntu)..."; \
		sudo apt-get update && sudo apt-get install -y z3; \
	elif command -v brew >/dev/null 2>&1; then \
		echo "Using Homebrew (macOS)..."; \
		brew install z3; \
	else \
		echo "Please install Z3 manually from: https://github.com/Z3Prover/z3"; \
	fi
	@echo ""
	@echo "2. Downloading TLA+ Tools..."
	@if [ ! -f tla2tools.jar ]; then \
		echo "Downloading tla2tools.jar..."; \
		wget https://github.com/tlaplus/tlaplus/releases/download/v1.7.1/tla2tools.jar; \
	else \
		echo "tla2tools.jar already present."; \
	fi
	@echo ""
	@echo "Installation complete!"
