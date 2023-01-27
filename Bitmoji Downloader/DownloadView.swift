//
//  DownloadView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/27/23.
//

import SwiftUI

struct DownloadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var tasksCompleted = 0.0
    @State private var taskCompleteCount = 0
    @State private var succeedCount = 0
    @State private var failedCount = 0
    @State private var valueLog : [valueItem] = []
    @State private var isBatchComplete = false
    @State private var isSFXEnable = true
    
    @Binding var saveDirectory: URL?
    var parameter: String
    var startValue: Int
    var endValue: Int
    var baseUrlString: String
    
    init(settings: DownloadSettings, saveDirectory: Binding<URL?>) {
        self.parameter = settings.selectedParameter.rawValue
        self.startValue = settings.startValue
        self.endValue = settings.endValue
        self.baseUrlString = settings.textfieldUrlString
        self._saveDirectory = saveDirectory
    }
    
    
    var body: some View {
        VStack {
            ProgressView(value: tasksCompleted, total: Double(endValue - startValue))
            
            VStack(alignment: .leading) {
                
                Text("Information")
                    .font(.headline)
                
                Divider()
                
                InformationLabel(labelText: "Completion", systemName: "circle.dashed", bodyText: "(\(taskCompleteCount)/\(endValue))", color: .blue)
                
                Divider()
                
                InformationLabel(labelText: "Succeed", systemName: "checkmark.seal.fill", bodyText: String(succeedCount), color: .green)
                
                Divider()
                
                InformationLabel(labelText: "Failed", systemName: "exclamationmark.octagon.fill", bodyText: String(failedCount), color: .red)
                
                Divider()
                
                InformationLabel(labelText: "Parameter", systemName: "slider.horizontal.3", bodyText: String(parameter), color: .yellow)
                
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
                    NSWorkspace.shared.open(saveDirectory!)
                } label: {
                    Label("Show In Finder", systemImage: "folder")
                }
                .disabled(saveDirectory == nil)
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
            
            let saveLocation = saveDirectory ?? showOpenPanel() ?? FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            saveDirectory = saveLocation
            
            for value in startValue...endValue {
                taskCompleteCount = value
                do {
                    guard let downloadURL = URL(string: baseUrlString + "&\(parameter)=\(value)") else {
                        throw FetchImageError.invalidURL
                    }
                    
                    guard let saveURL = URL(string: saveLocation.absoluteString + "\(parameter)_\(value).png") else {
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
