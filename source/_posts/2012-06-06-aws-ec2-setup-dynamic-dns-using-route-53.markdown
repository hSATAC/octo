---
layout: post
title: "利用 route 53 設定 ec2 動態 DNS"
date: 2012-06-06 14:44
comments: true
categories: [aws, ec2, route53, dns]
---

最近在玩 aws ec2 第一個一定會碰到的問題就是 ip 都是動態的，每次開機都不一樣。造成大部分的佈署方式會有問題，一般都是用動態 dns 來解決，原本想自己架 bind 或 djbdns ，但是架好以後還要處理動態 dns 更新的機制，於是把想法動到價格低廉的 route 53 身上，他有完整的 restful api 應該很符合我的需求。

找到這個 [script](http://www.linkdata.se/downloads/sourcecode/other/route53-dyndns.sh) 是利用 http://checkip.dyndns.com 來抓取自己 ip 再更新 route 53 的 A record 。

不過 ec2 的 public dns 有一個特性，從外面解會解到 public ip ，但是從裡面解會解到 private ip ，同一個 availability zone 用 private ip 互連是不多收費的。

如果設 A record 使用 public 連線，就沒有這個優勢了，所以我改用 CNAME 指到 ec2 的 public dns。然後原本取得 ip 的部分也改用 aws 取 meta-data 就可以了。

具體作法，可以開一個 subdomain 例如 ec2.hsatac.net ，然後把這個 subdomain delegate 給我們的 route 53 來解析。在 DNS 的部分新增一筆 NS  `ec2.hsatac.net` 然後 server 設定為 route 53 給的那幾組即可。
<!-- more -->
修改過後的 script 如下：

{% gist 2880516 %}