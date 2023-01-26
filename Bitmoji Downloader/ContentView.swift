//
//  ContentView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/21/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    @State private var baseUrlString = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    @State private var saveLocation : URL?
    @State private var logLocation : URL?
    @State private var selectedParameter = BitmojiParameter.Nose
    @State private var startValue = 0
    @State private var endValue = 9999
    @State private var log : [valueItem]?
    @State private var showValid = true
    @State private var showInvalid = true
    @State private var showLogo = true
    @State private var showDownload = true
    
    let defaultBaseUrl = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    
    var body: some View {
        NavigationStack {
            VStack {
                if showLogo {
                    Group {
                        Image("Icon")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                        Text("welcome to")
                            .font(Font.system(.title2).smallCaps())
                        Text("Bitmoji Downloader")
                            .bold()
                            .font(.title)
                        Text("Made by Yuhao in Santa Cruz")
                            .font(.caption)
                        Divider()
                    }
                    
                }
                
                TabView {
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
                            Text(saveLocation?.absoluteString ?? "")
                                .font(.caption)

                        }
                    }
                    .onAppear {
                        withAnimation {
                            showLogo = true
                            showDownload = true
                        }
                    }
                    .padding()
                    .tabItem {
                        Label("Batch Downloader", systemImage: "square.and.arrow.down.on.square.fill")
                    }
                    
                    // Log Editor
                    VStack {
                        
                        if let wrappedLog = log {
                            VStack(alignment: .leading) {
                                
                                Text("Information")
                                    .font(.headline)
                                
                                if let absLogLocation = logLocation {
                                    Divider()
                                    
                                    HStack {
                                        Label {
                                            Text("Path")
                                        } icon: {
                                            Image(systemName: "folder")
                                                .foregroundColor(.blue)
                                        }
                                        Spacer()
                                        Text(absLogLocation.absoluteString)
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Label {
                                        Text("Valid Value")
                                    } icon: {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                    }
                                    Spacer()
                                    if let validLog = wrappedLog.filter{ $0.valid == true } {
                                        Text(String(validLog.count))
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Label {
                                        Text("Invalid Value")
                                    } icon: {
                                        Image(systemName: "xmark.octagon.fill")
                                            .foregroundColor(.red)
                                    }
                                    Spacer()
                                    if let validLog = wrappedLog.filter{ $0.valid == false } {
                                        Text(String(validLog.count))
                                    }
                                }
                                
                                Divider()
                                
                                Text("Filter")
                                    .font(.headline)
                                
                                Toggle(isOn: $showValid) {
                                    Text("Show Valid")
                                }
                                .disabled(!showInvalid)
                                Toggle(isOn: $showInvalid) {
                                    Text("Show Invalid")
                                }
                                .disabled(!showValid)
                            }
                            
                            List(wrappedLog) { item in
                                if ((item.valid && showValid) || (!item.valid && showInvalid)) {
                                    Label(item.valid ? "\(item.id) is valid" : "\(item.id) invalid",
                                          systemImage: item.valid ? "checkmark.seal.fill" : "exclamationmark.octagon.fill")
                                    .foregroundColor(item.valid ? .green : .red)
                                }
                            }
                            .frame(minHeight: 200)
                        } else {
                            Group {
                                Spacer()
                                Text("Import Log to Start")
                                    .font(.title2)
                                Spacer()
                            }
                        }
                        Button {
                            do {
                                var prunedLog : [valueItem] = []
                                
                                if showValid && showInvalid {
                                    prunedLog = log!
                                } else if showValid {
                                    prunedLog = log!.filter{ $0.valid == true}
                                } else {
                                    prunedLog = log!.filter{ $0.valid == false}
                                }
                                
                                let jsonData = try JSONEncoder().encode(prunedLog)
                                let savePath = showSaveJsonPanel()
                                if let validPath = savePath {
                                    try jsonData.write(to: validPath)
                                }
                            } catch {
                                
                            }
                        } label: {
                            Label("Prune Log", systemImage: "scissors")
                        }
                        .disabled(log == nil)
                        
                        Button {
                            if let logURL = showOpenJsonPanel() {
                                do {
                                    logLocation = logURL
                                    let data = try Data(contentsOf: logURL)
                                    let jsonLog: [valueItem] = try! JSONDecoder().decode([valueItem].self, from: data)
                                    log = jsonLog
                                    print("3")
                                } catch {
                                    print("Failed to Open Log")
                                }
                            }
                        } label: {
                            Label("Import Log", systemImage: "square.and.arrow.down.fill")
                        }
                        
                    }
                    .padding()
                    .tabItem {
                        Label("Log Editor", systemImage: "doc.text")
                    }
                    .onAppear {
                        withAnimation {
                            showLogo = false
                            showDownload = false
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
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                        Text("Start Download")
                    }
                    .disabled(!showDownload)
                }
            }
            .frame(minWidth: 500, minHeight:  650)
            .padding()
        }
    }
}



