#include <stdio.h>
#include <unistd.h> /* for usleep */

void foo() {
  static unsigned int counter = 0;
  counter++;
  if(counter % 24) {
    counter += 1234;
  } else if (counter) {
    counter = counter + 45 / counter;
  } else {
    counter++;
  }
}

void infinite_function() {
  printf("infinite\n");
  while (1) {
    foo();
    //In case you want to test shared libraries:
    //usleep(1);
  }
}


void two() {
  printf("two\n");
  infinite_function();
}

void one() {
  printf("one\n");
  two();
}

int main(int argc, char* argv[]) {
  printf("main\n");
  one();

return 0;
}
