---
layout: post
title:  "bashスクリプトで子プロセスにSIGTERMを転送する"
date:   2026-01-29 16:30:00 -1000
categories: bash
---

HerokuというPlatform as a Service (PaaS)ではコンテナの停止時に[コンテナ内のすべてのプロセスにSIGTERMを送ります](https://devcenter.heroku.com/articles/dyno-shutdown-behavior#sigterm-signal)が、ナウでヤングなDockerやk8sなどでは親プロセスのみにSIGTERM送るのが一般的なのだそうです。このような状況でも子プロセスにSIGTERMを転送してくれるbashスクリプトを書きます。

```shell
#!/bin/bash
bundle exec puma -C config/puma.rb&
bundle exec bin/jobs&
cpids=`pgrep -P $$`;
trap 'for pid in $cpids; do kill -TERM $pid; done' SIGTERM;
wait -n;
kill -TERM -$$;
wait
```

上記のbashスクリプトは、PumaとSolid Queue(`bin/jobs`コマンド)を子プロセスとして起動して、

- 自スクリプトを実行しているbashプロセスがSIGTERMを受けた、
- 自スクリプトを実行しているbashプロセスと子プロセスがSIGTERMを受けた、あるいは、
- いずれかの子プロセスが何らかの理由で停止した

時に、

1. すべての子プロセスにSIGTERMを送って、
1. すべての子プロセスが停止したら
1. 自スクリプトを実行しているbashプロセスを停止する

ようになっているはずです。

## 自スクリプトを実行しているbashプロセスのIDを得る
bashスクリプト内の`$$`パラメータは、それを実行しているbashプロセスのIDに展開されます。

## 子プロセスのIDを列挙する
シグナルを転送する先のプロセスIDを得るために、`pgrep`コマンドを利用します。`-P`オプションを渡すと指定したプロセスの子プロセスを列挙してくれます。`man pgrep`より:

```
-P, --parent ppid,...
       Only match processes whose parent process ID is listed.
```

上記のスクリプトでは、得られたプロセスIDの一覧をシェル変数に格納します。

## シグナルを受けた時の動作を指定する
`trap`組み込みコマンドでスクリプトを実行しているbashプロセスがシグナルを受け取った時の動作を指定できます。文字列として渡した実行内容をシグナルを受け取った時に展開するようです。

上記のスクリプトでは、得られたプロセスIDの一覧を展開します。

## 子プロセスの終了を待つ
`wait`組み込みコマンドで子プロセスの終了を待つことができます。`-n`オプションを付けるといずれかの子プロセスが終了するまでブロックします。オプションを付けないと全ての子プロセスが終了するまでブロックします。

## 残っている子プロセスにシグナルを送る
`kill`コマンドにプロセスIDに負号を付けて指定することで、そのプロセスIDをリーダーとする[プロセスグープ](https://ja.wikipedia.org/wiki/%E3%83%97%E3%83%AD%E3%82%BB%E3%82%B9%E3%82%B0%E3%83%AB%E3%83%BC%E3%83%97)の全てのプロセスにシグナルを送ることができます。

上記のスクリプトでは、SIGTERM以外のきっかけでいずれかの子プロセスが停止した場合に、他の子プロセスにSIGTERMを送って停止させます。
