//
//  FEEAlert.swift
//  FEEALert
//
//  Created by Fee on 2024/1/2.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let defaultBorderWidth: CGFloat = (1.0 / UIScreen.main.scale + 0.02)
func viewSafeAreaInsets(_ view: UIView) -> UIEdgeInsets {
    if #available(iOS 11.0, *) {
        return view.safeAreaInsets
    } else {
        return UIEdgeInsets.zero
    }
}

protocol FEEAlertProtocol: AnyObject {
    func close(completionBlock: (() -> Void)?)
}

class FEEAlert: NSObject {
    
    static let shared = FEEAlert()
    
    var mainWindow: UIWindow? {
        didSet {
            if #available(iOS 13.0, *) {
                if let windowScene = mainWindow?.windowScene,
                   let feeWindow = _feeWindow {
                    feeWindow.windowScene = windowScene
                }
            }
        }
    }
    var _feeWindow: FEEAlertWindow?
    var feeWindow: FEEAlertWindow {
        get {
            if _feeWindow == nil {
                if #available(iOS 13.0, *) {
                    if let windowScene = mainWindow?.windowScene {
                        _feeWindow = FEEAlertWindow(windowScene: windowScene)
                    } else {
                        _feeWindow = FEEAlertWindow(frame: UIScreen.main.bounds)
                    }
                } else {
                    _feeWindow = FEEAlertWindow(frame: UIScreen.main.bounds)
                }

                _feeWindow?.rootViewController = UIViewController()
                _feeWindow?.backgroundColor = UIColor.clear
                _feeWindow?.windowLevel = UIWindow.Level.alert
                _feeWindow?.isHidden = true
            }
            return _feeWindow!
        }
    }
    var queueArray = [FEEBaseConfig]()
    fileprivate var configArray = [FEEBaseConfig]()
    
    class var alert: FEEAlertConfig {
        let config = FEEAlertConfig()
        FEEAlert.shared.configArray.append(config)
        return config
    }
    
    class var actionsheet: FEEActionSheetConfig {
        let config = FEEActionSheetConfig()
        FEEAlert.shared.configArray.append(config)
        return config
    }
    
    class var alertWindow: FEEAlertWindow {
        return FEEAlert.shared.feeWindow
    }
    
    class func configMainWindow(_ window: UIWindow) {
        FEEAlert.shared.mainWindow = window
    }
    
    class func continueQueueDisplay() {
        FEEAlert.shared.queueArray.last?.config.modelFinishConfig?()
    }
    
    class func clearQueue() {
        if isQueueEmpty() {
            return
        }
        let last = FEEAlert.shared.queueArray.last
        FEEAlert.shared.queueArray.removeAll()
        last?.close()
    }
    
    class func isQueueEmpty() -> Bool {
        return FEEAlert.shared.queueArray.isEmpty
    }
    
    class func containsQueue(withIdentifier identifier: String) -> Bool {
        return FEEAlert.shared.queueArray.filter({ $0.config.modelIdentifier == identifier}).count > 0
    }
    
    class func close(identifier: String? = nil, force: Bool = false, completionBlock: (() -> Void)? = nil) {
        guard !FEEAlert.shared.queueArray.isEmpty else {
            completionBlock?()
            return
        }
        guard let identifier = identifier else {
            FEEAlert.shared.queueArray.last?.close(completionBlock: completionBlock)
            return
        }
        
        var isLast = false
        var removeArray: [FEEBaseConfig] = []
        FEEAlert.shared.queueArray.enumerated().forEach { index, config in
            let model = config.config
            if let modelIdentifier = model.modelIdentifier,
               identifier == modelIdentifier {
                if let _ = FEEAlert.shared.viewController,
                   index == FEEAlert.shared.queueArray.count {
                    if force {
                        model.modelShouldClose = { return true }
                    }
                    isLast = true
                } else {
                    removeArray.append(config)
                }
            }
        }
        FEEAlert.shared.queueArray.removeAll { removeArray.contains($0) }
        
        if isLast {
            close(completionBlock: completionBlock)
        } else {
            completionBlock?()
        }
    }
        
    var viewController: FEEBaseViewController?
}

class FEEBaseConfig: NSObject {
    
    var isShowing: Bool = false
    
    lazy var config: FEEBaseConfigModel = {
        let config = FEEBaseConfigModel()
        return config
    }()
    
    deinit {
    }
    
    override init() {
        super.init()
        isShowing = false
        config.modelFinishConfig = { [weak self] in
            guard let self = self else { return }
            if let last = FEEAlert.shared.queueArray.last {
                // 当前未加入队列 同时 已显示的优先级高于当前 跳过
                if !config.modelIsQueue && last.config.modelQueuePriority > config.modelQueuePriority {
                    return
                }
                // 已显示的未加入队列 同时已显示的优先级小于等于当前 关闭已显示的并移除
                if !last.config.modelIsQueue && last.config.modelQueuePriority <= config.modelQueuePriority {
                    last.close()
                    FEEAlert.shared.queueArray.removeLast()
                }
                // 已显示的已加入队列 同时已显示的优先级小于等于当前 关闭已显示的不移除
                if last.config.modelIsQueue && last.config.modelQueuePriority <= config.modelQueuePriority {
                    last.close()
                }
                
                if !FEEAlert.shared.queueArray.contains(self) {
                    FEEAlert.shared.queueArray.append(self)
                    FEEAlert.shared.queueArray.sort { $0.config.modelQueuePriority < $1.config.modelQueuePriority }
                }
                if FEEAlert.shared.queueArray.last === self {
                    self.show()
                }
            } else {
                self.show()
                FEEAlert.shared.queueArray.append(self)
            }
        }
    }
    
    func show() {
        guard let viewController = FEEAlert.shared.viewController else { return }
        
        viewController.config = config
        
        if let presentationWindow = config.modelPresentation as? FEEPresentationWindow {
            FEEAlert.shared.feeWindow.rootViewController = FEEAlert.shared.viewController
            FEEAlert.shared.feeWindow.windowLevel = presentationWindow.windowLevel
            FEEAlert.shared.feeWindow.isHidden = false
            if #available(iOS 13.0, *) {
                FEEAlert.shared.feeWindow.overrideUserInterfaceStyle = config.modelUserInterfaceStyle
            }
            FEEAlert.shared.feeWindow.makeKeyAndVisible()
            isShowing = true
        }
        
        if let presentationViewController = config.modelPresentation as? FEEPresentationViewController {
            guard let viewController = presentationViewController.viewController else { return }
            viewController.addChild(FEEAlert.shared.viewController!)
            viewController.view.addSubview(FEEAlert.shared.viewController!.view)
            if #available(iOS 13.0, *) {
                FEEAlert.shared.viewController?.view.overrideUserInterfaceStyle = config.modelUserInterfaceStyle
            }
            FEEAlert.shared.viewController?.view.frame = viewController.view.bounds
            FEEAlert.shared.viewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.didMove(toParent: viewController)
            isShowing = true
        }
        
        FEEAlert.shared.viewController?.openFinishBlock = {
            
        }
        
        FEEAlert.shared.viewController?.closeFinishBlock = { [weak self] in
            guard let self = self else { return }
            if FEEAlert.shared.queueArray.last === self {
                self.close()
                FEEAlert.shared.queueArray.removeLast()
                if self.config.modelIsContinueQueueDisplay {
                    FEEAlert.continueQueueDisplay()
                }
            } else {
                FEEAlert.shared.queueArray.removeAll { $0 === self }
            }
            self.config.modelCloseComplete?()
            FEEAlert.shared.configArray.removeAll { $0 == self}
        }
    }
    
    func close() {
        if !isShowing { return }
        if config.modelPresentation is FEEPresentationWindow {
            FEEAlert.shared.feeWindow.isHidden = true
            if #available(iOS 16.0, *) {
                // do nothing
            } else {
                FEEAlert.shared.feeWindow.resignKey()
            }
            FEEAlert.shared.feeWindow.rootViewController = nil
        }
        if config.modelPresentation is FEEPresentationViewController {
            FEEAlert.shared.viewController?.willMove(toParent: nil)
            FEEAlert.shared.viewController?.view.removeFromSuperview()
            FEEAlert.shared.viewController?.removeFromParent()
        }
        FEEAlert.shared.viewController = nil
        FEEAlert.shared.configArray.removeAll { $0 == self}
    }
    
    func close(completionBlock: (() -> Void)?) {
        FEEAlert.shared.viewController?.closeAnimations(completionBlock: completionBlock)
    }
}

class FEEAlertConfig: FEEBaseConfig {
    
    override init() {
        super.init()
        
        config.feeConfigMaxWidth({ _, _ in
            return 280.0
        })
        .feeConfigMaxHeight({ _, size in
            let safeAreaInsets = viewSafeAreaInsets(FEEAlert.shared.feeWindow)
            return size.height - 40.0 - safeAreaInsets.top - safeAreaInsets.bottom
        })
        .feeOpenAnimationStyle([.orientationNone, .fade, .zoomEnlarge])
        .feeCloseAnimationStyle([.orientationNone, .fade, .zoomShrink])
    }
    
    override func show() {
        FEEAlert.shared.viewController = FEEAlertViewController()
        super.show()
    }
}

class FEEActionSheetConfig: FEEBaseConfig {
    
    override init() {
        super.init()
        config.feeConfigMaxWidth({ type, size in
            let safeAreaInsets = viewSafeAreaInsets(FEEAlert.alertWindow)
            return type == .horizontal ? size.height - safeAreaInsets.top - safeAreaInsets.bottom - 20.0 : size.width - safeAreaInsets.left - safeAreaInsets.right - 20.0
        })
        .feeConfigMaxHeight({ _, size in
            let safeAreaInsets = viewSafeAreaInsets(FEEAlert.alertWindow)
            return size.height - 40.0 - safeAreaInsets.top - safeAreaInsets.bottom
        })
        .feeOpenAnimationStyle(.orientationBottom)
        .feeCloseAnimationStyle(.orientationBottom)
        .feeClickBackgroundClose(true)
    }
    
    override func show() {
        FEEAlert.shared.viewController = FEEActionSheetViewController()
        super.show()
    }
}

enum FEEBackgroundStyle {
    case blur
    case translucent
}

struct FEEAnimationStyle: OptionSet {
    let rawValue: Int

    static let orientationNone   = FEEAnimationStyle(rawValue: 1 << 0)
    static let orientationTop    = FEEAnimationStyle(rawValue: 1 << 1)
    static let orientationBottom = FEEAnimationStyle(rawValue: 1 << 2)
    static let orientationLeft   = FEEAnimationStyle(rawValue: 1 << 3)
    static let orientationRight  = FEEAnimationStyle(rawValue: 1 << 4)
    
    static let fade              = FEEAnimationStyle(rawValue: 1 << 12)
    
    static let zoomEnlarge       = FEEAnimationStyle(rawValue: 1 << 24)
    static let zoomShrink        = FEEAnimationStyle(rawValue: 2 << 24)
}

enum FEEScreenOrientationType: Int {
    case horizontal
    case vertical
}

struct CornerRadii {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    static func cornerRadiiEqualTo(_ lhs: CornerRadii, _ rhs: CornerRadii) -> Bool {
        return lhs.topLeft == rhs.topLeft &&
            lhs.topRight == rhs.topRight &&
            lhs.bottomLeft == rhs.bottomLeft &&
            lhs.bottomRight == rhs.bottomRight
    }
    
    static var zero: CornerRadii {
        return CornerRadii(topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0)
    }
    
    static var null: CornerRadii {
        return CornerRadii(topLeft: -1, topRight: -1, bottomLeft: -1, bottomRight: -1)
    }
}

class FEEBaseConfigModel {
    var modelActionArray: [((FEEAction) -> Void)] = []
    var modelItemArray: [((FEEItem) -> Void)] = []
    var modelItemInsetsInfo: [Int: NSValue] = [:]
    
