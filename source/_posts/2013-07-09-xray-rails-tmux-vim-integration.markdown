---
layout: post
title: "Xray-rails 與 tmux, vim 整合"
date: 2013-07-09 22:00
comments: true
categories: [Xray-rails, Rails, RoR, tmux, vim, tmuxinator]
---

剛好又開新專案了，來介紹一下 [Xray-rails](https://github.com/brentd/xray-rails) 與 tmux, vim 的整合。

[Xray-rails](https://github.com/brentd/xray-rails) 是一層 rack middleware，會 inject 你的 view 和 javascript 檔案，只要在開發模式按快速鍵 `⌘ + ⇧ + x` 就會開啟一層 overlay，讓你很清楚的看出現在的畫面由哪些 view, partial, controller 生成，更方便的是只要一點畫面，即可在編輯器中開啟該檔案，大大降低 trace 程式碼的時間。

[![image](https://dl.dropboxusercontent.com/u/156655/xray-screenshot.png)](https://dl.dropboxusercontent.com/u/156655/xray-screenshot.png)
<!--more-->
[Xray-rails](https://github.com/brentd/xray-rails) 預設的編輯器是 [Sublime Text 2](http://www.sublimetext.com/2) (`/usr/local/bin/subl`)。可以透過 overlay 右下角的設定圖示、或者自己新增 `~/.xrayconfig` 檔案來設定你使用的編輯器。

我平常使用 [Tmuxinator](https://github.com/aziz/tmuxinator) 來管理我的專案和 tmux, 每個專案有自己的 tmux session，讓我可以快速在不同專案的開發環境之間切換。

我的 `~/.xrayconfig` 也改成透過 tmux 傳送指令給我的 vim，範例設定檔如下：

```
:editor: "/usr/local/bin/tmux send -t openapply:editor $'\e' :tabe $file ENTER"
```

`openapply` 是我的專案 tmux session 名稱，而 `editor` 是該 session 的 window 名稱，專門用來開啟 vim 編輯檔案。

但問題來了，我每一個專案都有自己獨立的 tmux session，這樣每次切換專案的時候我都要修改 `~/.xrayconfig` 實在很不方便，所以希望能在每一個專案底下放自己的 `.xrayconfig`。

這個功能已經[提案給原作者同意](https://github.com/brentd/xray-rails/issues/21)，也送了 [pull request](https://github.com/brentd/xray-rails/pull/23)，不過還沒被 merge 回主幹，如果現在有需要這個功能的朋友可以暫時先使用我修改的 fork。

```
  gem 'xray-rails', :git => 'https://github.com/hSATAC/xray-rails.git',
                    :branch => 'feature/project_specific_config'
```
