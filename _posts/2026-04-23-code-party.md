---
layout: post
title:  "コード懇親会 at RubyKaigi 2026でdRubyに触る"
date:   2027-04-25 00:00:00 +0900
categories: jekyll update
---

[RubyKaigi 2026](https://rubykaigi.org/2026/)に参加してきました。[2015](https://rubykaigi.org/2015/)以来の現地参加です。RubyKaigiも楽しかったのですが、関連イベントとして開催された[コード懇親会/Code Party(Social Coding) at RubyKaigi 2026](https://andpad.connpass.com/event/385946/)もかなり楽しく、終電の差し迫るなか、勢い余って[ruby/uriへのIssue](https://github.com/ruby/uri/issues/224)を提出してしまったのでした。

## 会場に到着したらRubyをインストールする
RubyKaigiでの作業[^helper]が終わって会場の開始5分前くらいに会場の会議室に到着すると、多くの参加者がわいわい話をしながら軽食を食べていました。みなさんコード懇親会を楽しみにされている雰囲気です。やっぱりみんなコードを書くのだいすきよね。僕も軽食（とくにお寿司がおいしかった！）をいただいて、ラップトップを開いたところで、先日Rubyのリリースがあったのを思い出しました。

```sh
$ brew update ruby-build
$ rbenv install 4.0.3
$ cd ~c/src/local/rk26-code-party
$ rbenv local 4.0.3
```

[^helper]: 今回はRubyKaigiのヘルパーの応募が当たったので、裏方としてかなり楽しませていただいたのでした。

## dRubyでオブジェクトをやりとりする
僕が参加したのは、[作者のsekiさんと一緒にdRubyを触ってみる](TODO)グループで、用意していただいていた[資料](https://www.druby.org/druby-matzyama.pdf)に沿ってdRubyを触っていきます。最近のRubyでは`webrick`がTODOライブラリーからはずれているので、gemとしてインストールします。`Gemfile`は下記のようになりました。

```
source "https://rubygems.org"
gem "drb", "~> 2.2"
gem "webrick", "~> 1.9"
gem "irb", "~> 1.18"
gem "driq", "~> 0.4.3"
```

### MacOS 15.7.5は自分のことをIPv6だと思っている
dRubyでは一部のクラスのオブジェクトのやりとりにサーバが必要なので、ホストとポートを指定して起動するサーバとは別にクライアント側のプロセスでもサーバを起動しておきます。

(サーバ)

```ruby
$ bundle exec irb -r drb
> h = Hash.new
> DRb.start_service('druby://localhost:54000', h)
  :
 @exported_uri=["druby://localhost:54000"],
  :
   @config=
    {tcp_original_host: "localhost",
  :
     tcp_port: 54000},
  :
```

(クライアント)

```ruby
$ bundle exec irb -r drb
> DRb.start_service
  :
 @exported_uri=["druby://::1:49357"],
  :
   @config=
    {tcp_original_host: "",
  :
     tcp_port: 49357},
> h = DRbObject.new_with_uri("druby://localhost:54000")
> h[:greeting] = "Hello, World!"
```

ここでの注目点は、`@exported_uri`が`druby://::1:49357`となっていることでした。URIを指定せずに起動したサーバは、`::1`にバインドしているようです。

### IPv6アドレスのURI
TODO:RFCの再確認 3986か？

[RFC 2732](https://datatracker.ietf.org/doc/html/rfc2732#section-2)によると、ホスト名部がIPv6であるURLではホスト名部を角かっこ(`[]`)で囲う必要があるようですが、上記で` DRb.start_service`が返したオブジェクトでは、`@exported_uri`で`::1`が角かっこに囲まれていません。

ここでdRubyのコードを追ってみます。MacOS 15.7.5上のRuby 4.0.3のdrb 2.2.3です。`@exported_uri`のホスト名部分は下記のメソッドで得ているようです。

(drb/drb.rb)

```ruby
    # Returns the hostname of this server
    def self.getservername
      host = Socket::gethostname
      begin
        Socket::getaddrinfo(host, nil,
                                  Socket::AF_UNSPEC,
                                  Socket::SOCK_STREAM,
                                  0,
                                  Socket::AI_PASSIVE)[0][3]
      rescue
        'localhost'
      end
    end
```

`irb`で試してみると確かに`::1`になるようです。

URIにするコードは下記のようになっていました。たしかに`druby://::1:<ポート番号>`となりそうです。

```ruby
  :
      if ... 
        host = getservername
        soc = open_server_inaddr_any(host, port)
      end
      port = soc.addr[1] ...
  :
      uri = "druby://#{host}:#{port}"
  :
```

このインスタンス変数はdRubyが動作する際に参照されることはなさそうだけれど、なんとなく気持ち悪いのでurl標準ライブラリなどでRFCどおりに整形してもらえばいいだろう。

## 標準ライブラリでIPv6アドレスのURLを整形してもらう


```
$ irb

⢀⡴⠊⢉⡟⢿  IRB v1.18.0 - Ruby 4.0.3
⣎⣀⣴⡋⡟⣻  Type "help" for commands, "help <cmd>" for details
⣟⣼⣱⣽⣟⣾  ~/c/src/local/rk26-code-party

> require 'uri'
> s = URI::Generic.new('https', nil, '::1', 443, nil, '/', nil, nil, nil).to_s
=> "https://::1:443/"
```

ありゃ。角かっこで囲まれていない。パースはできるのかな？

```
> URI.parse(s)
.../4.0.3/lib/ruby/4.0.0/uri/rfc3986_parser.rb:130:in 'URI::RFC3986_Parser#split': bad URI (is not URI?): "https://::1:443/" (URI::InvalidURIError)
```

## 一緒の部屋に居るのすごい
そんなこんなで、気づいたことを口頭でご報告して、uriライブラリについては報告先を推薦していただいて、20分間ほどで[新規のIssue](https://github.com/ruby/uri/issues/224)の提出までさせていただいてしまったのでした。

## TODO
- [ ] URIとURLとの区別
