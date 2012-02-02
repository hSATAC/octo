---
layout: post
title: "PHP-Resque Auto Scale Workers"
date: 2012-02-02 14:56
comments: true
categories: [PHP, PHP-Resque, Resque] 
---

[PHP-Resque](https://github.com/chrisboulton/php-resque) is an amazing PHP port of [Resque](http://github.com/defunkt/resque/). After playing it for a while, an idea crossed my mind: It's a total waste to create numbers of workers when there's not many jobs to do. How about auto scale it? With the EventListener design of PHP-Resque, we could achieve it by writing some simple hooks.

Also, is solved [issue #32 of PHP-Resque](https://github.com/chrisboulton/php-resque/issues/32).

Here's my code: [PHP-Resque Auto Scale](https://github.com/hSATAC/php-resque-auto-scale)

## Introduction

This is a project trying to build an auto scale architecture of PHP-Resque.
<!-- more -->
## Design

### Expected Behavior

* Trigger ```afterEnqueue``` to check the total job number of this queue.

* If the number larger than ```15``` than check the total number of workers involved in this queue.

* If the worker number is not enough, create one or more workers.

  * If there are more than one server, divided the number equally to each server.
  
  * In the mean time, try to create workers that deal the same queues on each server.

* Trigger ```beforeFork``` to check the total job number and worker number, close the useless ones.

### Number of Jobs and Workers

* 1~15 jobs => 1 worker

* 16~25 jobs => 2 workers

* 26~40 jobs => 3 workers

* 41~60 jobs => 4 workers

* 60+ jobs => 5 workers

## Usage

* You need to add the queue type as a member static variable to your Job class. Like this:

```php
<?php
class PHP_Job
{
    static public $queue = "default";
}
?>
```

* Require ```plugin.php``` both in your resque init script and enqueue part.

* Change the setting and code in ```plugin.php``` based on your need.

* Start only one worker via your resque init script.

* Now it's auto-scalable.

## Disclaimer

For now it's all experimental design.

All numbers and codes are not from production enviroments nor runned benchmarks. It's just a prototype for now, but it does what it says.
