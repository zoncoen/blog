+++
title = "今回のISUCON3本戦で我々は，いや，今回も...くっ...なんの成果も!!得られませんでした!! #isucon"
date = "2013-11-14"
aliases = ["blog/2013/11/14/isucon3-final"]
Categories = []
+++

\# タイトルはネタです[^fn1]．タイトルには若干語弊があって，実際はとてもよい経験をさせていただけたのでそれだけでも十分"成果"はありました．実力不足で"結果"が出せなかっただけです．

[@yunazuno](https://twitter.com/yunazuno)，[@nerbaraki_m2](https://twitter.com/nerbaraki_m2)とともに，[ISUCON](http://isucon.net/)の予選に学生枠で参加して惨敗した話を前に[書いた]({{ root_url }}/blog/2013/10/07/participation-of-the-isucon3-preliminary/)のですが，上位のチームが再現確認でFailしたようで学生枠[繰り上がりで本戦に出場](http://isucon.net/archives/32951235.html)できてしまいました．

予選が終わったあとに，楽しかったしスコア伸ばせなかったのも悔しさしかないし，本戦も出場したかったナーなどと3人でほざいてたら現実になりました．

<!--more-->

前日までにやったこと
----------

僕はFluentd + ElasticSerch + Kibana3でNginxのアクセスログやWebAppのプロファイリング結果を集計して可視化できるようにEC2にインスタンスつくって準備したりしてました．詳しくは下のエントリにあります(宣伝)．

- [Fluentd + ElasticSearch + Kibana3で簡単に様々なログを可視化・解析する]({{ root_url }}//blog/2013/11/11/logging-system-with-fluentd-elasticsearch-kibana3/)
- [WerkzeugでFlaskを使ったPythonのWebAppをプロファイリングする]({{ root_url }}/blog/2013/11/12/werkzeug-wsgi-application-profiler/)
- [Fluent-plugin-werkzeug-profilerを書いた](2013/11/13/fluent-plugin-werkzeug-profiler/)

余談ですが，僕らは奈良から遠征だったのでホテルをとろうとしたところ，いつも以上に渋谷周辺のホテルが埋まってる気がしました．他にもなにかイベントがあったりしたのでしょうか？

当日やったこと
----------

<h3>受付</h3>

本戦は予選TOP20組と学生枠3組，選抜2組の25組だったのですが，9:50くらいにヒカリエ11階にいったらすでにかなりの人数の参加者が揃っていました．エンジニアは朝弱いというのは迷信だったか...

<img src="/images/isucon3-nameplate.jpg" class="image">

<h3>本戦開始まで</h3>

本戦が始まるまでそれなりに時間があったのですが，あまりやれることもなく適当に参考になりそうな記事を読み返したりしてました．

<img src="/images/isucon3-line.jpg" class="image">

<h3>本戦開始</h3>

運営の方の挨拶とオープニングムービー．ムービーはしっかり作ってあって面白かったですｗお題は画像を使ったTwitter的なサービス．サーバは5台を好きなように使える．

とりあえず最初は必要なツールを入れたり，バックアップとったり，SupervisorでPythonのWebAppがあがるように設定したりした．ひとまずベンチを回してみると下のような感じのメッセージを吐いてScore:724.1のFail．

{{< highlight console >}}
2013-11-09T12:00:00 [13552] [CRITICAL] status: 500 INTERNAL SERVER ERROR
2013-11-09T12:00:00 [13552] [CRITICAL] POST http://125.6.152.4:8022/icon
2013-11-09T12:00:00 [13552] [CRITICAL] request http://125.6.152.4:8022/icon failed 500 INTERNAL SERVER ERROR
2013-11-09T12:00:26 [13549] [CRITICAL] status: 500 INTERNAL SERVER ERROR
2013-11-09T12:00:26 [13549] [CRITICAL] POST http://125.6.152.4:8022/icon
2013-11-09T12:00:26 [13549] [CRITICAL] request http://125.6.152.4:8022/icon failed 500 INTERNAL SERVER ERROR
{{< /highlight >}}

デフォルトの状態でなんで動かないんだーと悩み続ける事になります...

<h3>昼食</h3>

とりあえず落ち着こうと早々に昼食．とっても美味しかったです．

<img src="/images/isucon3-launch.jpg" class="image">

そして実は当日の朝にフィンランドから帰国した[@yunazuno](https://twitter.com/yunazuno)が関空経由で会場に到着ｗ疲れているとこ頑張って来てもらって若干申し訳なかったですね．

<h3>午後</h3>

WebAppの改善を始めていましたが，未だデフォルトの状態で動かないのなんなんじゃーとそれからも悩んでいました．結論をいうと，ブラウザで開いていたページを閉じたらベンチ通りました．しょうもなさすぎて涙目．

WebAppはサブプロセスでImageMagickをよんでるところをライブラリを使うようにしました．

すると次はこんなエラーに悩むことに．

{{< highlight console >}}
2013-11-09T17:32:25 [64799] [CRITICAL] http://125.6.152.4:8022/icon/9c27bebb6d43c722058cf02abfcdac7ef5e1ba203e176bc928ccb43a24a97911 status failed got: 596 expected: 200
2013-11-09T17:32:25 [64799] [CRITICAL] http://125.6.152.4:8022/image/e4eae20b3af5aee0a74c7a7c2e7ad866c4a898f6df72f7ccdbb305a96ca42f2a?size=s status failed got: 596 expected: 200
2013-11-09T17:32:25 [64799] [CRITICAL] http://125.6.152.4:8022/icon/566c02e3784d6a62fe801524b4a2a6dd928660c9378501139b77233bc256ad2b status failed got: 596 expected: 200
{{< /highlight >}}

Code:596ってなんやねんって感じだったんですが，REST APIのエンドポイントが見つからないってエラーなんですね．エラーが出てるURLを叩くと普通に画像が表示されてなんやねん〜って感じでした．

この件は散々悩んだ挙句，えいやでベンチマークのworkloadをあげてみたら解決しました．理由は未だに理解できてません．わけがわからないよ...

そして最後はIconのDiffエラー...

{{< highlight console >}}
2013-11-09T17:32:11 [64802] [CRITICAL] icon diff > 20% http://125.6.152.4:8022/icon/f101c904d7c8055371a6738ea78322ab600647d92b63d786e15939e4e7464a60
{{< /highlight >}}

これを解決することなくタイムアップで僕らのISUCON3本戦は終わったのでした...

<h3>結果</h3>

結果はもちろんFail．僕らに人権はない．

<h3>懇親会</h3>

懇親会はDATAHOTELさんにピザやKFCをごちそうになりました．ごちそうさまでした！

感想
----------

高速化をほとんどやることなく終わってしまったので予選よりも悔しかったですね．悔しすぎてこの日の夜はビール3.5Lくらい飲みました．学生枠で優勝して交通費の足しにするなど夢のまた夢だった．

優勝したLINE選抜チームさんは流石といった感じでした．ベンチがラウンドロビンで負荷をかける設定だったので，フロントに複数サーバを置くのはなんとなく想像出来ましたが，~~フロント4台+バックにApp1台~~(間違えていたのを訂正していただきましたありがとうございます)という構成は聞いててなるほどなーと思いました．複数サーバの適切な使い方が思いつかないあたり，やはり実務経験が足りない．

{{< tweet 400906312218714112 >}}

このような素晴らしいイベントに僕らのような学生にも参加するチャンスを与えてくださった事に大変感謝しています．LINEさん，カヤックさん，DATAHOTELさんなど運営に関わった皆様ありがとうございました．来年は社会人枠で参加して優勝を目指します！

\# 明日の[ISUCON3反省会](http://www.zusaar.com/event/1737003)参加したかったけど，距離的に参加は難しいので1人でプレモル飲んで反省会します．

[^fn1]: 進撃の巨人ネタですので旬過ぎてる感

