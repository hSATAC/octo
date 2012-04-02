---
layout: post
title: "Xcode 4.3 publish ipa for testflight"
date: 2012-03-07 10:05
comments: true
categories: [iOS, testflight, Xcode, Mac]
---
這兩天在研究 testflight 碰到了一點 Xcode 4.3 的小雷，記錄一下。

按照 testflight 的教學上傳 ipa 檔，一直出現 `mismatched-ubiquitykvstore-identifier-value` 的錯誤，但是憑證已經確認多次，肯定沒有問題。

翻了一下應該是 APP ID enable iCloud 的問題，但是不能 disable 掉的狀況，只好自己去 entitlement 補上需要的參數。

Xcode 4.3 的 entitlement 換地方了。

* 請到 target 的 summary tab 拉到最底下找到 entitlement 區塊，勾選 `enable Entitlement`。
* `iCloud key-value Store` 這個欄位填上 `.*`
* `iCloud Container` 這個部分自己加一個值 `.*`

存檔後你的專案就會多一個 `專案名.entitlements` 的檔案，打開確認一下內容是否有

```
<key>com.apple.developer.ubiquity-container-identifiers</key>
 <array>
     <string>$(TeamIdentifierPrefix).*</string>
 </array>
 <key>com.apple.developer.ubiquity-kvstore-identifier</key>
 <string>$(TeamIdentifierPrefix).*</string>
```

再做 Archive, Share 成 ipa 檔上傳就可以了。

*2012/04/42 補充*

用 .* 的 key 送審 AppStore 時會被 reject，請設成跟你的 bundle identifier 一樣即可。

也就是：

```
<key>com.apple.developer.ubiquity-container-identifiers</key>
 <array>
     <string>$(TeamIdentifierPrefix)com.yourcompany.coolapp</string>
 </array>
 <key>com.apple.developer.ubiquity-kvstore-identifier</key>
 <string>$(TeamIdentifierPrefix)com.yourcompany.coolapp</string>
```