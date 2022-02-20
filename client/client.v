module client

import util

pub fn client() {
	// watch scores.bin
	// reparse when mtime changes
	// use smth similar to a diff
	println(util.decode_score())
}