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

pub fn (mut this Position) advance(c byte) Position {
	this.offset += 1
	if c == `\n` {
		this.line += 1
		this.column = 1
	} else {
		this.column += 1
	}
	return this
}

pub fn (this Position) str() string {
	mut str := ''
	if this.file != '' {
		str += this.file + ':'
	}
	return '${str}${this.line}:${this.column}'
}

pub fn (this Position) is_valid() bool {
	return this.line > 0 && this.column > 0
}

pub fn Position.new(options PositionOptions) Position {
	return Position{options.file, options.offset, options.line, options.column}
}

pub fn new_position(options PositionOptions) Position {
	return Position.new(options)
}
