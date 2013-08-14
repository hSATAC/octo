---
layout: post
title: "The Art of Readable Code 讀書筆記"
date: 2013-08-07 22:07
comments: true
categories: [Programming, Art, Readability]
---

這次公司的讀書分享會我被指定報告這本 [The Art of Readable Code](http://shop.oreilly.com/product/9780596802301.do)。

![The Art of Readable Code Cover](/images/art_of_readable_code/cover.jpg)

這本書我以前就看過英文本，這次借這個機會重新複習整理了一下，又有新的收穫。把一些我覺得比較重要的點筆記下來，太基礎或可能用不太到的這邊就省略了。很推薦各位翻一下這本，是一本很值得一讀的小書。

<!--more-->

## 摘要

可讀性就是易於理解(最短時間理解)。

把寫程式從「會動就好」(寫給機器讀)，提升到「表明自己的意圖」(寫給人讀)的層次。

試著思考，閱讀這段程式的人會用怎樣的脈絡來理解你的程式碼。

## Part 1. 表層改善

### 富含資訊的名稱

* 選擇詞彙

`FetchPage` 比 `GetPage` 要好，表達出從網路拉資料的行為。

可以使用比 `Stop` 更清楚的名稱，例如不能復原的用 `Kill`，能復原的用 `Pause`, `Resume`。

* 避免使用 tmp, ret, i, j, k (除非真的是要交換變數)

* 優先使用具體名稱而非抽象名稱

`ServerCanStart` 抽象

`ServerCanListenOnPort` 具體

* 在名稱中加入額外資訊

`start` => `start_ms`

`size` => `size_mb`

* 加入其他重要屬性

`password` => `plaintext_password`

`comment` => `unescaped_comment`

較小範圍適合較短變數名稱

### 不被誤解的名稱

`Filter()` 是包含還是排除？ `Select()`, `Exclude()` 更清楚

`start, stop` 有沒有包含？ `first, last` 清楚表明有包含

* 符合使用者的預期

`get*()` 開頭預期是輕量 getter，不要做耗時運算。

`size()` 預期輕量，要計算可改為 `computeSize()`

### 美學

* 排版

* 有意義的順序

`first_name, last_name, email`

`first_name, email,...last_name`

* 風格一致性

* 區分程式碼段落

### 註解

* 註解自己的想法

* 註解程式碼缺陷

* 註解常數 (常數的設定通常都有其原因和意義)

`NUM_THREADS` 可能是根據 CPU 核心數推算出來。

* 為讀者設想(可能需要額外思考)

{% codeblock lang:obj-c %}
NSSet *selectedAdvisorIDs  = _filterVC.selectedAdvisors;

for (MBAdvisor *advisor in [self currentGroup].advisors) {
    if ([selectedAdvisorIDs containsObject:advisor.ID]) {
        [_filteredAdvisors addObject:advisor];
    }
}

// 為什麼不直接從 selectedAdvisorIDs 迴圈作處理？
for (NSNumber *advisorID in selectedAdvisorIDs) {
        [_filteredAdvisors addObject:[self findAdvisorByID:advisorID]];
}

// 為了維持原本 Advisor 的順序
{% endcodeblock %}

* 註明可能的陷阱

### 讓註解精確與簡潔

* 精確描述函數行為

`傳回檔案行數` 可能有很多狀況，改為 `計算檔案中 \n 個數` 更為精確。

* 使用代表性的輸入輸出範例 (rdoc)

* 函數參數名稱註解 (named parameters)

{% codeblock lang:c %}
Connect(10, false);

//=>

Connect(timeout_ms = 10, use_encryption = false);

//=>

Connect(/* timeout_ms = */ 10, /* use_encryption = */ false);
{% endcodeblock %}

* 使用訊息密集的詞彙

`cache`, `singleton`

## Part 2. 簡化迴圈與邏輯

### 提高控制流程與可讀性

* if/else 區塊順序
	1. 先肯定而非否定的情況
	2. 先簡單的情況
	3. 先*有趣*或明顯的情況
	
{% codeblock lang:c %}
if (!url.HasQueryParameter("expand_all")) {     response.Render(items);     ...} else {     for (int i = 0; i < items.size(); i++) {         items[i].Expand();     }     ...}
// 看到 expand_all 會一直想著 expand_all =>
if (url.HasQueryParameter("expand_all")) {     for (int i = 0; i < items.size(); i++) {         items[i].Expand();     }     ...} else {     response.Render(items);     ...}
{% endcodeblock %}

* 盡早返回 (return)

* 消除迴圈中的巢狀結構 (continue)

### 分解巨大表示式

* 解釋性變數

{% codeblock lang:python %}
if line.split(':')[0].strip() == "root":

#=>

username = line.split(':')[0].strip()
if username == "root":
{% endcodeblock %}


### 變數與可讀性

* 消除變數

{% codeblock lang:python %}
now = datetime.datetime.now()
root_message.last_view_time = now

# =>

root_message.last_view_time = datetime.datetime.now()
{% endcodeblock %}

* 縮減變數範圍

{% codeblock lang:obj-c %}
UIButton *sideMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
sideMenuButton.bounds = CGRectMake(0, 0, 20, 20);
[sideMenuButton setImage:[UIImage imageNamed:@"sidemenu_icon.png"] forState:UIControlStateNormal];
[sideMenuButton addTarget:self action:@selector(toggleRightPanelAction) forControlEvents:UIControlEventTouchUpInside];
self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideMenuButton];