struct DownloadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var tasksCompleted = 0.0
    @State private var taskCompleteCount = 0
    @State private var succeedCount = 0
    @State private var failedCount = 0
    @State private var valueLog : [valueItem] = []
    @State private var isBatchComplete = false
    @State private var isSFXEnable = true
    
    var parameter: String
    var startValue: Int
    var endValue: Int
    var baseUrlString: String
    @State var saveLocation: URL?
    
    var body: some View {
        VStack {
            ProgressView(value: tasksCompleted, total: Double(endValue - startValue))
            
            
            
            VStack(alignment: .leading) {
                
                Text("Information")
                    .font(.headline)
                
                Divider()
                
                HStack {
                    Label {
                        Text("Completion")
                    } icon: {
                        Image(systemName: "circle.dashed")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Text("(\(taskCompleteCount)/\(endValue))")
                }
                
                Divider()
                
                HStack {
                    Label {
                        Text("Succeed")
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                    }
                    Spacer()
                    Text(String(succeedCount))
                }
                
                Divider()
                
                HStack {
                    Label {
                        Text("Failed")
                    } icon: {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundColor(.red)
                    }
                    Spacer()
                    Text(String(failedCount))
                }
                
                Divider()
                
                HStack {
                    Label("Parameter", systemImage: "slider.horizontal.3")
                    Spacer()
                    Text(String(parameter))
                }
            }
            List{
                ForEach(valueLog.reversed()) { log in
                    VStack(alignment: .leading) {
                        Label(log.valid ? "Fetch Successful" : "Fetch Failed", systemImage: log.valid ? "checkmark.seal.fill" : "exclamationmark.octagon.fill")
                            .font(.headline)
                            .foregroundColor(log.valid ? .green : .red)
                        Text("value \(log.id)")
                            .font(.caption)
                    }
                    .listRowSeparator(.visible)
                }
            }
            .frame(minHeight: 100)
            Divider()
            HStack {
                Button {
                    do {
                        let jsonData = try JSONEncoder().encode(valueLog)
                        let savePath = showSaveJsonPanel()
                        if let validPath = savePath {
                            try jsonData.write(to: validPath)
                        }
                    } catch {
                        
                    }
                } label: {
                    Label("Save Log", systemImage: "doc.text")
                }
                .disabled(!isBatchComplete)
                Spacer()
            }
            
            HStack {
                Button {
                    if let filePath = saveLocation {
                        NSWorkspace.shared.open(filePath)
                    }
                    
                } label: {
                    Label("Show In Finder", systemImage: "folder")
                }
                Spacer()
            }
            
        }
        .frame(minWidth: 500, minHeight:  500)
        .padding()
        .navigationTitle("Downloading")
        .toolbarBackground(Color.accentColor)
        .navigationBarBackButtonHidden(!isBatchComplete)
        .toolbar{
            ToolbarItem(id: "soundToggle", placement: .automatic) {
                HStack {
                    Image(systemName: isSFXEnable ? "speaker.wave.3.fill" : "speaker.slash.fill")
                    Toggle("Sound", isOn: $isSFXEnable)
                    .toggleStyle(.switch)
                    .onChange(of: isSFXEnable) { value in
                        if value {
                            NSSound(named: "Glass")?.play()
                        }
                    }
                }
            }
            ToolbarItem(id: "stop", placement: .automatic) {
                Button {
                    isSFXEnable = false
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
                saveLocation = savePath
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
                    succeedCount += 1
                    
                } catch {
                    valueLog.append(valueItem(id: value, valid: false, url: nil))
                    failedCount += 1
                }
                
                if tasksCompleted < Double(endValue - startValue) {
                    tasksCompleted += 1
                }
            }
            if isSFXEnable {
                NSSound(named: "Funk")?.play()
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

func showOpenJsonPanel() -> URL? {
    
    let openPanel = NSOpenPanel()
    openPanel.allowedContentTypes = [.json]
    openPanel.canCreateDirectories = false
    openPanel.canChooseDirectories = false
    openPanel.isExtensionHidden = false
    openPanel.title = "Open your log"
    openPanel.message = "Choose the log to import."
    
    let response = openPanel.runModal()
    return response == .OK ? openPanel.url : nil
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

struct Log : Decodable {
    var parameter: BitmojiParameter
    var items: [valueItem]
}
struct valueItem : Identifiable, Encodable, Decodable {
    let id: Int
    let valid: Bool
    let url: String?
}

enum BitmojiParameter : String, Identifiable, CaseIterable, Decodable {
    
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
