# WBKit
WBKit IOS framework
----------------------------

* 2018.3.9
增加`UIGestureRecognizer+BlockedAction`，支持UIGestureRecognizer的事件block化

* 2018.2.8
增加`WBSerialAction`，提供异步事件完成的回调block，能够将多个异步事件串行执行，提供打断与完成回调的方法，使用`.`语法实现串行调用，也可以单独添加任务进队列，暂时不支持插队。

* 2018.2.2
增加`UIView+BadgeHelper`，可以对任意`UIView`子类增加badge，样式、颜色、内容、位置、大小都可以自定义。

* 2018.1.30
增加`UITableViewCell+StaticHelper`，支持使用`UITableViewController`简单高效的制作静态table。暂时还未完善对`UIViewController`手动添加的tableview支持。

* 2018.1.23
增加`WBWebBridge`，支持`WKWebView`与web页面之间的消息桥接。

* 2018.1.22
增加`NSObject+PropertyListing`，支持任意对象转字典，字典转任意对象。支持属性名转换字典key的时候重命名，支持数组装对象的多层嵌套。

* 2018.1.12
增加`UIControl+BlockedAction`，支持UIControl的事件block化

* 2018.1.11
增加`UIView+Skinable`，支持自定义默认控件样式

* 2017.12.29
增加Demo的target

* 2017.12.28
增加对app模块化的支持类

* 2017.12.26
增加 `NSMutableArray` 的unretain初始化方法

* 2017.12.25
增加 `NSDate` 的扩展方法

* 2017.12.18
增加 `NSObject` 的本地化功能

* 2017.12.15
创建 `WebKit`，iOS框架项目
