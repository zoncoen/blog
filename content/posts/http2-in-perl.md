+++
title = "Perl の HTTP/2 事情"
date = "2015-12-11"
aliases = ["blog/2015/12/11/http2-in-perl"]
Categories = []
+++

この記事は [Perl Advent Calendar 2015](http://qiita.com/advent-calendar/2015/perl5) の 11日目の記事です。

昨日の記事は [mackee_w](https://twitter.com/mackee_w) さんの「[ペライチPSGIアプリケーションの概念と実証](http://qiita.com/mackee_w/items/71eca78fb40e5c38fe60)」でした。

今年 2015 年は、HTTP/2 の RFC が出ましたね。というわけで HTTP/2 の話をします。以前 [Gotanda.pm #4](http://gotanda-pm.connpass.com/event/11993/) にて「[Perl の HTTP/2 事情](https://speakerdeck.com/zoncoen/http2-in-perl)」というタイトルで発表したのですが、それとだいたい一緒です（記事書いてなかったので…）。

<!--more-->

HTTP/2 の各言語実装は <https://github.com/http2/http2-spec/wiki/Implementations> にまとまっているのですが、ここを見ると Perl には `Protocol::HTTP2` / `http2-perl` という実装があるようです。ただ `http2-perl` は h2-04 準拠なので Older Implementations に入れられており、実質 `Protocol::HTTP2` 一択です。以前発表した時は `Protocol::HTTP2` は draft-17 だったのですが、現在は h2 になっているのできちんと開発は続いているようですね。

## How to Use Protocol::HTTP2

というわけで、`Protocol::HTTP2` を実際に使ってみましょう。今回はクライアントを `Protocol::HTTP2` を使って Perl で書き、[nghttp2](https://nghttp2.org/) のサーバーに繋いでみます。コードは GitHub にあげてあります。

<https://github.com/zoncoen-sample/p5-protocol-http2-nghttp2>

まずはこんな感じでクライアントを作ります。 `on_change_state` や `on_error` にコールバックを登録しておきます。

{{< highlight perl >}}
my $client = Protocol::HTTP2::Client->new(
    on_change_state => sub {
        my ( $stream_id, $previous_state, $current_state ) = @_;
        printf "Stream %i changed state from %s to %s\n",
          $stream_id, const_name( "states", $previous_state ),
          const_name( "states", $current_state );
    },
    on_error => sub {
        my $error = shift;
        printf "Error occured: %s\n", const_name( "errors", $error );
    },
);
{{< /highlight >}}

次にクライアントにリクエストを登録します。ここではリクエストの内容と、成功した時のコールバックを `on_done` として渡してあげます。まだ実際のリクエストは行われません。

{{< highlight perl >}}
$client->request(
    ':scheme'    => "http",
    ':authority' => $host . ":" . $port,
    ':path'      => "/assets/hello.txt",
    ':method'    => "GET",
    headers      => [
        'accept'     => '*/*',
        'user-agent' => 'perl-Protocol-HTTP2/0.01',
    ],
    on_done => sub {
        my ( $headers, $data ) = @_;
        printf "Get headers. Count: %i\n", scalar(@$headers) / 2;
        printf "Get data.   Length: %i\n", length($data);
        print $data;
    },
);
{{< /highlight >}}

ここまでできたら、`AnyEvent::Socket` の `tcp_connect` を使って TCP コネクションをはり、`$client->feed()` でクライアントに流れてくるデータを渡していきます。クライアントはリクエストが完了すると、リクエストを登録したときの `on_done` を実行します。

{{< highlight perl >}}
my $w = AnyEvent->condvar;

tcp_connect $host, $port, sub {
    my ($fh) = @_ or die "connection failed: $!";
    my $handle;
    $handle = AnyEvent::Handle->new(
        fh       => $fh,
        autocork => 1,
        on_error => sub {
            $_[0]->destroy;
            print "connection error\n";
            $w->send;
        },
        on_eof => sub {
            $handle->destroy;
            $w->send;
        }
    );

    # First write preface to peer
    while ( my $frame = $client->next_frame ) {
        $handle->push_write($frame);
    }

    $handle->on_read(
        sub {
            my $handle = shift;

            $client->feed( $handle->{rbuf} );

            $handle->{rbuf} = undef;
            while ( my $frame = $client->next_frame ) {
                $handle->push_write($frame);
            }
            $handle->push_shutdown if $client->shutdown;
        }
    );
};

$w->recv;
{{< /highlight >}}

簡単ですね（？）

{{< highlight bash >}}
$ carton exec -- perl client-simple.pl
Stream 1 changed state from IDLE to HALF_CLOSED
Stream 1 changed state from HALF_CLOSED to CLOSED
Get headers. Count: 6
Get data.   Length: 14
Hello HTTP/2!
{{< /highlight >}}

## リクエストの多重化

HTTP/2 は1つの TCP コネクション上で複数のストリームをつかってリクエストの多重化を行うことができます。`Protocol::HTTP2` でももちろんリクエストの多重化ができます。

複数のリクエストを同時になげるには、以下のように `request()` をつなげていきます。この例ではサイズの大きい `/assets/largefile` と、サイズの小さい `/assets/hello.txt` の GET を行います。

{{< highlight perl >}}
$client->request(
    ':scheme'    => "http",
    ':authority' => $host . ":" . $port,
    ':path'      => "/assets/largefile",
    ':method'    => "GET",
    headers      => [
        'accept'     => '*/*',
        'user-agent' => 'perl-Protocol-HTTP2/0.01',
    ],
    on_done => sub {
        my ( $headers, $data ) = @_;
        printf "Get headers. Count: %i\n", scalar(@$headers) / 2;
        printf "Get data.   Length: %i\n", length($data);
        print "Finish getting largefile.\n"
    },
)->request(
    ':scheme'    => "http",
    ':authority' => $host . ":" . $port,
    ':path'      => "/assets/hello.txt",
    ':method'    => "GET",
    headers      => [
        'accept'     => '*/*',
        'user-agent' => 'perl-Protocol-HTTP2/0.01',
    ],
    on_done => sub {
        my ( $headers, $data ) = @_;
        printf "Get headers. Count: %i\n", scalar(@$headers) / 2;
        printf "Get data.   Length: %i\n", length($data);
        print "$data\n";
    },
);
{{< /highlight >}}

これを実行すると以下のような結果が得られます。まず Stream 1 (largefile) のリクエストが実行され、次に Stream 3 (hello.txt) が実行されますが、さきに実行されたファイルサイズの大きい Stream 1 のリクエストにブロッキングされることなく、Stream 3 のリクエストが先に完了していることが分かります。

{{< highlight bash >}}
$ carton exec -- perl client-multi-streams.pl
Stream 1 changed state from IDLE to HALF_CLOSED
Stream 3 changed state from IDLE to HALF_CLOSED
Stream 3 changed state from HALF_CLOSED to CLOSED
Get headers. Count: 6
Get data.   Length: 14
Hello HTTP/2!

Stream 1 changed state from HALF_CLOSED to CLOSED
Get headers. Count: 6
Get data.   Length: 100000000
Finish getting largefile.
{{< /highlight >}}

HTTP/2 便利

## 所感

というわけで Perl でも HTTP/2 は使えるよ、という話でした。ただ AnyEvent でやるの割とめんどくさいですね…（コールバックばっかで一昔前の JavaScript っぽい）。
Enjoy!

明日は [yusukebe](https://twitter.com/yusukebe) さんです。楽しみですね！（すでに[「先走って」書かれている](http://blog.yusuke.be/entry/2015/12/09/104244)ようですがw）

## P.S.

これの一個前の[記事](http://blog.zoncoen.net/blog/2014/12/12/plagger-2014/)が去年の Advent Calendar の記事とかいうヤバイ状態でした。書くネタはあったのにブログ書くのサボりすぎ…来年はきちんと書いていきたい。
