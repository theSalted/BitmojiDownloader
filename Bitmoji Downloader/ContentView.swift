//
//  ContentView.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/21/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    // Batch Download Variables
    @StateObject var settings = DownloadSettings()
    
    var body: some View {
        NavigationStack {
            VStack {
                if settings.showingLogo {
                    LogoView()
                }
                
                TabView {
                    BatchDownloadSettingsView()
                    LogEditorView()
                }
            }
            .navigationTitle("Bitmoji Downloader")
            .toolbarBackground(Color.accentColor)
            .toolbar{
                ToolbarItem(id: "download", placement: .primaryAction) {
                    
                    NavigationLink {
                        DownloadView()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                        Text("Start Download")
                    }
                    .disabled(!settings.showingDownloadButton)
                    .disabled((settings.selectedMode == DownloadMode.Log) && (settings.log == nil))
                }
            }
            .frame(minWidth: 500, minHeight:  600)
            .padding()
        }
        .environmentObject(settings)
    }
}

/// Display Logo and copyright information
struct LogoView: View {
    var body: some View {
        Group {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 170)
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
}

/// A custom label displaying two texts and icon
struct InformationLabel: View {
    var labelText : String
    var systemName : String
    var bodyText : String
    var color : Color
    
    var body: some View {
        HStack {
            Label {
                Text(labelText)
            } icon: {
                Image(systemName: systemName)
                    .foregroundColor(color)
            }
            Spacer()
            Text(bodyText)
        }
    }
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

