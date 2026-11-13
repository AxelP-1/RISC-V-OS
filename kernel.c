#define UART0 ((volatile unsigned char *)0x10000000)

static void putc(char c)        { *UART0 = c; }
static void puts(const char *s) { while (*s) putc(*s++); }

void kmain(void) {
    puts("Hello from my OS!\n");
    for (;;) ;
}
