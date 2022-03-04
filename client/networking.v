module client

import net

fn send(clir Clir) {

	mut conn := net.dial_tcp('$settings.remote:$settings.port') or { panic('failed to start score transfer') }
	mut read_buf := []byte{len:1024} 

	conn.set_blocking(true) or { panic('not able to set blocking')}

	handshake := CHandshake{} // for verifying correct handshake later on
	conn.write(encode_handshake(handshake)) or { panic('failed to send handshake') }

	shake_len := conn.read(mut read_buf) or { panic('connection closed early') }
	s_shake := decode_packet(read_buf)
	println('handshake reply: ${read_buf[0..shake_len]}')
	// read_buf.clear()

	if s_shake is SHandshake{
		println('received handshake reply')
		if handshake.ts != s_shake.ts { 
			conn.close() or { panic('no closing') }
		}
	}

	auth := CAuthRequest{
		key: settings.auth_key
	}
	println('writing auth')
	conn.write(encode_auth_request(auth)) or { fuck_() }

	auth_len := conn.read(mut read_buf) or { fuck_() }
	auth_reply := decode_packet(read_buf)
	println('auth reply: ${read_buf[0..auth_len]}')
	// read_buf.clear()

	if auth_reply is SInvalid {
		conn.close() or { panic('bad auth key') }
	}

	clir_pack := CClirSend{
		key : settings.auth_key
		clir: clir
	}
	conn.write(encode_clir_send(clir_pack)) or { fuck_() }

	conn.close() or { panic('failed to end transmission') }
}

[noreturn]
fn fuck_() {

}