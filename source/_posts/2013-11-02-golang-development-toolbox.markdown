---
layout: post
title: "Go Development Toolbox"
date: 2013-11-02 13:24
comments: true
categories: [Golang, TDD]
---

這次去北京參加 RubyConfChina 2013 的來回飛機上，寫完了一個練習用的小專案：[gosnake](https://github.com/hSATAC/gosnake)，很明顯就是用 Go 寫的貪食蛇。會挑貪食蛇來練習，是因為之前在 iOS Dev Bootcamp 參加 [zonble](https://twitter.com/zonble) 的 workshop，題目就是寫一個貪食蛇，覺得這個題目拿來練習真的是挺不錯的。

先來看看動起來的樣子：
<script type="text/javascript" src="http://asciinema.org/a/6115.js" id="asciicast-6115" async></script>

程式本身很簡單，沒什麼好說的，倒是想紀錄一些開發上使用到的工具。
<!-- more -->

### 開發環境

首先我們都知道 Go 有所謂的 `GOPATH`，src, pkg 等等東西都會安裝在這裡。不過每個專案都有自己的套件相依性，再加上如果東西一直裝，這個目錄會很大一包。所以一般建議會在開發專案時，把 `GOPATH` 設定到專案目錄底下，以免互相污染。[c9s](http://twitter.com/c9s) 有寫了一個 script [goenv](https://github.com/c9s/goenv) 來簡化這個步驟，我使用的則是我 [fork 的版本](https://github.com/hSATAC/goenv)。

使用的方式很簡單，要開發這個專案的時候，切到專案目錄下 `source goenv` 即可。你的專案目錄下會建立一個 `go` 目錄，並且 `GOPATH` 會被指向此處。

### 套件管理

[goenv](https://github.com/c9s/goenv) 其實已經可以解決大部分的問題，如果把 `go` 目錄也直接 commit 進去的話其實就可以解決 reproducible build 的問題。不過還是希望能有類似 `bundler` 這樣的工具。

試了兩套 [gom](https://github.com/mattn/gom) 跟 [godep](https://github.com/kr/godep)。我自己是比較喜歡 gom 的 API 設計，而且他的 star 數也比較多。但是在 `gom gen gomfile` 自動掃描生成 `Gomfile` 這邊一直出現問題，會掃到很多不相關的東西。相對的同樣功能的 `godep save` 就沒什麼問題。並且也支援 `godep save -copy` 直接把整個 dependencies tree 複製到專案目錄下，讓你用 `GOPATH` 的方式使用，目前使用起來 [godep](https://github.com/kr/godep) 是一個挺不錯的選擇。

[godep](https://github.com/kr/godep) 會把你指定的每個 package 裝到 tmp 目錄下，使用 `godep path` 就可以看到。

用 `godep` 指令包 `go` 指令的話就會從這些地方載入套件，有點像是 bundler 的感覺。`godep go build`, `godep go test`。

目前我還是 goenv 和 godeps 並行，看看將來的發展怎麼樣。也希望官方能儘快解決這個問題，不然現在第三方的 Go package management tool 以一個禮拜一套的速度在推出啊...。

更詳細的 [godep](https://github.com/kr/godep) 教學，可以參考這篇文章： [Manage Dependencies With GODEP](http://www.goinggo.net/2013/10/manage-dependencies-with-godep.html)

### 測試套件

可能是 Ruby 寫慣了，總覺得 Go 內建的測試語法不太親民。我在這個專案使用了 [testify](https://github.com/stretchr/testify) 的 `assert` 套件，可以寫出這樣的語法：

{% codeblock lang:go %}
  // assert equality
  assert.Equal(t, 123, 123, "they should be equal")

  // assert inequality
  assert.NotEqual(t, 123, 456, "they should not be equal")

  // assert for nil (good for errors)
  assert.Nil(t, object)

  // assert for not nil (good when you expect something)
  if assert.NotNil(t, object) {

    // now we know that object isn't nil, we are safe to make
    // further assertions without causing any errors
    assert.Equal(t, "Something", object.Value)

  }

}
{% endcodeblock %}

[testify](https://github.com/stretchr/testify) 除了 `assert` 之外，也提供了 `http`, `mock`, `suite` 可使用，算是滿全面的測試工具。相類似的套件還有 [gocheck](http://labix.org/gocheck) 這個也滿受歡迎的。

另外兩個我覺得不錯的測試工具是 [Goconvey](https://github.com/smartystreets/goconvey) 以及 [PrettyTest](https://github.com/remogatto/prettytest)。

[GoConvey](https://github.com/smartystreets/goconvey) 可算一套完整的 BDD/TDD 測試框架，使用了自己的語法，離原生的 `testing` 又更遙遠了，帶有 WebUI 以及漂亮的 terminal output 可以很清楚產出測試報表。

[PrettyTest](https://github.com/remogatto/prettytest) 則是用自己的 assert 來產出清晰的 terminal output，也可以搭配上面提到的 [gocheck](http://labix.org/gocheck) 使用。

還有另外非常多的工具可以參考這篇：[Go Testing Toolbox](http://nathany.com/go-testing-toolbox/)

### 其他工具

[go-spew](https://github.com/davecgh/go-spew) 噴東西相當好用，什麼都可以噴，可以看一下他的 sample output 超威：

```
(main.Foo) {
 unexportedField: (*main.Bar)(0xf84002e210)({
  flag: (main.Flag) flagTwo,
  data: (uintptr) <nil>
 }),
 ExportedField: (map[interface {}]interface {}) {
  (string) "one": (bool) true
 }
}
([]uint8) {
 00000000  11 12 13 14 15 16 17 18  19 1a 1b 1c 1d 1e 1f 20  |............... |
 00000010  21 22 23 24 25 26 27 28  29 2a 2b 2c 2d 2e 2f 30  |!"#$%&'()*+,-./0|
 00000020  31 32                                             |12|
}
```

[termbox-go](https://github.com/nsf/termbox-go) 則是寫 CUI 程式的好幫手，非常容易使用。之前那個用 terminal 看股票的 top [mop](https://github.com/michaeldv/mop) 也是用這個寫的。