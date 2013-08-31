---
layout: post
title: "我的 Golang Vim 配置"
date: 2013-08-31 19:09
comments: true
categories: [Golang, Vim]
---

去年九月發過一篇[開發 Golang 的 IDEs](http://blog.hsatac.net/2012/09/golang-ides/)，不過現在我基本上都使用 vim 開發了， update 一下我現在的配置。所有資料都可以在我的 [vimrc](https://github.com/hSATAC/vimrc) 找到。

### 插件

和之前一樣最主要還是靠 golang 官方 plugin 以及 [gocode](https://github.com/nsf/gocode) 這兩個，多加了一個 [gotags](https://github.com/jstemmer/gotags) 取代 ctags，這個超好用的。

由於 golang 官方 plugin 和 gocode 的 plugin 都沒有抽出單獨的 repo，不方便 vundle 或 pathogen 使用，所以我之前就有自己抽出方便安裝的 repo：

* [Golang 官方 vim plugin](https://github.com/golangtw/go.vim)
* [Gocode vim plugin](https://github.com/golangtw/gocode.vim)

如果搭配 [supertab](https://github.com/ervandew/supertab) 可以設 `let g:SuperTabDefaultCompletionType = "context"` 來 trigger gocode 自動補完。

![gocode](/images/vimrc_golang/gocode.png)
<!--more-->
[gotags](https://github.com/jstemmer/gotags) 的部份則是要搭配 [tagbar](http://majutsushi.github.com/tagbar/) 來使用，抓的非常準(感謝 go 天生內建語法樹 parser)，而且安排的順序就完全是建議的順序，按這個順序組織你的程式碼就對了。

![gotags](/images/vimrc_golang/gotags.png)

[vim-airline](https://github.com/bling/vim-airline) 現在也內建 [tagbar](http://majutsushi.github.com/tagbar/) 支援了，所以可以直接在狀態列看到現在在程式的什麼區塊。

### 設定與巨集

`go fmt` 實在是一個非常優秀的設計，不用再為了 style 的瑣事吵半天。在存檔的時候順手執行 `go fmt` 吧！安裝過官方插件的話，只要加上 `au FileType go au BufWritePre <buffer> Fmt` 即可。

由於 golang 的哲學是，不需要的程式碼就不要，所以沒用到的變數或 import package 都會被當成 error 處理。導致常常改一改就要回到檔案最上方處理 import。多利用 `:Import <package>` 跟 `:Drop <package>` 兩個命令可以簡化這個步驟。

測試的部份，原來我就有使用 [tslime](https://github.com/jgdavey/tslime.vim) 這個插件，就多 bind 一個指令 `au FileType go map <leader>t :Tmux go test<CR>` 把 `go test` 指令送到 tmux 其他 window。目前這樣就能滿足我的需求。

![gotest](/images/vimrc_golang/gotest.png)

### 參考資料

還有更多 plugin 可以參考這篇：[My (Go-centric) Vim Setup](http://0value.com/my-Go-centric-Vim-setup)
