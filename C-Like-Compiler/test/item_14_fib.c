int fib(int n);

void main() {
    int x;
    puts("Type in integer...\n");
    x = getint();
    puts("\n");
    putint(fib(x));
}

int fib(int n) {
    int x;
    int y;
    if(n == 0 || n == 1) {
        return n;
    }
    x = fib(n-1);
    y = fib(n-2);
    return x + y;
}
