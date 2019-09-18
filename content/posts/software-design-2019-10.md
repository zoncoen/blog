---
title: 'Software Design 2019 年 10 月号に寄稿させていただきました'
date: 2019-09-18T20:43:24+09:00
tags: ['Go', 'book']
---

技術評論社様の [Software Design 2019 年 10 月号](http://gihyo.jp/magazine/SD/archive/2019/201910)に「Go のプラグイン機能でソフトウェアに柔軟な拡張性を」というタイトルで寄稿させていただきました。

<!--more-->

<iframe style="width:120px;height:240px;" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" src="//rcm-fe.amazon-adsystem.com/e/cm?lt1=_blank&bc1=000000&IS2=1&bg1=FFFFFF&fc1=000000&lc1=0000FF&t=zoncoen-22&language=ja_JP&o=9&p=8&l=as4&m=amazon&f=ifr&ref=as_ss_li_til&asins=B07W47BVVC&linkId=e7c9915c7c923d6951d95c62e134e359"></iframe>

Go におけるプラグイン機能の実現方法として、以下の 2 つを利用した方法を解説しました。

- 標準の `plugin` パッケージ
- `hashicorp/go-plugin`

記事に掲載されているサンプルコードは [github.com/zoncoen-sample/software-design-2019-10](https://github.com/zoncoen-sample/software-design-2019-10) に公開しています。

また標準の `plugin` パッケージを実際に利用しているプロダクトとして、私が開発している [scenarigo](https://github.com/zoncoen/scenarigo) を取り上げ、実際のプロダクトでの活用例についても紹介しています。

その他にも絵文字と文字コードの歴史など面白い記事目白押しです。ぜひともよろしくお願いいたします。
