FLAGS := -skip-unused -enable-globals
# skip-unused omits functions that we do not use
# enable-globals enables global variables

test-win:
	v $(FLAGS) .

build-win:
	v -cc gcc -prod $(FLAGS) .

test-linux:
	v $(FLAGS) -compress .

build-linux:
	v -prod $(FLAGS) -compress .