package client

import (
	"clir/util"
	"crypto/md5"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"sync"
)

const recursion_limit = 20000

var recursion_counter = 0

type Chart struct {
	Artist  string
	Name    string
	Charter string
}

func SongInfoForHash(hash string) {

	root := util.Settings.ClonFolder

	clir_client.FoundChart = false
	clir_client.RecentChart = Chart{}
	subfolders := []string{}

	if clir_client.FoundChart == false {
		dir, _ := ioutil.ReadDir(root)
		for i := range dir {

			fmt.Println(dir[i].Name())

			if is_dir(root + dir[i].Name()) {
				subfolders = append(subfolders, root+dir[i].Name()+"/")
				continue
			}

			if dir[i].Name() == "notes.chart" || dir[i].Name() == "notes.mid" {
				file, err := os.Open(root + dir[i].Name())
				if err != nil {
					panic("failed to open file for hashing")
				}

				found_hash := md5.New()
				_, err2 := io.Copy(found_hash, file)
				if err2 != nil {
					panic("dum")
				}

				if string(found_hash.Sum(nil)) == hash {
					parse_song_ini(file)
				}
			}
		}
	}

	if !clir_client.FoundChart {
		waitgroup := sync.WaitGroup{}
		for i := 0; i < len(subfolders); i++ {
			waitgroup.Add(1)
			go recurse_deeper(waitgroup, hash, subfolders[i])
		}
		waitgroup.Wait()
	}

	if clir_client.RecentChart.Artist != "" || recursion_counter == recursion_limit {
		clir_client.RecentChart = Chart{"chart", "not", "found"}
		return
	}

}

func recurse_deeper(waitgroup sync.WaitGroup, hash string, path string) {
	defer waitgroup.Done()
	recursion_counter++
	subfolders := []string{}

	if clir_client.FoundChart == false && recursion_counter < recursion_limit {
		dir, _ := ioutil.ReadDir(path)
		for i := range dir {

			fmt.Println(dir[i].Name())

			if is_dir(path + dir[i].Name()) {
				subfolders = append(subfolders, path+dir[i].Name()+"/")
				continue
			}

			if dir[i].Name() == "notes.chart" || dir[i].Name() == "notes.mid" {
				file, err := os.Open(path + dir[i].Name())
				if err != nil {
					panic("failed to open file for hashing")
				}

				found_hash := md5.New()
				_, err2 := io.Copy(found_hash, file)
				if err2 != nil {
					panic("dum")
				}

				if string(found_hash.Sum(nil)) == hash {
					parse_song_ini(file)
				}
			}
		}
	}

	if !clir_client.FoundChart && recursion_counter < recursion_limit {
		waitgroup2 := sync.WaitGroup{}
		for i := 0; i < len(subfolders); i++ {
			waitgroup2.Add(1)
			go recurse_deeper(waitgroup2, hash, path)
		}
		waitgroup2.Wait()
	}
}

func is_dir(path string) bool {
	file, err := os.Stat(path)
	if err != nil {
		panic("not a file or dir")
	}
	switch mode := file.Mode(); {
	case mode.IsDir():
		return true
	default:
		return false
	}
}

func parse_song_ini(file *os.File) {
	clir_client.FoundChart = true
}
