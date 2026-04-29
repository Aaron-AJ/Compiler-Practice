int f1();

void main() {
    int i;
    int z[];
    z = malloc(sizeof(int) * 20);
    puts("Intializing Array\n");
    do {
        z[i] = f1();
        i = i + 1;
    } while(i < 20);
    puts("Im looping it\n");
    i = 0;
    do {
        int j;
        j = 0;
        do {
            z[i] = z[i] + z[i];
            j = j+ 1;
        } while (j < 5);
        i = i + 1;
    } while(i < 20);
    i = 0;
    puts("Printing Array\n");
    while(i < 20) {
        putint(z[i]);
        puts("\n");
        i = i + 1;
    }
}

int f1() {
    int x;
    int y;
    x = 0;
    y = 1;
    return x + y;
}
