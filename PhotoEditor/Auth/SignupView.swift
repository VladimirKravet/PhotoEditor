//
//  SignupView.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 09.09.2024.
//

import SwiftUI
import Combine
import FirebaseAnalyticsSwift

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

struct SignupView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss

  @FocusState private var focus: FocusableField?

  private func signUpWithEmailPassword() {
    Task {
      if await viewModel.signUpWithEmailPassword() == true {
        dismiss()
      }
    }
  }

  var body: some View {
    VStack {
      Image("SignUp")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(minHeight: 300, maxHeight: 400)
      Text("Sign up")
        .font(.largeTitle)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        Image(systemName: "at")
        TextField("Email", text: $viewModel.email)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .focused($focus, equals: .email)
          .submitLabel(.next)
          .onSubmit {
            self.focus = .password
          }
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 4)

      HStack {
        Image(systemName: "lock")
          TextField("Password", text: $viewModel.password)
          .focused($focus, equals: .password)
          .submitLabel(.next)
          .disableAutocorrection(true)
          .onSubmit {
            self.focus = .confirmPassword
          }
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      HStack {
        Image(systemName: "lock")
          TextField("Confirm password", text: $viewModel.confirmPassword)
          .focused($focus, equals: .confirmPassword)
          .disableAutocorrection(true)
          .submitLabel(.go)
          .onSubmit {
            signUpWithEmailPassword()
          }
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)


      if !viewModel.errorMessage.isEmpty {
        VStack {
          Text(viewModel.errorMessage)
            .foregroundColor(Color(UIColor.systemRed))
        }
      }

      Button(action: signUpWithEmailPassword) {
        if viewModel.authenticationState != .authenticating {
          Text("Sign up")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        else {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
      }
      .disabled(!viewModel.isValid)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)

      HStack {
        Text("Already have an account?")
        Button(action: { viewModel.switchFlow() }) {
          Text("Log in")
            .fontWeight(.semibold)
            .foregroundColor(.blue)
        }
      }
      .padding([.top, .bottom], 50)

    }
    .listStyle(.plain)
    .padding()
  }
}
