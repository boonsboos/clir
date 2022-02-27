module main

import client
import util

fn main() {
	// read settings
	util.read_config()
	util.handle_args()

	client.run()
}
