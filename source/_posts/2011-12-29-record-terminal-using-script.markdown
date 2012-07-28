---
layout: post
title: "用 script 指令來紀錄輸出及輸入"
date: 2011-12-29 14:59
comments: true
categories: [linux,script]
---
假設我們現在要執行一個重要的動作，想要紀錄 terminal 下面每一個輸出和輸入，當然我們可以在每個指令後面用 ```cmd > filename``` 把輸出導向 log 檔，但如果是一連串的動作時就很不方便了。

unix 系列內建一個指令叫 ```script``` ，他可以很方便的紀錄你每一個輸出和輸入。詳細用法可以參考 ```man script``` 。

在這邊講兩個常用的方法，一個是 ```script log.txt``` 會把紀錄存到 log.txt, 用 ```script -a log.txt``` 就可以把新的 log append 到檔案後，不會蓋掉原本檔案。當你動作結束，想停止紀錄時，只要打 ```exit``` 就可以停止紀錄。

另一個是 ```script -C "ls -al" log.txt``` 他會把你指定的指令存到 log.txt 中，這個用法的不需輸入 ```exit``` 。

如果你的 .bash_profile 裏面有用到一些自訂的函數例如 git-autocompletion 之類，那你在使用 script 的時候可能會發現每下一個指令都告訴你 ```command not found```。正確的解法是把你的 function 移到 .bashrc 中，在 .bash_profile 裏面去 source .bashrc 即可。

最後說明一下 log 檔的觀看方式，因為 script 會把所有東西都紀錄下來，包括控制碼這些，所以可以用 ```less -r log.txt``` 或 ```more log.txt``` 來觀看。

如果需要把 log 的控制碼去掉，可以參考下面這個 script:

``` perl
#!/usr/bin/env perl
while (<>) {
    s/ \e[ #%()*+\-.\/]. |
       (?:\e\[|\x9b) [ -?]* [@-~] | # CSI ... Cmd
       (?:\e\]|\x9d) .*? (?:\e\\|[\a\x9c]) | # OSC ... (ST|BEL)
       (?:\e[P^_]|[\x90\x9e\x9f]) .*? (?:\e\\|\x9c) | # (DCS|PM|APC) ... ST
       \e.|[\x80-\x9f] //xg;
    print;
}
```

