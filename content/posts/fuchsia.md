---
title: 'Google の新しい OS「Fuchsia」を macOS 上で動かしてみる'
date: 2017-12-18T22:54:12+09:00
author: zoncoen
categories: ["programming"]
tags: ['fuchsia', 'os']
---

この記事は [WACUL Advent Calendar 2017](https://qiita.com/advent-calendar/2017/wacul) の 19 日目の記事です。

18 日目の記事は [@bokuweb](https://twitter.com/bokuweb17) さんの [「ファミコンエミュレータの創り方 - Hello, World!編 -」](https://qiita.com/bokuweb/items/1575337bef44ae82f4d3) でした。

<!--more-->

Fuchsia は、Andorid, Chrome OS に続く第三の Google が開発する OS です。Linux カーネルをベースに開発された Andorid や Chrome OS とは異なり、独自カーネル Zircon をカーネルとして利用しています。その他のレイヤーも Garnet, Peridot, Topaz というように[名前がつけられているようです](https://fuchsia.googlesource.com/docs/+/HEAD/layers.md)。

今回は macOS 上でこの Fuchsia を動かしてみました。

## Fuchsia のビルド

[公式ドキュメント](https://fuchsia.googlesource.com/docs/+/HEAD/getting_started.md)に従ってインストールします。

まずは Homebrew で必要なものをインストールしておきます。

```console
$ brew install wget pkg-config glib autoconf automake libtool golang
```

次に Fuchsia のソースコードをチェックアウトします。以下のコマンドを実行すると、Fuchsia が利用している `jiri` というレポジトリ管理ツールとともにソースコードがチェックアウトされます。

```console
$ curl -s "https://fuchsia.googlesource.com/scripts/+/master/bootstrap?format=TEXT" | base64 --decode | bash -s topaz
```

`jiri` と Fuchsia の開発用コマンドである `fx` に適当に PATH を通しておきます。

```console
$ cd topaz
$ ln -s `pwd`/.jiri_root/bin/jiri ~/bin
$ ln -s `pwd`/scripts/fx ~/bin
```

それでは Fuchsia をビルドしましょう。かなり時間がかかるので気長に待ちます。

```console
$ fx set x86-64
$ fx full-build
```

## Fuchsia の起動

macOS 上では QEMU を使って動かします。以下のコマンドを実行すると shell が起動します。

```console
$ fx run
```

`cd` や `ls` など基本的な Unix コマンドは使えます。試しに簡単なコードを書いて実行してみましょう。Fuchsia ではシステム UI の Armadillo が Flutter で書かれており、Dart の実行環境がデフォルトで用意されています。
またエディタは `vim` が使えます。version は 8.0 でした。

```console
$ cd /tmp
$ vim hello_world.dart
```

```dart
// hello_world.dart
void main() {
  print('Hello, World!');
}
```

```console
$ dart hello_world.dart
Hello, World!
```

## GUI アプリケーションについて

先述した通り Fuchsia ではシステム UI が Flutter で書かれており、アプリケーションを Flutter で作ることができます。しかし最新の Fuchsia では GUI を利用するのに Vulkan が必須なので、対応していない macOS 上では GUI アプリケーションを動作させることができません。

Vulkan に対応している端末上で動作させる場合は、以下のコマンドを実行することで GUI で起動することができます。

```console
$ fx run -g
```

## まとめ

Google が開発中の OS Fuchsia について紹介しました。昨年の Advent Calendar では [Flutter について書いた](https://qiita.com/zoncoen/items/4ad07dc66ce2d3011fa8)ので、今年は Flutter で作った GUI アプリケーションを Fuchsia 上で動かすという事をしようかと思っていたのですが、いつの間にか Vulkan が必須になっており macOS 上では不可能でした。残念… そのうち Intel NUC でも買ってやりたい。

明日の担当は昨日に引き続き [@bokuweb](https://twitter.com/bokuweb17) さんです。楽しみですね。
