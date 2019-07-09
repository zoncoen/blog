+++
title = "Go で HTTP/2 最速実装やってみた"
date = "2014-11-03"
aliases = ["blog/2014/11/03/minimum-http2"]
tags = ['Go']
+++

すでに 2 ヶ月も経過してますが、[http2 ハッカソン #3](http://http2study.connpass.com/event/8151/) に参加しました。
僕は初心者枠で参加したのですが、初心者向けに HTTP/2 最速実装の解説発表がありました。
HTTP/2 最速実装とは、複雑な機能を省略してできるだけ簡単に HTTP/2 っぽいものを実装するというものです。
参加した時に途中まで書いて放置していたのですが、今回 [HTTP/2 Conference](http://http2study.connpass.com/event/9209/) に向けて一応動くようにしてみました。

<!--more-->

## HTTP/2 最速実装について

基本的には [@syu_cream](https://twitter.com/syu_cream) さんの資料を参照すると良いと思います。

<script async class="speakerdeck-embed" data-id="a13eabc017a10132897d326a9d0b610b" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

あとは[ドラフト](https://tools.ietf.org/html/draft-ietf-httpbis-http2-14)。[日本語訳](http://summerwind.jp/docs/draft-ietf-httpbis-http2-14/)もあります。

一応簡単に言葉で説明すると、

1. プロトコルネゴシエーションは相手が HTTP/2 が喋れること前提にサボる
2. SETTINGS FRAME での設定はしない、全部読み飛ばす
3. HPACK での HEADER 圧縮は Literal Header Field without Indexing を利用（ハフマン符号化、インデキシングを行わない）

という感じでめんどくさいところは全部省略してるって感じですｗ

## 自分の実装について

Go の HTTP/2 実装は [@Jxck\_](https://twitter.com/Jxck_) さんの[実装がすでにある](https://github.com/Jxck/http2)のですが、自分が Go を書きたかったので今回は Go で書きました。
一応 [GitHub](https://github.com/zoncoen/minimum_http2) にあげてあります。
突貫で書いてとりあえず動くようにしたという感じで、コードカオスなのでもう触りたくない感じですが…

今回最速実装をやってみて HTTP/2 がどんな感じのものか少し理解が深まった気がします。
みなさんも HTTP/2 最速実装、ぜひ挑戦してみてはいかがでしょうか :)

次は Jxck さんの実装読みながら HPACK の実装でもやってみようとおもいます :D
