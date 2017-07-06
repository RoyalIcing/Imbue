//
//  FirstViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
	
	@IBOutlet var lSlider: UISlider!
	@IBOutlet var aSlider: UISlider!
	@IBOutlet var bSlider: UISlider!
	@IBOutlet var colorImageView: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		lSlider.addTarget(self, action: #selector(FirstViewController.sliderChanged), for: UIControlEvents.valueChanged)
		aSlider.addTarget(self, action: #selector(FirstViewController.sliderChanged), for: UIControlEvents.valueChanged)
		bSlider.addTarget(self, action: #selector(FirstViewController.sliderChanged), for: UIControlEvents.valueChanged)
		
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
		let displaySpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB)!
		let cgColorDisplay = cgColorLab.converted(to: displaySpace, intent: .absoluteColorimetric, options: nil)
		print("cgColorDisplay \(cgColorDisplay)")
		//let uiColor = UIColor.red
		colorImageView.layer.backgroundColor = cgColorLab
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

