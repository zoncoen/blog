+++
title = "Font Awesomeのクラス名が変わっていた件"
date = "2013-11-10T00:00:00+09:00"
aliases = ["blog/2013/11/10/changing-font-awesome-class"]
author = "zoncoen"
categories = ["programming"]
tags = ["font"]
+++

様々なアイコンをテキストとして埋め込むことができる，[Font Awesome](http://fontawesome.io/)というものがあります．原理としてはCSS3のWebフォントという技術を使っています．

綺麗なアイコンを簡単に使うことができ，またテキストであるためCSSで簡単に色や大きさなども変えられる大変便利なものです．このブログでもいくつか使っているのですが，久しぶりに触ってみたらclass名が変わっていました．例を挙げると下のような感じです．

Before:
{{< highlight css >}}
<i class="icon-circle-arrow-right"></i>
{{< /highlight >}}
After:
{{< highlight css >}}
<i class="fa fa-arrow-circle-right"></i>
{{< /highlight >}}

"icon"が"fa"に変わっただけではなく，"circle-arrow"が"arrow-circle"に変わっていたりするあたりなんともアレですね．
