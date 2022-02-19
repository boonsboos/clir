FLAGS := -skip-unused -enable-globals

test-win:
	v $(FLAGS) .

build-win:
	v -prod $(FLAGS) .
