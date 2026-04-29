// aliasing
int a1[];
int a2[];
void main() {
    a1 = malloc(sizeof(int) * 8);
    a2 = a1;	// reference copy
    a1[3] = 42;
    putint(a2[3]);	// 42
    exit();
}
