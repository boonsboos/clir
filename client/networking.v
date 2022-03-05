module client

import net

fn send(clir Clir) {

	mut conn := net.dial_tcp('$settings.remote:$settings.port') or { panic('failed to start score transfer') }

	conn.set_blocking(true) or { panic('not able to set blocking')}

	clir_pack := Packet{
		key : settings.auth_key
		clir: clir
	}
	conn.write(encode_clir_send(clir_pack)) or { panic('failed to send') }

	conn.close() or { panic('failed to end transmission') }
}