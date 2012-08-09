---
layout: post
title: "使用 mitmproxy 替換 request host 和 port"
date: 2012-08-09 11:25
comments: true
categories: [mitmproxy, Python] 
---

常在開發或測試階段會有更換 http request host 的需求。
簡單一點的方法就是直接更改 /etc/hosts 檔案。但如果連 port 都需要轉，那就需要其他方式了。

一般在 windows 上是推薦 [fiddler 2](www.fiddler2.com) 這套軟體，非常好用。可以參考 [vexed 的文章](http://blog.xuite.net/vexed/tech/62341108)。

不過在其他平台，可以使用 [mitmproxy](mitmproxy.org) 這套軟體，他是 CUI 介面，操作上沒有 fiddler 那樣直覺，但稍微看一下說明即可上手。

mitmproxy 提供許多 API 讓使用者自訂需求，都使用 Python 來編寫。不過關於 script 的 document 較少，可以參考[官方說明](http://mitmproxy.org//doc/scripts.html)有簡單的範例，或者使用 `pydoc libmproxy.flow.Request` 這樣的指令來查閱，再不然就只能直接看[原始碼](https://github.com/cortesi/mitmproxy/)了。
<!--more-->

使用方法很簡單，首先開一個檔案例如 mitmproxy.py 

{% gist 3300699 %}

開啟 mitmproxy 的時候帶參數 -s `mitmproxy -s mitmproxy.py` 或者進入 mitmproxy 後按快速鍵 s 輸入 mitmproxy.py 載入即可。
