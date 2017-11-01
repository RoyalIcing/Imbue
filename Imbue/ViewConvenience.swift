//
//  ViewConvenience.swift
//  Imbue
//
//  Created by Patrick Smith on 10/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit


func heightIntersecting(keyboardFrame: CGRect, withView view: UIView, layoutGuide: UILayoutGuide) -> CGFloat {
	let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
	let intersection = layoutGuide.layoutFrame.intersection(keyboardFrameInView)
	return intersection.height
}

extension UIView {
	func animateFor(keyboardNotification: Notification, useKeyboardEndFrame: (CGRect) -> ()) {
		guard
			let info = keyboardNotification.userInfo,
			let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect,
			let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
			let animationCurveInt = info[UIKeyboardAnimationCurveUserInfoKey] as? Int, //UIViewAnimationCurve
			let animationCurve = UIViewAnimationCurve(rawValue: animationCurveInt)
			else { return }
		
		useKeyboardEndFrame(keyboardFrame)
		
		UIView.beginAnimations("keyboard", context: nil)
		UIView.setAnimationDuration(duration)
		UIView.setAnimationCurve(animationCurve)
		self.layoutIfNeeded()
		UIView.commitAnimations()
	}
}

enum ViewConvenience {
	static func observeKeyboardNotifications(viewController: UIViewController, constraint: NSLayoutConstraint, valueWhenHidden: CGFloat) -> [Any] {
		let nc = NotificationCenter.default
		return [
			nc.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { [weak viewController] note in
				guard let viewController = viewController else { return }
				let view = viewController.view!
				view.animateFor(keyboardNotification: note, useKeyboardEndFrame: { keyboardFrame in
					if #available(iOS 11.0, *) {
						let insetHeight = heightIntersecting(keyboardFrame: keyboardFrame, withView: view, layoutGuide: view.safeAreaLayoutGuide)
						
						viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: insetHeight, right: 0)
					}
					else {
						constraint.constant = keyboardFrame.height
						view.setNeedsUpdateConstraints()
					}
				})
			},
			nc.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { [weak viewController] note in
				guard let viewController = viewController else { return }
				let view = viewController.view!
				
				view.animateFor(keyboardNotification: note, useKeyboardEndFrame: { keyboardFrame in
					if #available(iOS 11.0, *) {
						viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
					}
					else {
						constraint.constant = valueWhenHidden
						view.setNeedsUpdateConstraints()
					}
				})
			}
		]
	}

}
