//
//  SignFinishView.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class SignFinishView: UIView {
    
    // 关闭回调闭包
    var closeBlock: (() -> Void)?

    // 图片
    private var imageView: UIImageView!
    
    // 分数
    private var scoreLabel: UILabel!
    
    // 天数
    private var daysLabel: UILabel!
    
    // 描述
    private var descLabel: UILabel!
    
    // 打开按钮
    private var openButton: UIButton!
    
    // 关闭按钮
    private var closeButton: UIButton!

    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 初始化数据
        initData()
        
        // 初始化子视图
        initSubview()
        
        // 设置自动布局
        configAutoLayout()
    }
    
    // 初始化方法（通过 Interface Builder 加载）
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // 初始化数据
    private func initData() {
        // 这里可以初始化一些数据
    }
    
    // 初始化子视图
    private func initSubview() {
        // 图片
        imageView = UIImageView(image: UIImage(named: "signbg"))
        addSubview(imageView)
        
        // 分数
        scoreLabel = UILabel()
        scoreLabel.text = "+5"
        scoreLabel.textColor = UIColor.white
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 28.0)
        imageView.addSubview(scoreLabel)
        
        // 天数
        daysLabel = UILabel()
        daysLabel.text = "已成功签到1天"
        daysLabel.textColor = UIColor.white
        daysLabel.font = UIFont.systemFont(ofSize: 14.0)
        daysLabel.textAlignment = .center
        imageView.addSubview(daysLabel)
        
        // 描述
        descLabel = UILabel()
        descLabel.text = "积分可用于竞猜并参与抽奖"
        descLabel.textColor = UIColor.black
        descLabel.font = UIFont.systemFont(ofSize: 16.0)
        descLabel.textAlignment = .center
        imageView.addSubview(descLabel)
        
        // 设置按钮
        openButton = UIButton(type: .custom)
        openButton.layer.cornerRadius = 5.0
        openButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        openButton.setTitle("去竞猜", for: .normal)
        openButton.setTitleColor(UIColor.white, for: .normal)
        openButton.backgroundColor = UIColor(red: 34/255.0, green: 129/255.0, blue: 239/255.0, alpha: 1.0)
        openButton.addTarget(self, action: #selector(openButtonAction(_:)), for: .touchUpInside)
        addSubview(openButton)
        
        // 关闭按钮
        closeButton = UIButton(type: .custom)
        closeButton.isHighlighted = false
        closeButton.layer.cornerRadius = 15.0 // 使用比例会失效，手动设置
        closeButton.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        closeButton.setImage(UIImage(named: "infor_colse_image"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        addSubview(closeButton)
    }
    
    // 设置自动布局
    private func configAutoLayout() {
        // 图片
        imageView.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.left.right.equalTo(self)
            make.height.equalTo(imageView.snp.width).multipliedBy(1.07)
        }
        
        // 分数
        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(60)
            make.right.equalTo(imageView).offset(-80)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        // 天数
        daysLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(145)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        // 描述
        descLabel.snp.makeConstraints { make in
            make.bottom.equalTo(imageView).offset(-25)
            make.left.equalTo(imageView).offset(20)
            make.right.equalTo(imageView).offset(-20)
            make.height.equalTo(30)
        }
        
        // 打开按钮
        openButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(40)
        }
        
        // 关闭按钮
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(-10)
            make.width.height.equalTo(30)
        }
        
        snp.makeConstraints { make in
            make.bottom.equalTo(openButton).offset(20)
            make.width.equalTo(bounds.width)
        }
    }
    
    // 打开按钮点击事件
    @objc private func openButtonAction(_ sender: UIButton) {
        FEEAlert.close {
            // 打开XXX
        }
    }
    
    // 关闭按钮点击事件
    @objc private func closeButtonAction(_ sender: UIButton) {
        closeBlock?()
    }
}
