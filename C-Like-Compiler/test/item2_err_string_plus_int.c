int x;
string s;
void main() {
  x = 1;
  s = "hi";
  x = x + s;	// expect: compile-time error (string in arithmetic)
}
