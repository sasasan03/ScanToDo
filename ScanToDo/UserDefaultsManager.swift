//
//  UserDefaultsManager.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/02.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let todosKey = "todos"
    private let userDefaults = UserDefaults.standard

    private init() {}

    // Todoリストを保存
    func saveTodos(_ todos: [TodoItem]) {
        if let encoded = try? JSONEncoder().encode(todos) {
            userDefaults.set(encoded, forKey: todosKey)
        }
    }

    // Todoリストを読み込み
    func loadTodos() -> [TodoItem] {
        guard let data = userDefaults.data(forKey: todosKey),
              let todos = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            return []
        }
        return todos
    }

    // Todoリストを削除
    func deleteTodos() {
        userDefaults.removeObject(forKey: todosKey)
    }
}
