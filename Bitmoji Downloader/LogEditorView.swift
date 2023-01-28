//
//  LogEditorView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/27/23.
//

import SwiftUI

struct LogEditorView: View {
    @EnvironmentObject var settings: DownloadSettings
    var body: some View {
        VStack {
            if let wrappedLog = settings.log {
                VStack(alignment: .leading) {
                    
                    Text("Information")
                        .font(.headline)
                    
                    if let absLogLocation = settings.logLocation {
                        Divider()
                        InformationLabel(labelText: "Path", systemName: "folder", bodyText: absLogLocation.absoluteString, color: .blue)
                    }
                    
                    if let validLog = wrappedLog.filter{ $0.valid == true } {
                        Divider()
                        InformationLabel(labelText: "Valid Value", systemName: "checkmark.seal.fill", bodyText: String(validLog.count), color: .green)
                    }
                    
                    if let invalidLog = wrappedLog.filter{ $0.valid == false } {
                        Divider()
                        InformationLabel(labelText: "Invalid Value", systemName: "xmark.octagon.fill", bodyText: String(invalidLog.count), color: .red)
                    }
                    
                    Divider()
                    
                    Text("Filter")
                        .font(.headline)
                    
                    Toggle(isOn: $settings.showingValid) {
                        Text("Show Valid")
                    }
                    .disabled(!settings.showingInvalid)
                    Toggle(isOn: $settings.showingInvalid) {
                        Text("Show Invalid")
                    }
                    .disabled(!settings.showingValid)
                }
                
                List(wrappedLog) { item in
                    if ((item.valid && settings.showingValid) || (!item.valid && settings.showingInvalid)) {
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
                    
                    if settings.showingValid && settings.showingInvalid {
                        prunedLog = settings.log!
                    } else if settings.showingValid {
                        prunedLog = settings.log!.filter{ $0.valid == true}
                    } else {
                        prunedLog = settings.log!.filter{ $0.valid == false}
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
            .disabled(settings.log == nil)
            
            Button {
                if let logURL = showOpenJsonPanel() {
                    do {
                        settings.logLocation = logURL
                        let data = try Data(contentsOf: logURL)
                        let jsonLog: [valueItem] = try! JSONDecoder().decode([valueItem].self, from: data)
                        settings.log = jsonLog
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
                settings.showingLogo = false
                settings.showingDownloadButton = false
            }
        }
    }
}
