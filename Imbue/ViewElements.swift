//
//  ViewElements.swift
//  Imbue
//
//  Created by Patrick Smith on 20/5/18.
//  Copyright © 2018 Royal Icing. All rights reserved.
//

import Foundation
import UIKit
import Shohin


struct TextChoice : OptionSet {
	let rawValue: Int
	
	static let sizeNormal = TextChoice(rawValue: 1 << 0)
	static let sizeLarge = TextChoice(rawValue: 1 << 1)
	static let regularWeight = TextChoice(rawValue: 1 << 2)
	static let boldWeight = TextChoice(rawValue: 1 << 3)
	static let light = TextChoice(rawValue: 1 << 4)
	static let dark = TextChoice(rawValue: 1 << 5)
	
	var textColor: UIColor {
		if self.contains(.light) {
			return .white
		}
		else {
			return .black
		}
	}
	
	func labelProps<Msg>() -> [LabelProp<Msg>] {
		var fontSize: CGFloat = 17
		var fontWeight: UIFont.Weight = .regular
		var fontWeightText = "regular"
		
		if self.contains(.sizeLarge) {
			fontSize = 24
		}
		
		if self.contains(.boldWeight) {
			fontWeight = .bold
			fontWeightText = "bold"
		}
		
		return [
			.set(\.font, to: UIFont.systemFont(ofSize: fontSize, weight: fontWeight)),
			.set(\.textColor, to: self.textColor),
			.text("\(Int(fontSize)) px \(fontWeightText)")
		]
	}
	
	var wcagLuminance: WCAGLuminance {
		if self.contains(.light) {
			return .white
		}
		else {
			return .black
		}
	}
	
	var aaMinimumContrastRatio: CGFloat {
		if self.contains(.boldWeight) {
			return 3
		}
		else {
			if self.contains(.sizeNormal) {
				return 4.5
			}
			else {
				return 3
			}
		}
	}
	
	var aaaMinimumContrastRatio: CGFloat {
		if self.contains(.boldWeight) {
			return 4.5
		}
		else {
			if self.contains(.sizeNormal) {
				return 7
			}
			else {
				return 4.5
			}
		}
	}
}


let textChoices: [TextChoice] = [
	[.sizeNormal, .regularWeight, .dark],
	[.sizeNormal, .regularWeight, .light],
	[.sizeNormal, .boldWeight, .dark],
	[.sizeNormal, .boldWeight, .light],
	[.sizeLarge, .regularWeight, .dark],
	[.sizeLarge, .regularWeight, .light]
]

enum TextExamplesContext {
	struct Model {
		var backgroundSRGB: ColorValue.RGB
	}
	
	enum Msg {
		case changeBackgroundSRGB(ColorValue.RGB)
	}
	
	class Bud {
		let program: Program<Model, Msg>
		let buttonProgram: LayerProgram<Model, Msg, Store<Model, Msg>>
		
		fileprivate init(program: Program<Model, Msg>, buttonProgram: LayerProgram<Model, Msg, Store<Model, Msg>>) {
			self.program = program
			self.buttonProgram = buttonProgram
		}
		
		var backgroundSRGB: ColorValue.RGB {
			get {
				return self.program.model.backgroundSRGB
			}
			set {
				self.program.send(.changeBackgroundSRGB(newValue))
			}
		}
	}
	
	static func make(model: Model, view: UIView, guideForKey: @escaping (String) -> UILayoutGuide? = { _ in nil }) -> Bud {
		let store = Store(
			initial: (model, []),
			update: update
		)
		
		let program = Program(view: view, store: store, render: render, layoutGuideForKey: guideForKey, layout: layout)
		
		let layer = CALayer()
		view.layer.addSublayer(layer)
		
		let buttonLayerEnvironment = LayerProgram(layer: layer, store: store, render: renderButtonLayers)
		
		return Bud(program: program, buttonProgram: buttonLayerEnvironment)
	}
	
	private static func update(message: Msg, model: inout Model) -> Command<Msg> {
		switch message {
		case let .changeBackgroundSRGB(newValue):
			model.backgroundSRGB = newValue
		}
		return []
	}
	
	private static func keyForContrastRatio(textChoice: TextChoice) -> String {
		return "\(textChoice) contrastRatio"
	}
	
