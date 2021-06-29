#include <stdio.h>

void print(void) {
        printf("num is bigger than 0\n");
}

int main(void) {
    int num = 15;
    if (num > 0) {
        print();
    }
    else if (num > 5) {
        printf("num is bigger than 5\n");
    }
    else if (num > 10) {
        printf("num is bigger than 10\n");
    }
    else if (num > 15) {
        printf("num is bigger than 15\n");
    }
    else {
        printf("num is bigger than 18\n");
    }
    return 0;
}
