module util

import os
import toml

__global settings Settings

fn init() {
	settings = Settings{}
}

const settings_path = os.executable().replace('\\','/').all_before_last('/')+'/settings.toml'

pub struct Settings {
pub mut:
	port        int
	remote      string
	clon_folder	string
	auth_key    string
}

pub fn read_config() {

	if !os.exists(settings_path) {
		mut file := os.create(settings_path) or { panic(err) }
		// yes, this indenting is strange but i'm too lazy
		file.write_string('
port=43254
remote="127.0.0.1"
songs_folder=""
auth_key="blub"') or { panic('could not write to settings file') }
	}

	file := toml.parse(settings_path) or { panic('you messed up your settings file') }

	port := file.value('port').int()
	remote := file.value('remote').string()
	auth_key := file.value('auth_key').string()
	mut folder := file.value('songs_folder').string()//.replace('\\', '/')
	
	if port <= 1024 || port >= 65536 {
		panic('bad port!')
	}
	settings.port = port

	// TODO: check if remote exists/is reachable
	// TODO: remove this option, there should only be ONE
	// central clir server
	settings.remote = remote

	if folder[folder.len-1] == 0x4f { 
		folder = folder[0..folder.len]
	} // trailing slash handling
	if !os.exists(folder) && !os.is_dir(folder) {
		panic('bad songs folder path')
	} else { 
		settings.clon_folder = folder
	}

	settings.auth_key = auth_key
} 

pub fn handle_args() {

	if os.args.len > 1 {
		for i in os.args[1..os.args.len] {
			parse_arg(i)
		}
	}
}

fn parse_arg(argument string) {

	short_arg := argument.trim_string_left('-').all_before('=')

	mut value := ''

	if argument.contains('=') {
		value = argument.all_after_last('=')
	}

	match short_arg {
		'h' { help() }
		'p' {
			if value.int() > 0 && value.int() <= 65535 {
				settings.port = value.int()
			} else {
				no_value_found('-p', 'int')
			}
		}
		'r' {
			if value != '' {
				// verify the remote actually exists by pinging with handshake
				settings.remote = value
				// else error
			} else {
				no_value_found('-r', 'string')
			}
		}
		'f' {
			if value != '' { 
				if os.exists(value) && os.is_dir(value) {
					settings.clon_folder = value
				}
			} else { no_value_found('--folder', 'string') }
		}
		else {  
			// the long form args
			match short_arg.trim_left('-') {
				'help' { help() }
				'port' {
					if value.int() > 0 && value.int() <= 65535 {
						settings.port = value.int()
					} else {
						no_value_found('--port', 'int')
					}
				}
				'remote' {
					if value != '' {
						settings.remote = value
					} else {
						no_value_found('--remote', 'string')
					}
				}
				'folder' {
					if value != '' { 
						if os.exists(value) && os.is_dir(value) {
							settings.clon_folder = value
						}
					} else { no_value_found('--folder', 'string') }
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