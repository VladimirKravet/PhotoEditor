//
//  DrawingView.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 10.09.2024.
//

import Foundation
import SwiftUI


struct DrawingView: View {
    @ObservedObject var viewModel: DrawingViewModel
    
    var body: some View {
        ZStack{
            NavigationView {
                VStack {
                    if let _ = UIImage(data: viewModel.imageData) {
                        if viewModel.isEditorSelected {
                            DrawingScreen()
                                .overlay(
                                    HStack {
                                        Button {
                                            viewModel.cancelImageEditing()
                                            viewModel.isImageChoosen = false
                                            viewModel.isEditorSelected = false
                                            viewModel.isFilterSelected = false
                                            viewModel.scale = 0
                                            viewModel.rotation = .zero
                                            viewModel.isDrawing = false
                                            viewModel.imageScale  = 1
                                            viewModel.imageOffset = .zero
                                        } label: {
                                            Image(systemName: "xmark")
                                        }
                                        Spacer()
                                        Text("Photo Editor")
                                            .font(.title)
                                        Spacer()
                                        Button(action: {
                                            viewModel.saveImage()
                                        }, label: {
                                            Text("Save")
                                        })
                                        Button(action: {
                                            viewModel.shareImage()
                                        }, label: {
                                            Image(systemName: "square.and.arrow.up")
                                        })
                                        
                                        Button(action: {
                                            viewModel.textBoxes.append(TextBox())
                                            viewModel.currentIndex = viewModel.textBoxes.count - 1
                                            viewModel.isImageChoosen = true
                                            viewModel.addNewBox.toggle()
                                            viewModel.toolPicker.setVisible(false, forFirstResponder: viewModel.canvas)
                                            viewModel.canvas.resignFirstResponder()
                                        }, label: {
                                            Image(systemName: "plus")
                                        })
                                    }
                                        .offset(y: -340)
                                        .padding()
                                )
                                .environmentObject(viewModel)
                        } else {
                            
                            FilterView()
                                .preferredColorScheme(.dark)
                                .environmentObject(viewModel)
                        }
                        
                        
                    } else {
                        MainViewContecst(viewModel: viewModel)
                    }
                }
                .onChange(of: viewModel.value, perform: { (_) in
                    viewModel.updateEffect()
                })
                .onChange(of: viewModel.imageData, perform: { (_) in
                    viewModel.allImages.removeAll()
                    viewModel.mainView = nil
                    viewModel.loadFilter()
                })
            }
            if viewModel.addNewBox {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                TextField("Type Here", text: $viewModel.textBoxes[viewModel.currentIndex].text)
                    .font(.system(size: 35, weight: viewModel.textBoxes[viewModel.currentIndex].isBold ? .bold : .regular))
                    .colorScheme(.dark)
                    .foregroundColor(viewModel.textBoxes[viewModel.currentIndex].textColor)
                    .padding()
                HStack {
                    Button {
                        viewModel.textBoxes[viewModel.currentIndex].isAdded = true
                        
                        viewModel.toolPicker.setVisible(true, forFirstResponder: viewModel.canvas)
                        viewModel.canvas.becomeFirstResponder()
                        viewModel.addNewBox = false
                    } label: {
                        Text("Add")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Button {
                            viewModel.cancelTextView()
                        } label: {
                            Text("Cancel")
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                    }
                }
                .overlay (
                    HStack(spacing: 15){
                        ColorPicker("", selection: $viewModel.textBoxes[viewModel.currentIndex].textColor)
                            .labelsHidden()
                        Button {
                            viewModel.textBoxes[viewModel.currentIndex].isBold.toggle()
                        } label: {
                            Text(viewModel.textBoxes[viewModel.currentIndex].isBold ? "Normal" : "Bold")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.white)
                        }
                        
                    }
                )
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .sheet(isPresented: $viewModel.showImagePicker, content : {
            ImagePicker(viewModel: viewModel, showPicker: $viewModel.showImagePicker, imageData: $viewModel.imageData)
        })
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Message"), message: Text(viewModel.message), dismissButton: .destructive(Text("OK")))
        }
    }
}


struct MainViewContecst: View {
    @ObservedObject var viewModel: DrawingViewModel
    var body: some View {
        VStack {
            Text("Photo Editor")
                .font(.title)
            Spacer()
            Button(action: {
                viewModel.isEditorSelected = true
                viewModel.isFilterSelected = false
                viewModel.showImagePicker.toggle()
                viewModel.isImageChoosen = true
            }, label: {
                VStack {
                    Image(systemName: "pencil.tip.crop.circle.badge.plus.fill")
                        .font(.title)
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.7), radius: 5, x: 5, y: 5)
                    Text("Tappe to edditng photo")
                        .fontWeight(.bold)
                }
            })
            Button {
                viewModel.showImagePicker.toggle()
                viewModel.isImageChoosen = true
                viewModel.isEditorSelected = false
            } label: {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.7), radius: 5, x: 5, y: 5)
                    Text("Pick An Image to Filter")
                        .fontWeight(.bold)
                }
                .padding(.top, 100)
            }
            Spacer()
        }
    }
}
