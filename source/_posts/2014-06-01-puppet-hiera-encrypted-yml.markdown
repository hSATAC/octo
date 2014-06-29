---
layout: post
title: "Puppet Hiera Encrypted YAML"
date: 2014-06-01 02:04
comments: true
categories: [Puppet, Hiera, eyaml]
---

在 Puppet 中一些設定大多都是透過 hiera 來取得。 Hiera 最常見，也是預設的 backend 是 YAML 檔。不過有些機敏資訊諸如 API key 或密碼等等，總是不想直接毫無保護的存進 git repository 中，以往我的作法是使用 [Hiera-gpg](https://github.com/crayfishx/hiera-gpg) 來加密 YAML 檔，不過一來 gpg 頗為麻煩，二來他是整個檔案都加密，但有時我們只需要修改一些無傷大雅的設定，比如 cluster number 之類的，為此再抽一個加密的檔案專門放這些重要資訊，又破壞了原本的設計。

這次改用了 [Hiera-eyaml](https://github.com/TomPoulton/hiera-eyaml) 這個 plugin，他有許多特色和功能，最大的特點當然是他支援片段加密，也就是一個 YAML 檔，只有需要加密的地方再加密即可。我們的檔案可能就會長成這樣：

```
---
account: hSATAC

password: >
    ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
    NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
    jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
    l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
    /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
    IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]
```
<!--more-->
這樣不用特別破壞原本的目錄結構，要改一般設定時也不需要麻煩的加解密，非常方便。使用公鑰即可加密，所以可以把 public key 放在 repo 中，私鑰給相關權限人等即可。

使用上非常容易，基本上只要在需要用到的地方(例如你開發的電腦，以及 puppet master)透過 gem 安裝 `hiera-eyaml` 即可。

不過實際上我在配合 [apt.puppetlabs](http://apt.puppetlabs.com/) 提供的 apt 套件時卻發生了問題，追了一下才發現因為 apt.puppetlabs 提供的 puppet 是直接安裝到 `/usr/lib/ruby/vendor_ruby/` 下面，所以直接用了一點暴力的方式來解決這個問題：

``` bash
#!/bin/bash
gems=( "hiera-eyaml-2.0.2" "trollop-2.0" "highline-1.6.21" )

for gem in "${gems[@]}"
do
    wget http://rubygems.org/downloads/$gem.gem --quiet
    gem unpack $gem.gem
    sudo cp -r $gem/lib/* /usr/lib/ruby/vendor_ruby/
    rm -rf $gem*
done
```

自己手動把 gem 抓下來以後 unpack 也一起塞進 vendor_ruby 中就搞定了。如果你正常使用 gem 安裝 puppet 的話，應該直接安裝 hiera-eyaml 就可以了。