//
//  ContentView.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/01.

import SwiftUI

struct ContentView: View {
    @State private var todos: [TodoItem] = []
    @State private var showingAddTodo = false
    @State private var showingDeleteAlert = false
    @State private var editingTodo: TodoItem?
    private let userDefaults = UserDefaultsManager.shared
    @State var listRowText = ""
    
    //カメラ関連
    @State private var showingCamera = false
    @State private var isProcessing = false//現在は不使用。画像からテキストを認識するまでに時間がかかりそうであれば使用
    @State private var capturedImage: UIImage?
    @State private var recognizedTexts: [String] = []
    private let textRecognizer = TextRecognizer()
    @State private var showingEmptyEditAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                cameraRowView
                List {
                    Section {
                        ForEach(todos) { todo in
                            HStack {
                                // MARK: チェックマーク
                                Button(action: {
                                    toggleTodo(todo)
                                    editingTodo = nil
                                }) {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todo.isCompleted ? .green : .gray)
                                        .frame(width: 50)
                                        .frame(maxHeight: .infinity)
                                }
                                // MARK: テキスト部分
                                if editingTodo?.id == todo.id {
                                    if !todo.isCompleted {
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
                                            .strikethrough(true)
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity,
                                                   alignment: .leading
                                           )
                                            .frame(maxHeight: .infinity)
                                    }
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
                //MARK: 削除ボタン
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
            .alert("Todoを記入してください", isPresented: $showingEmptyEditAlert) {
                Button("OK", role: .cancel) {}
            }
            .sheet(isPresented: $showingAddTodo) {
                TodoFormView(todoText: "") { text in
                    addTodo(text: text)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(image: $capturedImage, sourceType: .camera)
                    .ignoresSafeArea()
                    .onDisappear {
                        recognizeTextFromImage()
                    }
            }
            .onAppear {
                if !userDefaults.loadTodos().isEmpty {
                    todos = userDefaults.loadTodos()
                }
            }
        }
    }
    
    private var cameraRowView: some View {
        Button(action: {
            showingCamera = true
        }, label: {
            Label("撮影して項目を追加", systemImage: "camera")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        })
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

extension ContentView {
    
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
        let trimmedTitle = listRowText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            showingEmptyEditAlert = true
            return
        }
        todos[index].title = trimmedTitle
        userDefaults.saveTodos(todos)
        editingTodo = nil
        listRowText = ""
    }

    private func deleteAllTodos() {
        todos.removeAll()
        userDefaults.deleteTodos()
    }
    
    private func recognizeTextFromImage() {
        isProcessing = true
        recognizedTexts = []
        guard let image = capturedImage else { return print("💫画像の取得に失敗") }
        textRecognizer.recognizeText(from: image) { texts in
            DispatchQueue.main.async {
                for text in texts {
                    let newTodo = TodoItem(title: text)
                    todos.append(newTodo)
                }
            }
            userDefaults.saveTodos(todos)
        }
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
