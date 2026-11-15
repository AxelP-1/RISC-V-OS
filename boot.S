.globl _start

_start:
    li t0, 0x10000000 #I/O device
    li s0, 0x88000000 #Message storage
    li sp, 0x88000000 #Stack pointer

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

    li t5, 127 # Delete?
    beq t2, t5, doBackspace
    li t5, 8 # Backspace?
    beq t2, t5, doBackspace


    sb t2, 0(t0)

    lw t3, -3(s0) #What us the length of the messages?

    sub t4, s0, t3 #Store the message wherever the next empty spot is (could use stack pointer but doesn't)
    addi t4, t4, -4
    sb t2, 0(t4)

    addi sp, sp, -1 #Increment message length and stack pointer
    addi t3, t3, 1
    sw t3, -3(s0)

    li t5, 10

    beq t5, t2, checkForCommands

    j wait #Repeat wait, do it like me: if you received a message, check your phone again in case a second message has come.


doBackspace:
    jal ra, backspace
    j wait

edBackspace:
    jal ra, backspace
    j runEditor

backspace:
    lw t3, -3(s0)
    beqz t3, bsDone

    sub t4, s0, t3
    addi t4, t4, -3
    lbu t2, 0(t4)

    addi t3, t3, -1
    sw t3, -3(s0)
    addi sp, sp, 1

    li t1, 10
    beq t2, t1, bsNewline
    li t1, 9
    beq t2, t1, bsTab
    li t6, 1
    j bsErase

bsTab:
    jal s2, getColumn
    andi t6, t5, 7
    li t1, 8
    sub t6, t1, t6

bsErase:
    li t1, 8
    sb t1, 0(t0)
    li t1, ' '
    sb t1, 0(t0)
    li t1, 8
    sb t1, 0(t0)
    addi t6, t6, -1
    bnez t6, bsErase

bsDone:
    ret

bsNewline:
    li t1, 27                 # ESC [ A  (cursor up)
    sb t1, 0(t0)
    li t1, '['
    sb t1, 0(t0)
    li t1, 'A'
    sb t1, 0(t0)
    li t1, 13                 # carriage return
    sb t1, 0(t0)

    sub t4, s0, t3
    addi t4, t4, -3
    mv t5, t4
    mv t6, t3

findLineStart:
    beqz t6, printLine
    lbu t2, 0(t4)
    li t1, 10
    beq t2, t1, printLine
    addi t4, t4, 1
    addi t6, t6, -1
    j findLineStart

printLine:
    addi t4, t4, -1
    bltu t4, t5, bsDone
    lbu t1, 0(t4)
    sb t1, 0(t0)
    j printLine

getColumn:
    mv t5, s1
    addi t4, s0, -4
    mv t6, t3
    colLoop:
    beqz t6, colDone
    lbu t2, 0(t4)
    li t1, 10
    beq t2, t1, colNewline
    li t1, 9
    beq t2, t1, colTab
    addi t5, t5, 1
    j colNext

colNewline:
    li t5, 0
    j colNext

colTab:
    andi t1, t5, 7
    li t2, 8
    sub t1, t2, t1
    add t5, t5, t1

colNext:
    addi t4, t4, -1
    addi t6, t6, -1
    j colLoop

colDone:
    jr s2


checkForCommands:
    la t6, checkForHello
    jalr ra, 0(t6)

    la t6, checkForEditor
    jalr ra, 0(t6)

    j rudeOption

checkForHello:
    lw t3, -3(s0) #What us the length of the messages?
    li t1, 6
    blt t3, t1, return

    lb t2, -4(s0)
    li t3, 'H'
    bne t2, t3, return
    lb t2, -5(s0)
    li t3, 'e'
    bne t2, t3, return
    lb t2, -6(s0)
    li t3, 'l'
    bne t2, t3, return
    lb  t2, -7(s0)
    li t3, 'l'
    bne t2, t3, return
    lb t2, -8(s0)
    li t3, 'o'
    bne t2, t3, return

    lb t2, -9(s0)
    li t3, 9
    beq t2, t3, respondHello
    li t3, 10
    beq t2, t3, respondHello
    li t3, 11
    beq t2, t3, respondHello
    li t3, 12
    beq t2, t3, respondHello
    li t3, 13
    beq t2, t3, respondHello
    li t3, 32
    beq t2, t3, respondHello

    j return


