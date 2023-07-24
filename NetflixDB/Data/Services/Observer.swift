//
//  Observer.swift
//  NetflixDB
//
//  Created by Александр Василевич on 21.07.23.
//

import Foundation

protocol Observer: AnyObject {
    func update()
}

struct WeakObserver {
    weak var value: Observer?
}

protocol Subject {
    func addObserver(observer: Observer)
    func removeObserver(observer: Observer)
    func notify()
}
