//
//  VideoService.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 22/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import UIKit
import AVFoundation

public protocol VideoService {

    var videoDurationInSeconds: Double { get }

    func frame(from time: CMTime) -> Result<UIImage, Error>
    func frames(from range: Range<Int>) -> [UIImage?]
}

public class VideoServiceImpl: VideoService {

    public var videoDurationInSeconds: Double { CMTimeGetSeconds(assetGenerator.asset.duration) }
    
    private let assetGenerator: AVAssetImageGenerator    

    public init(url: URL) {
        assetGenerator = AVAssetImageGenerator(asset: AVAsset(url: url))
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.maximumSize = CGSize(width: 200, height: 200)        
    }

    public func frame(from time: CMTime) -> Result<UIImage, Error> {
        do {
            let image = try assetGenerator.copyCGImage(at: time, actualTime: nil)
            return .success(UIImage(cgImage: image))
        }
        catch let error {
            return .failure(error)
        }
    }
}
