    .global main
main:
    li a0, 1              # Set up for syscall (1 = print)
    la a1, message        # Load address of message
    ecall                 # Make the syscall to print the message
    li a7, 10             # Set up for exit syscall
    ecall                 # Make the syscall to exit the program

    .data
message:
    .asciz "Hello, RISC-V!\n"

