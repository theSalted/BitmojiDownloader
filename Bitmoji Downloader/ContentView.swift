//
//  ContentView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/21/23.
//

import SwiftUI




struct ContentView: View {
    
    @State var baseUrlString = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    
    @State private var selectedParameter = BitmojiParameter.Nose
    
    @State private var saveLocation : URL?
    
    @State private var startValue = 0
    @State private var endValue = 9999
    
    let defaultBaseUrl = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        
                        TextField("Base URL:", text: $baseUrlString)
                        Button("Restore to default") {
                            baseUrlString = defaultBaseUrl
                        }
                        .disabled(baseUrlString == defaultBaseUrl)
                    }
                    
                    Section {
                        Picker("Parameters:", selection: $selectedParameter) {
                            ForEach(BitmojiParameter.allCases) { parameter in
                                Text(parameter.rawValue)
                                    .tag(parameter)
                            }
                        }
                    }
                    
                    Section {
                        TextField("Start Value:", value: $startValue, format: .number)
                        TextField("End Value:", value: $endValue, format: .number)
                    }
                    
                    Divider()
                    
                    Section {
                        Button {
                            saveLocation = showOpenPanel()
                        } label: {
                            Label("Save Location", systemImage: "folder")
                        }

                    }
                    
                }
            }
            .navigationTitle("Bitmoji Downloader")
            .toolbarBackground(Color.accentColor)
            .toolbar{
                ToolbarItem(id: "download", placement: .primaryAction) {
                    Button {
                        var fetchedImage : NSImage = NSImage()
                        
                        // Get save permission
                        var url : URL
                        
                        if saveLocation != nil {
                            url = saveLocation!
                        } else {
                            url = showOpenPanel()!
                        }
                        
                        // Create Download Task
                        Task {
                            for index in startValue...endValue {
                                do {
                                    // URL brute forcing and fetching
                                    let urlString = baseUrlString + "&" + selectedParameter.rawValue + "=" + String(index)
                                    fetchedImage = try await fetchImage(from: URL(string: urlString)!)
                                    
                                    // URL saving
                                    url.appendPathComponent("\(index).png")
                                    savePNG(image: fetchedImage, path: url)
                                    url = url.deletingLastPathComponent()
                                    print("\(index) saved succeefully")
                                }
                                catch
                                {
                                    print("\(index) no valid data")
                                }
                                
                            }
                        }
                        
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                        Text("Start Download")
                    }
                }
            }

            .padding()
        }
    }
}




enum BitmojiParameter : String, Identifiable, CaseIterable {
    
    case Ear = "ear",
         Eye = "eye",
         FaceProportion = "face_proportion",
         Hair = "hair",
         Jaw = "jaw",
         Mouth = "mouth",
         Nose = "nose",
         Pupil = "pupil"
    
    var id: String {self.rawValue}
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

// Get save directory and path from user (can't select file)
func showOpenPanel() -> URL? {
    
    let openPanel = NSOpenPanel()
    openPanel.canCreateDirectories = true
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = false
    openPanel.title = "Save your images"
    openPanel.message = "Choose a folder to store the image."
    openPanel.nameFieldLabel = "Image file name:"
    
    let response = openPanel.runModal()
    return response == .OK ? openPanel.url : nil
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
