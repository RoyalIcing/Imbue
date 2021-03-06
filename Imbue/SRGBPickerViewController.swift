//
//  SRGBPickerViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit
import MobileCoreServices

class SRGBPickerViewController: UIViewController, ColorProvider {

	@IBOutlet var rSlider: UISlider!
	@IBOutlet var gSlider: UISlider!
	@IBOutlet var bSlider: UISlider!
	@IBOutlet var rHexField: UITextField!
	@IBOutlet var gHexField: UITextField!
	@IBOutlet var bHexField: UITextField!
	@IBOutlet var labels: [UILabel]!
	@IBOutlet var rgbHexField: UITextField!
	@IBOutlet var colorImageView: UIImageView!
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
	
	var defaultSRGB: ColorValue.RGB {
		return ColorValue.RGB(r: 0.5, g: 0.5, b: 0.5)
	}
	
	@objc func endEditing() {
		self.view.endEditing(true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.addGestureRecognizer(
			UITapGestureRecognizer(target: self, action: #selector(endEditing))
		)
		
		self.themeUp()
		
		//UIApplication.shared.statusBarStyle = .lightContent
		colorImageView.addStatusBarVisualEffectView(effect: UIBlurEffect(style: .regular))
		
		// Sliders
		rSlider.minimumTrackTintColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		rSlider.maximumTrackTintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
		
		gSlider.minimumTrackTintColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
		gSlider.maximumTrackTintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		
		bSlider.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1)
		bSlider.maximumTrackTintColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
		
		rSlider.addTarget(self, action: #selector(SRGBPickerViewController.sliderChanged), for: UIControl.Event.valueChanged)
		gSlider.addTarget(self, action: #selector(SRGBPickerViewController.sliderChanged), for: UIControl.Event.valueChanged)
		bSlider.addTarget(self, action: #selector(SRGBPickerViewController.sliderChanged), for: UIControl.Event.valueChanged)
		
		// Hex fields
		for field in [rHexField!, gHexField!, bHexField!] {
			field.returnKeyType = .done
			field.keyboardType = .asciiCapable
			field.autocorrectionType = .no
			//field.smartDashesType = .no
			field.addTarget(self, action: #selector(SRGBPickerViewController.valueFieldChanged), for: .editingDidEndOnExit)
		}
		
		rgbHexField.returnKeyType = .done
		rgbHexField.keyboardType = .asciiCapable
		rgbHexField.autocorrectionType = .no
		//field.smartDashesType = .no
		rgbHexField.addTarget(self, action: #selector(SRGBPickerViewController.rgbHexFieldChanged), for: .editingDidEndOnExit)
		
		labels.forEach{ $0.themeUp() }
		
		textExamples = TextExamplesContext.make(
			model: TextExamplesContext.Model(backgroundSRGB: self.srgb),
			view: self.view,
			guideForKey: { [weak self]
				key in
				switch key {
				case "y":
					return self?.colorImageView.layoutMarginsGuide
				default:
					return nil
				}
			}
		)
		
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
	
	var srgbFromSliders: ColorValue.RGB {
		return ColorValue.RGB(
			r: CGFloat(rSlider.value),
			g: CGFloat(gSlider.value),
			b: CGFloat(bSlider.value)
		)
	}
	
	var srgbFromValueFields: ColorValue.RGB {
		return ColorValue.RGB(
			r: CGFloat(hexString: rHexField.text ?? "") ?? 0,
			g: CGFloat(hexString: gHexField.text ?? "") ?? 0,
			b: CGFloat(hexString: bHexField.text ?? "") ?? 0
		)
	}
	
	var srgbFromRGBHexField: ColorValue.RGB? {
		return ColorValue.RGB(
			hexString: rgbHexField.text ?? ""
		)
	}
	
	@objc func sliderChanged() {
		self.srgb = srgbFromSliders
	}
	
	@objc func valueFieldChanged() {
		self.srgb = srgbFromValueFields
	}
	
	@objc func rgbHexFieldChanged() {
		guard let srgb = srgbFromRGBHexField else { return }
		self.srgb = srgb
		updateUI()
	}
	
	func updateUI() {
		let srgb = self.srgb
		let cgColor = CGColor.sRGB(r: srgb.r, g: srgb.g, b: srgb.b)
		
		CATransaction.begin()
		colorImageView.layer.backgroundColor = cgColor
		CATransaction.commit()
		
		rSlider.value = Float(srgb.r)
		gSlider.value = Float(srgb.g)
		bSlider.value = Float(srgb.b)
		
		rHexField.text = srgb.r.hexString(minLength: 2)
		gHexField.text = srgb.g.hexString(minLength: 2)
		bHexField.text = srgb.b.hexString(minLength: 2)
		
		rgbHexField.text = srgb.hexString
		
		textExamples.backgroundSRGB = self.srgb
	}
	
	@IBAction override func copy(_ sender: Any?) {
		ColorValue.sRGB(self.srgb).copy(to: UIPasteboard.general)
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

