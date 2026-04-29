int a[];
string s;
void main() {
    a = malloc(sizeof(int) * 4);
    s = "x";
    a[s] = 1;	// error
    exit();
}
