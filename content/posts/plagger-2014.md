+++
title = "Plagger 入門 in 2014"
date = "2014-12-12"
slug = "2014/12/12/plagger-2014"
Categories = []
+++

この記事は [Perl Advent Calendar 2014](http://qiita.com/advent-calendar/2014/perl) の 12日目の記事です。いいですか、**2014** ですよ。あなたは間違えて2008年の Advent Calender を開いてしまったわけではないので安心してください。

11日目の記事は [hisaichi5518](https://twitter.com/hisaichi5518) さんの [Data::DumperとB::Deparseを合わせて使ってみる。](http://hisaichi5518.hatenablog.jp/entry/2014/12/11/222358) でした。

[Plagger](https://github.com/miyagawa/plagger) とは、（[Rebuild.fm](http://rebuild.fm/) の）[miyagawa](https://twitter.com/miyagawa) さんが中心となって開発されていた Perl 製のフィードアグリゲータで、プラグインを組み合わせることで RSS フィードなど様々なデータを任意の形式に変換して出力させることができるものです。雑に言うと [ifttt](https://ifttt.com/) のようなもの（のはず）です。

今は代替となるような Web サービスがあったり、そもそも RSS フィードや Web hooks がきちんと用意されている Web サービスも多く、使っている方はあまり多くないようですが[^fn1]、数年前には "[それPla](http://d.hatena.ne.jp/keyword/%A4%BD%A4%ECPlagger%A4%C7%A4%C7%A4%AD%A4%EB%A4%E8)" という言葉が生まれるほど人気のプロダクトだったようです。

ただ世界的に有名な Perl Hacker である宮川さんのプロダクトということもあり、Perl を使っている会社の人間がうかつなことを言うと、

{{< tweet 539243420452020224 >}}

{{< tweet 539247510691119105 >}}

このようにいじられる、ということを [yosuke_furukawa](https://twitter.com/yosuke_furukawa) 先輩が身体をはって教えてくださったので、その知見を活かして Plagger を使ったことのなかった僕はきちんと触ってみることにしました。（もちろん僕は Plagger 知っていましたよ :D）

<!--more-->

## Installation

インストールが大変だーみたいな話を聞いていたけど、意外とそこまででもなかった。ただ何回もやりたいことではないし、docker image にしました。

``` console
$ docker pull zoncoen/plagger
```

これですぐ手元で使える環境ができます。

## Plugin

前述したとおり、Plagger は Perl で書かれた Plugin を使えば様々な処理をデータに加える事ができます。それによって Web ページをスクレイピングしてメールで送信したり、YouTube から特定のキーワードに合致した動画を自動でダウンロードして iPod に転送したり、"はらへった" というキーワードでの検索が行われたら自動でピザを注文するなど様々なことが実現できるようになっています。

Plagger には `plugin.init`, `subscription.load`, `customfeed.handle`, `aggregator.finalize`, `plugin.finalize` というような hook point が用意されており、各 plugin は `load_plugin()` した時に呼ばれる `register()` の中で各 hook に任意のサブルーチンを登録します。すると実行の際に各フェイズで hook に登録されているサブルーチンが呼ばれ、データが加工されていく仕組みになっています。

今回は実際に簡単なプラグインを書いてみました。

- [zoncoen/Plagger-Plugin-CustomFeed-GitHub](https://github.com/zoncoen/Plagger-Plugin-CustomFeed-GitHub)
- [zoncoen/Plagger-Plugin-Notify-Slack](https://github.com/zoncoen/Plagger-Plugin-Notify-Slack)

名前のまんま GitHub の public user feed をとってくるやーつと、feed を slack に通知するやーつです。

### Plagger::Plugin::CustomFeed::GitHub

前述した通り最初に register() というサブルーチンが呼ばれるので、その中で subscription.load hook にサブルーチンを登録します。

``` perl
sub register {
    my ( $self, $context ) = @_;

    $context->register_hook( $self, 'subscription.load' => $self->can('load'), );
}
```

するとその名の通り subscription を load するために、Plagger の run() のなかで hook に登録されたサブルーチンが run_hook() で実行されます。
Plagger::Plugin::CustomFeed::GitHub では Plagger::Feed の aggregator としてサブルーチンを登録し、その feed を context に add() してます。

``` perl
sub load {
    my ( $self, $context, $args ) = @_;

    my $feed = Plagger::Feed->new;
    $feed->aggregator( sub { $self->aggregate(@_) } );
    $context->subscription->add($feed);

    return;
}
```

あとは run() のなかで feed の aggregate() が順番に実行されていくので、その時に Plagger::Plugin::CustomFeed::GitHub の aggregate() が呼ばれ、entry が add されていきます。

``` perl
sub load {
sub aggregate {
    my ( $self, $context, $args ) = @_;

    my $token = $self->conf->{token} or return;
    my $users = $self->conf->{users} or return;
    $users = [$users] unless ref $users;

    my $ua     = LWP::UserAgent->new;
    my $header = HTTP::Headers->new(
        "Authorization" => "token $token",
        "Accept"        => "application/atom+xml"
    );
    for my $user (@$users) {
        my $url = "https://github.com/$user";
        my $req = HTTP::Request->new( 'GET', $url, $header );

        $context->log( debug => "Fetch feed from $url" );

        my $res = $ua->request($req);

        unless ( $res->is_success ) {
            $context->log( error => "GitHub API failed: " . $res->status_line );
            next;
        }

        my $content = HTML::Entities::decode( $res->content );

        Plagger::Plugin::Aggregator::Simple->handle_feed( $url, \$content );
    }
}
```

ちなみに面倒くさがって Atom の xml から Plagger::Entry へ変換するのに Plagger::Plugin::Aggregator::Simple->handle_feed() を直接呼んでいて雑。
正しいやり方か怪しい。

### Plagger::Plugin::Notify::Slack

Plagger::Plugin::Notify::Slack も同じように register() で hook にサブルーチン登録する。

``` perl
sub load {
sub register {
    my ( $self, $context ) = @_;
    $context->register_hook(
        $self,
        'publish.entry' => $self->can('publish'),
        'plugin.init'   => $self->can('initialize'),
    );
}
```

initialize は plugin の initialization として呼ばれるので、ここで必須の設定とかする（今回エラー処理忘れてた）。

``` perl
sub initialize {
    my ( $self, $context, $args ) = @_;

    $self->{remote} = $self->conf->{webhook_url} or return;
}
```

あとは publish() が publish.entry の時に呼ばれるだけです！！！

``` perl
sub publish {
    my ( $self, $context, $args ) = @_;

    $context->log( info => "Notifying " . $args->{entry}->title . " to Slack" );

    my $text = $self->templatize( 'notify.tt', $args );
    Encode::_utf8_off($text) if Encode::is_utf8($text);

    my $payload = +{ text => $text };
    $payload->{username}   = $self->conf->{username}   if exists $self->conf->{username};
    $payload->{icon_url}   = $self->conf->{icon_url}   if exists $self->conf->{icon_url};
    $payload->{icon_emoji} = $self->conf->{icon_emoji} if exists $self->conf->{icon_emoji};
    $payload->{channel}    = $self->conf->{channel}    if exists $self->conf->{channel};

    my $ua = LWP::UserAgent->new;
    my $res = $ua->post( $self->{remote}, [ payload => encode_json($payload) ] );

    unless ( $res->is_success ) {
        $context->log( error => "Notiying to Slack failed: " . $res->status_line );
    }
}
```

### Usage

こんな感じで設定して `plagger -c config.yaml` すると Slack に宮川さんの activity が通知されるので動いてるっぽい。

``` yaml config.yaml
global:
  assets: ./assets
  log:
    level: info

plugins:
  - module: CustomFeed::GitHub
    config:
      token: {github_api_token}
      users:
        - miyagawa

  - module: Filter::Rule
    rule:
      - module: Deduped

  - module: Notify::Slack
    config:
      webhook_url: {incoming_webhook_url}
```

<img src="/images/plagger-notify-slack.jpg" class="image">

Filter::Rule は文字通り filter かけれるやつで、`module: Deduped` と設定しておくと重複は弾いてくれるようになるので、動かすたびに同じ feed が再送されなくなる感じです。

あと下のように設定すると任意のディレクトリの plugin を読み込めるようになります。

``` yaml
global:
  assets_path: ./assets
  plugin_path:
    - ./plugins
```

## 感想

Plagger ほんとに pluggable だった。確かになんでもできそう。発表スライドがリンク切れになってたりとかして、Plagger まとまったドキュメントがパッと見つからなかったけど、コード綺麗で example もあったから読んだらなんとなく分かった。読んだら勉強になりそう。

ちなみに定期実行は cron とかでやってたんですかね？そういう情報出てこなかったのでよくわかりませんでした！

13日目の担当は [Maco_Tasu](https://twitter.com/Maco_Tasu) さんです。楽しみですね！

[^fn1]: 要出典
