int a;
int b;
void main() {
   a = getint();
   b = 3;
   putint(a + b);

   if (a && b) {	// logical on ints only
     putint(1);
   }
 }
