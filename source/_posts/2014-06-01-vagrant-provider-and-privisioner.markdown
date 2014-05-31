---
layout: post
title: "Vagrant Provider and Provisioner"
date: 2014-06-01 01:34
comments: true
categories: [Vagrant]
---

在寫 Vagrantfile 的時候如果需要用不同的 provider，例如用 virtualbox 和 aws 兩個 provider，但是 provisioner 的內容非常類似，這時候想省掉重複的部分，可以利用 Vagrantfile 本身就是 Ruby 的特性，直接定義一個共用的 lambda，不同的地方再另外設定：

``` ruby
  # Puppet config
  puppet_block = lambda do |puppet|
    puppet.options = "--parser future --verbose --debug" # For debug only
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "vagrant.pp"
    puppet.module_path    = "modules"
    puppet.hiera_config_path = "hiera.yaml"
  end

  config.vm.provider "virtualbox" do |vb, override|
    override.vm.provision "puppet", &puppet_block
  end

  config.vm.provider :aws do |aws, override|
    override.vm.provision "puppet", &puppet_block
  end
``` 
<!--more-->
provisioner 其實是可以多個的，就算是相同類型也一樣，並且他會依照順序執行，例如：

``` ruby
  # Upgrade Puppet from 2.7 to 3.x
  config.vm.provision :shell, :path => "scripts/upgrade_puppet.sh"

  # Install hiera-eyaml for Puppet
  config.vm.provision :shell, :path => "scripts/install_eyaml.sh"
```

以上會依序執行兩個 script。萬一需要 override 掉之前的某個 provisioner 怎麼辦呢？

按照 [官方文件](https://docs.vagrantup.com/v2/provisioning/basic_usage.html)其實是可以指定一個 id 來 override 掉，但是這個功能好像一直沒有實現...當我踩到這個雷的時候發現正好在一天前發佈的 Vagrant 1.6.1 把這個 bug 修掉了...可以想見我心中的喜悅。

於是在需要 override 的場合就可以這樣寫：

``` ruby
  # Puppet config
  puppet_block = lambda do |puppet|
    puppet.options = "--parser future --verbose --debug" # For debug only
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "vagrant.pp"
    puppet.module_path    = "modules"
    puppet.hiera_config_path = "hiera.yaml"
  end

  config.vm.provider "virtualbox" do |vb, override|
    override.vm.provision "puppet", :id => "puppet" , &puppet_block
  end

  config.vm.define "staging" do |staging|
    staging.vm.hostname = "staging"
    staging.vm.provision "puppet", :id => "puppet", :preserve_order => true do |puppet|
      puppet_block.call(puppet)
      puppet.facter = {
        'environment' => "staging",
      }
    end
  end
```

`preserve_order` 可以維持原本被 override 掉的 provisioner 順序，沒有指定的話會加到最後面，變成最後執行。如果你的 provisioner 有順序相依性請務必注意這點。