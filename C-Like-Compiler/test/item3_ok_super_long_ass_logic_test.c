int a;
int b;
int x;
int y;
int z;
void main() {
a = 0;
y = !a;
putint(y);
puts("\n");	// 1

a = 5;
y = !a;
putint(y);
puts("\n");	// 0

putint(0 || 0); puts("\n");	// 0
putint(0 || 7); puts("\n");	// 1
putint(-3 || 0); puts("\n");	// 1

putint(0 && 1); puts("\n");	// 0
putint(5 && 2); puts("\n");	// 1
putint(5 && 0); puts("\n");	// 0

putint(0 || 0 && 1); puts("\n");	// 0   (&& binds tighter than ||)
putint(1 || 0 && 0); puts("\n");	// 1
putint((0 || 0) && 1); puts("\n");	// 0
putint((1 || 0) && 1); puts("\n");	// 1

putint(!0 == 1); puts("\n");	// 1   (! binds tighter than ==)
putint(!1 == 0); puts("\n");	// 1
putint(!2 == 0); puts("\n");	// 1
putint(!(2 == 0)); puts("\n");	// 1

putint((1 | 0) && 0); puts("\n");	// 0   (bitwise | binds tighter than &&)
putint(1 | (0 && 0)); puts("\n");	// 1

putint(!!0); puts("\n");	// 0
putint(!!5); puts("\n");	// 1

putint((5 && 2) == 1); puts("\n");	// 1   (normalised to 0/1)
putint((0 || 0) == 0); puts("\n");	// 1

}
