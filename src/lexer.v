module main

import strings.textscanner

@[params]
pub struct LexerOptions {
	input string
	file  string
	dir   string
}

@[noinit]
pub struct Lexer {
	textscanner.TextScanner
pub mut:
	file   string
	line   int = 1
	column int = 1
}

pub fn Lexer.new(o LexerOptions) Lexer {
	return new_lexer(o)
}

pub fn new_lexer(o LexerOptions) Lexer {
	return Lexer{
		TextScanner: textscanner.new(o.input)
		file:        o.file
	}
}

pub fn tokenize(options LexerOptions) []Token {
	mut l := new_lexer(
		input: options.input
		file:  options.file
	)

	return l.lex()
}

pub fn (mut l Lexer) lex() []Token {
	mut t := []Token{}

	for l.next() != -1 && l.pos != l.ilen {
		t << l.scan()
	}

	return t
}

pub fn (mut l Lexer) next_line() int {
	l.skip_line()
	return l.next()
}

pub fn (mut l Lexer) next_column() int {
	l.skip_column()
	return l.next()
}

pub fn (mut l Lexer) skip_line() {
	l.line++
	l.column = 1
}

pub fn (mut l Lexer) skip_column() {
	l.column++
}

pub fn (mut l Lexer) skip_line_n(n int) {
	l.line += n
	l.column = 1
}

pub fn (mut l Lexer) skip_column_n(n int) {
	l.column += n
}

pub fn (mut l Lexer) scan_char() u8 {
	c := if l.current_u8() == `\n` {
		l.next_line()
	} else {
		l.next_column()
	}
	return u8(c)
}

pub fn (mut l Lexer) scan() Token {
	mut c := l.current_u8()

	match c {
		0 {
			return l.emit(.eof)
		}
		`<` {
			c = l.scan_char()
			if c == `/` {
				return l.emit(.tag_end)
			}
			return l.emit(.tag_open)
		}
		`>` {
			l.scan_char()
			return l.emit(.tag_close)
		}
		`/` {
			c = l.scan_char()
			if c == `>` {
				l.scan_char()
				return l.emit(.tag_self_close)
			}
			return l.emit_lexeme(.unknown, '/')
		}
		`=` {
			l.scan_char()
			return l.emit(.equal)
		}
		`"`, `'` {
			ss := l.scan_string(l.current())
			return l.emit_lexeme(.string, ss)
		}
		`\n` {
			l.scan_char()
			return l.emit(.nl)
		}
		`{` {
			l.scan_char()
			return l.emit(.lcbr)
		}
		`}` {
			l.scan_char()
			return l.emit(.rcbr)
		}
		`(` {
			l.scan_char()
			return l.emit(.lpar)
		}
		`)` {
			l.scan_char()
			return l.emit(.rpar)
		}
		`[` {
			l.scan_char()
			return l.emit(.lsbr)
		}
		`]` {
			l.scan_char()
			return l.emit(.rsbr)
		}
		else {
			sp := l.scan_whitespace()
			if sp.len >= 1 {
				l.pos--
				return l.emit_lexeme(.whitespace, sp)
			}

			nb := l.scan_number()
			if nb.len >= 1 {
				l.pos--
				return l.emit_lexeme(.number, nb)
			}

			id := l.scan_identifier()
			if id.len >= 1 {
				l.pos--
				return l.emit_lexeme(.name, id)
			}
		}
	}

	return l.emit_lexeme(.unknown, c.ascii_str())
}

pub fn (mut l Lexer) scan_string(quote int) string {
	l.next_column()
	mut v := ''
	mut end := false

	for l.pos < l.ilen {
		if l.current() == quote && l.peek_back() != `\\` {
			end = true
			break
		}
		if l.current() == `\\` {
			v += match l.peek_u8() {
				`n` {
					'\n'
				}
				`r` {
					'\r'
				}
				`t` {
					'\t'
				}
				`\\` {
					'\\'
				}
				u8(quote) {
					u8(quote).ascii_str()
				}
				else {
					panic('Cannot escape ${l.peek_str()}')
				}
			}
			l.column += 2
			l.next()
			l.next()
			continue
		}
		if l.current_is_new_line() {
			l.skip_line()
		} else {
			l.skip_column()
		}
		v += l.current_str()
		l.next()
	}

	if !end {
		panic('End of string ${quote} expected')
	}

	return v
}

pub fn (mut l Lexer) scan_whitespace() string {
	mut w := ''

	for l.pos < l.ilen && l.current_is_space() {
		w += l.current_str()
		if l.current_is_new_line() {
			l.line++
			l.column = 1
		} else {
			l.column++
		}
		l.next()
	}

	return w
}

pub fn (mut l Lexer) scan_number() string {
	return l.scan_int() + l.scan_float()
}

pub fn (mut l Lexer) scan_int() string {
	mut i := ''

	for l.pos < l.ilen && l.current_is_digit() {
		i += l.current_str()
		l.column++
		l.next()
	}

	return i
}

pub fn (mut l Lexer) scan_float() string {
	mut d := ''

	if l.current_is_dot() && l.peek_is_digit() {
		d += l.current_str()
		l.column++
		for l.pos < l.ilen && l.peek_is_digit() {
			d += l.peek_str()
			l.column++
			l.next()
		}
	}

	return d
}

pub fn (mut l Lexer) scan_identifier() string {
	mut id := ''

	for l.pos < l.ilen && (l.current_is_dash() || l.current_is_letter()) {
		id += l.current_str()
		l.next_column()
	}

	if l.current_is_digit() {
		for l.pos < l.ilen && (l.current_is_digit() || l.current_is_dash() || l.current_is_letter()) {
			l.column++
			id += l.current_str()
			l.next()
		}
	}

	return id
}

pub fn (mut l Lexer) current_u8() u8 {
	return u8(l.current())
}

pub fn (mut l Lexer) current_str() string {
	return l.current_u8().ascii_str()
}

pub fn (mut l Lexer) current_is_space() bool {
	return l.current_u8().is_space()
}

pub fn (mut l Lexer) current_is_digit() bool {
	return l.current_u8().is_digit()
}

pub fn (mut l Lexer) current_is_letter() bool {
	return l.current_u8().is_letter()
}

pub fn (mut l Lexer) current_is_new_line() bool {
	return l.current_u8() == `\n`
}

pub fn (mut l Lexer) current_is_dot() bool {
	return l.current_u8() == `.`
}

pub fn (mut l Lexer) current_is_dash() bool {
	return l.current_u8() == `-`
}

pub fn (mut l Lexer) peek_str() string {
	return l.peek_u8().ascii_str()
}

pub fn (mut l Lexer) peek_is_space() bool {
	return l.peek_u8().is_space()
}

pub fn (mut l Lexer) peek_is_digit() bool {
	return l.peek_u8().is_digit()
}

pub fn (mut l Lexer) peek_is_letter() bool {
	return l.peek_u8().is_letter()
}

pub fn (mut l Lexer) peek_is_new_line() bool {
	return l.peek_u8() == `\n`
}

pub fn (mut l Lexer) emit(type TokenType) Token {
	return l.emit_lexeme(type, '')
}

pub fn (mut l Lexer) emit_lexeme(type TokenType, lexeme string) Token {
	value := if lexeme == '' { type.str() } else { lexeme }
	pos := new_position(
		file:   l.file
		offset: l.pos
		line:   l.line
		column: l.column - value.len
	)
	return new_token(
		type:   type
		lexeme: value
		pos:    pos
	)
}
