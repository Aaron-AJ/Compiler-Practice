int print(int x[], int current, int size);
int x[];

void main() {
    int y;
    int i;
    i = 0;
    x = malloc(sizeof(int) * 5);
    while(i < 5) {
        x[i] = i;
        i = i + 1;
    }
    y = print(x, 0, 5);
}

int print(int a[], int current, int size) {
    if(current >= size) {
        return 1;
    }
    puts("Array at index ");
    putint(current);
    puts("\n");

    puts("  ");
    putint(a[current]);
    puts("\n");
    return print(a, current + 1, size);
}