    var modelShadowOpacity: CGFloat = 0.3 //默认阴影不透明度
    var modelShadowRadius: CGFloat = 5.0 //默认阴影半径
    var modelOpenAnimationDuration: CGFloat = 0.3 //默认打开动画时长
    var modelCloseAnimationDuration: CGFloat = 0.2 //默认关闭动画时长
    var modelBackgroundStyleColorAlpha: CGFloat = 0.45 //自定义背景样式颜色透明度 默认为半透明背景样式 透明度为0.45f
    var modelQueuePriority: Int = 0 //默认队列优先级 (大于0时才会加入队列)
    
    var modelShadowColor: UIColor = .black //默认阴影颜色
    var modelHeaderColor: UIColor = { //默认颜色
        if #available(iOS 13.0, *) {
            return .tertiarySystemBackground
        }
        return .white
    }()
    var modelBackgroundColor: UIColor = .black //默认背景半透明颜色
    
    var modelIsClickHeaderClose: Bool = false
    var modelIsClickBackgroundClose: Bool = false //默认点击背景不关闭
    var modelIsShouldAutorotate: Bool = true //默认支持自动旋转
    var modelIsQueue: Bool = false //默认不加入队列
    var modelIsContinueQueueDisplay: Bool = true //默认继续队列显示
    var modelIsAvoidKeyboard: Bool = true //默认闪避键盘
    var modelIsScrollEnabled: Bool = true //默认可以滑动
    var modelIsShowsScrollIndicator: Bool = true //默认显示滑动指示器
    
    var modelIsActionFollowScrollEnabled: Bool = true //默认 Action 跟随 Item 滚动
    
    var modelShadowOffset: CGSize = CGSize(width: 0, height: 2) //默认阴影偏移
    var modelAlertCenterOffset: CGPoint = .zero
    var modelHeaderInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) //默认间距
    
    var modelIdentifier: String?
    
    var modelMaxWidthBlock: ((FEEScreenOrientationType, CGSize) -> CGFloat)?
    var modelMaxHeightBlock: ((FEEScreenOrientationType, CGSize) -> CGFloat)?
    
    var modelOpenAnimationConfigBlock: ((@escaping () -> Void, @escaping () -> Void) -> Void)?
    var modelCloseAnimationConfigBlock: ((@escaping () -> Void, @escaping () -> Void) -> Void)?
    var modelFinishConfig: (() -> Void)?
    var modelShouldClose: (() -> Bool)?
    var modelShouldActionClickClose: ((Int) -> Bool)?
    var modelCloseComplete: (() -> Void)?
    
    var modelBackgroundStyle: FEEBackgroundStyle = .translucent //默认为半透明背景样式
    var modelOpenAnimationStyle: FEEAnimationStyle = .orientationNone
    var modelCloseAnimationStyle: FEEAnimationStyle = .orientationNone
    
    var modelStatusBarStyle: UIStatusBarStyle = .default
    var modelBackgroundBlurEffectStyle: UIBlurEffect.Style = .dark //默认模糊效果类型Dark
    var modelSupportedInterfaceOrientations: UIInterfaceOrientationMask = .all //默认支持所有方向
    var modelUserInterfaceStyle: UIUserInterfaceStyle = .unspecified //默认支持全部样式
    
    var modelCornerRadii: CornerRadii = CornerRadii(topLeft: 13.0, topRight: 13.0, bottomLeft: 13.0, bottomRight: 13.0) //默认圆角半径
    var modelActionSheetHeaderCornerRadii: CornerRadii = CornerRadii(topLeft: 13.0, topRight: 13.0, bottomLeft: 13.0, bottomRight: 13.0) //默认圆角半径
    var modelActionSheetCancelActionCornerRadii: CornerRadii = CornerRadii(topLeft: 13.0, topRight: 13.0, bottomLeft: 13.0, bottomRight: 13.0) //默认圆角半径
    
    var modelActionSheetBackgroundColor: UIColor = .clear //默认actionsheet背景颜色
    var modelActionSheetCancelActionSpaceColor: UIColor = .clear //默认actionsheet取消按钮间隔颜色
    var modelActionSheetCancelActionSpaceWidth: CGFloat = 10.0 //默认actionsheet取消按钮间隔宽度
    var modelActionSheetBottomMargin: CGFloat = 10.0 //默认actionsheet距离屏幕底部距离
    
    var modelPresentation: FEEPresentation = FEEPresentation.windowLevel(.alert)
    
    init() {
        modelOpenAnimationConfigBlock = { [weak self] animatingBlock, animatedBlock in
            UIView.animate(withDuration: self!.modelOpenAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                animatingBlock()
            }, completion: { finished in
                animatedBlock()
            })
        }
        modelCloseAnimationConfigBlock = { [weak self] animatingBlock, animatedBlock in
            UIView.animate(withDuration: self!.modelCloseAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                animatingBlock()
            }, completion: { finished in
                animatedBlock()
            })
        }
        modelShouldClose = {
            return true
        }
        modelShouldActionClickClose = { index in
            return true
        }
    }
    
    deinit {
        modelActionArray.removeAll()
        modelItemArray.removeAll()
        modelItemInsetsInfo.removeAll()
    }
    
    @discardableResult
    func feeAddItem(_ block: ((FEEItem) -> Void)?) -> Self {
        if let block = block {
            modelItemArray.append(block)
        }
        return self
    }
    
    @discardableResult
    func feeTitle(_ str: String? = nil, _ block: ((UILabel) -> Void)? = nil) -> Self {
        return feeAddItem { item in
            item.type = .title
            item.insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
            item.block = { view in
                if let label = view as? UILabel {
                    if let str = str {
                        label.text = str
                    }
                    block?(label)
                }
            }
        }
    }
    
    @discardableResult
    func feeContent(_ str: String? = nil, _ block: ((UILabel) -> Void)? = nil) -> Self {
        return feeAddItem { item in
            item.type = .content
            item.insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
            item.block = { view in
                if let label = view as? UILabel {
                    if let str = str {
                        label.text = str
                    }
                    block?(label)
                }
            }
        }
    }
    
    @discardableResult
    func feeCustomView(_ view: UIView? = nil, _ block: ((FEECustomView) -> Void)? = nil) -> Self {
        return feeAddItem { item in
            item.type = .customView
            item.insets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
            item.block = { customView in
                if let customView = customView as? FEECustomView {
                    if let view = view {
                        customView.view = view
                    }
                    block?(customView)
                }
            }
        }
    }
    
    @discardableResult
    func feeAddAction(_ block: ((FEEAction) -> Void)?) -> Self {
        if let block = block {
            modelActionArray.append(block)
        }
        return self
    }
    
    @discardableResult
    func feeAction(_ title: String, _ block: (() -> Void)? = nil) -> Self {
        return feeAddAction { action in
            action.type = .default
            action.title = title
            action.clickBlock = block
        }
    }
    
    @discardableResult
    func feeCancelAction(_ title: String, _ block: (() -> Void)? = nil) -> Self {
        return feeAddAction { action in
            action.type = .cancel
            action.title = title
            action.font = UIFont.boldSystemFont(ofSize: 18)
            action.clickBlock = block
        }
    }
    
    @discardableResult
    func feeDestructiveAction(_ title: String, _ block: (() -> Void)? = nil) -> Self {
        return feeAddAction { action in
            action.type = .destructive
            action.title = title
            action.titleColor = .systemRed
            action.clickBlock = block
        }
    }
    
    @discardableResult
    func feeHeaderInsets(_ insets: UIEdgeInsets) -> Self {
        var updatedInsets = insets
        
        updatedInsets.top = max(updatedInsets.top, 0)
        updatedInsets.left = max(updatedInsets.left, 0)
        updatedInsets.bottom = max(updatedInsets.bottom, 0)
        updatedInsets.right = max(updatedInsets.right, 0)
        
        modelHeaderInsets = updatedInsets
        return self
    }
    
    @discardableResult
    func feeItemInsets(_ insets: UIEdgeInsets) -> Self {
        if !modelItemArray.isEmpty {
            var updatedInsets = insets
            
            updatedInsets.top = max(updatedInsets.top, 0)
            updatedInsets.left = max(updatedInsets.left, 0)
            updatedInsets.bottom = max(updatedInsets.bottom, 0)
            updatedInsets.right = max(updatedInsets.right, 0)
            
            modelItemInsetsInfo[modelItemArray.count - 1] = NSValue(uiEdgeInsets: updatedInsets)
        } else {
            assertionFailure("请在添加的某一项后面设置间距")
        }
        
        return self
    }
    
    @discardableResult
    func feeMaxWidth(_ number: CGFloat) -> Self {
        return feeConfigMaxWidth { _, _ in
            return number
        }
    }
    
    @discardableResult
    public func feeConfigMaxWidth(_ block: @escaping (FEEScreenOrientationType, CGSize) -> CGFloat) -> Self {
        modelMaxWidthBlock = block
        return self
    }
    
    @discardableResult
    func feeMaxHeight(_ number: CGFloat) -> Self {
        return feeConfigMaxHeight { _, _ in
            return number
        }
    }
    
    @discardableResult
    func feeConfigMaxHeight(_ block: @escaping (FEEScreenOrientationType, CGSize) -> CGFloat) -> Self {
        modelMaxHeightBlock = block
        return self
    }
    
    @discardableResult
    func feeCornerRadius(_ number: CGFloat) -> Self {
        modelCornerRadii = CornerRadii(topLeft: number, topRight: number, bottomLeft: number, bottomRight: number)
        return self
    }
    
    @discardableResult
    func feeCornerRadii(_ radii: CornerRadii) -> Self {
        modelCornerRadii = radii
        return self
    }
    
    @discardableResult
    func feeOpenAnimationDuration(_ number: CGFloat) -> Self {
        modelOpenAnimationDuration = number
        return self
    }
    
    @discardableResult
    func feeCloseAnimationDuration(_ number: CGFloat) -> Self {
        modelCloseAnimationDuration = number
        return self
    }
    
    @discardableResult
    func feeHeaderColor(_ color: UIColor) -> Self {
        modelHeaderColor = color
        return self
    }
    
    @discardableResult
    func feeBackGroundColor(_ color: UIColor) -> Self {
        modelBackgroundColor = color
        return self
    }
    
    @discardableResult
    func feeBackgroundStyleTranslucent(_ number: CGFloat) -> Self {
        modelBackgroundStyle = .translucent
        modelBackgroundStyleColorAlpha = number
        return self
    }
    
    @discardableResult
    func feeBackgroundStyleBlur(_ style: UIBlurEffect.Style) -> Self {
        modelBackgroundStyle = .blur
        modelBackgroundBlurEffectStyle = style
        return self
    }
    
    @discardableResult
    func feeClickHeaderClose(_ isClose: Bool) -> Self {
        modelIsClickHeaderClose = isClose
        return self
    }
    
    @discardableResult
    func feeClickBackgroundClose(_ isClose: Bool) -> Self {
        modelIsClickBackgroundClose = isClose
        return self
    }
    
    @discardableResult
    func feeIsScrollEnabled(_ isEnabled: Bool) -> Self {
        modelIsScrollEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func feeIsShowsScrollIndicator(_ isShow: Bool) -> Self {
        modelIsShowsScrollIndicator = isShow
        return self
    }
    
    @discardableResult
    func feeIsActionFollowScrollEnabled(_ isEnabled: Bool) -> Self {
        modelIsActionFollowScrollEnabled = isEnabled
        return self
    }
    
    @discardableResult
    func feeShadowOffset(_ size: CGSize) -> Self {
        modelShadowOffset = size
        return self
    }
    
    @discardableResult
    func feeShadowOpacity(_ number: CGFloat) -> Self {
        modelShadowOpacity = number
        return self
    }
    
    @discardableResult
    func feeShadowRadius(_ number: CGFloat) -> Self {
        modelShadowRadius = number
        return self
    }
    
    @discardableResult
    func feeShadowColor(_ color: UIColor) -> Self {
        modelShadowColor = color
        return self
    }
    
    @discardableResult
    func feeIdentifier(_ string: String) -> Self {
        modelIdentifier = string
        return self
    }
    
    @discardableResult
    func feeQueue(_ isQueue: Bool) -> Self {
        modelIsQueue = isQueue
        return self
    }
    
    @discardableResult
    func feePriority(_ number: NSInteger) -> Self {
        modelQueuePriority = number > 0 ? number : 0
        return self
    }
    
    @discardableResult
    func feeContinueQueueDisplay(_ isContinue: Bool) -> Self {
        modelIsContinueQueueDisplay = isContinue
        return self
    }
    
    @discardableResult
    func feePresentation(_ presentation: FEEPresentation) -> Self {
        modelPresentation = presentation
        return self
    }
    
    @discardableResult
    func feeShouldAutorotate(_ isShouldAutorotate: Bool) -> Self {
        modelIsShouldAutorotate = isShouldAutorotate
        return self
    }
    
    @discardableResult
    func feeSupportedInterfaceOrientations(_ mask: UIInterfaceOrientationMask) -> Self {
        modelSupportedInterfaceOrientations = mask
        return self
    }
    
    @discardableResult
    func feeOpenAnimationConfig(_ block: @escaping (@escaping ()->Void, @escaping ()->Void)->Void) -> Self {
        modelOpenAnimationConfigBlock = block
        return self
    }
    
    @discardableResult
    func feeCloseAnimationConfig(_ block: @escaping (@escaping ()->Void, @escaping ()->Void)->Void) -> Self {
        modelCloseAnimationConfigBlock = block
        return self
    }
    
    @discardableResult
    func feeOpenAnimationStyle(_ style: FEEAnimationStyle) -> Self {
        modelOpenAnimationStyle = style
        return self
    }
    
    @discardableResult
    func feeCloseAnimationStyle(_ style: FEEAnimationStyle) -> Self {
        modelCloseAnimationStyle = style
        return self
    }
    
    @discardableResult
    func feeStatusBarStyle(_ style: UIStatusBarStyle) -> Self {
        modelStatusBarStyle = style
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func feeUserInterfaceStyle(_ style: UIUserInterfaceStyle) -> Self {
        modelUserInterfaceStyle = style
        return self
    }
    
    @discardableResult
    func feeShow() -> Self {
        modelFinishConfig?()
        return self
    }
    
    @discardableResult
    func feeShouldClose(_ block: @escaping () -> Bool) -> Self {
        modelShouldClose = block
        return self
    }
    
    @discardableResult
    func feeShouldActionClickClose(_ block: @escaping (NSInteger) -> Bool) -> Self {
        modelShouldActionClickClose = block
        return self
    }
    
    @discardableResult
    func feeCloseComplete(_ block: @escaping () -> Void) -> Self {
        modelCloseComplete = block
        return self
    }
}

// Alert
extension FEEBaseConfigModel {
    @discardableResult
    func feeTextField(_ block: ((UITextField) -> Void)? = nil) -> Self {
        return feeAddItem { item in
            item.type = .textField
            item.insets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            item.block = { view in
                if let textField = view as? UITextField {
                    block?(textField)
                }
            }
        }
    }
    
    @discardableResult
    func feeAlertCenterOffset(_ offset: CGPoint) -> Self {
        modelAlertCenterOffset = offset
        return self
    }

    @discardableResult
    func feeAvoidKeyboard(_ isAvoid: Bool) -> Self {
        modelIsAvoidKeyboard = isAvoid
        return self
    }
}

// ActionSheet
extension FEEBaseConfigModel {
    
    @discardableResult
    func feeActionSheetCancelActionSpaceWidth(_ number: CGFloat) -> Self {
        modelActionSheetCancelActionSpaceWidth = number
        return self
    }
    
    @discardableResult
    func feeActionSheetCancelActionSpaceColor(_ color: UIColor) -> Self {
        modelActionSheetCancelActionSpaceColor = color
        return self
    }
    
    @discardableResult
    func feeActionSheetBottomMargin(_ number: CGFloat) -> Self {
        modelActionSheetBottomMargin = number
        return self
    }
    
    @discardableResult
    func feeActionSheetBackgroundColor(_ color: UIColor) -> Self {
        modelActionSheetBackgroundColor = color
        return self
    }
    
    @discardableResult
    func feeActionSheetHeaderCornerRadii(_ radii: CornerRadii) -> Self {
        modelActionSheetHeaderCornerRadii = radii
        return self
    }
    
    @discardableResult
    func feeActionSheetCancelActionCornerRadii(_ radii: CornerRadii) -> Self {
        modelActionSheetCancelActionCornerRadii = radii
        return self
    }
}

class FEEPresentation {
    class func windowLevel(_ level: UIWindow.Level) -> FEEPresentationWindow {
        return FEEPresentationWindow(level)
    }
    
    class func viewController(_ controller: UIViewController) -> FEEPresentationViewController {
        return FEEPresentationViewController(controller)
    }
}

class FEEPresentationWindow: FEEPresentation {
    var windowLevel: UIWindow.Level = .normal
    
    init(_ level: UIWindow.Level) {
        super.init()
        windowLevel = level
    }
}

class FEEPresentationViewController: FEEPresentation {
    var viewController: UIViewController?
    
    init(_ controller: UIViewController) {
        super.init()
        viewController = controller
    }
}

enum FEEItemType: Int {
    case title
    case content
    case textField
    case customView
}

class FEEItem {
    
    /// Item 类型
    var type: FEEItemType = .title
    
    /// Item 间距范围
    var insets: UIEdgeInsets = .zero
    
    /// Item 设置视图闭包
    var block: ((Any) -> Void)?
    
    /// Item 更新闭包
    var updateBlock: ((FEEItem) -> Void)?
    
    /// 更新 Item
    func update() {
        updateBlock?(self)
    }
}

class FEEAction: NSObject {
    
    enum FEEActionType: Int {
        case `default`
        case cancel
        case destructive
    }
    
    struct FEEActionBorderPosition: OptionSet {
        let rawValue: Int

        static let top = FEEActionBorderPosition(rawValue: 1 << 0)
        static let bottom = FEEActionBorderPosition(rawValue: 1 << 1)
        static let left = FEEActionBorderPosition(rawValue: 1 << 2)
        static let right = FEEActionBorderPosition(rawValue: 1 << 3)
    }
    
    // action类型
    var type: FEEActionType = .default
    // action标题
    var title: String?
    // action高亮标题
    var highlight: String?
    // action标题(attributed)
    var attributedTitle: NSAttributedString?
    // action高亮标题(attributed)
    var attributedHighlight: NSAttributedString?
    // action标题行数 默认为: 1
    var numberOfLines: Int = 1
    // action标题对齐方式 默认为: NSTextAlignmentLeft
    var textAlignment: NSTextAlignment = .left
    // action字体
    var font: UIFont?
    // action字体大小随宽度变化 默认为: NO
    var adjustsFontSizeToFitWidth: Bool = false
    // action断行模式 默认为: NSLineBreakByTruncatingMiddle
    var lineBreakMode: NSLineBreakMode = .byTruncatingMiddle
    // action标题颜色
    var titleColor: UIColor?
    // action高亮标题颜色
    var highlightColor: UIColor?
    // action背景颜色 (与 backgroundImage 相同)
    var backgroundColor: UIColor?
    // action高亮背景颜色
    var backgroundHighlightColor: UIColor?
    // action背景图片 (与 backgroundColor 相同)
    var backgroundImage: UIImage?
    // action高亮背景图片
    var backgroundHighlightImage: UIImage?
    // action图片
    var image: UIImage?
    // action高亮图片
    var highlightImage: UIImage?
    // action间距范围
    var insets: UIEdgeInsets = .zero
    // action图片的间距范围
    var imageEdgeInsets: UIEdgeInsets = .zero
    // action标题的间距范围
    var titleEdgeInsets: UIEdgeInsets = .zero
    // action内容边距
    var contentEdgeInsets: UIEdgeInsets = .zero
    // action内容垂直对齐
    var contentVerticalAlignment: UIControl.ContentVerticalAlignment = .center
    // action内容水平对齐
    var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .center
    // action圆角曲率
    var cornerRadius: CGFloat = 0.0
    // action高度
    var height: CGFloat = 0.0
    // action边框宽度
    var borderWidth: CGFloat = 0.0
    // action边框颜色
    var borderColor: UIColor?
    // action边框位置
    var borderPosition: FEEActionBorderPosition?
    // action点击不关闭 (仅适用于默认类型)
    var isClickNotClose: Bool = false
    // action点击事件回调Block
    var clickBlock: (() -> Void)?
    var updateBlock: ((FEEAction) -> Void)?
    
    // 更新操作
    func update() {
        updateBlock?(self)
    }
}

enum FEECustomViewPositionType: Int {
    case center
    case left
    case right
}

class FEECustomView: NSObject {
    
    var view: UIView? {
        didSet {
            guard let view = view else { return }
            
            oldValue?.removeFromSuperview()
            oldValue?.removeObserver(self, forKeyPath: "frame")
            oldValue?.removeObserver(self, forKeyPath: "bounds")
            
            view.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            view.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
            
            view.layoutIfNeeded()
            view.layoutSubviews()
            
            size = view.frame.size
            
            updateContainerFrame(view: view)
            
            container.addSubview(view)
            
            // 保证使用AutoLayout的自定义视图在容器视图内的位置正确
            if view.translatesAutoresizingMaskIntoConstraints == false {
                let centerXConstraint = NSLayoutConstraint(item: view,
                                                           attribute: .centerX,
                                                           relatedBy: .equal,
                                                           toItem: container,
                                                           attribute: .centerX,
                                                           multiplier: 1,
                                                           constant: 0)
                container.addConstraint(centerXConstraint)
                
                let centerYConstraint = NSLayoutConstraint(item: view,
                                                           attribute: .centerY,
                                                           relatedBy: .equal,
                                                           toItem: container,
                                                           attribute: .centerY,
                                                           multiplier: 1,
                                                           constant: 0)
                container.addConstraint(centerYConstraint)
            }
        }
    }
    
    var positionType: FEECustomViewPositionType = .center
    var isAutoWidth: Bool = false
    var item: FEEItem!
    lazy var container: UIView = {
        let container = UIView(frame: .zero)
        container.backgroundColor = UIColor.clear
        container.clipsToBounds = true
        
        container.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
        container.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        return container
    }()
    var size: CGSize = .zero
    var sizeChangedBlock: (() -> Void)?
    
    override init() {
        super.init()
        positionType = .center
    }
    
    deinit {
        view = nil
        container.removeObserver(self, forKeyPath: "frame")
        container.removeObserver(self, forKeyPath: "bounds")
    }
    
    func updateContainerFrame(view: UIView) {
        view.frame = view.bounds
        container.bounds = view.bounds
    }
    
    // KVO 监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let view = object as? UIView else { return }
        
        if view.isEqual(container), isAutoWidth, let keyPath = keyPath, keyPath == "frame" || keyPath == "bounds" {
            for subView in view.subviews {
                var tempFrame = subView.frame
                tempFrame.size.width = view.bounds.size.width
                subView.frame = tempFrame
            }
        }
        
        if view.isEqual(self.view) {
            if let keyPath = keyPath, keyPath == "frame" {
                if isAutoWidth {
                    size = CGSize(width: view.frame.size.width, height: size.height)
                }
                
                if size != view.frame.size {
                    size = view.frame.size
                    updateContainerFrame(view: view)
                    sizeChangedBlock?()
                }
            }
            
            if let keyPath = keyPath, keyPath == "bounds" {
                if isAutoWidth {
                    size = CGSize(width: view.bounds.size.width, height: size.height)
                }
                
                if size != view.bounds.size {
                    size = view.bounds.size
                    updateContainerFrame(view: view)
                    sizeChangedBlock?()
                }
            }
        }
    }
}

