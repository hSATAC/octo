---
layout: post
title: "Duplicate Production Requests for Testing"
date: 2014-10-21 00:09
comments: true
categories: [gor, Go, devOps]
---

當我們上新的架構或者調整資料庫參數等等的時候，總希望能夠用 production 環境來測試才比較準確，不過這麼重大的改變不能隨便拿正式環境和使用者當白老鼠；就算使用 production 資料庫的 dump, 也無法重複真正使用者的行為。

一般常用的方式是偷偷把 production 環境的流量複製一份，導到測試機器/環境去，觀察看看行為是否符合預期。

相較於以往看到較為複雜的 solution, 這邊介紹一個用 Go 開發的工具 - [gor](https://github.com/buger/gor)
<!--more-->

## 簡介

gor 已經發展了一年多了，進展的非常快。現在是一個簡單又非常好用的工具。可以監聽你指定的 port, 把流量轉到其他機器、或者 dump 成檔案，之後可再從這個檔案 replay、如果有統計分析的需求，也可以直接 redirect 進 elasticsearch 中再進行處理。


## Usage

這邊列幾個基本常用的用途：

* 把 request dump 到檔案

`sudo ./gor --input-raw :80 --output-file requests.gor`

* 從檔案 replay 流量 (限定 GET)

`sudo ./gor --input-file requests.gor --output-http http://10.2.7.202 --output-http-method GET`

* 直接複製流量丟到測試機

`sudo ./gor --input-raw :80 --output-http http://10.2.7.202 --output-http-method GET`

注意：這個動作會比較吃 CPU, 官方文件是建議開兩個 process 一個錄流量，一個丟到 output.

除此之外還有很多功能，例如各種 regex, filter, 插入 header, http basic auth, 丟到多個機器...等等。
