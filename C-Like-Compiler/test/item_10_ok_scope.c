void main() {
    int x;
    x = 10;
    if(x) {
        int x;
        puts("\n");
        x = 11;
        if(x) {
            int x;
            puts("\n");
            x = 12;
            if(x) {
                int x;
                puts("\n");
                x = 13;
                puts("Scope 3. Val: ");
                putint(x);
                puts("\n");
            }
            puts("Sscope 2. Val: ");
            putint(x);
            puts("\n");
        }
        puts("Scope 1. Val: ");
        putint(x);
        puts("\n");
    }
    puts("Scope 0. Val: ");
    putint(x);
    puts("\n");
}
