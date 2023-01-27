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
            
            Section {
                TextField("Start Value:", value: $settings.startValue, format: .number)
                TextField("End Value:", value: $settings.endValue, format: .number)
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
