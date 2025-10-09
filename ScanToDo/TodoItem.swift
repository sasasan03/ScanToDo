//
//  TodoItem.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/01.
//

import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
}