class FEEAlertWindow: UIWindow {}

class FEEBaseViewController: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        config = nil
        currentKeyWindow = nil
        backgroundVisualEffectView = nil
    }
    
    var config: FEEBaseConfigModel!
    private var _currentKeyWindow: UIWindow!
    var currentKeyWindow: UIWindow! {
        get {
            if _currentKeyWindow == nil {
                _currentKeyWindow = FEEAlert.shared.mainWindow
            }
            
            if _currentKeyWindow == nil {
                _currentKeyWindow = UIApplication.shared.keyWindow
            }
            
            if _currentKeyWindow.windowLevel != UIWindow.Level.normal {
                let predicate = NSPredicate(format: "windowLevel == %ld AND hidden == 0 ", UIWindow.Level.normal.rawValue)
                _currentKeyWindow = UIApplication.shared.windows.filter { predicate.evaluate(with: $0) }.first
            }
            
            if _currentKeyWindow != nil, (FEEAlert.shared.mainWindow == nil) {
                FEEAlert.shared.mainWindow = _currentKeyWindow
            }
            
            return _currentKeyWindow
        }
        set {
            _currentKeyWindow = newValue
        }
    }
    var backgroundVisualEffectView: UIVisualEffectView!
    
    var orientationType: FEEScreenOrientationType!
    var isShowing: Bool = false
    var isClosing: Bool = false
    var openFinishBlock: (() -> Void)?
    var closeFinishBlock: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = false
