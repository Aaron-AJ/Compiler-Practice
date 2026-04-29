int a;
int b;
int r;
void main() {
  a = 5;
  b = 1;
  r = -(a + (b - 10));	// -(5 + (1-10)) = -(-4) = 4
  putint(r);	// expect: 4
}
