---
title: "ブログで使う static site generator を Octopress から Hugo に移行した"
date: 2017-12-02T18:36:13+09:00
---

最近全然更新できてなかったこのブログを、いまさらながら Octopress から Hugo に移行した。

<!--more-->

[マイグレーションスクリプト](https://gohugo.io/tools/migrations/#octopress)を使えば割と簡単だったけれど、一部対応が必要だったのでメモ。

### マイグレーションスクリプトの微修正

[公式ドキュメント](https://gohugo.io/tools/migrations/#octopress)にて紹介されている [octohug](https://github.com/codebrane/octohug) を使うと記事を一括で変換してくれるけど、元のタイトルを変えてしまうのが都合悪かったので修正したものを使った。

<https://github.com/zoncoen/octohug>

### Octopress オリジナルのタグの置き換え

img tag

```console
$ find ./content/posts -type f -exec sed -i "" -e 's/{%.*img.*\/images\/\([^ ]*\) .*%}/<img src=\"\/images\/\1\" class=\"image\">/g' {} \;
```

oembed tag

```console
$ find ./content/posts -type f -exec sed -i "" -e 's/{%.*oembed.*https:\/\/twitter.com\/.*\/status\/\(.*\) .*%}/{{</* tweet \1 */>}}/g' {} \;
```

### リダイレクト設定

```console
$ find ./content/posts/old -type f -exec sed -i "" -e 's/slug = \"\(.*\)\"/aliases = \[\"blog\/\1\"\]/g' {} \;
```

### markdown code blocks の Hugo shortcodes への置き換え


```console
$ find ./content/posts -type f -exec sed -i "" -e 's/^```$/{{</* \/highlight */>}}/g' {} \;
$ find ./content/posts -type f -exec sed -i "" -e 's/^``` *\([a-zA-Z]*\)\(.*\)/{{</* highlight \1 */>}}/g' {} \;
```

以上でだいたい終わり。簡単だった。
