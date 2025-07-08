# Cup 🫖 — The Cascading Markup Language

**Cup** is a lightweight, flexible, and elegant templating engine written in
[V](https://vlang.io). It combines the structure of **HTML**, the cascading
power of **CSS**, and the interactivity of **JavaScript/TypeScript** into a
single, clean, and expressive syntax — without sacrificing compatibility.

> ✨ **Write once. Render fast. See clearly.**

---

## 🚀 Features

- ✅ **HTML/CSS/JS-inspired syntax** — fully compatible with standard tags and
  attributes  
- 💡 **Cascading and nested blocks** — like CSS, but across markup and logic  
- 🧠 **Scoped styles and inline logic** — embed behavior within elements  
- 🔄 **Dynamic templating** — simple conditionals, loops,
and reactive variables (planned)  
- ⚙️ **Transpiles to pure HTML/CSS/JS** — no runtime dependencies  
- 🦕 **Built in V** — minimal, blazing fast, cross-platform  

---

## 📦 Installation

### Using VPM (V Package Manager)

```bash
v install siguici.cup
````

Or directly from GitHub:

```bash
v install github.com/siguici/cup
```

---

## 🧪 Quick Example

```cup
button {
  Click me
  style {
    @import './global.css';

    background: var(--primary-color);
    color: white;
    padding: 1em;
    border-radius: 8px;

    &:hover {
      background: var(--secondary-color);
    }
  }
  script {
    this.addEventListener('click', () => {
      alert("Hello from Cup!")
    })
  }
}
```

Compiles to:

```html
<button onclick="alert('Hello from Cup!')" style="background:#7878ff;color:white;padding:1em;border-radius:8px;">
  Click me
</button>
```

---

## 🔧 Usage in V

```v
import siguici.cup

fn main() {
  html := cup.render_file('examples/hello.cup') or {
    eprintln('Error: $err')
    return
  }
  println(html)
}
```

---

## 🗺️ Roadmap

- [x] Basic lexer/parser
- [x] Embedded style and script blocks
- [x] HTML transpilation
- [ ] Conditionals (`@if`, `@else`)
- [ ] Loops (`@for`, `@each`)
- [ ] Reactive variables (`@var`, `@watch`)
- [ ] Live preview / runtime renderer (optional)
- [ ] Plugin system

---

## 🤝 Contributing

Pull requests, feedback, ideas, and questions are welcome!

> **To contribute:**
>
> 1. Fork this repo
> 2. Clone locally and create a new branch
> 3. Make your changes
> 4. Open a pull request

---

## 📜 License

MIT © [Sigui Kessé Emmanuel](https://github.com/siguici)
