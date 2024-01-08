//
//  ActionSheetViewController.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class ActionSheetViewController: UIViewController {
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
                
        var baseArray = [[String: String]]()
        var demoArray = [[String: String]]()
        
        baseArray.append(["title": "显示一个默认的 actionSheet 菜单", "content": ""])
        baseArray.append(["title": "显示一个带取消按钮的 actionSheet 菜单", "content": ""])
        baseArray.append(["title": "显示一个不同控件顺序的 actionSheet 菜单", "content": "设置的顺序决定了控件显示的顺序."])
        baseArray.append(["title": "显示一个带自定义视图的 actionSheet 菜单", "content": "自定义视图的size发生改变时 会自动适应其改变."])
        baseArray.append(["title": "显示一个横竖屏不同宽度的 actionSheet 菜单", "content": "最大高度与最大宽度设置方法一样"])
        baseArray.append(["title": "显示一个自定义标题和内容的 actionSheet 菜单", "content": "除了标题和内容 其他控件均支持自定义."])
        baseArray.append(["title": "显示一个多种action的 actionSheet 菜单", "content": "action分为三种类型 可添加多个 设置的顺序决定了显示的顺序."])
        baseArray.append(["title": "显示一个自定义action的 actionSheet 菜单", "content": "action的自定义属性可查看\"LEEAction\"类."])
        baseArray.append(["title": "显示一个可动态改变action的 actionSheet 菜单", "content": "已经显示后 可再次对action进行调整"])
        baseArray.append(["title": "显示一个可动态改变标题和内容的 actionSheet 菜单", "content": "已经显示后 可再次对其进行调整"])
        baseArray.append(["title": "显示一个模糊背景样式的 actionSheet 菜单", "content": "传入UIBlurEffectStyle枚举类型 默认为Dark"])
        baseArray.append(["title": "显示多个加入队列和优先级的 actionSheet 菜单", "content": "当多个同时需要显示时, 队列和优先级决定了如何去显示"])
        baseArray.append(["title": "显示一个自定义动画配置的 actionSheet 菜单", "content": "可自定义打开与关闭的动画配置(UIView 动画)"])
        baseArray.append(["title": "显示一个自定义动画样式的 actionSheet 菜单", "content": "动画样式可设置动画方向, 淡入淡出, 缩放等"])
        baseArray.append(["title": "显示一个mask圆角的 actionSheet 菜单", "content": "通过CornerRadii指定各个圆角半径"])
        baseArray.append(["title": "显示一个Action不跟随Item滑动的 actionSheet 菜单", "content": "通过LeeIsActionFollowScrollEnabled属性设置是否跟随滑动"])
        
        demoArray.append(["title": "显示一个蓝色自定义风格的 actionSheet 菜单", "content": "菜单背景等颜色均可以自定义"])
        demoArray.append(["title": "显示一个类似微信布局的 actionSheet 菜单", "content": "只需要调整最大宽度,取消action的间隔颜色和底部间距即可"])
        demoArray.append(["title": "显示一个分享登录的 actionSheet 菜单", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个设置字体大小等级的 actionSheet 菜单", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个单选举报的 actionSheet 菜单", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个多选举报的 actionSheet 菜单", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        demoArray.append(["title": "显示一个带有更多功能的分享 actionSheet 菜单", "content": "类似某些复杂内容的弹框 可以通过封装成自定义视图来显示"])
        
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
            FEEAlert.actionsheet.config
                .feeTitle("标题")
                .feeContent("内容")
                .feeAction("好的") {
                    // 点击事件Block
                }
                .feeShow()
            
        case 1:
            FEEAlert.actionsheet.config
                .feeTitle("标题")
                .feeContent("内容")
                .feeAction("确认") {
                    // 点击事件Block
                }
                .feeCancelAction("取消") {
                    // 点击事件Block
                }
                .feeShow()
            
        case 2:
            FEEAlert.actionsheet.config
                .feeContent("内容")
                .feeTitle("标题")
                .feeAction("确认") {
                    // 点击事件Block
                }
                .feeCancelAction("取消") {
                    // 点击事件Block
                }
                .feeShow()
            
        case 3:
            let customView = UIView(frame: CGRect(x: 10, y: 0, width: 200, height: 100))
            customView.backgroundColor = UIColor(red: 43/255.0, green: 133/255.0, blue: 208/255.0, alpha: 1.0)
            customView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapAction(_:))))
            
            FEEAlert.actionsheet.config
                .feeTitle("标题")
                .feeContent("内容")
                // .feeCustomView(customView)
                .feeCustomView { custom in
                    custom.view = customView
                    // custom.isAutoWidth = true // 设置自动宽度后 会根据insets和最大的宽度自动计算自定义视图的宽度 并修改其frame属性
                }
                .feeAction("确认") {
                    // 点击事件Block
                }
                .feeCancelAction("取消") {
                    // 点击事件Block
                }
                .feeShow()
            
        case 4:
            FEEAlert.actionsheet.config
                .feeContent("内容")
                .feeTitle("标题")
                .feeAction("确认")
                .feeCancelAction("取消")
                // .feeMaxWidth(280) // feeMaxWidth设置的最大宽度为固定数值 横屏竖屏都会采用这个宽度 (高度同理)
                .feeConfigMaxWidth { type, size in // feeConfigMaxWidth可以单独对横屏竖屏情况进行设置
                    switch type {
                    case .horizontal:
                        // 横屏时最大宽度
                        return size.width * 0.7
                    case .vertical:
                        // 竖屏时最大宽度
                        return size.width * 0.9
                    }
                }
                .feeShow()
            
        case 5:
            FEEAlert.actionsheet.config
                .feeTitle { label in
                    label.text = "已经退出该群组"
                    label.textColor = UIColor.darkGray
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
            FEEAlert.actionsheet.config
                .feeTitle("这是一个actionSheet 它有三个不同类型的action!")
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
            FEEAlert.actionsheet.config
                .feeTitle("自定义 Action 的 actionSheet!")
                .feeAddAction { action in
                    action.type = .default
                    action.title = "自定义"
                    action.titleColor = UIColor.brown
                    action.highlight = "被点啦"
                    action.highlightColor = UIColor.orange
                    action.image = UIImage(named: "smile")
                    action.highlightImage = UIImage(named: "tongue")
                    action.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
                    action.height = 60.0
                    action.clickBlock = {
                        // 点击事件Block
                    }
                }
                .feeAddAction { action in
                    action.type = .cancel
                    action.title = "自定义"
                    action.titleColor = UIColor.orange
                    action.highlightColor = UIColor.brown
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
            
            FEEAlert.actionsheet.config
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
                        tempAction?.titleColor = UIColor.red
                        tempAction?.update() // 更改设置后 调用更新
                    }
                }
                .feeCancelAction("取消")
                .feeShow()
            
        case 9:
            var tempTitle: UILabel?
            var tempContent: UILabel?
            
            FEEAlert.actionsheet.config
                .feeTitle { label in
                    label.text = "动态改变标题和内容的actionSheet"
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
                        tempTitle?.textColor = UIColor.gray
                        tempTitle?.textAlignment = .left
                        
                        tempContent?.text = "一个改变后的内容"
                        tempContent?.textColor = UIColor.lightGray
                        tempContent?.textAlignment = .left
                        // 其他控件同理
                    }
                }
                .feeCancelAction("取消")
                .feeShow()
            
        case 10:
            FEEAlert.actionsheet.config
                .feeTitle("这是一个毛玻璃背景样式的actionSheet")
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
            
            FEEAlert.actionsheet.config
                .feeTitle("actionSheet 1")
                .feeCancelAction("取消")
                .feeAction("确认")
                .feeQueue(true)
                .feePriority(2)
                .feeShow()
            
            FEEAlert.actionsheet.config
                .feeTitle("actionSheet 2")
                .feeCancelAction("取消")
                .feeAction("确认")
                .feeQueue(true)
                .feePriority(1)
                .feeShow()

        case 12:
            FEEAlert.actionsheet.config
                .feeTitle("自定义动画配置的 Actionsheet")
                .feeContent("支持 自定义打开动画配置和关闭动画配置 基于 UIView 动画API")
                .feeAction("好的") {
                    // 点击事件Block
                }
                .feeOpenAnimationConfig { animatingBlock, animatedBlock in
                    UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
                        animatingBlock() //调用动画中Block
                    }) { finished in
                        animatedBlock() //调用动画结束Block
                    }
                }
                .feeCloseAnimationConfig { animatingBlock, animatedBlock in
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                        animatingBlock()
                    }) { finished in
                        animatedBlock()
                    }
                }
                .feeShow()

        case 13:
            /*
             动画样式的方向只可以设置一个 其他样式枚举可随意增加.
             动画样式和动画配置可同时设置 这里不多做演示 欢迎自行探索
             */
            
            FEEAlert.actionsheet.config
                .feeTitle("自定义动画样式的 Actionsheet")
                .feeContent("动画样式可设置动画方向, 淡入淡出, 缩放等")
                .feeAction("好的") {
                    // 点击事件Block
                }
                //.feeOpenAnimationStyle([.orientationTop, .zoomShrink]) //这里设置打开动画样式的方向为上 以及淡入效果.
                //.feeCloseAnimationStyle([.orientationBottom, .zoomShrink]) //这里设置关闭动画样式的方向为下 以及淡出效果
                .feeOpenAnimationStyle([.orientationLeft, .fade]) //这里设置打开动画样式的方向为左 以及缩放效果.
                .feeCloseAnimationStyle([.orientationRight, .fade]) //这里设置关闭动画样式的方向为右 以及缩放效果
                .feeShow()

        case 14:
            FEEAlert.actionsheet.config
                .feeTitle("标题")
                .feeContent("内容")
                .feeCancelAction("取消") {
                    // 取消点击事件Block
                }
                .feeAction("确认") {
                    // 确认点击事件Block
                }
                // 在ActionSheet中 由于特殊的UI结构 圆角设置方法分为3个, 分别控制整体, 头部, 取消按钮.
                //.feeCornerRadius(20)  // 相当于于feeCornerRadii
                .feeCornerRadii(CornerRadii.zero)   // 指定整体圆角半径 基于LayerMask实现
                .feeActionSheetHeaderCornerRadii(CornerRadii(topLeft: 50, topRight: 20, bottomLeft: 10, bottomRight: 10)) // 指定头部圆角半径
                .feeActionSheetCancelActionCornerRadii(CornerRadii(topLeft: 10, topRight: 20, bottomLeft: 10, bottomRight: 10)) // 指定取消按钮圆角半径
                .feeShow() // 设置完成后 别忘记调用Show来显示

        case 15:
            FEEAlert.actionsheet.config
                .feeTitle("标题")
                .feeContent("竖屏内容高度不太够, 可以横屏观看, 也可以增加点item来查看效果\nღ( ´･ᴗ･` )比心")
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
                .feeIsActionFollowScrollEnabled(false) // 不跟随滑动时 如果最大高度不够内容显示 那么 item和action会按照各自50%的高度来划分区域
                .feeShow() // 设置完成后 别忘记调用Show来显示

        default:
            break
        }

    }
    
    // MARK: - Demo
    func demo(_ index: Int) {
        switch index {
        case 0:
            let blueColor = UIColor(red: 90/255.0, green: 154/255.0, blue: 239/255.0, alpha: 1.0)

            FEEAlert.actionsheet.config
                .feeTitle { label in
                    label.text = "确认删除?"
                    label.textColor = UIColor.white
                }
                .feeContent { label in
                    label.text = "删除后将无法恢复, 请慎重考虑"
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
        case 1:
            FEEAlert.actionsheet.config
                .feeContent("退出后不会通知群聊中其他成员, 且不会接收此群聊消息.出后不会通知群聊中其他成员, 且不会接收此群聊消息")
                .feeDestructiveAction("确定") {
                    // 点击事件回调Block
                }
                .feeAddAction { action in
                    action.type = .cancel
                    action.title = "取消"
                    action.titleColor = UIColor.black
                    action.font = UIFont.systemFont(ofSize: 18.0)
                }
                .feeActionSheetCancelActionSpaceColor(UIColor(white: 0.92, alpha: 1.0)) // 设置取消按钮间隔的颜色
                .feeActionSheetBottomMargin(0.0) // 设置底部距离屏幕的边距为0
                .feeCornerRadii(CornerRadii(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0))   // 指定整体圆角半径
                .feeActionSheetHeaderCornerRadii(CornerRadii.zero) // 指定头部圆角半径
                .feeActionSheetCancelActionCornerRadii(CornerRadii.zero) // 指定取消按钮圆角半径
                .feeConfigMaxWidth { type, size in
                    // 这是最大宽度为屏幕宽度 (横屏和竖屏)
                    return size.width
                }
                .feeActionSheetBackgroundColor(UIColor.white) // 通过设置背景颜色来填充底部间隙
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
        case 2:
            // 初始化分享视图

            let width = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width) - 20

            let shareView = ShareView(frame: CGRect(x: 0, y: 0, width: width, height: 0), infoArray: nil, maxLineNumber: 2, maxSingleCount: 3)

            shareView.openShareBlock = { type in
                print(type.rawValue)
            }

            FEEAlert.actionsheet.config
                .feeCustomView { custom in
                    custom.view = shareView
                    custom.positionType = .center
                }
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeAddAction { action in
                    action.type = .default
                    action.title = "取消"
                    action.titleColor = UIColor.gray
                }
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
        case 3:
            let fontSizeView = FontSizeView()

            fontSizeView.changeBlock = { level in
                print("字体大小: \(level)")
            }

            FEEAlert.actionsheet.config
                .feeCustomView { custom in
                    custom.view = fontSizeView
                    custom.isAutoWidth = true
                }
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeAddAction { action in
                    action.title = "取消"
                    action.titleColor = UIColor.gray
                    action.height = 45.0
                }
                .feeHeaderInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeActionSheetBottomMargin(0.0)
                .feeActionSheetBackgroundColor(UIColor.white)
                .feeCornerRadius(0.0)
                .feeActionSheetHeaderCornerRadii(CornerRadii.zero)
                .feeConfigMaxWidth { type, size in
                    // 这是最大宽度为屏幕宽度(竖屏) 屏幕高度(横屏)
                    return type == .horizontal ? size.height : size.width
                }
                #if __IPHONE_13_0
                .feeUserInterfaceStyle(.light)
                #endif
                .feeShow()
        case 4:
            let view = SelectedListView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), style: .plain)

            view.isSingle = true

            view.selectedBlock = { array in
                FEEAlert.close {
                    print("选中的\(array)")
                }
            }

            FEEAlert.actionsheet.config
                .feeTitle("举报内容问题")
                .feeItemInsets(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
                .feeCustomView { custom in
                    custom.view = view
                    custom.isAutoWidth = true
                }
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeAddAction { action in
                    action.title = "取消"
                    action.titleColor = UIColor.black
                    action.backgroundColor = UIColor.white
                }
                .feeHeaderInsets(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
                .feeHeaderColor(UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0))
                .feeActionSheetBottomMargin(0.0) // 设置底部距离屏幕的边距为0
                .feeActionSheetBackgroundColor(UIColor.white)
                .feeCornerRadius(0.0) // 设置圆角曲率为0
                .feeConfigMaxWidth { _, size in
                    // 这是最大宽度为屏幕宽度 (横屏和竖屏)
                    return size.width
                }
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
        case 5:
            var tempAction: FEEAction?

            let view = SelectedListView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), style: .plain)

            view.isSingle = false

            view.selectedBlock = { array in
                print("选中的\(array)")
            }

            var blockView: SelectedListView? = view // 解决循环引用

            view.changedBlock = { array in
                // 当选择改变时 判断当前选中的数量 改变action的样式
                if array.count > 0 {
                    tempAction?.title = "举报"
                    tempAction?.titleColor = UIColor.red
                    tempAction?.clickBlock = { [weak blockView] in
                        blockView?.finish()
                        blockView = nil
                    }
                } else {
                    tempAction?.title = "取消"
                    tempAction?.titleColor = UIColor.lightGray
                    tempAction?.clickBlock = nil
                }
                tempAction?.update()
            }

            FEEAlert.actionsheet.config
                .feeTitle("举报内容问题")
                .feeItemInsets(UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
                .feeCustomView { custom in
                    custom.view = view
                    custom.isAutoWidth = true
                }
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeAddAction { action in
                    tempAction = action
                    action.title = "取消"
                    action.titleColor = UIColor.lightGray
                    action.backgroundColor = UIColor.white
                }
                .feeHeaderInsets(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
                .feeHeaderColor(UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0))
                .feeActionSheetBottomMargin(0.0) // 设置底部距离屏幕的边距为0
                .feeActionSheetBackgroundColor(UIColor.white)
                .feeCornerRadius(0.0) // 设置圆角曲率为0
                .feeConfigMaxWidth { (type, size) in
                    // 这是最大宽度为屏幕宽度 (横屏和竖屏)
                    return size.width
                }
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
        case 6:
            let view = AllShareView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), showMore: true, showReport: true)

            view.openShareBlock = { type in
                print("\(type.rawValue)")
            }

            view.openMoreBlock = { type in
                switch type {
                case .toTheme:
                    // 切换主题 (关于主题开源库 推荐一下: https://github.com/lixiang1994/LEETheme)
                    break
                case .toReport:
                    // 打开举报
                    self.demo(4)
                    break
                case .toFontSize:
                    // 打开字体设置
                    self.demo(3)
                    break
                case .toCopyLink:
                    // 复制链接
                    break
                }
            }

            // 显示代码可以封装到自定义视图中 例如 [view show];

            FEEAlert.actionsheet.config
                .feeCustomView { custom in
                    custom.view = view
                    custom.isAutoWidth = true
                }
                .feeItemInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeAddAction { action in
                    action.title = "取消"
                    action.titleColor = UIColor.gray
                    action.height = 45.0
                }
                .feeHeaderInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
                .feeActionSheetBottomMargin(0.0)
                .feeActionSheetBackgroundColor(UIColor.white)
                .feeCornerRadius(0.0)
                .feeConfigMaxWidth { _, size in
                    // 这是最大宽度为屏幕宽度 (横屏和竖屏)
                    return size.width
                }
                .feeOpenAnimationConfig { animatingBlock, animatedBlock in
                    UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
                        animatingBlock() //调用动画中Block
                    }, completion: { finished in
                        animatedBlock() //调用动画结束Block
                    })
                }
                #if canImport(iOS)
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

extension ActionSheetViewController: UITableViewDataSource {
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

extension ActionSheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            base(indexPath.row)
        } else {
            demo(indexPath.row)
        }
    }
}
