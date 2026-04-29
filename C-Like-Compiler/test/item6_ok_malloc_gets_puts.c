string buf;
int bytes;
void main() {
  buf = malloc(32);       // EXPR_REF -> assign to string OK
  bytes = gets(buf, 31);  // returns bytes read in $v0; parser treats GETS as expr -> int
  putint(bytes);
  puts(buf);
}
