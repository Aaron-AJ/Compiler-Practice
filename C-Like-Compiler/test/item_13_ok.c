int test(string s);
int sum(string s, int size, int t);

void main() {
    int ret;
    string y;
    string s;
    s = "Hello Everybody\n";
    y = malloc(32);
    y = "hello\n";
    ret = test(y);
    ret = test(s);
    ret = sum(y, 5, 10);
    putint(ret);
}

int test(string s) {
    puts(s);
    return 1;
}

int sum(string s, int size, int t) {
    int z;
    puts(s);
    putint(size);
    puts("\n");
    putint(t);
    puts("\n");
    z = size + t;
    return z;
}
