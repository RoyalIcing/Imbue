//
//  Manager.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit


enum Defaults : String {
	case currentColorValue = "currentColorValue"

	static func loadColorValue(fallback: ColorValue) -> ColorValue {
		let ud = UserDefaults.standard
		guard
			let dict = ud.dictionary(forKey: currentColorValue.rawValue),
			let colorValue = ColorValue(dictionary: dict)
			else {
				return fallback
		}
		
		return colorValue
	}

	static func save(colorValue: ColorValue?) {
		guard let value = colorValue else { return }
		
		let ud = UserDefaults.standard
		let dict = value.toDictionary()
		ud.set(dict, forKey: currentColorValue.rawValue)
	}
}


class Manager {
	static var shared = Manager()
	
	private init() {
		observe()
	}
	
	private func observe() {
		let nc = NotificationCenter.default
		nc.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] note in
			self?.load()
		}
		nc.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { [weak self] note in
			self?.save()
		}
	}
	
	private var _currentColorValue: ColorValue!
	var currentColorValue: ColorValue {
		get {
			if _currentColorValue == nil {
				load()
			}
			
			return _currentColorValue!
		}
		set(newValue) {
			_currentColorValue = newValue
		}
	}
	
	private func load() {
		_currentColorValue = Defaults.loadColorValue(fallback: ColorValue.labD50(ColorValue.Lab(l: 0.5, a: 0.5, b: 0.5)))
	}
	
	private func save() {
		Defaults.save(colorValue: _currentColorValue)
	}
}
