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
$ bundle exec jekyll new zunda.github.io
$ cd zunda.github.io
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

## GitHub Pagesで公開する
[GitHub Pages documentation](https://docs.github.com/en/pages)に従って公開してみます。

僕のGitHubアカウントではこれまで別のレポジトリをGitHub Pagesとして公開していました。[Creating a GitHub Pages site](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site)に従って、新しいレポジトリをつくり、このサイトを公開してみます。[GitHub Pagesを公開するレポジトリ名は`<user>.github.io`に限定されているようです](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site#creating-a-repository-for-your-site)。

1. 既存のレポジトリ`zunda/zunda.github.io`のSettings-PagesからGitHub PagesをUnpublish siteしビルド元のBranchをNoneにしSaveする
1. レポジトリ名を変更する
1. 新しいレポジトリ`zunda/zunda.github.io`を作る
1. このサイトの内容をpushする
   ```shell
   $ git remote add origin git@github.com:zunda/zunda.github.io.git
   $ git push -u origin master
   ```
1. 新しいレポジトリのSettingsからVisibilityをPublicにする
1. 新しいレポジトリのSettings-PagesのBuild and deploymentから
   1. SourceをGitHub Actionsにして、
   1. JekyllをConfigureして、
   1. `.github/workflows/jekyll.yml`の内容を確認して、Commit changes...する。右ペインのFestured Actionsのうち、[Cache](https://github.com/marketplace/actions/cache)か[Download a Build Artifact](https://github.com/marketplace/actions/download-a-build-artifact)でインクリメンタルなビルドができるようになるかもしれない。

ここまでのメモを公開してみます。

```
$ git pull
$ git add _posts/2026-01-14-welcome-to-jekyll.md
$ git commit
$ git push
```
