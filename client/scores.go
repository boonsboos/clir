package client

import (
	"encoding/binary"
	"os"
	"runtime"
	"strings"
)

const ()

func get_home_dir() string {
	dir, err := os.UserHomeDir()
	if err != nil {
		panic("Failed to get home directory")
	}
	return dir
}

func GetScoresPath() string {
	if runtime.GOOS == "windows" {
		return get_home_dir() + "/AppData/LocalLow/srylain Inc_/Clone Hero/scores.bin"
	} else if runtime.GOOS == "macos" {
		return get_home_dir() + "/Library/Application Support/com.srylain.CloneHero/scores.bin"
	} else {
		return get_home_dir() + "/.config/unity3d/srylain Inc_/Clone Hero/scores.bin"
	}
}

type Score struct {
	Hash       string
	Playcount  byte
	Difficulty byte
	Percentage byte
	Fc         bool
	Speed      uint16
	Stars      byte
	Mods       byte
	HighScore  uint32
}

func DecodeScores() []Score {
	bytes, err := os.ReadFile(GetScoresPath())
	if err != nil {
		panic("Can't access your scores")
	}

	decoder := ScoreDecoder{bytes, 0}

	decoder.skip(8) // skip file header

	scores := []Score{}

	for !decoder.is_eof() {
		if decoder.read_byte() != 0x20 {
			panic("Malformed scores file!")
		}

		hash := strings.ToLower(decoder.read_string())
		decoder.skip(1)
		playcount := decoder.read_byte()

		decoder.skip(4) // not sure what these are

		difficulty := decoder.read_byte()
		percentage := decoder.read_byte()
		fc := byte_bool(decoder.read_byte())
		speed := decoder.read_uint16()
		stars := decoder.read_byte()
		mods := decoder.read_byte()
		hiscore := decoder.read_uint()

		score := Score{hash, playcount, difficulty, percentage, fc, speed, stars, mods, hiscore}

		scores = append(scores, score)
	}

	return scores
}

type ScoreDecoder struct {
	Data []byte
	Idx  int
}

func (s *ScoreDecoder) read_byte() byte {
	s.Idx++
	return s.Data[s.Idx-1]
}

func (s *ScoreDecoder) read_uint() uint32 {
	s.Idx += 4
	return binary.LittleEndian.Uint32(s.Data[s.Idx-4 : s.Idx])
}

func (s *ScoreDecoder) read_string() string {
	s.Idx += 32
	return string(s.Data[s.Idx-32 : s.Idx])
}

func (s *ScoreDecoder) read_uint16() uint16 {
	s.Idx += 2
	return binary.LittleEndian.Uint16(s.Data[s.Idx-2 : s.Idx])
}

func (s *ScoreDecoder) skip(a int) {
	s.Idx += a
}

func (s *ScoreDecoder) is_eof() bool {
	return s.Idx >= len(s.Data)
}

func byte_bool(i byte) bool {
	return i == 1
}
