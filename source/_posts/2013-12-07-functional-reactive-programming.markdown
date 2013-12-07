---
layout: post
title: "Functional Reactive Programming"
date: 2013-12-07 20:49
comments: true
categories: [Functional Reactive Programming, ReactiveCocoa, Cocoa, Objective-C]
---

### Functional Reactive Programming

第一次聽到 [Functional Reactive Programming(FRP)](http://en.wikipedia.org/wiki/Functional_reactive_programming) 是在今年新加坡的 RedDotRubyConf 2013 的最後一個 Session: [Functional Reactive Programming in Ruby](https://github.com/steveklabnik/frappuccino)。那時一直無法理解這個主題，直到大約九月時碰到了 [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 並開始在公司專案中使用，才對 FRP 開始有些感覺。

Functional Reactive Programming 就是 Functional Programming + Reactive Programming。 Functional Programming 大家應該比較熟悉，那什麼是 Reactive Programming 呢？最常看到的比喻就是像試算表一樣，你可以定義 `C1 = A1 + B1` ，之後只要你更改了 `A1` 或 `B1` 的值， `C1` 就會跟著改變。

光看這樣實在還是無法理解到底 FRP 是什麼，以及可以帶來什麼好處。這就是我今年六月剛聽到這個名詞時的感受。直到我開始使用 ReactiveCocoa(RAC)。
<!-- more -->
### ReactiveCocoa

ReactiveCocoa 的概念是從 .NET 的 Reactive Extensions 來的，在 Cocoa Framework 上實作了這個 paradigm，使用 ReactiveCocoa 可以讓我們減少大量複雜的程式碼。

幾個 FRP 中比較重要的名詞：`Streams`, `Sequences`, `Signals`,  `Subscriptions`。

`Stream` 就像是一個水管，裡面會一直有東西跑出來。

`Sequences` 是一種以拉為主的 `Stream`，常用在把 `NSArray`, `NSDictionary` 轉成 `RACSequence` 來接上高階函數操作 `map`, `filter`, `fold`, `reduce` 等。

`Signal` 是一種以推為主的 `Stream`，有三種類型：`next`, `error`, `completion` 分別表達有新的值、錯誤以及結束。

`Subscription` 則是誰要來等待/處理這些 `Signal`。

基本概念大概是這樣，不過有什麼應用場景呢？官網給的範例其實都滿簡單的，例如處理表單驗證，或是等到兩個 requests 都完成後才做下一步動作等等...。其實無處不可用，用下去幾乎都能看到立即的好處，甚至也有看到把 delegate protocol 都用 FRP 來寫的。不過我覺得這反而有點難讀了。

我們專案目前最常用的情境是：

1. 處理 Model 跟 View 之間的 binding, 值有變化的時候不用再一直去通知 View 更新。

2. Request 回來後把資料轉成我們要的樣子。光是這樣就已經很好用了。

不過 View 在處理深入一點的話可能要看看 MVVM 跟 [ReactiveViewModel](https://github.com/ReactiveCocoa/ReactiveViewModel) 這樣感覺也比較好寫測試...不過可能要等之後的新專案再來研究看看。

然後順便提一下 [Extended Objective-C (libextobjc)](https://github.com/jspahrsummers/libextobjc) 這個東西...因為 ReactiveCocoa 依賴 libextobjc 所以一定會裝到，除了很常見的 `@weakify`, `@strongify` 以外 libextobjc 還有不少好東西可以用，例如 `Concrete protocols`，`EXTNil` 等等，可以參考看看。

### Reference

* [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
* [ReactiveViewModel](https://github.com/ReactiveCocoa/ReactiveViewModel)
* [Mattt Thompson 介紹 RAC](http://nshipster.com/reactivecocoa/)
* [codeblog.share.dk 有幾篇不錯的文章](http://codeblog.shape.dk/blog/categories/reactivecocoa/)
* [Ash Furrow 寫的書 Functional Reactive Programming on iOS](https://leanpub.com/iosfrp)