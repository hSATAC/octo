---
layout: post
title: "開發 Golang 的 IDEs"
date: 2012-09-19 00:34
comments: true
categories: [golang, IDE, editor]
---

介紹一些開發 Golang 的 IDEs

首先是我慣常使用的 [Sublime Text 2](http://www.sublimetext.com/2) 搭配  [gosublime](https://github.com/disposaboy/gosublime) 外掛。

![gosublime](/images/golang_ides/subl.png)
<!--more-->
以及也是我慣用的 vim + [gocode](https://github.com/nsf/gocode/) 

在 `$GOROOT/misc/vim` 下已經有提供給 vim 使用的 syntax, indent, plugin 等，全部複製到 `~/.vim` 下面即可。如果不知道 go 安裝的位置可以使用 `go env` 來查詢。

按 gocode 的說明安裝完成後就可以在 vim 裡面使用 golang 的 autocompletion 了。

![vim + gocode](/images/golang_ides/vim.png)

提了 vim 也不得不提 emacs. Emacs 一樣使用 `$GOROOT/misc/emacs` 下提供的檔案以及搭配 gocode 做自動完成。

![emacs + gocode](/images/golang_ides/emacs.png)

再來介紹一個大陸開發的 [golangide](http://code.google.com/p/golangide/) 相當優秀，也是跨三平台版本。安裝就可以使用了，不需要多餘的設定。

![golangide](/images/golang_ides/golangide.png)

[goeclipse](http://code.google.com/p/goclipse/)
Golang 的 Eclipse plugin…Eclipse 現在完全是個萬能 editor.

![goeclipse](/images/golang_ides/goeclipse.png)

[zeus](http://www.zeusedit.com/go.html) 是一個 windows 的 programming editor，也提供了深度支援開發 golang。

<iframe width="560" height="315" src="http://www.youtube.com/embed/CZ5Yl0KnbKs" frameborder="0" allowfullscreen></iframe>

<iframe width="560" height="315" src="http://www.youtube.com/embed/84i7H-E0YUM" frameborder="0" allowfullscreen></iframe>

Zeus 整合的相當好，包括 debugger, build manager, package manager 都有提供，比較有完整 IDE 的感覺。但完整版是要付費購買的。不管如何，選擇一個喜歡，順手合自己意的才是最重要的。