---
title: 'Bazel を使うための準備（Vim 編）'
date: 2019-07-08T12:17:34+09:00
author: zoncoen
categories: ["programming"]
tags: ['vim', 'bazel']
---

[Bazel](https://bazel.build/) に入門するための下準備として Vim で `BUILD.bazel` を書くための設定をした。

<!--more-->

## tl;dr

[vim-plug](https://github.com/junegunn/vim-plug) を利用してる場合、以下のように設定すれば保存したときに自動整形される。

```vim
call plug#begin('~/.vim/plugged')

" filetype
Plug 'bazelbuild/vim-ft-bzl'

" code formatter
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'google/vim-codefmt'

call plug#end()

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
augroup END
```

## filetype

[vim-ft-bzl](https://github.com/bazelbuild/vim-ft-bzl) で filetype を追加する。

```vim
call plug#begin('~/.vim/plugged')

" filetype
Plug 'bazelbuild/vim-ft-bzl'

call plug#end()
```

## コード整形

最近はなんでもかんでも自動整形してくれないと生きていけない怠惰な人間になってしまったので、[vim-codefmt](https://github.com/google/vim-codefmt) で保存時に自動で整形されるように設定する。
vim-maktaba と vim-glaive に依存しているようなのであわせてインストールしておく。

```vim
call plug#begin('~/.vim/plugged')

" code formatter
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'google/vim-codefmt'

call plug#end()

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
augroup END
```

実際のコード整形は [buildifier](https://github.com/bazelbuild/buildtools/blob/master/buildifier/README.md) がやってるのでインストールしておく。

```shell
$ go get -u github.com/bazelbuild/buildtools/buildifier
```
