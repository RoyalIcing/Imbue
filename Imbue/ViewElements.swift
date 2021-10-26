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
		let previewer: Program<Model, Msg>
		
		fileprivate init(previewer: Program<Model, Msg>) {
			self.previewer = previewer
		}
		
		var backgroundSRGB: ColorValue.RGB {
			get {
				return self.previewer.model.backgroundSRGB
			}
			set {
				self.previewer.send(.changeBackgroundSRGB(newValue))
			}
		}
	}
	
	static func make(model: Model, view: UIView, guideForKey: @escaping (String) -> UILayoutGuide? = { _ in nil }) -> Bud {
		let store = LocalStore(
			initial: (model, []),
			update: update
		)
		
		let previewer = Program(view: view, store: store, render: render, layoutGuideForKey: guideForKey, layout: layout)
		
		return Bud(previewer: previewer)
	}
	
	private static func update(message: Msg, model: inout Model) -> Command<Msg> {
		switch message {
		case let .changeBackgroundSRGB(newValue):
			model.backgroundSRGB = newValue
		}
		return []
	}
	
	enum PreviewKey : String {
		case pages = "pages"
		case buttons = "buttons preview"
		
		static func forContrastRatio(textChoice: TextChoice) -> String {
			return "\(textChoice) contrastRatio"
		}
	}
	
	enum PreviewPage : Int {
		case empty
		case accessibleText
		case buttons
		
		func render(model: Model) -> [ViewElement<Msg>] {
			switch self {
			case .empty:
				return []
			case .accessibleText:
				return [
					TextExamplesContext.textExamples,
					TextExamplesContext.contrastRatios(model: model)
					].flatMap { $0 }
			case .buttons:
				return [
					.layers(
						PreviewKey.buttons,
						TextExamplesContext.renderButtonLayers(model: model)
//					[
//						LayerElement.custom("button", CATextLayer.self, [
//							.set(\.frame, to: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 100.0)),
//							.set(\.contentsScale, to: 2.0),
//							.set(\.string, to: "Click me"),
//							.set(\.alignmentMode, to: .center),
//							//.set(\.font, to: CTFontCreateWithName(UIFont.systemFont(ofSize: UIFont.buttonFontSize).fontName, 0.0, nil)),
//							.set(\.backgroundColor, to: ColorValue.sRGB(model.backgroundSRGB).cgColor),
//							.set(\.borderWidth, to: 4.0),
//							.set(\.borderColor, to: UIColor.black.cgColor),
//							.set(\.cornerRadius, to: 6.0)
//							])
//					]
					)
				]
			}
		}
		
		func layout(model: Model, context: LayoutContext) -> [NSLayoutConstraint] {
			let margins = context.marginsGuide
			let yGuide = context.guide("y")
			var constraints = [NSLayoutConstraint]()
			
			switch self {
			case .empty:
				break
			case .accessibleText:
				if let firstText = context.view(textChoices[0]) {
					let midText = context.view(textChoices[(textChoices.count + 1) / 2])!
					constraints.append(contentsOf: [
						firstText.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
						midText.centerYAnchor.constraint(equalTo: yGuide?.centerYAnchor ?? margins.centerYAnchor)
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
						let contrastRatioKey = PreviewKey.forContrastRatio(textChoice: textChoice)
						if let contrastRatioLabel = context.view(contrastRatioKey) {
							let mainLabel = context.view(textChoice)!
							constraints.append(contentsOf: [
								contrastRatioLabel.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor, constant: 12.0),
								contrastRatioLabel.firstBaselineAnchor.constraint(equalTo: mainLabel.firstBaselineAnchor)
								])
						}
					}
				}
			case .buttons:
				if let buttonView = context.view(PreviewKey.buttons) {
					
					constraints.append(contentsOf: [
						//			buttonView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8.0),
						buttonView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
						buttonView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
						buttonView.widthAnchor.constraint(equalToConstant: 200.0),
						buttonView.heightAnchor.constraint(equalToConstant: 100.0)
						])
				}
			}
			return []
		}
	}
	
	private static func render(model: Model) -> [ViewElement<Msg>] {
		return [
			ViewElement.Pages(PreviewKey.pages, count: 3, selected: PreviewPage.accessibleText, renderPage: { page in return page.render(model: model) }, layoutPage: { page, context in return page.layout(model: model, context: context) })
		]
		
//		let page = PreviewPage.buttons
//		return page.render(model: model)
		
//		return [
//			textExamples,
//			contrastRatios(model: model),
//			[
//				.layers(
//					PreviewKey.buttons,
//					self.renderButtonLayers(model: model)
//				)
//			]
//			].flatMap { $0 }
	}
	
	private static func renderButtonLayers(model: Model) -> [LayerElement<Msg>] {
		return [
			.custom("button", CATextLayer.self, [
				.set(\.frame, to: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 100.0)),
				.set(\.contentsScale, to: 2.0),
				.set(\.string, to: "Click me"),
				.set(\.alignmentMode, to: .center),
				//.set(\.font, to: CTFontCreateWithName(UIFont.systemFont(ofSize: UIFont.buttonFontSize).fontName, 0.0, nil)),
				.set(\.backgroundColor, to: ColorValue.sRGB(model.backgroundSRGB).cgColor),
				.set(\.borderWidth, to: 4.0),
				.set(\.borderColor, to: UIColor.black.cgColor),
				.set(\.cornerRadius, to: 6.0)
				])
		]
	}
	
	private static func layout(model: Model, context: LayoutContext) -> [NSLayoutConstraint] {
		let margins = context.marginsGuide
		let outerMargins = context.view
		let yGuide = context.guide("y")
		var constraints = [NSLayoutConstraint]()
		
		if let pages = context.view(PreviewKey.pages) {
			constraints.append(contentsOf: [
				pages.topAnchor.constraint(equalTo: margins.topAnchor),
				pages.bottomAnchor.constraint(equalTo: yGuide!.bottomAnchor),
				pages.leadingAnchor.constraint(equalTo: outerMargins.leadingAnchor),
				pages.trailingAnchor.constraint(equalTo: outerMargins.trailingAnchor)
				])
		}
		
		// Center first label
		if let firstText = context.view(textChoices[0]) {
			let midText = context.view(textChoices[(textChoices.count + 1) / 2])!
			constraints.append(contentsOf: [
				firstText.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
				midText.centerYAnchor.constraint(equalTo: yGuide?.centerYAnchor ?? margins.centerYAnchor)
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
				let contrastRatioKey = PreviewKey.forContrastRatio(textChoice: textChoice)
				if let contrastRatioLabel = context.view(contrastRatioKey) {
					let mainLabel = context.view(textChoice)!
					constraints.append(contentsOf: [
						contrastRatioLabel.leadingAnchor.constraint(equalTo: mainLabel.trailingAnchor, constant: 12.0),
						contrastRatioLabel.firstBaselineAnchor.constraint(equalTo: mainLabel.firstBaselineAnchor)
						])
				}
			}
		}
		
//		let lastView = context.view(textChoices.last!)!
		if let buttonView = context.view(PreviewKey.buttons) {
		
			constraints.append(contentsOf: [
				//			buttonView.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8.0),
				buttonView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
				buttonView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
				buttonView.widthAnchor.constraint(equalToConstant: 200.0),
				buttonView.heightAnchor.constraint(equalToConstant: 100.0)
				])
		}
		
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
			
			return label(PreviewKey.forContrastRatio(textChoice: textChoice), [
				.text(text),
				.set(\.font, to: smallCapsFont),
				.set(\.textColor, to: textChoice.textColor),
				])
		}
	}
}
