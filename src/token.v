module main

pub enum TokenType {
	boolean // true or false
	comment // <!-- ... -->
	doctype // <!DOCTYPE html>
	eof
	equal          // =
	lcbr           // {
	lpar           // (
	lsbr           // [
	name           // tag or attribute name
	nl             // \n
	number         // 123 or .456 or 123.456
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
	type   TokenType
	pos    Position
	lexeme string
}

pub struct Token {
	type   TokenType
	lexeme string
	size   int
	pos    Position
}

pub fn (t TokenType) str() string {
	return match t {
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

pub fn (t Token) lexeme_is(lexeme string) bool {
	return t.lexeme == lexeme || t.name() == lexeme
}

pub fn (t Token) lexeme_in(lexemes []string) bool {
	for lexeme in lexemes {
		if t.lexeme_is(lexeme) {
			return true
		}
	}
	return false
}

pub fn (t Token) is_literal() bool {
	return t.type in [.text, .string, .number]
}

pub fn (t Token) is_block() bool {
	return t.type in [.script_block, .style_block]
}

pub fn (t Token) debug_str() string {
	return '${t.type.str()} at ${t.pos.str()}'
}

pub fn (tokens []Token) debug_str() string {
	return tokens.map(it.debug_str()).join('\n')
}

pub fn Token.new(o TokenOptions) Token {
	return new_token(o)
}

pub fn new_token(o TokenOptions) Token {
	lexeme := if o.lexeme.len > 0 {
		o.lexeme
	} else {
		o.type.str()
	}
	return Token{
		type:   o.type
		lexeme: lexeme
		size:   lexeme.len
		pos:    o.pos
	}
}

pub fn (t Token) is_keyword() bool {
	return t.type.str() == t.lexeme
}
