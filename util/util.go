package util

import (
	"bufio"
	"os"
	"strconv"
	"strings"
)

var Settings SettingsContainer

type SettingsContainer struct {
	Port       int
	Remote     string
	ClonFolder string
	AuthKey    string
}

func ReadConfig() {

	file, err := os.Open("./Settings.toml")

	if err != nil {
		nfile, err := os.Create("./Settings.toml")
		if err != nil {
			panic("could not create settings file")
		}

		nfile.WriteString(`port=43254
remote="127.0.0.1"
songs_folder=""
auth_key="blub"`)

		nfile.Close()
		file, err = os.Open("./Settings.toml")
		if err != nil {
			panic("HOW")
		}
	}

	reader := bufio.NewReader(file)
	por, _, _ := reader.ReadLine()
	port, _ := strconv.Atoi(strings.Split(string(por), "=")[1])

	if port <= 1024 || port >= 65536 {
		panic("bad port!")
	}

	rem, _, _ := reader.ReadLine()
	remote := strings.Split(string(rem), "=")[1]

	fol, _, _ := reader.ReadLine()
	folder := strings.Split(string(fol), "=")[1]
	rep := strings.NewReplacer("\"", "")
	folder = rep.Replace(folder)
	// if folder[len(folder)-1] == 0x2f {
	// 	folder = folder[0 : len(folder)-2]
	// }

	key, _, _ := reader.ReadLine()
	auth_key := strings.Split(string(key), "=")[1]

	subs, _ := os.ReadDir(folder)
	if len(subs) == 0 {
		panic("not a valid clon songs folder, sorry")
	}

	if !strings.HasSuffix(folder, "/") {
		folder += "/"
	}

	Settings.AuthKey = auth_key
	Settings.ClonFolder = folder
	Settings.Port = port
	Settings.Remote = remote

}
