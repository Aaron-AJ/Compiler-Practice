// complex index expression 2*i+1.
int a[];
int i;
void main() {
    a = malloc(sizeof(int) * 8);
    i = 2;
    a[2 * i + 1] = 7;	// writes a[5]
    putint(a[5]);	// 7
    exit();
}
