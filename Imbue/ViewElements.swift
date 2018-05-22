//
//  ViewElements.swift
//  Imbue
//
//  Created by Patrick Smith on 20/5/18.
//  Copyright © 2018 Royal Icing. All rights reserved.
//

import Foundation
import Shohin


struct TextChoice : OptionSet {
	let rawValue: Int
	
	static let size17 = TextChoice(rawValue: 1 << 0)
	static let size24 = TextChoice(rawValue: 1 << 1)
	static let regularWeight = TextChoice(rawValue: 1 << 2)
	static let boldWeight = TextChoice(rawValue: 1 << 3)
	static let light = TextChoice(rawValue: 1 << 4)
	static let dark = TextChoice(rawValue: 1 << 5)
	
	func labelProps<Msg>() -> [LabelProp<Msg>] {
		var fontSize: CGFloat = 17
		var fontWeight: UIFont.Weight = .regular
		var fontWeightText = "regular"
		let color: UIColor
		
		if (self.contains(.size24)) {
			fontSize = 24
		}
		
		if (self.contains(.boldWeight)) {
			fontWeight = .bold
			fontWeightText = "bold"
		}
		
		if (self.contains(.light)) {
			color = .white
		}
		else {
			color = .black
		}
		
		return [
			.set(\.font, to: UIFont.systemFont(ofSize: fontSize, weight: fontWeight)),
			.set(\.textColor, to: color),
			.text("\(Int(fontSize)) px \(fontWeightText)")
		]
	}
}


let textChoices: [TextChoice] = [
	[.size17, .regularWeight, .dark],
	[.size17, .regularWeight, .light],
	[.size17, .boldWeight, .dark],
	[.size17, .boldWeight, .light],
	[.size24, .regularWeight, .dark],
	[.size24, .regularWeight, .light]
]

enum TextExamplesContext {
	typealias Model = ()
	typealias Msg = Never
	typealias Bud = Program<Model, Msg>
	
	static func make(view: UIView, guideForKey: @escaping (String) -> UILayoutGuide? = { _ in nil }) -> Bud {
		return Program(view: view, model: (), render: render, layoutGuideForKey: guideForKey, layout: layout)
	}
	
	private static func render(model: Model) -> [Element<Msg>] {
		return textExamples
	}
	
	private static func layout(model: Model, context: LayoutContext) -> [NSLayoutConstraint] {
		let margins = context.marginsGuide
		let yGuide = context.guide("y")
		var constraints = [NSLayoutConstraint]()
		
		let first = context.view(textChoices.first!)!
		let mid = context.view(textChoices[(textChoices.count - 1) / 2])!
		constraints.append(contentsOf: [
			first.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
			mid.centerYAnchor.constraint(equalTo: yGuide?.centerYAnchor ?? margins.centerYAnchor)
		])
		
		for (topChoice, bottomChoice) in zip(textChoices, textChoices[1...]) {
			let topView = context.view(topChoice)!
			let bottomView = context.view(bottomChoice)!
			
			constraints.append(contentsOf: [
				bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 8.0),
				bottomView.centerXAnchor.constraint(equalTo: margins.centerXAnchor)
			])
		}
		
		return constraints
	}
	
	private static let textExamples: [Element<Msg>] = textChoices.map { textChoice in
		label(textChoice, textChoice.labelProps())
	}
}
