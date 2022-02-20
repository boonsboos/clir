module client

import os
import crypto.md5

struct Chart {
	artist  string
	name    string
	charter string
}

const root = settings.clon_folder

fn song_info_for_hash(hash string) ?Chart {

	songs := os.ls(root) or { ['no files'] }

	mut subfolders := []string{}

	println(songs)

	for i in 0..songs.len {

		if os.is_dir(root+songs[i]) {
			subfolders << root+songs[i]
		}

		if songs[i].all_before('.') == 'notes' {
			found_hash := md5.hexhash(os.read_file(root+songs[i]) or { '' } )
			if found_hash == hash {
				
			}
		}

	}

	println(subfolders)

	return Chart{}
}

fn parse_song_ini(folder string) Chart {
	// find song.ini
	// read line 1, 2, 4
}