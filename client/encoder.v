module client

import encoding.binary

[heap]
pub struct Encoder {
mut:
	data	[]byte
}

// strings are length prefixed
pub fn (mut c Encoder) encode_string(s string) {
	binary.little_endian_put_u32(mut c.data, u32(s.len))
	c.data << s.bytes()
}

pub fn (mut c Encoder) encode_byte(b byte) {
	c.data << b
}

pub fn (mut c Encoder) encode_u64(u u64) {
	binary.little_endian_put_u64(mut c.data, u)
}

pub fn (mut c Encoder) encode_u32(u u32) {
	binary.little_endian_put_u32(mut c.data, u)
}

pub fn (mut c Encoder) encode_u16(u u16) {
	binary.little_endian_put_u16(mut c.data, u)
}

pub fn (mut c Encoder) encode_bool(b bool) {
	c.encode_byte(byte(b))
}

pub fn (mut c Encoder) finish() []byte {
	mut tmp := []byte{len:4+c.data.len}
	binary.little_endian_put_u32(mut tmp, u32(c.data.len))
	tmp << c.data
	return tmp
}

fn encode_handshake() []byte {
	pack := CHandshake{}
	mut e := Encoder{}
	e.encode_byte(pack.id)
	e.encode_u64(pack.ts)
	return e.finish()
}

fn encode_c_auth_request(pack CAuthRequest) []byte {
	mut e := Encoder{}
	e.encode_byte(pack.id)
	e.encode_string(pack.key)
	return e.finish()
}

fn encode_clir_send(pack CClirSend) []byte {
	mut e := Encoder{}
	e.encode_byte(pack.id)
	// encode the key here so we can be sure it's the same player
	e.encode_string(pack.key)
	// beware for messy
	score := pack.clir.score_data
	data := pack.clir.score_data.scoredata
	e.encode_string(score.hash) // chart hash
	e.encode_byte(score.playcount) // might remove this

	e.encode_byte(data.diff) // chart difficulty
	e.encode_byte(data.percent) // accuracy
	e.encode_bool(data.fc) // is fc?
	e.encode_u16(data.speed) // speed in percentages
	e.encode_byte(data.stars) // how many stars
	e.encode_byte(data.mods) // modifiers, i only know 0x01 == no fail
	e.encode_u32(data.hiscore) // actual score

	chart := pack.clir.chart_data
	e.encode_string(chart.artist)
	e.encode_string(chart.name) // song name
	e.encode_string(chart.charter) // name of charter
	return e.finish()
}