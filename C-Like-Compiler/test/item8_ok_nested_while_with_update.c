int outer;
int inner;
void main() {
  outer = 0;
  while (outer < 3) {
    inner = 0;
    while (inner < 1) {
      putint(outer);
      inner = inner + 1;
    }
    outer = outer + 1;
  }
}
