//
//  ContentView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/21/23.
//

import SwiftUI




struct ContentView: View {
    
    @State private var baseUrlString = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    @State private var saveLocation : URL?
    @State private var selectedParameter = BitmojiParameter.Nose
    @State private var startValue = 0
    @State private var endValue = 9999
    let defaultBaseUrl = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 50, maxHeight: 200)
                Text("welcome to")
                    .font(Font.system(.title2).smallCaps())
                Text("Bitmoji Downloader")
                    .bold()
                    .font(.title)
                Text("Made by Yuhao in Santa Cruz")
                    .font(.caption)
                Divider()
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
                    
                    NavigationLink {
                        DownloadView(parameter: selectedParameter.rawValue, startValue: startValue, endValue: endValue, baseUrlString: baseUrlString, saveLocation: saveLocation)
                            .fixedSize()
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



struct DownloadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var tasksCompleted = 0.0
    @State private var taskCompleteCount = 0
    @State private var valueLog : [valueItem] = []
    @State private var isBatchComplete = false
    
    var parameter: String
    var startValue: Int
    var endValue: Int
    var baseUrlString: String
    var saveLocation: URL?
    
    var body: some View {
        VStack {
            ProgressView(value: tasksCompleted, total: Double(endValue - startValue))
            Text("Fetching image (\(taskCompleteCount)/\(endValue))...")
            List{
                ForEach(valueLog.reversed()) { log in
                    VStack(alignment: .leading) {
                        Text(log.valid ? "Fetch Successful" : "Fetch Failed")
                            .font(.headline)
                        Text("value \(log.id)")
                            .font(.caption)
                    }
                    .listRowSeparator(.visible)
                }
            }
            .frame(minWidth: 500, minHeight: 100)
            Divider()
            HStack {
                Button {
                    do {
                        let jsonData = try JSONEncoder().encode(valueLog)
                        let savePath = showSaveJsonPanel()
                        try jsonData.write(to: savePath!)
                    } catch {
                        
                    }
                } label: {
                    Label("Save Log", systemImage: "doc.text")
                }
                .disabled(!isBatchComplete)
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Downloading")
        .toolbarBackground(Color.accentColor)
        .navigationBarBackButtonHidden(!isBatchComplete)
        .toolbar{
            ToolbarItem(id: "stop", placement: .primaryAction) {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.octagon.fill")
                    Text("Stop Download")
                }
                .disabled(isBatchComplete)
            }
        }
        .task {
            
            var savePath : URL
                                    
            if saveLocation != nil {
                savePath = saveLocation!
            } else {
                savePath = showOpenPanel() ?? FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            }
            
            for value in startValue...endValue {
                taskCompleteCount = value
                do {
                    guard let downloadURL = URL(string: baseUrlString + "&\(parameter)=\(value)") else {
                        throw FetchImageError.invalidURL
                    }
                    
                    guard let saveURL = URL(string: savePath.absoluteString + "\(parameter)_\(value).png") else {
                        throw FetchImageError.invalidURL
                    }
                    
                    let fetchedImage = try await fetchImage(from: downloadURL)
                    savePNG(image: fetchedImage, path: saveURL)
                    
                    valueLog.append(valueItem(id: value, valid: true, url: downloadURL.absoluteString))
                    print("\(value) saved successfully")
                    
                } catch {
                    valueLog.append(valueItem(id: value, valid: false, url: nil))
                    print("\(value) no valid data")
                }
                
                if tasksCompleted < Double(endValue - startValue) {
                    tasksCompleted += 1
                }
            }
            isBatchComplete = true
        }
    }
}



func batchDownload(parameter: String, startValue: Int, endValue: Int, baseUrlString: String, savePath: URL) {
    Task {
        for value in startValue...endValue {
            do {
                guard let downloadURL = URL(string: baseUrlString + "&\(parameter)=\(value)") else {
                    throw FetchImageError.invalidURL
                }
                
                guard let saveURL = URL(string: savePath.absoluteString + "\(parameter)_\(value).png") else {
                    throw FetchImageError.invalidURL
                }
                
                let fetchedImage = try await fetchImage(from: downloadURL)
                savePNG(image: fetchedImage, path: saveURL)
                
                print("\(value) saved successfully")
                
            } catch {
                print("\(value) no valid data")
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

// Get save directory and path from user
func showSaveJsonPanel() -> URL? {
    
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.json]
    savePanel.canCreateDirectories = true
    savePanel.isExtensionHidden = false
    savePanel.title = "Save your log"
    savePanel.message = "Choose a folder and name to store the log."
    savePanel.nameFieldLabel = "Log file name:"
    
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

struct valueItem : Identifiable, Encodable {
    let id: Int
    let valid: Bool
    let url: String?
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum FetchImageError: Error {
    case invalidData
    case badRequest
    case invalidURL
}
