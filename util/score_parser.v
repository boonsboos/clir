module util

import encoding.binary
import os

const (
	home_dir    = os.home_dir()
	scores_path = scores_path()
)

fn scores_path() string {
	$if macos {
		return '$home_dir/Library/Application Support/com.srylain.CloneHero/scores.bin'
	}
	$else $if windows {
		return '$home_dir/AppData/LocalLow/srylain Inc_/Clone Hero/scores.bin'
	}
	$else {
		return '$home_dir/.config/unity3d/srylain Inc_/Clone Hero/scores.bin'
	}
}

[heap]
pub struct Score {
pub:
	hash		string
	instr_amnt	byte // amount of instruments
	playcount	byte
	scoredata   ScoreData
}

[heap]
pub struct ScoreData {
pub:
	id		byte
	// after id there's a skip byte
	diff	byte
	percent byte
	fc		bool
	speed   u16
	stars   byte 
	mods    byte // bitmask
	hiscore u32
}

[heap]
struct ScoreDecoder {
mut:
	data	[]byte
	idx		int
}

pub fn decode_score() Score {
	mut decoder := ScoreDecoder{
		data: os.read_bytes(scores_path) or { panic('can\'t access your scores') }
	}

	decoder.skip(8) // skip version bytes at beginning of file

	decoder.skip(1) // skip block begin
	
	hash := decoder.read_string()
	instr_amnt := decoder.read_byte()
	playcount := decoder.read_byte()

	decoder.skip(2)

	id := decoder.read_byte()

	decoder.skip(1)

	difficulty := decoder.read_byte()
	percentage := decoder.read_byte()
	fc := byte_bool(decoder.read_byte())
	speed := decoder.read_u16()
	stars := decoder.read_byte()
	mods := decoder.read_byte()

	hiscore := decoder.read_uint()

	data := ScoreData {
		id, difficulty, percentage, fc, speed, stars, mods, hiscore
	}

	score := Score {
		hash, instr_amnt, playcount, data
	}

	dump(score)

	return score
}

fn (mut s ScoreDecoder) read_byte() byte {
	s.idx++
	return s.data[s.idx-1]
}

fn (mut s ScoreDecoder) read_uint() u32 {
	s.idx += 4
	return binary.little_endian_u32(s.data[s.idx-4..s.idx])
}

fn (mut s ScoreDecoder) read_string() string {
	// technically, since this'll only be used for the hash
	// we can assume there'll always be 32 characters
	s.idx += 32
	return s.data[s.idx-32..s.idx].bytestr()
}

fn (mut s ScoreDecoder) read_u16() u16 {
	s.idx += 2
	return binary.little_endian_u16(s.data[s.idx-2..s.idx])
}

fn (mut s ScoreDecoder) skip(a int) {
	s.idx += a
}

[inline]
fn byte_bool(i byte) bool {
	if i == 0 { return false } 
	return true
}