---
layout: post
title:  "GitHub ActionsでのJekyllのIncremental Regeneration (現状の観察)"
date:   2026-01-14 15:00:00 -1000
categories: jekyll update
---

[JekyllのIncremental Regeneration](https://jekyllrb.com/docs/configuration/incremental-regeneration/)を試してみたいので、GitHub Actionsがビルド結果のファイルをどのように扱うのか確認してみました。Incremental Regenerationを利用するには、

- GitHub Actionsによる前回のビルドから、`./_site/`以下のアーティファクトと`./.jekyll-metadata`ファイルを引き継いで、今回のビルドのために展開する
- GitHub Actionsによるビルドごとにカレントディレクトリが変化しない

必要がありそうです。

## ローカルでのビルド
Incremental Regenerationでは`.jekyll-metadata`ファイルに前回のビルド結果を保存するとのことです。このファイルはトップディレクトリに生成され、メタデータにはフルパスが含まれるようです。

```
$ bundle exec jekyll build -I
$ ruby -rpp -e 'pp Marshal.load(File.read(".jekyll-metadata")).first'
["/home/zunda/c/src/github.com/zunda/zunda.github.io/_posts/2026-01-14-welcome-to-jekyll.md",
 {"mtime" => 2026-01-14 14:34:52.872091488 -1000,
  "deps" =>
   ["/home/zunda/c/src/github.com/zunda/zunda.github.io/vendor/bundle/ruby/4.0.0/gems/minima-2.5.2/_layouts/post.html",
    "/home/zunda/c/src/github.com/zunda/zunda.github.io/vendor/bundle/ruby/4.0.0/gems/minima-2.5.2/_includes/head.html",
    "/home/zunda/c/src/github.com/zunda/zunda.github.io/vendor/bundle/ruby/4.0.0/gems/minima-2.5.2/_includes/header.html",
    "/home/zunda/c/src/github.com/zunda/zunda.github.io/vendor/bundle/ruby/4.0.0/gems/minima-2.5.2/_includes/footer.html",
    "/home/zunda/c/src/github.com/zunda/zunda.github.io/vendor/bundle/ruby/4.0.0/gems/minima-2.5.2/_includes/social.html",
    "/home/zunda/c/src/github.com/zunda/zunda.github.io/vendor/bundle/ruby/4.0.0/gems/minima-2.5.2/_layouts/default.html"]}]
```


## GitHub Actionsによるアーティファクト
GitHub Pagesにこのサイトを公開してもらってGitHub.comのユーザーインターフェースからGitHub Actionsのログを確認すると、アーティファクトをダウンロードできることに気づきました。Tarファイルをzipしたもので、内容はローカルで`bundle exec jekyll serve`した時に`_site/`ディレクトリに生成されるものと同様のようです。

```shell
$ unzip ~/Downloads/github-pages.zip
$ tar xf artifact.tar
$ tree .
.
├── 404.html
├── about
│   └── index.html
├── artifact.tar
├── assets
│   ├── main.css
│   ├── main.css.map
│   └── minima-social-icons.svg
├── feed.xml
├── index.html
└── jekyll
    └── update
        └── 2026
            └── 01
                └── 14
                    └── welcome-to-jekyll.html

8 directories, 9 files
```

このアーティファクトは、buildジョブのUpload artifactステップでアップロードされ、deployジョブのDeploy to GitHub Pagesステップでダウンロードされるものと同一のハッシュのようです。


