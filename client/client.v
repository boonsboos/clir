module client

import util

__global client_obj Client

fn init() {
	client_obj = Client{}
}

pub struct Client {
pub mut:
	scores		 map[string]util.Score
	recent_chart Chart
	// login details? identification key?
}

struct Chart {
mut:
	artist  string
	name    string
	charter string
}

pub fn client() {
	// watch scores.bin
	// reparse when mtime changes
	// use smth similar to a diff
	map_scores()

	println('$client_obj.scores.len scores')
	// space oddity
	song := go song_info_for_hash('B164D095681DE51A5F9E341906DCF602'.to_lower())

	song.wait()
	println(client_obj.recent_chart)
}

fn map_scores() {
	for i in util.decode_scores() {
		client_obj.scores[i.hash] = i
	}
}