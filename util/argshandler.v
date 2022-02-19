module util

import os

__global settings Settings

fn init() {
	settings = parse_args()
}

pub struct Settings {
pub mut:
	server_mode    bool
	port           int
	remote         string 
}

pub fn parse_args() Settings {

	mut s := Settings{}

	if os.args.len > 1 {
		for i in os.args {
			parse_arg(i, mut s)
		}
	}
	
	return Settings{
		server_mode: false // run as client by default
	}

}

fn parse_arg(argument string, mut s Settings) {

	short_arg := argument.replace('-', '').all_before('=')
	
	mut value := ''

	if argument.contains('=') {
		value = argument.all_after_last('=')
	}

	match short_arg {
		's' {
			s.server_mode == true
		}
		'p' {
			if value.int() > 0 && value.int() < 65536 {
				s.port = value.int()
			} else {
				no_value_found('-p', 'int')
			}
		}
		else {}
	}

}

fn no_value_found(option string, v_type string) {
	println('no value was found where one was required')
	println('option: $option | value type: $v_type')
}