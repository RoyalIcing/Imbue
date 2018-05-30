//
//  AdjustViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 27/5/18.
//  Copyright © 2018 Royal Icing. All rights reserved.
//

//
//  LabPickerViewController.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit
import Shohin

enum AdjustMsg {
	case changeLightenAmount(CGFloat)
	case changeDarkenAmount(CGFloat)
	case changeDesaturateAmount(CGFloat)
	case copyOutputHexString(String)
}

fileprivate struct Model {
	var lightenAmount: CGFloat = 0.0
	var darkenAmount: CGFloat = 0.0
	var desaturateAmount: CGFloat = 0.0
	
	fileprivate enum Step : Int {
		case lighten = 0
		case darken
		case desaturate
	}
	
	func transform(color: ColorValue, upTo: Step) -> ColorValue {
		var rgb = color.toSRGB()!
		for step in 0 ... upTo.rawValue {
			switch step {
			case Step.lighten.rawValue:
				rgb = rgb.lightened(amount: self.lightenAmount)
			case Step.darken.rawValue:
				rgb = rgb.darkened(amount: self.darkenAmount)
			case Step.desaturate.rawValue:
				rgb = rgb.desaturated(amount: self.desaturateAmount)
			default:
				break
			}
		}
		return ColorValue.sRGB(rgb)
	}
}

private struct AdjustItem {
	var model: Model
	var inputColorValue: ColorValue
	var cellIdentifier: CellIdentifier
}

private enum CellIdentifier : String {
	case inputColor
	case lighten
	case darken
	case desaturate
	case outputColor
	
	static let all: [CellIdentifier] = [
		.inputColor,
		.lighten,
		.darken,
		.desaturate,
		.outputColor
	]
}

private enum Section : Int {
	case input
	case adjustments
	case output
	
	static let all: [Section] = [.input, .adjustments, .output]
	
	private static let cellIdentifiersTable: [Section: [CellIdentifier]] = [
		.input: [.inputColor],
		.adjustments: [.lighten, .darken, .desaturate],
		.output: [.outputColor]
	]
	
	var count: Int {
		return Section.cellIdentifiersTable[self]!.count
	}
	
	subscript(_ index: Int) -> CellIdentifier {
		return Section.cellIdentifiersTable[self]![index]
	}
}

extension CellIdentifier {
	enum ElementKey : String {
		case label
		case amount
		case colorPreview
		case copyButton
	}
	