//        automaticallyAdjustsScrollViewInsets = false
        
        if config.modelBackgroundStyle == .blur {
            backgroundVisualEffectView = UIVisualEffectView(effect: nil)
            backgroundVisualEffectView?.frame = view.frame
            view.addSubview(backgroundVisualEffectView!)
        }
        
        view.backgroundColor = config.modelBackgroundColor.withAlphaComponent(0.0)
        
        orientationType = view.frame.height > view.frame.width ? .vertical : .horizontal
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let backgroundVisualEffectView = backgroundVisualEffectView {
            backgroundVisualEffectView.frame = view.frame
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        orientationType = size.height > size.width ? .vertical : .horizontal
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if config.modelIsClickBackgroundClose {
            closeAnimations(completionBlock: nil)
        }
    }
    
    // MARK: - Start Animations
    
    func showAnimations(completionBlock: (() -> Void)?) {
        currentKeyWindow?.endEditing(true)
        view.isUserInteractionEnabled = false
        view.layoutIfNeeded()
    }
    
    // MARK: - Close Animations
    
    func closeAnimations(completionBlock: (() -> Void)?) {
        FEEAlert.shared.feeWindow.endEditing(true)
    }
    
    // MARK: - Rotation
    
    override var shouldAutorotate: Bool {
        return config.modelIsShouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return config.modelSupportedInterfaceOrientations
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return config.modelStatusBarStyle
    }
}

class FEEAlertViewController: FEEBaseViewController, UIGestureRecognizerDelegate {
    var containerView: FEEView = FEEView()
    var contentView: FEEView = FEEView()
    private lazy var itemsScrollView: UIScrollView = {
        let _itemsScrollView = UIScrollView()
        _itemsScrollView.backgroundColor = UIColor.clear
        _itemsScrollView.isDirectionalLockEnabled = true
        _itemsScrollView.bounces = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapAction(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.delegate = self
        _itemsScrollView.addGestureRecognizer(tap)
        return _itemsScrollView
    }()
    var actionsScrollView: UIScrollView = {
        let _actionsScrollView = UIScrollView()
        _actionsScrollView.backgroundColor = .clear
        _actionsScrollView.isDirectionalLockEnabled = true
        _actionsScrollView.bounces = false
        return _actionsScrollView
    }()
    var alertItemArray: [NSObject] = [NSObject]()
    var alertActionArray: [FEEActionButton] = [FEEActionButton]()
    
    private var isShowingKeyboard = false
    private var keyboardFrame: CGRect = .zero
    
    deinit {
        alertItemArray.removeAll()
        alertActionArray.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNotification()
        configAlert()
    }
    
    private func configNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        var local = true
        
        if #available(iOS 9.0, *) {
            local = (notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber)?.boolValue ?? true
        }
        
