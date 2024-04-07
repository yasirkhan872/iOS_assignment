//
//  Observable.swift
//  iOS_assignment
//
//  Created by Yasir Khan on 06/04/2024.
//

import Foundation

class Observable<T> {
    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.valueChanged?(self.value)
            }
        }
    }
    private var valueChanged: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    func bind(_ onChange: @escaping (T) -> Void) {
        valueChanged = onChange
        valueChanged?(value)
    }
}