	func render(item: AdjustItem) -> [CellProp<AdjustMsg>] {
		switch self {
		case .inputColor:
			return [
				.backgroundColor(UIColor(cgColor: item.inputColorValue.cgColor!)),
			]
		case .outputColor:
			let outputColor = item.model.transform(color: item.inputColorValue, upTo: .desaturate)
			let hexString = outputColor.toSRGB()!.hexString
			return [
				.backgroundColor(UIColor(cgColor: UI.backgroundColor)),
				.content([
					label(ElementKey.label, [
						.text(hexString),
						.set(\.textColor, to: UIColor.white),
						]),
					button(ElementKey.copyButton, [
						.title("Copy Hex", for: .normal),
						.set(\.font, to: UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)),
						.onPress { .copyOutputHexString(hexString) }
						])
				])
			]
		case .lighten:
			let outputColor = item.model.transform(color: item.inputColorValue, upTo: .lighten)
			return [
				.backgroundColor(UIColor(cgColor: UI.backgroundColor)),
				.content([
					customView(ElementKey.colorPreview, UIView.self, [
						.backgroundColor(outputColor.cgColor!)
						]),
					label(ElementKey.label, [
						.text("Lighten"),
						.set(\.textColor, to: UIColor.white),
						]),
					slider(ElementKey.amount, [
						.value(Float(item.model.lightenAmount)),
						.on(.valueChanged) { slider, event in
							.changeLightenAmount(CGFloat(slider.value))
						}
						]),
					])
			]
		case .darken:
			let outputColor = item.model.transform(color: item.inputColorValue, upTo: .darken)
			return [
				.backgroundColor(UIColor(cgColor: UI.backgroundColor)),
				.content([
					customView(ElementKey.colorPreview, UIView.self, [
						.backgroundColor(outputColor.cgColor!)
						]),
					label(ElementKey.label, [
						.text("Darken"),
						.set(\.textColor, to: UIColor.white),
						]),
					slider(ElementKey.amount, [
						.value(Float(item.model.darkenAmount)),
						.on(.valueChanged) { slider, event in
							.changeDarkenAmount(CGFloat(slider.value))
						}
						]),
					])
			]
		case .desaturate:
			let outputColor = item.model.transform(color: item.inputColorValue, upTo: .desaturate)
			return [
				.backgroundColor(UIColor(cgColor: UI.backgroundColor)),
				.content([
					customView(ElementKey.colorPreview, UIView.self, [
						.backgroundColor(outputColor.cgColor!)
						]),
					label(ElementKey.label, [
						.text("Desaturate"),
						.set(\.textColor, to: UIColor.white),
						]),
					slider(ElementKey.amount, [
						.value(Float(item.model.desaturateAmount)),
						.on(.valueChanged) { slider, event in
							.changeDesaturateAmount(CGFloat(slider.value))
						}
						]),
					])
			]
		}
	}
	
	func layout(item: AdjustItem, context: LayoutContext) -> [NSLayoutConstraint] {
		let margins = context.marginsGuide
		let view = context.view
		switch item.cellIdentifier {
		case .lighten, .darken, .desaturate:
			let colorPreview = context.view(ElementKey.colorPreview)!
			let label = context.view(ElementKey.label)!
			let amount = context.view(ElementKey.amount)!
			return [
				label.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
				label.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5),
				label.centerYAnchor.constraint(equalTo: amount.centerYAnchor),
				amount.leadingAnchor.constraint(equalTo: label.trailingAnchor),
				amount.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
				amount.topAnchor.constraint(equalTo: margins.topAnchor),
				colorPreview.topAnchor.constraint(equalTo: margins.centerYAnchor),
				colorPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				colorPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				colorPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			]
		case .outputColor:
			let label = context.view(ElementKey.label)!
			let copyButton = context.view(ElementKey.copyButton)!
			return [
				label.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
				label.widthAnchor.constraint(equalTo: margins.widthAnchor, multiplier: 0.5),
				label.centerYAnchor.constraint(equalTo: copyButton.centerYAnchor),
				copyButton.leadingAnchor.constraintGreaterThanOrEqualToSystemSpacingAfter(label.trailingAnchor, multiplier: 1.0),
				copyButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
				copyButton.topAnchor.constraint(equalTo: margins.topAnchor),
			]
		default:
			return []
		}
	}
}

// MARK: -

private func update(message: AdjustMsg, model: inout Model) {
	switch message {
	case let .changeLightenAmount(amount):
		model.lightenAmount = amount
	case let .changeDarkenAmount(amount):
		model.darkenAmount = amount
	case let .changeDesaturateAmount(amount):
		model.desaturateAmount = amount
	case let .copyOutputHexString(hexString):
		let rgb = ColorValue.RGB(hexString: hexString)!
		ColorValue.sRGB(rgb).copy(to: UIPasteboard.general)
	}
}

class AdjustViewController: UITableViewController, ColorProvider {
	private var tableAssistant: TableAssistant<Model, AdjustItem, AdjustMsg>!
	
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
		
		self.themeUp()
		
		let tableView = self.tableView!
		tableView.allowsSelection = false
		tableView.rowHeight = 88.0
		tableView.separatorStyle = .none
		tableView.insetsContentViewsToSafeArea = false
		tableView.contentInsetAdjustmentBehavior = .never
		
		self.tableAssistant = TableAssistant<Model, AdjustItem, AdjustMsg>(tableView: tableView, initial: Model(), update: update)
		
		for cellIdentifier in CellIdentifier.all {
			tableAssistant.registerCells(reuseIdentifier: cellIdentifier, render: cellIdentifier.render, layout: cellIdentifier.layout, tableView: tableView)
		}
		
		// Update
		updateUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateUI()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	func updateUI() {
		tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: Table data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.all.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
		return Section(rawValue: sectionIndex)!.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = Section(rawValue: indexPath.section)!
		let cellIdentifier = section[indexPath.item]
		let item = AdjustItem(model: tableAssistant.model, inputColorValue: colorValue, cellIdentifier: cellIdentifier)
		return tableAssistant.cell(cellIdentifier, item, tableView: tableView)
	}
}
