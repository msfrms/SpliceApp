//
//  FrameListPresenter.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 22/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import Foundation
import UIKit

public class FrameListPresenter {

    private let interactor: FrameListInteractor

    public init(interactor: FrameListInteractor) {
        self.interactor = interactor
    }

    public func observe(_ render: @escaping (FrameListViewController.Props) -> Void) {
        render(.inProgress)
        interactor.observe(CommandWith { [unowned self] result in
            switch result {

            case .failure(let error):
                render(.empty(error.localizedDescription))

            case .success(let batch):
                let framesOptional = batch.frames.map { FrameView.Props(image: $0, onTap: .nop) }.nonEmptyArray
                guard let frames = framesOptional else {
                    render(.empty("Не удалось загрузить видео файл"))
                    return
                }
                let props: FrameListViewController.Props = .content(FrameListViewController.Props.Content(
                    frames: frames,
                    onLastFrameScrolled: batch.isEnd ? nil : Command { self.interactor.nextFrame() }))
                render(props)
            }
        }.observe(queue: .main))
    }
}
