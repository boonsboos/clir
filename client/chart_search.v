module client

import os
import crypto.md5

const root = settings.clon_folder

fn song_info_for_hash(hash string) {

	mut subfolders := []string{}

	if !clir_client.found_chart { 
		for i in os.ls(root) or { [''] } {

			if os.is_dir(root+i) {
				subfolders << '$root$i/'
				continue
			}

			if i == 'notes.chart' || i == 'notes.mid' {
				found_hash := md5.hexhash(os.read_file('$root/$i/') or { '' } )
				if found_hash == hash {
					parse_song_ini(i)
				}
			}	

		}
	}

	if !clir_client.found_chart {
		for i in subfolders {
			recurse_deeper(i, hash)
		}
	}

	println('chart not found')
	clir_client.found_chart = false

}

fn recurse_deeper(folder string, hash string) {
	
	mut subfolders := []string{}

	if !clir_client.found_chart {
		for i in os.ls('$folder') or { ['no'] } {

			if os.is_dir(folder+i) {
				subfolders << '$folder$i/'
				continue
			}

			if i == 'notes.chart' || i == 'notes.mid' {
				found_hash := md5.hexhash(os.read_file('$folder$i') or { '' } )
				if found_hash == hash {
					println('hash matches, parsing ini')
					parse_song_ini(folder)
				}
			}

		}
	}

	if !clir_client.found_chart {
		for i in subfolders {
			recurse_deeper(i, hash)
		}
	}

}

fn parse_song_ini(folder string) {
	println('success')
	clir_client.found_chart = true
	clir_client.recent_chart = Chart{'joe', 'mama', 'pizzeria'}
}