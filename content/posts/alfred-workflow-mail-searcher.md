+++
title = "Gmail ライクにメールを検索する Alfred Workflow をつくった"
date = "2014-02-16T00:00:00+09:00"
aliases = ["blog/2014/02/16/alfred-workflow-mail-searcher"]
author = "zoncoen"
categories = ["programming"]
tags = ["perl", "alfred", "tool"]
+++

Mac ユーザの皆さま，[Alfred](http://www.alfredapp.com/) は使っておられますでしょうか？
ご存知の方も多いと思いますが，Alfred は Mac で使えるコマンドライン型ランチャーです．
基本的には標準で搭載されている Spotlight でも同じようなことができますが，Alfred の方が拡張性も高く使いやすいと思います．
特に [Powerpack](http://www.alfredapp.com/powerpack/) という有料パックを購入すると使えるようになる Workflow という機能がめちゃくちゃ便利です．
Workflow とは Alfred からスクリプトを実行する機能で，例えば Alfred から VM を操作したり，Evernote を検索したりすることができます．
Workflow は簡単に公開することができるので，様々な Workflow が公開されています．

(参考: [Alfred 2のユーザ体験をロケットスタートで始めるための13の偉大なWorkflow](http://veadardiary.blog29.fc2.com/blog-entry-4425.html)，[16 Great Workflows to Jumpstart Your Alfred Experience](http://mac.appstorm.net/roundups/utilities-roundups/16-great-workflows-to-jumpstart-your-alfred-experience/)，[Alfred 2 Workflow List](http://www.alfredworkflow.com/))

個人的には Mac を使う理由の1つと言ってもよいほど快適です．
使ってない人はぜひ一度試してみてください（Alfred の紹介記事は検索すればたくさんヒットするので使い方等は割愛します）．

で，ヘビーユーザーな自分はメールの検索も Alfred でやりたかったので，今回 Alfred で Mail.app 内のメールを検索する Workflow をつくったという話です．

<img src="/images/mail-searcher.gif" class="image">

<!--more-->

導入
----------

以下のリンクから`MailSearcher.alfredworkflow`をダウンロードして，ダブルクリックすれば勝手にインポートされます．

- [Download](https://raw.github.com/zoncoen/alfred- workflow- mail- searcher/master/MailSearcher.alfredworkflow)

ソースは以下のレポジトリにあります．

- [zoncoen/alfred-workflow-mail-searcher - Github](https://github.com/zoncoen/alfred-workflow-mail-searcher)

当然 Powerpack 導入済の Alfred が必要です．
あとこの Workflow は あくまで Mail.app 内のメール検索なので，Thunderbird など他のメールクライアントを使ってる場合は使えないです...

使い方
----------

`mls {query}`で`{query}`を件名か本文に含むメールのリストを Alfred 上に表示，Enter を押すとそのメールを開きます．

ちなみに以下に示すような，Gmail の Advanced Search Operator の一部が使えます．

Operator|Definition|Examples
:----|:----|:----
from:|Used to specify the sender.|Example: from:amy<br>Meaning: Messages from Amy
to:|Used to specify a recipient.|Example: to:david<br>Meaning: All messages that were sent to David
subject:|Search for words in the subject line.|Example: subject:dinner<br>Meaning: Messages that have the word "dinner" in the subject
is:starred<br>is:unread<br>is:read|Search for messages that are starred, unread, or read.|Example: is:read is:starred from:David<br>Meaning: Messages from David that have been read and are marked with a star

(From [Advanced search - Gmail Help](https://support.google.com/mail/answer/7190?hl=en).)

`mls from:`と入力するとアドレス一覧が出てくるなど，補完機能もついているので TAB で補完できます．

実装について
----------

Perl スクリプトから Mail.app の sqlite DB を見てるだけです．
Mail.app で開く部分は AppleScript でやってます．
全文検索を`LIKE`演算子でやってるのでデータが多いと結果が返ってくるのが遅い... FTS 3 + MeCab とか使ったらいいのでしょうが，DBへの変更は Mail.app がやるわけでどうするのが賢いのか思いついてない感じです．
そのうち何とかせねば...

まとめ
----------

自分が使いたかったので作りましたが，使ってくれる方がいらっしゃれば幸いです．
プルリク等お待ちしてます．

皆さんも Workflow を自作して素敵な Alfred ライフを実現しましょう :)
