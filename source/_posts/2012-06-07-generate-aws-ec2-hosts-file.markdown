---
layout: post
title: "動態產生 ec2 的 hosts 檔案"
date: 2012-06-07 11:43
comments: true
categories: [aws, ec2, hosts]
---

這個議題類似上一篇 [利用 Route 53 設定 Ec2 動態 DNS](http://blog.hsatac.net/2012/06/aws-ec2-setup-dynamic-dns-using-route-53/) ，同樣也是要解決主機名稱對應浮動 ip 的問題。

雖然現在用完整域名已經可以對應到 ip ，但是還是有很多時候我們的主機需要知道主機名稱和 ip 的對應。

這個問題大概也是可以用 hosts 或 dns 來解決，不過由於我已經把 yp nis 架設起來，其他機器可以直接吃 nis 伺服器的 hosts 檔案，所以決定用 hosts 這個方式來處理。

概念很簡單，利用 ec2 api sdk 抓取正在運行的主機列表，一一寫入 /etc/hosts 後再重新 make yp 的資料庫。

設個排程每個小時跑一下或開新機器時手動執行一下即可。

script 如下：

{% gist 2881131 %}