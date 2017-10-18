+++
title = "Gotanda.pm #1 に参加してきました"
date = "2014-06-18"
slug = "2014/06/18/gotanda-pm-01"
Categories = []
+++

時間がたってしまいましたが、6/11に [Gotanda.pm Perl Technology Conference #1](http://www.zusaar.com/event/10397006) に参加してきました。

<!--more-->

## Talks

### App::RunCronもしくはGitMasterData (@songmuさん)

- [資料](http://songmu.github.io/slides/gotandapm1/#0)

便利なRuncronとGitMasterDataのお話でした。

他のDBMS用にDDLを変換する SQL::Translator はかなりヤバいですが、SQL::Translator::Diff は更に2つのDDL間の差分を取得できるということでなんかもう色々とすごい。
GitDDLはそれを利用して、Gitのブランチを変えた時なんかに現在のSQLとの差分を取得して当て込む事ができる。
で、GitMasterDataはマスタデータの管理にもその考え方を持ち込んだ感じということだと思う（たぶん）

とりあえずデータベースの設計してDDL書いて性能とか測りながら設計をブラッシュアップしていくみたいなことをこの間研修でもやっていたので、データベース設計初心者な僕の役に立ちそう！という気がしています。
そのうち業務等でもお世話になりそうです！

### 新卒研修を支える技術 (@\_\_papix\_\_さん)

GaiaXさんでの新卒研修のお話でした。

色々ためになりそうな開発方法などの話もあったので、資料あげていただけないかなーと思っております（ﾁﾗｯ

余談ですが、[Daiku](https://github.com/tokuhirom/Daiku)を使ってるという話の時のTLはこんな感じであったことを記録しておきます。

{% oembed https://twitter.com/tokuhirom/status/476677399820509184 %}

{% oembed https://twitter.com/songmu/status/476677694818496513 %}

{% oembed https://twitter.com/moznion/status/476677566187577344 %}

### webの属人性排除を支える技術 (@saisa6153さん)

- [資料](https://speakerdeck.com/saisa6153/individual-skills)
- [Blog記事](http://saisa.hateblo.jp/entry/2014/06/12/014621)

コードの属人性をなんとかしたいという発表でした。

Podがコードと乖離してるだとか、使ってるモジュールが統一されていないだとか、テストが書かれていないだとかもろもろの問題を、属人性を排除することでなんとかしたいとのことでした。
僕はまだ研修中で実際に業務でチーム開発を経験していないのですが、この辺の話はどこでも多かれ少なかれ問題になりそうというのは容易に想像できます。

以下知見です。

{% oembed https://twitter.com/tokuhirom/status/476680087064948736 %}

{% oembed https://twitter.com/tokuhirom/status/476680505199316992 %}

{% oembed https://twitter.com/songmu/status/476682870442848256 %}

## 懇親会

懇親会では色々な人の話を聞くことができて、自分が気になってたことへのアドバイスなんかも頂けてだいぶ有意義な感じでした。

なんか終わりがけに諸先輩方からものすごいいじられ方をした気がしますが、

{% oembed https://twitter.com/ryopeko/status/476744530763333633 %}

とのことなのでパールの世界に入門成功しただけのようです（違う

主催者の[@karupanerura](https://twitter.com/karupanerura)さんありがとうございました！
9月に予定されている第2回も楽しみにしています！
