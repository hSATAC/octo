---
layout: post
title: "Nagios 基本設定"
date: 2012-12-11 13:41
comments: true
categories: [nagios]
published: false
---

Nagios 是一個相當萬用的老牌監控軟體，資源和插件都很多。不過由於他的彈性太好，相對設定上就不是很容易上手。這篇文章將會紀錄比較重要的一些基本設定和觀念。

由於不同 distribution 的差異，以下路徑都是 Archlinux 下的，可能會有所不同。

### /etc/nagios/nagios.cfg

所有相關 nagios 本身的設定都在此。如果之後發現有一些預期以外的行為，通常回來這個檔案仔細檢查問題都在這。基礎跑的話可以先不用修改這個檔案的內容。先把監控項目設定起來，最後再回頭來微調就好。

### /etc/nagios/objects

這個目錄是最重要的目錄，所有監控的設定都放在這邊。

### /etc/nagios/objects/templates.cfg

Nagios 設定的方式有點 OO 的感覺，許多設定都是繼承某個原型而來。當然你也可以都不要繼承，每一條都詳細設定，不過這樣寫起來會很繁瑣，日後也不好維護管理。


