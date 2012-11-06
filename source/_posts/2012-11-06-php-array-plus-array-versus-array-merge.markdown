---
layout: post
title: "PHP array 相加與 array_merge"
date: 2012-11-06 13:17
comments: true
categories: [PHP]
---

今天跟聊到這個問題，喚起我沈睡的記憶…應該寫下來不然兩年後我大概又會忘了。

在 PHP 中 `array + array` 與 `array_merge` 的行為是不一樣的，陣列相加的效能會比 `array_merge` 來的好，但換來的代價是可能不是你預期的行為以及資料流失。

PHP 的陣列可以有 key 也可以沒有 key，也可以兩者混合。不過所謂的沒有 key ，其實他還是有 key ，只是是自動編上去的 int 流水號 key 例如 0,1,2,3...不管是哪一種，在陣列相加以及 `array_merge` 的行為都不一樣。

先講一下 `array_merge` 的行為，`array_merge($a, $b)` 的話，如果 `$a` 和 `$b` 裡面有 key 相同的元素，則會**後蓋前**也就是 `$b` 的值會蓋掉 `$a` 的值。那如果是沒有 key (流水號 key)的值，則會以附加在尾端 (append) 的方式合併上去，而所有流水號 key 的 index 則會重排。
<!--more-->
底下是一個簡單的例子：

``` php array_merge
<?php
$arr_a = array('a'=>1, 'b'=>2, 1=>3);
$arr_b = array('b'=>1, 4, 5);
var_dump(array_merge($arr_a, $arr_b));
```

結果為：
```
array(5) {
  ["a"]=>
  int(1)
  ["b"]=>
  int(1)
  [0]=>
  int(3)
  [1]=>
  int(4)
  [2]=>
  int(5)
}
```

那如果是 `array + array` 的狀況，在有 key 的值的部分是相反的**前蓋後**，而沒有 key(流水號 key)的部分也會**前蓋後**，流水號 index 不會重排。我們用同樣的例子來觀察：

``` php array_merge
<?php
$arr_a = array('a'=>1, 'b'=>2, 1=>3);
$arr_b = array('b'=>1, 4, 5);
var_dump($arr_a + $arr_b);
```

結果為：
```
array(4) {
  ["a"]=>
  int(1)
  ["b"]=>
  int(2)
  [1]=>
  int(3)
  [0]=>
  int(4)
}
```

由此可知 `array + array` 和 `array_merge` 的行為是完全不一樣的，而大多數的情況陣列相加不會是我們想要的結果。請根據使用狀況謹慎選擇。

我只有在一個地方使用過陣列相加，在處理使用者設定的部分，系統有一個預設的設定陣列，使用者也會有使用者自訂的設定陣列，而使用者可能只設了其中幾項，這時把這兩個陣列相加，就可以組合出一個完整的使用者設定陣列，使用者沒設定的部分就由預設值陣列填補。

``` php
<?php
...
static protected function _fillWithDefault($settings)
{
	settype($settings, "array");
	$defaults = self::getDefault();
	
	foreach($settings as $key=>$value) {
		if(!array_key_exists($key, $defaults)) unset($settings[$key]);
	}
	
	return $settings + $defaults;
}
```

當然這個 case 寫成 `array_merge($defaults, $settings)` 也是可以達到一樣的效果，不過當時我覺得陣列相加效能較好，語意上也不會造成混淆，所以就採用這個寫法。