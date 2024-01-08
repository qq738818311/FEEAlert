//
//  ShareView.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class ShareView: UIView, UIScrollViewDelegate {

    var openShareBlock: ((ShareType) -> Void)?
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var pageControl: UIPageControl!
    private var infoArray: [[String: Any]]!
    private var buttonArray: [ShareButton]!
    private var pageViewArray: [UIView]!
    
    private var lineMaxNumber: Int!
    private var singleMaxCount: Int!
    
    convenience init(frame: CGRect, infoArray: [[String: Any]]?, maxLineNumber: Int, maxSingleCount: Int) {
        self.init(frame: frame)
        self.infoArray = infoArray
        self.buttonArray = []
        self.pageViewArray = []
        self.lineMaxNumber = maxLineNumber > 0 ? maxLineNumber : 2
        self.singleMaxCount = maxSingleCount > 0 ? maxSingleCount : 3
        
        // 初始化数据
        initData()
        
        // 初始化子视图
        initSubview()
        
        // 设置自动布局
        configAutoLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        scrollView = nil
        pageControl = nil
        infoArray = nil
        buttonArray = nil
        pageViewArray = nil
    }
    
    // MARK: - 初始化数据
    
    private func initData() {
        // 非空判断 设置默认数据
        if infoArray == nil {
            infoArray = [
                ["title": "微信", "image": "infor_popshare_weixin_nor", "highlightedImage": "infor_popshare_weixin_pre", "type": ShareType.toWechat.rawValue],
                ["title": "微信朋友圈", "image": "infor_popshare_friends_nor", "highlightedImage": "infor_popshare_friends_pre", "type": ShareType.toWechatTimeline.rawValue],
                // 多复制几个用来演示分页
                ["title": "新浪微博", "image": "infor_popshare_sina_nor", "highlightedImage": "infor_popshare_sina_pre", "type": ShareType.toSina.rawValue],
                ["title": "QQ好友", "image": "infor_popshare_qq_nor", "highlightedImage": "infor_popshare_qq_pre", "type": ShareType.toQQFriend.rawValue],
                ["title": "QQ空间", "image": "infor_popshare_kunjian_nor", "highlightedImage": "infor_popshare_kunjian_pre", "type": ShareType.toQZone.rawValue],
                // 结束
                ["title": "新浪微博", "image": "infor_popshare_sina_nor", "highlightedImage": "infor_popshare_sina_pre", "type": ShareType.toSina.rawValue],
                ["title": "QQ好友", "image": "infor_popshare_qq_nor", "highlightedImage": "infor_popshare_qq_pre", "type": ShareType.toQQFriend.rawValue],
                ["title": "QQ空间", "image": "infor_popshare_kunjian_nor", "highlightedImage": "infor_popshare_kunjian_pre", "type": ShareType.toQZone.rawValue]
            ]
        }
        
        lineMaxNumber = lineMaxNumber > 0 ? lineMaxNumber : 2
        singleMaxCount = singleMaxCount > 0 ? singleMaxCount : 3
    }
    
    // MARK: - 初始化子视图
    
    private func initSubview() {
        // 初始化滑动视图
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = self
        scrollView.bounces = true
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        // 初始化pageControl
        pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = UIColor.gray
        addSubview(pageControl)
        
        // 循环初始化分享按钮
        var index = 0
        var pageView: UIView!
        
        for info in infoArray {
            // 判断是否需要分页
            if index % (lineMaxNumber * singleMaxCount) == 0 {
                // 初始化页视图
                pageView = UIView()
                contentView.addSubview(pageView)
                pageViewArray.append(pageView)
            }
            
            // 初始化按钮
            let button = ShareButton(type: .custom)
            button.configTitle(title: info["title"] as? String, image: UIImage(named: info["image"] as? String ?? ""))
            button.setImage(UIImage(named: info["highlightedImage"] as? String ?? ""), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(shareButtonAction(_:)), for: .touchUpInside)
            pageView?.addSubview(button)
            buttonArray.append(button)
            
            index += 1
        }
        
        // 设置总页数
        pageControl.numberOfPages = pageViewArray.count > 1 ? pageViewArray.count : 0
    }
    
    // MARK: - 设置自动布局
    
    private func configAutoLayout() {
        
        // 使用SDAutoLayout循环布局分享按钮
        let lineNumber = Int(ceil(Double(infoArray.count) / Double(singleMaxCount))) // 所需行数 小数向上取整
        let singleCount = Int(ceil(Double(infoArray.count) / Double(lineNumber))) // 单行个数 小数向上取整
        let adjustedSingleCount = singleCount >= infoArray.count ? singleCount : singleMaxCount // 处理单行个数
        
        let buttonWidth = bounds.width / CGFloat(adjustedSingleCount!)
        let buttonHeight: CGFloat = 100.0
        
        // 滑动视图
        scrollView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(bounds.width)
            make.height.equalTo(buttonHeight * 2)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.height.equalTo(scrollView)
        }
        
        var index = 0
        var currentPageCount = 0
        var pageView: UIView!
        
        var lastPageView: UIView?
        var lastButton: ShareButton?

        for button in buttonArray {
            // 判断是否分页
            if index % (lineMaxNumber * singleMaxCount) == 0 {
                pageView = pageViewArray[currentPageCount]
                // 布局页视图
                pageView.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.width.equalTo(bounds.width)
                    if currentPageCount == 0 {
                        make.left.equalToSuperview()
                    } else {
                        make.left.equalTo(lastPageView!.snp.right)
                    }
                    if currentPageCount == pageViewArray.count - 1 {
                        make.right.equalToSuperview()
                    }
                }
                lastPageView = pageView
                
                currentPageCount += 1
            }
            // 布局按钮
            button.snp.makeConstraints { make in
                make.width.equalTo(buttonWidth)
                make.height.equalTo(buttonHeight)
                if index % singleCount == 0 {
                    make.left.equalTo(pageView)
                } else {
                    make.left.equalTo(lastButton!.snp.right)
                }
                if (index / singleCount) % lineMaxNumber == 0 {
                    make.top.equalTo(pageView)
                } else {
                    if index % singleCount == 0 {
                        make.top.equalTo(lastButton!.snp.bottom)
                    } else {
                        make.top.equalTo(lastButton!)
                    }
                }
            }
            lastButton = button
            
            index += 1
        }
                
        // pageControl
        pageControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(scrollView.snp.bottom).offset(5.0)
            make.height.equalTo(10.0)
//            make.bottom.equalToSuperview().priority(.medium)
        }
        
        // 设置自身高度
        snp.makeConstraints { make in
            make.bottom.equalTo(pageControl.snp.bottom)
            make.width.equalTo(bounds.width)
        }
    }
    
    // MARK: - 分享按钮点击事件
    
    @objc private func shareButtonAction(_ sender: UIButton) {
        FEEAlert.close { [weak self] in
            guard let self = self else { return }
            
            if let index = self.buttonArray.firstIndex(of: sender as! ShareButton) {
                let type = ShareType(rawValue: (self.infoArray[index]["type"] as? Int) ?? 0) ?? .toWechat
                if let openShareBlock = self.openShareBlock {
                    openShareBlock(type)
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 通过最终的偏移量offset值 来确定pageControl当前应该显示第几页
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
}

