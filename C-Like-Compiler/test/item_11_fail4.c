void main() {
    int f(string s); //cannot declare here
    int x;
    x = f(10);
}

int f(string s) {
    return 1;
}
