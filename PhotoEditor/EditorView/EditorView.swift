//
//  EditorView.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 09.09.2024.
//

import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift

class EditorViewModel: ObservableObject {
  @Published var favouriteNumber: Int = 42

  private var defaults = UserDefaults.standard
  private let favouriteNumberKey = "favouriteNumber"
  private var cancellables = Set<AnyCancellable>()

  init() {
    if let number = defaults.object(forKey: favouriteNumberKey) as? Int {
      favouriteNumber = number
    }
    $favouriteNumber
      .sink { number in
        self.defaults.set(number, forKey: self.favouriteNumberKey)
        Analytics.logEvent("stepper", parameters: ["value" : number])
      }
      .store(in: &cancellables)
  }
}

struct EditorView: View {
  @StateObject var viewModel = EditorViewModel()
  var body: some View {
    VStack {
      Text("What's your favourite number?")
        .font(.title)
        .multilineTextAlignment(.center)
      Spacer()
      Stepper(value: $viewModel.favouriteNumber, in: 0...100) {
        Text("\(viewModel.favouriteNumber)")
      }
    }
    .frame(maxHeight: 150)
    .foregroundColor(.white)
    .padding()
    #if os(iOS)
    .background(Color(UIColor.systemPink))
    #endif
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .shadow(radius: 8)
    .navigationTitle("Favourite Number")
  }
}