        if config.modelIsAvoidKeyboard && local {
            if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
               let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
               let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                
                _ = UIView.AnimationCurve(rawValue: Int(curveValue)) ?? .linear
                keyboardFrame = keyboardFrameValue.cgRectValue
                
                isShowingKeyboard = round(keyboardFrame.origin.y) < SCREEN_HEIGHT
                
                UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                    self?.updateAlertLayout()
                }, completion: nil)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAlertLayout()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateAlertLayout()
    }
    
    private func updateAlertLayout() {
        updateAlertLayoutWith(viewWidth: view.frame.width, viewHeight: view.frame.height)
    }

    private func updateAlertLayoutWith(viewWidth: CGFloat, viewHeight: CGFloat) {
        let alertViewMaxWidth = config.modelMaxWidthBlock?(orientationType, CGSize(width: viewWidth, height: viewHeight)) ?? 280
        
        let safeAreaInsets = viewSafeAreaInsets(FEEAlert.shared.feeWindow)
        let height = viewHeight - 40.0 - safeAreaInsets.top - safeAreaInsets.bottom
        var alertViewMaxHeight = config.modelMaxHeightBlock?(orientationType, CGSize(width: viewWidth, height: viewHeight)) ?? height
        
        let offset = config.modelAlertCenterOffset
        
        // 解决设置 transform 导致触发 layoutSubviews 的问题 (动画效果异常)
        let transform = containerView.transform
        containerView.transform = .identity
        
        if isShowingKeyboard {
            if keyboardFrame.size.height > 0 {
                // 处理非全屏时当前视图在窗口中的位置 解决键盘遮挡范围计算问题
                let current = view.convert(view.bounds, to: view.window)
                let keyboardY = keyboardFrame.origin.y - current.origin.y
                alertViewMaxHeight = keyboardY - 20
                
                if #available(iOS 11.0, *) {
                    alertViewMaxHeight -= view.safeAreaInsets.top
                }
                
                var contentViewFrame = contentView.frame
                contentViewFrame.size.width = alertViewMaxWidth
                
                if config.modelIsActionFollowScrollEnabled {
                    let itemsHeight = updateItemsLayoutWithMaxWidth(maxWidth: alertViewMaxWidth)
                    contentViewFrame.size.height = itemsHeight > alertViewMaxHeight ? alertViewMaxHeight : itemsHeight
                    itemsScrollView.frame = contentViewFrame
                    itemsScrollView.contentSize = CGSize(width: alertViewMaxWidth, height: itemsHeight)
                    actionsScrollView.frame = CGRect(x: 0, y: contentViewFrame.size.height, width: alertViewMaxWidth, height: 0)
                    actionsScrollView.contentSize = CGSize.zero
                } else {
                    var itemsHeight = updateItemsLayoutWithMaxWidth(maxWidth: alertViewMaxWidth)
                    var actionsHeight = updateActionsLayoutWith(initialPosition: 0, maxWidth: alertViewMaxWidth)
                    itemsScrollView.contentSize = CGSize(width: alertViewMaxWidth, height: itemsHeight)
                    actionsScrollView.contentSize = CGSize(width: alertViewMaxWidth, height: actionsHeight)
                    
                    if (itemsHeight + actionsHeight) > alertViewMaxHeight {
                        contentViewFrame.size.height = alertViewMaxHeight
                        let maxActionsHeight = alertViewMaxHeight * 0.5
                        actionsHeight = actionsHeight < maxActionsHeight ? actionsHeight : maxActionsHeight
                        let maxItemsHeight = alertViewMaxHeight - actionsHeight
                        itemsHeight = itemsHeight < maxItemsHeight ? itemsHeight : maxItemsHeight
                        actionsHeight = alertViewMaxHeight - itemsHeight
                        itemsScrollView.frame = CGRect(x: 0, y: 0, width: alertViewMaxWidth, height: itemsHeight)
                        actionsScrollView.frame = CGRect(x: 0, y: itemsHeight, width: alertViewMaxWidth, height: actionsHeight)
                    } else {
                        contentViewFrame.size.height = itemsHeight + actionsHeight
                        itemsScrollView.frame = CGRect(x: 0, y: 0, width: alertViewMaxWidth, height: itemsHeight)
                        actionsScrollView.frame = CGRect(x: 0, y: itemsHeight, width: alertViewMaxWidth, height: actionsHeight)
                    }
                }
                
                contentView.frame = contentViewFrame
                
                var tempAlertViewY = keyboardY - contentViewFrame.size.height - 10
                let originalAlertViewY = (viewHeight - contentViewFrame.size.height) * 0.5 + offset.y
                
                var containerFrame = containerView.frame
                containerFrame.size.width = contentViewFrame.size.width
                containerFrame.size.height = contentViewFrame.size.height
                containerFrame.origin.x = (viewWidth - contentViewFrame.size.width) * 0.5 + offset.x
                tempAlertViewY = tempAlertViewY < originalAlertViewY ? tempAlertViewY : originalAlertViewY
                containerFrame.origin.y = tempAlertViewY
                containerView.frame = containerFrame
                
                if let firstResponder = findFirstResponder(in: itemsScrollView) {
                    itemsScrollView.scrollRectToVisible(firstResponder.frame, animated: true)
                }
            }
        } else {
            alertViewMaxHeight -= abs(offset.y)
            var contentViewFrame = contentView.frame
            contentViewFrame.size.width = alertViewMaxWidth
            
            if self.config.modelIsActionFollowScrollEnabled {
                let itemsHeight = updateItemsLayoutWithMaxWidth(maxWidth: alertViewMaxWidth)
                contentViewFrame.size.height = itemsHeight > alertViewMaxHeight ? alertViewMaxHeight : itemsHeight
                itemsScrollView.frame = contentViewFrame
                itemsScrollView.contentSize = CGSize(width: alertViewMaxWidth, height: itemsHeight)
                actionsScrollView.frame = CGRect(x: 0, y: contentViewFrame.size.height, width: alertViewMaxWidth, height: 0)
                actionsScrollView.contentSize = CGSize.zero
            } else {
                var itemsHeight = updateItemsLayoutWithMaxWidth(maxWidth: alertViewMaxWidth)
                var actionsHeight = updateActionsLayoutWith(initialPosition: 0, maxWidth: alertViewMaxWidth)
                itemsScrollView.contentSize = CGSize(width: alertViewMaxWidth, height: itemsHeight)
                actionsScrollView.contentSize = CGSize(width: alertViewMaxWidth, height: actionsHeight)
                
                if (itemsHeight + actionsHeight) > alertViewMaxHeight {
                    contentViewFrame.size.height = alertViewMaxHeight
                    let maxActionsHeight = alertViewMaxHeight * 0.5
                    actionsHeight = actionsHeight < maxActionsHeight ? actionsHeight : maxActionsHeight
                    let maxItemsHeight = alertViewMaxHeight - actionsHeight
                    itemsHeight = itemsHeight < maxItemsHeight ? itemsHeight : maxItemsHeight
                    actionsHeight = alertViewMaxHeight - itemsHeight
                    itemsScrollView.frame = CGRect(x: 0, y: 0, width: alertViewMaxWidth, height: itemsHeight)
                    actionsScrollView.frame = CGRect(x: 0, y: itemsHeight, width: alertViewMaxWidth, height: actionsHeight)
                } else {
                    contentViewFrame.size.height = itemsHeight + actionsHeight
                    itemsScrollView.frame = CGRect(x: 0, y: 0, width: alertViewMaxWidth, height: itemsHeight)
                    actionsScrollView.frame = CGRect(x: 0, y: itemsHeight, width: alertViewMaxWidth, height: actionsHeight)
                }
            }
            
            contentView.frame = contentViewFrame
            
            var containerFrame = containerView.frame
            containerFrame.size.width = contentViewFrame.size.width
            containerFrame.size.height = contentViewFrame.size.height
            containerFrame.origin.x = (viewWidth - alertViewMaxWidth) * 0.5 + offset.x
            containerFrame.origin.y = (viewHeight - contentViewFrame.size.height) * 0.5 + offset.y
            containerView.frame = containerFrame
        }
        
        containerView.transform = transform
    }
    
    private func updateItemsLayoutWithMaxWidth(maxWidth: CGFloat) -> CGFloat {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        var finalHeight: CGFloat = 0.0
        
        alertItemArray.enumerated().forEach { (idx, item) in
            if idx == 0 {
                finalHeight += config.modelHeaderInsets.top
            }
            
            if let view = item as? UIView {
                var viewItem: FEEItem!
                if let view = view as? FEEItemLabel {
                    viewItem = view.item
                }
                if let view = view as? FEEItemTextField {
                    viewItem = view.item
                }
                var viewFrame = view.frame
                let safeAreaInsets = viewSafeAreaInsets(view)
                viewFrame.origin.x = config.modelHeaderInsets.left + viewItem.insets.left + safeAreaInsets.left
                viewFrame.origin.y = finalHeight + viewItem.insets.top
                viewFrame.size.width = maxWidth - viewFrame.origin.x - config.modelHeaderInsets.right - viewItem.insets.right - safeAreaInsets.left - safeAreaInsets.right
                
                if view.isKind(of: UILabel.self) {
                    viewFrame.size.height = (item as! UILabel).sizeThatFits(CGSize(width: viewFrame.size.width, height: CGFloat(MAXFLOAT))).height
                }
                
                view.frame = viewFrame
                finalHeight += viewFrame.size.height + viewItem.insets.top + viewItem.insets.bottom
            } else if let custom = item as? FEECustomView {
                var viewFrame = custom.container.frame
                
                if custom.isAutoWidth {
                    custom.positionType = .center
                    viewFrame.size.width = maxWidth - config.modelHeaderInsets.left - custom.item.insets.left - config.modelHeaderInsets.right - custom.item.insets.right
                }
                
                switch custom.positionType {
                case .center:
                    viewFrame.origin.x = (maxWidth - viewFrame.size.width) * 0.5
                case .left:
                    viewFrame.origin.x = config.modelHeaderInsets.left + custom.item.insets.left
                case .right:
                    viewFrame.origin.x = maxWidth - config.modelHeaderInsets.right - custom.item.insets.right - viewFrame.size.width
                }
                
                viewFrame.origin.y = finalHeight + custom.item.insets.top
                custom.container.frame = viewFrame
                finalHeight += viewFrame.size.height + custom.item.insets.top + custom.item.insets.bottom
            }
            
            if item == alertItemArray.last {
                finalHeight += config.modelHeaderInsets.bottom
            }
        }
        
        if config.modelIsActionFollowScrollEnabled {
            finalHeight += updateActionsLayoutWith(initialPosition: finalHeight, maxWidth: maxWidth)
        }
        
        CATransaction.commit()
        
        return finalHeight
    }
    
    private func updateActionsLayoutWith(initialPosition: CGFloat, maxWidth: CGFloat) -> CGFloat {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        var finalHeight = initialPosition
        
        for button in alertActionArray {
            var buttonFrame = button.frame
            buttonFrame.origin.x = button.action.insets.left
            buttonFrame.origin.y = finalHeight + button.action.insets.top
            buttonFrame.size.width = maxWidth - button.action.insets.left - button.action.insets.right
            button.frame = buttonFrame
            finalHeight += buttonFrame.size.height + button.action.insets.top + button.action.insets.bottom
        }
        
        if alertActionArray.count == 2 {
            let buttonA = alertActionArray.count == config.modelActionArray.count ? alertActionArray.first! : alertActionArray.last!
            let buttonB = alertActionArray.count == config.modelActionArray.count ? alertActionArray.last! : alertActionArray.first!
            
            let buttonAInsets = buttonA.action.insets
            let buttonBInsets = buttonB.action.insets
            let buttonAHeight = buttonA.frame.height + buttonAInsets.top + buttonAInsets.bottom
            let buttonBHeight = buttonB.frame.height + buttonBInsets.top + buttonBInsets.bottom
            
            let minHeight = min(buttonAHeight, buttonBHeight)
            let minY = min((buttonA.frame.origin.y - buttonAInsets.top), (buttonB.frame.origin.y - buttonBInsets.top))
            
            buttonA.frame = CGRect(x: buttonAInsets.left, y: minY + buttonAInsets.top, width: (maxWidth / 2) - buttonAInsets.left - buttonAInsets.right, height: buttonA.frame.height)
            
            buttonB.frame = CGRect(x: (maxWidth / 2) + buttonBInsets.left, y: minY + buttonBInsets.top, width: (maxWidth / 2) - buttonBInsets.left - buttonBInsets.right, height: buttonB.frame.height)
            
            finalHeight -= minHeight
        }
        
        CATransaction.commit()
        
        return finalHeight - initialPosition
    }

    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }

        for subview in view.subviews {
            if let firstResponder = findFirstResponder(in: subview) {
                return firstResponder
            }
        }

        return nil
    }
    
    func configAlert() {
        view.addSubview(containerView)
        
        contentView.addSubview(itemsScrollView)
        contentView.addSubview(actionsScrollView)
        containerView.addSubview(contentView)
        
        containerView.layer.shadowOffset = config.modelShadowOffset
        containerView.layer.shadowRadius = config.modelShadowRadius
        containerView.layer.shadowOpacity = Float(config.modelShadowOpacity)
        containerView.layer.shadowColor = config.modelShadowColor.cgColor
        
        contentView.feeAlertCornerRadii = config.modelCornerRadii
        contentView.backgroundColor = config.modelHeaderColor
        
        itemsScrollView.isScrollEnabled = config.modelIsScrollEnabled
        itemsScrollView.showsVerticalScrollIndicator = config.modelIsShowsScrollIndicator
        
        actionsScrollView.isScrollEnabled = config.modelIsScrollEnabled
        actionsScrollView.showsVerticalScrollIndicator = config.modelIsShowsScrollIndicator
        
        config.modelItemArray.enumerated().forEach { [weak self] idx, obj in
            guard let self = self else { return }
            let itemBlock: ((FEEItem) -> Void)? = obj
            let item = FEEItem()
            
            itemBlock?(item)
            
            if let insetValue = config.modelItemInsetsInfo[idx] {
                item.insets = insetValue.uiEdgeInsetsValue
            }
            
            switch item.type {
            case .title:
                let labelBlock: ((UILabel) -> Void)? = item.block
                let label = FEEItemLabel.label()
                itemsScrollView.addSubview(label)
                alertItemArray.append(label)
                
                label.textAlignment = .center
                label.font = UIFont.boldSystemFont(ofSize: 18.0)
                
                if #available(iOS 13.0, *) {
                    label.textColor = UIColor.label
                } else {
                    label.textColor = UIColor.black
                }
                
                label.numberOfLines = 0
                labelBlock?(label)
                label.item = item
                
                label.textChangedBlock = { [weak self] in
                    self?.updateAlertLayout()
                }
                
            case .content:
                let labelBlock: ((UILabel) -> Void)? = item.block
                let label = FEEItemLabel.label()
                itemsScrollView.addSubview(label)
                alertItemArray.append(label)
                
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 14.0)
                
                if #available(iOS 13.0, *) {
                    label.textColor = UIColor.label
                } else {
                    label.textColor = UIColor.black
                }
                
                label.numberOfLines = 0
                labelBlock?(label)
                label.item = item
                
                label.textChangedBlock = { [weak self] in
                    self?.updateAlertLayout()
                }
                
            case .customView:
                let customBlock: ((FEECustomView) -> Void)? = item.block
                let custom = FEECustomView()
                customBlock?(custom)
                itemsScrollView.addSubview(custom.container)
                alertItemArray.append(custom)
                custom.item = item
                
                custom.sizeChangedBlock = { [weak self] in
                    self?.updateAlertLayout()
                }
                
            case .textField:
                let textField = FEEItemTextField.textField()
                textField.frame = CGRect(x: 0, y: 0, width: 0, height: 40.0)
                itemsScrollView.addSubview(textField)
                alertItemArray.append(textField)
                
                textField.borderStyle = .roundedRect
                
                let textFieldBlock: ((UITextField) -> Void)? = item.block
                textFieldBlock?(textField)
                
                textField.item = item
            }
        }
        
        // 根据 modelIsActionFollowScrollEnabled 属性控制Action添加到哪个父视图
        let actionContainerView = config.modelIsActionFollowScrollEnabled ? itemsScrollView : actionsScrollView
        
        config.modelActionArray.enumerated().forEach { [weak self] idx, item in
            guard let self = self else { return }
            let block: ((FEEAction) -> Void)? = item
            let action = FEEAction()
            block?(action)
            
            if action.font == nil {
                action.font = UIFont.systemFont(ofSize: 18.0)
            }
            
            if action.title == nil {
                action.title = "按钮"
            }
            
            if action.titleColor == nil {
                if #available(iOS 13.0, *) {
                    action.titleColor = UIColor.systemBlue
                } else {
                    action.titleColor = UIColor(red: 21/255.0, green: 123/255.0, blue: 245/255.0, alpha: 1.0)
                }
            }
            
            if action.backgroundColor == nil {
                action.backgroundColor = self.config.modelHeaderColor
            }
            
            if action.backgroundHighlightColor == nil {
                if #available(iOS 13.0, *) {
                    action.backgroundHighlightColor = UIColor.systemGray6
                } else {
                    action.backgroundHighlightColor = UIColor(white: 0.97, alpha: 1.0)
                }
            }
            
            if action.borderColor == nil {
                if #available(iOS 13.0, *) {
                    action.borderColor = UIColor.systemGray3
                } else {
                    action.borderColor = UIColor(white: 0.84, alpha: 1.0)
                }
            }
            
            if action.borderWidth == 0 {
                action.borderWidth = defaultBorderWidth
            }
            if action.borderPosition == nil {
                action.borderPosition = (config.modelActionArray.count == 2 && idx == 0) ? [.top, .right] : .top
            }
            if action.height == 0 {
                action.height = 45.0
            }
            
            let button = FEEActionButton.button()
            button.action = action
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            actionContainerView.addSubview(button)
            alertActionArray.append(button)
            
            button.heightChangedBlock = { [weak self] in
                self?.updateAlertLayout()
            }
        }
        
        // 更新布局
        updateAlertLayout()
        
        showAnimations(completionBlock: { [weak self] in
            self?.updateAlertLayout()
        })
    }
    
    @objc func buttonAction(_ sender: FEEActionButton) {
        
        var isClose = false
        var clickBlock: (() -> Void)? = nil
        
        switch sender.action.type {
        case .default:
            isClose = sender.action.isClickNotClose ? false : true
        case .cancel:
            isClose = true
        case .destructive:
            isClose = true
        }
        
        clickBlock = sender.action.clickBlock
        
        if isClose {
            if let modelShouldActionClickClose = config.modelShouldActionClickClose,
               modelShouldActionClickClose(alertActionArray.firstIndex(of: sender)!) {
                closeAnimations {
                    clickBlock?()
                }
            } else {
                clickBlock?()
            }
        } else {
            clickBlock?()
        }
    }

    @objc func headerTapAction(_ tap: UITapGestureRecognizer) {
        if config.modelIsClickHeaderClose {
            closeAnimations(completionBlock: nil)
        }
    }
    
    override func showAnimations(completionBlock: (() -> Void)?) {
        super.showAnimations(completionBlock: completionBlock)
        
        if isShowing { return }
        isShowing = true
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
        var containerFrame = containerView.frame
        
        if config.modelOpenAnimationStyle.contains(.orientationNone) {
            containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
            containerFrame.origin.y = (viewHeight - containerFrame.size.height) * 0.5
        } else if config.modelOpenAnimationStyle.contains(.orientationTop) {
            containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
            containerFrame.origin.y = 0 - containerFrame.size.height
        } else if config.modelOpenAnimationStyle.contains(.orientationBottom) {
            containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
            containerFrame.origin.y = viewHeight
        } else if config.modelOpenAnimationStyle.contains(.orientationLeft) {
            containerFrame.origin.x = 0 - containerFrame.size.width
            containerFrame.origin.y = (viewHeight - containerFrame.size.height) * 0.5
        } else if config.modelOpenAnimationStyle.contains(.orientationRight) {
            containerFrame.origin.x = viewWidth
            containerFrame.origin.y = (viewHeight - containerFrame.size.height) * 0.5
        }
        
        containerView.frame = containerFrame
        
        if config.modelOpenAnimationStyle.contains(.fade) {
            containerView.alpha = 0.0
        }
        
        if config.modelOpenAnimationStyle.contains(.zoomEnlarge) {
            containerView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
        
        if config.modelOpenAnimationStyle.contains(.zoomShrink) {
            containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
        if let modelOpenAnimationConfigBlock = config.modelOpenAnimationConfigBlock {
            modelOpenAnimationConfigBlock({ [weak self] in
                guard let self = self else { return }
                
                if self.config.modelBackgroundStyle == .translucent {
                    self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(self.config.modelBackgroundStyleColorAlpha)
                } else if self.config.modelBackgroundStyle == .blur {
                    self.backgroundVisualEffectView.effect = UIBlurEffect(style: self.config.modelBackgroundBlurEffectStyle)
                }
                
                var containerFrame = self.containerView.frame
                containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
                containerFrame.origin.y = (viewHeight - containerFrame.size.height) * 0.5
                self.containerView.frame = containerFrame
                
                self.containerView.alpha = 1.0
                self.containerView.transform = .identity
            }, { [weak self] in
                guard let self = self else { return }
                
                self.isShowing = false
                self.view.isUserInteractionEnabled = true
                
                self.openFinishBlock?()
                completionBlock?()
            })
        }
    }
    
    override func closeAnimations(completionBlock: (() -> Void)?) {
        super.closeAnimations(completionBlock: completionBlock)
        
        if isClosing { return }
        if let modelShouldClose = config.modelShouldClose, !modelShouldClose() {
            return
        }
        
        isClosing = true
        
        let viewWidth = view.frame.size.width
        let viewHeight = view.frame.size.height
                
        if let modelCloseAnimationConfigBlock = config.modelCloseAnimationConfigBlock {
            modelCloseAnimationConfigBlock({ [weak self] in
                guard let self = self else { return }
                
                if self.config.modelBackgroundStyle == .translucent {
                    self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0.0)
                } else if self.config.modelBackgroundStyle == .blur {
                    self.backgroundVisualEffectView.alpha = 0.0
                }
                
                var containerFrame = self.containerView.frame
                
                if self.config.modelCloseAnimationStyle.contains(.orientationNone) {
                    containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
                    containerFrame.origin.y = (viewHeight - containerFrame.size.height) * 0.5
                } else if self.config.modelCloseAnimationStyle.contains(.orientationTop) {
                    containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
                    containerFrame.origin.y = 0 - containerFrame.size.height
                } else if self.config.modelCloseAnimationStyle.contains(.orientationBottom) {
                    containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
                    containerFrame.origin.y = viewHeight
                } else if self.config.modelCloseAnimationStyle.contains(.orientationLeft) {
                    containerFrame.origin.x = 0 - containerFrame.size.width
                    containerFrame.origin.y = (viewHeight - containerFrame.size.height) * 0.5
                } else if self.config.modelCloseAnimationStyle.contains(.orientationRight) {
                    containerFrame.origin.x = viewWidth
                    containerFrame.origin.y = (viewHeight - containerFrame.size.height) * 0.5
                }
                
                self.containerView.frame = containerFrame
                
                if self.config.modelCloseAnimationStyle.contains(.fade) {
                    self.containerView.alpha = 0.0
                }
                
                if self.config.modelCloseAnimationStyle.contains(.zoomEnlarge) {
                    self.containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
                
                if self.config.modelCloseAnimationStyle.contains(.zoomShrink) {
                    self.containerView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                }
            }, { [weak self] in
                guard let self = self else { return }
                self.isClosing = false
                self.closeFinishBlock?()
                completionBlock?()
            })
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == itemsScrollView ? true : false
    }

}

class FEEActionSheetViewController: FEEBaseViewController, UIGestureRecognizerDelegate {
    private var isShowed = false
    
    var containerView: FEEView = FEEView()
    var contentView: FEEView = FEEView()
    private lazy var itemsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapAction(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        return scrollView
    }()
    var actionsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    var actionSheetItemArray = [Any]()
    var actionSheetActionArray = [FEEActionButton]()
    var actionSheetCancelActionSpaceView: UIView!
    var actionSheetCancelAction: FEEActionButton!
    
    deinit {
        actionSheetItemArray = []
        actionSheetCancelActionSpaceView = nil
        actionSheetCancelAction = nil
        actionSheetActionArray = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateActionSheetLayout()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateActionSheetLayout()
    }
    
    func updateActionSheetLayout() {
        updateActionSheetLayoutWithViewWidth(view.frame.width, view.frame.height)
    }
    
    func updateActionSheetLayoutWithViewWidth(_ viewWidth: CGFloat, _ viewHeight: CGFloat) {
        let actionSheetViewMaxWidth = config.modelMaxWidthBlock!(orientationType, CGSize(width: viewWidth, height: viewHeight))
        let actionSheetViewMaxHeight = config.modelMaxHeightBlock!(orientationType, CGSize(width: viewWidth, height: viewHeight))
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let cancelActionTotalHeight = actionSheetCancelAction != nil ? actionSheetCancelAction.actionHeight + config.modelActionSheetCancelActionSpaceWidth : 0.0
        
        var contentViewFrame = contentView.frame
        contentViewFrame.size.width = actionSheetViewMaxWidth
        
        if config.modelIsActionFollowScrollEnabled {
            let itemsHeight = updateItemsLayoutWithMaxWidth(actionSheetViewMaxWidth)
            contentViewFrame.size.height = itemsHeight > actionSheetViewMaxHeight - cancelActionTotalHeight ? actionSheetViewMaxHeight - cancelActionTotalHeight : itemsHeight
            
            itemsScrollView.frame = contentViewFrame
            itemsScrollView.contentSize = CGSize(width: actionSheetViewMaxWidth, height: itemsHeight)
            actionsScrollView.frame = CGRect(x: 0, y: contentViewFrame.size.height, width: actionSheetViewMaxWidth, height: 0)
            actionsScrollView.contentSize = CGSize.zero
        } else {
            var itemsHeight = updateItemsLayoutWithMaxWidth(actionSheetViewMaxWidth)
            var actionsHeight = updateActionsLayoutWithInitialPosition(0, maxWidth: actionSheetViewMaxWidth)
            
            itemsScrollView.contentSize = CGSize(width: actionSheetViewMaxWidth, height: itemsHeight)
            actionsScrollView.contentSize = CGSize(width: actionSheetViewMaxWidth, height: actionsHeight)
            
            let availableHeight = actionSheetViewMaxHeight - cancelActionTotalHeight
            
            if (itemsHeight + actionsHeight) > availableHeight {
                contentViewFrame.size.height = availableHeight
                let maxActionsHeight = availableHeight * 0.5
                actionsHeight = actionsHeight < maxActionsHeight ? actionsHeight : maxActionsHeight
                let maxItemsHeight = availableHeight - actionsHeight
                itemsHeight = itemsHeight < maxItemsHeight ? itemsHeight : maxItemsHeight
                actionsHeight = availableHeight - itemsHeight
                
                itemsScrollView.frame = CGRect(x: 0, y: 0, width: actionSheetViewMaxWidth, height: itemsHeight)
                actionsScrollView.frame = CGRect(x: 0, y: itemsHeight, width: actionSheetViewMaxWidth, height: actionsHeight)
            } else {
                contentViewFrame.size.height = itemsHeight + actionsHeight
                itemsScrollView.frame = CGRect(x: 0, y: 0, width: actionSheetViewMaxWidth, height: itemsHeight)
                actionsScrollView.frame = CGRect(x: 0, y: itemsHeight, width: actionSheetViewMaxWidth, height: actionsHeight)
            }
        }
        
        contentView.frame = contentViewFrame
        
        if let actionSheetCancelAction = actionSheetCancelAction {
            var spaceFrame = actionSheetCancelActionSpaceView.frame
            spaceFrame.origin.x = contentViewFrame.origin.x
            spaceFrame.origin.y = contentViewFrame.origin.y + contentViewFrame.size.height
            spaceFrame.size.width = actionSheetViewMaxWidth
            spaceFrame.size.height = config.modelActionSheetCancelActionSpaceWidth
            actionSheetCancelActionSpaceView.frame = spaceFrame
            
            var buttonFrame = actionSheetCancelAction.frame
            buttonFrame.origin.x = contentViewFrame.origin.x
            buttonFrame.origin.y = contentViewFrame.origin.y + contentViewFrame.size.height + spaceFrame.size.height
            buttonFrame.size.width = actionSheetViewMaxWidth
            actionSheetCancelAction.frame = buttonFrame
        }
        
        CATransaction.commit()
        
        var containerFrame = containerView.frame
        containerFrame.size.width = actionSheetViewMaxWidth
        containerFrame.size.height = contentViewFrame.size.height + cancelActionTotalHeight + viewSafeAreaInsets(view).bottom + config.modelActionSheetBottomMargin
        containerFrame.origin.x = (viewWidth - actionSheetViewMaxWidth) * 0.5
        
        if isShowed {
            containerFrame.origin.y = viewHeight - containerFrame.size.height
        } else {
            containerFrame.origin.y = viewHeight
        }
        
        containerView.frame = containerFrame
    }
    
    func updateItemsLayoutWithMaxWidth(_ maxWidth: CGFloat) -> CGFloat {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        var finalHeight: CGFloat = 0.0
        
        actionSheetItemArray.enumerated().forEach { index, item in
            if index == 0 {
                finalHeight += config.modelHeaderInsets.top
            }
            if let view = item as? UIView {
                var viewItem: FEEItem!
                if let view = view as? FEEItemLabel {
                    viewItem = view.item
                }
                if let view = view as? FEEItemTextField {
                    viewItem = view.item
                }
                var viewFrame = view.frame
                let safeAreaInsets = viewSafeAreaInsets(view)
                viewFrame.origin.x = config.modelHeaderInsets.left + viewItem.insets.left + safeAreaInsets.left
                viewFrame.origin.y = finalHeight + viewItem.insets.top
                viewFrame.size.width = maxWidth - viewFrame.origin.x - config.modelHeaderInsets.right - viewItem.insets.right - safeAreaInsets.left - safeAreaInsets.right
                
                if let label = item as? UILabel {
                    viewFrame.size.height = label.sizeThatFits(CGSize(width: viewFrame.size.width, height: CGFloat(MAXFLOAT))).height
                }
                
                view.frame = viewFrame
                finalHeight += view.frame.size.height + viewItem.insets.top + viewItem.insets.bottom
            } else if let custom = item as? FEECustomView {
                var viewFrame = custom.container.frame
                
                if custom.isAutoWidth {
                    custom.positionType = .center
                    viewFrame.size.width = maxWidth - config.modelHeaderInsets.left - custom.item.insets.left - config.modelHeaderInsets.right - custom.item.insets.right
                }
                
                switch custom.positionType {
                case .center:
                    viewFrame.origin.x = (maxWidth - viewFrame.size.width) * 0.5
                case .left:
                    viewFrame.origin.x = config.modelHeaderInsets.left + custom.item.insets.left
                case .right:
                    viewFrame.origin.x = maxWidth - config.modelHeaderInsets.right - custom.item.insets.right - viewFrame.size.width
                }
                
                viewFrame.origin.y = finalHeight + custom.item.insets.top
                custom.container.frame = viewFrame
                finalHeight += viewFrame.size.height + custom.item.insets.top + custom.item.insets.bottom
            }
            
            if item as! NSObject == actionSheetItemArray.last as! NSObject {
                finalHeight += config.modelHeaderInsets.bottom
            }
        }
        
        if config.modelIsActionFollowScrollEnabled {
            finalHeight += updateActionsLayoutWithInitialPosition(finalHeight, maxWidth: maxWidth)
        }
        
        CATransaction.commit()
        
        return finalHeight
    }
    
    func updateActionsLayoutWithInitialPosition(_ initialPosition: CGFloat, maxWidth: CGFloat) -> CGFloat {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        var finalHeight = initialPosition
        
        for button in actionSheetActionArray {
            var buttonFrame = button.frame
            buttonFrame.origin.x = button.action.insets.left
            buttonFrame.origin.y = finalHeight + button.action.insets.top
            buttonFrame.size.width = maxWidth - button.action.insets.left - button.action.insets.right
            button.frame = buttonFrame
            finalHeight += buttonFrame.size.height + button.action.insets.top + button.action.insets.bottom
        }
        
        CATransaction.commit()
        
        return finalHeight - initialPosition
    }
    
    func configActionSheet() {
        let shadowView = UIView()
        shadowView.frame = view.bounds
        shadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowOffset = config.modelShadowOffset
        shadowView.layer.shadowRadius = config.modelShadowRadius
        shadowView.layer.shadowOpacity = Float(config.modelShadowOpacity)
        shadowView.layer.shadowColor = config.modelShadowColor.cgColor
        view.addSubview(shadowView)
        
        shadowView.addSubview(containerView)
        
        contentView.addSubview(itemsScrollView)
        contentView.addSubview(actionsScrollView)
        containerView.addSubview(contentView)
        
        contentView.backgroundColor = config.modelHeaderColor
        containerView.backgroundColor = config.modelActionSheetBackgroundColor
        containerView.feeAlertCornerRadii = config.modelCornerRadii
        contentView.feeAlertCornerRadii = config.modelActionSheetHeaderCornerRadii
        itemsScrollView.isScrollEnabled = config.modelIsScrollEnabled
        itemsScrollView.showsVerticalScrollIndicator = config.modelIsShowsScrollIndicator
        actionsScrollView.isScrollEnabled = config.modelIsScrollEnabled
        actionsScrollView.showsVerticalScrollIndicator = config.modelIsShowsScrollIndicator
        
        config.modelItemArray.enumerated().forEach { index, itemBlock in
            let item = FEEItem()
            itemBlock(item)
            
            if let insetValue = config.modelItemInsetsInfo[index] {
                item.insets = insetValue.uiEdgeInsetsValue
            }
            
            switch item.type {
            case .title:
                let label = FEEItemLabel.label()
                itemsScrollView.addSubview(label)
                actionSheetItemArray.append(label)
                label.textAlignment = .center
                label.font = UIFont.boldSystemFont(ofSize: 16.0)
                if #available(iOS 13.0, *) {
                    label.textColor = .secondaryLabel
                } else {
                    label.textColor = .darkGray
                }
                label.numberOfLines = 0
                item.block?(label)
                label.item = item
                label.textChangedBlock = { [weak self] in
                    self?.updateActionSheetLayout()
                }
                
            case .content:
                let label = FEEItemLabel.label()
                itemsScrollView.addSubview(label)
                actionSheetItemArray.append(label)
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 14.0)
                if #available(iOS 13.0, *) {
                    label.textColor = .tertiaryLabel
                } else {
                    label.textColor = .gray
                }
                label.numberOfLines = 0
                item.block?(label)
                label.item = item
                label.textChangedBlock = { [weak self] in
                    self?.updateActionSheetLayout()
                }
                
            case .customView:
                let custom = FEECustomView()
                item.block?(custom)
                itemsScrollView.addSubview(custom.container)
                actionSheetItemArray.append(custom)
                custom.item = item
                custom.sizeChangedBlock = { [weak self] in
                    self?.updateActionSheetLayout()
                }
            default:
                break
            }
        }
        
        // 根据 modelIsActionFollowScrollEnabled 属性控制Action添加到哪个父视图
        let actionContainerView = config.modelIsActionFollowScrollEnabled ? itemsScrollView : actionsScrollView
        
        for (index, block) in config.modelActionArray.enumerated() {
            let action = FEEAction()
            block(action)
            
            if action.font == nil {
                action.font = UIFont.systemFont(ofSize: 18.0)
            }
            
            if action.title == nil {
                action.title = "按钮"
            }
            
            if action.titleColor == nil {
                if #available(iOS 13.0, *) {
                    action.titleColor = UIColor.systemBlue
                } else {
                    action.titleColor = UIColor(red: 21/255.0, green: 123/255.0, blue: 245/255.0, alpha: 1.0)
                }
            }
            
            if action.backgroundColor == nil {
                action.backgroundColor = config.modelHeaderColor
            }
            
            if action.backgroundHighlightColor == nil {
                if #available(iOS 13.0, *) {
                    action.backgroundHighlightColor = UIColor.systemGray6
                } else {
                    action.backgroundHighlightColor = UIColor(white: 0.97, alpha: 1.0)
                }
            }
            
            if action.borderColor == nil {
                if #available(iOS 13.0, *) {
                    action.borderColor = UIColor.systemGray3
                } else {
                    action.borderColor = UIColor(white: 0.84, alpha: 1.0)
                }
            }
            
            if action.borderWidth == 0 {
                action.borderWidth = defaultBorderWidth
            }
            
            if action.height == 0 {
                action.height = 57.0
            }
            
            let button = FEEActionButton.button()
            switch action.type {
            case .cancel:
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                button.feeAlertCornerRadii = config.modelActionSheetCancelActionCornerRadii
                button.backgroundColor = action.backgroundColor
                containerView.addSubview(button)
                actionSheetCancelAction = button
                
                actionSheetCancelActionSpaceView = UIView()
                actionSheetCancelActionSpaceView.backgroundColor = config.modelActionSheetCancelActionSpaceColor
                containerView.addSubview(actionSheetCancelActionSpaceView)
                
            default:
                if action.borderPosition == nil {
                    action.borderPosition = .top
                }
                
                button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                actionContainerView.addSubview(button)
                actionSheetActionArray.append(button)
            }
            
            button.action = action
            
            button.heightChangedBlock = { [weak self] in
                self?.updateActionSheetLayout()
            }
            
            if index == config.modelActionArray.count - 1 {
                updateActionSheetLayout()
                showAnimations(completionBlock: { [weak self] in
                    self?.updateActionSheetLayout()
                })
            }
        }
    }
    
    @objc func buttonAction(_ sender: FEEActionButton) {
        var isClose = false
        var index = 0
        var clickBlock: (() -> Void)? = nil
        
        switch sender.action.type {
        case .default:
            isClose = sender.action.isClickNotClose ? false : true
            index = actionSheetActionArray.firstIndex(of: sender) ?? 0
            
        case .cancel:
            isClose = true
            index = actionSheetActionArray.count
            
        case .destructive:
            isClose = true
            index = actionSheetActionArray.firstIndex(of: sender) ?? 0
        }
        
        clickBlock = sender.action.clickBlock
        
        if isClose {
            if let shouldActionClickClose = config.modelShouldActionClickClose, shouldActionClickClose(index) {
                closeAnimations(completionBlock: {
                    clickBlock?()
                })
            } else {
                clickBlock?()
            }
        } else {
            clickBlock?()
        }
    }
    
    @objc func headerTapAction(_ tap: UITapGestureRecognizer) {
        if config.modelIsClickHeaderClose {
            closeAnimations(completionBlock: nil)
        }
    }
    
    override func showAnimations(completionBlock: (() -> Void)?) {
        super.showAnimations(completionBlock: completionBlock)
        
        if isShowing { return }
        
        isShowing = true
        isShowed = true
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
        var containerFrame = self.containerView.frame
        
        if config.modelOpenAnimationStyle.contains(.orientationNone) {
            containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
            containerFrame.origin.y = (viewHeight - containerFrame.size.height) - config.modelActionSheetBottomMargin
        } else if config.modelOpenAnimationStyle.contains(.orientationTop) {
            containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
            containerFrame.origin.y = 0 - containerFrame.size.height
        } else if config.modelOpenAnimationStyle.contains(.orientationBottom) {
            containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
            containerFrame.origin.y = viewHeight
        } else if config.modelOpenAnimationStyle.contains(.orientationLeft) {
            containerFrame.origin.x = 0 - containerFrame.size.width
            containerFrame.origin.y = (viewHeight - containerFrame.size.height) - config.modelActionSheetBottomMargin
        } else if config.modelOpenAnimationStyle.contains(.orientationRight) {
            containerFrame.origin.x = viewWidth
            containerFrame.origin.y = (viewHeight - containerFrame.size.height) - config.modelActionSheetBottomMargin
        }
        
        self.containerView.frame = containerFrame
        
        if config.modelOpenAnimationStyle.contains(.fade) {
            self.containerView.alpha = 0.0
        }
        
        if config.modelOpenAnimationStyle.contains(.zoomEnlarge) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }
        
        if config.modelOpenAnimationStyle.contains(.zoomShrink) {
            self.containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
                
        if let animationConfigBlock = config.modelOpenAnimationConfigBlock {
            animationConfigBlock({ [weak self] in
                guard let self = self else { return }
                
                switch self.config.modelBackgroundStyle {
                case .blur:
                    self.backgroundVisualEffectView.effect = UIBlurEffect(style: self.config.modelBackgroundBlurEffectStyle)
                case .translucent:
                    self.view.backgroundColor = self.config.modelBackgroundColor.withAlphaComponent(self.config.modelBackgroundStyleColorAlpha)
                }
                
                var containerFrame = self.containerView.frame
                containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
                containerFrame.origin.y = viewHeight - containerFrame.size.height
                self.containerView.frame = containerFrame
                
                self.containerView.alpha = 1.0
                self.containerView.transform = .identity
            }, { [weak self] in
                guard let self = self else { return }
                
                self.isShowing = false
                self.view.isUserInteractionEnabled = true
                
                self.openFinishBlock?()
                completionBlock?()
            })
        }
    }
    
    override func closeAnimations(completionBlock: (() -> Void)?) {
        super.closeAnimations(completionBlock: completionBlock)
        
        if isClosing { return }
        if let modelShouldClose = config.modelShouldClose,
           !modelShouldClose() {
            return
        }
        
        isClosing = true
        isShowed = false
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
        if let animationConfigBlock = config.modelCloseAnimationConfigBlock {
            animationConfigBlock({ [weak self] in
                guard let self = self else { return }
                
                switch self.config.modelBackgroundStyle {
                case .blur:
                    self.backgroundVisualEffectView.alpha = 0.0
                case .translucent:
                    self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0.0)
                }
                
                var containerFrame = self.containerView.frame
                
                if self.config.modelCloseAnimationStyle.contains(.orientationNone) {
                    // no-op
                } else if self.config.modelCloseAnimationStyle.contains(.orientationTop) {
                    containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
                    containerFrame.origin.y = 0 - containerFrame.size.height
                } else if self.config.modelCloseAnimationStyle.contains(.orientationBottom) {
                    containerFrame.origin.x = (viewWidth - containerFrame.size.width) * 0.5
                    containerFrame.origin.y = viewHeight
                } else if self.config.modelCloseAnimationStyle.contains(.orientationLeft) {
                    containerFrame.origin.x = 0 - containerFrame.size.width
                } else if self.config.modelCloseAnimationStyle.contains(.orientationRight) {
                    containerFrame.origin.x = viewWidth
                }
                
                self.containerView.frame = containerFrame
                
                if self.config.modelCloseAnimationStyle.contains(.fade) {
                    self.containerView.alpha = 0.0
                }
                
                if self.config.modelCloseAnimationStyle.contains(.zoomEnlarge) {
                    self.containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
                
                if self.config.modelCloseAnimationStyle.contains(.zoomShrink) {
                    self.containerView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                }
            }, { [weak self] in
                guard let self = self else { return }
                
                self.isClosing = false
                self.closeFinishBlock?()
                completionBlock?()
            })
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == itemsScrollView
    }
}


