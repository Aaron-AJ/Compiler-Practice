int a;
int b;
void main() {
  a = 1;
  b = 0;
  if (a) {
    if (b) {
      puts("both true");
    } else {
      puts("a true, b false");
    }
  } else {
    puts("a false");
  }
}
