//
//  DownloadSettings.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/27/23.
//

import Foundation

final class DownloadSettings : ObservableObject {
    
    let defaultDownloadURL = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    
    @Published var textfieldUrlString = "https://preview.bitmoji.com/avatar-builder-v3/preview/hair?scale=3&gender=1&style=5"
    @Published var saveDirectory : URL?
    @Published var selectedParameter = BitmojiParameter.Nose
    @Published var selectedMode = DownloadMode.Range
    @Published var selecredColorTemplate = ColorTemplate.None
    @Published var startValue = 0
    @Published var endValue = 9999
    @Published var log : [valueItem]?
    @Published var showingLogo = true
    @Published var showingDownloadButton = true
    @Published var logLocation : URL?
    @Published var showingValid = true
    @Published var showingInvalid = true
    @Published var downloadingValidOnly = false
    @Published var downloadingInValidOnly = false
    @Published var downloadWithLink = false
    @Published var newColor: String = "#FFFFFF"
    @Published var hexStrings: [String] = []
}

struct valueItem : Identifiable, Encodable, Decodable {
    let id: Int
    let valid: Bool
    let url: String?
}

enum BitmojiParameter : String, Identifiable, CaseIterable, Decodable {
    
    case Beard = "beard",
         Brow = "brow",
         Ear = "ear",
         Eye = "eye",
         Eyelash = "eyelash",
         FaceProportion = "face_proportion",
         Hair = "hair",
         Jaw = "jaw",
         Mouth = "mouth",
         Nose = "nose",
         Pupil = "pupil",
         HairTone = "hair_tone",
         SkinTone = "skin_tone",
         PupilTone = "pupil_tone"
    
    var id: String {self.rawValue}
    
    func isTone() -> Bool {
        switch self {
        case .HairTone, .SkinTone, .PupilTone:
            return true
        default:
            return false
        }
        
    }
}

enum ColorTemplate : String, Identifiable, CaseIterable {
    case Skin = "Skin Tone",
         Hair = "Hair Tone",
         Eye = "Eye Color",
         None = "Custom"
    
    var id: String {self.rawValue}
    
    func getTemplate() -> [String] {
        switch self {
        case .Skin:
            return ["#93552d", "#ffcc99", "#b38a3f", "#7b4c2b", "#955e38", "#ffb284", "#caa660", "#713d20", "#aa734c", "#cfac6a", "#694126", "#f7b993", "#fbb789", "#eeab77", "#f4ad68", "#d89b5f", "#db9360", "#e0965b", "#dc924e", "#d6915b", "#c4894f", "#d58d5b", "#b2754b", "#bc8865", "#f9bc99", "#e0c282", "#65351a", "#c18f74", "#fac7b0", "#c0a282", "#5d361a", "#c18f74", "#fac7b0", "#c0a282", "#5d3619", "#c5ada0", "#ffd3bb", "#eacda9", "#53301a", "#e3c2b6", "#ffeeed", "#fae7d0", "#4a3729"]
        case .Hair:
            return ["#201d1e", "#262b2c", "#37241b", "#4a2d29", "#55423b", "#6e553d", "#663521", "#654026", "#83532a", "#a16f19", "#a67e26", "#bd9b35", "#c29d61", "#d8ab61", "#efc97c", "#eac994", "#cf8753", "#e3cb9d", "#feffcd", "#eee7d0", "#f7f7f7", "#d0cdc5", "#948a82", "#6c635e", "#a3a696", "#7f836b", "#99cacd", "#fdff04", "#fdff04", "#ff9902", "#d67542", "#d95a00", "#a94731", "#cc3331", "#980000", "#772628", "#4a1112", "#61a2a5", "#3399ff", "#0066fd", "#1f4c88", "#82cb6f", "#00ff03", "#019965", "#458446", "#ff99cc", "#f28fb3", "#c74699", "#cc0197", "#cbccfe", "#844199", "#72296f", "#583f79"]
        case .Eye:
            return ["#5c88b3", "#75666a", "#246435", "#528a63", "#111111", "#655074", "#586669", "#585566", "#465d6f", "#327891", "#71a8df", "#b38c44", "#a9ab87", "#aab9cd"]
        case .None:
            return []
        }
    }
}
