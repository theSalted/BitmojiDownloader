//
//  ContentView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/21/23.
//

import SwiftUI

struct ContentView: View {
    
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
            
            Button("Hair Brute Force") {
                
                var fetchedImage : NSImage = NSImage()
                
                // Get save permission
                if var url = showSavePanel() {
                    Task {
                        for index in 0...9999 {
                            do {
                                // URL brute forcing and fetching
                                let urlString = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=2&style=5&hair=1303&nose=" + String(index)
                                fetchedImage = try await fetchImage(from: URL(string: urlString)!)
                                
                                // URL saving
                                url = url.deletingLastPathComponent()
                                url.appendPathComponent("\(index).png")
                                savePNG(image: fetchedImage, path: url)
                                print("\(index) saved succeefully")
                            }
                            catch
                            {
                                print("\(index) no valid data")
                            }
                            
                        }
                    }
                }
            }
            
        }
        .padding()
        .onAppear {
            Task {
                image = try await fetchImage(from: URL(string: "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=2&style=5&hair=1303")!)
            }
            
        }
    }
}

// Get save directory and path from user
func showSavePanel() -> URL? {
    
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.png]
    savePanel.canCreateDirectories = true
    savePanel.isExtensionHidden = false
    savePanel.title = "Save your image"
    savePanel.message = "Choose a folder and name to store the image."
    savePanel.nameFieldLabel = "Image file name:"
    
    let response = savePanel.runModal()
    return response == .OK ? savePanel.url : nil
}

// Convert image to png and save
func savePNG(image: NSImage, path: URL) {
    let imageRepresentation = NSBitmapImageRep(data: image.tiffRepresentation!)
    let pngData = imageRepresentation?.representation(using: .png, properties: [:])
    do {
        try pngData!.write(to: path)
    } catch {
        print(error)
    }
}

func fetchImage(from url: URL) async throws -> NSImage {
    
    enum FetchImageError: Error {
        case invalidData
        case badRequest
    }
    
    // downloading data from URL
    let (data, response) = try await URLSession.shared.data(from: url)
    
    
    // http response error checking
    if let httpResponse = response as? HTTPURLResponse {
        
        if httpResponse.statusCode != 200 {
            throw FetchImageError.badRequest
        }
    }
    
    // converting data to NSImage
    guard let image = NSImage(data: data) else {
        throw FetchImageError.invalidData
    }
    
    return image
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
