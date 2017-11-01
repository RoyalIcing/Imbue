//
//  UserInterface.swift
//  Imbue
//
//  Created by Patrick Smith on 1/11/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit

private enum UI {
	static let backgroundColor = ColorValue.labD50(ColorValue.Lab(l: 8, a: 0, b: 0)).cgColor!
	static let textColor = ColorValue.labD50(ColorValue.Lab(l: 98, a: 0, b: 0)).cgColor!
}

extension UIViewController {
	public func themeUp() {
		view.backgroundColor = UIColor(cgColor: UI.backgroundColor)
		
		if let tbc = self as? UITabBarController {
			tbc.tabBar.barTintColor = UIColor(cgColor: UI.backgroundColor)
		}
	}
}

extension UILabel {
	public func themeUp() {
		self.textColor = UIColor(cgColor: UI.textColor)
	}
}
