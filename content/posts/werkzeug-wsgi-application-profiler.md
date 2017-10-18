+++
title = "WerkzeugでFlaskを使ったPythonのWebAppをプロファイリングする"
date = "2013-11-12"
aliases = ["blog/2013/11/12/werkzeug-wsgi-application-profiler"]
Categories = []
+++

[前回の記事]({{ root_url }}/blog/2013/11/11/logging-system-with-fluentd-elasticsearch-kibana3/)に引き続きISUCONのために調べたことをまとめてみます．

うちのチームは使用言語にPythonを選択していたので，ISUCON2やISUCON3の予選でも使われていた[Flask](http://flask.pocoo.org/)というフレームワークを使ったWSGI Application用のプロファイラを探したところWerkzeugのWSGI Application Profilerというものがあったので使ってみました．

<!--more-->

Flask
----------

[Flask](http://flask.pocoo.org/)は，[Werkzeug](http://werkzeug.pocoo.org/docs/)をベースにして[Jinja2](http://jinja.pocoo.org/docs/)をテンプレートに使った軽量なWAFです．

Werkzeug
----------

[Werkzeug](http://werkzeug.pocoo.org/docs/)はWSGI Applicationのutility libraryで，フレームワークという程ではないですがWSGIの実装を助けるようなrequest/responseオブジェクトの支援ツールやテスター，デバッガなどが含まれています．

そしてこのWerkzeugの中にはbuiltin moduleであるprofileやcProfileを使った[WSGI Application Profiler](http://werkzeug.pocoo.org/docs/contrib/profiler/)も含まれています．今回はこのModuleを使ってprofilingを行います．

導入
----------

Gitレポジトリからクローンしてきて，```setup.py```を実行するだけです．

``` console
$ git clone https://github.com/mitsuhiko/werkzeug
# python setup.py install
```

プロファイリングを行う
----------

それでは実際にプロファイリングを行ってみましょう．ここではサンプルアプリケーションとして，`/`にアクセスすると`Hello World!`と表示する単純なプログラムを用意します．まずFlaskをインストールしておきます．

``` console
# pip install flask
```

それではflaskを使ったapp.pyを作ります．

``` python app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return "Hello World!"

if __name__ == '__main__':
    app.run()
```

次にプロファイリングするコードを書きます．

``` python profiler.py
#!flask/bin/python
from werkzeug.contrib.profiler import ProfilerMiddleware, MergeStream
from app import app

app.config['PROFILE'] = True
app.wsgi_app = ProfilerMiddleware(app.wsgi_app)
app.run(debug = True)
```

それでは実行してみましょう．

``` console
$ python profiler.py
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
 * Restarting with reloader
```

<http://127.0.0.1:5000/>にアクセスします．すると以下のようにプロファイリング結果が標準出力に出力されます．

``` console
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
 * Restarting with reloader
--------------------------------------------------------------------------------
PATH: '/'
         301 function calls in 0.001 seconds

   Ordered by: internal time, call count

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/Werkzeug-0.10_devdev_20131113-py2.7.egg/werkzeug/wrappers.py:734(__init__)
       10    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/Werkzeug-0.10_devdev_20131113-py2.7.egg/werkzeug/local.py:67(__getattr__)
       10    0.000    0.000    0.000    0.000 {method 'decode' of 'str' objects}

    ...snip...

        1    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/Werkzeug-0.10_devdev_20131113-py2.7.egg/werkzeug/wrappers.py:60(_warn_if_string)
        1    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/flask/sessions.py:189(is_null_session)
        1    0.000    0.000    0.000    0.000 {method 'disable' of '_lsprof.Profiler' objects}


--------------------------------------------------------------------------------

127.0.0.1 - - [13/Nov/2013 14:21:51] "GET / HTTP/1.1" 200 -
```

プロファイリング結果の各項目の説明は以下のようになります．

項目                     |説明                                                  
-------------------------|------------------------------------------------------
ncalls                   |関数の呼び出し回数                                    
tottime                  |関数の実行にかかった時間                              
percall                  |tottime/ncalls                                        
cumtime                  |関数内で別の関数を呼んでいた場合，その関数も含めた時間
percall                  |cumtime/ncalls                                        
filename:lineno(function)|ファイル名:行数(関数名)                               

`sort_by=['calls']`で結果をncallsでソート，`restrictions=[10]`で出力を10件に制限する，などというようにオプションを指定することもできます．

``` python profiler.py
...snip...
app.wsgi_app = ProfilerMiddleware(app.wsgi_app, sort_by=['calls'], restrictions=[10])
app.run(debug = True)
```

``` console
--------------------------------------------------------------------------------
PATH: '/'
         301 function calls in 0.001 seconds

   Ordered by: call count
   List reduced from 138 to 10 due to restriction <10>

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
       35    0.000    0.000    0.000    0.000 {isinstance}
       14    0.000    0.000    0.000    0.000 {thread.get_ident}
       11    0.000    0.000    0.000    0.000 {method 'get' of 'dict' objects}
       10    0.000    0.000    0.000    0.000 {method 'decode' of 'str' objects}
       10    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/Werkzeug-0.10_devdev_20131113-py2.7.egg/werkzeug/local.py:67(__getattr__)
       10    0.000    0.000    0.000    0.000 {len}
        8    0.000    0.000    0.000    0.000 {getattr}
        6    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/flask/signals.py:35(<lambda>)
        6    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/Werkzeug-0.10_devdev_20131113-py2.7.egg/werkzeug/local.py:157(top)
        6    0.000    0.000    0.000    0.000 {method 'lower' of 'str' objects}


--------------------------------------------------------------------------------

127.0.0.1 - - [13/Nov/2013 15:11:02] "GET / HTTP/1.1" 200 -
```

また，以下のように`MergeStream()`を使えば，標準出力にログを流しながらファイルに書き出すこともできます．

``` python profiler.py
#!flask/bin/python
from werkzeug.contrib.profiler import ProfilerMiddleware, MergeStream
from app import app
import sys

f = open('profiler.log', 'w')
stream = MergeStream(sys.stdout, f)
app.config['PROFILE'] = True
app.wsgi_app = ProfilerMiddleware(app.wsgi_app, stream, sort_by=['calls'], restrictions=[10])
app.run(debug = True)
```

それでは再帰関数を呼んでみて，きちんとプロファイリングできているか確認してみましょう．以下のように`app.py`を変更し，20番目のフィボナッチ数を出力するようにしてみます．

``` python app.py
from flask import Flask
app = Flask(__name__)

def fib(n):
    if n <= 2:
        return 1
    else:
        return fib(n-1) + fib(n-2)

@app.route('/')
def fibonacci():
    n = 20
    return str(n) + "th Fibonacci number is " + str(fib(n)) +"."

if __name__ == '__main__':
    app.run()
```

`profiler.py`を実行し，<http://127.0.0.1:5000/>にアクセスします．

``` console
--------------------------------------------------------------------------------
PATH: '/'
         13830 function calls (302 primitive calls) in 0.008 seconds

   Ordered by: call count
   List reduced from 139 to 10 due to restriction <10>

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
  13529/1    0.007    0.000    0.007    0.007 /home/kenta/Documents/flask/app.py:4(fib)
       35    0.000    0.000    0.000    0.000 {isinstance}
       14    0.000    0.000    0.000    0.000 {thread.get_ident}
       11    0.000    0.000    0.000    0.000 {method 'get' of 'dict' objects}
       10    0.000    0.000    0.000    0.000 {method 'decode' of 'str' objects}
       10    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/Werkzeug-0.10_devdev_20131113-py2.7.egg/werkzeug/local.py:67(__getattr__)
       10    0.000    0.000    0.000    0.000 {len}
        8    0.000    0.000    0.000    0.000 {getattr}
        6    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/flask/signals.py:35(<lambda>)
        6    0.000    0.000    0.000    0.000 /usr/local/lib/python2.7/dist-packages/Werkzeug-0.10_devdev_20131113-py2.7.egg/werkzeug/local.py:157(top)


--------------------------------------------------------------------------------

127.0.0.1 - - [13/Nov/2013 17:58:24] "GET / HTTP/1.1" 200 -
```

fib()が時間がかかっているのが確認できると思います．ちなみにncallsの`13529/1`は，`(再帰も含めた呼び出し回数)/(再帰でない大元の呼び出し回数)`となっています．

おわりに
----------

今回はFlaskを使ったWSGI Applicationのプロファイリング方法を紹介しました．この結果をもとに時間のかかっている処理を特定・改善すれば，Applicationの高速化が図れます．

ちなみに，[前回の記事]({{ root_url }}/blog/2013/11/11/logging-system-with-fluentd-elasticsearch-kibana3/)で紹介したkibanaで表示できるように，Fluentdのプラグインも書いてみました．

[fluent-plugin-werkzeug-profiler - Github](https://github.com/zoncoen/fluent-plugin-werkzeug-profiler)

[fluent-plugin-werkzeug-profilerを書いた]({{ root_url }}/blog/2013/11/13/fluent-plugin-werkzeug-profiler)
