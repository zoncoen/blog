---
title: "chezmoi で dotfiles を管理する"
date: 2022-01-26T17:55:20+09:00
tags: ['tool', 'shell', 'go']
---

dotfiles は自前のスクリプトを使って Git 管理していたが、最近は dotfiles manager 的なツールがいくつかあるようなので、そのうちの一つである [chezmoi](https://github.com/twpayne/chezmoi) を試しに触ってみた。

<!--more-->

ざっくり検索したところメジャーな dotfiles manager は以下のようなものがあった。

- [chezmoi](https://github.com/twpayne/chezmoi)
  - GitHub Star 5900
  - Go
  - 1Password や Keychain などに保存した機密情報を利用できる
- [dotbot](https://github.com/anishathalye/dotbot)
  - GitHub Star 5000
  - Python
- [yadm](https://github.com/TheLocehiliosan/yadm)
  - GitHub Star 3100
  - Python
  - GnuPG, OpenSSL, transcrypt, git-crypt を使った機密情報の暗号化機能
- [rcm](https://github.com/thoughtbot/rcm)
  - GitHub Star 2700
  - Perl
- [fresh](https://github.com/freshshell/fresh)
  - GitHub Star 1100
  - Ruby

記事執筆時点で GitHub Star が一番多くメンテナンスもされていそうだったこと、自分が慣れている Go で書かれていること、1Password 連携があることなどから今回は chezmoi を使うことにした。

### Installation

Homebrew のような package manager を使えるので簡単、chezmoi は他のツールと比較してドキュメントがきちんと整備されているのもよい。

https://www.chezmoi.io/install/

### Setup

chezmoi は `~/.local/share/chezmoi` をソースディレクトリとして使うので、以下のコマンドで初期化すると `~/.local/share/chezmoi` が作られる。
このディレクトリを Git のような VCS で管理していく。

```sh
$ chezmoi init
$ chezmoi cd
$ git remote add origin https://github.com/<username>/<reponame>.git
```

### Usage

ファイルやディレクトリを `add` で追加すると、chezmoi の管理対象になる。
例えば以下のコマンドを実行すると `~/.vimrc` が管理対象になり、 `~/.local/share/chezmoi/dot_vimrc` ができる。

```sh
$ chezmoi add ~/.vimrc
```

管理対象のファイル一覧は `managed` で確認できる。

```sh
$ chezmoi managed
.vimrc
```

ソースディレクトリを Git で管理することで、他のデバイスと同期することができる。
`chezmoi cd` でソースディレクトリに移動して `git` コマンドを直接叩いてもよいが、 `chezmoi git` でも操作できる。

```sh
$ chezmoi git -- add -A
$ chezmoi git -- commit -m 'add .vimrc'
$ chezmoi git -- push origin main
```

他のデバイスで利用する場合は、以下のようにセットアップする。

```sh
$ chezmoi init https://github.com/<username>/<reponame>.git
```

変更を取り込むには、 `update` コマンドを使う。内部的には `git pull` して `apply` しているっぽい。

```sh
$ chezmoi update
```

### Apply External Repositories

chezmoi は自分の dotfiles 管理用レポジトリ以外のレポジトリをサブディレクトリとしてとってくることができる。この機能は [`tpm`](https://github.com/tmux-plugins/tpm) や [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) のようなプロダクトを使う場合に有用。使い方は `~/.local/share/chezmoi/.chezmoiexternal.toml` に設定を書くだけ。

```toml ~/.local/share/chezmoi/.chezmoiexternal.toml
[".tmux/plugins/tpm"]
    type = "archive"
    url = "https://github.com/tmux-plugins/tpm/archive/master.tar.gz"
    exact = true
    stripComponents = 1
    refreshPeriod = "168h"
```

### Template

chezmoi には、デバイスごとの値をセットできるように Go の [`text/template`](https://pkg.go.dev/text/template) を使ったテンプレートの機能が用意されている。
例として以下のような JSON を管理することを考える。

```json ~/.example.json
{
  "email": "account1@example.com"
}
```

デバイス毎に変えたい `account1@example.com` を `data` として `~/.config/chezmoi/chezmoi.toml` に定義する。

```toml ~/.config/chezmoi/chezmoi.toml
[data]
    email = "account1@example.com"
```

その状態で `--autotemplate` を使って `add` すると、テンプレートファイル `dot_example.json.tmpl` として追加することができる。

```sh
$ chezmoi add --autotemplate ~/.example.json
```

```tmpl ~/.local/share/chezmoi/dot_example.json.tmpl
{
  "email": "{{ .email }}"
}
```

git で管理するのはこのテンプレートファイルなので、他のデバイスでは別の `email` を設定すれば異なる値を利用することができる。

```toml ~/.config/chezmoi/chezmoi.toml
[data]
    email = "account2@example.com"
```

```json ~/.example.json
{
  "email": "account2@example.com"
}
```

### Credential

chezmoi のテンプレートでは [1Password CLI](https://support.1password.com/command-line-getting-started/) を利用することで 1Password で管理している値を利用することもできる。

1Password CLI をインストールしてログインする。

```sh
$ eval $(op signin <subdomain>.1password.com <email>)
```

1Password の各 item には uuid がふられているので、その uuid を指定することで値を取り出すことができる。

```sh
op get item <uuid> | jq .
```

uuid は以下のようにして確認することができる。

```sh
$ op list items --vault <vault-name> | jq '.[] | select(.overview.title == "<item-name>")'
```

実際にテンプレートで使う場合は `op get` の結果のオブジェクトが渡ってくるので、必要なフィールドを指定して利用する。

```sh
export GITHUB_TOKEN={{ (onepassword "<uuid>").details.password | quote }}
```

### Conclusion

dotfiles の管理を自作スクリプトでやるのはメンテナンスするのがめんどくさくなったので、試しに chezmoi に移行してみた。とりあえず 1Password 連携が便利なのでよい。
