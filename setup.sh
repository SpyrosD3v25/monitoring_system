#!/bin/bash

echo "Making scripts executable..."
chmod +x run_all.sh
chmod +x src/*.sh
chmod +x tests/*.sh
echo ""

echo "Compiling C programs..."

echo "  - Compiling analyze.c..."
gcc -o analyze_log src/analyze.c
if [ $? -eq 0 ]; then
    chmod +x analyze_log
else
    exit 1
fi

echo "  - Compiling parallel_analyze.c..."
gcc -pthread -o parallel_analyze src/parallel_analyze.c
if [ $? -eq 0 ]; then
    chmod +x parallel_analyze
else
    exit 1
fi

cd tests
gcc -o generator generator.c
if [ $? -eq 0 ]; then
    chmod +x generator
else
fi
cd ..

echo ""
echo "========================================="
echo "   Setup Complete!"
echo "========================================="
echo ""
echo "You can now run:"
echo "  ./run_all.sh                  # Use sample data"
echo "  ./run_all.sh --test_size 1000 # Generate test data"
echo ""
