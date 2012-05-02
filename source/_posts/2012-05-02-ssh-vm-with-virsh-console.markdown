---
layout: post
title: "ssh vm with virsh console"
date: 2012-05-02 16:29
comments: true
categories: [kvm, virsh, vm, vnc]
---
最近在玩 kvm，當 guest vm 的 network 環境不確定的時候，可以用 virt-viewer vnc 進去作設定，但總有沒有 X 或不適合使用 GUI 的狀況。這時可以利用 virsh console 這個指令進行連線。不過在 guest vm 要先修改一下設定。

首先修改 guest vm 的 `/etc/grub.conf` ，把 kernel 那行最後加上 `console=tty0 console=ttyS0,1152200`

例如：
{% codeblock %}
kernel /vmlinuz-2.6.32-220.13.1.el6.centos.plus.x86_64 ro root=/dev/mappp
er/vg_w2vm001-lv_root rd_NO_LUKS  KEYBOARDTYPE=pc KEYTABLE=us LANG=en_US.UTF-8 rr
d_LVM_LV=vg_w2vm001/lv_swap rd_NO_MD quiet rd_LVM_LV=vg_w2vm001/lv_root rhgb craa
shkernel=auto SYSFONT=latarcyrheb-sun16 rd_NO_DM console=tty0 console=ttyS0,1152200
{% endcodeblock %}

重開 guest vm 之後，在 host 就可以用 `virsh console <domain>` 直接連到 ssh terminal 啦。