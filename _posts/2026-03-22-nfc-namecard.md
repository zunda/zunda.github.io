---
layout: post
title:  "NFCタグを名刺にする"
date:   2026-03-22 16;00:00 -1000
categories: NFC
---

僕は名札にアイコン、メールアドレス、OpenGPG鍵の指紋、[ホームページのURL](https://zunda.ninja)の他、ホームページのURLをQRコードにしたものを掲載しています。ある日、NFCタグも用意すると携帯電話のカメラで撮影しなくてもホームページを訪問してもらえるのではないかと思い立ちました。

ホームページのURLを書き込んだNFCタグは付属の金属リングで名札の紐に取り付けました。下記の写真では左上に写っています。

![](/assets/2026-03-22-namecard.jpg)

[Amazonで売られているNFCタグ](https://www.amazon.com/dp/B0FVFCDWK6)を購入します。届いたNFCタグをそのまま携帯電話に近づけても、携帯電話は反応しません。

上記のAmazonのページで紹介されていたアプリケーション[NFC Tools](https://play.google.com/store/apps/details?id=com.wakdev.wdnfc)を、手元のAndroidの携帯電話(Pixel 9a)にインストールし起動します。Readタブが選択された状態でNFCタグを携帯電話の背面に近づけると、NFCタグとしての情報が得られるようです。

![](/assets/2026-03-22-read.png)

| 項目 | 内容 |
|---|---|
| Tag type | ISO 14443-3A, NXP - Mifare Ultralight |
| Technologies available | NfcA, Ndef |
| ATQA | 0x0044 |
| SAK | 0x00 |
| Data format | NFC Forum Type 2 |
| Size | 0 / 492 Bytes |
| Writable | Yes |
| Can be made Read-Only | Yes |

Writeタブを選択し、Add a recordボタンをタップし、URL / URIメニューをタップし、URLを入力します。Writeボタンをタップし、NFCタグを携帯電話の背面に近づけると、指定したURLがNFCタグに書き込まれます。

URLを書き込んだNFCタグをアンロックされた携帯電話の背面に近づけると、ブラウザが開き、URLの内容が表示されます。
