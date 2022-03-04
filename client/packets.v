module client

import time

// C->S Handshake
// S->C Handshake
// C->S Authentication Request
// Server Verifies
// If fails:
	// S->C Invalid
	// terminates the connection
// S->C Clir Request
// C->S Clir
// S Processes

// If ANY packet fails, the connection is terminated

// Packets are length prefixed (u32)

interface Packet { 
	id byte
}

struct CHandshake {
pub:
	id byte = 1
	// ts = TimeStamp
	ts u64 = u64(time.now().unix_time())
}

struct SHandshake {
pub:
	id byte = 1
	ts u64 // no default, because it has reply with the client's payload
}

struct CAuthRequest {
pub:
	id  byte = 2
	key string
}

struct SInvalid {
pub:
	id byte = 3
}

struct SClirRequest {
pub:
	id byte = 4
}

struct CClirSend {
pub:
	id   byte = 5
	key  string
	clir Clir
}