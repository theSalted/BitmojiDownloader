//
//  SavePanels.swift
//  Bitmoji Downloader
//
//  Created by Yuhao Chen on 1/27/23.
//

import Foundation
import SwiftUI

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
