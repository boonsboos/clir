package main

import (
	"clir/client"
	"clir/util"
	"fmt"
)

func main() {
	util.ReadConfig()

	fmt.Println(util.Settings)

	client.Run()
}
