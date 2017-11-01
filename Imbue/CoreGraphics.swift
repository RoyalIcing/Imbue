//
//  CoreGraphics.swift
//  Imbue
//
//  Created by Patrick Smith on 1/11/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import CoreGraphics


extension CGFloat {
	func hexString(minLength: Int) -> String {
		let clamped: CGFloat = Swift.min(Swift.max(self, 0.0), 1.0)
		let uint255 = UInt8(clamped * 255)
		let hexString = String(uint255, radix: 16, uppercase: true)
		return hexString.padding(toLength: minLength, withPad: "0", startingAt: 0)
	}
	
	init?<S>(hexString hexStringInput: S)
		where S : StringProtocol
	{
		let hexString = String(hexStringInput).replacingOccurrences(of: "0x", with: "")
		guard let uint255 = UInt8(hexString, radix: 16)
			else { return nil }
		
		let f0to1 = CGFloat(uint255) / 255.0
		
		self.init(f0to1)
	}
}
