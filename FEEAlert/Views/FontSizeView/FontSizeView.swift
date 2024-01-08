//
//  FontSizeView.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/8.
//

import UIKit

class FontSizeView: UIView {
    var changeBlock: ((Int) -> Void)?

    private var decreaseButton: UIButton!
    private var slider: UISlider!
    private var increaseButton: UIButton!
    private let promptInfoArray = ["小", "中", "大", "特大", "巨大"]
    private var promptLabelArray = [UILabel]()
    private var currentIndex = 1

    // MARK: - Initialization

    deinit {
        decreaseButton = nil
        slider = nil
        increaseButton = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initData()
        initSubview()
        configAutoLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Private Methods

    private func initData() {
        backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0)
        currentIndex = 1
    }

    private func initSubview() {
        decreaseButton = UIButton(type: .custom)
        decreaseButton.setImage(UIImage(named: "infor_poptypebar_wordsmall"), for: .normal)
        decreaseButton.addTarget(self, action: #selector(decreaseButtonAction(_:)), for: .touchUpInside)
        addSubview(decreaseButton)

        slider = UISlider()
        slider.setThumbImage(UIImage(named: "infor_poptypebar_slider"), for: .normal)
        slider.maximumTrackTintColor = UIColor.clear
        slider.minimumTrackTintColor = UIColor.clear
        slider.minimumValue = 0
        slider.maximumValue = Float(promptInfoArray.count - 1)
        slider.setValue(Float(currentIndex), animated: false)
        slider.addTarget(self, action: #selector(sliderChangeAction(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderAction(_:)), for: [.touchUpInside, .touchUpOutside])
        addSubview(slider)

        increaseButton = UIButton(type: .custom)
        increaseButton.setImage(UIImage(named: "infor_poptypebar_wordbig"), for: .normal)
        increaseButton.addTarget(self, action: #selector(increaseButtonAction(_:)), for: .touchUpInside)
        addSubview(increaseButton)

        promptInfoArray.enumerated().forEach { (index, title) in
            let label = UILabel()
            label.textColor = UIColor.gray
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.text = title
            label.textAlignment = .center
            label.alpha = currentIndex == index ? 1.0 : 0.0
            addSubview(label)
            promptLabelArray.append(label)
        }
    }

    private func configAutoLayout() {
        frame.size.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        frame.size.height = 140.0

        decreaseButton.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(60)
            make.width.height.equalTo(40)
        }
        
        increaseButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.width.height.equalTo(decreaseButton)
        }
        
        slider.snp.makeConstraints { make in
            make.centerY.equalTo(decreaseButton)
            make.left.equalTo(decreaseButton.snp.right).offset(5)
            make.right.equalTo(increaseButton.snp.left).offset(-5)
            make.height.equalTo(20)
        }

        layoutIfNeeded()

        let lineWith = slider.bounds.width - 22
        let rootPath = UIBezierPath()
        rootPath.move(to: CGPoint(x: 0, y: 0))
        rootPath.addLine(to: CGPoint(x: 0, y: 6))
        rootPath.addLine(to: CGPoint(x: lineWith, y: 6))
        rootPath.addLine(to: CGPoint(x: lineWith, y: 0))

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 11, y: 4, width: lineWith, height: 6)
        shapeLayer.path = rootPath.cgPath
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        slider.layer.insertSublayer(shapeLayer, at: 0)

        let offset = lineWith / CGFloat(promptInfoArray.count - 1)

        var i = 1
        while offset * CGFloat(i) != lineWith {
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: offset * CGFloat(i), y: 0))
            linePath.addLine(to: CGPoint(x: offset * CGFloat(i), y: 6))

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.gray.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.insertSublayer(lineLayer, at: 0)

            i += 1
        }
        
        promptLabelArray.enumerated().forEach { (index, label) in
            let centerX = 6 + offset * CGFloat(index)
            
            label.snp.makeConstraints { make in
                make.bottom.equalTo(slider.snp.top).offset(-5)
                make.centerX.equalTo(slider.snp.left).offset(centerX)
                make.width.equalTo(30)
                make.height.equalTo(20)
            }
        }
    }

    // MARK: - Actions

    @objc private func decreaseButtonAction(_ sender: UIButton) {
        slider.value -= 1
        sliderChangeAction(slider)
        configFontSize()
    }

    @objc private func increaseButtonAction(_ sender: UIButton) {
        slider.value += 1
        sliderChangeAction(slider)
        configFontSize()
    }

    @objc private func sliderAction(_ slider: UISlider) {
        slider.setValue(Float(numberFormat(CGFloat(slider.value))!)!, animated: true)
        configFontSize()
    }

    @objc private func sliderChangeAction(_ slider: UISlider) {
        promptLabelArray[currentIndex].alpha = 0.0
        currentIndex = Int(numberFormat(CGFloat(slider.value))!)!
        promptLabelArray[currentIndex].alpha = 1.0
    }

    private func configFontSize() {
        let sliderValue = Int(slider.value)
        changeBlock?(sliderValue)
    }

    private func numberFormat(_ num: CGFloat) -> String? {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "0"
        return formatter.string(from: NSNumber(value: Float(num)))
    }
}
