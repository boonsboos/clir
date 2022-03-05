module client

import os
import crypto.md5

struct Chart {
mut:
	artist  string
	name    string
	charter string
}

const search_limit = 20000
__global search_counter int

fn song_info_for_hash(hash string) {

	root := settings.clon_folder
	clir_client.found_chart = false
	clir_client.recent_chart = Chart{}
	mut subfolders := []string{}

	search_counter = 0

	if clir_client.found_chart == false {
		for i in os.ls(root) or { [''] } {
			if os.is_dir(root+'/'+i) {
				subfolders << '$root/$i/'
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

	if !clir_client.found_chart && search_counter < search_limit {
		mut threads := []thread{len: subfolders.len} 
		for i in subfolders {
			threads << go recurse_deeper(i, hash)
		}
		threads.wait()
	}

	if clir_client.recent_chart == Chart{} {
		clir_client.recent_chart = Chart {
			'chart'
			'not'
			'found'
		}
		return
	}

}

fn recurse_deeper(folder string, hash string) {
	
	mut subfolders := []string{}

	search_counter++

	if clir_client.found_chart == false && search_counter < search_limit {
		for i in os.ls(folder) or { [''] } {
			if os.is_dir(folder+i) {
				subfolders << '$folder$i/'
				continue
			}

			if i == 'notes.chart' || i == 'notes.mid' {
				found_hash := md5.hexhash(os.read_file('$folder$i') or { '' } )
				if found_hash == hash {
					parse_song_ini('${folder}song.ini')
				}
			}

		}
	}

	if !clir_client.found_chart && search_counter < search_limit {
		mut threads := []thread{len: subfolders.len} 
		for i in subfolders {
			threads << go recurse_deeper(i, hash)
		}
		threads.wait()
	}

}

fn parse_song_ini(song string) {
	clir_client.found_chart = true
	mut chart := Chart{} 
	ini := os.read_lines(song) or { panic('you got something funny going on with the') }
	for i in ini {
		value := i.all_after('=').trim_space()
		if i.starts_with('name')            { chart.name = value }
		else if i.starts_with('artist')   { chart.artist = value }
		else if i.starts_with('charter') { chart.charter = remove_html_tags(value) }
	}

	clir_client.recent_chart = chart
}

fn remove_html_tags(s string) string {
	mut res := s
    for res.contains_any('</>') {
        open := res.index('<') or { 0 }
        close := res.index('>') or { 0 }
        substr := res.substr(open, close)
        res.replace(substr, '')
    }
    return res
}