//
//  AlertViewController.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class AlertViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        //        tableView.estimatedRowHeight = 50
        tableView.rowHeight = 60
        tableView.sectionHeaderHeight = 30
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    var dataArray: [[[String: String]]] = []
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        var baseArray: [[String: String]] = []
        var demoArray: [[String: String]] = []
        
        baseArray.append(["title": "显示一个默认的 alert 弹框", "content": ""])
        baseArray.append(["title": "显示一个带输入框的 alert 弹框", "content": "可以添加多个输入框."])
        baseArray.append(["title": "显示一个不同控件顺序的 alert 弹框", "content": "设置的顺序决定了控件显示的顺序."])
        baseArray.append(["title": "显示一个带自定义视图的 alert 弹框", "content": "自定义视图的size发生改变时 会自动适应其改变."])
        baseArray.append(["title": "显示一个横竖屏不同宽度的 alert 弹框", "content": "可以对横竖屏的最大宽度进行设置"])
        baseArray.append(["title": "显示一个自定义标题和内容的 alert 弹框", "content": "除了标题和内容 其他控件均支持自定义."])
        baseArray.append(["title": "显示一个多种action的 alert 弹框", "content": "action分为三种类型 可添加多个 设置的顺序决定了显示的顺序."])
        baseArray.append(["title": "显示一个自定义action的 alert 弹框", "content": "action的自定义属性可查看\"FEEAction\"类."])
        baseArray.append(["title": "显示一个可动态改变action的 alert 弹框", "content": "已经显示后 可再次对action进行调整"])
        baseArray.append(["title": "显示一个可动态改变标题和内容的 alert 弹框", "content": "已经显示后 可再次对其进行调整"])
        baseArray.append(["title": "显示一个模糊背景样式的 alert 弹框", "content": "传入UIBlurEffectStyle枚举类型 默认为Dark"])
        baseArray.append(["title": "显示多个加入队列和优先级的 alert 弹框", "content": "当多个同时需要显示时, 队列和优先级决定了如何去显示"])
        baseArray.append(["title": "显示一个自定义动画配置的 alert 弹框", "content": "可自定义打开与关闭的动画配置(UIView 动画)"])
        baseArray.append(["title": "显示一个自定义动画样式的 alert 弹框", "content": "动画样式可设置动画方向, 淡入淡出, 缩放等"])
        baseArray.append(["title": "显示一个带XIB自定义视图的 alert 弹框", "content": "自定义视图的size发生改变时 会自动适应其改变."])
        baseArray.append(["title": "显示多个带Identifier的 alert 弹框", "content": "关闭指定Identifier的alert."])
        baseArray.append(["title": "显示一个带SnapKit布局的自定义视图的 alert 弹框", "content": "模拟2秒后自定义视图约束发生变化"])
        baseArray.append(["title": "显示一个mask圆角的 alert 弹框", "content": "通过CornerRadii指定各个圆角半径"])
        baseArray.append(["title": "显示一个层级在视图控制器的 alert 弹框", "content": "通过feePresentation属性设置弹窗所在层级"])
        baseArray.append(["title": "显示一个Action不跟随Item滑动的 alert 弹框", "content": "通过feeIsActionFollowScrollEnabled属性设置是否跟随滑动"])
        
        demoArray.append(["title": "显示一个蓝色自定义风格的 alert 弹框", "content": "弹框背景等颜色均可以自定义"])
        demoArray.append(["title": "显示一个分享登录的 alert 弹框", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个提示打开推送的 alert 弹框", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个提示签到成功的 alert 弹框", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个单选选择列表的 alert 弹框", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个省市区选择列表的 alert 弹框", "content": "自定义的Action 通过设置其间距范围和边框等属性实现"])
        demoArray.append(["title": "显示一个评分的 alert 弹框", "content": "自定义的Action 通过设置其间距范围和边框等属性实现"])
        demoArray.append(["title": "显示一个新手红包的 alert 弹框", "content": "包含自定义视图 自定义title 自定义Action"])
        
        dataArray.append(baseArray)
        dataArray.append(demoArray)
    }
    
    // MARK: - 自定义视图点击事件 (随机调整size)
    @objc func viewTapAction(_ tap: UITapGestureRecognizer) {
        let randomWidth = CGFloat(arc4random() % 240 + 10)
        let randomHeight = CGFloat(arc4random() % 400 + 10)
        
        var viewFrame = tap.view?.frame ?? CGRect.zero
        viewFrame.size.width = randomWidth
        viewFrame.size.height = randomHeight
        
        tap.view?.frame = viewFrame
    }
    
    // MARK: - 基础
    func base(_ index: Int) {
        switch index {
        case 0:
            FEEAlert.alert
                .config
                .feeTitle("标题")
                .feeContent("内容")
                .feeCancelAction("取消") {
                    // 取消点击事件Block
                }
                .feeAction("确认") {
                    // 确认点击事件Block
                }
                .feeShow()
            
        case 1:
            var tf: UITextField!
            FEEAlert.alert
                .config
                .feeTitle("标题")
                .feeContent("内容")
                .feeTextField { textField in
                    textField.placeholder = "输入框"
                    
                    if #available(iOS 13.0, *) {
                        textField.textColor = UIColor.secondaryLabel
                    } else {
                        textField.textColor = UIColor.darkGray
                    }
                    
                    tf = textField
                }
                .feeAction("好的") {
                    // 确认点击事件Block
                }
                .feeShouldActionClickClose({ index in
                    // 是否可以关闭回调, 当即将关闭时会被调用 根据返回值决定是否执行关闭处理
                    // 这里演示了与输入框非空校验结合的例子
                    var result = false
                    if let text = tf?.text {
                        result = !text.isEmpty
                    }
                    result = index == 0 ? result : true
                    return result
                })
                .feeCancelAction("取消") // 点击事件的Block如果不需要可以传nil
                .feeShow()
            
        case 2:
            FEEAlert.alert
                .config
                .feeTextField() // 如果不需要其他设置 也可以传入nil 输入框会按照默认样式显示
                .feeContent("内容1")
                .feeTitle("标题")
                .feeContent("内容2")
                .feeTextField { textField in
                    textField.placeholder = "输入框2"
                }
                .feeAction("好的")
                .feeCancelAction("取消")
                .feeShow()
            
        case 3:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            view.backgroundColor = UIColor(red: 43/255.0, green: 133/255.0, blue: 208/255.0, alpha: 1.0)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapAction(_:))))
            
            FEEAlert.alert
                .config
                .feeTitle("标题")
                .feeCustomView { custom in
                    custom.view = view
                    custom.isAutoWidth = true
                    // custom.positionType = .right
                }
                .feeItemInsets(UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10))
                .feeContent("内容")
                .feeItemInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                .feeTextField { textField in
                    textField.placeholder = "输入框"
                }
                .feeAction("确认")
                .feeCancelAction("取消")
                .feeShow()
            
        case 4:
            FEEAlert.alert
                .config
                .feeTitle("标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题标题")
                .feeContent("内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容")
                .feeTextField { textField in
                    textField.placeholder = "输入框"
                }
                .feeCancelAction("取消") {
                }
                .feeAction("确认") {
                }
                .feeConfigMaxWidth { type, size in
                    switch type {
                    case .horizontal:
                        return size.width * 0.7
                    case .vertical:
                        return size.width * 0.9
                    }
                }
                .feeShow()
        case 5:
            FEEAlert.alert.config
                .feeTitle { label in
                    label.text = "已经退出该群组"
                    if #available(iOS 13.0, *) {
                        label.textColor = .secondaryLabel
                    } else {
                        label.textColor = .darkGray
                    }
                    label.textAlignment = .left
                }
                .feeContent { label in
                    label.text = "以后将不会再收到该群组的任何消息"
                    label.textColor = UIColor.red.withAlphaComponent(0.5)
                    label.textAlignment = .left
                }
                .feeAction("好的")
                .feeShow()
        case 6:
            FEEAlert.alert.config
                .feeTitle("这是一个alert 它有三个不同类型的action!")
                .feeAction("一个默认action") {
                    // 点击事件Block
                }
                .feeDestructiveAction("一个销毁action") {
                    // 点击事件Block
                }
                .feeCancelAction("一个取消action") {
                    // 点击事件Block
                }
                .feeShow()
        case 7:
            FEEAlert.alert.config
                .feeTitle("自定义 Action 的 Alert!")
                .feeAddAction { action in
                    action.type = .default
                    action.title = "自定义"
                    action.titleColor = .brown
                    action.highlight = "被点啦"
                    action.highlightColor = .orange
                    action.image = UIImage(named: "smile")
                    action.highlightImage = UIImage(named: "tongue")
                    action.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
                    action.height = 60.0
                    action.clickBlock = {
                        // 点击事件Block
                    }
                }
                .feeAddAction { action in
                    action.type = .default
                    action.title = "自定义"
                    action.titleColor = .orange
                    action.highlightColor = .brown
                    action.image = UIImage(named: "smile")
                    action.highlightImage = UIImage(named: "tongue")
                    action.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
                    action.height = 60.0
                    action.clickBlock = {
                        // 点击事件Block
                    }
                }
                .feeShow()
        case 8:
            var tempAction: FEEAction?
            
            FEEAlert.alert.config
                .feeContent("点击改变 第一个action会长高哦")
                .feeAddAction { action in
                    action.title = "我是action"
                    tempAction = action
                }
                .feeAddAction { action in
                    action.title = "改变"
                    action.isClickNotClose = true // 设置点击不关闭 (仅适用于默认类型的action)
                    action.clickBlock = {
                        tempAction?.height += 40
                        tempAction?.title = "我长高了"
                        tempAction?.titleColor = .red
                        tempAction?.update() // 更改设置后 调用更新
                    }
                }
                .feeCancelAction("取消")
                .feeShow()
        case 9:
            var tempTitle: UILabel?
            var tempContent: UILabel?
            
            FEEAlert.alert.config
                .feeTitle { label in
                    label.text = "动态改变标题和内容的alert"
                    tempTitle = label
                }
                .feeContent { label in
                    label.text = "点击调整 action 即可改变"
                    tempContent = label
                }
                .feeAddAction { action in
                    action.title = "调整"
                    action.isClickNotClose = true // 设置点击不关闭 (仅适用于默认类型的action)
                    action.clickBlock = {
                        tempTitle?.text = "一个改变后的标题 ..................................................................."
                        tempTitle?.textColor = .gray
                        tempTitle?.textAlignment = .left
                        tempContent?.text = "一个改变后的内容"
                        tempContent?.textColor = .lightGray
                        tempContent?.textAlignment = .left
                        // 其他控件同理 ,
                    }
                }
                .feeCancelAction("取消")
                .feeShow()
        case 10:
            FEEAlert.alert.config
                .feeTitle("这是一个毛玻璃背景样式的alert")
                .feeContent("通过UIBlurEffectStyle枚举设置效果样式")
                .feeAction("确认")
                .feeCancelAction("取消")
                .feeBackgroundStyleBlur(UIBlurEffect.Style.light)
                .feeShow()
        case 11:
            // 队列: 加入队列后 在显示过程中 如果有一个更高优先级的alert要显示 那么当前的alert会暂时关闭 显示新的 待新的alert显示结束后 继续显示.
            // 优先级: 按照优先级从高到低的顺序显示, 优先级相同时 优先显示最新的.
            // 队列和优先级: 当两者结合时 两者的特性会相互融合
            
            // 下面代码可自行调试理解
            
            FEEAlert.alert.config
                .feeTitle("alert 1")
                .feeCancelAction("取消")
                .feeAction("确认")
            //                .feeQueue(true) // 添加到队列
                .feePriority(1) // 设置优先级
                .feePresentation(FEEPresentation.viewController(self))
                .feeShow()
            
            FEEAlert.alert.config
                .feeTitle("alert 2")
                .feeCancelAction("取消")
                .feeAction("确认")
                .feeQueue(true) // 添加到队列
                .feePriority(3) // 设置优先级
                .feeShow()
            
            FEEAlert.alert.config
                .feeTitle("alert 3")
                .feeCancelAction("取消")
                .feeAction("确认")
                .feeQueue(true) // 添加到队列
                .feePriority(2) // 设置优先级
                .feeShow()
        case 12:
            FEEAlert.alert.config
                .feeTitle("自定义动画配置的 Alert")
                .feeContent("支持 自定义打开动画配置和关闭动画配置 基于 UIView 动画API")
                .feeAction("好的") {
                    // 点击事件Block
                }
                .feeOpenAnimationConfig({ animatingBlock, animatedBlock in
                    UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .allowUserInteraction) {
                        animatingBlock() //调用动画中Block
                    } completion: { _ in
                        animatedBlock() //调用动画结束Block
                    }
                })
                .feeCloseAnimationConfig { animatingBlock, animatedBlock in
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                        animatingBlock()
                    }, completion: { finished in
                        animatedBlock()
                    })
                }
                .feeShow()
            
        case 13:
            FEEAlert.alert.config
                .feeTitle("自定义动画样式的 Alert")
                .feeContent("动画样式可设置动画方向, 淡入淡出, 缩放等")
                .feeAction("好的") {
                    // 点击事件Block
                }
                .feeOpenAnimationStyle([.orientationTop, .fade]) //这里设置打开动画样式的方向为上 以及淡入效果.
                .feeCloseAnimationStyle([.orientationBottom, .fade]) //这里设置关闭动画样式的方向为下 以及淡出效果
                .feeShow()
            
        case 14:
            let view = NibView.instance()
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Nib形式请设置UIViewAutoresizingNone
            
            FEEAlert.alert.config
                .feeTitle("标题")
                .feeCustomView { custom in
                    custom.view = view
                    custom.positionType = .center
                }
                .feeItemInsets(UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)) // 想为哪一项设置间距范围 直接在其后面设置即可 ()
                .feeContent("内容")
                .feeItemInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)) // 这个间距范围就是对content设置的
                .feeAction("确认")
                .feeCancelAction("取消")
                .feeShow()
        case 15:
            /*
             场景模拟: 同时有3个需要 alert 显示, 一个显示中, 其余在队列中等待显示, 此时发生某些情况需要移除指定某个alert.
             
             为不同alert设置.feeIdentifier("xxx")
             通过 FEEAlert.closeWithIdentifier(_:completionBlock:) 方法关闭指定Identifier的alert.
             
             注意:
             当关闭指定的alert正在显示时则与正常关闭相同.
             当关闭指定的alert在队列中等待时会直接移除.
             当队列中存在相同Identifier的alert时 会移除所匹配到的全部alert.
             */
            
            FEEAlert.alert.config
                .feeTitle("alert 1")
                .feeCancelAction("取消")
                .feeAction("确认")
                .feeIdentifier("1")
                .feeQueue(true) // 添加到队列
                .feeShow()
            
            FEEAlert.alert.config
                .feeTitle("alert 2")
                .feeCancelAction("取消")
                .feeAction("确认")
                .feeIdentifier("2")
                .feeQueue(true) // 添加到队列
                .feeShow()
            
            FEEAlert.alert.config
                .feeTitle("alert 3")
                .feeCancelAction("取消")
                .feeAction("确认")
                .feeIdentifier("3")
                .feeQueue(true) // 添加到队列
                .feeShow()
            
            // 模拟5秒后关闭指定标识的alert
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                FEEAlert.close(identifier: "2") {
                    // 关闭完成
                }
            }
            
        case 16:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            
            view.backgroundColor = UIColor(red: 43/255.0, green: 133/255.0, blue: 208/255.0, alpha: 1.0)
            // 使用AutoLayout布局的自定义视图 必须设置translatesAutoresizingMaskIntoConstraints
            // 内部会为该视图设置centerXY的约束, 所以请不要为该视图设置关于top left right bottom center等位置相关的约束.
            // 不需要关心该视图位置 只需要保证大小正确即可.
            view.translatesAutoresizingMaskIntoConstraints = false
            
            FEEAlert.alert.config
                .feeTitle("标题")
                .feeCustomView { custom in
                    custom.view = view
                    custom.positionType = .center
                }
                .feeItemInsets(UIEdgeInsets(top: 30, left: 10, bottom: 30, right: 10)) // 想为哪一项设置间距范围 直接在其后面设置即可 ()
                .feeContent("内容")
                .feeItemInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)) // 这个间距范围就是对content设置的
                .feeTextField { textField in
                    textField.placeholder = "输入框"
                }
                .feeAction("确认")
                .feeCancelAction("取消")
                .feeShow()
            
            let sub = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            sub.backgroundColor = UIColor.red
            view.addSubview(sub)
            
            sub.snp.makeConstraints { make in
                make.width.equalTo(180.0)
                make.height.equalTo(300.0)
            }
            
            view.snp.makeConstraints { make in
                make.edges.equalTo(sub).inset(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
            }
            
            /// 模拟自定义视图约束发生变化
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                sub.snp.updateConstraints { make in
                    make.width.equalTo(100.0)
                    make.height.equalTo(100.0)
                }
                
                print(view.frame)
                view.layoutIfNeeded()
                print(view.frame)
            }
        case 17:
            FEEAlert.alert.config
                .feeTitle("标题")
                .feeContent("内容")
                .feeCancelAction("取消") {
                    // 取消点击事件Block
                }
                .feeAction("确认") {
                    // 确认点击事件Block
                }
                .feeCornerRadii(CornerRadii(topLeft: 50, topRight: 20, bottomLeft: 10, bottomRight: 10)) // 指定圆角半径 基于LayerMask实现 优先级高于
                .feeShow() // 设置完成后 别忘记调用Show来显示
        case 18:
            FEEAlert.alert.config
                .feeTitle("标题")
                .feeContent("内容")
                .feeCancelAction("取消") {
                    // 取消点击事件Block
                }
                .feeAction("确认") {
                    // 确认点击事件Block
                }
            //        .feePresentation(FEEPresentation.windowLevel(UIWindow.Level.alert))
                .feePresentation(FEEPresentation.viewController(self))
                .feeShow() // 设置完成后别忘记调用Show来显示
            
        case 19:
            FEEAlert.alert.config
                .feeTitle("标题")
                .feeContent("竖屏内容高度不太够，可以横屏观看，也可以增加点item来查看效果\nღ( ´･ᴗ･` )比心")
                .feeCancelAction("取消") { }
                .feeAction("确认1") { }
                .feeAction("确认2") { }
                .feeAction("确认3") { }
                .feeAction("确认4") { }
                .feeAction("确认5") { }
                .feeAction("确认6") { }
                .feeAction("确认7") { }
                .feeAction("确认8") { }
                .feeAction("确认9") { }
                .feeIsActionFollowScrollEnabled(false) // 不跟随滑动时如果最大高度不够内容显示，那么 item 和 action 会按照各自50%的高度来划分区域
                .feeShow() // 设置完成后别忘记调用Show来显示
        default:
            break
        }
    }
    
    // MARK: - Demo
    func demo(_ index: Int) {
        switch index {
            // 确认删除
        case 0:
            let blueColor = UIColor(red: 90/255.0, green: 154/255.0, blue: 239/255.0, alpha: 1.0)
            FEEAlert.alert.config
                .feeTitle { label in
                    label.text = "确认删除?"
                    label.textColor = UIColor.white
                }
                .feeContent { label in
                    label.text = "删除后将无法恢复，请慎重考虑"
                    label.textColor = UIColor.white.withAlphaComponent(0.75)
                }
                .feeAddAction { action in
                    action.type = .cancel
                    action.title = "取消"
                    action.titleColor = blueColor
                    action.backgroundColor = UIColor.white
                    action.clickBlock = {
                        // 取消点击事件Block
                    }
                }
                .feeAddAction { action in
                    action.type = .default
                    action.title = "删除"
                    action.titleColor = blueColor
                    action.backgroundColor = UIColor.white
                    action.clickBlock = {
                        // 删除点击事件Block
                    }
                }
                .feeHeaderColor(blueColor)
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
            
            // 分享视图
        case 1:
            // 假设 ShareView 是一个用于分享的自定义 UIView
            let shareView = ShareView(frame: CGRect(x: 0, y: 0, width: 280, height: 0), infoArray: nil, maxLineNumber: 2, maxSingleCount: 3)
            shareView.layoutIfNeeded()
            
            shareView.openShareBlock = { type in
                print(type)
            }
            
            FEEAlert.alert.config
                .feeCustomView { custom in
                    custom.view = shareView
                    custom.positionType = .center
                }
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeAddAction { action in
                    action.type = .cancel
                    action.title = "取消"
                    action.titleColor = UIColor.gray
                }
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
            
            // 开启推送视图
        case 2:
            let view = OpenPushView(frame: CGRect(x: 0, y: 0, width: 280, height: 0))
            
            view.closeBlock = {
                FEEAlert.close()
            }
            
            FEEAlert.alert.config
                .feeCustomView(view)
                .feeHeaderInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
            
            // 签到完成视图
        case 3:
            let view = SignFinishView(frame: CGRect(x: 0, y: 0, width: 280, height: 0))
            
            view.closeBlock = {
                FEEAlert.close()
            }
            
            FEEAlert.alert.config
                .feeCustomView(view)
                .feeHeaderInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeHeaderColor(UIColor.clear)
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
            
            // 选择列表视图
        case 4:
            let view = SelectedListView(frame: CGRect(x: 0, y: 0, width: 280, height: 0), style: .plain)
            
            view.isSingle = true
            
            view.selectedBlock = { array in
                FEEAlert.close {
                    print("选中的\(array)")
                }
            }
            
            FEEAlert.alert.config
                .feeTitle("举报内容问题")
                .feeItemInsets(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
                .feeCustomView(view)
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeHeaderInsets(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
                .feeClickBackgroundClose(true)
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
            
            view.array = [
                SelectedListModel(sid: 0, title: "垃圾广告"),
                SelectedListModel(sid: 1, title: "淫秽色情"),
                SelectedListModel(sid: 2, title: "低俗辱骂"),
                SelectedListModel(sid: 3, title: "涉政涉密"),
                SelectedListModel(sid: 4, title: "欺诈谣言")
            ]
            
            // 选择省市区
        case 5:
            var province: String? = nil
            var city: String? = nil
            var area: String? = nil
            
            let resultBlock: () -> Void = {
                FEEAlert.alert.config
                    .feeTitle("结果")
                    .feeContent("\(province ?? "") \(city ?? "") \(area ?? "")")
                    .feeAction("好的")
                    .feeShow()
            }
            
            // 获取plist数据
            guard let addressInfo = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "address", ofType: "plist") ?? "") as? [String: Any],
                  let provinceArray = addressInfo["address"] as? [[String: Any]] else {
                return
            }
            
            // 获取省数据 并显示
            var array = [SelectedListModel]()
            provinceArray.enumerated().forEach { index, info in
                array.append(SelectedListModel(sid: index, title: info["name"] as? String ?? "", context: info))
            }
            
            let view = SelectedListView(frame: CGRect(x: 0, y: 0, width: 280, height: 0), style: .plain)
            view.isSingle = true
            view.selectedBlock = { array in
                FEEAlert.close {
                    // 根据选中的省获取市数据 并显示
                    if let model = array.first {
                        province = model.title //设置省
                        if let cityArray = model.context?["sub"] as? [[String: Any]] {
                            var cityArrayModel = [SelectedListModel]()
                            cityArray.enumerated().forEach { index, info in
                                cityArrayModel.append(SelectedListModel(sid: index, title: info["name"] as? String ?? "", context: info))
                            }
                            let cityView = SelectedListView(frame: CGRect(x: 0, y: 0, width: 280, height: 0), style: .plain)
                            cityView.isSingle = true
                            cityView.selectedBlock = { array in
                                FEEAlert.close {
                                    // 根据选中的市获取区数据 并显示
                                    if let model = array.first {
                                        city = model.title //设置市
                                        if let areaArray = model.context?["sub"] as? [String] {
                                            var areaArrayModel = [SelectedListModel]()
                                            areaArray.enumerated().forEach { index, area in
                                                areaArrayModel.append(SelectedListModel(sid: index, title: area))
                                            }
                                            let areaView = SelectedListView(frame: CGRect(x: 0, y: 0, width: 280, height: 0), style: .plain)
                                            areaView.isSingle = true
                                            areaView.selectedBlock = { array in
                                                FEEAlert.close {
                                                    // 获取区数据 并显示最终结果
                                                    if let model = array.first {
                                                        area = model.title //设置区
                                                        resultBlock()
                                                    }
                                                }
                                            }
                                            
                                            FEEAlert.alert.config
                                                .feeTitle(model.title)
                                                .feeCustomView(areaView)
                                                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                                                .feeHeaderInsets(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
                                                .feeClickBackgroundClose(true)
                                                #if __IPHONE_13_0
                                                .feeUserInterfaceStyle(.light)
                                                #endif
                                                .feeShow()
                                            
                                            areaView.array = areaArrayModel
                                        } else {
                                            resultBlock()
                                        }
                                    }
                                }
                            }
                            
                            FEEAlert.alert.config
                                .feeTitle(model.title)
                                .feeCustomView(cityView)
                                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                                .feeHeaderInsets(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
                                .feeClickBackgroundClose(true)
                                #if __IPHONE_13_0
                                .feeUserInterfaceStyle(.light)
                                #endif
                                .feeShow()
                            
                            cityView.array = cityArrayModel
                        } else {
                            resultBlock()
                        }
                    }
                }
            }
            
            FEEAlert.alert.config
                .feeTitle("选择省")
                .feeCustomView(view)
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeHeaderInsets(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
                .feeClickBackgroundClose(true)
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
            
            view.array = array
            
            // 评分
        case 6:
            FEEAlert.alert.config
                .feeTitle("评个分吧")
                .feeContent { label in
                    label.text = "如果您觉得不错，那就给个五星好评吧 亲~"
                    label.textColor = UIColor.gray
                }
                .feeAddAction { action in
                    action.title = "果断拒绝"
                    action.titleColor = UIColor.darkGray
                    action.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
                    action.backgroundHighlightColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
                    action.insets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
                    action.borderPosition = [.top, .bottom, .left, .right]
                    action.borderWidth = 1.0
                    action.borderColor = action.backgroundHighlightColor
                    action.cornerRadius = 5.0
                }
                .feeAddAction { action in
                    action.title = "立刻吐槽"
                    action.titleColor = UIColor.darkGray
                    action.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
                    action.backgroundHighlightColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1.0)
                    action.insets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
                    action.borderPosition = [.top, .bottom, .left, .right]
                    action.borderWidth = 1.0
                    action.borderColor = action.backgroundHighlightColor
                    action.cornerRadius = 5.0
                }
                .feeAddAction { action in
                    action.type = .cancel
                    action.title = "五星好评"
                    action.titleColor = UIColor.white
                    action.backgroundColor = UIColor(red: 243/255.0, green: 94/255.0, blue: 83/255.0, alpha: 1.0)
                    action.backgroundHighlightColor = UIColor(red: 219/255.0, green: 100/255.0, blue: 94/255.0, alpha: 1.0)
                    action.insets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
                    action.borderPosition = [.top, .bottom, .left, .right]
                    action.borderWidth = 1.0
                    action.borderColor = action.backgroundHighlightColor
                    action.cornerRadius = 5.0
                }
                .feeCornerRadius(2.0)
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
        case 7:
            let redColor = UIColor(red: 221/255.0, green: 86/255.0, blue: 78/255.0, alpha: 1.0)

            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 280, height: 280 * 0.4))
            imageView.image = UIImage(named: "infor_pop_hongbao")

            FEEAlert.alert.config
                .feeCustomView(imageView)
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeTitle { label in
                    label.text = "注册后您将获得"
                    label.textColor = redColor
                    label.font = UIFont.systemFont(ofSize: 16.0)
                }
                .feeItemInsets(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
                .feeTitle { label in
                    label.text = "¥10.0"
                    label.textColor = UIColor.black
                    label.font = UIFont.boldSystemFont(ofSize: 35.0)
                }
                .feeItemInsets(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
                .feeTitle { label in
                    label.text = "注册后存入您的余额"
                    label.textColor = UIColor.gray
                    label.font = UIFont.systemFont(ofSize: 12.0)
                }
                .feeItemInsets(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
                .feeAddAction { action in
                    action.type = .cancel
                    action.title = "立即注册"
                    action.titleColor = UIColor.white
                    action.backgroundColor = redColor
                    action.backgroundHighlightColor = UIColor(red: 219/255.0, green: 100/255.0, blue: 94/255.0, alpha: 1.0)
                    action.insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    action.cornerRadius = 5.0
                }
                .feeCornerRadius(5.0)
                .feeHeaderInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeHeaderColor(UIColor(red: 239 / 255.0, green: 225 / 255.0, blue: 212 / 255.0, alpha: 1.0))
                .feeClickBackgroundClose(true)
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()

            
        default:
            break
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AlertViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let info = dataArray[indexPath.section][indexPath.row]
        cell?.textLabel?.text = "\(indexPath.row). \(info["title"] ?? "")"
        cell?.textLabel?.textColor = .darkGray
        cell?.detailTextLabel?.text = info["content"]
        cell?.detailTextLabel?.textColor = .gray
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "基础" : "Demo"
    }
}

extension AlertViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            base(indexPath.row)
        } else {
            demo(indexPath.row)
        }
    }
}
