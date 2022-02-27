package main

import (
	"clir/util"
	"fmt"
)

func main() {
	util.ReadConfig()

	fmt.Println(util.Settings)
}
