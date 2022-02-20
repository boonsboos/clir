module client

import util

__global client Client

fn init() {
	client = Client{}
}

pub struct Client {
pub mut:
	scores	map[string]util.Score
	// login details?
}

pub fn client() {
	// watch scores.bin
	// reparse when mtime changes
	// use smth similar to a diff
	map_scores()

	println(client.scores)
	println(client.scores.len)
	// major tom to ground control
	song_info_for_hash('B164D095681DE51A5F9E341906DCF602'.to_lower()) or { }

}

fn map_scores() {
	for i in util.decode_scores() {
		client.scores[i.hash] = i
	}
}