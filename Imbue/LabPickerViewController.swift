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

	override func viewDidLoad() {
		super.viewDidLoad()
		
		lSlider.minimumTrackTintColor = UIColor.darkGray
		lSlider.maximumTrackTintColor = UIColor.lightGray
		
		aSlider.minimumTrackTintColor = CGColor.labD50(l: 50, a: -128, b: 0)?.toDisplayUIColor()
		aSlider.maximumTrackTintColor = CGColor.labD50(l: 50, a: 127, b: 0)?.toDisplayUIColor()
		
		bSlider.minimumTrackTintColor = CGColor.labD50(l: 50, a: 0, b: -128)?.toDisplayUIColor()
		bSlider.maximumTrackTintColor = CGColor.labD50(l: 50, a: 0, b: 127)?.toDisplayUIColor()
		
		lSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		aSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		bSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		
		updateColorView()
	}
	
	func sliderChanged() {
		updateColorView()
	}
	
	var colorValues: (l: CGFloat, a: CGFloat, b: CGFloat) {
		return (CGFloat(lSlider.value), CGFloat(aSlider.value), CGFloat(bSlider.value))
	}
	
	func updateColorView() {
		let colorValues = self.colorValues
		let cgColorLab = CGColor.labD50(l: colorValues.l, a: colorValues.a, b: colorValues.b)!
		colorImageView.layer.backgroundColor = cgColorLab
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

