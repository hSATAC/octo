---
layout: post
title: "2010 MBP 升級 SSD 與 Fusion Drive"
date: 2012-11-26 15:15
comments: true
categories: [Mac]
---

我現在用來開發 iOS 的電腦是公司提供的一台 Macbook Pro 13" 2010 mid 4G ram。使用上還算堪用，但時不時的 lag 以及 freeze 實在非常挑戰開發者的耐心。尤其當我 Xcode 開著，git 切換 branch 然後 Xcode 重新 index 的時候簡直慘不忍睹。

畢竟電腦還是自己在用，開心順手最重要，所以決定自己投資一點下去升級。因為光碟機很少在用，所以查了一下以前看過的硬碟轉接托架，意外發現非常便宜才 200 多元，還附拆機工具組。參考[玩物喪誌](http://blog.lyhdev.com/2012/10/apple-macbook-pro-ssd.html)的心得一樣購買 Jeyi 的硬碟托架以及 Micron M4 7mm 超薄 SSD。別人踩過一次的雷就不用再踩了。

把光碟機拆下，原本的位置裝上 SSD。內裝的硬碟則不動。如果把內裝硬碟裝在硬碟托架的話硬碟的感震偵測會無法作用。拆機安裝部分參考 [ifixit](http://www.ifixit.com/Guide/MacBook+Pro+13-Inch+Unibody+Mid+2010+Optical+Drive+Replacement/4318/) 的說明。最需要注意的是螺絲不要滑牙了。

在拆機的過程中也順便把家裡的 Mac mini server 8G 出包版的記憶體拆下與 MBP 的 4G 對調，兩組都是 DDR 3 1066 的規格，對換毫無困難。

裝上以後開機確認是否有抓到及辨識到 SSD 固態硬碟，link speed 也跑到 SATA II 全速。接著使用 Carbon Copy Cloner 先把原本的系統碟備份到外接 USB 硬碟。再改用 USB 硬碟開機，準備做 Fusion Drive。

會使用 Fusion Drive 的原因是 SSD 實在不夠大，原本要自己安排哪些目錄放 SSD，哪些少用放 HD ，但是使用 Fusion Drive 技術的話可以將 SSD 與 HD 變成一顆邏輯磁碟，而系統會自己幫你判斷哪些常用的檔案放在 SSD, 不常用的則移去 HD ，兼顧了速度與容量和便利性，似乎是個不錯的選擇，所以決定試試看。

參考 [Fusion drive on older Macs? YES!](http://jollyjinx.tumblr.com/post/34638496292/fusion-drive-on-older-macs-yes-since-apple-has) 的說明做好 Fusion Drive，再用 Carbon Copy Cloner 把外接 USB 硬碟的資料複製回做好的 Fusion Drive。值得一提的是 Fusion Drive 似乎無法製作 Recovery Partition，這部份只好無視他的 warning 。

最後把 Fusion Drive 設為開機碟重開就完成了這次的升級。相關照片和紀錄都放在 [Facebook 相簿](http://www.facebook.com/media/set/?set=a.4857081506317.2196205.1275503618&type=1&l=bb8d23d675) 中。