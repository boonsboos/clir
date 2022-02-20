module util

import os

__global settings Settings

fn init() {
	settings = handle_args()
}

pub struct Settings {
pub mut:
	server_mode bool
	port        int
	remote      string
	clon_folder	string
}

fn handle_args() Settings {
	mut s := Settings{}

	if os.args.len > 1 {
		for i in os.args[1..os.args.len] {
			parse_arg(i, mut s)
		}
	}

	return Settings{
		server_mode: false // run as client by default
		port	   : 43253
		remote     : '127.0.0.1' 
		clon_folder: 'd:/things/clonehero-win64/songs/'
		// TODO: point to default clir server instead of localhost
	}
}

fn parse_arg(argument string, mut s Settings) {

	short_arg := argument.trim_string_left('-').all_before('=')

	mut value := ''

	if argument.contains('=') {
		value = argument.all_after_last('=')
	}

	match short_arg {
		'h' { help() }
		's' { s.server_mode = true }
		'p' {
			if value.int() > 0 && value.int() <= 65535 {
				s.port = value.int()
			} else {
				no_value_found('-p', 'int')
			}
		}
		'r' {
			if value != '' {
				// verify the remote actually exists by pinging with handshake
				s.remote = value
				// else error
			} else {
				no_value_found('-r', 'string')
			}
		}
		'f' {
			if value != '' { s.clon_folder = value }
			else { no_value_found('-f', 'string') }
		}
		else {  
			// the long form args
			match short_arg.trim_left('-') {
				'help' { help() }
				'server' { s.server_mode = true }
				'port' {
					if value.int() > 0 && value.int() <= 65535 {
						s.port = value.int()
					} else {
						no_value_found('--port', 'int')
					}
				}
				'folder' {
					if value != '' { s.clon_folder = value }
					else { no_value_found('--folder', 'string') }
				}

				else { unknown_option(argument) }
			}
		}
	}
}

fn no_value_found(option string, v_type string) {
	println('no value was found where one was required')
	println('option: $option | value type: $v_type')
}

fn unknown_option(a string) {
	println('unknown option: $a')
}

fn help() {
	println('everything about clir can be found on the wiki')
	println('https://github.com/mrsherobrine/clir/wiki')
}