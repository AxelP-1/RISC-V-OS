.section .text.init
.global _start
_start:
    csrr t0, mhartid
    bnez t0, park
    la   sp, stack_top
    call kmain
park:
    wfi
    j park
