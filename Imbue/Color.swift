//
//  Color.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import Foundation
import CoreGraphics


// https://web.archive.org/web/20081207061220/http://kb.adobe.com/selfservice/viewContent.do?externalId=310838
// http://www.color-image.com/2011/10/the-reference-white-in-adobe-photoshop-lab-mode/
//let d50WhitePoint: [CGFloat] = [0.9642, 1.0000, 0.8249]
// https://au.mathworks.com/help/images/ref/whitepoint.html?requestedDomain=au.mathworks.com
let d50WhitePoint: [CGFloat] = [0.9642, 1.0000, 0.8251]
//let pcsWhitePoint: [CGFloat] = [0.962, 1.0000, 0.8249]
let blackPoint: [CGFloat] = [0.0, 0.0, 0.0]
let range: [CGFloat] = [-128, 127, -128, 127]
let labD50ColorSpace = d50WhitePoint.withUnsafeBufferPointer { (whitePointBuffer) in
	blackPoint.withUnsafeBufferPointer { (blackPointBuffer) in
		range.withUnsafeBufferPointer { (rangeBuffer) in
			CGColorSpace(labWhitePoint: whitePointBuffer.baseAddress, blackPoint: blackPointBuffer.baseAddress, range: rangeBuffer.baseAddress)
		}
	}
}!


extension CGColor {
	class func labD50(l: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> CGColor? {
		let values: [CGFloat] = [l, a, b, alpha]
		return values.withUnsafeBufferPointer { valuesBuffer in
				return CGColor(colorSpace: labD50ColorSpace, components: valuesBuffer.baseAddress!)
		}
	}
}
