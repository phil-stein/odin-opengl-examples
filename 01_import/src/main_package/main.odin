package main

import "core:fmt"

import other "../other_package"

main :: proc() {
	program := "+ + * ^ - /"
	accumulator := 0

	for token in program {
		switch token {
		case '+': accumulator += 1
		case '-': accumulator -= 1
		case '*': accumulator *= 2
		case '/': accumulator /= 2
		case '^': accumulator *= accumulator
		case: // Ignore everything else
		}
	}

	fmt.printf("The program \"%s\" calculates the value %d\n",
	           program, accumulator)

  my_func();
  other.other_func();
}
