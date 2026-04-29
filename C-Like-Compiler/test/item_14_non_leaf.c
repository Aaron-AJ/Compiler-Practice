int f1(int a);
int f2(int a);
int f3(int a, string s);

void main() {
    int x;
    x = f2(75);
    putint(x);
}

int f2(int a) {
    string s;
    s = "In Function f2\n";
    puts(s);
    return f1(a);
}

int f1(int a) {
    string s;
    s = "In Function f1\n";
    puts(s);
    s = "In Function f3\n";
    return f3(a, s);
}

int f3(int a, string s) {
    int z;
    z = 10;
    puts(s);
    s = "Argument Value\n";
    puts(s); //
    putint(a);
    puts("\n");
    return z + 5;
}
