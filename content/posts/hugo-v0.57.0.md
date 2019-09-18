---
title: 'Hugo v0.57.0 の breaking change'
date: 2019-09-18T22:28:39+09:00
tags: ['Go', 'tool', 'blog']
---

Hugo v0.57.0 に breaking change が含まれていて自分のブログのトップページが壊れた。その時の修正メモ。

<!--more-->

## 問題になった変更

該当の issue は[これ](https://github.com/gohugoio/hugo/issues/6153)。

`home.Pages` でとれる値が変更されたらしい。今まで通りの値が欲しければ `.Site.RegularPages` を使えとのこと。

## 修正方法

自分のテーマの場合 `layouts/index.html` で `.Data.Pages` を使っていたのでトップページに記事一覧が表示されなくなってしまった。`.Site.RegularPages` を使うようにすることで[修正した](https://github.com/zoncoen/hugo_theme_pickles/commit/bf493d6f366cf4ab239685511a772d91e2caa038)。
