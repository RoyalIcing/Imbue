//
//  ViewConvenience.swift
//  Imbue
//
//  Created by Patrick Smith on 10/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit


extension UIViewController {
	fileprivate func animateForKeyboardChange(constraint: NSLayoutConstraint, height: CGFloat, duration: TimeInterval, curve: UIViewAnimationCurve) {
		constraint.constant = height
		view.setNeedsUpdateConstraints()
		
		UIView.beginAnimations("keyboard", context: nil)
		UIView.setAnimationDuration(duration)
		UIView.setAnimationCurve(curve)
		view.layoutIfNeeded()
		UIView.commitAnimations()
	}
}

enum ViewConvenience {
	static func observeKeyboardNotifications(viewController: UIViewController, constraint: NSLayoutConstraint, valueWhenHidden: CGFloat) -> [Any] {
		let nc = NotificationCenter.default
		return [
			nc.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { [weak viewController] note in
				guard let viewController = viewController else { return }
				guard
					let info = note.userInfo,
					let keyboardRect = info[UIKeyboardFrameEndUserInfoKey] as? CGRect,
					let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
					let animationCurveInt = info[UIKeyboardAnimationCurveUserInfoKey] as? Int, //UIViewAnimationCurve
					let animationCurve = UIViewAnimationCurve(rawValue: animationCurveInt)
					else { return }
				
				viewController.animateForKeyboardChange(constraint: constraint, height: keyboardRect.height, duration: duration, curve: animationCurve)
			},
			nc.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { [weak viewController] note in
				guard let viewController = viewController else { return }
				guard
					let info = note.userInfo,
					let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
					let animationCurveInt = info[UIKeyboardAnimationCurveUserInfoKey] as? Int, //UIViewAnimationCurve
					let animationCurve = UIViewAnimationCurve(rawValue: animationCurveInt)
					else { return }
				
				viewController.animateForKeyboardChange(constraint: constraint, height: valueWhenHidden, duration: duration, curve: animationCurve)
			}
		]
	}

}
