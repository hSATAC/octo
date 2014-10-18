---
layout: post
title: "使用 Docker 建置 QA 環境"
date: 2014-10-18 16:58
comments: true
categories: [Docker]
---

這篇是延續上一篇[《整合 Jenkins 和 Docker》](/2014/06/working-with-docker-and-jenkins/)，使用 Docker 來建置 QA 環境的想法。

在上一篇有提到，原本的設計是當 Github 收到 Pull Request 時，就讓 Jenkins 來跑測試，如果測試通過，就直接用原本建置出來的 docker image 建立起一個 QA 環境，這樣就可以直接透過連到 `<ticket-number>.qa.domain.internal` 的方式來驗收，確定無誤後再按下 merge 按鈕，然後 trigger 自動關閉此 QA 環境。

不過後來因為這個情境不適合我們的 workflow, 所以最後沒有這樣實做。而是寫成 rake task 來運用。
<!-- more -->
具體的方式是，把整個 docker 中的 app 目錄 mount 出來，然後 nginx 透過 subdomain  來決定 app root 和 proxy_pass backend. 由於可能會有許多 qa 環境同時存在，要弄轉 port 還挺麻煩的，所以這邊都使用 unix domain socket.


## Nginx

先來看一下 nginx 這邊的設定，其實很單純，簡化過後大概就長這樣：

{% gist fba5950eec5e90385015 nginx.conf %}

這樣透過 `newfeature.qa.domain.internal` 就可以連到從 docker 裡面 mount 出來到 `/var/www/newfeature` 這個目錄的靜態檔案和 unix domain socket.

## Makefile

Makefile 是用來 build docker image, 這部分做的事情大致上是切到一個 workspace 目錄，此目錄是我 app 的 git repo, 然後切到我要建置的 QA branch 後開始 build docker image.

{% gist fba5950eec5e90385015 Makefile %}

gem 的部分再上一篇有提過，預先安裝 gem 是為了加速整個建置的過程，這邊會丟到 crontab 每天晚上自動執行更新。

執行 `make qa_branch QA_BRANCH=master QA_DOMAIN=master` 即可建置出特定 branch 的 docker image.

可以看到我直接把 branch name 和 domain name 寫到 app 資料夾中，這樣就不用資料庫來紀錄什麼 domain name 對應什麼 branch 了。

這邊需要注意由於 domain name 用在三個地方：

1. domain
2. 路徑
3. docker image name

比較麻煩的是 domain name 只能有 `-` 不能有 `_`, 而 docker image name 則剛好相反，不能有 `-` 只能有 `_` 所以在輸入名稱的時候要特別注意。由於我外面是包 messaging bot 來下指令，那邊有做檢查，所以這邊就沒有另外再做檢查。

## Rakefile

Rakefile 是拿來啟動 / 關閉 QA 環境用的。

{% gist fba5950eec5e90385015 Rakefile %}

這邊值得一提的是，由於 container build 好，到整個 service run 起來其實還有一段時間差，是用來啟動 service, initial db 等等動作...所以在 app 目錄下會寫一個 `status` file 來判斷現在 app initial 到什麼階段，等他變成 `ready` 後才判斷為建置完成。

## start_rails.sh

這是 QA docker image run 起來後會執行的 script, 比較重要的有兩個部分，一個是上面提的把目前階段寫入 `status` 檔案，讓外面知道現在進行到什麼步驟；另一個則是使用 [socat](http://www.dest-unreach.org/socat/) 把 port 轉為 unix domain socket 再 mount 出去，就可以讓外面的 nginx 跟 docker 內部的 web services 溝通，而不需要處理 docker 的 port 了。

把 8080 port 轉到 `/opt/run/myapp/go.sock`：

`socat UNIX-LISTEN:/opt/run/myapp/go.sock,reuseaddr,fork TCP:localhost:8080` 


{% gist fba5950eec5e90385015 start_rails.sh %}

## Conclusion

這篇的 scripts 有點繁雜，不過概念其實很簡單，只是細節上有不少需要注意的地方。

使用 docker 來建置 QA branch 可以方便快速的建出乾淨的環境，相較以往要處理非常多資料庫 / 轉 port / services isolation 等等問題，實在是輕鬆太多了。