module client

import encoding.binary

pub struct Decoder {
mut:
	data []byte
	idx  int = 4
	len  int 
}

pub fn new_decoder(dat []byte) Decoder {
	return Decoder{
		data: dat
		//idx : 4 // account for offset
		len : int(binary.little_endian_u32(dat[0..4]))
	}
}

pub fn (mut d Decoder) decode_string() string {
	str_len := int(d.decode_u32())
	if d.not_eof() && d.offset_eof(str_len) {
		d.idx += str_len
	} else {
		panic('mangled string')
	}
	return d.data[d.idx-str_len..d.idx].bytestr()
}

pub fn (mut d Decoder) decode_u64() u64 {
	if d.not_eof() && d.offset_eof(8) {
		d.idx += 8
	} else {
		panic('mangled u64')
	}
	return binary.little_endian_u64(d.data[d.idx-8..d.idx])
}

pub fn (mut d Decoder) decode_u32() u32 {
	if d.not_eof() && d.offset_eof(4) {
		d.idx += 4
	} else {
		panic('mangled u32')
	}
	return binary.little_endian_u32(d.data[d.idx-4..d.idx])
}

pub fn (mut d Decoder) decode_u16() u16 {
	if d.not_eof() && d.offset_eof(2) {
		d.idx += 2
	} else {
		panic('mangled short')
	}
	return binary.little_endian_u16(d.data[d.idx-2..d.idx])
}

pub fn (mut d Decoder) decode_byte() byte {
	if d.not_eof() && d.offset_eof(1) {
		d.idx++
	} else {
		panic('mangled byte')
	}
	return d.data[d.idx-1]
}

pub fn (mut d Decoder) decode_bool() bool {
	return d.decode_byte() == 1
}

[inline]
pub fn (mut d Decoder) not_eof() bool {
	return d.len >= d.idx-4
}

[inline]
pub fn (mut d Decoder) offset_eof(offset int) bool {
	return d.len >= d.idx-4 + offset
}

// should be delegated to packet handling function
pub fn decode_packet(packet []byte) Packet {
	
	mut d := new_decoder(packet)

	match d.decode_byte() {
		1 {
			return SHandshake { ts: d.decode_u64() }
		}
		3 {
			return SInvalid{}
		}
		4 {
			return SClirRequest{}
		}
		else { 
			return SInvalid{} // signals to terminate connection anyway
		}
	}

}