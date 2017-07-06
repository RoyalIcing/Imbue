//
//  ImbueTests.swift
//  ImbueTests
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import XCTest
@testable import Imbue

class ImbueTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testColorValueRGB() {
		do {
			let rgb = ColorValue.RGB(r: 0.5, g: 0.5, b: 0.5)
			let rgbDictionary = rgb.toDictionary()
			
			let data = try PropertyListSerialization.data(fromPropertyList: rgbDictionary, format: .binary, options: 0)
			let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
			guard let dict = plist as? [String: Any] else {
				XCTFail()
				fatalError()
			}
			
			let rgb2 = ColorValue.RGB(dictionary: dict)
			XCTAssert(rgb == rgb2!)
		}
		catch (let error) {
			XCTFail("Error \(error)")
			fatalError()
		}
	}
	
	func testColorValue() {
		do {
			let value = ColorValue.sRGB(ColorValue.RGB(r: 0.5, g: 0.5, b: 0.5))
			let dict1 = value.toDictionary()
			
			let data = try PropertyListSerialization.data(fromPropertyList: dict1, format: .binary, options: 0)
			let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
			guard let dict2 = plist as? [String: Any] else {
				XCTFail()
				fatalError()
			}
			
			let value2 = ColorValue(dictionary: dict2)
			XCTAssert(value == value2!)
		}
		catch (let error) {
			XCTFail("Error \(error)")
			fatalError()
		}
	}
	
	
	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}
	
}
