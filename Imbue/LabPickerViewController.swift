//
//  LabPickerViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit
import MobileCoreServices

class LabPickerViewController: UIViewController {
	
	@IBOutlet var lSlider: UISlider!
	@IBOutlet var aSlider: UISlider!
	@IBOutlet var bSlider: UISlider!
	@IBOutlet var lHexField: UITextField!
	@IBOutlet var aHexField: UITextField!
	@IBOutlet var bHexField: UITextField!
	@IBOutlet var colorImageView: UIImageView!

	var colorValues: ColorValue.Lab {
		get {
			return Manager.shared.currentColorValue.toLabD50() ?? ColorValue.Lab(l: 50.0, a: 0.0, b: 0.0)
		}
		set(lab) {
			Manager.shared.currentColorValue = .labD50(lab)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Sliders
		lSlider.minimumTrackTintColor = UIColor.darkGray
		lSlider.maximumTrackTintColor = UIColor.lightGray
		
		aSlider.minimumTrackTintColor = CGColor.labD50(l: 50, a: -128, b: 0)?.toDisplayUIColor()
		aSlider.maximumTrackTintColor = CGColor.labD50(l: 50, a: 127, b: 0)?.toDisplayUIColor()
		
		bSlider.minimumTrackTintColor = CGColor.labD50(l: 50, a: 0, b: -128)?.toDisplayUIColor()
		bSlider.maximumTrackTintColor = CGColor.labD50(l: 50, a: 0, b: 127)?.toDisplayUIColor()
		
		lSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		aSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		bSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		
		// Hex fields
		for field in [lHexField!, aHexField!, bHexField!] {
			field.returnKeyType = .done
			field.keyboardType = .asciiCapable
			
			field.addTarget(self, action: #selector(LabPickerViewController.hexFieldChanged), for: .editingDidEnd)
		}
		
		// Update
		updateUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateUI()
	}
	
	var colorValuesFromSliders: ColorValue.Lab {
		return ColorValue.Lab(
			l: CGFloat(lSlider.value),
			a: CGFloat(aSlider.value),
			b: CGFloat(bSlider.value)
		)
	}
	
	var colorValuesFromHexFields: ColorValue.Lab {
		return ColorValue.Lab(
			l: CGFloat(hexString: lHexField.text ?? "") ?? 0,
			a: CGFloat(hexString: aHexField.text ?? "") ?? 0,
			b: CGFloat(hexString: bHexField.text ?? "") ?? 0
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
		let cgColor = CGColor.labD50(l: colorValues.l, a: colorValues.a, b: colorValues.b)!
		
		CATransaction.begin()
		colorImageView.layer.backgroundColor = cgColor
		CATransaction.commit()
		
		lSlider.value = Float(colorValues.l)
		aSlider.value = Float(colorValues.a)
		bSlider.value = Float(colorValues.b)
		
		lHexField.text = "\(Int(colorValues.l))"
		aHexField.text = "\(Int(colorValues.a))"
		bHexField.text = "\(Int(colorValues.b))"
	}
	
	override func copy(_ sender: Any?) {
		guard let rgb = ColorValue.labD50(self.colorValues).toSRGB()
			else { return }
		
		let pb = UIPasteboard.general
		pb.color = ColorValue.sRGB(rgb).cgColor.map{ UIColor(cgColor: $0) }
		pb.addItems([
			[kUTTypeUTF8PlainText as String: rgb.hexString]
		])
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

