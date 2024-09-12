//
//  AuthenticatedView.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 09.09.2024.
//

import SwiftUI

extension AuthenticatedView where Unauthenticated == EmptyView {
    init(viewModelForDrawing: DrawingViewModel, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.viewModelForDrawing = viewModelForDrawing
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @ObservedObject var viewModelForDrawing: DrawingViewModel
    
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false
    
    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content
    
    public init(viewModelForDrawing: DrawingViewModel, unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
        self.viewModelForDrawing = viewModelForDrawing
        self.unauthenticated = unauthenticated
        self.content = content
    }
    
    public init(viewModelForDrawing: DrawingViewModel, @ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
        self.viewModelForDrawing = viewModelForDrawing
        self.unauthenticated = unauthenticated()
        self.content = content
    }
    
    public init(viewModelForDrawing: DrawingViewModel, @ViewBuilder content: @escaping () -> Content) {
        self.viewModelForDrawing = viewModelForDrawing
        self.unauthenticated = nil
        self.content = content
    }
    
    
    var body: some View {
        switch viewModel.authenticationState {
        case .unauthenticated, .authenticating:
            VStack {
                if let unauthenticated {
                    unauthenticated
                }
                else {
                    Text("You're not logged in.")
                }
                Button("Tap here to log in") {
                    viewModel.reset()
                    presentingLoginScreen.toggle()
                }
            }
            .sheet(isPresented: $presentingLoginScreen) {
                AuthenticationView()
                    .environmentObject(viewModel)
            }
        case .authenticated:
            VStack {
                content()
                if !viewModelForDrawing.isImageChoosen {
                    Text("You're logged in as \(viewModel.displayName).")
                    Button("Tap here to view your profile") {
                        presentingProfileScreen.toggle()
                    }
                }
            }
            .sheet(isPresented: $presentingProfileScreen) {
                if #available(iOS 16.0, *) {
                    NavigationStack {
                        UserProfileView()
                            .environmentObject(viewModel)
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}
