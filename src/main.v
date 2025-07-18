import os

fn main() {
	path := 'test/samples/hello.cup'
	source := os.read_file(path) or { panic(err) }
	lines := tokenize(source)
	nodes := parse(lines)
	html := render(nodes)

	println(path)

	println(html)
}
