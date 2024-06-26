//
//  Task.swift
//  TaskApp
//
//  Created by 中村 行汰 on 2024/04/15.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @Persisted(primaryKey: true) var id: ObjectId

    // タイトル
    @Persisted var title = ""

    // 内容
    @Persisted var contents = ""

    // 日時
    @Persisted var date = Date()
    
    //カテゴリ名
    @Persisted var category: Category?

}

class Category: Object {
    // ID
    @Persisted(primaryKey: true) var id: ObjectId
    //カテゴリ名
    @Persisted var categoryName = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
