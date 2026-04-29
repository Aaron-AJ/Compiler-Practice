int n;
void main() {
  n = 4;
  while (malloc(n)) {   // yeilds a reference not an int so no go
    puts("should not compile");
  }
}

