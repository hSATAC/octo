---
layout: post
title: "Migrate AWS AMI across region painlessly"
date: 2013-02-27 15:45
comments: true
categories: [aws]
---

Recently I need to migrate my infrastructure from Tokyo to Singapore. According to the information I gathered from AWS 201 course, it's a little troublesome to migrate AWS AMI between regions.

As [Copying EBS Boot AMIs Between EC2 Regions](http://alestic.com/2010/10/ec2-ami-copy) demostrated, we need to mount ebs for each regions and rsync them, than we register the ebs as AMI; Also there's [CloudyScript](https://cloudyscripts.com/tool/show/5), it's a online tool that does these steps for you.

After some study, I found that it's not necessary now. Amazon announced [EBS Snapshot Copy](http://aws.typepad.com/aws/2012/12/ebs-snapshot-copy.html) last December. Although you can't migrate AMI but we could do so just for some more steps.
<!--more-->
It's really simple:

Find the snapshot or your AMI, click `Copy Snapshot` to copy snapshot to your destinated region.

[![1](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_1.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_1.png)

Check the `Kernel ID` field of your AMI.

[![2](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_2.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_2.png)

Visit [the cloud market](http://thecloudmarket.com/image/aki-ee5df7ef) to check AKI's description to see which manifest.xml it belongs. For instance: `pv-grub-hd0_1.02-x86_64.gz.manifest.xml`

[![3](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_3.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_3.png)

Search for `pv-grub-hd0_1.02-x86_64.gz.manifest.xml` and find the AKI for your destinated region.

[![4](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_4.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_4.png)

Perform `Create Image from Snapshot` on your cloned snapshot.

[![5](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_5.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_5.png)

Select the AKI you just got.

[![6](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_6.png)](/images/ami_migrate/migrate_aws_ami_across_region_painlessly_6.png)

You don't need to rsync anything. It's just that easy!