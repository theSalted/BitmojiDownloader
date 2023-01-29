//
//  DownloadView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/27/23.
//

import SwiftUI

struct DownloadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var settings: DownloadSettings
    
    @State private var totalTasks = 1
    @State private var tasksCompleted = 0
    @State private var succeedCount = 0
    @State private var failedCount = 0
    @State private var valueLog : [valueItem] = []
    @State private var isBatchComplete = false
    @State private var isSFXEnable = true
    
    var body: some View {
        VStack {
            ProgressView(value: (Double(tasksCompleted)/Double(totalTasks)), total: 1.0)
            
            VStack(alignment: .leading) {
                
                Text("Information")
                    .font(.headline)
                Group {
                    Divider()
                    InformationLabel(labelText: "Completion", systemName: "circle.dashed", bodyText: "(\(tasksCompleted)/\(totalTasks))", color: .blue)
                }
                Group {
                    Divider()
                    InformationLabel(labelText: "Succeed", systemName: "checkmark.seal.fill", bodyText: String(succeedCount), color: .green)
                }
                Group {
                    Divider()
                    InformationLabel(labelText: "Failed", systemName: "exclamationmark.octagon.fill", bodyText: String(failedCount), color: .red)
                }
                Group {
                    Divider()
                    InformationLabel(labelText: "Parameter", systemName: "slider.horizontal.3", bodyText: String(settings.selectedParameter.rawValue), color: .primary)
                }
                Group {
                    Divider()
                    InformationLabel(labelText: "Save Path", systemName: "folder", bodyText: settings.saveDirectory?.absoluteString ?? "", color: .primary)
                }
                Group {
                    Divider()
                    InformationLabel(labelText: "Download Mode", systemName: "filemenu.and.selection", bodyText: settings.selectedMode.rawValue, color: .primary)
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
                    NSWorkspace.shared.open(settings.saveDirectory!)
                } label: {
                    Label("Show In Finder", systemImage: "folder")
                }
                .disabled(settings.saveDirectory == nil)
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
            
            let saveLocation = settings.saveDirectory ?? showOpenPanel() ?? FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            settings.saveDirectory = saveLocation
            
            switch settings.selectedMode {
            case .Range:
                print("Range Downloading")
                totalTasks = settings.endValue - settings.startValue
                for value in settings.startValue...settings.endValue {
                    do {
                        guard let downloadURL = URL(string: settings.textfieldUrlString + "&\(settings.selectedParameter.rawValue)=\(value)") else {
                            throw FetchImageError.invalidURL
                        }
                        
                        guard let saveURL = URL(string: saveLocation.absoluteString + "\(settings.selectedParameter.rawValue)_\(value).png") else {
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
                    
                    if tasksCompleted <= (totalTasks - 1) {
                        tasksCompleted += 1
                    }
                    
                }
            case .Log:
                print("Log Downloading")
                if let unwrappedLog = settings.log {
                    var log : [valueItem]
                    
                    if settings.downloadingValidOnly {
                        log = unwrappedLog.filter{ $0.valid == true }
                    } else if settings.downloadingInValidOnly {
                        log = unwrappedLog.filter{ $0.valid == false }
                    } else {
                        log = unwrappedLog
                    }
                    
                    totalTasks = log.count
                    
                    for logItem in log {
                        
                        do {
                            var downloadURL : URL
                            
                            if settings.downloadWithLink {
                                if let unwrappedURL = URL(string: logItem.url ?? "") {
                                    downloadURL = unwrappedURL
                                } else {
                                    throw FetchImageError.invalidURL
                                }
                            } else {
                                if let unwrappedURL = URL(string: settings.textfieldUrlString + "&\(settings.selectedParameter.rawValue)=\(logItem.id)") {
                                    downloadURL = unwrappedURL
                                } else {
                                    throw FetchImageError.invalidURL
                                }
                            }
                            
                            guard let saveURL = URL(string: saveLocation.absoluteString + "\(settings.selectedParameter.rawValue)_\(logItem.id).png") else {
                                throw FetchImageError.invalidURL
                            }
                            
                            let fetchedImage = try await fetchImage(from: downloadURL)
                            savePNG(image: fetchedImage, path: saveURL)
                            valueLog.append(valueItem(id: logItem.id, valid: true, url: downloadURL.absoluteString))
                            succeedCount += 1
                            
                        } catch {
                            valueLog.append(valueItem(id: logItem.id, valid: false, url: nil))
                            failedCount += 1
                        }
                        
                        if tasksCompleted <= (totalTasks - 1) {
                            print("test complete")
                            tasksCompleted += 1
                        }
                    }
                    
                    
                } else {
                    print("NO LOG!!!")
                }
                
            case .Color:
                print("Tone Downloading")
                totalTasks = settings.hexStrings.count
                for hex in settings.hexStrings {
                    print(hex)
                    let rawHex = hex.dropFirst()
                    if let rawDec = Int(rawHex, radix: 16) {
                        do {
                            guard let downloadURL = URL(string: settings.textfieldUrlString + "&\(settings.selectedParameter.rawValue)=\(rawDec)") else {
                                throw FetchImageError.invalidURL
                            }
                            
                            guard let saveURL = URL(string: saveLocation.absoluteString + "\(settings.selectedParameter.rawValue)_\(rawDec).png") else {
                                throw FetchImageError.invalidURL
                            }
                            
                            let fetchedImage = try await fetchImage(from: downloadURL)
                            savePNG(image: fetchedImage, path: saveURL)
                            
                            valueLog.append(valueItem(id: rawDec, valid: true, url: downloadURL.absoluteString))
                            succeedCount += 1
                            
                        } catch {
                            valueLog.append(valueItem(id: rawDec, valid: false, url: nil))
                            failedCount += 1
                        }
                        
                        if tasksCompleted <= (totalTasks - 1) {
                            tasksCompleted += 1
                        }
                    }
                }
            }
            if isSFXEnable {
                NSSound(named: "Funk")?.play()
            }
            isBatchComplete = true
        }
    }
}
