//
//  main.swift
//  heic
//
//  Created by Hyunmin Kang on 14/06/2019.
//

import AVFoundation
import ArgumentParser
import CoreImage

@main
struct Heic: ParsableCommand {
    @Option(help: "Compress quality (0 ~ 100)")
    var quality: Double?

    @Argument(help: "Input image files")
    var files: [String]

    func run() throws {
        for path in files {
            let fromUrl = URL(fileURLWithPath: path)
            let toUrl = fromUrl.deletingPathExtension().appendingPathExtension("HEIC")

            print(fromUrl.lastPathComponent, " -> ", toUrl.lastPathComponent)

            let source = CGImageSourceCreateWithURL(fromUrl as CFURL, nil)!
            let metadata =
                CGImageSourceCopyPropertiesAtIndex(source, 0, nil)! as! [AnyHashable: Any]

            let properties: NSMutableDictionary = [:]
            properties.addEntries(from: metadata)
            properties[kCGImageDestinationLossyCompressionQuality] =
                self.quality ?? (metadata[kCGImagePropertyDepth] as? Int ?? 0 > 8 ? 0.5 : 0.7)

            let destination = CGImageDestinationCreateWithURL(
                toUrl as CFURL, AVFileType.heic as CFString, 1, nil)!

            switch fromUrl.pathExtension.uppercased() {
            case "ARW", "CR2", "CR3", "NEF", "ORF", "PEF", "RAF", "RW2":  // Raw
                let colorSpace = CGColorSpace(name: CGColorSpace.displayP3_PQ)!
                let fromImage = CIImage(contentsOf: fromUrl, options: [.expandToHDR: true])!
                let toImage = CIContext().createCGImage(
                    fromImage, from: fromImage.extent, format: .RGB10, colorSpace: colorSpace)!
                CGImageDestinationAddImage(destination, toImage, properties)
            default:
                CGImageDestinationAddImageFromSource(destination, source, 0, properties)
            }

            CGImageDestinationFinalize(destination)
        }
    }
}
