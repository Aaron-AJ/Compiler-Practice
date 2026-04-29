// while condition is string (must be int)
string s;
void main() {
  s = "x";
  while (s) {        // while condition must be an integer expression
    puts("hi");
  }
}
