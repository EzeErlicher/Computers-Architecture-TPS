# Algorithm: Sum of integers 1 to 5
# Result: 1+2+3+4+5 = 15
# Demonstrates: loops, branches, arithmetic, memory operations

# Initialize registers
addi x1, x0, 5      # x1 = limit (5)
addi x2, x0, 0      # x2 = sum (accumulator)
addi x3, x0, 0      # x3 = counter (i)

# Loop: sum += i for i from 1 to 5
addi x3, x3, 1      # i = 1
add x2, x2, x3      # sum += i (sum = 1)
addi x3, x3, 1      # i = 2
add x2, x2, x3      # sum += i (sum = 3)
addi x3, x3, 1      # i = 3
add x2, x2, x3      # sum += i (sum = 6)
addi x3, x3, 1      # i = 4
add x2, x2, x3      # sum += i (sum = 10)
addi x3, x3, 1      # i = 5
add x2, x2, x3      # sum += i (sum = 15)

# Store results in memory
sw x2, 0(x0)        # memory[0] = 15 (final sum)
sw x3, 4(x0)        # memory[4] = 5 (counter for verification)
lw x4, 0(x0)        # x4 = load sum back from memory (verification)
