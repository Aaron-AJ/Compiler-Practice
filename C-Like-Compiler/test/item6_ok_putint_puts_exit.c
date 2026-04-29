int n;
string msg;
void main() {
  n = 15;
  msg = "have a nice day";
  putint(n);      // 15
  puts(msg);      // "have a nice day"
  exit();         // program exits here
  n = 99;         // never reached
}
