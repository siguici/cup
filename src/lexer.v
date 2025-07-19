module main

import strings

@[params]
pub struct LexerOptions {
	input  string
	file   string
	offset int
	line   int = 1
	column int = 1
}

pub struct Lexer {
	input string
mut:
	pos         Position
	ch          u8 = `\0`
	tokens      []Token
	input_len   int
	input_index int
}

pub fn lex(opts LexerOptions) []Token {
	mut l := new_lexer(opts)

	return l.lex()
}

pub fn new_lexer(opts LexerOptions) Lexer {
	mut l := Lexer{
		input:       opts.input
		pos:         Position{
			file:   opts.file
			offset: opts.offset
			line:   opts.line
			column: opts.column
		}
		input_len:   opts.input.len
		input_index: 0
	}
	l.ch = l.read_char()
	return l
}

fn (mut this Lexer) read_char() u8 {
	if this.input_index >= this.input_len {
		return `\0`
	}
	ch := this.input[this.input_index]
	this.input_index++
	this.pos.advance(ch)
	return ch
}

fn (this Lexer) peek_char() u8 {
	if this.input_index >= this.input_len {
		return `\0`
	}
	return this.input[this.input_index]
}

pub fn (mut this Lexer) add_token(typ TokenType, val string, pos Position) {
	this.tokens << new_token(typ, val, pos)
}

pub fn (mut this Lexer) skip_whitespace() {
	for this.ch == ` ` || this.ch == `\t` || this.ch == `\n` || this.ch == `\r` {
		this.ch = this.read_char()
	}
}

pub fn (mut this Lexer) lex() []Token {
	for this.ch != `\0` {
		pos_start := this.pos
		match this.ch {
			`<` {
				if this.peek_char() == `/` {
					this.read_char() // consume '/'
					this.add_token(.tag_end, '</', pos_start)
					this.ch = this.read_char()
				} else if this.peek_char() == `!` {
					// Maybe comment or doctype
					if this.input[this.input_index..].starts_with('!--') {
						this.read_char() // consume '!'
						this.read_char() // consume '-'
						this.read_char() // consume '-'
						this.scan_comment(pos_start)
					} else if this.input[this.input_index..].starts_with('DOCTYPE')
						|| this.input[this.input_index..].starts_with('doctype') {
						this.scan_doctype(pos_start)
					} else {
						this.add_token(.tag_open, '<', pos_start)
						this.ch = this.read_char()
					}
				} else if this.peek_char() == `>` {
					this.read_char() // consume '>'
					this.add_token(.tag_self_close, '/>', pos_start)
					this.ch = this.read_char()
				} else {
					this.add_token(.tag_open, '<', pos_start)
					this.ch = this.read_char()
				}
			}
			`>` {
				this.add_token(.tag_close, '>', pos_start)
				this.ch = this.read_char()
			}
			`/` {
				if this.peek_char() == `>` {
					this.read_char()
					this.add_token(.tag_self_close, '/>', pos_start)
					this.ch = this.read_char()
				} else {
					this.add_token(.unknown, '/', pos_start)
					this.ch = this.read_char()
				}
			}
			`=` {
				this.add_token(.equal, '=', pos_start)
				this.ch = this.read_char()
			}
			`{` {
				this.add_token(.lcbr, '{', pos_start)
				this.ch = this.read_char()
			}
			`}` {
				this.add_token(.rcbr, '}', pos_start)
				this.ch = this.read_char()
			}
			`(` {
				this.add_token(.lpar, '(', pos_start)
				this.ch = this.read_char()
			}
			`)` {
				this.add_token(.rpar, ')', pos_start)
				this.ch = this.read_char()
			}
			`[` {
				this.add_token(.lsbr, '[', pos_start)
				this.ch = this.read_char()
			}
			`]` {
				this.add_token(.rsbr, ']', pos_start)
				this.ch = this.read_char()
			}
			`@` {
				this.add_token(.at, '@', pos_start)
				this.ch = this.read_char()
			}
			`&` {
				this.add_token(.amp, '&', pos_start)
				this.ch = this.read_char()
			}
			`'`, `"` {
				this.scan_string()
			}
			`0`...`9` {
				this.scan_number()
			}
			` `, `\t`, `\r`, `\n` {
				this.skip_whitespace()
			}
			else {
				if is_name_start_char(this.ch) {
					this.scan_name()
				} else {
					this.add_token(.unknown, this.ch.ascii_str(), pos_start)
					this.ch = this.read_char()
				}
			}
		}
	}
	this.add_token(.eof, '', this.pos)
	return this.tokens
}

fn is_name_start_char(ch u8) bool {
	return (ch >= `a` && ch <= `z`) || (ch >= `A` && ch <= `Z`) || ch == `_` || ch == `:`
}

fn is_name_char(ch u8) bool {
	return is_name_start_char(ch) || (ch >= `0` && ch <= `9`) || ch == `-` || ch == `.`
}

fn (mut this Lexer) scan_name() {
	pos_start := this.pos
	mut name := strings.new_builder(32)
	for is_name_char(this.ch) {
		name.write_u8(this.ch)
		this.ch = this.read_char()
	}
	this.add_token(.name, name.str(), pos_start)
}

fn (mut this Lexer) scan_string() {
	pos_start := this.pos
	quote := this.ch
	mut str_val := strings.new_builder(32)
	this.ch = this.read_char() // consume quote
	for this.ch != quote && this.ch != `\0` {
		str_val.write_u8(this.ch)
		this.ch = this.read_char()
	}
	this.ch = this.read_char() // consume closing quote
	this.add_token(.string, str_val.str(), pos_start)
}

fn (mut this Lexer) scan_number() {
	pos_start := this.pos
	mut num_str := strings.new_builder(16)
	for this.ch >= `0` && this.ch <= `9` {
		num_str.write_u8(this.ch)
		this.ch = this.read_char()
	}
	if this.ch == `.` {
		num_str.write_u8(this.ch)
		this.ch = this.read_char()
		for this.ch >= `0` && this.ch <= `9` {
			num_str.write_u8(this.ch)
			this.ch = this.read_char()
		}
		this.add_token(.float, num_str.str(), pos_start)
	} else {
		this.add_token(.int, num_str.str(), pos_start)
	}
}

fn (mut this Lexer) scan_comment(start_pos Position) {
	mut comment := strings.new_builder(64)
	for !(this.ch == `-` && this.peek_char() == `-` && this.input[this.input_index] == `>`)
		&& this.ch != `\0` {
		comment.write_u8(this.ch)
		this.ch = this.read_char()
	}
	this.read_char() // '-'
	this.read_char() // '>'
	this.add_token(.comment, comment.str(), start_pos)
	this.ch = this.read_char()
}

fn (mut this Lexer) scan_doctype(start_pos Position) {
	mut doctype := strings.new_builder(64)
	for !(this.ch == `>`) && this.ch != `\0` {
		doctype.write_u8(this.ch)
		this.ch = this.read_char()
	}
	this.add_token(.doctype, doctype.str(), start_pos)
	this.ch = this.read_char()
}
