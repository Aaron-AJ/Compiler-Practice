int f();
int f2();

void main() {
    int x;
    x = f() + f2();
    putint(x);
}

int f() {
    return 20;
}

int f2() {
    return 15;
}
