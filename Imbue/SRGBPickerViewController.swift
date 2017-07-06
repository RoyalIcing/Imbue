//
//  SRGBPickerViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit

class SRGBPickerViewController: UIViewController {

	@IBOutlet var rSlider: UISlider!
	@IBOutlet var gSlider: UISlider!
	@IBOutlet var bSlider: UISlider!
	@IBOutlet var rHexField: UITextField!
	@IBOutlet var gHexField: UITextField!
	@IBOutlet var bHexField: UITextField!
	@IBOutlet var colorImageView: UIImageView!
	
	var colorValues: (r: CGFloat, g: CGFloat, b: CGFloat) = (0.5, 0.5, 0.5)
	
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
		rHexField.returnKeyType = .done
		rHexField.keyboardType = .asciiCapable
		gHexField.returnKeyType = .done
		gHexField.keyboardType = .asciiCapable
		bHexField.returnKeyType = .done
		bHexField.keyboardType = .asciiCapable
		
		rHexField.addTarget(self, action: #selector(SRGBPickerViewController.hexFieldChanged), for: .editingDidEnd)
		gHexField.addTarget(self, action: #selector(SRGBPickerViewController.hexFieldChanged), for: .editingDidEnd)
		bHexField.addTarget(self, action: #selector(SRGBPickerViewController.hexFieldChanged), for: .editingDidEnd)
		
		// Update
		updateUI()
	}
	
	var colorValuesFromSliders: (r: CGFloat, g: CGFloat, b: CGFloat) {
		return (
			CGFloat(rSlider.value),
			CGFloat(gSlider.value),
			CGFloat(bSlider.value)
		)
	}
	
	var colorValuesFromHexFields: (r: CGFloat, g: CGFloat, b: CGFloat) {
		return (
			CGFloat(hexString: rHexField.text ?? "") ?? 0,
			CGFloat(hexString: gHexField.text ?? "") ?? 0,
			CGFloat(hexString: bHexField.text ?? "") ?? 0
		)
	}
	
	func sliderChanged() {
		colorValues = colorValuesFromSliders
		updateUI()
	}
	
	func hexFieldChanged() {
		colorValues = colorValuesFromHexFields
		updateUI()
	}
	
	func updateUI() {
		let colorValues = self.colorValues
		let cgColorLab = CGColor.linearSRGB(r: colorValues.r, g: colorValues.g, b: colorValues.b)
		colorImageView.layer.backgroundColor = cgColorLab
		
		rSlider.value = Float(colorValues.r)
		gSlider.value = Float(colorValues.g)
		bSlider.value = Float(colorValues.b)
		
		rHexField.text = colorValues.r.hexString
		gHexField.text = colorValues.g.hexString
		bHexField.text = colorValues.b.hexString
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