// =>

// scoped temp variables. last line will be returned.
self.navigationItem.rightBarButtonItem = ({
  UIButton *sideMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
  sideMenuButton.bounds = CGRectMake(0, 0, 20, 20);
  [sideMenuButton setImage:[UIImage imageNamed:@"sidemenu_icon.png"] forState:UIControlStateNormal];
  [sideMenuButton addTarget:self action:@selector(toggleRightPanelAction) forControlEvents:UIControlEventTouchUpInside];
  [[UIBarButtonItem alloc] initWithCustomView:sideMenuButton];
});
{% endcodeblock %}

* 減少變數改變



## Part 3. 重新組織程式碼

### 抽離不相關子問題

* 避免過猶不及

{% codeblock lang:python %}
user_info = { "username": "...", "password": "..." }user_str = json.dumps(user_info)cipher = Cipher("aes_128_cbc", key=PRIVATE_KEY, init_vector=INIT_VECTOR, op=ENCODE)encrypted_bytes = cipher.update(user_str)encrypted_bytes += cipher.final() # flush out the current 128 bit blockurl = "http://example.com/?user_info=" + base64.urlsafe_b64encode(encrypted_bytes)
…
#=>

def url_safe_encrypt(obj):	obj_str = json.dumps(obj)	cipher = Cipher("aes_128_cbc", key=PRIVATE_KEY, init_vector=INIT_VECTOR, op=ENCODE)	encrypted_bytes = cipher.update(obj_str)	encrypted_bytes += cipher.final() # flush out the current 128 bit block	return base64.urlsafe_b64encode(encrypted_bytes)user_info = { "username": "...", "password": "..." }url = "http://example.com/?user_info=" + url_safe_encrypt(user_info)

#=> this went too far…

user_info = { "username": "...", "password": "..." }url = "http://example.com/?user_info=" + url_safe_encrypt_obj(user_info)
def url_safe_encrypt_obj(obj):	obj_str = json.dumps(obj)	return url_safe_encrypt_str(obj_str)def url_safe_encrypt_str(data):	encrypted_bytes = encrypt(data)	return base64.urlsafe_b64encode(encrypted_bytes)def encrypt(data):	cipher = make_cipher()	encrypted_bytes = cipher.update(data)	encrypted_bytes += cipher.final() # flush out any remaining bytes	return encrypted_bytesdef make_cipher():	return Cipher("aes_128_cbc", key=PRIVATE_KEY, init_vector=INIT_VECTOR, op=ENCODE)
{% endcodeblock %}

### 撰寫較少程式碼

* 可讀性最高的程式碼就是完全沒有程式碼

* 不開發那些功能 - 不會需要

* 詢問與分解需求

* 熟悉你的函式庫

