---
layout: post
title:  "RSSフィードを利用してJekyllのビルド後に新しいページを検出する"
date:   2026-01-15 12:00:00 -1000
categories: jekyll update
---

公開RSSを利用してJekyllサイトのビルド後に新しいページを検出してみます。

## Jekyllの設定
このサイトの`_config.yml`には下記のようにRSSフィードを生成するプラグインが含まれています。

```yml
plugins:
  - jekyll-feed
```

このサイトのカスタムドメインも`_config.yml`に設定しておきます。

```yml
url: "https://blog.zunda.ninja"
```

この状態でpush、ビルド、デプロイしてこのサイトのRSSフィードがカスタムドメインを含むURLにリンクするようにしておきます。

## 検出スクリプトの作成
`script/find_new_pages.rb`として下記のようなスクリプトを書きます。

```ruby
# Detect new pages from RSS feeds
require "rss"
require "uri"

base_url = "https://blog.zunda.ninja"
latest_rss = "./_site/feed.xml"
public_rss = base_url + "/feed.xml"

begin
  # Compare paths of posts.
  # ignoring shceme and hostname which maybe different with `jekyll serve`
  new_paths = [
    RSS::Parser.parse(File.read(latest_rss)), # current build
    RSS::Parser.parse(public_rss)             # prebious deploy
  ].map{|feed| feed.items.map{|item| URI.parse(item.link.href).path}}.inject(:-)

  if new_paths.empty?
    puts "No new pages."
  else
    puts "New pages:\n#{new_paths.map{|path| base_url + path}.join("\n")}"
  end
rescue => e
  # Let build continue even we failed finding new pages
  puts "#{e.message}\n\tfrom #{e.backtrace.last}"
end
```

このディレクトリが公開されないよう、`_config.yml`ファイルに設定を追加しておきます。

```yml
exclude:
  - script/
```

## 検出スクリプトのGitHub Workflowからの実行
`.github/workflows/jekyll.yml`のBuildジョブのBuild with Jekyllステップの後に下記のようなステップを挿入します。

```patch
diff --git a/.github/workflows/jekyll.yml b/.github/workflows/jekyll.yml
index 615d29b..f93a2e8 100644
--- a/.github/workflows/jekyll.yml
+++ b/.github/workflows/jekyll.yml
@@ -47,6 +47,8 @@ jobs:
         run: bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
         env:
           JEKYLL_ENV: production
+      - name: Find new pages since previous deploy
+        run: ruby ./script/find_new_pages.rb
       - name: Upload artifact
         # Automatically uploads an artifact from the './_site' directory by default
         uses: actions/upload-pages-artifact@v3
```

ここまでの変更点をいったんpushしておきます。

## 結果
それではこの記事を公開してみます。

```shell
$ git add _posts/2026-01-15-find-new-pages-with-rss.md
$ git commit
$ git push
```
