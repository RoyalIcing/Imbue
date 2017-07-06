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
	@IBOutlet var colorImageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		rSlider.minimumTrackTintColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		rSlider.maximumTrackTintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
		
		gSlider.minimumTrackTintColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
		gSlider.maximumTrackTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		
		bSlider.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
		bSlider.maximumTrackTintColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
		
		rSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		gSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		bSlider.addTarget(self, action: #selector(LabPickerViewController.sliderChanged), for: UIControlEvents.valueChanged)
		
		updateColorView()
	}
	
	func sliderChanged() {
		updateColorView()
	}
	
	var colorValues: (r: CGFloat, g: CGFloat, b: CGFloat) {
		return (CGFloat(rSlider.value), CGFloat(gSlider.value), CGFloat(bSlider.value))
	}
	
	func updateColorView() {
		let colorValues = self.colorValues
		let cgColorLab = CGColor.linearSRGB(r: colorValues.r, g: colorValues.g, b: colorValues.b)
		colorImageView.layer.backgroundColor = cgColorLab
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

