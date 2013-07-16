---
layout: post
title: "用 Commandline 發 github pull request"
date: 2013-07-16 12:40
comments: true
categories: [Github, Git, Hub]
---

現在團隊使用 github 來作 code hosting, 利用 pull request 機制來做 code review。比以往自己架 gitosis 和 redmine 的方式更方便好用。

不過 programmer 天性懶惰，日子一久對於要開 github 網頁用滑鼠選 branch 發 pull request 的操作感到厭倦，能自動化的東西就懶得自己按按鈕啦！

使用 [hub](https://github.com/github/hub) 就可以用 commandline 進行各種 github 的操作。
<!--more-->
用 `homebrew` 或 `gem` 都可以進行安裝。

```
brew install hub
gem install hub
```

我們 team 開發流程是 feature branch 開發完畢後 push 到專案 remote 發 pull request，所以我在 `.bash_profile` 加了下面這個 function：

{% gist 5591270 %}

> 從 team 的 (現在目錄所在 branch) 發 pull request 到 team 的 (develop) branch