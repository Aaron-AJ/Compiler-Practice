void main() {
    int a;
    int b;
    int c;
    a = 1;
    b = 2;
    c = 3;

    putint(a + b < c * a);	// 3 < 3 = 0
    puts("\n");
    putint(a == b == 0);	// 0 == 0 = 0
    puts("\n");
    putint((a < b) == 1);	// 1 == 1 = 1
    puts("\n");
}
