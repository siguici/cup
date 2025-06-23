pub fn parse(lines []string) []Node {
	mut nodes := []Node{}

	for line in lines {
		trimmed := line.trim_space()

		if trimmed.starts_with('<style') {
			nodes << Node{
				node_type: .style
				content:   extract_block(lines, 'style')
			}
		} else if trimmed.starts_with('<script') {
			nodes << Node{
				node_type: .script
				content:   extract_block(lines, 'script')
			}
		} else if trimmed.starts_with('<') && trimmed.ends_with('>') {
			tag := trimmed.trim_left('<').trim_right('>')
			nodes << Node{
				node_type: .tag
				name:      tag
			}
		} else if trimmed != '' {
			nodes << Node{
				node_type: .text
				content:   trimmed
			}
		}
	}

	return nodes
}

fn extract_block(lines []string, tag string) string {
	mut capturing := false
	mut result := ''

	for line in lines {
		if line.contains('<${tag}') {
			capturing = true
			continue
		}
		if line.contains('</${tag}>') {
			break
		}
		if capturing {
			result += line + '\n'
		}
	}

	return result.trim_space()
}
