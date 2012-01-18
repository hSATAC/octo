---
layout: post
title: "Youtube 加入我的最愛後自動抓檔上傳至 Google Music"
date: 2012-01-17 19:33
comments: true
categories: [Ruby, Google Music, Youtube]
---
這個標題很冗長，不過正是 Youtube 加入我的最愛後自動抓檔上傳到 Google Music 。

這個需求是這樣來的，我常常在 Youtube 聽到喜歡的歌，習慣性按加入最愛，隨時可以拿出來重複播放。不過在最近都用 Google Music 來管理我的音樂庫，行進時也可以用 Android 上的 Google Music App 聆聽音樂。

但這樣一來，就要透過 Youtube Downloader 等網站或軟體抓下影片檔後再轉檔、上傳到 Google Music ，這樣實在是太麻煩了。

有沒有什麼方法可以把這個過程自動化呢？第一個想到的是利用 ifttt 。不過 ifttt 要達成這個功能需要繞許多彎路，最後決定自己寫一個。
<!--more-->
想法很簡單，大概分為四部分：

* 讀取 Youtube 我的最愛

* 抓到有新增就取得資訊下載影片

* 透過 ```ffmpeg``` 之類轉為 mp3 

* 透過 Google Music Manager 上傳

做了一番 survey 後發現 [youtube-dl](https://github.com/rg3/youtube-dl) 這個工具實在非常好用。他是用 python 寫的一個 script ，只要丟網址給他就會幫你下載。更棒的是他連 ```ffmpeg``` 都接好了，加上參數就可以直接輸出成 mp3 檔案。

抓取的指令是：

```youtube-dl -o "%(title)s.%(ext)s" -q --extract-audio --audio-format "mp3" "[youtube_url]"```

剩下的工作就只剩下讀取 Youtube 我的最愛，判斷加入的時間。想來應該很簡單，不過這部份卻卡了一兩個小時。

原因是 **Youtube 的 API 寫的太不清楚啦！！！**

根據 [GData Youtube API](http://code.google.com/intl/zh-TW/apis/youtube/2.0/developers_guide_protocol_favorites.html#Retrieving_favorite_videos) ：

> The ```<published>``` tag in a favorite videos feed entry identifies the time that the video was marked as a favorite and not the time that the video was published.

用 ```<published>``` 這個欄位就可以取得這筆影片新增到我的最愛的時間，這樣就可以用來判斷是否是新加入的項目。

但是他從頭到尾沒有提到 **這個 API 要用 v=2 來連這個欄位才會有效** 這件事。如果沒有指定 version ，這個欄位出來的值是影片上傳時間，卡在這邊超久的啊。

總之用一個檔案來記錄上次抓取的時間，就可以達成原本的目的了。

記得最後把 Google Music Manager 設定成這個目錄，這樣轉好的 mp3 就會自動上傳到 Google Music 啦。

所有的程式碼在這裡。 

[https://github.com/hSATAC/youtube-favorite-to-google-music](https://github.com/hSATAC/youtube-favorite-to-google-music)

### 附錄

其實原本的需求是抓下來以後先存進 itunes 再上傳到 Google Music ，但是後來因為現在沒在用 itunes 所以簡化了。

如果有這個需求的朋友可以參考 [Folder Actions and iTunes](http://dougscripts.com/itunes/itinfo/folderaction01.php) (Mac Only)。

對指定資料夾設定動作，當有新增音樂檔案到此資料夾的時候自動把檔案丟進 itunes 。再把 Google Music Manager 設定成自動上傳 itunes 新增的音樂即可。

之後可能會加上轉好 mp3 後加上 ID3 TAG 的功能吧，不過那又是另外一個故事了(遠目)。