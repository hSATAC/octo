---
layout: post
title: "同步 git 和 hg 的 repository"
date: 2012-10-17 10:20
comments: true
categories: [git, hg, mercurial, golang, go, gocode]
---
最近在玩 go，編輯器主要是使用 vim 搭配 [gocode](https://github.com/nsf/gocode)。我習慣用 [pathogen.vim](https://github.com/tpope/vim-pathogen) 來管理我的 vim 套件，不過 go 官方附的 vim syntax plugin 和 gocode 提供的 autocompletion plugin 目錄結構都無法直接當成 git submodule 引入我的 vim 設定中。

由於我個人潔癖作祟，不想再用 copy 的方式來管理我的 vim plugins，所以我決定自己把這兩份 plugin 抽出來獨立成各自的 git repositories，就可以當成 git submodule 引用了。
<!--more-->
gocode 的部分很容易，他原本就是 git，只要參考我之前的文章「[把 Git 中的目錄搬到另一個 Git 並保留 Commit](http://blog.hsatac.net/2012/04/moving-files-from-one-git-repository-to-another-keeping-commit-history/)」就可以了。不過 go 的部分就沒這麼簡單了。go 的原始碼 host 在 google code 上，採用 hg，因此要想辦法先把他由 hg 轉換成 git 才行。

一開始使用的是 [hg-git](http://hg-git.github.com/) 這套，不過在 gexport 這個過程非常緩慢，不知道是這個套件本身有問題還是 go 的 hg repository 太大了。試了兩天之後只好放棄，改用 [git-hg](http://offbytwo.com/git-hg/) 這套。這套一樣也是使用 python 寫的，不過效率上就挺不錯的。使用上也很方便，直接 `git-hg clone https://code.google.com/p/go/` 出來就是 git 的目錄了。

值得一提的是，使用 homebrew 安裝 git-hg 時，由於 git-hg 有 require [fast-export](http://repo.or.cz/w/fast-export.git) 這個 submodule，但 homebrew 安裝下來的 fast-export 居然不是最新的，導致無法使用。後來自己到 `/usr/local/Cellar/git-hg/HEAD` 把 fast-export 這個目錄移除，再 clone 一份新的 fast-export 就可以正常使用了。

我不想弄亂這個目錄，所以我是在 local 端再 clone 一次這個使用 git-hg clone 下來的 repository，再來作 `git filter-branch` 的動作。另外這個 repository 也順便丟到 github 上當作一個 go 的 git mirror 給有需要的人使用。

產出三個 repositories:

* [https://github.com/golangtw/go.vim](https://github.com/golangtw/go.vim) go 的 syntax plugin

* [https://github.com/golangtw/gocode.vim](https://github.com/golangtw/gocode.vim) gocode 的 autocomplete plugin

* [https://github.com/golangtw/go](https://github.com/golangtw/go) go 的 git mirror

最後再寫一個 script 每天跑一次 cronjob 自動去 sync 就完成啦！

{% gist 3903435 %}