//
//  TextRecognizer.swift
//  ScanToDo
//
//  Created by sako0602 on 2025/10/01.
//

import Vision
import UIKit

class TextRecognizer {
    func recognizeText(from image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion([])
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }

            let recognizedTexts = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            completion(recognizedTexts)
        }

        request.recognitionLanguages = ["ja-JP", "en-US"]
        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion([])
            }
        }
    }
}
