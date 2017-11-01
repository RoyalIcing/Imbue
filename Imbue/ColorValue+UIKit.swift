//
//  ColorProvider+UIKit.swift
//  Imbue
//
//  Created by Patrick Smith on 1/11/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit


extension ColorValue {
	func copy(to pb: UIPasteboard) {
		guard let srgb = self.toSRGB()
			else { return }
		pb.string = srgb.hexString
		print("Copied: \(pb.items)")
	}
	
	init?(pasteboard pb: UIPasteboard) {
		print("PASTE 1 hasColors: \(pb.hasColors) color: \(pb.color) colors: \(pb.colors) .items: \(pb.items) \(pb.string)")
		
		if
			let string = pb.string,
			let rgb = ColorValue.RGB(hexString: string)
		{
			print("PASTED \(rgb)")
			self = .sRGB(rgb)
			return
		}
		
		return nil
	}
}
