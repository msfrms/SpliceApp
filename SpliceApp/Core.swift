//
//  Core.swift
//  SpliceApp
//
//  Created by Radaev Mikhail on 21/01/2020.
//  Copyright © 2020 msfrms. All rights reserved.
//

import Foundation

public struct NonEmptyArray<T> {
    public let head: T
    public let tail: [T]
    public var array: [T] { [head] + tail }
}

extension Array {
    public var nonEmptyArray: NonEmptyArray<Element>? {
        guard let first = first else { return nil }
        return NonEmptyArray<Element>(head: first, tail: [Element](dropFirst(1)))
    }
}

// простая реализация паттерна Команда
public final class CommandWith<T> {

    public typealias Callback = (T) -> ()

    private let callback: Callback
    private let id: String
    private let file: StaticString
    private let function: StaticString
    private let line: Int

    public init(id: String = "unnamed",
         file: StaticString = #file,
         function: StaticString = #function,
         line: Int = #line,
         callback: @escaping Callback) {
        self.id = id
        self.file = file
        self.function = function
        self.line = line
        self.callback = callback
    }

    public func execute(value: T) { self.callback(value) }
}

public extension CommandWith where T == Void {

    func execute() { self.execute(value: ()) }
}

public typealias Command = CommandWith<Void>

public extension CommandWith {

    static var nop: CommandWith<T> { CommandWith<T> { _ in } }

    func debounce(delay: DispatchTimeInterval, queue: DispatchQueue) -> CommandWith<T> {
        var currentWorkItem: DispatchWorkItem?
        return  CommandWith<T>(id: self.id) { value in
            currentWorkItem?.cancel()
            currentWorkItem = DispatchWorkItem { self.execute(value: value) }
            queue.asyncAfter(deadline: .now() + delay, execute: currentWorkItem!)
        }
    }

    func delay(_ delay: DispatchTimeInterval, queue: DispatchQueue = .main) -> CommandWith<T> {
        return  CommandWith<T>(id: self.id) { value in
            queue.asyncAfter(deadline: .now() + delay) { self.execute(value: value) }
        }
    }

    func observe(queue: DispatchQueue) -> CommandWith<T> {
        return CommandWith<T>(id: self.id) { value in queue.async { self.execute(value: value) } }
    }
}
