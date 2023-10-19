+++
title = "Dashのスニペット機能の紹介"
date = "2014-07-07T00:00:00+09:00"
aliases = ["blog/2014/07/07/dash-snippet"]
author = "zoncoen"
categories = ['tips']
tags = ['tips']
+++

[Dash](https://itunes.apple.com/jp/app/dash-docs-snippets/id458034879) という Mac 用のアプリケーションがありますが、それのスニペット機能が個人的にイケてますよという話です。

<!--more-->

## 発端

{{< tweet user="Iketaki" id="486017174163574786" >}}

（ショートカットではないけど…）

## 導入

[App Store](https://itunes.apple.com/jp/app/dash-docs-snippets/id458034879) にあります。（雑）

## 使い方

### 1. シンプルなスニペットの例

まずは単純なスニペットの登録をしてみます。
Dash を起動して下の画像で示している＋ボタンから "New Snippet" を選択します。

<img src="/images/dash-snippet/default.jpg" class="image">

そして以下のように入力してみましょう。これで ",ml" と入力すると "example [at] gmail.com" と展開されるスニペットが登録されます。タグはつけとくとスニペットが増えてきた時に管理が楽になります。

<img src="/images/dash-snippet/snippet1.jpg" class="image">

以下のようにスニペットが展開されます。

<img src="/images/dash-snippet/demo1.gif" class="image">

### 2. 日付や時間を自動的に挿入する

日付を毎回手打ちとかつらいですよね？そこで次はその日の日付を使うスニペットを登録してみます。

右上のプルダウンメニューから Data を選択すると、展開文字列に "@date" という文字列が挿入されます。もちろんそのまま "@date" と挿入しても大丈夫です。

<img src="/images/dash-snippet/snippet2.jpg" class="image">

これを呼び出すと以下のように自動的に日付が挿入されます。

<img src="/images/dash-snippet/demo2.gif" class="image">

時間も同じようにプルダウンメニューから Time を選択することで挿入できます。

なおフォーマットは設定の Snippets タブから設定することができます。

<img src="/images/dash-snippet/format.jpg" class="image">

### 3. プレースホルダーを利用する

Dash のスニペットはプレースホルダーも使うことができます。デフォルトのプレースホルダーは "\_\_hoge\_\_" のようにアンダースコア 2 つで囲む形式です。以下の様なスニペットを登録してみましょう。

<img src="/images/dash-snippet/snippet3.jpg" class="image">

スニペットを展開するとポップアップで編集画面が開くので、プレースホルダーの部分を編集して挿入することができます。

<img src="/images/dash-snippet/demo3.gif" class="image">

### 4. スニペットを複数マシンで共有する

Dash はスニペットが外部ファイルとして保存されるので、 Dropbox などを使うことで簡単にスニペットを共有することができます。

設定の "Snippet Library Location" を Dropbox のディレクトリにすれば OK です。

<img src="/images/dash-snippet/sync.jpg" class="image">

二台目以降は open で snippet ファイルを開けば他のマシンで登録したスニペットが使えるようになります。

## まとめ

Dash のスニペットは簡単に登録できてどこからでも使えて、設定も複数マシン間で共有できるのでなかなかよいのではないでしょうか？個人的には日本語入力になっていてもきちんと展開されるのも地味に嬉しいなと思ってます。使ってない人は是非試してみてください。
