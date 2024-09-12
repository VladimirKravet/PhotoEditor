//
//  FilterView.swift
//  PhotoEditor
//
//  Created by Vladimir Kravets on 11.09.2024.
//

import SwiftUI

struct FilterView: View {
    @EnvironmentObject var viewModel: DrawingViewModel
    
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewModel.isEditorSelected = false
                    viewModel.isImageChoosen = false
                    viewModel.isFilterSelected = true
                    viewModel.imageData = Data(count: 0)
                    
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title)
                }
                Spacer()
                Text("Filler")
                    .font(.title)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(action: {
                    viewModel.shareImageFilter()
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                Button {
                    viewModel.showAlert = true
                    viewModel.message = "Saved Successfully"
                    UIImageWriteToSavedPhotosAlbum(viewModel.mainView.image, nil, nil, nil)
                } label: {
                    Text("Save")
                }
                .disabled(viewModel.mainView == nil ? true : false)
                
            }
            .padding()
            if !viewModel.allImages.isEmpty && viewModel.mainView != nil {
                
                Image(uiImage: viewModel.mainView.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity )
                
                Slider(value: $viewModel.value)
                    .padding()
                    .opacity(viewModel.mainView.isEditable ? 1 : 0)
                    .disabled(viewModel.mainView.isEditable ? false : true)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.allImages) { fillted in
                            Image(uiImage: fillted.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .onTapGesture {
                                    viewModel.value = 1.0
                                    viewModel.mainView = fillted
                                }
                            
                        }
                    }
                    .padding()
                }
            } else {
                ProgressView()
            }
            Spacer()
        }
        .onAppear{
            viewModel.isImageChoosen = true
        }
    }
}

