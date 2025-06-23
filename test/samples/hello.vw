style {
  body {
    background: #f2f2f2;
    color: #333;
  }
}

script {
  function hello() {
    alert("Hello View!");
  }
}

div {
  h1 [onclick="hello()"] {
    Hello View
  }
}
