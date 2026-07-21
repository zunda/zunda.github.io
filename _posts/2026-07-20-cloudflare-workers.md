---
layout: post
title:  "静的サイトをCloudflare Workersで公開する"
date:   2026-07-20 15:00:00 -1000
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
