//
//  AllShareView.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/8.
//

import UIKit

enum MoreType: Int {
    case toTheme = 0
    case toReport
    case toFontSize
    case toCopyLink
}

class AllShareView: UIView {
    
    var openShareBlock: ((ShareType) -> Void)?
    var openMoreBlock: ((MoreType) -> Void)?

    private var backGroundView: UIView!
    private var shareScrollView: UIScrollView!
    private var shareContentView: UIView!
    private var moreScrollView: UIScrollView?
    private var moreContentView: UIView?
    private var lineView: UIView?
    private var shareInfoArray: [[String: Any]]!
    private var moreInfoArray: [[String: Any]]?
    private var shareButtonArray: [ShareButton]!
    private var moreButtonArray: [ShareButton]?
    
    private var isShowMore: Bool = false
    private var isShowReport: Bool = false
    
    deinit {
        backGroundView = nil
        shareScrollView = nil
        moreScrollView = nil
        lineView = nil
        shareInfoArray = nil
        moreInfoArray = nil
        shareButtonArray = nil
        moreButtonArray = nil
    }

    convenience init(frame: CGRect, showMore: Bool) {
        self.init(frame: frame, showMore: showMore, showReport: false)
    }

    convenience init(frame: CGRect, showMore: Bool, showReport: Bool) {
        self.init(frame: frame)
        isShowMore = showMore
        isShowReport = showReport
        initData()
        initSubview()
        configAutoLayout()
    }

    private func initData() {
        shareButtonArray = []
        moreButtonArray = []

        var tempShareInfoArray: [[String: Any]] = []

        // if (判断是否安装微信) {
        tempShareInfoArray.append(["title": "朋友圈", "image": "infor_popshare_friends_nor", "highlightedImage": "infor_popshare_friends_pre", "type": ShareType.toWechatTimeline.rawValue])
        tempShareInfoArray.append(["title": "微信", "image": "infor_popshare_weixin_nor", "highlightedImage": "infor_popshare_weixin_pre", "type": ShareType.toWechat.rawValue])
        // }

        // if (判断是否安装QQ) {
        tempShareInfoArray.append(["title": "QQ好友", "image": "infor_popshare_qq_nor", "highlightedImage": "infor_popshare_qq_pre", "type": ShareType.toQQFriend.rawValue])
        tempShareInfoArray.append(["title": "新浪微博", "image": "infor_popshare_sina_nor", "highlightedImage": "infor_popshare_sina_pre", "type": ShareType.toSina.rawValue])
        tempShareInfoArray.append(["title": "QQ空间", "image": "infor_popshare_kunjian_nor", "highlightedImage": "infor_popshare_kunjian_pre", "type": ShareType.toQZone.rawValue])
        // }

        tempShareInfoArray.append(["title": "新浪微博", "image": "infor_popshare_sina_nor", "highlightedImage": "infor_popshare_sina_pre", "type": ShareType.toSina.rawValue])

        shareInfoArray = tempShareInfoArray

        var tempMoreInfoArray: [[String: Any]] = []

//        tempMoreInfoArray.append(/* DISABLES CODE */ (1) == 1 ?
//            ["title": "夜间模式", "image": "infor_popshare_light_nor", "highlightedImage": "infor_popshare_light_pre", "type": MoreType.toTheme.rawValue] :
//            ["title": "日间模式", "image": "infor_popshare_day_nor", "highlightedImage": "infor_popshare_day_pre", "type": MoreType.toTheme.rawValue])
        tempMoreInfoArray.append(["title": "夜间模式", "image": "infor_popshare_light_nor", "highlightedImage": "infor_popshare_light_pre", "type": MoreType.toTheme.rawValue])

        if isShowReport {
            tempMoreInfoArray.append(["title": "举报", "image": "infor_popshare_report_nor", "highlightedImage": "infor_popshare_report_pre", "type": MoreType.toReport.rawValue])
        }

        tempMoreInfoArray.append(["title": "字体设置", "image": "infor_popshare_wordsize_nor", "highlightedImage": "infor_popshare_wordsize_pre", "type": MoreType.toFontSize.rawValue])
        tempMoreInfoArray.append(["title": "复制链接", "image": "infor_popshare_copylink_nor", "highlightedImage": "infor_popshare_copylink_pre", "type": MoreType.toCopyLink.rawValue])

        moreInfoArray = tempMoreInfoArray
    }

    private func initSubview() {
        backGroundView = UIView()
        backGroundView.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0)
        addSubview(backGroundView)

        shareScrollView = UIScrollView()
        shareScrollView.backgroundColor = UIColor.clear
        shareScrollView.bounces = true
        shareScrollView.showsVerticalScrollIndicator = false
        shareScrollView.showsHorizontalScrollIndicator = false
        backGroundView.addSubview(shareScrollView)
        
        shareContentView = UIView()
        shareScrollView.addSubview(shareContentView)

        for info in shareInfoArray {
            let button = ShareButton(type: .custom)
            button.configTitle(title: info["title"] as? String, image: UIImage(named: info["image"] as? String ?? ""))
            button.setImage(UIImage(named: info["highlightedImage"] as? String ?? ""), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(shareButtonAction(_:)), for: .touchUpInside)
            shareContentView.addSubview(button)
            shareButtonArray.append(button)
        }