	static var keyForButtonLayers: String {
		return "button layers"
	}
	
	private static func render(model: Model) -> [ViewElement<Msg>] {
		return [
			textExamples,
			contrastRatios(model: model),
			[
				.layers(
					self.keyForButtonLayers,
					[
						.custom("button", CALayer.self, [
							.set(\.backgroundColor, to: UIColor.red.cgColor)
							])
					]
				)
			]
			].flatMap { $0 }
	}
	
	private static func renderButtonLayers(model: Model) -> [LayerElement<Msg>] {
		return [
			
		]
	}
	
	private static func layout(model: Model, context: LayoutContext) -> [NSLayoutConstraint] {
		let margins = context.marginsGuide
		let yGuide = context.guide("y")
		var constraints = [NSLayoutConstraint]()
		
		// Center first label
		let first = context.view(textChoices.first!)!
		let mid = context.view(textChoices[(textChoices.count + 1) / 2])!
		constraints.append(contentsOf: [
			first.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
			mid.centerYAnchor.constraint(equalTo: yGuide?.centerYAnchor ?? margins.centerYAnchor)
		])
		
		// Stack each label on top of each other
		for (topChoice, bottomChoice) in zip(textChoices, textChoices[1...]) {
			let topView = context.view(topChoice)!
			let bottomView = context.view(bottomChoice)!
			
			let stackConstraint = bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 8.0)
			//stackConstraint.priority = .defaultLow
			
			constraints.append(contentsOf: [
				stackConstraint,
				bottomView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
				//bottomView.bottomAnchor.constraint(lessThanOrEqualTo: margins.bottomAnchor)
			])
		}
		
		// Add accessibility contrast ratio scores
		for textChoice in textChoices {
			let contrastRatioKey = keyForContrastRatio(textChoice: textChoice)
			if let contrastRatioLabel = context.view(contrastRatioKey) {
				let mainLabel = context.view(textChoice)!
				constraints.append(contentsOf: [
					contrastRatioLabel.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor, constant: 12.0),
					contrastRatioLabel.firstBaselineAnchor.constraint(equalTo: mainLabel.firstBaselineAnchor)
					])
			}
		}
		
		let lastView = context.view(textChoices.last!)!
		let buttonView = context.view(self.keyForButtonLayers)!
		constraints.append(contentsOf: [
//			buttonView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8.0),
			buttonView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
			buttonView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
			buttonView.widthAnchor.constraint(equalToConstant: 200.0),
			buttonView.heightAnchor.constraint(equalToConstant: 20.0)
			])
		
		return constraints
	}
	
	private static let textExamples: [ViewElement<Msg>] = textChoices.map { textChoice in
		label(textChoice, textChoice.labelProps())
	}
	
	private static var smallCapsFont: UIFont {
		let baseFont = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
		let smallCapsDesc = baseFont.fontDescriptor.addingAttributes([
			.featureSettings: [
				[
					kCTFontFeatureTypeIdentifierKey: kUpperCaseType,
					kCTFontFeatureSelectorIdentifierKey: kUpperCaseSmallCapsSelector
				],
				[
					kCTFontFeatureTypeIdentifierKey: kNumberSpacingType,
					kCTFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
				]
			]
			])
		return UIFont(descriptor: smallCapsDesc, size: baseFont.pointSize)
	}
	
	private static func contrastRatios(model: Model) -> [ViewElement<Msg>] {
		return textChoices.map { textChoice in
			let (lighter, darker) = getLighterAndDarker(model.backgroundSRGB.wcagLuminance, textChoice.wcagLuminance)
			let contrastRatio = calculateContrastRatio(lighter: lighter, darker: darker)
			let text: String
			let formatted = { "\((contrastRatio * 100.0).rounded() / 100.0)" }
			if contrastRatio >= textChoice.aaaMinimumContrastRatio {
				text = "AAA \(formatted())"
			}
			else if contrastRatio >= textChoice.aaMinimumContrastRatio {
				text = "AA \(formatted())"
			}
			else {
				text = " "
			}
			
			return label(keyForContrastRatio(textChoice: textChoice), [
				.text(text),
				.set(\.font, to: smallCapsFont),
				.set(\.textColor, to: textChoice.textColor),
				])
		}
	}
}
