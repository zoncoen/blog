+++
title = "ライフチェンジングなpercolとautojumpの紹介"
date = "2014-01-14"
aliases = ["blog/2014/01/14/percol-autojump-with-zsh"]
Categories = []
+++

ご存知な方も多いかと思いますが，percolとautojumpはライフチェンジングなシロモノですよという話です．

<!--more-->

percol
----------

[percol](https://github.com/mooz/percol)は，標準入力で与えたものを行単位でインタラクティブに絞り込むことができるコマンドです．
簡単に言うとemacsのanything.elやvimのunite.vimのコマンドライン版といった感じ．

<h3>導入方法</h3>

[README.md](https://github.com/mooz/percol/blob/master/README.md)の通りですが，以下のようにすれば導入できます．

{{< highlight text >}}
$ git clone git://github.com/mooz/percol.git
$ cd percol
# python setup.py install
{{< /highlight >}}

<h3>簡単な使い方</h3>

ファイルを指定してやるとそのファイルを行単位でインタラクティブに絞り込めます．

{{< highlight text >}}
$ percol /var/log/syslog
{{< /highlight >}}

パイプを使うと他のコマンドの実行結果も絞り込めます．

{{< highlight text >}}
$ ps aux | percol
{{< /highlight >}}

アイデアしだいで色々な使い方ができますね！

<h3>オススメ利用法</h3>

zshのコマンド履歴をpercolで絞り込むの超オススメです（というか僕は現状これにしか使っていない）．
以下のように`.zshrc`に追記します．

{{< highlight sh >}}
function exists { which $1 &> /dev/null }

if exists percol; then
    function percol_select_history() {
        local tac
        exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
        BUFFER=$(history -n 1 | eval $tac | percol --query "$LBUFFER")
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }

    zle -N percol_select_history
    bindkey '^R' percol_select_history
fi
{{< /highlight >}}

すると`Ctrl+R`でのコマンド履歴検索がpercolのインターフェースで行えます．
たまーに使うコマンドとかさっと叩けます．
便利！！✌('ω'✌ )三✌('ω')✌三( ✌'ω')✌

<img src="/images/percol.png" class="image">

[追記 (2014-05-13)]

oh-my-zsh を使っていると勝手に `alias history='fc -l 1'` されてしまってこのコードが動かないようです。
その場合は L7 を `BUFFER=$(fc -l -n 1 | eval $tac | percol --query "$LBUFFER")` とすると正常に動作します。
というか `history` って `fc -l` の 単なる alias だったんですね！学びがある（かなり）

{{< /highlight >}}
$ man zshbuiltins

...snip...

    history
        Same as fc -l.
{{< /highlight >}}

Akihiro HARAI さんコメントしていただきありがとうございました！

[ここまで追記]

ちなみに以下のように`$HOME/.percol.d/rc.py`に書いておくとEmacsライクなショートカットが使えてより便利です．

{{< highlight sh >}}
# Emacs like
percol.import_keymap({
    "C-h" : lambda percol: percol.command.delete_backward_char(),
    "C-d" : lambda percol: percol.command.delete_forward_char(),
    "C-k" : lambda percol: percol.command.kill_end_of_line(),
    "C-y" : lambda percol: percol.command.yank(),
    "C-a" : lambda percol: percol.command.beginning_of_line(),
    "C-e" : lambda percol: percol.command.end_of_line(),
    "C-b" : lambda percol: percol.command.backward_char(),
    "C-f" : lambda percol: percol.command.forward_char(),
    "C-n" : lambda percol: percol.command.select_next(),
    "C-p" : lambda percol: percol.command.select_previous(),
    "C-v" : lambda percol: percol.command.select_next_page(),
    "M-v" : lambda percol: percol.command.select_previous_page(),
    "M-<" : lambda percol: percol.command.select_top(),
    "M->" : lambda percol: percol.command.select_bottom(),
    "C-m" : lambda percol: percol.finish(),
    "C-j" : lambda percol: percol.finish(),
    "C-g" : lambda percol: percol.cancel(),
})
{{< /highlight >}}

autojump
----------

[autojump](https://github.com/joelthelion/autojump)は，`cd`で移動したディレクトリを記録して，カレントディレクトリに関係なく過去に移動したディレクトリに移動できるコマンドです．

<h3>導入方法</h3>

[README.md](https://github.com/joelthelion/autojump/blob/master/README.md)を参考に，以下のようにすれば導入できます．

{{< highlight text >}}
$ git clone git://github.com/joelthelion/autojump.git
$ cd autojump
# ./install.py
{{< /highlight >}}

MacならHomebrewでもインストール可能です．

{{< highlight text >}}
$ brew install autojump
{{< /highlight >}}

`.zshrc`に以下のように書いておけば`<TAB>`で補完が効くようになります．

{{< highlight sh >}}
[[ -s /usr/share/autojump/autojump.zsh ]] && . /usr/share/autojump/autojump.zsh

# for homebrew
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh
{{< /highlight >}}

使い方
----------

インストールすると，`cd`で移動したディレクトリが記録されていきます．
導入後に移動したディレクトリであれば，`j`コマンドで素早く移動できます．
例えばTerminal上で以下のように入力して`<TAB>`を押すと，fooが含まれる移動したことがあるディレクトリ一覧が表示され，`<ENTER>`でそのディレクトリに移動します．

{{< highlight text >}}
$ j foo
{{< /highlight >}}

カレントディレクトリに関係なく移動できるのが最高です．
便利！！✌('ω'✌ )三✌('ω')✌三( ✌'ω')✌

まとめ
----------

一年以上使ってますがpercolもautojumpもチョー便利ですね．オススメです．

