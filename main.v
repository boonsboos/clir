module main

import client

fn main() {
	if settings.server_mode {
		// server()
		println('server')
	} else {
		client.client()
	}
}
