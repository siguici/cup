pub fn render(nodes []Node) string {
	mut output := ''

	for node in nodes {
		match node.node_type {
			.style {
				output += '<style>\n${node.content}\n</style>\n'
			}
			.script {
				output += '<script>\n${node.content}\n</script>\n'
			}
			.tag {
				output += '<${node.name}>'
				for child in node.children {
					output += render([child])
				}
				output += '</${node.name}>\n'
			}
			.text {
				output += node.content + '\n'
			}
		}
	}

	return output
}
