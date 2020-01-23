//
//  FrameListInteractor.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 22/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public struct FrameBatch {
    public let frames: [UIImage]
    public let isEnd: Bool
}

public protocol FrameListInteractor {

    func nextFrame()

    func observe(_ result: CommandWith<Result<FrameBatch, Error>>)
}

public enum FrameListDispatcher {

    public struct State {
        let timeInSeconds: Double
        let isEnd: Bool
        let inProgress: Bool
    }

    public enum Action {
        case nextFramesLoading
        case prevFramesLoading
        case frameLoaded
    }

    public static func reduce(prev: State, action: Action, batchSize: Double, videoDuration: Double) -> State {
        switch action {

        case .nextFramesLoading:
            guard prev.inProgress == false else { return prev }
            let seconds = prev.timeInSeconds + batchSize
            return State(
                timeInSeconds: seconds,
                isEnd: seconds >= videoDuration,
                inProgress: false)

        case .prevFramesLoading:
            guard prev.inProgress == false else { return prev }
            let seconds = max(1.0, prev.timeInSeconds - batchSize)
            return State(
                timeInSeconds: seconds,
                isEnd: false,
                inProgress: false)

        case .frameLoaded:
            return State(
                timeInSeconds: prev.timeInSeconds,
                isEnd: prev.isEnd,
                inProgress: false)
        }
    }
}

public class FrameListInteractorImpl: FrameListInteractor {

    private enum Const {
        static let batchSize = 48.0
    }

    private let videoService: VideoService
    private var observer: CommandWith<Result<FrameBatch, Error>> = .nop
    private let videoDuration: Double
    private var state: FrameListDispatcher.State = FrameListDispatcher.State(timeInSeconds: 0.0, isEnd: false, inProgress: false)

    public init(videoService: VideoService) {
        self.videoService = videoService
        videoDuration = videoService.videoDurationInSeconds
        nextFrame()
    }

    public func nextFrame() {

        assert(Thread.isMainThread)

        guard state.inProgress == false else { return }

        let prevTime = Int(state.timeInSeconds)

        self.state = FrameListDispatcher.reduce(
            prev: self.state,
            action: .nextFramesLoading,
            batchSize: Const.batchSize,
            videoDuration: self.videoDuration)

        DispatchQueue.global().async {

            let frames: [UIImage?] = (prevTime...Int(self.state.timeInSeconds))
                .map { sec in
                    let result = self.videoService.frame(from: CMTimeMakeWithSeconds(Double(prevTime) + Double(sec), preferredTimescale: 60))

                    switch result {

                    case .success(let image):
                        return image

                    case .failure:
                        return nil
                    }
                }

            DispatchQueue.main.async {

                self.state = FrameListDispatcher.reduce(
                    prev: self.state,
                    action: .frameLoaded,
                    batchSize: Const.batchSize,
                    videoDuration: self.videoDuration)

                self.observer.execute(value: .success(FrameBatch(frames: frames.compactMap { $0 }, isEnd: self.state.isEnd)))
            }
        }
    }

    public func observe(_ result: CommandWith<Result<FrameBatch, Error>>) {
        observer = result
    }
}
