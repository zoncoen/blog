+++
title = "fluent-plugin-werkzeug-profilerを書いた"
date = "2013-11-13T00:00:00+09:00"
aliases = ["blog/2013/11/13/fluent-plugin-werkzeug-profiler"]
author = "zoncoen"
categories = ["programming"]
tags = ["fluentd", "plugin", "kibana"]
+++

表題の通り，KibanaでWerkzeugのプロファイリング結果を見たいがためにFluentdのプラグインを書いてみました．あまりにもニッチすぎる感．ISUCONのために書きました．

[fluent-plugin-werkzeug-profiler - Github](https://github.com/zoncoen/fluent-plugin-werkzeug-profiler)

Rubyを普段書かないので多分コードは汚いです．

<!--more-->

導入
----------

[RubyGems.org](http://rubygems.org/)にあげてあるのでgemで入ります．

{{< highlight console >}}
$ gem install fluent-plugin-werkzeug-profiler
{{< /highlight >}}

使い方
----------

[前回の記事]({{ root_url }}/blog/2013/11/12/werkzeug-wsgi-application-profiler)で紹介したように，Werkzeugのプロファイリング結果をファイルに出力します．あとはtd-agentのconfigに以下の感じで追加するだけです．

{{< highlight text >}}
<source>
  type werkzeug_profiler
  path path/to/werkzeug.log
  tag werkzeug.webserver
</source>
{{< /highlight >}}

in_tailを拡張しているだけなので，新しいログをどんどんとってきてくれます．あとは[前々回の記事]({{ root_url }}/blog/2013/11/11/logging-system-with-fluentd-elasticsearch-kibana3/)で紹介したようにElasticSerchとKibana3と組み合わせれば，可視化・解析が簡単にできます．

問題はやはりニッチ過ぎて使う人がいなさそうなところですね．僕ももう使うことはないと思います()

