---
layout: post
title: "RSpec-Given 與 RSpec-Spies"
date: 2013-06-30 17:53
comments: true
categories: [Ruby, Rspec, Rspec-given, Rspec-spies, TDD]
---

## RSpec/Given

[rspec-given](https://github.com/jimweirich/rspec-given) 其實是這次去新加坡 [RedDotRubyConf](http://www.reddotrubyconf.com/) 聽 rake 的作者 [jimweirich](https://twitter.com/jimweirich) 介紹的。

乍看之下只是一個 syntax sugar，但實際用起來非常有幫助，可以有效的協助你寫出乾淨漂亮的測試。

[rspec-given](https://github.com/jimweirich/rspec-given) 提供了 `Given`, `Then`, `When` 三個關鍵字以及其他一些額外的功能。 `Given` 類似原本的 `let`，而 `it` 則拆成 `Then` 和 `When`。

原本用 `it` 來寫測試，一個 `it` 裡面容易越寫愈多，越寫越肥，而且執行的程式碼和 assertion 混在一起，不容易閱讀。

用 `Given` 定義需要的東西、 `When` 寫實際執行的程式碼、 `Then` 放 assertion，這樣可以很方便、清楚的組織你的測試程式碼。
<!--more-->
此外還有 `And` 可以搭配 `Then` 使用，以及一個比較特別的 `Invariant`：當每次 `Then` 被執行到的時候都會跑這個 assertion。

## RSpec-Spies

我們現在把測試分很明顯的三個區塊 `Given`, `Then`, `When` 以後，就會碰到一個問題叫 `should_receive`。

以往 `should_receive` 這件事是跟在 mock method 一起做的，這語句本身就同時有 `Then` 和 `When` 的涵義在。而且整段測試會變成前面有 assertion, 中間一段執行程式碼，後面又是 assertion ，使的整個閱讀性大大降低。

並且，我們一般人思考的順序是「我做了什麼事」 → 「得到什麼結果」。而 `should_receive` 是要寫在真正執行的程式碼前面的，跟我們思考的順序恰好相反，容易混淆。所以我們需要有一個語法能把 mock 跟 assertion(should_receive) 這兩件事分開。

這時候就可以使用 [rspec-spies](https://github.com/technicalpickles/rspec-spies)。

這樣我們就可以把 `have_receieved` 當成一般的 matcher 搬到 `Then` 區塊，整段測試就很清楚明瞭。

更好的是這個語法在 RSpec 2.14 就會內建支援，所以現在先使用這個 gem ，等 RSpec 2.14 正式 release 以後再拿掉即可無縫銜接。

## 延伸閱讀

* [RSpec/Given Tutorial](https://github.com/jimweirich/rspec-given/wiki/Tutorial)
* [Test Spy Pattern](http://xunitpatterns.com/Test%20Spy.html)