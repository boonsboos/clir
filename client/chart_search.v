module client

import os
import crypto.md5

__global found_chart bool

const root = settings.clon_folder

fn song_info_for_hash(hash string) {

	mut subfolders := []string{}

	if !found_chart { 
		for i in os.ls(root) or { [''] } {

			if os.is_dir(root+i) {
				subfolders << '$root$i/'
				continue
			}

			if i.all_before('.') == 'notes' {
				found_hash := md5.hexhash(os.read_file('$root/$i/') or { '' } )
				if found_hash == hash {
					parse_song_ini(i)
				}
			}	

		}
	}

	if !found_chart {
		for i in subfolders {
			recurse_deeper(i, hash)
		}
	}

	println('found: $found_chart')

}

fn recurse_deeper(folder string, hash string) {
	
	mut subfolders := []string{}

	if !found_chart {
		for i in os.ls('$folder') or { ['no'] } {

			if os.is_dir(folder+i) {
				subfolders << '$folder$i/'
				continue
			}

			if i == 'notes.mid' || i == 'notes.chart' {
				found_hash := md5.hexhash(os.read_file('$folder$i') or { '' } )
				if found_hash == hash {
					println('hash matches, parsing ini')
					parse_song_ini(folder)
				}
			}

		}
	}

	if !found_chart {
		for i in subfolders {
			recurse_deeper(i, hash)
		}
	}

}

fn parse_song_ini(folder string) {
	println('success')
	found_chart = true
	client_obj.recent_chart = Chart{'joe', 'mama', 'pizzeria'}
}