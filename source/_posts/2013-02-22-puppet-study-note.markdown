---
layout: post
title: "Puppet 學習筆記"
date: 2013-02-22 11:38
comments: true
categories: [puppet]
---

前陣子玩了 Puppet…把一些重點和資源紀錄在這邊…
初學 Puppet 的話很建議看一遍[官方教學](http://docs.puppetlabs.com/learning/)，雖然沒有很完整但整個 run 過基礎的概念會有。

## Infrastructure as Code

Puppet 的概念是 infrastructure as code，那跟以往寫 shell scripts 有何不同...？

其實基本上是相通的…但概念層次上高了一層。寫 shell script 主要是加速重複性工作、減少人為疏失，但你也很難去 reuse 這些東西。

Puppet 則是往上拉了一層虛擬層，你只要定義你 infrastructure 的狀態，。可以模組化、重用你程式碼，用清楚易懂的 code 描述套件要怎麼裝，設定檔有哪些，每個 server 之間的關係是怎麼樣...。

Code 就是文件， code 就是你的 infrastructure。不但好寫好讀好維護，更可直接拿來執行。
<!--more-->
## Resource

Puppet 中最重要的東西、以及最基本的基礎元件叫做 resource，例如 file, package, service 這三個就是最常用的 resource ，你可以透過 resource 來指定你的檔案狀態、套件安裝狀態、服務狀態等等。

Resource 列表和用法可參考：[http://docs.puppetlabs.com/references/latest/type.html](http://docs.puppetlabs.com/references/latest/type.html)

resource type 要注意大小寫，當作 metaparameters 的時候寫作 `Type[title]` Type 要大寫。

## Dependencies

我們會撰寫 manifest 檔案來描述 resource，需要注意的是這些 resource 都是 sync 執行的，並不是順序執行，因此就會有相依性的問題產生。

Puppet 提供了 before / require 關鍵字

{% codeblock %}
    file {'/tmp/test1':
      ensure  => present,
      content => "Hi.",
      before  => Notify['/tmp/test1 has already been synced.'],
      # (See what I meant about symbolic titles being a good idea?)
    }

    notify {'/tmp/test1 has already been synced.':}
{% endcodeblock %}

也可以用 chaining 的寫法，以箭頭表示 <- 或 -> 都可以：

{% codeblock %}
    file {'/tmp/test1':
      ensure  => present,
      content => "Hi.",
    }

    notify {'after':
      message => '/tmp/test1 has already been synced.',
    }

    File['/tmp/test1'] -> Notify['after']
{% endcodeblock %}

另外有一組「觸發」的關鍵字叫 notify / subscribe ，可以用 <~ 或 ~> 表示，當前面的 Resource 有更新，會通知後面的 resource 執行。

還有一些狀況 Puppet 會自動處理 dependencies 。這叫 Autorequire。

例如你定義了兩個目錄，其中一個目錄在另一個目錄之下，Puppet 很聰明會自動判斷他們的相依性。又例如你定義 user 和這個 user 的 ssh_authorized_key，Puppet 也會自動處理他們的順序。

## Module

在 Puppet 裡面我們可以寫 class，而 module 就是可重用的 class。放在 modulepath 裡面。

可使用 `puppet apply --configprint modulepath` 查看 modulepath 設定值。

`puppet apply --configprint all` 可看全部設定。

Module 目錄有固定的格式

* `/etc/puppet/module/{module_name}/manifests/init.pp` 這是 module 的 main file

* `/etc/puppet/module/{module_name}/manifests/files` 使用 `puppet://` 來 serve file 的時候會抓這下面的檔案。例如 `puppet:///module/php/php.conf` 就是 ``/etc/puppet/module/php/files/php.conf`。

* `/etc/puppet/module/{module_name}/templates/` module 若有使用 template 就要放在這。

寫好 module 後想測試可執行 `puppet apply -e "include php"` 來測試，想看完整 debug 訊息可加上 `-vd` 參數 `puppet apply -e "include php" -vd`

除了自己寫的 module 以外也可以使用別人寫好的 module 來加快開發速度。

關於 module 設計的一些基本概念可以參考這篇好文：[Simple Puppet Module Structure Redux](http://www.devco.net/archives/2012/12/13/simple-puppet-module-structure-redux.php)

### Puppet Forge

Puppet 提供了一個 module 集中地 [Puppet Forge](http://forge.puppetlabs.com/) 可以直接來此搜尋現成的 module。不過根據我的觀察這些 module 大多都是支援 debian/ubuntu 等主流 distro，若使用其他 distro 的可能要考慮自己寫或是 contribute 。

不管怎樣，可以來這裡參考別人寫的 module 收穫會很多。

安裝 Puppet module 可使用以下指令：

{% codeblock %}
puppet module install puppetlabs-apache --version 0.0.2
puppet module list
puppet module search apache
puppet module uninstall puppetlabs-apache
puppet module upgrade puppetlabs-apache --version 0.0.3
{% endcodeblock %}

更詳細的說明可參考：[Modules Installing](http://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)

## Defined Resource Types

我們可以定義自己的 resource type，透過 `define` 這個關鍵字。跟 class 用法基本上一樣，但是 define 不支援繼承。有點像是 marco 的功能，例如我們可以定義一個 developer 的 resource，把相關的東西都包在一起：

{% codeblock %}
define developer($user = $title, $uid, $ssh_key) {
        $key_seg = split($ssh_key, ' ')
        $ssh_key_title = $key_seg[2]
        $ssh_key_type  = $key_seg[0]
        $ssh_key_hash  = $key_seg[1]
        user {$user:
                ensure => present,
                managehome => true,
                groups => ['wheel', 'users'],
                uid => $uid,
        } ->
        ssh_authorized_key {"${user}_puppet_key":
                ensure => present,
                key => $ssh_key_hash,
                user => $user,
                type => $ssh_key_type,
                name => "${user}_puppet_key",
        } ->
        file {"/home/${user}":
                mode => 0755,
        } ->
        file {"/home/dev/${user}":
                ensure => link,
                target => '/home/$user',
        }
}
{% endcodeblock %}

## Functions

Puppet 提供了一些函數可運用，可透過 `puppet doc --reference function` 指令查看，或者至 [http://docs.puppetlabs.com/references/latest/function.html function list](http://docs.puppetlabs.com/references/latest/function.html function list) 

## Stage

有些狀況想讓不同 module 在不同的 stage 執行，就可以使用 stage 功能。

預設所有 module 都是 default 在 `main` stage，所以可以定義其他的 stage 在 main 之前或之後即可。

詳細參考 [Puppet Run Stages](http://docs.puppetlabs.com/puppet/latest/reference/lang_run_stages.html)

## Puppet 目錄架構

* `/etc/puppet/puppet.conf` 主要設定檔，可參考[官方文件](http://docs.puppetlabs.com/guides/configuring.html)

* `/etc/puppet/modules/` 放你寫的 modules

* `/etc/puppet/manifests/site.pp` 放你的 node 描述檔，也就是你每台伺服器要怎樣定義寫在這。

## Puppet 流程

Puppet 會把我們撰寫的 manifest 檔案 compile 起來並處理其中的 dependencies 後打成一包，再查詢目前系統的狀態後更改系統到我們定義的狀態，如圖示：

![manifest to defined state](http://docs.puppetlabs.com/learning/images/manifest_to_defined_state_unified.png)

### Master-Agent

Puppet 可以採用 Master-Agent 架構，一台 master 據說能承載 5000 個 agents。也可以單機跑，也就是類似所謂的 Chef solo。

Master-Agent 的流程如下圖：

![master agent](http://docs.puppetlabs.com/learning/images/manifest_to_defined_state_split.png)

基本架構就是 master 上 run `puppetmaster` 服務， agent 上 run `puppetagent` 服務。

也可以手動從 agent 觸發，執行 `puppet agent --test -vd`。

### Masterless Puppet

想要使用 masterless puppet 非常容易，只要自己指定你的 modulepath 和你的 site.pp 即可。

`puppet apply --modulepath ./modules manifests/site.pp`

## 其他參考資料

* [Trouble Shooting](http://docs.puppetlabs.com/guides/troubleshooting.html) Puppet 使用上有問題可以先來這邊查查看。

* [Puppet CookBook](http://www.puppetcookbook.com/) 有許多實用案例

* [Puppet Examples](https://github.com/jordansissel/puppet-examples) 有很多東西直接看 code 是最快的...。

* 關於 Archlinux 使用 Puppet 相關可參考我上兩篇文章：[ArchLinux 使用 Puppet 注意事項](http://blog.hsatac.net/2013/02/using-puppet-on-archlinux/)、[使用 Puppet 快速佈署 Archlinux](http://blog.hsatac.net/2013/02/bootstrap-archlinux-with-puppet/)