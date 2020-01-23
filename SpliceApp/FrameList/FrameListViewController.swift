//
//  FrameListViewController.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 21/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import UIKit

extension UICollectionViewLayout {
    static var horizontal: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }
}

public class FrameListViewController: UIViewController {

    private enum Constants {
        static let frameReuseIdentifier = "frame.wrap.cell"
        static let spinnerReuseIdentifier = "spinner.cell"
    }

    public enum Props {
        public struct Content {
            // NonEmptyArray используется чтобы не нужно было делать проверки на пустоту, такая типизация убирает часть не нужной логики
            public let frames: NonEmptyArray<FrameView.Props>
            public let onLastFrameScrolled: Command?
        }
        case empty(String)
        case inProgress
        case content(Content)
    }

    private enum FlatProps {
        case frame(FrameView.Props)
        case inProgress
    }

    private var props: Props = .empty("Не удалось загрузить кадры из видеофайла")
    // использовал UICollectionView из - за reuse, так как он эффективен по памяти
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .horizontal)
    private var items: [FlatProps] = []
    private let emptyLabel = UILabel()
    private let spinner = SpinnerView(frame: .zero)

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        collectionView.register(UICollectionViewCellWrapper.self, forCellWithReuseIdentifier: Constants.frameReuseIdentifier)
        collectionView.register(UICollectionViewCellWrapper.self, forCellWithReuseIdentifier: Constants.spinnerReuseIdentifier)

        collectionView.backgroundColor = .blue
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)

        emptyLabel.font = UIFont.systemFont(ofSize: 14)
        emptyLabel.textColor = .black
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        spinner.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyLabel)
        view.addSubview(spinner)

        let constraints: [NSLayoutConstraint] = [
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 150),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    public func render(props: Props) {
        self.props = props

        // цель такого дублирования - минимизация вероятности ошибки
        // это работает за счет того что код добавляется а не изменяется существующий, соотвественно не надо проводить регресс
        // также исключена возможность того что я могу что то забыть в блоке switch/case, к примеру в
        // case .inProgress могу забыть проставить spinner.isHidden = false, а в блоке ниже мне забыть не даст компилятор
        
        collectionView.isHidden = {
            switch props {
            case .content:
                return false
            default:
                return true
            }
        }()

        emptyLabel.isHidden = {
            switch props {
            case .empty:
                return false
            default:
                return true
            }
        }()

        spinner.isHidden = {
            switch props {
            case .inProgress:
                return false
            default:
                return true
            }
        }()

        switch props {

        case .content(let props):
            let newItems: [FlatProps] = props.frames.array.map { .frame($0) } + (props.onLastFrameScrolled != nil ? [.inProgress] : [])
            // обычно для таких случаев использую diffing, например у IGListKit/Diffing
            // сейчас сделал по простому, чтобы не усложнять код
            if items.count > 0 {
                items.removeLast()
            }
            items += newItems
            collectionView.reloadData()

        case .inProgress:
            spinner.start()

        case .empty(let text):
            emptyLabel.text = text
        }
    }
}

extension FrameListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if items.indices.last == indexPath.row {
            props.content?.onLastFrameScrolled?.execute()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width / 3.0, height: 100)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let frames = props.content?.frames.array else { return }
        guard frames.indices.contains(indexPath.row) else { return }
        frames[indexPath.row].onTap.execute(value: self)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard items.indices.contains(indexPath.row) else { fatalError("Index path \(indexPath) is out of bounds") }

        let item = items[indexPath.row]

        switch item {

        case .frame(let props):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.frameReuseIdentifier, for: indexPath) as? UICollectionViewCellWrapper else { fatalError() }

            let frameView = FrameView(frame: .zero)
            frameView.render(props: props)
            cell.wrapped(content: frameView)
            return cell

        case .inProgress:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.spinnerReuseIdentifier, for: indexPath) as? UICollectionViewCellWrapper else { fatalError() }

            let spinner = SpinnerView(frame: .zero)
            cell.wrapped(content: spinner)
            return cell
        }
    }
}

extension FrameListViewController.Props {
    var content: Content? {
        switch self {

        case .content(let props):
            return props

        default:
            return nil
        }
    }
}
