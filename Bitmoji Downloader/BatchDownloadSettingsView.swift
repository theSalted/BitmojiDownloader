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
                        
                        switch settings.selectedMode {
                        case .Color:
                            if parameter.isTone() {
                                Text(parameter.rawValue)
                                    .tag(parameter)
                            }
                            
                        default:
                            Text(parameter.rawValue)
                                .tag(parameter)
                        }
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
                Section {
                    Picker("Tone Template", selection: $settings.selecredColorTemplate) {
                        ForEach(ColorTemplate.allCases) { template in
                            Text(template.rawValue)
                                .tag(template)
                        }
                    }
                    .onChange(of: settings.selecredColorTemplate) { newValue in
                        if settings.selecredColorTemplate != ColorTemplate.None {
                            settings.hexStrings = settings.selecredColorTemplate.getTemplate()
                        }
                    }
                    .onChange(of: settings.hexStrings) { newValue in
                        if settings.hexStrings != settings.selecredColorTemplate.getTemplate() {
                            settings.selecredColorTemplate = ColorTemplate.None
                        }
                    }
                }
                Section {
                    TextField("Tone", text: $settings.newColor)
                        .onSubmit {
                            let hex = settings.newColor
                            if (hex.hasPrefix("#") && hex.count == 7 && !settings.hexStrings.contains(hex.uppercased())) {
                                let rawHex = hex.dropFirst()
                                if let rawDec = Int(rawHex, radix: 16) {
                                    print(rawDec)
                                    settings.hexStrings.append(settings.newColor.uppercased())
                                }
                            }
                        }
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(settings.hexStrings, id: \.self) { hex in
                                Button {
                                    settings.hexStrings = settings.hexStrings.filter { $0 != hex }
                                } label: {
                                    let color = hexStringToUIColor(hex: hex)
                                    Label(hex, systemImage: "circle.fill")
                                        .foregroundColor(color)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    settings.selectedParameter = BitmojiParameter.HairTone
                }
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

func hexStringToUIColor (hex:String) -> Color {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return Color.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return Color(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0
    )
}

enum DownloadMode : String, Identifiable, CaseIterable {
    case Range = "Decimal Range",
         Log = "Log",
         Color = "HEX Color Sequence"
    
    var id: String {self.rawValue}
}
