int a;
int b;
int r1;
int r2;
void main() {
  a = 2;
  b = 3;
  r1 = a + b * 4;	// 2 + (3*4) = 14
  r2 = (a + b) * 4;	// (2+3)*4 = 20
  putint(r1);	// expect: 14
  putint(r2);	// expect: 20
}
