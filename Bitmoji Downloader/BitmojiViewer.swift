//
//  BitmojiViewer.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/25/23.
//

import SwiftUI

struct BitmojiViewer: View {
    @State var image: NSImage = NSImage()
    let parameter = "nose"
    @State var value = 1491
    
    var body: some View {
        VStack {
            
            // Display image
            Image(nsImage: image)
            
            // Image forward and backward
            HStack {
                
                // minus value by 1
                Button {
                    Task {
                        value -= 1
                        let urlString = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=2&style=5&hair=1303&" + parameter + "=" + String(value)
                        image = try await fetchImage(from: URL(string: urlString)!)
                    }
                } label: {
                    Text("Previous")
                }

                Text(parameter + ": " + String(value))
                
                // add value by 1
                Button {
                    Task {
                        value += 1
                        let urlString = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=2&style=5&hair=1303&" + parameter + "=" + String(value)
                        image = try await fetchImage(from: URL(string: urlString)!)
                        
                    }
                } label: {
                    Text("Next")
                }
            }
            
            Button("Save Image") {
                if let url = showSavePanel() {
                    savePNG(image: image, path: url)
                }
            }
        }
    }
}

struct BitmojiViewer_Previews: PreviewProvider {
    static var previews: some View {
        BitmojiViewer()
    }
}
