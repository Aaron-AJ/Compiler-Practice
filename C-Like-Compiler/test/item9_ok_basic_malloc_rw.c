// declare array, malloc N*sizeof(int), write & read two elements.
int a[];
int i;
void main() {
    a = malloc(sizeof(int) * 4);	// 4 ints
    i = 0;
    a[i] = 10;
    i = 1;
    a[i] = 20;
    putint(a[0]);	// 10
    putint(a[1]);	// 20
    exit();
}
