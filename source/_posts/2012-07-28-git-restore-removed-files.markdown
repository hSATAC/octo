---
layout: post
title: "Git 救回已刪除的檔案"
date: 2012-07-28 20:30
comments: true
categories: [Git]
---

在 Git 操作的過程中，有些檔案是無法用 git checkout 救回來的。這些稱之為 unreachable files 。例如你 git add 了，但還沒 commit 就 pull ，這時這些檔案會被刪除，但因為沒有 commit 所以無法用 reset 救回。並且在 git reflog 裡面也不會有紀錄。

還好 Git 非常萬能，可以使用 `git fsck --cache --unreachable` 會列出一堆檔案的 bash ，再使用 `git show <hash>` 逐一檢視檔案內容即可救回失去的檔案。