class FEEActionButton: UIButton {
    
    var action: FEEAction! {
        didSet {
            guard let action = action else { return }
            self.clipsToBounds = true
            if let title = action.title {
                self.setTitle(title, for: .normal)
            }
            
            if let highlight = action.highlight {
                self.setTitle(highlight, for: .highlighted)
            }
            
            if let attributedTitle = action.attributedTitle {
                self.setAttributedTitle(attributedTitle, for: .normal)
            }
            
            if let attributedHighlight = action.attributedHighlight {
                self.setAttributedTitle(attributedHighlight, for: .highlighted)
            }
            
            self.titleLabel?.numberOfLines = action.numberOfLines
            self.titleLabel?.textAlignment = action.textAlignment
            self.contentEdgeInsets = action.contentEdgeInsets
            self.contentVerticalAlignment = action.contentVerticalAlignment
            self.contentHorizontalAlignment = action.contentHorizontalAlignment
            
            if let font = action.font {
                self.titleLabel?.font = font
            }
            
            self.titleLabel?.adjustsFontSizeToFitWidth = action.adjustsFontSizeToFitWidth
            self.titleLabel?.lineBreakMode = action.lineBreakMode
            
            if let titleColor = action.titleColor {
                setTitleColor(titleColor, for: .normal)
            }
            
            if let highlightColor = action.highlightColor {
                setTitleColor(highlightColor, for: .highlighted)
            }
            
            if let backgroundColor = action.backgroundColor {
                setBackgroundImage(self.getImageWithColor(backgroundColor), for: .normal)
            }
            
            if let backgroundHighlightColor = action.backgroundHighlightColor {
                setBackgroundImage(self.getImageWithColor(backgroundHighlightColor), for: .highlighted)
            }
            
            if let backgroundImage = action.backgroundImage {
                setBackgroundImage(backgroundImage, for: .normal)
            }
            
            if let backgroundHighlightImage = action.backgroundHighlightImage {
                setBackgroundImage(backgroundHighlightImage, for: .highlighted)
            }
            
            if let borderColor = action.borderColor {
                self.borderColor = borderColor
            }
            
            if action.borderWidth > 0 {
                borderWidth = action.borderWidth < defaultBorderWidth ? defaultBorderWidth : action.borderWidth
            } else {
                borderWidth = 0
            }
            
            if let image = action.image {
                setImage(image, for: .normal)
            }
            
            if let highlightImage = action.highlightImage {
                setImage(highlightImage, for: .highlighted)
            }
            
            actionHeight = action.height
            
            layer.cornerRadius = action.cornerRadius
            
            imageEdgeInsets = action.imageEdgeInsets
            titleEdgeInsets = action.titleEdgeInsets
            
            if let borderPosition = action.borderPosition {
                if borderPosition.contains(.top) &&
                    borderPosition.contains(.bottom) &&
                    borderPosition.contains(.left) &&
                    borderPosition.contains(.right) {
                    
                    self.layer.borderWidth = action.borderWidth
                    self.layer.borderColor = action.borderColor?.cgColor
                    
                    self.removeTopBorder()
                    self.removeBottomBorder()
                    self.removeLeftBorder()
                    self.removeRightBorder()
                    
                } else {
                    
                    self.layer.borderWidth = 0.0
                    self.layer.borderColor = UIColor.clear.cgColor
                    
                    if borderPosition.contains(.top) { self.addTopBorder() } else { self.removeTopBorder() }
                    if borderPosition.contains(.bottom) { self.addBottomBorder() } else { self.removeBottomBorder() }
                    if borderPosition.contains(.left) { self.addLeftBorder() } else { self.removeLeftBorder() }
                    if borderPosition.contains(.right) { self.addRightBorder() } else { self.removeRightBorder() }
                }
            }
            
            self.action?.updateBlock = { [weak self] act in
                if let weakSelf = self {
                    weakSelf.action = act
                }
            }
        }
    }
    var heightChangedBlock: (() -> Void)?
    