checkForEditor:
    lw t3, -3(s0) #What us the length of the messages?
    li t1, 7
    blt t3, t1, return

    lb t2, -4(s0)
    li t3, 'E'
    bne t2, t3, return
    lb t2, -5(s0)
    li t3, 'd'
    bne t2, t3, return
    lb t2, -6(s0)
    li t3, 'i'
    bne t2, t3, return
    lb  t2, -7(s0)
    li t3, 't'
    bne t2, t3, return
    lb t2, -8(s0)
    li t3, 'o'
    bne t2, t3, return
    lb t2, -9(s0)
    li t3, 'r'
    bne t2, t3, return

    lb t2, -10(s0)
    li t3, 9
    beq t2, t3, respondEditor
    li t3, 10
    beq t2, t3, respondEditor
    li t3, 11
    beq t2, t3, respondEditor
    li t3, 12
    beq t2, t3, respondEditor
    li t3, 13
    beq t2, t3, respondEditor
    li t3, 32
    beq t2, t3, respondEditor

    j return

respondEditor:
    li t1, 'N'
    sb t1, 0(t0)
    li t1, 'e'
    sb t1, 0(t0)
    li t1, 'w'
    sb t1, 0(t0)
    li t1, ' '
    sb t1, 0(t0)
    li t1, 'f'
    sb t1, 0(t0)
    li t1, 'i'
    sb t1, 0(t0)
    li t1, 'l'
    sb t1, 0(t0)
    li t1, 'e'
    sb t1, 0(t0)

    li t1, 10
    sb t1, 0(t0)
    li t1, 10
    sb t1, 0(t0)
    li t1, 10
    sb t1, 0(t0)

    la t6, wipeMemory
    jalr ra, 0(t6)

    j runEditor

runEditor:
    lbu t1, 5(t0)
    andi t1, t1, 1 #Is there a  message notification?
    beqz t1, runEditor #No? Check phone again

    lbu t2, 0(t0) #What message have I received?

    li t5, 127 # Delete?
    beq t2, t5, edBackspace
    li t5, 8 # Backspace?
    beq t2, t5, edBackspace

    sb t2, 0(t0)

    lw t3, -3(s0) #What us the length of the messages?

    sub t4, s0, t3 #Store the message wherever the next empty spot is (could use stack pointer but doesn't)
    addi t4, t4, -4
    sb t2, 0(t4)

    addi sp, sp, -1 #Increment message length and stack pointer
    addi t3, t3, 1
    sw t3, -3(s0)


    j runEditor


respondHello:
    li t1, 'H'
    sb t1, 0(t0)
    li t1, 'i'
    sb t1, 0(t0)
    li t1, '.'
    sb t1, 0(t0)
    li t1, 10
    sb t1, 0(t0)

    la t6, wipeMemory
    jalr ra, 0(t6)

    j newLine


return:
    ret

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
    li t1, ' '
    sb t1, 0(t0)
    li t1, 't'
    sb t1, 0(t0)
    li t1, 'o'
    sb t1, 0(t0)
    li t1, ' '
    sb t1, 0(t0)
    li t1, 'M'
    sb t1, 0(t0)
    li t1, 'y'
    sb t1, 0(t0)
    li t1, 'O'
    sb t1, 0(t0)
    li t1, 'S'
    sb t1, 0(t0)
    li t1, '.'
    sb t1, 0(t0)
    li t1, 10
    sb t1, 0(t0)

    la t6, wipeMemory
    jalr ra, 0(t6)
    j newLine

wipeMemory:
    sb zero, 0(sp)
    addi sp, sp, 1

    bne sp, s0, wipeMemory

    sw zero, -3(s0)

    ret
