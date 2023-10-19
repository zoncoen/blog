+++
title = "Fluentd + ElasticSearch + Kibana3で簡単に様々なログを可視化・解析する"
date = "2013-11-11T00:00:00+09:00"
aliases = ["blog/2013/11/11/logging-system-with-fluentd-elasticsearch-kibana3"]
author = "zoncoen"
categories = ["programming"]
tags = ['fluentd', 'kibana', 'ElasticSearch']
+++

[ISUCON](http://isucon.net/)本戦に参加することができてしまったため，各種ログを集めて簡単に見れると良さそうだなぁと思っていたところ，[Fluentd](http://fluentd.org/) + [Elasticsearch](http://www.elasticsearch.org/) + [Kibana3](http://www.elasticsearch.org/overview/kibana/)の組み合わせがなかなかよさそうだったので試してみました．  
本記事では，NginxのAccessLogとMySQLのSlowQueryLogを可視化してみます．

<img src="/images/kibana3-derivequeries.png" class="image">

<!--more-->

<h3>Fluentd</h3>

[Fluentd](http://fluentd.org/)はご存知の方も多いと思いますが，[Treasure Data](http://www.treasure-data.com/)のメンバによって開発が進めれているオープンソースのログ収集ツールです．Fluentdに追加された様々なログデータはJSONに変換，アウトプットされます．実装はRubyで行われており，[plugin](http://fluentd.org/plugin/)を追加することでで様々なINPUT/OUTPUT先を追加することができます．  
Fluentdにはリアルタイムにログを収集して活用できることや，様々なログフォーマットの違いを吸収してJSONで同じように扱えることなどのメリットがあります．

<h3>ElasticSearch</h3>

[ElasticSearch](http://www.elasticsearch.org/)は分散型の全文検索エンジンです．RESTfulなAPIを通してデータの追加や検索を行います．スキマーレスでありスケーラビリティも考慮されていて，[foursquare](https://foursquare.com/)や[Github](https://github.com/)でも使われているようです．

<h3>Kibana3</h3>

[Kibana3](http://www.elasticsearch.org/overview/kibana/)は，ブラウザ上でElasticSearch上のログをリアルタイムビジュアライゼーションする事ができるWebアプリケーションです．[Kibana2](https://github.com/rashidkpc/Kibana)はRubyで実装されていたのですが，Kibana3はHTMLとJavascriptで書かれており，様々なパネルが用意されていて見た目も綺麗になっています．ただHTML+Javascriptであるため，ブラウザが動作しているマシンからデータが保存されているElasticSearchにアクセスできなければならないという制限があります．

導入と設定
----------

今回は以下のような環境で試してみました

- Ubuntu 12.04
- ruby 1.9.3

{{< highlight text >}}
+------------------------+        +---------------------------------------+
| Nginx  ---+            |        |                                       |
|           |            |        |                                       |
|           +--> Fluentd | =====> | Fluentd --> ElasticSearch --> Kibana3 |
|           |            |        |                                       |
| MySQL  ---+            |        |                                       |
+------------------------+        +---------------------------------------+
        Web Server                                Log Server
{{< /highlight >}}

<h3>Nginx & MySQL</h3>

まず下準備としてNginxとMySQLの設定を確認しておきましょう．Nginxはltsvでログを出力するように，MySQLはSlowQueryLogを出力するようにします．ここでは導入方法は省きます．

{{< highlight text >}}
...snip...

http {
  log_format  ltsv  'time:$time_local\t'
                      'msec:$msec\t'
                      'host:$remote_addr\t'
                      'forwardedfor:$http_x_forwarded_for\t'
                      'req:$request\t'
                      'method:$request_method\t'
                      'uri:$request_uri\t'
                      'status:$status\t'
                      'size:$body_bytes_sent\t'
                      'referer:$http_referer\t'
                      'ua:$http_user_agent\t'
                      'reqtime:$request_time\t'
                      'upsttime:$upstream_response_time\t'
                      'cache:$upstream_http_x_cache\t'
                      'runtime:$upstream_http_x_runtime\t'
                      'vhost:$host';
  
  access_log  /var/log/nginx/access.log  ltsv;

...snip...
{{< /highlight >}}

{{< highlight text >}}
...snip...

slow_query_log=ON
slow_query_log_file=/var/log/mysql/slow_query.log
long_query_time=1

...snip...
{{< /highlight >}}

<h3>ElasticSearch</h3>

それではLogServerにElasticSearchを導入しましょう．最新版は[公式サイト](http://www.elasticsearch.org/download/)で確認して下さい．ElasticSearchにはJavaの実行環境が必要なのでなければそれも導入します．

{{< highlight console >}}
# apt-get install openjdk-7-jdk
$ wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.6.deb
# dpkg -i elasticsearch-0.90.6.deb
{{< /highlight >}}

起動します．

{{< highlight console >}}
# service elasticsearch start
{{< /highlight >}}

<h3>Fluentd</h3>

次にログを収集するために各サーバにFluentdを導入します．ここではFluentdの安定版であるtd-agentを使います．最新版が利用したい場合は[Gitリポジトリ](https://github.com/fluent/fluentd.git)から最新版を落としてきて導入してください．

{{< highlight console >}}
$ sudo -i
# curl -L http://toolbelt.treasure-data.com/sh/install-ubuntu-precise.sh | sh
{{< /highlight >}}

次に各サーバに必要なプラグインを導入し，```/etc/td-agent/td-agent.conf```を編集します．なおtd-agentは自前のRubyインタプリタを使用しているため，```/usr/lib/fluent/ruby/bin/gem```などtd-agentとともに導入されたgemを使ってプラグインの導入を行ってください(でないと認識されない)．

- Web Server

{{< highlight console >}}
# gem install fluent-plugin-mysqlslowquery
{{< /highlight >}}

{{< highlight text >}}
<source>
  type tail
  format ltsv
  path /var/log/nginx/access.log
  tag nginx.access
  time_format %d/%b/%Y:%H:%M:%S %z
</source>

<source>
  type mysql_slow_query
  path /var/log/mysql/mysql-slow.log
  tag mysql.slow_query
</source>

<match **>
  type forward
  <server>
    host {IP of Log Server}
    port 24224
  </server>
  flush_interval 1s
</match>
{{< /highlight >}}

- Log Server

{{< highlight console >}}
# gem install fluent-plugin-elasticsearch
{{< /highlight >}}

{{< highlight text >}}
<source>
  type forward
  port 24224
</source>

<match nginx.*>
  index_name adminpack
  type_name nginx
  type elasticsearch
  include_tag_key true
  tag_key @log_name
  host localhost
  port 9200
  logstash_format true
  flush_interval 3s
</match>

<match mysql.*>
  index_name adminpack
  type_name mysql
  type elasticsearch
  include_tag_key true
  tag_key @log_name
  host localhost
  port 9200
  logstash_format true
  flush_interval 3s
</match>
{{< /highlight >}}

設定が済んだら起動しましょう．ログがとれているか確認したい場合は，Log Server側で```type stdout```を利用して標準出力を見たり，```/var/log/td-agent/td-agent.log```を確認しましょう．

{{< highlight console >}}
# service td-agent start
{{< /highlight >}}

これでLogServerのElasticSerchにログが保存されていくようにになりました．

<h3>Kibana3</h3>

最後にLogServerにKibana3を導入します．LogServerの公開用ディレクトリに```git clone```して，```/sample```にある設定ファイルを参考に，```index.html```にブラウザでアクセスできるようにします．

{{< highlight console >}}
$ git clone https://github.com/elasticsearch/kibana.git
{{< /highlight >}}

使い方
----------

ブラウザで```http://{IP of Log Server}```にアクセスすると下のようなページが表示されるので，真ん中下あたりの赤丸で囲んでいる```Logstash Dashboard```をクリックします．

<img src="/images/kibana3-welcome.png" class="image">

きちんとログがElasticSearchに追加されていれば，下のようにグラフとJSONフォーマットなデータが見れるようになっているはずです．

<img src="/images/kibana3-histogram.png" class="image">

あとは上にある検索窓や左にあるFieldから絞込を行って，ある時間のuri毎のアクセス数を見たり，Statusコードの割合を見たり，レスポンスに一定以上の時間がかかっているアクセスを探したりと色々なことができます．
またこのページの上でのせたようにグラフの種類や色を変えたりももちろんできます．

この辺りの使い方は以下の記事がよくまとまっているので参考にしてみてください．

[Kibana3というのもありまして - @johtaniの日記 2nd](http://blog.johtani.info/blog/2013/06/19/introduction-kibana3/)

ちなみにこんな感じでドラッグで範囲を指定すると

<img src="/images/kibana3-drag.png" class="image">

選択した範囲で絞り込めたりもします．すごい(小並感)

<img src="/images/kibana3-zoom.png" class="image">

まとめ
----------

以上かなり長くなってしまいましたが，Fluentd + ElasticSearch + Kibana3でNginxのアクセスログやMySQLのSlowQueryLogを可視化・解析する方法を紹介しました．WebServerの台数が増えてもFluentdでTagをつけておけばServer毎の解析や全体での解析もスムーズに切り替えることができますし，なかなか良いのではないのでしょうか :)