    private var borderColor: UIColor?
    private var borderWidth: CGFloat = 0.0
    private var _topLayer: CALayer?
    private var topLayer: CALayer? {
        get {
            if _topLayer == nil {
                _topLayer = createLayer()
            }
            return _topLayer
        }
        set {
            _topLayer = newValue
        }
    }
    private var _bottomLayer: CALayer?
    private var bottomLayer: CALayer? {
        get {
            if _bottomLayer == nil {
                _bottomLayer = createLayer()
            }
            return _bottomLayer
        }
        set {
            _bottomLayer = newValue
        }
    }
    private var _leftLayer: CALayer?
    private var leftLayer: CALayer? {
        get {
            if _leftLayer == nil {
                _leftLayer = createLayer()
            }
            return _leftLayer
        }
        set {
            _leftLayer = newValue
        }
    }
    private var _rightLayer: CALayer?
    private var rightLayer: CALayer? {
        get {
            if _rightLayer == nil {
                _rightLayer = createLayer()
            }
            return _rightLayer
        }
        set {
            _rightLayer = newValue
        }
    }
    var feeAlertCornerRadii: CornerRadii = .null

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // 刷新Action设置
        if let action = action {
            self.action = action
        }
    }
    
    class func button() -> FEEActionButton {
        return FEEActionButton(type: .custom)
    }
    
    var actionHeight: CGFloat {
        get {
            return frame.size.height
        }
        set {
            let isChange = actionHeight == newValue ? false : true
            frame.size.height = newValue
            if isChange {
                heightChangedBlock?()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topLayer?.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        bottomLayer?.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        leftLayer?.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        rightLayer?.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        updateCornerRadii()
    }
    
    func addTopBorder() {
        removeTopBorder()
        if let topLayer = topLayer {
            self.layer.addSublayer(topLayer)
        }
    }
    
    func addBottomBorder() {
        removeBottomBorder()
        if let bottomLayer = bottomLayer {
            self.layer.addSublayer(bottomLayer)
        }
    }
    
    func addLeftBorder() {
        removeLeftBorder()
        if let leftLayer = leftLayer {
            self.layer.addSublayer(leftLayer)
        }
    }
    
    func addRightBorder() {
        removeRightBorder()
        if let rightLayer = rightLayer {
            self.layer.addSublayer(rightLayer)
        }
    }
    
    func removeTopBorder() {
        topLayer?.removeFromSuperlayer()
        topLayer = nil
    }
    
    func removeBottomBorder() {
        bottomLayer?.removeFromSuperlayer()
        bottomLayer = nil
    }
    
    func removeLeftBorder() {
        leftLayer?.removeFromSuperlayer()
        leftLayer = nil
    }
    
    func removeRightBorder() {
        rightLayer?.removeFromSuperlayer()
        rightLayer = nil
    }
    
    private func createLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = self.borderColor?.cgColor
        return layer
    }
    
    private func getImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    private func updateCornerRadii() {
        guard !CornerRadii.cornerRadiiEqualTo(feeAlertCornerRadii, CornerRadii.null) else {
            return
        }
        let lastLayer: CAShapeLayer = (layer.mask as? CAShapeLayer) ?? CAShapeLayer()
        let lastPath = lastLayer.path?.copy()
        let path = FEEView.FEECGPathCreateWithRoundedRect(bounds: bounds, cornerRadii: feeAlertCornerRadii)

        // 防止相同路径多次设置
        if lastPath != path {
            // 移除原有路径动画
            lastLayer.removeAnimation(forKey: "path")
            // 重置新路径mask
            let maskLayer = CAShapeLayer()
            maskLayer.path = path
            layer.mask = maskLayer
            // 同步视图大小变更动画
            if let temp = layer.animation(forKey: "bounds.size") {
                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = temp.duration
                animation.fillMode = temp.fillMode
                animation.timingFunction = temp.timingFunction
                animation.fromValue = lastPath
                animation.toValue = path
                maskLayer.add(animation, forKey: "path")
            }
        }
    }
}

