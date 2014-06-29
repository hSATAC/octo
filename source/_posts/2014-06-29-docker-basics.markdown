---
layout: post
title: "Docker Basics"
date: 2014-06-29 10:52
comments: true
categories: [Docker]
---

隨著 AWS Elastic Beanstalk [支援 Docker](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.html), Google Computer Engine 也宣布[支援 Docker](https://developers.google.com/compute/docs/containers/container_vms)，以及 Google 最近發表的一些 container 工具例如 [cAdvisor](https://github.com/google/cadvisor) 這套分析 container 資源和效能的軟體，也同時支援 Google 自己的 [lmctfy](https://github.com/google/lmctfy) 和 Docker 來看，Docker 真的是越來越普及了。這個月 Docker 更[釋出了 1.0 版](http://blog.docker.com/2014/06/its-here-docker-1-0/) 標誌著 Docker 已經 production-ready 了。

關於 Docker 的概念這邊不多加著墨，可以直接上 [Docker 官網](http://www.docker.com/) 閱讀。第一次接觸的朋友可以花十分鐘玩一下 [Try Docker](http://www.docker.com/tryit/)。這邊先簡單筆記一些名詞解說和常用的指令。
<!--more-->
## Containers and Images

使用 Docker 時很常見到 container 和 image 這兩個名詞。

Image 是做好的磁碟檔案，可以透過四種方式取得，一種是 `docker pull` 拉下遠端檔案、另一種是 `docker build` 從 `Dockerfile` 開始建置、第三種是 `docker commit` 從某個 container commit 成 image, 第四種則是 `docker import` 匯入。

Container 則是 `docker run` 某個 image 時產生的，可以透過 `docker ps` 查看正在運行中的 containers, 一個 image 可以同時運行好幾個 containers. `docker ps -a` 可以查看所有包含停止運行的 containers. 當 container 停止運行後，磁碟中的檔案會存在該 container 中，但記憶體中的資料都會消失。在 Docker 0.12 版本中使用 cgroup freeze 機制，加入了 `docker pause` 和 `docker unpause` 指令，可以 suspend 和 resume 指定的 container.

會注意到每個 image 和 container 都有一個 hash id, 當你每 commit 一次上去時其實就是透過 aufs 疊了一層檔案上去。

## 常用指令

```
docker ps
# 列出運行中的 container

docker ps -a
# 列出所有 container

docker images
# 列出 image

docker rm <container id>
# 刪除 continer

docker rmi <image id>
# 刪除 image

docker build .
# Build ./Dockerfile 的 image

docker build --rm . 
# Build 但是刪除 intermediate layer, 也就是不會保留中間步驟產生的 container

docker build --no-cache . 
# 不使用 cache, 會從頭重新 build

docker build -t kktix/base . 
# build 完以後給他一個 tag kktix/base

docker build --rm --no-cache -t base . 
# 組合技

docker run base 
# 跑 base image，會產生一個 container

docker run base /bin/ping www.google.com 
# 跑 base image 並指定指令

docker run -d base /bin/ping www.google.com 
# 用 daemon 模式跑

docker run -i -t base /bin/bash 
# (i)nterative (t)ty 跑 bash 就等於是進去他的 shell

docker run --rm base /bin/ping www.google.com 
# 跑完以後自動把這個 container 砍掉，注意 --rm 和 -d 無法同時下

docker run -v /host/folder:/docker/folder base
# 把 Host 的目錄 mount 到 docker container 的目錄

docker run -d -i -t base /bin/bash 
# 組合技，這樣可以用 docker attach 回去 shell

docker attach <container id> 
# attach 回某個 container
# 如果跑的時候不是給 -d -i -t /bin/bash 的話是不能下指令的
# ctrl + c 會跳出。
# 但如果是 -d -i -t /bin/bash ctrl + c 會 stop 整個 container.
# 在此情況下不想停止 container 只想跳出請用 ctrl + p, ctrl + q
```

## Dockerfile

Dockerfile 是用來建置 Docker image 的檔案，簡介可以直接參考[官方文件](http://docs.docker.com/reference/builder/)，這邊筆記一些容易搞錯的部分。

### ENTRYPOINT, CMD and RUN

* `RUN` 是最基本的，就單純是在 build 的時候跑某個指令。

* `CMD` 則是 `docker run <image> <command>` 時，如果沒有指定 command 時會跑的指令。

* `ENTRYPOINT` 則是設定 `docker run <image> <command>` 時，用來接 command 的指令。預設的 `ENTRYPOINT` 是 `/bin/sh -c` ，例如我們把 `ENTRYPOINT` 改成 `/usr/bin/redis-cli` 這樣當我們跑 `docker run redis monitor` 時，他實際執行的指令就會是 `/usr/bin/redis-cli monitor`。

### ADD vs COPY

`ADD` 會把你指定的檔案或目錄複製到 docker image 中，需要注意的是他不能用 `../` 指定到當前目錄(context) 之外，並且如果你是用 `docker build - < somefile` 這樣的方式也沒辦法使用，因為沒有 context。

`ADD` 和 `COPY` 基本上是一樣的，唯一的差別在於當使用 `ADD` 時，如果檔案是認得的壓縮檔(gzip, bzip2 or xz) 他會自動幫你解壓縮，而 COPY 則不會。

### ONBUILD

`ONBUILD` 是一個很好用的功能，他不會發生在你這個 Dockerfile 的建置過程中，而是「用此 Dockerfile 建置出來的 IMAGE 來建置」的過程才會觸發。

舉例你用現在的 Dockerfile 建立了一個 image 叫做 base, 當有另一個 Dockerfile 使用 `FROM base` 來建置 image 時才會跑 `ONBUILD` 這行。這是一個有點 tricky 但又很實用的功能。

## 小結

Docker 真的是把 linux container 的操作難度降低非常多，也加上了很多實用的功能以及安全性的限制，他可以運用的範圍非常廣，接下來預計寫幾篇我們實際運用 docker 的例子和筆記。