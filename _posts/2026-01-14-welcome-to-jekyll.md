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

```shell
$ git pull
$ git add _posts/2026-01-14-welcome-to-jekyll.md
$ git commit
$ git push
```

## Rubyのバージョンを調整する
新しいレポジトリのActionsタブを確認すると、無事にworkflowが起動したようですが、エラー終了が記録されていました。ログを確認するには、失敗したrunのコミットメッセージをクリックし、赤いマークの付いているworkflowのステップをクリックし、エラーの表示されている行の上の行をクリックするようです。

```
Installing Bundler
  Using Bundler 4.0.3 from Gemfile.lock BUNDLED WITH 4.0.3
  /opt/hostedtoolcache/Ruby/3.1.6/x64/bin/gem install bundler -v 4.0.3
  ERROR:  Error installing bundler:
  	bundler-4.0.3 requires Ruby version >= 3.2.0. The current ruby version is 3.1.6.
  Took   0.36 seconds
```

`.github/workflows/jekyll.yml`を眺めると、下記のように`ruby/setup-ruby`のタグが指定されているようです。このレポジトリの[リリース](https://github.com/ruby/setup-ruby/releases)は執筆時点でv1.283.0まで進んでいるようなので、これを使ってみます。

```yml
jobs:
  # Build job
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Ruby
        # https://github.com/ruby/setup-ruby/releases/tag/v1.207.0
        uses: ruby/setup-ruby@4a9ddd6f338a97768b8006bf671dfbad383215f4
        with:
          ruby-version: '3.1' # Not needed with a .ruby-version file
          bundler-cache: true # runs 'bundle install' and caches installed gems automatically
          cache-version: 0 # Increment this number if you need to re-download cached gems
```

```patch
diff --git a/.github/workflows/jekyll.yml b/.github/workflows/jekyll.yml
index 501686b..615d29b 100644
--- a/.github/workflows/jekyll.yml
+++ b/.github/workflows/jekyll.yml
@@ -34,10 +34,9 @@ jobs:
       - name: Checkout
         uses: actions/checkout@v4
       - name: Setup Ruby
-        # https://github.com/ruby/setup-ruby/releases/tag/v1.207.0
-        uses: ruby/setup-ruby@4a9ddd6f338a97768b8006bf671dfbad383215f4
+        # https://github.com/ruby/setup-ruby/releases/tag/v1.283.0
+        uses: ruby/setup-ruby@708024e6c902387ab41de36e1669e43b5ee7085e
         with:
-          ruby-version: '3.1' # Not needed with a .ruby-version file
           bundler-cache: true # runs 'bundle install' and caches installed gems automatically
           cache-version: 0 # Increment this number if you need to re-download cached gems
       - name: Setup Pages
```
