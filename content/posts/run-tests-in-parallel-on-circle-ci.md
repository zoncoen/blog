---
title: 'Circle CI で Go のテストを並列に実行する'
date: 2018-08-06T15:45:10+09:00
author: zoncoen
categories: ["programming"]
tags: ['go', 'test', 'CI', 'tips']
---

CicleCI の機能を使うと簡単にできる。

<!--more-->

`parallelism` で複数のノードを使うようにして、 `circleci tests split` でノード毎にテストするパッケージを分ける。

```yaml
version: 2

jobs:
  build:
    parallelism: 3
    steps:
      - run:
          name: Run tests
          command: |
            circleci tests split <(go list ./src/...) > pkgs
            export TESTPKGS=$(cat pkgs | tr '\n' ' ')
            go test ${TESTPKGS}
```

ちなみに `Codecov` を利用している場合、

> Codecov does not override report data for multiple uploads. We always merge the data. Simply upload all three reports at once, or separately.

ということなので何も気にせずノード毎にカバレッジ測定の結果を `bash <(curl -s https://codecov.io/bash)` とかでアップロードすればいい感じにマージしてくれる。

## テスト対象以外もノードごとに挙動を変えたい

`${CIRCLE_NODE_INDEX}` という環境変数がノードごとに設定されるのでそれを利用する。例えば以下のようにして接続するデータベースを切り替えることができる。

```yaml
version: 2

jobs:
  build:
    parallelism: 3
    steps:
      - run:
          name: set database name
          command: |
            echo "export DBNAME=${CIRCLE_BUILD_NUM}-${CIRCLE_NODE_INDEX}" >> $BASH_ENV
            source $BASH_ENV
```

## References

- [Running Tests in Parallel - CircleCI](https://circleci.com/docs/2.0/parallelism-faster-jobs/)
- [Merging Reports - Codecov](https://docs.codecov.io/docs/merging-reports)
