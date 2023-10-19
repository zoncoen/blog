+++
title = "Gingerを使って英文校正を行うSublime Textプラグインをつくった"
date = "2013-08-11T00:00:00+09:00"
aliases = ["blog/2013/08/11/plugin-to-check-grammar-by-ginger-for-sublime-text-2"]
author = "zoncoen"
categories = ["programming"]
tags = ['text editor']
+++

去年から[Sublime Text](http://www.sublimetext.com/)というテキストエディタを使っています．UIが綺麗で使い方も分かりやすく，Goto Anythingで素早くファイル移動が行えるなど様々な利点がありますが，個人的にはプラグインによる拡張性が一番の魅力だと思っています．様々な人がプラグインを公開しており，プラグインによってテキストエディタでありながらIDEのような便利な機能を実現できます．プラグインはPythonで簡単に作成できるので，自分も何かネタがあれば一度作成してみたいなぁと思っていました．

そして先日こんな記事を読みました．

[Ginger API を試してみた - にひりずむ::しんぷる](http://blog.livedoor.jp/xaicron/archives/54466736.html)

簡単に要約すると[Ginger](http://www.getginger.jp/)という自動で英文チェックをしてくれるWebサービスがあるのですが，そのサービスのAPIが非公式ではありますが存在するということでした．これはいいなーと思ったので，今回よい機会だとSublime Text上でAPIを叩いて英文チェックを行うプラグインを練習がてら作成してみました．コードは[Github](https://github.com/zoncoen/Sublime2Ginger)上に公開しています．

[Sublime2Ginger - Github](https://github.com/zoncoen/Sublime2Ginger)

<!--more-->

導入方法
----------

**Package Controlを使う:** レポジトリに[https://github.com/zoncoen/Sublime2Ginger](https://github.com/zoncoen/Sublime2Ginger)を追加し，`Package Control: Install Package`からSublime2Gingerをインストールすれば導入完了です．

**Gitを使う:** Sublime TextのPackagesディレクトリにレポジトリを`git clone`します．
{{< highlight sh >}}
$ git clone https://github.com/zoncoen/Sublime2Ginger.git
{{< /highlight >}}
デフォルトのPackagesディレクトリは以下の場所にあります．

- **OSX:** ```~/Library/Application Support/Sublime Text 2/Packages/```
- **Linux:** ```~/.config/sublime-text-2/Packages/```
- **Windows:** ```%APPDATA%/Sublime Text 2/Packages/```

使い方
----------

![Sublime2Ginger example](/images/Sublime2Ginger-example.gif)

コマンドパレットから`Sublime2Ginger: Grammar Check`を実行すると，現在のカーソル行の英文校正が行われます．デフォルトではショートカットとして`Ctrl+Shift+G`が割り当てられているので，ショートカットから実行することもできます．

またデフォルトでは実行すると自動で校正結果が本文に反映されますが，`Preferences->Package Settings->Sublime2Ginger->Settings - User`からUser Settingsファイルを開き，
{{< highlight json >}}
{ "auto_replace" : false }
{{< /highlight >}}
とすると自動置換は行われず，校正結果がアウトプットパネルに表示されるだけになります．

おわりに
----------

今回初めてSublime Textのプラグインを作ってみましたが，Pythonで簡単に書けるので作成自体はそんなに難しくないと感じました．皆さんも自分でプラグインを作成して，さらに快適な環境を整えてみてはいかがでしょうか :)

Reference
----------

- [Ginger API を試してみた - にひりずむ::しんぷる](http://blog.livedoor.jp/xaicron/archives/54466736.html)  
- [公式API Reference](http://www.sublimetext.com/docs/2/api_reference.html)  
- [How to Create a Sublime Text 2 Plugin | Nettuts+](http://net.tutsplus.com/tutorials/python-tutorials/how-to-create-a-sublime-text-2-plugin/)
