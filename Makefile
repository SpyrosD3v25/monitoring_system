CC = gcc
CFLAGS = -Wall -Wextra -Werror -std=c11 -O2
THREAD_FLAGS = -pthread

ANALYZER = analyze_log
PARALLEL = parallel_analyze

SRC_DIR = src
ANALYZER_SRC = $(SRC_DIR)/analyze.c
PARALLEL_SRC = $(SRC_DIR)/parallel_analyze.c

all: $(ANALYZER) $(PARALLEL)
	@echo ""
	@echo "Build complete"
	@echo "Programs: analyze_log, parallel_analyze"
	@echo ""

$(ANALYZER): $(ANALYZER_SRC)
	@echo "Compiling analyze_log..."
	$(CC) $(CFLAGS) -o $@ $<

$(PARALLEL): $(PARALLEL_SRC)
	@echo "Compiling parallel_analyze..."
	$(CC) $(CFLAGS) $(THREAD_FLAGS) -o $@ $<

clean:
	@echo "Cleaning..."
	rm -f $(ANALYZER) $(PARALLEL)
	rm -rf monitor/processed/* monitor/reports/*
	@echo "Done"

test: all
	@echo ""
	@echo "Running tests..."
	@echo ""
	@echo "Test 1: No arguments"
	@./$(ANALYZER) || true
	@echo ""
	@echo "Test 2: Non-existent file"
	@./$(ANALYZER) /tmp/nonexistent.log || true
	@echo ""

.PHONY: all clean test
