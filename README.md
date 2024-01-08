
# FEEAlert - Swift 版 [LEEAlert - 优雅的Alert ActionSheet](https://github.com/lixiang1994/LEEAlert)

[![](https://img.shields.io/cocoapods/l/LEEAlert.svg)](LICENSE)&nbsp;
[![](http://img.shields.io/cocoapods/v/LEEAlert.svg?style=flat)](http://cocoapods.org/?q=LEEAlert)&nbsp;
[![](http://img.shields.io/cocoapods/p/LEEAlert.svg?style=flat)](http://cocoapods.org/?q=LEEAlert)&nbsp;
[![](https://img.shields.io/badge/support-iOS8%2B-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![](https://img.shields.io/badge/Xcode-11.0-blue.svg)](https://developer.apple.com/xcode/)&nbsp;
[![](https://img.shields.io/badge/language-Objective--C-f48041.svg?style=flat)](https://www.apple.com/)&nbsp;
![Build Status](https://travis-ci.org/lixiang1994/LEEAlert.svg?branch=master)&nbsp;
![](https://img.shields.io/cocoapods/dt/LEEAlert.svg)



演示
==============
![AlertDemo演示](https://github.com/lixiang1994/Resources/blob/master/LEEAlert/alertDemo.gif)
![ActionSheetDemo演示](https://github.com/lixiang1994/Resources/blob/master/LEEAlert/actionSheetDemo.gif)


特性
==============
 - 链式语法 结构优雅
 - 支持alert类型与actionsheet类型
 - 默认样式为Apple风格 可自定义其样式
 - 支持自定义标题与内容 可动态调整其样式
 - 支持自定义视图添加 同时可设置位置类型等 自定义视图size改变时会自动适应.
 - 支持输入框添加 自动处理键盘相关的细节
 - 支持屏幕旋转适应 同时可自定义横竖屏最大宽度和高度
 - 支持自定义action添加 可动态调整其样式
 - 支持内部添加的功能项的间距范围设置等
 - 支持圆角设置 支持阴影效果设置
 - 支持队列和优先级 多个同时显示时根据优先级顺序排队弹出 添加到队列的如被高优先级覆盖 以后还会继续显示等.
 - 支持两种背景样式 1.半透明 (支持自定义透明度比例和颜色) 2.毛玻璃 (支持效果类型)
 - 支持自定义UIView动画方法
 - 支持自定义打开关闭动画样式(动画方向 渐变过渡 缩放过渡等)
 - 支持iOS13 Dark样式
 - 更多特性未来版本中将不断更新.


用法
==============

### 概念

无论是Alert还是ActionSheet 这里我把它们内部的控件分为两类 一: 功能项类型 (Item) 二: 动作类型 (Action).

按照apple的风格设计 弹框分为上下两个部分 其中功能项的位置为 Header 既 头部, 而Action则在下部分.

功能项一般分为4种类型  1. 标题 2. 内容(也叫Message) 3.输入框 4.自定义的视图 

Action一般分为3种类型 1. 默认类型 2. 销毁类型(Destructive) 3.取消类型(Cancel)

所以说 能添加的东西归根结底为两种 1. Item 2.Action  其余的都是一些设置等.


根据上面的概念 我来简单介绍一下API的结构:

所有添加的方法都是以 `feeAddItem` 和 `feeAddAction` 两个方法为基础进行的扩展.

查看源码 可以发现 无论是 `feeTitle` 还是 `feeTextField` 最终都是通过 `feeAddItem` 来实现的.

也就是说整个添加的结构是以他们两个展开的 , 这个仅作为了解即可.

![Layout](https://github.com/lixiang1994/LEEAlert/blob/master/Resources/layout.png)

### Alert
```
    // 完整结构
    FEEAlert.alert.cofing.XXXXX.XXXXX.feeShow()
```

### ActionSheet
```
    // 完整结构
    FEEAlert.actionSheet.cofing.XXXXX.XXXXX.feeShow()
```

### 默认基础功能添加

```
    FEEAlert.alert.config
    .feeTitle("标题") 		// 添加一个标题 (默认样式)
    .feeContent("内容")		// 添加一个标题 (默认样式)
    .feeTextField { textField in	// 添加一个输入框 (自定义设置)
    	// textfield设置Block
    }
    .feeCustomView(view)	// 添加自定义的视图
    .feeAction("默认Action") {		//添加一个默认类型的Action (默认样式 字体颜色为蓝色)
    	// 点击事件Block
    }
    .feeDestructiveAction("销毁Action") {	// 添加一个销毁类型的Action (默认样式 字体颜色为红色)
    	// 点击事件Block
    }
    .feeCancelAction("取消Action") {	// 添加一个取消类型的Action (默认样式 alert中为粗体 actionsheet中为最下方独立)
    	// 点击事件Block
    }
    .feeShow() // 最后调用Show开始显示
```	
	
### 自定义基础功能添加

```
    FEEAlert.alert.config
    .feeTitle { label in
        
        // 自定义设置Block
        
        // 关于UILabel的设置这里不多说了
        
        label.text = "标题"
        
        label.textColor = .red
    }
    .feeContent { label in
        
        // 自定义设置Block
        
        // 同标题一样
    }
    .feeTextField { textField in
        
        // 自定义设置Block
        
        // 关于UITextField的设置你们都懂的 这里textField默认高度为40.0f 如果需要调整可直接设置frame 当然frame只有高度是有效的 其他的均无效
        
        textField.textColor = .red
    }
    .feeCustomView { custom in
        
        // 自定义设置Block
        
        // 设置视图对象
        custom.view = view
        
        // 设置自定义视图的位置类型 (包括靠左 靠右 居中 , 默认为居中)
        custom.positionType = .left
        
        // 设置是否自动适应宽度 (自适应宽度后 位置类型为居中)
        custom.isAutoWidth = true
    }
    .feeAddAction { action in
        
        // 自定义设置Block
        
        // 关于更多属性的设置 请查看'LEEAction'类 这里不过多演示了
        
        action.title = "确认"
        
        action.titleColor = .blue
    }
    .feeShow()
```

### 自定义相关样式

```
    FEEAlert.alert.config
    .feeCornerRadius(10.0f) 	//弹框圆角曲率
    .feeShadowOpacity(0.35f) 	//弹框阴影的不透明度 0.0 -- 1.0
    .feeHeaderColor([UIColor whiteColor]) 	//弹框背景颜色
    .feeBackGroundColor([UIColor whiteColor])	 //屏幕背景颜色
    .feeBackgroundStyleTranslucent(0.5f) 	//屏幕背景半透明样式 参数为透明度
    .feeBackgroundStyleBlur(UIBlurEffectStyleDark)	 //屏幕背景毛玻璃样式 参数为模糊处理样式类型 `UIBlurEffectStyle`
    .feeShow()
```

### 自定义最大宽高范围及相关间距

```
    FEEAlert.alert.config
    .feeHeaderInsets(UIEdgeInsetsMake(10, 10, 10, 10)) 		// 头部内间距设置 等于内部项的范围
    .feeMaxWidth(280.0f) // 设置最大宽度 (固定数值 横竖屏相同)
    .feeMaxHeight(400.0f) // 设置最大高度 (固定数值 横竖屏相同)
    .feeConfigMaxWidth { (type, size) in 	// 设置最大宽度 (根据横竖屏类型进行设置 最大高度同理)
        
        if type == .vertical {
            
            // 竖屏类型
            
            return 280.0
        }
        
        if type == .horizontal {
            
            // 横屏类型
            
            return 400.0
        }
        
        return 0.0
    }
    .feeShow()
    

    FEEAlert.alert.config
    .feeTitle("标题")
    .feeItemInsets(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)) 	// 设置某一项的外边距范围 在哪一项后面 就是对哪一项进行设置
    .feeContent("内容")
    .feeItemInsets(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)) 	// 例如在设置标题后 紧接着添加一个feeItemInsets() 就等于为这个标题设置了外边距范围  以此类推
    .feeShow()
    
    /**
   	 feeHeaderInsets 与 feeItemInsets 决定了所添加的功能项的布局 可根据需求添加调整.
    */
```

### 自定义动画时长

```
    FEEAlert.alert.config
    .feeOpenAnimationDuration(0.3) // 设置打开动画时长 默认为0.3秒
    .feeCloseAnimationDuration(0.2) // 设置关闭动画时长 默认为0.2秒
    .feeShow()
```

### 自定义动画样式

```
    FEEAlert.alert.config
    .feeOpenAnimationStyle([.orientationNone, .fade, .zoomEnlarge]) //设置打开动画样式的方向为上 以及淡入效果和缩放效果.
    .feeCloseAnimationStyle([.orientationNone, .fade, .zoomShrink]) //设置关闭动画样式的方向为下 以及淡出效果和缩放效果.
    .feeShow()
```

### 自定义动画方法设置

```
    FEEAlert.alert.config
    .feeOpenAnimationConfig { animatingBlock, animatedBlock in
        // 可自定义UIView动画方法以及参数设置
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .allowUserInteraction) {
            animatingBlock() //调用动画中Block
        } completion: { _ in
            animatedBlock() //调用动画结束Block
        }
    }
    .feeCloseAnimationConfig { animatingBlock, animatedBlock in
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            animatingBlock()
        }, completion: { finished in
            animatedBlock()
        })
    }
    .feeShow()
```

### 队列与优先级设置

```
    FEEAlert.alert.config
    .feeQueue(true)	// 设置添加到队列 默认不添加 (添加后 处于显示状态时 如果有新的弹框显示 会将它暂时隐藏 等新的弹框显示结束 再将其显示出来)
    .feePriority(1) 	// 设置优先级 默认为0 按照优先级从高到低的顺序显示, 优先级相同时 优先显示最新的
    .feeShow()
    /**
    	优先级和队列结合使用会将其特性融合 具体效果请运行demo自行调试体验
    */
```

### 其他设置

```
    FEEAlert.alert.config
    .feePresentation(FEEPresentation.windowLevel(.alert)) // 弹框window层级 默认UIWindowLevelAlert
    .feeShouldAutorotate(true) // 是否支持自动旋转 默认为false
    .feeSupportedInterfaceOrientations(.all) // 支持的旋转方向 默认为UIInterfaceOrientationMaskAll
    .feeClickHeaderClose(true) // 点击弹框进行关闭 默认为false
    .feeClickBackgroundClose(true) // 设置点击背景进行关闭 Alert默认 false , ActionSheet默认 true
    .feeCloseComplete { 
    	// 关闭回调事件
    }
    .feeShow()
```

### 关闭显示

```
    // 关闭指定标识的Alert或ActionSheet
    FEEAlert.close(identifier: "xxxx", completionBlock: {
        // 关闭完成
    })

    // 关闭当前显示的Alert或ActionSheet
    FEEAlert.close {
    	
    	// 如果在关闭后需要做一些其他操作 建议在该Block中进行
    }
```


### 注意事项

- 在 AppDelegate 或 SceneDelegate 中设置主要Window: 
`FEEAlert.configMainWindow(window)`
- 添加的功能项顺序会决定显示的排列顺序.
- 当需要很复杂的样式时 如果默认提供的这些功能项无法满足, 建议将其封装成一个UIView对象 添加自定义视图来显示.
- ActionSheet中 取消类型的Action 显示的位置与原生位置相同 处于底部独立的位置.
- 设置最大宽度高度时如果使用`CGRectGetWidth([[UIScreen mainScreen] bounds])`这类方法 请考虑iOS8以后屏幕旋转 width和height会变化的特性.



特别说明
==============

该库是由 [LEEAlert](https://github.com/lixiang1994/LEEAlert) 翻译为 Swift 版本，对于 Swift 进行一些适配，特别感谢 LEEAlert 的作者
