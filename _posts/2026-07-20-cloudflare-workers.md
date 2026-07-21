---
layout: post
title:  "静的サイトをCloudflare Workersで公開する"
date:   2026-07-20 15:00:00 -1000
last_modified_at: 2026-07-20 16:50:00 -1000
categories: vitepress cloudflare cloudflareworkers
---

この記事は未完です。

いろいろあって、VitePressに生成してもらっている静的サイトmitome.inのトップレベルドメインを変更してmitome.inkに引っ越すことにしました。ついでに、ビルドと公開にCloudflare Workersを試してみることにしました。

## 現状
Cloudflareのアカウントに支払い手段を設定して引っ越し先のドメインmitome.inkを購入しました。

静的サイトのコードはGitHubに[zunda/mitome.in](https://github.com/zunda/mitome.in)として管理していただいています。

## Cloudflare Workers
Cloudflareによるドキュメントを眺めてみると、Workersでは[CI/CD機能](https://developers.cloudflare.com/workers/ci-cd/)としてWorkers Buildsやその他のプロバイダによるビルドシステムを利用できるようです。ここでは、[Workers Builds](https://developers.cloudflare.com/workers/ci-cd/builds/)のGitHub Integrationを利用してみます。

Workers Buildsの[Get started文書](https://developers.cloudflare.com/workers/ci-cd/builds/#get-started)に従って作業を進めてみます。

### Workerの作成
CloudflareとGitHubにログインした状態のブラウザを利用します。

1. Cloudflareのダッシュボードにログインします
1. GitHubにログインしておきます。
1. [Workers & Pages](https://dash.cloudflare.com/?to=/:account/workers-and-pages)を閲覧します
1. 右上のCreate applicationボタンを押します
1. Ship something newという表題の下記の選択肢からConnect GitHubを選択します
  - Connect GitHub
  - Connect GitLab
  - Start with Hello World!
  - Select a template
  - Upload your static files
1. GitHubのウインドウが開くので、Cloudflare Workers and Pagesをインストールする対象のGitHub アカウント/組織とレポジトリを選択します。今回は、自アカウントの、Only selected repositoriesとして、zunda/mitome.inを選択しました。これによって、下記のパーミションが有効になるとのことでした。書き込み権限が広いようにも思うけれどもしかたないのかな。
  - Read access to metadata 
  - Read and write access to administration, checks, code, deployments, and pull requests
1. 元のウインドウで、Continuw with GitHub→を選択します
1. GitHubレポジトリを選択します
1. Set up your applicationという表題のステップで、下記を設定します
  - Project name: mitomein (小文字のアルファベットと数字とダッシュのみが利用できるとのことです)
  - Build command: `yarn docs:build` (デフォルトは空白)
  - Deploy command: デフォルトの`npx wrangler deploy`のまま
  - Builds for non-production branches有効に (デフォルトは有効)
1. Deployボタンを押します。生成されたサイトのパス (`./docs/.vuepress/dist/`) を設定する項目はありませんでしたがとりあえず進めます

ここまでの作業で、ブラウザにビルドの進行状況が表示されました。今回のビルドは下記のようなログを残して失敗したようです。

```
2026-07-21T01:16:38.145Z	Initializing build environment...
2026-07-21T01:16:38.145Z	Initializing build environment...
2026-07-21T01:16:39.870Z	Success: Finished initializing build environment
2026-07-21T01:16:41.275Z	Cloning repository...
2026-07-21T01:16:42.703Z	Restoring from dependencies cache
2026-07-21T01:16:42.705Z	Restoring from build output cache
2026-07-21T01:16:42.708Z	Detected the following tools from environment: yarn@4.9.1, nodejs@22.16.0
2026-07-21T01:16:42.845Z	Installing project dependencies: yarn
2026-07-21T01:16:44.128Z	➤ YN0087: Migrated your project to the latest Yarn version 🚀
2026-07-21T01:16:44.129Z
2026-07-21T01:16:44.130Z	➤ YN0000: · Yarn 4.5.0
2026-07-21T01:16:44.149Z	➤ YN0000: ┌ Resolution step
2026-07-21T01:16:46.945Z	➤ YN0085: │ + @fortawesome/fontawesome-svg-core@npm:6.7.2, @fortawesome/free-solid-svg-icons@npm:6.7.2, @fortawesome/vue-fontawesome@npm:3.0.8, and 197 more.
2026-07-21T01:16:46.952Z	➤ YN0000: └ Completed in 2s 804ms
2026-07-21T01:16:46.953Z	➤ YN0000: ┌ Post-resolution validation
2026-07-21T01:16:46.953Z	➤ YN0002: │ mitome.in@workspace:. doesn't provide vue (pdbc23), requested by @fortawesome/vue-fontawesome and other dependencies.
2026-07-21T01:16:46.954Z	➤ YN0086: │ Some peer dependencies are incorrectly met by your project; run yarn explain peer-requirements <hash> for details, where <hash> is the six-letter p-prefixed code.
2026-07-21T01:16:46.954Z	➤ YN0086: │ Some peer dependencies are incorrectly met by dependencies; run yarn explain peer-requirements for details.
2026-07-21T01:16:46.976Z	➤ YN0028: │ The lockfile would have been modified by this install, which is explicitly forbidden.
2026-07-21T01:16:46.977Z	➤ YN0000: └ Completed
2026-07-21T01:16:46.982Z	➤ YN0000: · Failed with errors in 2s 845ms
2026-07-21T01:16:47.026Z	Failed: error occurred while installing tools or dependencies
```

## ビルドの問題への対応
ローカルで問題を再現して対応していきます。

### 問題の再現
これまでは古いYarnコマンドで`yarn install`に成功していました。

```
$ yarn install --pure-lockfile
yarn install v1.22.22
[1/5] Validating package.json...
[2/5] Resolving packages...
[3/5] Fetching packages...
[4/5] Linking dependencies...
warning " > @fortawesome/vue-fontawesome@3.0.8" has unmet peer dependency "vue@>= 3.0.0 < 4".
warning "vitepress > @docsearch/js > @docsearch/react > @algolia/autocomplete-preset-algolia@1.17.7" has unmet peer dependency "@algolia/client-search@>= 4.9.1 < 6".
warning "vitepress > @docsearch/js > @docsearch/react > @algolia/autocomplete-core > @algolia/autocomplete-plugin-algolia-insights@1.17.7" has unmet peer dependency "search-insights@>= 1 < 3".
warning "vitepress > @docsearch/js > @docsearch/react > @algolia/autocomplete-core > @algolia/autocomplete-shared@1.17.7" has unmet peer dependency "@algolia/client-search@>= 4.9.1 < 6".
warning " > vue-toast-notification@3.1.3" has unmet peer dependency "vue@^3.0".
[5/5] Building fresh packages...
Done in 1.44s.
```

YarnコマンドをCloudflare Workersと同じバージョンにすることで、無事に`yarn install`を失敗させることができました。

```
$ yarn set version 4.5.0
$ yarn install --immutable
➤ YN0000: · Yarn 4.5.0
➤ YN0000: ┌ Resolution step
➤ YN0085: │ + @fortawesome/fontawesome-svg-core@npm:6.7.2, and 199 more.
➤ YN0000: └ Completed in 1s 289ms
➤ YN0000: ┌ Post-resolution validation
➤ YN0002: │ mitome.in@workspace:. doesn't provide vue (pdbc23), requested by @fortawesome/vue-fontawesome and other dependencies.
➤ YN0086: │ Some peer dependencies are incorrectly met by your project; run yarn explain peer-requirements <hash> for details, where <hash> is the six-letter p-prefixed code.
➤ YN0086: │ Some peer dependencies are incorrectly met by dependencies; run yarn explain peer-requirements for details.
➤ YN0028: │ The lockfile would have been modified by this install, which is explicitly forbidden.
➤ YN0000: └ Completed
➤ YN0000: · Failed with errors in 1s 329ms
```

## 足りないモジュールの追加
ブランチで作業します。

```
$ git switch -c build-on-cloudflare
$ yarn add -D vue
➤ YN0000: · Yarn 4.5.0
➤ YN0000: ┌ Resolution step
➤ YN0085: │ + vue@npm:3.5.40, and 19 more.
➤ YN0000: └ Completed in 0s 679ms
➤ YN0000: ┌ Post-resolution validation
➤ YN0086: │ Some peer dependencies are incorrectly met by dependencies; run yarn explain peer-requirements for details.
➤ YN0000: └ Completed
➤ YN0000: ┌ Fetch step
➤ YN0013: │ 20 packages were added to the project (+ 16.01 MiB).
➤ YN0000: └ Completed in 1s 141ms
➤ YN0000: ┌ Link step
➤ YN0000: └ Completed in 0s 356ms
➤ YN0000: · Done with warnings in 2s 221ms
```

ここまでの作業で下記のような差分が得られました。`vue`モジュールの追加のみをライセンスの追加と一緒にcommitしてGitHubにpushします。

```diff
diff --git a/package.json b/package.json
index 65f32b5..5451c22 100644
--- a/package.json
+++ b/package.json
@@ -18,11 +18,13 @@
     "moment": "^2.30.1",
     "openpgp": "^6.1.1",
     "vitepress": "^1.5.0",
+    "vue": "^3.5.40",
     "vue-toast-notification": "^3"
   },
   "scripts": {
     "docs:dev": "vitepress dev docs",
     "docs:build": "vitepress build docs",
     "docs:preview": "vitepress preview docs"
-  }
+  },
+  "packageManager": "yarn@4.5.0"
 }
```

## Cloudflare Workersでのビルド
Cloudflareのダッシュボードに戻り、左のペインから、Build - Workers & Pagesを選択し、先ほど作成したWorkerを選択します。下方のVersionペインの、先ほどpushしたハッシュをクリックすると、ビルド済みのページを閲覧することができました。右の方のブランチ名をクリックすると、ビルドログを閲覧できるようです。

```
2026-07-21T02:32:15.629Z	Initializing build environment...
2026-07-21T02:32:17.922Z	Success: Finished initializing build environment
2026-07-21T02:32:18.646Z	Cloning repository...
2026-07-21T02:32:20.773Z	Restoring from dependencies cache
2026-07-21T02:32:20.774Z	Restoring from build output cache
2026-07-21T02:32:20.776Z	Detected the following tools from environment: yarn@4.9.1, nodejs@22.16.0
2026-07-21T02:32:20.914Z	Installing project dependencies: yarn
  :
2026-07-21T02:32:27.984Z	Executing user build command: yarn docs:build
  :
2026-07-21T02:32:39.458Z	Executing user deploy command: npx wrangler deploy
  :
2026-07-21T02:32:48.543Z	Detected Project Settings:
2026-07-21T02:32:48.543Z	 - Worker Name: mitomein
2026-07-21T02:32:48.543Z	 - Framework: Static
2026-07-21T02:32:48.543Z	 - Build Command: yarn run docs:build
2026-07-21T02:32:48.544Z	 - Output Directory: docs/.vitepress/dist
  :
2026-07-21T02:32:48.549Z	📄 Create wrangler.jsonc:
2026-07-21T02:32:48.549Z	  {
2026-07-21T02:32:48.549Z	    "$schema": "node_modules/wrangler/config-schema.json",
2026-07-21T02:32:48.549Z	    "name": "mitomein",
2026-07-21T02:32:48.549Z	    "compatibility_date": "2026-07-21",
2026-07-21T02:32:48.549Z	    "observability": {
2026-07-21T02:32:48.549Z	      "enabled": true
2026-07-21T02:32:48.549Z	    },
2026-07-21T02:32:48.549Z	    "assets": {
2026-07-21T02:32:48.554Z	      "directory": "docs/.vitepress/dist"
2026-07-21T02:32:48.554Z	    },
2026-07-21T02:32:48.554Z	    "compatibility_flags": [
2026-07-21T02:32:48.554Z	      "nodejs_compat"
2026-07-21T02:32:48.554Z	    ]
2026-07-21T02:32:48.555Z	  }
  :
2026-07-21T02:33:01.495Z	[build] Running: yarn run docs:build
  :
2026-07-21T02:33:13.732Z	🌀 Building list of assets...
2026-07-21T02:33:13.735Z	✨ Read 194 files from the assets directory /opt/buildhome/repo/docs/.vitepress/dist
2026-07-21T02:33:13.817Z	🌀 Starting asset upload...
2026-07-21T02:33:15.577Z	🌀 Found 182 new or modified static assets to upload. Proceeding with upload...
  :
2026-07-21T02:33:17.530Z	✨ Success! Uploaded 182 files (1 already uploaded) (1.95 sec)
  :
2026-07-21T02:33:20.063Z	Deployed mitomein triggers (1.06 sec)
2026-07-21T02:33:20.064Z	  https://mitomein.zundan-cloudflare.workers.dev
  :
2026-07-21T02:33:24.555Z	✨ Success! Build completed.
  :
```
