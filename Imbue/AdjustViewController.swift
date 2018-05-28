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

private enum Section : Int {
	case input
	case adjustments
	
	static let all: [Section] = [.input, .adjustments]
	
	var count: Int {
		switch self {
		case .input:
			return 1
		case .adjustments:
			return 3
		}
	}
	
	subscript(_ index: Int) -> CellIdentifier {
		switch self {
		case .input:
			switch index {
			case 0:
				return .inputColor
			default:
				fatalError("Unknown index \(index) in section \(self)")
			}
		case .adjustments:
			switch index {
			case 0:
				return .lighten
			case 1:
				return .darken
			case 2:
				return .desaturate
			default:
				fatalError("Unknown index \(index) in section \(self)")
			}
		}
	}
}

private enum CellIdentifier : String {
	case inputColor
	case lighten
	case darken
	case desaturate
	
	static let all: [CellIdentifier] = [
		.inputColor,
		.lighten,
		.darken,
		.desaturate
	]
	
	enum ElementKey : String {
		case label
		case amount
		case colorPreview
	}
	
	func render(item: AdjustItem) -> [CellProp<AdjustMsg>] {
		switch self {
		case .inputColor:
			return [
				.backgroundColor(UIColor(cgColor: item.inputColorValue.cgColor!)),
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
		
		self.tableView.insetsContentViewsToSafeArea = false
		self.tableView.contentInsetAdjustmentBehavior = .never
		
		self.tableAssistant = TableAssistant<Model, AdjustItem, AdjustMsg>(tableView: self.tableView, initial: Model(), update: update)
		
		self.themeUp()
		
		tableView.allowsSelection = false
		tableView.rowHeight = 88.0
		tableView.separatorStyle = .none
		
		for cellIdentifier in CellIdentifier.all {
			tableAssistant.registerCells(reuseIdentifier: cellIdentifier, render: cellIdentifier.render, layout: cellIdentifier.layout, tableView: self.tableView)
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
