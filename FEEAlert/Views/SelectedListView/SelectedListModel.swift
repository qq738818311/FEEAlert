//
//  SelectedListModel.swift
//  FEEAlert
//
//  Created by Fee on 2024/1/5.
//

import Foundation

class SelectedListModel: NSObject {
    var sid: Int
    var title: String
    var context: [String: Any]?

    init(sid: Int, title: String) {
        self.sid = sid
        self.title = title
        self.context = nil
        super.init()
    }

    init(sid: Int, title: String, context: [String: Any]?) {
        self.sid = sid
        self.title = title
        self.context = context
        super.init()
    }
}
