
.globl _start

_start:
    li t0, 0x10000000 #I/O device
    li s0, 0x88000000 #Message storage
    li sp,0x88000000 #Stack pointer

    addi sp, sp, -4

    sw zero, -3(s0)


    j newLine

newLine:
    #Print > to indicate the message is starting
    li t1, '>'
    sb t1, 0(t0)
    li t1, ' '
    sb t1, 0(t0)


    j wait

wait:
    lbu t1, 5(t0)
    andi t1, t1, 1 #Is there a  message notification?
    beqz t1, wait #No? Check phone again

    lbu t2, 0(t0) #What message have I received?

    sb t2, 0(t0)

    lw t3, -3(s0) #What us the length of the messages?

    sub t4, s0, t3 #Store the message wherever the next empty spot is (could use stack pointer but doesn't)
    addi t4, t4, -4
    sb t2, 0(t4)

    addi sp, sp, -1 #Increment message length and stack pointer
    addi t3, t3, 1
    sw t3, -3(s0)

    li t5, 10

    beq t5, t2, checkForHello

    j wait #Repeat wait, do it like me: if you received a message, check your phone again in case a second message has come.

checkForHello:
    lw t3, -3(s0) #What us the length of the messages?
    li t1, 5
    blt t3, t1, rudeOption

    lb t2, -4(s0)
    li t3, 'H'
    bne t2, t3, rudeOption
    lb t2, -5(s0)
    li t3, 'e'
    bne t2, t3, rudeOption
    lb t2, -6(s0)
    li t3, 'l'
    bne t2, t3, rudeOption
    lb  t2, -7(s0)
    li t3, 'l'
    bne t2, t3, rudeOption
    lb t2, -8(s0)
    li t3, 'o'
    bne t2, t3, rudeOption

    li t1, 'H'
    sb t1, 0(t0)
    li t1, 'i'
    sb t1, 0(t0)
    li t1, '.'
    sb t1, 0(t0)
    li t1, 10
    sb t1, 0(t0)

    j wipeMemory

rudeOption:
    li t1, 'H'
    sb t1, 0(t0)
    li t1, 'i'
    sb t1, 0(t0)
    li t1, ','
    sb t1, 0(t0)
    li t1, ' '
    sb t1, 0(t0)
    li t1, 's'
    sb t1, 0(t0)
    li t1, 'h'
    sb t1, 0(t0)
    li t1, 'o'
    sb t1, 0(t0)
    li t1, 'w'
    sb t1, 0(t0)
    li t1, ' '
    sb t1, 0(t0)
    li t1, 'r'
    sb t1, 0(t0)
    li t1, 'e'
    sb t1, 0(t0)
    li t1, 's'
    sb t1, 0(t0)
    li t1, 'p'
    sb t1, 0(t0)
    li t1, 'e'
    sb t1, 0(t0)
    li t1, 'c'
    sb t1, 0(t0)
    li t1, 't'
    sb t1, 0(t0)
    li t1, '.'
    sb t1, 0(t0)
    li t1, 10
    sb t1, 0(t0)

    j wipeMemory

wipeMemory:
    sb zero, 0(sp)
    addi sp, sp, 1

    bne sp, s0, wipeMemory

    sw zero, -3(s0)

    j newLine
