//
//  ContentView.swift
//  Img generator 1
//
//  Created by Yohey Kuwabara on 2022/10/17.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @ObservedObject var vision = VisionModel()
    
    @State var showPicker = false
    @State var showActivityView = false
    
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack{
            VStack {
                Spacer()
                if vision.success{
                    Image(uiImage: vision.outputImage!)
                        .resizable()
                        .scaledToFit()
                        .onLongPressGesture {
                            self.showActivityView.toggle()
                            mediumImpact.impactOccurred()
                        }
                        .sheet(isPresented: $showActivityView){
                            ActivityView(activityItems: [vision.pngOutputImg], applicationActivities: nil)
                        }
                }else{
                    if vision.photoIsPicked{
                        Image(uiImage: vision.pickedImage!)
                            .resizable()
                            .scaledToFit()
                    }else if vision.movieIsPicked{
                        videoPlayer(movieURL: $vision.movieURL)
                    }
                }
                Spacer()
                HStack{
                    Button(action: {
                        showPicker.toggle()
                    }){
                        Image(systemName: "photo")
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    
                    Spacer()
                    if vision.photoIsPicked || vision.movieIsPicked {
                        if vision.success == false{
                            Button(action: {
                                withAnimation(){
                                    vision.processing = true
                                    print(vision.processing)
                                    vision.bgBlur = 20
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        ///vision.processing = false
                                        ///print(vision.processing)
                                        if vision.movieIsPicked{
                                            vision.extractFirstFrame()
                                        }else if vision.photoIsPicked{
                                            ///vision.styleTransfer(originalImage: vision.pickedImage!)
                                            vision.refine(originalImage: vision.pickedImage!)
                                        }
                                    }
                                }
                            }){
                                Image(systemName: "wand.and.stars")
                            }
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .blur(radius: vision.bgBlur)
            .sheet(isPresented: $showPicker){
                PhotoPicker(vision: vision, image: $vision.pickedImage, movieUrl: $vision.movieURL, photoIsPicked: $vision.photoIsPicked, movieIsPicked: $vision.movieIsPicked)
            }
            ///.fullScreenCover(isPresented: $picked) {
            ///videoPlayer(movieURL: $movieURL)
            ///}
            
            if vision.processing{
                VStack{
                    Text("loading...")
                        .fontWeight(.bold)
                        
                }
                .padding()
                ///.background(.thinMaterial)
                ///.cornerRadius(10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct videoPlayer: View{
    @Binding var movieURL: URL?
    
    var body: some View{
        VideoPlayer(player: AVPlayer(url: movieURL!))
    }
}
