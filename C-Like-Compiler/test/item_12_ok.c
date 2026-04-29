int z;
int f1();
int y;
int f2();

void main() {
    z = f1() + f2();
    y = f2();
    putint(z); //20
    puts("\n");
    putint(y); //8
}

int f1() {
    int z;
    int y;
    z = 144;
    y = 12;
    return z / 12;
}

int f2() {
    int z;
    int y;
    z = 2;
    y = 4;
    return z * y;
}
