//
//  SelectedListView.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import UIKit

class SelectedListView: UITableView {
    
    // 已选中Block
    var selectedBlock: (([SelectedListModel]) -> Void)?
    
    // 选择改变Block (多选情况 当选择改变时调用)
    var changedBlock: (([SelectedListModel]) -> Void)?
    
    // 是否单选
    var isSingle: Bool = false
    
    // 数据数组
    var array: [SelectedListModel] = [] {
        didSet {
            reloadData()
            setEditing(!isSingle, animated: false)
            let height = CGFloat(array.count) * 50.0
            frame.size.height = height
        }
    }
    
    var dataArray: [SelectedListModel] = []

    // 初始化方法
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        // 初始化数据
        initData()
    }
    
    // 初始化方法（通过 Interface Builder 加载）
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // 初始化数据
    private func initData() {
        backgroundColor = UIColor.clear
        delegate = self
        dataSource = self
        bounces = false
        allowsMultipleSelectionDuringEditing = true // 支持同时选中多行
        separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        separatorColor = UIColor.gray.withAlphaComponent(0.2)
        register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // 完成选择 (多选会调用selectedBlock回调所选结果)
    func finish() {
        selectedBlock?(dataArray)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SelectedListView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let model = array[indexPath.row]
        cell.textLabel?.text = model.title
        cell.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = array[indexPath.row]
        dataArray.append(model)
        
        if isSingle {
            tableView.deselectRow(at: indexPath, animated: true)
            finish()
        } else {
            changedBlock?(dataArray)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let model = array[indexPath.row]
        
        if !isSingle {
            dataArray.removeAll { $0 === model }
            changedBlock?(dataArray)
        }
    }
}
