int x;
string z;

void main() {
    int y;
    string dynamic;
    int total_read;
    x = 10;
    y = 15;
    z = "\n";
    dynamic = malloc(32);
    total_read = gets(dynamic, 32);
    puts("Read: ");
    putint(total_read);
    puts(" Bytes from stdin.\n Starting Loop. Type number greater than 25 to end\n");
    do {
        int user_input;
        user_input = getint();
        if(user_input > (x + y)) {
            exit();
        }
    } while(1);
}
