---
layout: post
title: "8 款我最近常用的 command line 工具"
date: 2012-09-28 13:45
comments: true
categories: [commandline, mosh, mitmproxy, pdsh, pdcp, rpdcp, htop, goaccess, ack, ag, the_silver_searcher, tig, bashmarks]
---

介紹八款我最近常用的 command line 工具，對開發很有幫助。
<!--more-->

## 1. Mosh ##

### 說明 ###

不會斷線的 ssh
[http://mosh.mit.edu/](http://mosh.mit.edu/)

### 安裝 ###

client 和 server 都需要安裝
{% codeblock %}
packer mosh (Archlinux)
yum install mosh (Centos)
brew install mobile-shell (MacOS)
{% endcodeblock %}

### 使用 ###

{% codeblock %}
mosh ash_wu@myserver.com
mosh myserver.com -- screen -rx
{% endcodeblock %}

## 2. Mitmproxy ##

### 說明 ###

middleman proxy 可用來 debug , fiddler 的 *nix 版

[http://mitmproxy.org](http://mitmproxy.org)

### 安裝 ###

使用 python 套件管理 pip 安裝

有 https 需求的話則需要安裝他的憑證

{% codeblock %}
pip install mitmproxy
{% endcodeblock %}

### 使用 ###

{% codeblock %}
mitmproxy
mitmdump
{% endcodeblock %}

### 擴充 ###

mitmproxy 提供許多 hook 可以自訂擴充，以 python 編寫即可。可參考我的文章

[http://blog.hsatac.net/2012/08/mitmproxy-modify-request-host-and-port-howto/](http://blog.hsatac.net/2012/08/mitmproxy-modify-request-host-and-port-howto/)
{% codeblock %}
mitmproxy -s test.py
{% endcodeblock %}

## 3. pdsh/pdcp/rpdcp ##

### 說明 ###

一次大量對許多機器下指令/複製檔案

### 安裝 ###

要使用 pdcp 的話 client 和 server 都要裝
{% codeblock %}
packer pdsh (Archlinux)
yum install pdsh (Centos)
brew install pdsh (MacOS)
{% endcodeblock %}

### 使用 ###

{% codeblock %}
pdsh -w web[01-10],static[7,9-10] ls
pdcp -w ash_wu@dmyserver[1-2].com test.py /home/ash_wu/
{% endcodeblock %}

## 4. htop ##

### 說明 ###

better top. 可以直接看 process tree, 直接砍掉

[http://htop.sourceforge.net/](http://htop.sourceforge.net/)

## 5. goaccess ##

看 apache/nginx log

[http://goaccess.prosoftcorp.com/](http://goaccess.prosoftcorp.com/)

### 使用 ###

{% codeblock %}goaccess <apache_access_log or nginx_access_log>{% endcodeblock %}

## 6. ack, ag ##

### 說明 ###

Ack - Better than grep

Ag - Better than Ack

比 grep 更方便好用

[http://betterthangrep.com/](http://betterthangrep.com/)

[https://github.com/ggreer/the_silver_searcher](https://github.com/ggreer/the_silver_searcher)

### 安裝 ###

{% codeblock %}
packer the_silver_searcher
brew install the_silver_searcher
{% endcodeblock %}

### 同場加映 ###

ack.vim

[https://github.com/mileszs/ack.vim](https://github.com/mileszs/ack.vim)

ag.vim

[https://github.com/epmatsw/ag.vim](https://github.com/epmatsw/ag.vim)

## 7. tig ##

git CUI client

[https://github.com/jonas/tig](https://github.com/jonas/tig)

## 8. bashmarks ##

### 說明 ###

快速在目錄間切換

[https://github.com/huyng/bashmarks](https://github.com/huyng/bashmarks)

### 安裝 ###

{% codeblock %}
git clone git://github.com/huyng/bashmarks.git
make install
source ~/.local/bin/bashmarks.sh from within your ~.bash_profile or ~/.bashrc file
{% endcodeblock %}

### 使用 ###

{% codeblock %}
s <bookmark_name> - Saves the current directory as "bookmark_name"
g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"
p <bookmark_name> - Prints the directory associated with "bookmark_name"
d <bookmark_name> - Deletes the bookmark
l                 - Lists all available bookmarks
{% endcodeblock %}
