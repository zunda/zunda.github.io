---
layout: post
title:  "Jekyllの記事に更新日を記す"
date:   2026-01-30 10:30:00 -1000
last_modified_at: 2026-01-30 10:40:00 -1000
categories: jekyll update
---

これまでに公開した記事を改訂したくなったので、記事に更新日を明記します。

## last_modified_at変数を表示する
[jekyll-sitemapやjekyll-feedは`page.last_modified_at`に既に対応している](https://pl.kpherox.dev/objects/7848aa88-ca45-4f09-833d-62c9ecc13270)とのことです。確かに、jekyll-feed-0.17.0の`feed.xml`に下記のような行が含まれていて、`published`タグに`date`変数が、`updated`タグに`last_modified_at`変数が適用されることがわかります。

```xml
{% raw %}<title type="html">{{ post_title }}</title>
<link href="{{ post.url | absolute_url }}" rel="alternate" type="text/html" title="{{ post_title }}" />
<published>{{ post.date | date_to_xmlschema }}</published>
<updated>{{ post.last_modified_at | default: post.date | date_to_xmlschema }}</updated>{% endraw %}
```

minima-2.5.2の`_layouts/posts.html`を`./_layouts/`以下にコピーしてきて下記のように編集します。

```patch
{% raw %}diff --git a/_layouts/post.html b/_layouts/post.html
index abf9696..bb83c91 100644
--- a/_layouts/post.html
+++ b/_layouts/post.html
@@ -6,10 +6,17 @@ layout: default
   <header class="post-header">
     <h1 class="post-title p-name" itemprop="name headline">{{ page.title | escape }}</h1>
     <p class="post-meta">
+      公開:
       <time class="dt-published" datetime="{{ page.date | date_to_xmlschema }}" itemprop="datePublished">
         {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
         {{ page.date | date: date_format }}
       </time>
+      {%- if page.last_modified_at -%}
+        • 更新:
+        <span class="dt-published">
+          {{ page.last_modified_at | date: date_format }}
+        </span>
+      {%- endif -%}
       {%- if page.author -%}
         • <span itemprop="author" itemscope itemtype="http://schema.org/Person"><span class="p-author h-card" itemprop="name">{{ page.author }}</span></span>
       {%- endif -%}</p>{% endraw %}
```

## 記事に更新日時を設定する
フロントマターの`last_modified_at`変数を設定する。この記事では下記のように設定してみました。同じ日付が表示されることになります。

```yml
layout: post
title:  "Jekyllの記事に更新日を記す"
date:   2026-01-30 10:30:00 -1000
last_modified_at: 2026-01-30 10:40:00 -1000
categories: jekyll update
```
