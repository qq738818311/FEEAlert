//
//  OpenPushView.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class OpenPushView: UIView {
    
    // 关闭回调闭包
    var closeBlock: (() -> Void)?

    // 图片
    private var imageView: UIImageView!
    
    // 标题
    private var titleLabel: UILabel!
    
    // 内容
    private var contentLabel: UILabel!
    
    // 设置按钮
    private var settingButton: UIButton!
    
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
        imageView = UIImageView(image: UIImage(named: "open_push_image"))
        addSubview(imageView)
        
        // 标题
        titleLabel = UILabel()
        titleLabel.text = "第一时间获知重大新闻"
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        // 内容
        contentLabel = UILabel()
        contentLabel.text = "及时获取"
        contentLabel.textColor = UIColor.gray
        contentLabel.font = UIFont.systemFont(ofSize: 16.0)
        contentLabel.textAlignment = .center
        addSubview(contentLabel)
        
        // 设置按钮
        settingButton = UIButton(type: .custom)
        settingButton.layer.cornerRadius = 5.0
        settingButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        settingButton.setTitle("去设置", for: .normal)
        settingButton.setTitleColor(UIColor.white, for: .normal)
        settingButton.backgroundColor = UIColor(red: 190/255.0, green: 40/255.0, blue: 44/255.0, alpha: 1.0)
        settingButton.addTarget(self, action: #selector(settingButtonAction(_:)), for: .touchUpInside)
        addSubview(settingButton)
        
        // 关闭按钮
        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "infor_colse_image"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        addSubview(closeButton)
    }
    
    // 设置自动布局
    private func configAutoLayout() {
        // 图片
        imageView.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(imageView.snp.width).multipliedBy(0.87)
        }
        
        // 标题
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        
        // 内容
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        
        // 设置按钮
        settingButton.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(40)
        }
        
        // 关闭按钮
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(-10)
            make.width.height.equalTo(30)
        }
        
        snp.makeConstraints { make in
            make.bottom.equalTo(settingButton).offset(20)
            make.width.equalTo(bounds.width)
        }
    }
    
    // 设置按钮点击事件
    @objc private func settingButtonAction(_ sender: UIButton) {
        FEEAlert.close {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    // 关闭按钮点击事件
    @objc private func closeButtonAction(_ sender: UIButton) {
        closeBlock?()
    }
}
