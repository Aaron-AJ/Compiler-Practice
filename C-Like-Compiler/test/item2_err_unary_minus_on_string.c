string s;
int x;
void main() {
  s = "nope";
  x = -s;	// expect: compile-time error (unary minus on string)
}
