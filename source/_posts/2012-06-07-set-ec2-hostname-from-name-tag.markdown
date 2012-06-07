---
layout: post
title: "用 ec2 的 Name tag 設定 hostname"
date: 2012-06-07 15:50
comments: true
categories: [ec2, aws]
---

如果 hostname 每一台都要自己一一指定相當麻煩，寫了一個小 script 放在開機時執行，抓取 instance-id 後取得 Name tag 再設定成 hostname。

{% gist 2887240 %}