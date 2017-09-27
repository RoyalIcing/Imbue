//
//  SRGBPickerViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit
import MobileCoreServices

class SRGBPickerViewController: UIViewController {

	@IBOutlet var rSlider: UISlider!
	@IBOutlet var gSlider: UISlider!
	@IBOutlet var bSlider: UISlider!
	@IBOutlet var rHexField: UITextField!
	@IBOutlet var gHexField: UITextField!
	@IBOutlet var bHexField: UITextField!
	@IBOutlet var colorImageView: UIImageView!
	@IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
	
	private var observers = [Any]()
	
	var colorValues: ColorValue.RGB {
		get {
			return Manager.shared.currentColorValue.toSRGB() ?? ColorValue.RGB(r: 0.5, g: 0.5, b: 0.5)
		}
		set(rgb) {
			Manager.shared.currentColorValue = .sRGB(rgb)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Sliders
		rSlider.minimumTrackTintColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		rSlider.maximumTrackTintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
		
		gSlider.minimumTrackTintColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
		gSlider.maximumTrackTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		
		bSlider.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
		bSlider.maximumTrackTintColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
		
		rSlider.addTarget(self, action: #selector(SRGBPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		gSlider.addTarget(self, action: #selector(SRGBPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		bSlider.addTarget(self, action: #selector(SRGBPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		
		// Hex fields
		for field in [rHexField!, gHexField!, bHexField!] {
			field.returnKeyType = .done
			field.keyboardType = .asciiCapable
			
			field.addTarget(self, action: #selector(SRGBPickerViewController.hexFieldChanged), for: .editingDidEndOnExit)
		}
		
		// Update
		updateUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		observers += ViewConvenience.observeKeyboardNotifications(viewController: self, constraint: bottomLayoutConstraint, valueWhenHidden: 12.0)
		
		updateUI()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		let nc = NotificationCenter.default
		for observer in observers {
			nc.removeObserver(observer)
		}
		observers.removeAll()
	}
	
	var colorValuesFromSliders: ColorValue.RGB {
		return ColorValue.RGB(
			r: CGFloat(rSlider.value),
			g: CGFloat(gSlider.value),
			b: CGFloat(bSlider.value)
		)
	}
	
	var colorValuesFromHexFields: ColorValue.RGB {
		return ColorValue.RGB(
			r: CGFloat(hexString: rHexField.text ?? "") ?? 0,
			g: CGFloat(hexString: gHexField.text ?? "") ?? 0,
			b: CGFloat(hexString: bHexField.text ?? "") ?? 0
		)
	}
	
	@objc func sliderChanged() {
		colorValues = colorValuesFromSliders
		updateUI()
	}
	
	@objc func hexFieldChanged() {
		colorValues = colorValuesFromHexFields
		updateUI()
	}
	
	func updateUI() {
		let colorValues = self.colorValues
		let cgColor = CGColor.sRGB(r: colorValues.r, g: colorValues.g, b: colorValues.b)
		
		CATransaction.begin()
		colorImageView.layer.backgroundColor = cgColor
		CATransaction.commit()
		
		rSlider.value = Float(colorValues.r)
		gSlider.value = Float(colorValues.g)
		bSlider.value = Float(colorValues.b)
		
		rHexField.text = colorValues.r.hexString
		gHexField.text = colorValues.g.hexString
		bHexField.text = colorValues.b.hexString
	}
	
	@IBAction override func copy(_ sender: Any?) {
		let rgb = self.colorValues
		let pb = UIPasteboard.general
		pb.color = ColorValue.sRGB(rgb).cgColor.map{ UIColor(cgColor: $0) }
		pb.addItems([
			[kUTTypeUTF8PlainText as String: rgb.hexString],
		])
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

