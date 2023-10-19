+++
title = "初心者がGoでpercolを実装してみた"
date = "2014-06-06T00:00:00+09:00"
aliases = ["blog/2014/06/06/percol-in-golang"]
author = "zoncoen"
categories = ["programming"]
tags = ['go', 'tool']
+++

percol って何？って方は以下の記事をどうぞ。

[ライフチェンジングな percol と autojump の紹介](http://blog.zoncoen.net/blog/2014/01/14/percol-autojump-with-zsh/)

最近 Go を勉強していて、[ヒカルの go (hikarie.go)](http://connpass.com/event/6579/)の LT 応募したのもあって、自分が普段から使っている percol を練習がてら Go で実装してみました。

<!--more-->

## tl;dr

理由はよく分かりませんが、先々週くらいから急に percol が有名になったような感じで、他の人も作りそうだなーとか思ってたら案の定 [@lestrrat](https://twitter.com/lestrrat) さんが書いているみたいです。
すでに書いてたので一応動くようにはして記事も書きましたが、勢いで書いた全く golang っぽくない汚いコードなので、実際は [@lestrrat](https://twitter.com/lestrrat) さんが実装された go-percol を使うのがよいと思います！

{{< tweet user="mattn_jp" id="474708586770079744" >}}

{{< tweet user="lestrrat" id="474708853200670722" >}}

{{< tweet user="lestrrat" id="475843757481275393" >}}

{{< tweet user="lestrrat" id="475932471721086976" >}}

## 使い方

ソースは GitHub にあるので、

[zoncoen/fourmi](https://github.com/zoncoen/fourmi)

`$ go get github.com/zoncoen/fourmi`

これで入ります。go get 便利。

使い方は percol と一緒で、ファイル名を引数に与えるか、

`$ fourmi /var/log/syslog`

パイプで渡してやります。

`$ ps aux | fourmi`

ちなみに `fourmi` ってのは蟻のフランス語で、渋谷の[ありんこオフィス](http://www.ants-office.com/)でこれのコード書きはじめたからというだけです。（テキトー）

## 初心者の些細なギモン

- Go のファイル分割の基準がよくわからない

  - クラスとかないし長くなり過ぎないようにテキトーに分ける？よくわからん

- 構造体名について
  - export するやつだけキャメルケースで書く？それとも基本的に構造体はキャメルケース？よくわからん

きちんと調べればわかるのかもしれませんが、少し探した程度では指針となりそうな情報が見つけられませんでしたので優しい方教えてください。

## まとめ

percol クッソ便利なので普及してきて嬉しい限りです（何様）

とりあえずもう少し Go の書き方分かってきたらこのクソコード何とかして migemo の Go 実装書いてこいつにブチ込みたいなぁなんて思ってます。思ってるだけで実際やるか（やれるか）は知りません。
