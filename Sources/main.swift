//
//  main.swift
//  heic
//
//  Created by Hyunmin Kang on 14/06/2019.
//  Copyright © 2019 Hyunmin Kang. All rights reserved.
//

import AVFoundation

let args = CommandLine.arguments;

if args.count < 2 {
    print("Usage: heic [images...]")
    print()
    exit(EXIT_SUCCESS)
}

let data = NSMutableData()
let properties = [kCGImageDestinationLossyCompressionQuality: 0.65] as CFDictionary

for file in args.dropFirst() {
    autoreleasepool {
        if FileManager.default.fileExists(atPath: file) == false {
            print(file, "not found.")
            exit(EXIT_FAILURE)
        }
        
        let fromUrl = URL(fileURLWithPath: file)
        
        let toUrl = fromUrl.deletingPathExtension().appendingPathExtension("HEIC")
        print(fromUrl.lastPathComponent + " -> " + toUrl.lastPathComponent)
        
        let source = CGImageSourceCreateWithURL(fromUrl as CFURL, nil)!
        let destination = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, source, 0, properties)
        CGImageDestinationFinalize(destination)
        
        data.write(to: toUrl, atomically: true)
        data.resetBytes(in: NSRange(location: 0, length: data.length))
        
        try! FileManager.default.removeItem(at: fromUrl)
    }
}
