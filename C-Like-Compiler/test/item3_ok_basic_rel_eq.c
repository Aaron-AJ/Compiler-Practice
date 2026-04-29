void main() {
    int x;
    int y;
    int z;
    x = 3;
    y = 5;
    z = 5;

    putint(x < y);	//1
    puts("\n");
    putint(y <= z);	//1
    puts("\n");
    putint(z > x);	//1
    puts("\n");
    putint(z >= y);	//1
    puts("\n");
    putint(x == y);	//0
    puts("\n");
    putint(y != z);	//0
    puts("\n");
}
