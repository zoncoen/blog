---
title: "Google Home と mornin' を使って声でカーテンを開閉する"
date: 2017-12-12T00:16:44+09:00
author: zoncoen
categories: ["programming"]
tags: ['Google Home']
---

この記事は [WACUL Advent Calendar 2017](https://qiita.com/advent-calendar/2017/wacul) の 12 日目の記事です。

11 日目の記事は [@kyoh86](https://twitter.com/kyoh86) さんの [「Go の俺的 scaffold はこれだ！2017 年版」](https://qiita.com/kyoh86/items/74dbf9dcddd5bd43e01e) でした。

<!--more-->

## tl;dr

<img src="/images/posts/mornin-with-google-home/flow.jpg" class="image">

Google Home から IFTTT をキックして Pushbullet で送ったプッシュ通知をトリガーに Tasker で mornin' の Android アプリを操作する

## Motivation

我が家では以前から [Nature Remo](http://nature.global/) を利用してエアコンをアプリ経由で屋外から操作したりしていましたが、10 月に Google Home が発売されたことで声でエアコンやテレビを操作できる様になりました。Google Home と Nature Remo の連携は [公式のドキュメント](http://nature.global/jp/ifttt-setup/2017/10/8/google-home) に記載されている通り簡単に行うことができます。

また、テレビやエアコンだけでなく [mornin'](https://mornin.jp/) を使って起床時間にカーテンが自動的に開くようにしているのですが、これを取り付けていると手動でカーテンを開け閉めできずアプリ経由で操作しなければなりません。頻繁に開け閉めするわけではないとはいえ、毎回スマートフォンを手にとりアプリを起動して操作する事には煩わしさを感じていました。そこで mornin' も Google Home から声で操作できるようにしました。

## mornin' をプログラマブルに利用するときの制約について

mornin' には開発者向けの API や IFTTT との連携が用意されておらず、 Bluetooth で接続したスマートフォン上のアプリから操作することでしか操作できないため、今回は使っていない Nexus 5X を自動操作することで mornin' を動かすことにしました。

## 本記事の手法にて利用するもの

- [Google Home](https://store.google.com/product/google_home)
- [mornin'](https://mornin.jp/)
- [IFTTT](https://ifttt.com/)
- [Pushbullet](https://www.pushbullet.com/)
- 以下のアプリを導入した適当な Android 端末
  - [Tasker](https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm)
    - [Secure Settings Plugin](https://play.google.com/store/apps/details?id=com.intangibleobject.securesettings.plugin)
    - [AutoInput Plugin](https://play.google.com/store/apps/details?id=com.joaomgcd.autoinput)
  - [めざましカーテン mornin’ [モーニン]](https://play.google.com/store/apps/details?id=jp.co.robit.mornin)

## 1. Google Home から IFTTT をキックする

IFTTT にログインし、 `MyApplet > NewApplet` から新しい Applet を作成し、 トリガーに `Google Assistant > Say a simple phrase` を選択します。

<img src="/images/posts/mornin-with-google-home/ifttt-google-assistant-triggers.png" class="image">

Google Home に反応してもらう適当なフレーズを設定します。

<img src="/images/posts/mornin-with-google-home/ifttt-google-assistant.png" class="image">

## 2. IFTTT から Pushbullet を叩く

アクションに `Pushbullet > Push a note` を選択します。

<img src="/images/posts/mornin-with-google-home/ifttt-pushbullet-actions.png" class="image">

タイトルに Tasker に反応させる適当なキーワードを設定しておきます。

<img src="/images/posts/mornin-with-google-home/ifttt-pushbullet.png" class="image">

## 3. Tasker に mornin' のアプリを操作する Task を登録する

Tasker を起動して、新しい Task を追加する。

<img src="/images/posts/mornin-with-google-home/tasker-task.png" class="image">

## 4. Pushbullet の通知をトリガーに mornin' を操作する

`Profiles > Event > UI > Notification` から Pushbullet の Notification をトリガーに先ほど登録した Task を実行する Profile を作成する。

<img src="/images/posts/mornin-with-google-home/tasker-profile.png" class="image">

ここまで設定すれば Google Home に喋りかけることでカーテンを操作することができます。試してみましょう。

{{< youtube qUH6gxwgSEs >}}

IFTTT や Pushbullet が間にいることや Tasker での自動操作に Wait を入れていることもあり少し時間がかかっていますが、声でカーテンを操作できるようになりました。

明日 13 日目は [@podhmo](https://twitter.com/podhmo) さんです。楽しみですね。
