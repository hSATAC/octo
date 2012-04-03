---
layout: post
title: "把 Git 中的目錄搬到另一個 Git 並保留 commit"
date: 2012-04-03 21:43
comments: true
categories: [Git]
---

今天在 refactor 公司的 git repository 時，有個需求，是要把原本 A repository 的其中一個目錄抽出來，獨立成 B repository。

原本以為這個需求無法達成，不過做了點研究以後發現是可行的，甚至 B repository 是已存在的 repository 也可以做到！

先說獨立出新的 repository 這個狀況，很簡單，先 git clone 出一個乾淨的 A repository 然後 `git remote rm origin` 不要 track remote。

接著在 git 根目錄下 `git filter-branch --subdirectory-filter <目錄> -- --all` 你就會看到這個目錄以外的東西都不見了，而且相關的 commit log 還在。

如果是要獨立出一個新的 repository 做到這邊就可以結束了。

接著講要把檔案和 commit log 匯到已存在的 B repository：接續上一步，用 `mkdir <你要的目錄>; mv * <你要的目錄>` 把抽出來的檔案都移到你預想要放的目錄 `git add .; git commit` 後 `cd ..` 再用 git clone 把 B repository clone 出來，切到 B repository 的目錄，用 add local repository as remote 的方式 `git remote add repoA ../<A repo 的目錄>` 然後 `git pull repoA master` 就完成了。

參考：[Moving Files from one Git Repository to Another, Preserving History](http://gbayer.com/development/moving-files-from-one-git-repository-to-another-preserving-history/)