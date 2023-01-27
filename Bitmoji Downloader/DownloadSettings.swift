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
    @Published var startValue = 0
    @Published var endValue = 9999
    @Published var log : [valueItem]?
    @Published var showingLogo = true
    @Published var showingDownloadButton = true
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
         HairTone = "hair_tone"
    
    var id: String {self.rawValue}
}
