//
//  ContentView.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/01.
//

import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoItem] = []
    @State private var newTodoTitle = ""
    @State private var showingAddTodo = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(todos) { todo in
                        HStack {
                            Button(action: {
                                toggleTodo(todo)
                            }) {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .green : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Text(todo.title)
                                .strikethrough(todo.isCompleted)
                                .foregroundColor(todo.isCompleted ? .gray : .primary)

                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteTodos)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Todo List")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: CameraView(todos: $todos)) {
                        Image(systemName: "camera")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                NavigationView {
                    VStack {
                        TextField("新しいTodo", text: $newTodoTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        Spacer()
                    }
                    .navigationTitle("Todoを追加")
                    .navigationBarItems(
                        leading: Button("キャンセル") {
                            newTodoTitle = ""
                            showingAddTodo = false
                        },
                        trailing: Button("追加") {
                            addTodo()
                        }
                        .disabled(newTodoTitle.isEmpty)
                    )
                }
            }
        }
    }

    private func addTodo() {
        let newTodo = TodoItem(title: newTodoTitle)
        todos.append(newTodo)
        newTodoTitle = ""
        showingAddTodo = false
    }

    private func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }

    private func deleteTodos(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
