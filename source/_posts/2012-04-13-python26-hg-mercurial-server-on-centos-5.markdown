---
layout: post
title: "在 CentOS 5 上安裝 Python26, hg, mercurial-server"
date: 2012-04-13 10:41
comments: true
categories: [CentOS, Python, hg, mercurial, mercurial-server]
---

筆記一下在 CentOS 5 上設定 Python 2.6, hg 以及 mercurial-server。

CentOS 套件庫裡面有 hg ，不過版本很舊，而且 mercurial-server 的 hook 部分會需要 python 2.5+ 的特性，而官方套件庫裡的 hg 相依於 python 2.4，因此套件庫裡面的 hg 就不合用了。

## 安裝 Python 2.6 + hg ##

* 先 `sudo yum install python26 python26-devel` 從 epel 安裝 python 2.6
* 抓下最新的 hg source `wget http://mercurial.selenic.com/release/mercurial-2.1.2.tar.gz` 解壓後不要急著 make，先修改一下 Makefile
* line 9 的 PYTHON 改成 `PYTHON=python26` 讓他抓 python 2.6
* doc 的部份應該是缺 docutils 所以會出錯，不需要 doc 直接砍掉：line 33 改為 `all: build`, line 53 改為 `install: install-bin`

* 接著就可以 `make all && su -c "make install" && hg version`

## 安裝 mercurial-server ##

* 抓下最新 mercurial-server 原始碼解壓
* 一樣先修改 Makefile， doc 的部份一樣移除： line 53 改為 `installfiles: install pythoninstall`
* CentOS 的 useradd 不支援 `--system`，把 `--system` 改成 `-r`。如果 repositories 的 path 想改可以順便修改 `--home` 的值。
* 修改完後 `sudo make setup-useradd` 就安裝好了

## 設定 mercurial-server ##

* 先把自己的 public key 放到 `/etc/mercurial-server/keys/root/` 下，接著要改用 hgadmin 這個 repo 來設定
* check out hgadmin 這個 repo `hg clone ssh://hg@localhost/hgadmin`
* 把 `/etc/mercurial-server/keys` 和 `etc/mercurial-server/access.conf` 複製過來。
* add, commit 後 push，以後就可以用這個 repo 來管理使用者和權限了。
* 原本的 `/etc/mercurial-server/access.conf` 和 `/etc/mercurial-server/keys` 就可以刪除了。

### Redmine + hg ###

順便講一下 Redmine 和 hg 搭配，如果設定好後在 repositories 分頁一直 404，看 log 顯示 `hg: error during getting info: hg exited with non-zero status: 255` 的話，多半是檔案權限問題。

可以修改 `redmine/config/environment.rb` 打開 `config.log_level = :debug` 看更詳細的 log

應該可以看到實際執行的 hg 指令，用 redmine user 去執行看看就能抓出問題所在。