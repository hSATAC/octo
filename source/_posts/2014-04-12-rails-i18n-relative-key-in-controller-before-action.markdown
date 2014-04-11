---
layout: post
title: "Rails i18n Relative Key in Controller Before Action"
date: 2014-04-12 04:42
comments: true
categories: [Rails, RoR]
---

在 Rails i18n 裡面可以用 relative path 像 `t('.key')` 這樣的 shortcut，不過這個 shortcut 吃得是 `"#{ controller_path.tr('/', '.') }.#{ action_name }#{ key }"`。

今天碰到 controller 的 before action 裡面用 relative path 結果 locale yml 編到 before action 的 key，但真正會去 lookup 的是 `action_name` 而不是 before action 的 method name 所以就爆 missing 了。

萬一這個 before_action 之後多加幾個其他的 action 的話很容易就沒改到 locale yml 而爆錯誤，為了保險起見決定把他們都改成 absolute key path. 不過 controller 檔案非常多，所以要寫一隻程式把所有 before action 裡面有用到 relative path 的 t 撈出來。

一開始的想法是用 regex 速解，不過因為 controller 裡面的 t 還滿多的，然後我又很難判斷 before action method 的 scope，於是念頭一轉就直接改用 [Ruby Parser](https://github.com/whitequark/parser) 來做。

直接把 controller 檔案都讀進來，拿 AST 來抓 before actions，再去檢查這些 before action 是否有 call 到 relative keypath 的 t。用起來還滿方便的，效率也不差，一下子就寫完了。

程式碼放在 [Github](https://github.com/hSATAC/parse-relative-key)，不過這麼特定目的東西應該是無法重用，放著以後有需要的時候回來看一下。

最後就是...i18n 沒事還是不要用 relative key 比較好...散在 controller, helper, service 裡面到時要搬移 code 或者作 refactor 的時候就麻煩了。動態語言重構不像靜態語言這麼便利啊...。