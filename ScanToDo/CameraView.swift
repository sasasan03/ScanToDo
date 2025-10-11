//
//  CameraView.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/01.
//

import SwiftUI

struct CameraView: View {
    @Binding var todos: [TodoItem]
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var recognizedTexts: [String] = []
    @State private var isProcessing = false
    @State private var cameraUnavailableAlert = false

    private let textRecognizer = TextRecognizer()
    private let userDefaults = UserDefaultsManager.shared

    var body: some View {
        VStack(spacing: 20) {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .cornerRadius(10)
                    .padding()
            } else {
                Image(systemName: "camera.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
                    .padding()
            }

            Button(action: {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showingCamera = true
                } else {
                    cameraUnavailableAlert = true
                }
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text("カメラを起動")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
            }

            if capturedImage != nil {
                if isProcessing {
                    ProgressView("テキストを認識中...")
                        .padding()
                } else if !recognizedTexts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("認識されたテキスト:")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(recognizedTexts, id: \.self) { text in
                                    Text("• \(text)")
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .frame(maxHeight: 200)

                        Button(action: {
                            addRecognizedTextsToTodos()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Todoリストに追加")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }

                Button(action: {
                    capturedImage = nil
                    recognizedTexts = []
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("画像を削除")
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

            Spacer()
        }
        .navigationTitle("カメラ")
        .fullScreenCover(isPresented: $showingCamera) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                recognizeTextFromImage(image)
            }
        }
        .alert("カメラが利用できません", isPresented: $cameraUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("このデバイスではカメラを使用できません。")
        }
    }

    private func recognizeTextFromImage(_ image: UIImage) {
        isProcessing = true
        recognizedTexts = []

        textRecognizer.recognizeText(from: image) { texts in
            DispatchQueue.main.async {
                self.recognizedTexts = texts
                self.isProcessing = false
            }
        }
    }

    private func addRecognizedTextsToTodos() {
        for text in recognizedTexts {
            let newTodo = TodoItem(title: text)
            todos.append(newTodo)
        }
        userDefaults.saveTodos(todos)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    NavigationView {
        CameraView(todos: .constant([]))
    }
}
