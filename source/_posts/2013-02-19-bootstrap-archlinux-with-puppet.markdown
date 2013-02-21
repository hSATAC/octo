---
layout: post
title: "使用 Puppet 快速佈署 Archlinux"
date: 2013-02-19 17:51
comments: true
categories: [Archlinux, puppet]
---

筆記一下安裝步驟...。

## Install Archlinux

由於 Archlinux 本身沒有提供方便的安裝模式、因此我們使用 [@helmuthdu](https://twitter.com/helmuthdu) 的快速安裝 script [AUI](https://github.com/helmuthdu/aui)，安裝完成後再使用 puppet bootstrap 環境

* 放入 CD 選擇 x64_64 開機
* 執行 `curl hsatac.net/getaui | sh`
* 進入 helmuthdu-aui-xxxx 目錄
* 執行 `./aui --ais` 進入安裝程式
* 輸入 1-14 執行全部安裝步驟

ps. 如遇特定機種無法使用 grub2 可改用 syslinux bootloader

## Reboot

安裝完成重開機後後首先設定讓網路能通
可參考[官方wiki](https://wiki.archlinux.org/index.php/Network_Configuration)

如欲使用 dhcp 可執行 `systemctl start dhcpcd`
`systemctl enable dhcpcd` 開機自動執行

* 回到 helmuthdu-aui-xxx 目錄
* 執行 `./aui` 繼續安裝
* 新增使用者步驟必須執行，因後續步驟需用 sudo
* AUR helper 選擇 yaourt 
(Yaourt 和 packer 大同小異，但因 puppet 使用 yaourt 所以改用。)
* 後面的 setup 可跳過，或者裝 Basic Setup 即可，這邊都是 桌面環境相關
* 設定 /etc/resolv.conf

## 使用 puppet

puppet 可使用 master-agent 架構或者單機(solo) 安裝，詳見 puppet wiki

* `yaourt puppet` 安裝 puppet
* 在 /etc/hosts 設定 puppet master hostname 並在 /etc/puppet/puppet.conf [agent] 區塊設定 `server = xxx` (hostname 要跟 master hostname 一樣不然憑證不會過)
* run `puppet agent --test` 會出現沒有憑證訊息
* 回到 puppet master 執行 `puppet cert list` 會看到待簽署的憑證
* 執行 `puppet cert sign [hostname]` 簽署
* 記得在 master 的 /etc/puppet/manifests/site.pp 設定新的 node 定義
* 回到 agent 執行 `puppet agent --test` 進行安裝