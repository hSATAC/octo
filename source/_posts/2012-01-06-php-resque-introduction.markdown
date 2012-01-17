---
layout: post
title: "PHP-Resque 簡介"
date: 2012-01-06 15:14
comments: true
categories: [PHP, Resque, PHP-Resque]
---
[Resque](https://github.com/defunkt/resque) 是 Github 基於 Redis 開發的 background job 系統。相較其他肥大的 queue 系統， Resque 的設計真的非常單純簡潔，充分利用 Redis 的特性。更多介紹可以看[原作者的 Blog](https://github.com/blog/542-introducing-resque)

[PHP-Resque](https://github.com/chrisboulton/php-resque) 是把 Resque porting 到 PHP 的專案。使用和 原本 Resque 一樣的概念和設計。甚至連 Redis 的 key 命名都一樣，因此也可以使用 Ruby 版本的 [resque-web](https://github.com/defunkt/resque-web) 來監控 PHP-Resque 的運行狀況。

## 設計
Resque 的設計有兩個角色： Job 和 Worker。 每個 Job 都是定義成類別，新增 Job 的時候會將 Job 的類別和相關參數 json_encode 後儲存到不同的 queue 裡面，而 Worker(s) 則會依序從 redis 讀取 Job 出來執行。

執行的時候並不是這個 Worker 本身去執行，而是會 fork 一個 process 來執行。這樣設計是為了避免時間一長， Worker 的記憶體管理不良導致卡死的狀況。

讀取 queue 時會依據你啟動 worker 的時候給的 queue 順序來讀取，因此優先權較高的 queue 要設定在前面。 Redis 可以是單機或 RedisCluster。而許多不同伺服器上可以按需求部屬執行不同 queue 的 worker。

Resque Job 執行失敗並不會自動重試，而是把它丟到 fail 的 queue 裡面。如果你有重試的需求可能要自己處理。若是有特別重要的 Job 需要監控執行狀態的，可以參考 README 中的 Tracking Job Statuses 一節。

以下先來介紹如何使用 PHP-Resque：

## 安裝 PHP-Resque

安裝非常容易，只要 ```git clone https://github.com/chrisboulton/php-resque.git``` 下來，放到你想要的地方，由於 Resque 沒有 config 檔的設計，設定都是寫在環境變數中再執行就可以了。
<!-- more -->
## 環境變數

PHP-Resque 支援的環境變數有：

* QUEUE - 這個是必要的，會決定 worker 要執行什麼任務，重要的在前，例如 ```QUEUE=notify,mail,log``` 。也可以設定為 ```QUEUE=*``` 表示執行所有任務。

* APP_INCLUDE - 這也可以說是必要的，因為 Resque 的 Job 都是寫成物件，那 worker 執行的時候當然要把物件的檔案引入進來。可以設成 ```APP_INCLUDE=require.php``` 再在 require.php 中引入所有 Job 的 Class 檔案即可。

* COUNT - 設定 worker 數量，預設是1 ```COUNT=5``` 。

* REDIS_BACKEND - 設定 Redis 的 ip, port。如果沒設定，預設是連 ```localhost:6379``` 。

* LOGGING, VERBOSE - 設定 log， ```VERBOSE=1``` 即可。

* VVERBOSE - 比較詳細的 log， ```VVERBOSE=1``` debug 的時候可以開出來看。

* INTERVAL - worker 檢查 queue 的間隔，預設是五秒 ```INTERVAL=5``` 。

* PIDFILE - 如果你是開單 worker，可以指定 PIDFILE 把 pid 寫入，例如 ```PIDFILE=/var/run/resque.pid``` 。

有一個 Resque 支援，但 PHP-Resque 沒有的參數叫 ```BACKGROUND``` 可以把 resque 丟到背景執行。不過這個其實不太重要，有需要的話自己加個 ```php resque.php &``` 就可以了。

所以，你的指令最後可能會變這樣：

```
QUEUE=* APP_INCLUDE=require.php COUNT=5 VVERBOSE=1 php resque.php
```

如果覺得太長，可以寫一支啟動 script 來輔助你，我有寫一支可供參考：

{% gist 1619972 %}

## 使用 PHP-Resque

把檔案抓下來以後一定想先試驗看看的，確定你的 redis-server 都有正常啟動後，在 demo 資料夾下面有幾個檔案可以先試驗看看。

切到 demo 目錄後，執行 ```VVERBOSE=1 QUEUE=* php resque.php``` 應該會看到 resque 已經開始執行了。

執行 ```php queue.php PHP_Job``` 、 ```php queue.php Bad_PHP_Job``` 、 ```php queue.php Long_PHP_Job``` 、 ```php queue.php PHP_Error_Job``` 可以把工作丟進 queue 裡面，看看執行的結果。

後面帶的名稱其實就是 Job class 的名稱，所以 PHP-Resque 在執行時也要把相關的 class 檔案設定在 APP_INCLUDE 引入才行。

Job 的 class 很簡單，大概長這樣：

``` php
<?php
class My_Job
{
    public function perform()
    {
        // Work work work
        echo $this->args['name'];
    }
}
?>
```

只要定義 perform 方法， Worker 就會把 Job new 出來以後執行 perform 。

當然，也可以定義 ```setUp()``` 和 ```tearDown()``` 方法，前者會在 ```perform()``` 執行前執行，後者會在 ```perform()``` 執行後執行。

需要注意的是，Job exit 後都視為正常執行，如果要讓他判斷失敗丟到 fail queue 中的話，需要 throw exception。

將 Job 塞入 queue 的方式是：

``` php
<?php
require_once 'lib/Resque.php';

Resque::setBackend('localhost:6379');

$args = array(
    'name' => 'Chris'
);
Resque::enqueue('default', 'My_Job', $args);
?>
```

其中第一個參數 ```default``` 就是你的 queue 名稱，例如你可以設定 notify, mail, image 之類，至於為什麼要這樣設計，在後面的篇幅再敘述。

值得一提的是，在原 ruby 版 rescue 每個 Job 屬於哪個 queue 是直接定義在 class 中的，PHP 版則是 enqueue 時才傳入，不知道為什麼要這樣設計，可能會導致一些意料之外的結果，需要注意。

PHP-Resque 的使用方法大致就是這樣，接下來講一些其他的小細節。

## Hooks

PHP-Resque 可以定義 Event Hooks 讓你能在相對應的事件發生時執行你想要的動作。支援的事件有很多，請各位自行參考原專案的 README。在專案目錄下的 extra 目錄下有 sample.plugin.php 可以看 Event hook 的範例寫法。

有一點需要注意的是，很直覺我們會把這隻 sample.plugin.php 丟到 APP_INCLUDE 變數中，這樣沒錯，但要注意跟 enqueue 有關的 event 並不是由 worker 來觸發，因此你在新增 Job 的那段程式也需要引入 sample.plugin.php 才能觸發到 ```AFTERENQUEUE``` 。

## 監控

### resque-web

前面有提到可以直接使用 resque-web 來監控 PHP-Resque 的狀態，相當建議使用，非常清楚易懂，要看 Redis 相關的數據也可以看，不用進 redis-cli 自己打指令。

安裝方法：```gem install resque```

執行：```resque-web -p 3000``` 即可運行在 3000 port。

首頁有 live reload 按鈕可以按， debug 時非常方便。

screenshot: {% img /images/wp-uploads/2012/01/resque-web.jpg %}

### Supervisord

在專案的 extra 目錄下另有 resque.monit 檔案，這是供 [Supervisord](http://supervisord.org/) 使用的設定檔。他會在 worker 吃掉 300MB 以上的記憶體，或者是跑了 10 次輪迴後砍掉重開。可以參考看看。 

### proctitle

如果你 ```ps | grep resque``` 只會看到 ```php resuqe.php``` 的訊息，還記得 Worker 會 fork 出一個 process 來執行 Job 嗎？這樣就有兩倍的 processes 但是你完全分不出來哪個是哪個。原本 ruby 版本的設計是可以輕易看出 Worker fork 了哪個 process 而被 fork 出來的正在執行什麼工作。

Ruby 只要改 ```$0``` 就可以了， PHP 就沒這麼簡單了，要使用 ```setproctitle``` 。

但是這要安裝 pecl 的 ```proctitle``` 模組才能使用。

安裝方式：```pecl install proctitle channel://pecl.php.net/proctitle-0.1.1```

記得要去 php.ini 讀進 .so 的 extension 。

完成後再執行 ```ps -e -o pid,command | grep [r]esque``` 時，就會從原本的

```
10486 php resque.php
10487 php resque.php
```

變成好讀易懂的：

```
10621 resque-1.0: Waiting for notify,mail,image,default
10622 resque-1.0: Forked 10632 at 2012-01-16 13:42:55
10632 resque-1.0: Processing default since 2012-01-16 13:42:55
```

## 佈署

之前提到可以除了預設的 default 以外，還可以設定不同的 queue，為什麼要這樣做呢？除了執行優先權外，(撈 queue 時會按你給 worker 的設定，在前面 queue 的會先撈，就會先執行到) 還有多伺服器佈署的原因。

假如今天你有個 queue 專門要處理使用者圖片的東西，當然一般圖片會有自己的伺服器。於是在你的主 web 伺服器上你就可以執行 ```QUEUE=notify,mail``` 而在圖片伺服器上就可以執行 ```QUEUE=images``` 的 worker。

另外就是由於 Worker 啟動時已經將 ```APP_INCLUDE``` 的檔案都讀入，持續執行。因此如果有修改引入的 Job 或 hook plugin 等檔案的話，deploy 時要將 worker 停止，重新啟動才會讀入新的 ```APP_INCLULDE``` 檔案。

## 已知問題

首先，PHP-Resque 使用的是 [Redisent](https://github.com/jdp/redisent) 這套 Redis interface。但因為和另一套 php module [phpredis](http://code.google.com/p/phpredis/) 同樣都定義了 RedisException 這個類別，所以會衝突，必須把 phpredis 移除才能使用。

再來，在部屬時常常 REDIS_BACKEND 是設到別台機器的，而且一般我們都會開不只一個 worker ，這時候有一個已知 issue 就是有時 lpop 拉回來的 Job 錯誤，是一個陣列，導致噴出 json_decode 的錯誤，而且這個 Job 就不會執行，會 missing 。 (see [#32](https://github.com/chrisboulton/php-resque/issues/32))

目前還不清楚確實問題所在，不過有一個 workaround 的解法是，不要用 ```COUNT=5``` 去開，而是設 ```COUNT=1``` 然後執行 5 次，就不會有這個問題產生。

## 結語

Resque 真的是一個很棒很輕巧的設計，感謝有人把它 porting 到 PHP 。希望越來越多人來使用，一起來發展維護 PHP-Resque。
