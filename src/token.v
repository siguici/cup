module main

pub enum TokenType {
	amp     // &
	at      // @
	comment // <!-- ... -->
	doctype // <!DOCTYPE html>
	eof
	equal          // =
	float          // .456
	int            // 123
	lcbr           // {
	lpar           // (
	lsbr           // [
	name           // tag or attribute name
	nl             // \n
	rcbr           // }
	rpar           // )
	rsbr           // ]
	script_block   // script { ... }
	string         // "foo" or 'bar'
	style_block    // style { ... }
	tag_close      // >
	tag_end        // </
	tag_open       // <
	tag_self_close // />
	text           // plain text
	unknown
	whitespace
}

@[params]
pub struct TokenOptions {
	type TokenType
	pos  Position
	val  string
}

pub struct Token {
	type TokenType
	val  string
	size int
	pos  Position
}

pub fn (t TokenType) str() string {
	return match t {
		.amp { '&' }
		.at { '@' }
		.doctype { '<!DOCTYPE html>' }
		.equal { '=' }
		.lcbr { '{' }
		.lpar { '(' }
		.lsbr { '[' }
		.nl { '\n' }
		.rcbr { '}' }
		.rpar { ')' }
		.rsbr { ']' }
		.tag_close { '>' }
		.tag_end { '</' }
		.tag_open { '<' }
		.tag_self_close { '/>' }
		.eof { 'EOF' }
		else { t.str() }
	}
}

pub fn (types []TokenType) str() string {
	return types.map(it.str()).join(' ')
}

pub fn (t Token) is(tt TokenType) bool {
	return t.type == tt
}

pub fn (t Token) in(tts []TokenType) bool {
	for typ in tts {
		if t.is(typ) {
			return true
		}
	}
	return false
}

pub fn (t Token) name() string {
	return t.type.str()
}

pub fn (t Token) val_is(val string) bool {
	return t.val == val || t.name() == val
}

pub fn (t Token) val_in(vals []string) bool {
	for val in vals {
		if t.val_is(val) {
			return true
		}
	}
	return false
}

pub fn (t Token) is_value() bool {
	return t.type in [.string, .int, .float]
}

pub fn (t Token) is_block() bool {
	return t.type in [.script_block, .style_block]
}

pub fn (t Token) is_literal() bool {
	return t.is_value() || t.type == .text
}

pub fn (t Token) debug_str() string {
	return '${t.type.str()} at ${t.pos.str()}'
}

pub fn (tokens []Token) debug_str() string {
	return tokens.map(it.debug_str()).join('\n')
}

pub fn Token.new(opts TokenOptions) Token {
	val := if opts.val.len > 0 {
		opts.val
	} else {
		opts.type.str()
	}
	return Token{
		type: opts.type
		val:  val
		size: val.len
		pos:  opts.pos
	}
}

pub fn new_token(tt TokenType, val string, pos Position) Token {
	return Token.new(type: tt, val: val, pos: pos)
}

pub fn new_keyword(keyword TokenType, pos Position) Token {
	return new_token(keyword, keyword.str(), pos)
}

pub fn (t Token) is_keyword() bool {
	return t.type.str() == t.val
}
