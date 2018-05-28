//
//  LabPickerViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit
import MobileCoreServices

class LabPickerViewController: UIViewController, ColorProvider {
	
	@IBOutlet var lSlider: UISlider!
	@IBOutlet var aSlider: UISlider!
	@IBOutlet var bSlider: UISlider!
	@IBOutlet var lHexField: UITextField!
	@IBOutlet var aHexField: UITextField!
	@IBOutlet var bHexField: UITextField!
	@IBOutlet var labels: [UILabel]!
	@IBOutlet var rgbHexField: UITextField!
	@IBOutlet var colorImageView: UIImageView!
	@IBOutlet var sRGBImageView: UIImageView!
	@IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
	
	private var textExamples: TextExamplesContext.Bud!
	
	private var observers = [Any]()
	
	var colorValue: ColorValue {
		get {
			return Manager.shared.currentColorValue
		}
		set(colorValue) {
			Manager.shared.currentColorValue = colorValue
			updateUI()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		colorImageView.addStatusBarVisualEffectView(effect: UIBlurEffect(style: .regular))
		sRGBImageView.addStatusBarVisualEffectView(effect: UIBlurEffect(style: .regular))
		
		self.themeUp()
		
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
			field.keyboardType = .numbersAndPunctuation
			field.autocorrectionType = .no
			//field.smartDashesType = .no
			field.addTarget(self, action: #selector(LabPickerViewController.valueFieldChanged), for: .editingDidEndOnExit)
		}
		
		rgbHexField.returnKeyType = .done
		rgbHexField.keyboardType = .numbersAndPunctuation
		rgbHexField.autocorrectionType = .no
		//field.smartDashesType = .no
		rgbHexField.addTarget(self, action: #selector(LabPickerViewController.rgbHexFieldChanged), for: .editingDidEndOnExit)
		
		labels.forEach{ $0.themeUp() }
		
		textExamples = TextExamplesContext.make(
			model: TextExamplesContext.Model(backgroundSRGB: self.srgb),
			view: self.view,
			guideForKey: { [weak self] key in
				switch key {
				case "y":
					return self?.colorImageView.layoutMarginsGuide
				default:
					return nil
				}
		})
		
		// Update
		updateUI()
	}
	
	func animateForKeyboard(height: CGFloat, duration: TimeInterval, curve: UIViewAnimationCurve) {
		bottomLayoutConstraint.constant = height
		view.setNeedsUpdateConstraints()
		
		UIView.beginAnimations("keyboard", context: nil)
		UIView.setAnimationDuration(duration)
		UIView.setAnimationCurve(curve)
		view.layoutIfNeeded()
		UIView.commitAnimations()
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
	
	var labFromSliders: ColorValue.Lab {
		return ColorValue.Lab(
			l: CGFloat(lSlider.value),
			a: CGFloat(aSlider.value),
			b: CGFloat(bSlider.value)
		)
	}
	
	var labFromValueFields: ColorValue.Lab {
		return ColorValue.Lab(
			l: lHexField.text.flatMap(CGFloat.NativeType.init).map{ CGFloat($0) } ?? 0,
			a: aHexField.text.flatMap(CGFloat.NativeType.init).map{ CGFloat($0) } ?? 0,
			b: bHexField.text.flatMap(CGFloat.NativeType.init).map{ CGFloat($0) } ?? 0
		)
	}
	
	var srgbFromRGBHexField: ColorValue.RGB? {
		return ColorValue.RGB(
			hexString: rgbHexField.text ?? ""
		)
	}
	
	@objc func sliderChanged() {
		self.labD50 = labFromSliders
		updateUI()
	}
	
	@objc func valueFieldChanged() {
		self.labD50 = labFromValueFields
		updateUI()
	}
	
	@objc func rgbHexFieldChanged() {
		guard let srgb = srgbFromRGBHexField else { return }
		self.srgb = srgb
		updateUI()
	}
	
	func updateUI() {
		let lab = self.labD50
		let cgColor = CGColor.labD50(l: lab.l, a: lab.a, b: lab.b)!
		
		CATransaction.begin()
		colorImageView.layer.backgroundColor = cgColor
		sRGBImageView.layer.backgroundColor = cgColor.toSRGB()
		CATransaction.commit()
		
		lSlider.value = Float(lab.l)
		aSlider.value = Float(lab.a)
		bSlider.value = Float(lab.b)
		
		lHexField.text = "\(Int(lab.l))"
		aHexField.text = "\(Int(lab.a))"
		bHexField.text = "\(Int(lab.b))"
		
		rgbHexField.text = srgb.hexString
		
		textExamples.backgroundSRGB = self.srgb
	}
	
	@IBAction override func copy(_ sender: Any?) {
		ColorValue.labD50(self.labD50).copy(to: UIPasteboard.general)
	}
	
	@IBAction override func paste(_ sender: Any?) {
		guard let colorValue = ColorValue(pasteboard: .general)
			else { return }
		self.colorValue = colorValue
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

