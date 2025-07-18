pub enum NodeType {
	tag
	text
	style
	script
}

pub struct Node {
pub mut:
	node_type NodeType
	name      string
	attrs     map[string]string
	children  []Node
	content   string
}
