//
//  LabPickerViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit

class LabPickerViewController: UIViewController {
	
	@IBOutlet var lSlider: UISlider!
	@IBOutlet var aSlider: UISlider!
	@IBOutlet var bSlider: UISlider!
	@IBOutlet var colorImageView: UIImageView!

	var colorValues: ColorValue.Lab {
		get {
			return Manager.shared.currentColorValue.toLabD50() ?? ColorValue.Lab(l: 0.0, a: 0.0, b: 0.0)
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
		
		// Update
		updateUI()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		updateUI()
	}
	
	var colorValuesFromSliders: ColorValue.Lab {
		return ColorValue.Lab(
			l: CGFloat(lSlider.value),
			a: CGFloat(aSlider.value),
			b: CGFloat(bSlider.value)
		)
	}
	
	func sliderChanged() {
		colorValues = colorValuesFromSliders
		updateUI()
	}
	
	func updateUI() {
		let colorValues = self.colorValues
		let cgColorLab = CGColor.labD50(l: colorValues.l, a: colorValues.a, b: colorValues.b)!
		
		CATransaction.begin()
		colorImageView.layer.backgroundColor = cgColorLab
		CATransaction.commit()
		
		lSlider.value = Float(colorValues.l)
		aSlider.value = Float(colorValues.a)
		bSlider.value = Float(colorValues.b)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

