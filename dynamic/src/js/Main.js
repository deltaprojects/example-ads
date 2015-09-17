var mustache = require("mustache")

html5.ready(() => {
  var template = document.getElementById('products').innerHTML
  mustache.parse(template)
  var rendered = mustache.render(template, {products: html5.products.all()})
  document.body.innerHTML = rendered
})
