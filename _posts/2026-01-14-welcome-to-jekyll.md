---
layout: post
title:  "Jekyll始めました"
date:   2026-01-14 10:53:04 -1000
categories: jekyll update
---

[jekyllrb.com](https://jekyllrb.com/)に従ってJekyllを動かしてみることにしました。

## 雛形を作ってもらう
```shell
$ mkdir x
$ cd x
$ rbenv local 4.0.1
$ bundle init
$ bundle add jekyll
$ bundle add logger
$ bundle exec jekyll new zunda-blog
$ cd zunda-blog
$ rbenv local 4.0.1
$ bundle add logger
$ bundle exec jekyll serve
```

いくつか警告が表示されるけれども http://127.0.0.1:4000/ で雛形が見えました。ここまでの状態を記録しておきます。

```shell
$ git init
$ git add .gitignore .ruby-version 404.html Gemfile Gemfile.lock _config.yml _posts/2026-01-14-welcome-to-jekyll.markdown about.markdown index.markdown
$ git commit -m 'Initial commit'
```

## 自分好みにする
### 記事ファイルの拡張子
拡張子は`.markdown`よりも`.md`が好み。

```shell
$ git mv index.markdown index.md
$ git mv about.markdown about.md
$ git mv _posts/2026-01-14-welcome-to-jekyll.markdown _posts/2026-01-14-welcome-to-jekyll.md
$ git commit
```

### 全体的な設定
`_config.yml`を編集します。`kramdown`を使ってみます。

```shell
$ bundle add kramdown
$ vi _config.yml
```

`_config.yml`に下記のような行を追加しました。

```yml
markdown: kramdown
kramdown:
  input: GFM
  hard_wrap: false
  syntax_highlighter: rouge
  autolink: true
```

[このサイトについて](/about)も編集します。

```shell
$ vi about.html
```

### 記事
このメモを最初の記事にします。

```shell
$ vi _posts/2026-01-14-welcome-to-jekyll.md
```

ここまでの作業を記録しておきます。

```shell
$ git commit -a
```
