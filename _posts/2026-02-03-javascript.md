---
layout: post
title:  "Jekyllの記事にJavaScriptを書く"
date:   2026-02-03 22:00:00 -1000
categories: jekyll kramdown
---

<p>
<form id="form">
<input type="text" id="src" placeholder="元の文字列" />に
<select id="mark">
<option value="full" selected>濁点</option>
<option value="half">半濁点</option>
</select>を<button>くっつける</button>と
<input type="text" id="dst" placeholder="こうなる" />
</form>
</p>
<script>
const form = document.getElementById("form");
const mark = document.getElementById("mark");
const src = document.getElementById("src");
const dst = document.getElementById("dst");
function convert(event) {
  event.preventDefault();
  var m = "\u3099";
  if (mark.value == "half") { m = "\u309A"; }
  dst.value = Array.from(src.value).map((c) => c + m).join("");
}
form.addEventListener("submit", convert);
</script>

kramdownにはHTMLだけじゃなくてJavaScriptもそのまま書けるんだ。

例えば、下記のようなフォームとコードを原稿に直書きしておくと、上記のように実行できるようです。Jekyllはページをビルドする時に[Liquidテンプレートエンジン](https://shopify.github.io/liquid/)を適用するので、HTMLやJavaScript中にLiquidのタグが現れる場合には[rawタグ](https://shopify.dev/docs/api/liquid/tags/raw)で囲むなどの注意が必要かもしれません。

```html
<p>
<form id="form">
<input type="text" id="src" placeholder="元の文字列" />に
<select id="mark">
<option value="full" selected>濁点</option>
<option value="half">半濁点</option>
</select>を<button>くっつける</button>と
<input type="text" id="dst" placeholder="こうなる" />
</form>
</p>
<script>
const form = document.getElementById("form");
const mark = document.getElementById("mark");
const src = document.getElementById("src");
const dst = document.getElementById("dst");
function convert(event) {
  event.preventDefault();
  var m = "\u3099";
  if (mark.value == "half") { m = "\u309A"; }
  dst.value = Array.from(src.value).map((c) => c + m).join("");
}
form.addEventListener("submit", convert);
</script>
```
