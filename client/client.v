module client

import os

__global clir_client Client

fn init() {
	clir_client = Client{}
}

pub struct Client {
pub mut:
	scores		 map[string]Score
	recent_chart Chart
	score_mtime  i64
	found_chart  bool
	// login details? identification key?
}

struct Chart {
mut:
	artist  string
	name    string
	charter string
}

pub fn run() {
	// watch scores.bin
	// reparse when mtime changes
	map_scores_to_client()
	clir_client.score_mtime = os.file_last_mod_unix(scores_path)

	for {
		if os.file_last_mod_unix(scores_path) != clir_client.score_mtime {
			clir_client.score_mtime = os.file_last_mod_unix(scores_path)
			compare_map()

		}
	}
}

fn compare_map() {
	for i in decode_scores() {
		if i != clir_client.scores[i.hash] {
			println(i)
			song_info_for_hash(i.hash.to_lower())
			println(clir_client.recent_chart)
			// send the score to the server
			map_scores_to_client()
			break
		}
	}
}

fn map_scores() map[string]Score {
	mut tmp := map[string]Score{}
	for i in decode_scores() {
		tmp[i.hash] = i
	}
	return tmp
}

[inline]
fn map_scores_to_client() {
	clir_client.scores = map_scores()
}