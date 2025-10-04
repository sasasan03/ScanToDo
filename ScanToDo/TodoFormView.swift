//
//  TodoFormView.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/03.
//

import SwiftUI

struct TodoFormView: View {

    @State private var todoText: String = ""
    @Environment(\.dismiss) var dismiss
    let saveText: (String) -> Void
    let initialTodoText: String

    var todoTextPlaceholder: String {
        todoText.isEmpty ? "Todoを記入してください" : todoText
    }
    
    var navigationTilteText: String {
        todoText.isEmpty ? "Todoを追加" : "Todoを編集"
    }
    
    var hasChange: Bool {
        initialTodoText == todoText
    }
    
    init(todoText: String, saveText: @escaping (String) -> Void) {
        _todoText = State(initialValue: todoText) 
        self.initialTodoText = todoText
        self.saveText = saveText
    }
    
    var body: some View {
        VStack {
            ZStack {
                Text(navigationTilteText)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Button("キャンセル") {
                        dismiss()
                    }
                    Spacer()
                    Button("完了") {
                        saveText(todoText)
                        dismiss()
                    }
                    .disabled(hasChange)
                }
                .padding()
            }
            TextField(todoTextPlaceholder, text: $todoText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Spacer()
        }
    }
}

#Preview {
    TodoFormView(todoText: "", saveText: { _ in })
}
