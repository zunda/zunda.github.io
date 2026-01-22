---
layout: post
title:  "Jekyllのminimaテーマをカスタマイズする"
date:   2026-01-21 20:00:00 -1000
categories: jekyll update
---
[`jekyll new`するとデフォルトで付いてくるMinimaテーマ](https://jekyllrb.com/docs/themes/)を自分好みに変更してみます。

## フッタの調整
`_config.yml`にサイトの情報として`title`のみを設定していると、ビルド後のフッタには

> zundaの個人サイト
>
> zundaの個人サイト

とタイトルが2回繰り返して表示されてしまいました。2回繰り返すほど大事なことではない。

Jekyllのドキュメント[Includes](https://jekyllrb.com/docs/includes/)によると、フッタのような要素のテンプレートは`_includes`ディレクトリから見つけるか、[gemでインストールされた`_includes`ディレクトリから見つける](https://jekyllrb.com/docs/themes/#understanding-gem-based-themes)ようです。試しにminima gemの`/_includes/footer.html`をこのサイトの`_includes`ディレクトリにコピーして編集して閲覧してみたところ、編集内容が反映されました。`site.homepage`を設定して`site.author`からリンクするように[変更](https://github.com/zunda/zunda.github.io/commit/066ba2ff80540f70a343e435d01f72264f0fa42f)してみます。

## スタイルシートの調整
フォントや色合いも調整してみます。`include`タグとは違い[gemとして提供されているディレクトリツリー全部をコピーしてきて編集するのが良](https://talk.jekyllrb.com/t/defining-a-second-font-in-minima/2504)さそうです。

```shell
$ cp -pr vendor/bundle/ruby/4.0.0/gems/minima-2.5.2/_sass .
```

`bundle exec jekyll serve`で生成したサイトをブラウザで閲覧し、開発者ツールのInspectorで色やフォントが気になる要素をpickしてどのファイルで設定されているのかを調べ、調整します。

ついでに、ビルド時に表示される`Deprecation Warning [color-functions]: lighten() is deprecated.`や`darken() is deprecated.`といった警告も[jekyll/jekyllのIssueへのコメント](https://github.com/jekyll/jekyll/issues/9686#issuecomment-2373992357)を参考に[抑制](https://github.com/zunda/zunda.github.io/commit/05940f22ad4c8ebded2e8828bb66a48c380ab911)しておきます。

```patch
diff --git a/_sass/minima.scss b/_sass/minima.scss
index f772ad5..e253c62 100644
--- a/_sass/minima.scss
+++ b/_sass/minima.scss
@@ -1,4 +1,5 @@
 @charset "utf-8";
+@use "sass:color";
 
 // Define defaults for each variable.
 
@@ -16,8 +17,8 @@ $brand-color:      #d88000 !default;
 $brand-color-light:#ffa000 !default;
 
 $grey-color:       #828282 !default;
-$grey-color-light: lighten($grey-color, 40%) !default;
-$grey-color-dark:  darken($grey-color, 25%) !default;
+$grey-color-light: color.adjust($grey-color, $lightness: 40%, $space: hsl) !default;
+$grey-color-dark:  color.adjust($grey-color, $lightness: -25%, $space: hsl) !default;
 
 $table-text-align: left !default;
 
diff --git a/_sass/minima/_base.scss b/_sass/minima/_base.scss
index b32254d..b76b843 100644
--- a/_sass/minima/_base.scss
+++ b/_sass/minima/_base.scss
@@ -1,3 +1,5 @@
+@use "sass:color";
+
 /**
  * Reset some basic elements
  */
@@ -225,21 +227,21 @@ table {
   margin-bottom: $spacing-unit;
   width: 100%;
   text-align: $table-text-align;
-  color: lighten($text-color, 18%);
+  color: color.adjust($text-color, $lightness: 18%, $space: hsl);
   border-collapse: collapse;
   border: 1px solid $grey-color-light;
   tr {
     &:nth-child(even) {
-      background-color: lighten($grey-color-light, 6%);
+      background-color: color.adjust($grey-color-light, $lightness: 6%, $space: hsl);
     }
   }
   th, td {
     padding: ($spacing-unit * 0.3333333333) ($spacing-unit * 0.5);
   }
   th {
-    background-color: lighten($grey-color-light, 3%);
-    border: 1px solid darken($grey-color-light, 4%);
-    border-bottom-color: darken($grey-color-light, 12%);
+    background-color: color.adjust($grey-color-light, $lightness: 3%, $space: hsl);
+    border: 1px solid color.adjust($grey-color-light, $lightness: -4%, $space: hsl);
+    border-bottom-color: color.adjust($grey-color-light, $lightness: -12%, $space: hsl);
   }
   td {
     border: 1px solid $grey-color-light;
```
