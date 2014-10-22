---
layout: post
title: "Docker 1.3 釋出"
date: 2014-10-22 11:09
comments: true
categories: [Docker, devOps]
---

[Docker 1.3](https://blog.docker.com/2014/10/docker-1-3-signed-images-process-injection-security-options-mac-shared-directories/) 釋出。

最方便的一個地方是多了一個 `docker exec` 可以 inject 新的 process 到正在執行中的 docker container 中，只要下 `docker exec -i -t <container id> /bin/bash` 就可以進 shell 了， debug 方便許多，不需要再像之前一樣用各種 hack 例如 `lxc-attach` 或者 endpoint script 最後下 `/bin/bash` 之類的 workaround 來解了。

再來就是 boot2docker 在這版也解了 OSX 的 mount volume 的問題，可以正確 mount 到 Mac 本機，一樣可以拋棄之前的第三方 workaround 了。
