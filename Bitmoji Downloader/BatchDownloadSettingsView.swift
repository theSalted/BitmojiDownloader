//
//  BatchDownloadSettingsView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/27/23.
//

import SwiftUI

struct BatchDownloadSettingsView: View {
    
    @EnvironmentObject var settings: DownloadSettings
    
    var body: some View {
        Form {
            Section {
                Picker("Download Mode", selection: $settings.selectedMode) {
                    ForEach(DownloadMode.allCases) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
            }
            
            Section {
                TextField("Base URL:", text: $settings.textfieldUrlString)
                Button("Restore to default") {
                    settings.textfieldUrlString = settings.defaultDownloadURL
                }
                .disabled(settings.textfieldUrlString == settings.defaultDownloadURL)
            }
            
            Section {
                Picker("Parameters:", selection: $settings.selectedParameter) {
                    ForEach(BitmojiParameter.allCases) { parameter in
                        Text(parameter.rawValue)
                            .tag(parameter)
                    }
                }
            }
            
            switch settings.selectedMode {
            case .Range:
                Section {
                    TextField("Start Value:", value: $settings.startValue, format: .number)
                    TextField("End Value:", value: $settings.endValue, format: .number)
                }
            case .Log:
                Section {
                    Toggle(isOn: $settings.downloadingValidOnly) {
                        Text("Download Valid Only")
                    }
                    .onChange(of: settings.downloadingValidOnly, perform: { newValue in
                        if settings.downloadingValidOnly {
                            settings.downloadWithLink = true
                        } else {
                            settings.downloadWithLink = false
                        }
                    })
                    .disabled(settings.downloadingInValidOnly)
                    Toggle(isOn: $settings.downloadingInValidOnly) {
                        Text("Download Invalid Only")
                    }
                    .onChange(of: settings.downloadingInValidOnly, perform: { newValue in
                        if settings.downloadingInValidOnly {
                            settings.downloadWithLink = false
                        }
                    })
                    .disabled(settings.downloadingValidOnly)
                    Toggle(isOn: $settings.downloadWithLink) {
                        Text("Download with Links")
                    }
                    .disabled(!settings.downloadingValidOnly)
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
                    Text(settings.logLocation?.absoluteString ?? "Import log to start")
                        .font(.caption)
                }
            case .Color:
                Text("Coming Soon")
            }
            
            
            Divider()
            
            Section {
                Button {
                    settings.saveDirectory = showOpenPanel()
                } label: {
                    Label("Save Location", systemImage: "folder")
                }
                Text(settings.saveDirectory?.absoluteString ?? "")
                    .font(.caption)
                
            }
        }
        .onAppear {
            withAnimation {
                settings.showingLogo = true
                settings.showingDownloadButton = true
            }
        }
        .padding()
        .tabItem {
            Label("Batch Downloader", systemImage: "square.and.arrow.down.on.square.fill")
        }
    }
}

enum DownloadMode : String, Identifiable, CaseIterable {
    case Range = "Decimal Range",
         Log = "Log",
         Color = "HEX Color Sequence"
    
    var id: String {self.rawValue}
}
