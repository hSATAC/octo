---
layout: post
title: "Bash PS1 補滿"
date: 2011-12-20 16:00
comments: true
categories: [Bash, Prompt, PS1]
---
今天 Even Wu 在 facebook 上問了一個問題：他的 Bash PS1 要補滿 dash 到換行為止，感覺很有趣，稍微研究了一下。

首先要取得 term 的寬度，這個很容易直接抓 ```$COLUMNS``` 就好。

再來要抓原本 PS1 的長度，原本打算用 ```$PWD``` 去抓，不過 \w 碰到自己的家目錄會變 ```~``` 所以長度不對，這邊要自己處理一下：

``` bash
  if [ $HOME == $PWD ]
  then
    newPWD="~"
  elif [ $HOME ==  ${PWD:0:${#HOME}} ]
  then
    newPWD="~${PWD:${#HOME}}"
  else
    newPWD=$PWD
  fi
```
<!--more-->

然後塞成跟原本 PS1 一樣的 temp 字串來算長度，最後把 term width 減去 temp 就可以抓到長度了，再作補滿的動作即可。

最後結果如下：

{% gist 1500143 %}