        if isShowMore {
            lineView = UIView()
            lineView?.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            backGroundView.addSubview(lineView!)

            moreScrollView = UIScrollView()
            moreScrollView?.backgroundColor = UIColor.clear
            moreScrollView?.bounces = true
            moreScrollView?.showsVerticalScrollIndicator = false
            moreScrollView?.showsHorizontalScrollIndicator = false
            backGroundView.addSubview(moreScrollView!)
            
            moreContentView = UIView()
            moreScrollView?.addSubview(moreContentView!)

            if let moreInfoArray = moreInfoArray {
                for info in moreInfoArray {
                    let button = ShareButton(type: .custom)
                    button.configTitle(title: info["title"] as? String, image: UIImage(named: info["image"] as? String ?? ""))
                    button.setImage(UIImage(named: info["highlightedImage"] as? String ?? ""), for: .highlighted)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
                    button.setTitleColor(UIColor.black, for: .normal)
                    button.addTarget(self, action: #selector(moreButtonAction(_:)), for: .touchUpInside)
                    moreContentView?.addSubview(button)
                    moreButtonArray?.append(button)
                }
            }
        }
    }

    private func configAutoLayout() {
        let height: CGFloat = 140
        let buttonMargin: CGFloat = 20

        backGroundView.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }

        shareScrollView.snp.makeConstraints { make in
            make.top.equalTo(backGroundView).offset(20)
            make.centerX.width.equalTo(backGroundView)
            make.height.equalTo(100)
        }
        
        shareContentView.snp.makeConstraints { make in
            make.edges.height.equalTo(shareScrollView)
        }

        for (index, button) in shareButtonArray.enumerated() {
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(shareContentView)
                if index == 0 {
                    make.left.equalTo(shareContentView).offset(20)
                } else {
                    make.left.equalTo(shareButtonArray[index - 1].snp.right).offset(buttonMargin)
                }
                make.width.equalTo(60.0)
                if index == shareButtonArray.count - 1 {
                    make.right.equalTo(shareContentView).offset(-20)
                }
            }
        }

        if isShowMore {
            lineView?.snp.makeConstraints { make in
                make.top.equalTo(shareScrollView.snp.bottom).offset(10)
                make.left.equalTo(backGroundView).offset(30)
                make.right.equalTo(backGroundView).offset(-30)
                make.height.equalTo(0.5)
            }

            moreScrollView?.snp.makeConstraints { make in
                make.top.equalTo(lineView!.snp.bottom).offset(10)
                make.centerX.width.equalTo(backGroundView)
                make.height.equalTo(100)
            }
            
            moreContentView?.snp.makeConstraints { make in
                make.edges.height.equalTo(moreScrollView!)
            }

            if let moreButtonArray = moreButtonArray {
                for (index, button) in moreButtonArray.enumerated() {
                    button.snp.makeConstraints { make in
                        make.top.bottom.equalTo(moreContentView!)
                        if index == 0 {
                            make.left.equalTo(moreContentView!).offset(20)
                        } else {
                            make.left.equalTo(moreButtonArray[index - 1].snp.right).offset(buttonMargin)
                        }
                        make.width.equalTo(60.0)
                        if index == moreButtonArray.count - 1 {
                            make.right.equalTo(moreContentView!).offset(-20)
                        }
                    }
                }

                backGroundView.snp.makeConstraints { make in
                    make.bottom.equalTo(moreScrollView!.snp.bottom).offset(20)
                }

                let height: CGFloat = 260
                snp.makeConstraints { make in
                    make.height.equalTo(height)
                    make.width.equalTo(bounds.width)
                }
            } else {
                backGroundView.snp.makeConstraints { make in
                    make.bottom.equalTo(shareScrollView.snp.bottom).offset(20)
                }

                let height: CGFloat = 140
                self.snp.makeConstraints { make in
                    make.height.equalTo(height)
                }
            }
        } else {
            backGroundView.snp.makeConstraints { make in
                make.bottom.equalTo(shareScrollView.snp.bottom).offset(20)
            }

            self.snp.makeConstraints { make in
                make.height.equalTo(height)
            }
        }
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()

        shareScrollView.snp.updateConstraints { make in
            make.top.equalTo(backGroundView).offset(20 + safeAreaInsets.top)
        }

        if isShowMore {
            moreScrollView?.snp.updateConstraints { make in
                make.top.equalTo(lineView!.snp.bottom).offset(10 + safeAreaInsets.top)
            }
        }
    }

    @objc private func shareButtonAction(_ sender: ShareButton) {
        FEEAlert.close { [weak self] in
            guard let self = self else { return }

            if let index = self.shareButtonArray.firstIndex(of: sender) {
                let type = ShareType(rawValue: (self.shareInfoArray[index]["type"] as? Int) ?? 0) ?? .toWechat
                if let openShareBlock = self.openShareBlock {
                    openShareBlock(type)
                }
            }
        }
    }

    @objc private func moreButtonAction(_ sender: ShareButton) {
        FEEAlert.close { [weak self] in
            guard let self = self else { return }

            if let index = self.moreButtonArray?.firstIndex(of: sender) {
                let type = MoreType(rawValue: (self.moreInfoArray?[index]["type"] as? Int) ?? 0) ?? .toTheme
                if let openMoreBlock = self.openMoreBlock {
                    openMoreBlock(type)
                }
            }
        }
    }

    func show() {
        FEEAlert.actionsheet.config
            .feeCustomView { custom in
                custom.view = self
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
            .feeCornerRadius(0.0)
            .feeConfigMaxWidth { _, _ in
                // 这是最大宽度为屏幕宽度 (横屏和竖屏)
                return UIScreen.main.bounds.width
            }
            .feeShow()
    }
}
