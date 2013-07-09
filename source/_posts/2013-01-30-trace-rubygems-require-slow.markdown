---
layout: post
title: "追蹤 Rubygems require 緩慢紀錄"
date: 2013-01-30 10:18
comments: true
categories: [Ruby]
---

昨天灌了一台新的機器，正準備用 [puppet](http://puppetlabs.com) bootstrap 時卻發現他的 puppet 執行的非常緩慢。追蹤解決問題的過程十分有趣，在這邊紀錄一下。

由於 puppet 執行檔本身是一隻 ruby script，於是開啟了 irb -d 使用 DEBUG 模式直接執行看看該 script 的內容，看看能否看出問題在哪。
<!--more-->
結果是慢在 `require 'puppet'` 這裡。想說是不是 gempath 的問題，先用 gem env 看一下設定和環境變數，感覺一切正常。在使用 gem 指令的過程中，發現 `gem help commands` 這個指令也異常緩慢，而且和 puppet 慢的速度感覺是一樣的。使用 `time gem help commands` 和 `time puppet`
測量，果然兩邊都是慢 20 秒，感覺之間可能有某些關聯。

一度懷疑是硬碟壞軌，使用 `smartctl` 顯示硬碟狀況良好，又開始懷疑是 Ruby 1.9.3-p374 的 bug。但是上網搜尋沒有這樣的狀況，拿另一台舊的機器升級 Ruby 1.9.3-p374 也沒有這樣的狀況。看來是機器本身的問題。

`ruby -d` 和 `irb -d` 都無法提供有用的資訊，只能看出在某個階段會卡住很久，只能往更低階的方向走。

先使用 `ltrace` 來觀察：

{% raw %}
<pre>
# ltrace -r ruby `which gem` help commands
  0.000000 __libc_start_main(0x400860, 4, 0x7fff767d5ce8, 0x4009a0 <unfinished ...>
  0.000301 setlocale(LC_CTYPE, "")                                                                                                            = "en_US.UTF-8"
  0.000577 ruby_sysinit(0x7fff767d5bec, 0x7fff767d5be0, 1, 1)                                                                                 = 0
  0.000319 ruby_init_stack(0x7fff767d5bf8, 0x7fff767d5b30, 0x7fff767d5b30, -1)                                                                = 0
  0.000759 ruby_init(0x7febf8, 0xffffffff, 0, 0)                                                                                              = 0x876f20
  0.005726 ruby_options(4, 0x7fff767d5ce8, 0x877520, 0x7f3c31b59640)                                                                          = 0xad4800
  0.025221 ruby_run_node(0xad4800, 0x7fff767d6fea, 0x877520, 0xad9560
  20.511227 +++ exited (status 0) +++
</pre>
{% endraw %}

只能看出卡在 ruby_run_node 這邊，再翻出 `strace` 試試：

{% raw %}
<pre>
# strace -rT ruby `which gem` help commands
     0.000051 open("/usr/lib/libresolv.so.2", O_RDONLY|O_CLOEXEC) = 5 <0.000012>
     0.000049 read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\220:\0\0\0\0\0\0"..., 832) = 832 <0.000008>
     0.000049 fstat(5, {st_mode=S_IFREG|0755, st_size=84840, ...}) = 0 <0.000007>
     0.000049 mmap(NULL, 2189960, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5, 0) = 0x7fd97dd1e000 <0.000009>
     0.000047 mprotect(0x7fd97dd31000, 2097152, PROT_NONE) = 0 <0.000012>
     0.000048 mmap(0x7fd97df31000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0x13000) = 0x7fd97df31000 <0.000011>
     0.000054 mmap(0x7fd97df33000, 6792, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fd97df33000 <0.000010>
     0.000053 close(5)                  = 0 <0.000007>
     0.000104 mprotect(0x7fd97df31000, 4096, PROT_READ) = 0 <0.000011>
     0.000059 mprotect(0x7fd97e139000, 4096, PROT_READ) = 0 <0.000009>
     0.000048 munmap(0x7fd98213a000, 24363) = 0 <0.000011>
     0.000100 socket(PF_INET, SOCK_DGRAM|SOCK_NONBLOCK, IPPROTO_IP) = 5 <0.000013>
     0.000051 connect(5, {sa_family=AF_INET, sin_port=htons(53), sin_addr=inet_addr("192.168.79.161")}, 16) = 0 <0.000017>
     0.000073 poll([{fd=5, events=POLLOUT}], 1, 0) = 1 ([{fd=5, revents=POLLOUT}]) <0.000009>
     0.000058 sendmmsg(5, {{{msg_name(0)=NULL, msg_iov(1)=[{"\362\36\1\0\0\1\0\0\0\0\0\0\5devm3\0\0\1\0\1", 23}], msg_controllen=0, msg_flags=MSG_EOR|MSG_TRUNC|MSG_DONTWAIT|MSG_FIN|MSG_SYN|MSG_NOSIGNAL|MSG_MORE|MSG_WAITFORONE|0x13a0000}, 23}, {{msg_name(0)=NULL, msg_iov(1)=[{":O\1\0\0\1\0\0\0\0\0\0\5devm3\0\0\34\0\1", 23}], msg_controllen=0, msg_flags=MSG_PROXY|MSG_EOR|MSG_WAITALL|MSG_TRUNC|MSG_DONTWAIT|MSG_SYN|MSG_RST|MSG_WAITFORONE|0x1120000}, 23}}, 2, MSG_NOSIGNAL) = 2 <0.000020>
     0.000081 poll([{fd=5, events=POLLIN}], 1, 5000) = 0 (Timeout) <5.004974>
     5.005030 poll([{fd=5, events=POLLOUT}], 1, 0) = 1 ([{fd=5, revents=POLLOUT}]) <0.000008>
     0.000051 sendmmsg(5, {{{msg_name(0)=NULL, msg_iov(1)=[{"\362\36\1\0\0\1\0\0\0\0\0\0\5devm3\0\0\1\0\1", 23}], msg_controllen=0, msg_flags=MSG_EOR|MSG_TRUNC|MSG_DONTWAIT|MSG_FIN|MSG_SYN|MSG_NOSIGNAL|MSG_MORE|MSG_WAITFORONE|0x13a0000}, 23}, {{msg_name(0)=NULL, msg_iov(1)=[{":O\1\0\0\1\0\0\0\0\0\0\5devm3\0\0\34\0\1", 23}], msg_controllen=0, msg_flags=MSG_PROXY|MSG_EOR|MSG_WAITALL|MSG_TRUNC|MSG_DONTWAIT|MSG_SYN|MSG_RST|MSG_WAITFORONE|0x1120000}, 23}}, 2, MSG_NOSIGNAL) = 2 <0.000015>
     0.000075 poll([{fd=5, events=POLLIN}], 1, 5000^CProcess 7498 detached
 <detached ...>
</pre>
{% endraw %}

可以很明顯看出是往 192.168.79.161:53 問 devm3 ，結果 timeout 了四次，一次五秒剛好 20 秒。

兇手已經呼之欲出了，就是我 =皿=

當時幫這台新機器改了 hostname 以後，忘記修改 /etc/hosts ，導致他自己不認得自己的 hostname。當然那個會 timeout 的 DNS 也是有問題，不過那是關於 djbdns 的另一個故事了...。

最後將 /etc/hosts 改回來就完全正常了。可喜可賀。最難抓的 bug 果然都是最愚蠢的...。

在這邊要感謝 [Debug Hacks 除錯駭客－極致除錯的技巧與工具](http://www.tenlong.com.tw/items/9862765674?item_id=481936) 一書的譯者，事實證明寫 scripting language 也是要會一些基礎 debug 技巧的！推薦各位購買這本書。