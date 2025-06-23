# 👁️ View — HTML/CSS-Inspired Syntax Template Rendering Engine (in [V](https://vlang.io))

**View** is a lightweight, flexible and elegant **template rendering engine**
written in [V](https://vlang.io).  
It combines the structure of **HTML**, the cascading power of **CSS**,
and the interactivity of **JavaScript** into a single,
clean and expressive syntax — without sacrificing compatibility.

> ✨ **Write once. Render fast. See clearly.**

---

## 🚀 Features

- ✅ **HTML/CSS/JS-inspired syntax** — fully compatible with standard tags and attributes
- 💡 **Cascading and nested blocks** — like CSS, but across markup and logic
- 🧠 **Scoped styles and inline logic** — embedded behavior within elements
- 🔄 **Dynamic templating** — simple conditionals, loops,
and reactive variables (planned)
- ⚙️ **Transpiles to pure HTML/CSS/JS** — no runtime dependencies
- 🦕 **Built in V** — minimal, blazing fast, cross-platform

---

## 📦 Installation

### Using VPM (V Package Manager)

```bash
v install siguici.view
````

Or directly from GitHub:

```bash
v install github.com/siguici/view
```

---

## 🧪 Quick Example

```view
@color: #7878ff;

button {
  Click me
  style {
    background: @color;
    color: white;
    padding: 1em;
    border-radius: 8px;
  }
  onclick {
    alert("Hello from View!")
  }
}
```

Compiles to:

```html
<button onclick="alert('Hello from View!')" style="background:#7878ff;color:white;padding:1em;border-radius:8px;">
  Click me
</button>
```

---

## 🔧 Usage in V

```v
import view

fn main() {
    html := view.render_file('examples/hello.view') or {
        eprintln('Error: $err')
        return
    }
    println(html)
}
```

---

## 📁 Project Structure

```
view/
├── src/
│   ├── lexer.v         # Tokenizer for the .view syntax
│   ├── parser.v        # Converts tokens into AST
│   ├── transpiler.v    # Generates HTML/CSS/JS output
│   ├── renderer.v      # Optional live renderer or runtime
│   └── utils.v         # Shared helpers
├── examples/           # .view template samples
├── tests/              # Unit and integration tests
├── README.md
└── view.vmod
```

---

## 📄 `view.vmod`

```toml
Module {
  name = "view"
  version = "0.1.0"
  description = "👁️ View: HTML/CSS-inspired syntax template rendering engine written in V."
  license = "MIT"
  repository = "https://github.com/yourusername/view"
  dependencies = []
}
```

---

## 🗺️ Roadmap

* [x] Basic lexer/parser
* [x] Embedded style and script blocks
* [x] HTML transpilation
* [ ] Conditionals (`@if`, `@else`)
* [ ] Loops (`@for`, `@each`)
* [ ] Reactive variables (`@var`, `@watch`)
* [ ] Live preview / runtime renderer (optional)
* [ ] Plugin system

---

## 🤝 Contributing

Pull requests, feedback, ideas and questions are welcome!

> **To contribute:**
>
> 1. Fork this repo
> 2. Clone locally and create a new branch
> 3. Make your changes
> 4. Open a pull request

---

## 📜 License

MIT © [Sigui Kessé Emmanuel](https://github.com/siguici)
