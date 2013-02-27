---
layout: post
title: "無痛跨 region 轉移 AWS AMI"
date: 2013-02-27 15:45
comments: true
categories: [aws]
---

最近要把一些日本的東西轉移到新加坡，根據以前參加 AWS 201 的資料，跨 region 轉移 AMI(Amazon Machine Image) 這件事有點麻煩。

通常找來找去都是用 [Copying EBS Boot AMIs Between EC2 Regions](http://alestic.com/2010/10/ec2-ami-copy) 推薦的方法，在兩邊各開一個 ebs mount 起來然後 rsync 再 register 成 AMI…操作起來耗時又複雜；不然就是用 [CloudyScript](https://cloudyscripts.com/tool/show/5) 提供的線上工具，不過他其實就只是幫你把上面這些動作自動化而已...。

弄了一陣子發現，現在根本不需要這些瑣碎的步驟！ Amazone 在去年 12 月就發表了 [EBS Snapshot Copy](http://aws.typepad.com/aws/2012/12/ebs-snapshot-copy.html) 可以自由的跨區複製 snapshot! 雖然還不能複製 AMI，不過我們只要手動多幾個步驟就好。
<!--more-->
整個過程很簡單，以下用圖示說明：

先找出你 AMI 的 snapshot, 點選 `Copy Snapshot` 複製到你要的 region.

[![1](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_1.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_1.png)

複製完成後，看一下原本的 AMI 資訊，注意 `Kernel ID` 這個欄位，把他記下來。

[![2](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_2.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_2.png)

接著我們要使用演算法優化的大絕招 - 查表法。拜訪 [the cloud market](http://thecloudmarket.com/image/aki-ee5df7ef) 找出這個 AKI 的 Description 是哪個 manifest.xml ，例如我的就是 `pv-grub-hd0_1.02-x86_64.gz.manifest.xml`

[![3](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_3.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_3.png)

接著再搜尋 `pv-grub-hd0_1.02-x86_64.gz.manifest.xml` 並找出你要的 region，記住這個 AKI。

[![4](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_4.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_4.png)

在已複製好的 snapshot 上右鍵點選 `Create Image from Snapshot`

[![5](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_5.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_5.png)

Kernel ID 選擇你剛剛查到的 AKI 就可以了！

[![6](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_6.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_6.png)

完全不需要什麼 rsync 啦！無痛跨 region 轉移就這麼簡單！