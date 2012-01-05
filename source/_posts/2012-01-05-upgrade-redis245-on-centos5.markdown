---
layout: post
title: "在 CentOs 5 上升級 Redis 2.4.5"
date: 2012-01-05 13:51
comments: true
categories: [centos, redis]
---
CentOS 5 上的 Redis 套件只有到 2.0
最近用一套 [PHP-Resque](https://github.com/chrisboulton/php-resque) 需求 Redis 2.2 以上，只好手動升級了。

首先抓下最新穩定版解壓
```
wget http://redis.googlecode.com/files/redis-2.4.5.tar.gz
tar zxvf redis-2.4.5.tar.gz
cd redis-2.4.5
make
```
跟原本的 redis 2.0 裝在同一個目錄
```
sudo make PREFIX=/usr install
```
再把新的 config 檔蓋過去
```
sudo cp redis.conf /etc/
```
為了讓原本的 init script 正常運作
redis.conf 要稍微修改
```
daemonize yes
...
pidfile /var/run/redis/redis.pid
```
原本 redis-server 是裝在 /usr/sbin 新的是裝在 /usr/bin
把 /usr/sbin/redis-server 覆蓋過去
```
sudo mv /usr/bin/redis-server /usr/sbin/
```

大功告成。
