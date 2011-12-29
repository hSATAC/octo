---
layout: post
title: "Vim runtime 不需存檔檢查 PHP 語法"
date: 2011-12-22 17:29
comments: true
categories: [vim, php, syntax]
---
之前 vim PHP syntax check 都是跟存檔綁在一起，同事想要不用存檔就可以檢查，就弄了一下。

{% gist 1496197 %}

用法直接 ```:call PHPsynCHK()``` 即可，可以自己綁定熱鍵。