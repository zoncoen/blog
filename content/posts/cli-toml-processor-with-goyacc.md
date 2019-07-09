+++
title = "goyacc を使って簡単な jq like query parser を作る"
date = "2015-12-22"
aliases = ["blog/2015/12/22/cli-toml-processor-with-goyacc"]
tags = ['Go', 'tool']
+++

この記事は [Go その 3 Advent Calendar 2015](http://qiita.com/advent-calendar/2015/go3) の 22 日目の記事です。

go tool の中には [yacc](https://golang.org/cmd/yacc/) というコマンドがあります。これはパーサジェネレータである yacc の Go 言語版です。この記事ではこれをつかって簡単な [jq](https://stedolan.github.io/jq/) のクエリパーサっぽいものを作ってみようと思います。

（この記事のコードは <https://github.com/zoncoen-sample/goyacc-jq-query-parser> にあります。あとこの記事で話してるものを使って雑に作った jq like TOML processor が <https://github.com/zoncoen/tq> に上がってます。）

<!--more-->

ご存知の方も多いかと思いますが一応簡単に紹介しておくと、 jq は標準入力から受けとった JSON 文字列から値を取り出したり加工したりする事ができるコマンドラインツールです。 JSON API から受け取ったレスポンスを簡単に処理するのに使ったりしている人も多いのではないかと思います。jq はかなり複雑なこともできたりするのですが、今回はそのなかでも簡単なフィルターをかけるようなクエリをパースできるパーサを、 goyacc で作ってみます。

## jq の簡単なクエリの紹介

今回は以下に挙げたものを実装していきます。

_`.`_

入力の JSON をそのまま出力するフィルターです。インデントなどをいい感じして整形してくれるので、地味に便利だったりします。

_`.key`_

指定したキーの値だけを出力するフィルターです。配列に対しては使えません。

_`.[0]`_

指定したインデックスの値だけを出力するフィルターです。配列に対してのみ使えます。

_`|`_

Unix のパイプのように、前の出力結果を次の入力として渡すことができるオペレータです。

## goyacc を使ってみる

### yacc の使い方

goyacc は yacc の Go 言語版なので、基本的な使い方は yacc と同じです。今回でてくる部分は簡単に説明しますが、Go はわかるけど yacc 全く分からん！という人は [goyacc で構文解析を行う](http://qiita.com/k0kubun/items/1b641dfd186fe46feb65) を先に読むと良いかもしれません。
また yacc の仕組みなどをもう少し詳しく知りたい場合は、 [速習 yacc](http://i.loveruby.net/ja/rhg/book/yacc.html) が参考になるかもしれません。 私も yacc を触るのは今回が初めてだったのですが、これらの記事がとても参考になりました。

### 雛形を作る

雛形として `parser.go.y` というファイルを作ります。まずは `.` という文字列を AST にすることを目指します。大まかなコードの流れとしては `Lexer.Lex()` で文字列をトークンに分割し、それを Perse して AST にしていきます。ファイル全体はこちら <https://github.com/zoncoen-sample/goyacc-jq-query-parser/blob/be513ae6d4bd210b8bc0c439d5140634365e1186/parser.go.y>

#### Lexer

パースを行う前の文字列の字句解析を行うために、`Lex()` 関数を実装した `Lexer` を作ります。今回は簡略化のために、スキャナには `text/scanner` の `Scanner` を利用します（これを使えば Go の準拠のもの、例えばダブルクォートで囲まれたものを文字列トークンとして扱う、みたいなところを自分で書かないで済みます）。

とりあえず `.` をトークンにできればよいので、そのようにコードを書きます。

{{< highlight go >}}
type Lexer struct {
scanner.Scanner
result Filter
}

func (l *Lexer) Lex(lval *yySymType) int {
token := int(l.Scan())
if token == int('.') {
token = PERIOD
}
lval.token = Token{token: token, literal: l.TokenText()}
return token
}
{{< /highlight >}}

#### Parser

Parser 自体は goyacc が生成してくれるので、定義を書きます。とりあえず sturuct はこんな感じで用意します。Parse した結果がこの struct を用いて AST として表現されます。

{{< highlight go >}}
type Filter interface{}

type Token struct {
token int
literal string
}

type EmptyFilter struct {}
{{< /highlight >}}

Parser の定義はこんな感じです。PERIOD (`.`) がきたら `empty_filter` とみなして `EmptyFilter{}` を返します。最初の実装は `.` の対応のみなので、 `filter` 全体は `empty_filter` のみで構成されます。

{{< highlight go >}}
%union{
token Token
expr Filter
}

%type<expr> filter empty_filter
%token<token> PERIOD

%%

filter
: empty_filter
{
\$$ = $1
yylex.(\*Lexer).result = $$
    }
empty_filter
    : PERIOD
    {
        $$ = EmptyFilter{}
}
{{< /highlight >}}

#### main() を実装する

動作の確認を行えるように `main()` を実装しておきます。`yyParse()` という関数が goyacc によって生成されるので、それに `Lexer` を渡して Parse するコードです。

{{< highlight go >}}
func main() {
l := new(Lexer)
l.Init(strings.NewReader(os.Args[1]))
yyParse(l)
fmt.Printf("%#v\n", l.result)
}
{{< /highlight >}}

#### parser の生成

それでは goyacc を使って定義から Parser の生成してみましょう。以下のコマンドで `parser.go` が生成されます。

{{< highlight sh >}}
\$ go tool yacc -o parser.go parser.go.y
{{< /highlight >}}

あとは動作確認をしてみましょう。以下の様な結果が得られたでしょうか？

{{< highlight sh >}}
\$ go run parser.go '.'
main.EmptyFilter{}
{{< /highlight >}}

## テストを書く

毎回手打ちで確認するのもあれなので、以下のようにテストを書いておくとよいかと思います。 <https://github.com/zoncoen-sample/goyacc-jq-query-parser/blob/0065f7b9c9e71034dc39f49f6f0090f6028c93d7/parser_test.go>

{{< highlight go >}}
package main

import (
"io"
"strings"
"testing"
)

var parseTests = []struct {
text string
ast Filter
}{
{".", EmptyFilter{}},
}

func parse(r io.Reader) Filter {
l := new(Lexer)
l.Init(r)
yyParse(l)
return l.result
}

func TestParse(t \*testing.T) {
for i, test := range parseTests {
r := strings.NewReader(test.text)
res := parse(r)
if res != test.ast {
t.Errorf("case %d: got %#v; expected %#v", i, res, test.ast)
}
}
}
{{< /highlight >}}

{{< highlight sh >}}
\$ go test ./
{{< /highlight >}}

## `.key`, `.[0]` の実装

それでは別のクエリも実装してみましょう。<https://github.com/zoncoen-sample/goyacc-jq-query-parser/blob/d9200730ac7b239aa73672cb527613fc6a3e388f/parser.go.y>

Lexer で Token として扱うようにして、

{{< highlight go >}}
func (l *Lexer) Lex(lval *yySymType) int {
token := int(l.Scan())
if token == int('.') {
token = PERIOD
}
if token == scanner.Ident {
token = STRING
}
if token == scanner.Int {
token = INT
}
if token == int('[') {
token = LBRACK
}
if token == int(']') {
token = RBRACK
}
lval.token = Token{Token: token, Literal: l.TokenText()}
return token
}
{{< /highlight >}}

Parser の定義を追加します。

{{< highlight go >}}
empty_filter
: PERIOD
{

$$
    }
key_filter
    : PERIOD STRING
    {
        $$ = KeyFilter{Key: $2.Literal}
    }
index_filter
    : PERIOD LBRACK INT RBRACK
    {
        $$ = IndexFilter{Index: $3.Literal}
}
{{< /highlight >}}

テストを追加して確認します。

{{< highlight go >}}
{".key", KeyFilter{Key: "key"}},
{".[0]", IndexFilter{Index: "0"}},
{{< /highlight >}}

## `|` の実装

最後に `|` の機能を実装してみましょう。<https://github.com/zoncoen-sample/goyacc-jq-query-parser/blob/b4d1b497feed99f467883e1db5270576ebe772c1/parser.go.y>

Token として追加して

{{< highlight go >}}
if token == int('|') {
token = PIPE
}
{{< /highlight >}}

Parser の定義を追加します。こんな感じで再帰のようになっていても問題ありません。

{{< highlight go >}}
filter
...
| filter PIPE filter
{
\$$ = BinOp{Left: $1, Op: $2, Right: $3}
}
{{< /highlight >}}

と言っているのに `conflicts` という一見エラーかな？と思うメッセージがでてきます。実はこのままでもきちんと動くのですが、一体このメッセージはなんなのでしょうか？

{{< highlight console >}}
\$ go tool yacc -o parser.go parser.go.y
conflicts: 1 shift/reduce
{{< /highlight >}}

### conflicts: shift/reduce について

このメッセージの表す意味を一言で言うと、「複数の規則が同時に適応可能な曖昧な規則になっている」ということになります。

今回の例で言うと下のような文字列を Parse する場合に、

{{< highlight sh >}}
'.first | .second | .third'
{{< /highlight >}}

`(.first | .second) | .third` として解釈すべきなのか、 `.first | (.second | .third)` として解釈すべきなのかが明示されておらず曖昧だ、という事になります。

conflicts: shift/reduce の有名な例として「ぶら下がり else 問題」というものがあります。詳しい解説が前述した [速習 yacc](http://i.loveruby.net/ja/rhg/book/yacc.html) にて詳しく解説されています。

ちなみに今回の場合、 `|` 演算子は左結合（常に左から右へと処理を進めていく）なので、`%left<token> PIPE` としてその事を明示してやれば、曖昧ではなくなり conflicts は出なくなります。

### 動作の確認

conflicts を解消したので、テストを追加して確認します。

{{< highlight go >}}
{".key | .[0]", BinOp{Left: KeyFilter{Key: "key"}, Op: Token{Token: 57351, Literal: "|"}, Right: IndexFilter{Index: "0"}}},
{".first | .second | .third", BinOp{
Left: BinOp{
Left: KeyFilter{Key: "first"},
Op: Token{Token: 57351, Literal: "|"},
Right: KeyFilter{Key: "second"}},
Op: Token{Token: 57351, Literal: "|"},
Right: KeyFilter{Key: "third"}}},
{{< /highlight >}}

少し長くなってしまいましたが、これでごく簡単な jq のクエリをパースできるようになりました！

## おわりに

今回はよくある四則演算などの例とはまた違った感じで goyacc の紹介をしてみました。
自分は今まで yacc を使ったことがなかったのでざっと調べながらやったのですが、それでも一応動くものができました。yacc 便利。

ちなみに goyacc で生成した Parser を使って jq like なクエリで TOML を filter する簡単なコマンドラインツールを作ってみました。 <https://github.com/zoncoen/tq>

TOML は top level が配列であることを許してないので、その辺ケアしてあげないといけなくてどういう挙動が正しいんかねと作ってて思ったり。（そもそもだれもコマンドライン TOML プロセッサーなんて使わないのではと思いつつ）

あと deeeet さんが[紹介されてた](http://deeeet.com/writing/2015/12/21/go-fuzz/) go-fuzz を使った fuzz testing とかこういうののテストに良さそうだなーと思ったのでそのうちやってみたい。
$$
