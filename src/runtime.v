module main

import os

@[params]
struct RunOptions {
	code string
	file string
}

pub fn run(code string) {
	mut path := code
	if os.exists(path) {
		run_path(path)
	} else {
		if !path.ends_with('.cup') {
			path += '.cup'
		}

		if os.is_file(path) {
			run_file(path)
		} else {
			run_code(code: code)
		}
	}
}

pub fn run_path(path string) {
	if os.is_dir(path) {
		for file in os.ls(path) or { panic(err) } {
			run_file(file)
		}
	} else if os.is_file(path) {
		run_file(path)
	}
}

pub fn run_file(file string) {
	code := os.read_file(file) or { panic(err) }
	run_code(code: code, file: file)
}

pub fn run_code(opts RunOptions) {
	tokens := tokenize(input: opts.code, file: opts.file)
	// nodes := parse(lines)
	// html := render(nodes)
	dump(tokens)
}
