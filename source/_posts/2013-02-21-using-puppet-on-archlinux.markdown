---
layout: post
title: "ArchLinux 使用 Puppet 注意事項"
date: 2013-02-21 14:12
comments: true
categories: [Archlinux, puppet]
---

想在 ArchLinux 使用 Puppet 有一些需要注意的地方，在這邊順便補充一下。

## systemctl 路徑

Arch 在之前的改版已經把 `/bin/systemctl` 移到 `/usr/bin/systemctl` 下，但 Puppet 還是抓 `/usr/systemctl` 導致找不到 systemd 這個 provider ，這個問題已經在 Puppet 3.1 修改，也可以自己手動 link 一下。

## 套件庫需更新到最新版

Arch 每次都要先 `pacman -Syy` 一下不然 package 會無法使用。

以上這兩個問題我有寫了一段 module

{% codeblock %}
# For Archlinux. This issue will be fixed in puppet 3.1

class archfix {
    file {'/bin/systemctl':
        ensure => link,
        target => '/usr/bin/systemctl',
    }   
    exec {'pacman -Syy':
        path => ["/usr/bin"]
    }   
}
{% endcodeblock %}

在 manifest 中利用 stage 功能先執行 archfix 這個 module 就可以了。

{% codeblock %}
node 'devm3' {
    stage { 'pre': }
    class {
        "archfix": stage => "pre"; 
    }   
    Stage["pre"] -> Stage["main"]

	# include other modules...
}
{% endcodeblock %}

## Openrc & Systemd

ArchLinux 現在還有很多套件同時支援 openrc 的 initscript 和 systemd，Puppet 會偵測到兩個 provider 但是他會選擇用 initscript 。可以在 service resource 指定 `provider => systemd` 即可。