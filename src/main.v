module main

import os
import cli
import term

pub fn main() {
	mut app := cli.Command{
		name:        'cup'
		description: 'Run Cup scripts or codes'
		usage:       '[file_or_code]'
		execute:     fn (cmd cli.Command) ! {
			args := cmd.args

			if args.len < 1 {
				mut code := ''
				q := term.bg_blue(term.white(term.bold(' \\q ')))
				exit_i := term.bg_magenta(term.white(term.bold(' exit() ')))
				ctrl_c := term.bg_black(term.white('Ctrl-C'))
				println('Welcome to the experimental ${term.cyan('Cup')} REPL')
				println('Type ${q} or ${exit_i} or press ${ctrl_c} to exit:')
				for {
					if mut line := os.input_opt('❯ ') {
						if line !in ['\\q', 'exit()'] {
							code += line + '\n'
							continue
						}
						break
					}
				}
				if code == '' {
					h := cmd.help_message()
					println(h)
					exit(0)
				}
				run_code(code: code)
			}

			for arg in cmd.args {
				run(arg)
			}
		}
	}

	app.setup()
	app.parse(os.args)
}
