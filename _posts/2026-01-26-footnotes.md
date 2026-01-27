---
layout: post
title:  "Jekyllの記事に脚注を書く"
date:   2026-01-26 15:40:00 -1000
categories: jekyll update
---

## kramdownによる記述

kramdownを利用しているJekyllでは、[kramdownの仕様](https://kramdown.gettalong.org/syntax.html#footnotes)に従って脚注を書くことができるようです。

下記のような原稿を書いておくと、

```
> 吾輩は猫である。名前はまだ無い。[^footnote]
> 
> [^footnote]: 夏目漱石『吾輩は猫である』より
> 
> どこで生れたかとんと見当がつかぬ。何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。
```

下記のように表示されます。

> 吾輩は猫である。名前はまだ無い。[^footnote]
> 
> [^footnote]: 夏目漱石『吾輩は猫である』より
> 
> どこで生れたかとんと見当がつかぬ。何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。

## スタイルシート
minimaテーマには脚注関連のスタイルは定義されていないようです。とりあえず[^css]`minima/_layout.scss`に追加しておきます。

[^css]: zundaはCSSのことをよく知らないので見様見真似です

```css
/**
 * footernote
 */
.footnotes {
  border-top: 1px solid $grey-color-light;
  padding: $spacing-unit 0;
  font-size: $small-font-size;
}
```
