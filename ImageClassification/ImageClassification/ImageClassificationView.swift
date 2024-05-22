//
//  ImageClassificationView.swift
//  ImageClassification
//
//  Created by Jason Sanchez on 5/22/24.
//

import SwiftUI
import CoreML

struct ImageClassificationView: View {
    
    let images = ["cat_1", "cat_2", "cat_3", "cat_4", "cat_5", "dog_1", "dog_2", "dog_3", "dog_4", "dog_5"]
    @State private var currentIndex = 0
    @State private var probs: [String: Double] = [: ]
    
    let model = try! CatsvsDogsImageClassifier(configuration: MLModelConfiguration())
    var sortedProbs: [Dictionary<String, Double>.Element] {
        let probsArray = Array(probs)
        return probsArray.sorted { lhs, rhs in
            lhs.value > rhs.value
    }
    
    var body: some View {
        VStack {
            Image(images[currentIndex])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            HStack {
                Button("Previous") {
                    currentIndex -= 1
                }.buttonStyle(.bordered)
                    .disabled(currentIndex == 0)
                
                Button("Next") {
                    currentIndex += 1
                }.buttonStyle(.bordered)
                    .disabled(currentIndex == images.count - 1)
            }
            Button("Predict") {
                guard let uiImage = UIImage(named: images[currentIndex]) else { return }
                // resize the image
                let resizedImage = uiImage.resize(to: CGSize(width: 224, height: 224))
                guard let buffer = resizedImage.toCVPixelBuffer() else { return }
                
                do {
                    let prediction = try model.prediction(image: buffer)
                    probs = prediction.classLabelProbs
                    print(prediction.classLabel)
                } catch {
                    print(error.localizedDescription)
                }
            }.buttonStyle(.borderedProminent)
            
            ProbabilityListView(probs: sortedProbs)
        }
        .padding()
    }
}

#Preview {
    ImageClassificationView()
}
