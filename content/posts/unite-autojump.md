+++
title = "unite-autojumpをつくった"
date = "2014-01-15T00:00:00+09:00"
aliases = ["blog/2014/01/15/unite-autojump"]
author = "zoncoen"
categories = ["programming"]
tags = ["vim"]
+++

この記事は[ Vim Advent Calendar 2013 ](http://atnd.org/events/45072)46 日目の記事になります． # 46 日目とは

私事ですが，諸般の事情によりエディタを Sublime Text から Vim に変えました．
Vim を使い始めて数ヶ月，そろそろプラグインでも作ってみたいなーと思っていたところ，昨年の 12 月に Vim プラグイン読書会なるものが[ Lingr の Vim 部屋](http://lingr.com/room/vim/)にて行われました．

参考: [Vim プラグイン読書会を行いました - C++でゲームプログラミング](http://d.hatena.ne.jp/osyo-manga/20131215/1387115301)

これは！と思って参加したのですが，そういえば普段お世話になっている unite.vim の拡張方法とか理解してないよなーってなりました．
そこで勉強がてら Vim から unite.vim のインターフェースを通して[ autojump ](https://github.com/joelthelion/autojump)を使う的な簡単プラグインを作ってみました．

[zoncoen/unite-autojump - Github](https://github.com/zoncoen/unite-autojump)

<!--more-->

[autojump ](https://github.com/joelthelion/autojump)は，`cd`で移動したディレクトリを記録して，カレントディレクトリに関係なく過去に移動したディレクトリに移動できるコマンドです．
導入などは以下参照．

[ライフチェンジングな percol と autojump の紹介 - 404 Engineer Logs](http://blog.zoncoen.net/blog/2014/01/14/percol-autojump-with-zsh/)

今回は普段 Terminal 上で使い倒してる`autojump`を Vim から使えるようにしてみました．

## 導入

[NeoBundle ](https://github.com/Shougo/neobundle.vim)で簡単にインストール．

{{< highlight vim >}}
NeoBundle 'zoncoen/unite-autojump'
{{< /highlight >}}

当然ですが unite.vim と autojump が必要です．

## 使い方

Vim 上で以下のコマンドを実行すると，unite.vim のインターフェースで autojump ライクな機能が使えます．

{{< highlight text >}}
:Unite autojump
{{< /highlight >}}

`.vimrc`に以下のように書いておけば，`:j`で呼び出せて便利（かもしれない）．

{{< highlight vim >}}
nnoremap :j :<C-u>Unite autojump<CR>
{{< /highlight >}}

## 簡単な解説

unite source と unite action を追加する簡単なプラグインです．
autojump は過去に移動したディレクトリ履歴と各ディレクトリの重みが`autojump --stat`で取得できるので，その結果を unite.vim に渡しています．

{{< highlight vim >}}
let s:autojump_command = 'autojump -s'

let s:unite_source = {
\ 'name': 'autojump',
\ 'description': 'candidates from autojump database',
\ 'default_action' : 'cd_autojump',
\ }

function! s:unite_source.gather_candidates(args, context)
let l:directories = reverse(split(unite#util#system(s:autojump_command),"\n"))[7:]
return map(directories,
\ '{
\ "word": split(v:val, "\t")[1],
\ "source": "autojump",
\ "kind": "cdable",
\ "action\_\_directory": split(v:val, "\t")[1],
\ }')
endfunction

function! unite#sources#autojump#define()
return exists('s:autojump_command') ? s:unite_source : []
endfunction
{{< /highlight >}}

また，`cd`したらその結果を`autojump --add`で autojump のデータベースに反映する`cd_autojump`という unite action を定義しています．

{{< highlight vim >}}
let s:autojump_add_command = 'autojump -a %s'

let s:action = {
\ 'description': 'change current working directory with adding path to autojump database',
\ 'is_selectable': 0,
\ }

function! s:action.func(candidate)
if a:candidate.action**directory != ''
execute g:unite_kind_cdable_cd_command a:candidate.action**directory
echo a:candidate.action**directory
call unite#util#system(printf('autojump -a %s', a:candidate.action**directory))
endif
endfunction

call unite#custom#action('cdable', 'cd_autojump', s:action)
{{< /highlight >}}

## TODO

Terminal 上での`cd`コマンドのように，Vim 上での`:cd`でも移動先のパスを autojump のデータベースに反映できたらなぁと思ってます．
`:cd`に hook して処理を行うことができればよさそう（ autocmd のオレオレ event を作る？）．
Vim 力高い方アドバイスお願いします :-)

## まとめ

初 Vim プラグイン作成でしたが，autojump に便利オプションがあったため割と簡単にできてしまいました．
unite source や unite action の作り方は，unite.vim の`:help`や ujihisa さんの[ unite-locate ](https://github.com/ujihisa/unite-locate)を参考にさせていただきました．

あと余談ですが，vim script のテストに関して現時点でのベストプラクティスとかはあるんでしょうか？
テストフレームワークがたくさんあって悩ましい...
