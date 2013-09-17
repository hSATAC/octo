---
layout: post
title: "Golang The Fun Part - Struct And Interfacce"
date: 2013-09-17 22:03
comments: true
categories: [Golang]
---

之前說要寫一篇 Go 簡介…不過網路上 Go 的資料已經很豐富，把一些我喜歡 Go 的點記錄下來好了。

Go 是物件導向的語言嗎？是，也不是。

他沒有類別，也沒有繼承。我們來用實例來看看 Go 如何實現物件導向的特性。

### Struct

有接觸過 c-like 語言的人應該都對 `struct` 不陌生，我們可以定義一組結構，裡面包含各種資料型態的變數。

舉例來說我們可以定義一個叫 `Human` 的 `struct`：

{% codeblock lang:go %}
type Human struct {
	name string
	age int
}
{% endcodeblock %}

然後我們就可以這樣來使用：

{% codeblock lang:go %}
person := Human{"Ash", 18}
//或者
person := Human{name:"Ash", age:18}

person.name
person.age
{% endcodeblock %}
<!--more-->
不一樣的地方是，我們可以給這個 `struct` 定義方法：

{% codeblock lang:go %}
func (human *Human)Eat() {
	fmt.Println("Eating")
}

person.Eat()
{% endcodeblock %}

我們可以定義另一個 `struct` 來「繼承」`Human` 的屬性和方法，例如我們定義一個 `F2E`：

{% codeblock lang:go %}
type F2E struct {
	Human
	cssLevel int
	javascriptLevel int
}
{% endcodeblock %}

然後我們就可以這樣使用 `F2E`：

{% codeblock lang:go %}
aar0n := F2E{Human{name:"aar0n", age:35}, 80, 90}
aar0n.Eat()
// 當然也可以 access Human 的屬性
aar0n.name
// 或者
aar0n.Human.name
{% endcodeblock %}

我們也可以讓 `F2E` override `Human` 的屬性跟方法：

{% codeblock lang:go %}
type F2E struct {
	Human
	cssLevel int
	javascriptLevel int
	name int
}

func (f2e *F2E)Eat() {
	fmt.Println("F2E does not eat!")
}
// 還是可以 access Human 的屬性跟方法
aar0n.Human.name
aar0n.Human.Eat()
{% endcodeblock %}

#### Type 其他技巧

`type` 基本上是一個 alias 資料型態的關鍵字，不只可以使用在 `struct` 上。例如我們可以定義一個 Value Object 叫 `Money`：

{% codeblock lang:go %}
type Money int

// Money 也可以有方法
func (money Money)Disappear() {
	fmt.Println("Magic!")
}

money := Money(100)
money.Disappear()
{% endcodeblock %}

### Interface

Go 另外一個很棒的設計是 `interface` 來實現多型。基本上 `interface` 的概念是，假設你會作某些事，我就把你當這個對象。

例如我們定義一個 `interface` 叫 `RD`，條件是要會 `Coding`：

{% codeblock lang:go %}
type RD interface {
	Coding()
}
{% endcodeblock %}

然後我們幫剛剛的 `F2E` 加一個 `Coding()` 的方法，他就滿足了 `RD` 這個 `interface`：

{% codeblock lang:go %}
func (f2e *F2E)Coding() {
	fmt.Println("I write cool css and javascript!")
}

// RD(會 Coding) 可以工作
func work(rd RD) {
	rd.Coding()
}

work(&aar0n)
{% endcodeblock %}

所以我們可以再從 `Human` 繼承出一個 `Backend` 出來，一樣實作 `Coding()` 方法，他也就符合了 `RD` 這個 `interface`，一樣可以丟去工作。

{% codeblock lang:go %}
type Backend struct {
	Human
}
func (backend *Backend)Coding() {
	fmt.Println("I write Rails applications!")
}

// 凡是 RD(會 Coding) 就給我去工作
ilake := Backend{Human{"ilake", 30}}
work(&aar0n)
work(&ilake)
{% endcodeblock %}

更有趣的地方是，`interface` 也可以組合(繼承)。例如我們再定義一個 `interface` 叫 `Designer` 條件是會 `Design()`：

{% codeblock lang:go %}
type Designer interface {
	Design()
}
{% endcodeblock %}

那我們就可以稱「又會 Design 又會 Coding」的人叫全端工程師(FullStack)：

{% codeblock lang:go %}
// 同時滿足 RD 跟 Designer 兩個 interface
type FullStack interface {
	RD
	Designer
}

// 既是全端工程師，又會唱歌跳舞，那你肯定是 CTO 了
type CTO interface {
	FullStack
	Dance()
	Sing()
}
{% endcodeblock %}

#### Interface 其他技巧

在 Go 裡面，所有的資料型態都滿足「空的 interface」 `interface{}`。所以如果我們真的有一個 `slice` 或方法，裡面要塞可能是任何型態的變數，我們就可以使用「空 interface」：

{% codeblock lang:go %}
// 隨便你傳
func DoSomething(obj interface{}) {
	//...
}

// 隨便你塞
ary := make([]interface{}, 2)
ary[0] = 1
ary[1] = "string"
{% endcodeblock %}