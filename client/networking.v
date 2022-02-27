module client

import net

fn send(clir Clir) {

	mut conn := net.dial_tcp('$settings.remote:$settings.port') or { panic('failed to start score transfer') }
	mut read_buf := []byte{len:1024} 

	conn.set_blocking(true) or { panic('not able to set blocking')}

	handshake := CHandshake{} // for verifying correct handshake later on
	conn.write(encode_handshake(handshake)) or { panic('failed to send handshake') }

	buf_len := conn.read(mut read_buf) or { panic('connection closed early') }
	println(read_buf[0..buf_len])
	s_shake := decode_packet(read_buf)
	read_buf.clear()

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
	conn.write(encode_auth_request(auth)) or { panic('failed to send auth') }

	conn.read(mut read_buf) or { panic('failed to read 2') }
	auth_reply := decode_packet(read_buf)
	println(read_buf[0..buf_len])
	read_buf.clear()

	if auth_reply is SInvalid {
		conn.close() or { panic('bad auth key') }
	}

	clir_pack := CClirSend{
		key : settings.auth_key
		clir: clir
	}
	conn.write(encode_clir_send(clir_pack)) or { panic('failed to send clir') }

	conn.close() or { panic('failed to end transmission') }
}