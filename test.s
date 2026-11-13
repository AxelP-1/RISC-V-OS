
.text
.globl main

main:
    li a1, 1
    li a2, 1000

    j loop

loop:
    add a1, a1, a1  

    li a0, 1       # Print integer
    mv a3, a1      # Preserve value as print argument
    mv a1, a3
    ecall

    li a0, 11      # Print character
    li a1, 10      # Newline
    ecall

    li a2, 1000

    mv a1, a3
    blt a1, a2, loop

    
    j done

done:
    li a0, 10
    ecall
