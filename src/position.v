pub struct Position {
mut:
	file   string
	offset int
	line   int
	column int
}

@[params]
pub struct PositionOptions {
	file   string
	offset int
	line   int
	column int
}

pub fn (mut p Position) advance(c u8) Position {
	p.offset += 1
	if c == `\n` {
		p.line += 1
		p.column = 1
	} else {
		p.column += 1
	}
	return p
}

pub fn (p Position) str() string {
	mut str := ''
	if p.file != '' {
		str += p.file + ':'
	}
	return '${str}${p.line}:${p.column}'
}

pub fn (p Position) is_valid() bool {
	return p.line > 0 && p.column > 0
}

pub fn Position.new(o PositionOptions) Position {
	return new_position(o)
}

pub fn new_position(o PositionOptions) Position {
	return Position{o.file, o.offset, o.line, o.column}
}
