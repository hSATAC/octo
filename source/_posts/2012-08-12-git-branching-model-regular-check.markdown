---
layout: post
title: "自動檢查 git branch 是否 merge 過"
date: 2012-08-12 12:28
comments: true
categories: [Git]
---

按照一般 [Git branching model](http://nvie.com/posts/a-successful-git-branching-model/) 來開發，當團隊人數稍多時，管理 Git branch 會變得有些麻煩。Branch 數量多之外，也很難記得哪些 branches 是已經 merge 進主幹、不再需要可以刪除；或者哪些 branches 沒有 merge 進主幹但已經放棄不用。這時就需要一些自動化的 script 幫助管理。
<!--more-->
本來是想全部用 bash 寫，不過功力不夠，最後還是偷懶用 ruby 了。

這個 script 會先檢查哪些 branches 已經 merge 過，如果沒有特殊理由就可以刪除了。也可以把刪除的動作寫在 script 讓他自動化，不過我這邊選擇保留一些手動的彈性。

再來是檢查哪些 branches 已經開很久了(開超過一個月)，卻又沒有 merge 進主幹，這時管理者可以看一下這些 branches 是否已經不再使用，可以刪除。

{% gist 3246217 %}

我們團隊對於 branch 命名有規定，中間一定是八位數字的日期，例如 feature_20120812_sthcool 以便分辨這個 branch 的開創時間。如果沒有這樣的命名規定的話，也可以透過下面這樣的 script 來找出最後 active 的時間。

{% codeblock %}
for k in `git branch|perl -pe s/^..//`;do echo -e `git show --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k|head -n 1`\\t$k;done|sort -r
{% endcodeblock %}