module client

import os
import time

__global clir_client Client

fn init() {
	clir_client = Client{}
}

[heap]
pub struct Client {
pub mut:
	busy         bool
	scores		 map[string]Score
	recent_chart Chart
	recent_score Clir
	score_mtime  i64
	found_chart  bool
	// login details? identification key?
}

pub struct Clir {
pub:
	score_data	Score
	chart_data  Chart
}

pub fn run() {
	
	map_scores_to_client()
	clir_client.score_mtime = os.file_last_mod_unix(scores_path)

	song_info_for_hash('a')
	song_info_for_hash('b')
	// watch scores.bin
	// reparse when mtime changes
	for {
		if os.file_last_mod_unix(scores_path) != clir_client.score_mtime && !clir_client.busy {
			clir_client.score_mtime = os.file_last_mod_unix(scores_path)
			compare_map() 
		}
		time.sleep(time.second)
	}
}

// compare current scores to updated scores
fn compare_map() {
	for i in decode_scores() {
		if i != clir_client.scores[i.hash] {
			clir_client.busy = true
			song_info_for_hash(i.hash.to_lower())

			clir_client.recent_score = Clir{i, clir_client.recent_chart}

			println(clir_client.recent_score)
			// send the score to the server
			send(clir_client.recent_score)
			map_scores_to_client()
			clir_client.busy = false
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