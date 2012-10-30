---
layout: post
title: "Obj-C 單元測試非同步連線"
date: 2012-10-30 13:14
comments: true
categories: [iOS, unit test]
---
使用 Xcode 的 OCUnit 來做單元測試網路連線時，由於 OCUnit 不會等 block 執行，所以會直接跳到 pass。一般正常作法應該是用 mock object 來測試，不過總有要實際測試真實連線的時候。這時可以使用以下的 snippet:

{% gist 3978482 %}
