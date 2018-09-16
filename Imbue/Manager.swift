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
		nc.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] note in
			self?.load()
		}
		nc.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] note in
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
	
	private var defaultColorValue: ColorValue {
		return 	ColorValue.labD50(ColorValue.Lab(l: 50.0, a: -87.0, b: -95.0))
	}
	
	private func load() {
		_currentColorValue = Defaults.loadColorValue(fallback: defaultColorValue)
	}
	
	private func save() {
		Defaults.save(colorValue: _currentColorValue)
	}
}
