//
//  ShareButton.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

// 分享类型枚举
enum ShareType: Int {
    case toQQFriend = 0    // 分享到QQ好友
    case toQZone           // 分享到QQ空间
    case toWechat          // 分享到微信好友
    case toWechatTimeline  // 分享到微信朋友圈
    case toSina            // 分享到新浪微博
}

class ShareButton: UIButton {
    
    // 上下间距
    var range: CGFloat = 10.0
    
    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // 初始化方法（通过 Interface Builder 加载）
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // 共用的初始化方法
    private func commonInit() {
        range = 10.0
        self.titleLabel?.textAlignment = .center
    }
    
    // 重写布局方法
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 居中图片
        var center = self.imageView?.center ?? CGPoint.zero
        center.x = self.frame.size.width / 2
        center.y = (self.imageView?.frame.size.height ?? 0) / 2
        self.imageView?.center = center
        
        // 调整位置
        var imageFrame = self.imageView?.frame ?? CGRect.zero
        imageFrame.origin.y = (self.frame.size.height - imageFrame.size.height - (self.titleLabel?.frame.size.height ?? 0) - range) / 2
        self.imageView?.frame = imageFrame
        
        // 调整标题
        var titleFrame = self.titleLabel?.frame ?? CGRect.zero
        titleFrame.origin.x = 0
        titleFrame.origin.y = imageFrame.origin.y + imageFrame.size.height + range
        titleFrame.size.width = self.frame.size.width
        self.titleLabel?.frame = titleFrame
        self.titleLabel?.textAlignment = .center
    }
    
    // 配置标题和图标
    func configTitle(title: String?, image: UIImage?) {
        self.setTitle(title, for: .normal)
        self.setImage(image, for: .normal)
    }
}
