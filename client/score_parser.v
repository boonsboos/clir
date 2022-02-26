module client

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

// MOST OF THIS WAS INDIRECTLY COPIED FROM github.com/gardockt/ch-merger
// THANKS FOR YOUR REVERSE ENGINEER
// YOU'VE SAVED ME A LOT OF TIME

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

pub fn decode_scores() []Score {
	mut decoder := ScoreDecoder{
		data: os.read_bytes(scores_path) or { panic('can\'t access your scores') }
	}

	decoder.skip(8) // skip version bytes at beginning of file

	mut scores := []Score{}

	for !decoder.is_eof() {
		if decoder.read_byte() != 0x20 {
			panic('malformed scores.bin!')
		} // block beginning
		
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
		scores << score
	}

	return scores
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
	return s.data[s.idx-32..s.idx].bytestr().to_lower()
}

fn (mut s ScoreDecoder) read_u16() u16 {
	s.idx += 2
	return binary.little_endian_u16(s.data[s.idx-2..s.idx])
}

fn (mut s ScoreDecoder) skip(a int) {
	s.idx += a
}

fn (mut s ScoreDecoder) is_eof() bool {
	println('idx: $s.idx | data len: $s.data.len')
	return s.idx >= s.data.len
}

fn byte_bool(i byte) bool {
	return i == 1
}