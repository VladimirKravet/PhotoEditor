//
//  PhotoEditorApp.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 09.09.2024.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        //    Auth.auth().useEmulator(withHost:"localhost", port:9099)
        return true
    }
}

@main
struct PhotoEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var drawingViewModel = DrawingViewModel()
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    AuthenticatedView(viewModelForDrawing: drawingViewModel){
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 100 , height: 100)
                            .foregroundColor(Color(.systemTeal))
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                            .padding(4)
                        Text("Welcome to Photo Editor!")
                            .font(.title)
                        Text("You need to be logged in to use this app.")
                    } content:  {
                        DrawingView(viewModel: drawingViewModel)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
