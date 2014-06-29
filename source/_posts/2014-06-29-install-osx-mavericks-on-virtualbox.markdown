---
layout: post
title: "在 Virtualbox 中安裝 OSX Mavericks 10.9"
date: 2014-06-29 09:58
comments: true
categories: [Mac, Virtualbox]
---

筆記一下在 Virtualbox 中安裝 OSX 10.9.3 的方式，裝一個乾淨的 Mac vm image 作為測試環境或者 CI 編譯用的 VM 來說相當實用。

以下說明略過 Virtualbox 安裝以及使用的部分，請自行參考 Virtualbox 說明文件。以下步驟在 Virtualbox 4.3.12 測試成功。

1. 從 AppStore 下載 OSX 安裝檔，不需要進行安裝。

2. `$ gem install iesd`

3. `$ iesd -i /Applications/Install\ OS\ X\ Mavericks.app -o Mavericks.dmg -t BaseSyste`
這個步驟做完在家目錄會多一個 Mavericks.dmg 檔案

4. 建立一個新的 Virtualbox 虛擬機器，選 OSX Mavericks 建立好以後先不要開機，進入設定 > 系統 > 晶片組選 PIIX3 然後確定 EFI 有打勾。

5. `$ VBoxManage modifyvm <vmname> –cpuidset 1 000206a7 02100800 1fbae3bf bfebfbff`
vmname 請帶入你設定的虛擬機器名稱 (可使用指令 VBoxManage list vms 查看)

6. 啟動虛擬機，會要求啟動磁碟，選剛剛的 Mavericks.dmg 經過一段開機時間後就會進入安裝畫面，依照正常程序安裝。

Ref: [How to install OS X on VirtualBox](http://www.robertsetiadi.net/install-os-x-virtualbox/)


