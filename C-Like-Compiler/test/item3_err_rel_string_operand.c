void main() {
   int n;
   string msg;
   n = 5;
   msg = "hello";

   int bad = (msg < n); // compile-time type error (strings not allowed in relations)
   putint(bad); puts("\n");
}
