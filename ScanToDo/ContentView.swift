//
//  ContentView.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/01.
//

import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoItem] = []
    @State private var showingAddTodo = false
    @State private var showingDeleteAlert = false
    @State private var editingTodo: TodoItem?
    private let userDefaults = UserDefaultsManager.shared
    @State var listRowText = ""

    var body: some View {
        NavigationStack {
            VStack {
                cameraRowView
                List {
                    Section {
                        ForEach(todos) { todo in
                            HStack {
                                Button(action: {
                                    toggleTodo(todo)
                                    editingTodo = nil
                                }) {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todo.isCompleted ? .green : .gray)
                                        .frame(width: 50)
                                        .frame(maxHeight: .infinity)
                                }
                                if editingTodo?.id == todo.id {
                                    TextField("Todoを記入してください", text: $listRowText)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            saveEdit()
                                        }
                                    Button("編集終了") {
                                        saveEdit()
                                    }
                                    .buttonStyle(.borderedProminent)
                                } else {
                                    Text(todo.title)
                                        .strikethrough(todo.isCompleted)
                                        .foregroundColor(todo.isCompleted ? .gray : .primary)
                                        .frame(maxWidth: .infinity,
                                               alignment: .leading
                                       )
                                        .frame(maxHeight: .infinity)
                                        .onTapGesture {
                                            startEditing(todo)
                                        }
                                }
                                Spacer()
                            }
                        }
                        .onDelete(perform: deleteTodos)
                    }
                }
                .listStyle(PlainListStyle())
                if !todos.isEmpty {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("すべて削除")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("メモ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddTodo = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("すべてのTodoを削除", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("削除", role: .destructive) {
                    deleteAllTodos()
                }
            } message: {
                Text("すべてのTodoを削除してもよろしいですか？")
            }
            .sheet(isPresented: $showingAddTodo) {
                TodoFormView(todoText: "") { text in
                    addTodo(text: text)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                if !userDefaults.loadTodos().isEmpty {
                    todos = userDefaults.loadTodos()
                }
            }
        }
    }
    
    private var cameraRowView: some View {
        NavigationLink(destination: CameraView(todos: $todos)) {
            Label("撮影して項目を追加", systemImage: "camera")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func addTodo(text: String) {
        let newTodo = TodoItem(title: text)
        todos.append(newTodo)
        userDefaults.saveTodos(todos)
        showingAddTodo = false
    }

    private func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
            userDefaults.saveTodos(todos)
        }
    }

    private func deleteTodos(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
        userDefaults.saveTodos(todos)
    }

    private func startEditing(_ todo: TodoItem) {
        editingTodo = todo
        listRowText = todo.title
    }

    private func saveEdit() {
        guard let todo = editingTodo,
              let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].title = listRowText
        userDefaults.saveTodos(todos)
        editingTodo = nil
        listRowText = ""
    }

    private func deleteAllTodos() {
        todos.removeAll()
        userDefaults.deleteTodos()
    }
}

#Preview {
    ContentView()
}

//@State private var todos: [TodoItem] = [TodoItem(title: "牛乳を買う", isCompleted: false, createdAt: Date()),
//                                        TodoItem(title: "メールを返信する", isCompleted: true, createdAt: Date().addingTimeInterval(-3600)),
//                                        TodoItem(title: "ランニングする", isCompleted: false, createdAt: Date().addingTimeInterval(-86400)),
//                                        TodoItem(title: "Swiftの勉強をする", isCompleted: false, createdAt: Date().addingTimeInterval(-172800)),
//                                        TodoItem(title: "アプリのUIを改善する", isCompleted: true, createdAt: Date().addingTimeInterval(-259200))
//                                    ]