class FEEItemView: UIView {
    var item: FEEItem!
}

class FEEItemLabel: UILabel {
    
    var item: FEEItem!
    var textChangedBlock: (() -> Void)?

    class func label() -> FEEItemLabel {
        return FEEItemLabel()
    }

    override var text: String? {
        didSet {
            super.text = text
            textChangedBlock?()
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            super.attributedText = attributedText
            textChangedBlock?()
        }
    }

    override var font: UIFont? {
        didSet {
            super.font = font
            textChangedBlock?()
        }
    }

    override var numberOfLines: Int {
        didSet {
            super.numberOfLines = numberOfLines
            textChangedBlock?()
        }
    }
}

class FEEItemTextField: UITextField {

    var item: FEEItem!

    class func textField() -> FEEItemTextField {
        return FEEItemTextField()
    }
}

class FEEView: UIView {
    var feeAlertCornerRadii: CornerRadii = .null
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadii()
    }
    
    func updateCornerRadii() {
        guard !CornerRadii.cornerRadiiEqualTo(feeAlertCornerRadii, CornerRadii.null) else {
            return
        }
        let lastLayer: CAShapeLayer = (layer.mask as? CAShapeLayer) ?? CAShapeLayer()
        let lastPath = lastLayer.path?.copy()
        let path = FEEView.FEECGPathCreateWithRoundedRect(bounds: bounds, cornerRadii: feeAlertCornerRadii)

        // 防止相同路径多次设置
        if lastPath != path {
            // 移除原有路径动画
            lastLayer.removeAnimation(forKey: "path")
            // 重置新路径mask
            let maskLayer = CAShapeLayer()
            maskLayer.path = path
            layer.mask = maskLayer
            // 同步视图大小变更动画
            if let temp = layer.animation(forKey: "bounds.size") {
                let animation = CABasicAnimation(keyPath: "path")
                animation.duration = temp.duration
                animation.fillMode = temp.fillMode
                animation.timingFunction = temp.timingFunction
                animation.fromValue = lastPath
                animation.toValue = path
                maskLayer.add(animation, forKey: "path")
            }
        }
    }

    class func FEECGPathCreateWithRoundedRect(bounds: CGRect, cornerRadii: CornerRadii) -> CGPath {
        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY
        
        let topLeftCenterX = minX + cornerRadii.topLeft
        let topLeftCenterY = minY + cornerRadii.topLeft
        
        let topRightCenterX = maxX - cornerRadii.topRight
        let topRightCenterY = minY + cornerRadii.topRight
        
        let bottomLeftCenterX = minX + cornerRadii.bottomLeft
        let bottomLeftCenterY = maxY - cornerRadii.bottomLeft
        
        let bottomRightCenterX = maxX - cornerRadii.bottomRight
        let bottomRightCenterY = maxY - cornerRadii.bottomRight
        
        let path = CGMutablePath()
        
        // 顶 左
        path.addArc(center: CGPoint(x: topLeftCenterX, y: topLeftCenterY), radius: cornerRadii.topLeft, startAngle: CGFloat.pi, endAngle: 3 * CGFloat.pi / 2, clockwise: false)
        // 顶 右
        path.addArc(center: CGPoint(x: topRightCenterX, y: topRightCenterY), radius: cornerRadii.topRight, startAngle: 3 * CGFloat.pi / 2, endAngle: 0, clockwise: false)
        // 底 右
        path.addArc(center: CGPoint(x: bottomRightCenterX, y: bottomRightCenterY), radius: cornerRadii.bottomRight, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: false)
        // 底 左
        path.addArc(center: CGPoint(x: bottomLeftCenterX, y: bottomLeftCenterY), radius: cornerRadii.bottomLeft, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
}


