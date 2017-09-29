//
//  Extensions.swift
//  ReorderableGridView
//
//  Created by Hongfei Zhang on 9/28/17.
//  Copyright © 2017 Happy Guy. All rights reserved.
//

import UIKit

extension UIColor {
	
	static func randomColor () -> UIColor {
		let randomR: CGFloat = CGFloat(drand48())
		let randomG: CGFloat = CGFloat(drand48())
		let randomB: CGFloat = CGFloat(drand48())
		return UIColor(red: randomR, green: randomG, blue: randomB, alpha: 1.0)
	}
	
	static func RGBColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
		return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
	}
	
	static func RGBAColor (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
		return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
	}
	
}

extension UIFont {
	
	enum FontType: String {
		case Regular = "Regular"
		case Bold = "Bold"
		case Light = "Light"
		case UltraLight = "UltraLight"
		case Italic = "Italic"
		case Thin = "Thin"
	}
	
	enum FontName: String {
		case HelveticaNeue = "HelveticaNeue"
		case Helvetica = "Helvetica"
		case Futura = "Futura"
		case Menlo = "Menlo"
	}
	
	class func Font(name: FontName, type: FontType, size: CGFloat) -> UIFont {
		return UIFont(name: name.rawValue + "-" + type.rawValue, size: size)!
	}
	
	class func HelveticaNeue(type: FontType, size: CGFloat) -> UIFont {
		return Font(name: .HelveticaNeue, type: type, size: size)
	}
	
}

extension UIView {
	
	// MARK: Frame Extensions
	
	var x: CGFloat {
		return self.frame.origin.x
	}
	
	var y: CGFloat {
		return self.frame.origin.y
	}
	
	var w: CGFloat {
		return self.frame.size.width
	}
	
	var h: CGFloat {
		return self.frame.size.height
	}
	
	
	var left: CGFloat {
		return self.x
	}
	
	var right: CGFloat {
		return self.x + self.w
	}
	
	var top: CGFloat {
		return self.y
	}
	
	var bottom: CGFloat {
		return self.y + self.h
	}
	
	func setX(x: CGFloat) {
		self.frame = CGRect(x: x, y: self.y, width: self.w, height: self.h)
	}
	
	func setY(y: CGFloat) {
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.frame = CGRect(x: self.x, y: y, width: self.w, height: self.h)
		})
	}
	
	func setX(x: CGFloat, y: CGFloat) {
		self.frame = CGRect(x: x, y: y, width: self.w, height: self.h)
	}
	
	
	func setW(w: CGFloat) {
		self.frame = CGRect(x: self.x, y: self.y, width: w, height: self.h)
	}
	
	func setH(h: CGFloat) {
		self.frame = CGRect(x: self.x, y: self.y, width: self.w, height: h)
	}
	
	func setW(w: CGFloat, h: CGFloat) {
		self.frame = CGRect(x: self.x, y: self.y, width: w, height: h)
	}
	
	func setSize(size: CGSize) {
		self.frame = CGRect(x: self.x, y: self.y, width: size.width, height: size.height)
	}
	
	func setPosition(position: CGPoint) {
		if (frame.origin == position) {
			return
		}
		
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.frame = CGRect(x: position.x, y: position.y, width: self.w, height: self.h)
		})
	}
	
	func leftWithOffset(offset: CGFloat) -> CGFloat {
		return self.left - offset
	}
	
	func rightWithOffset(offset: CGFloat) -> CGFloat {
		return self.right + offset
	}
	
	func topWithOffset(offset: CGFloat) -> CGFloat {
		return self.top - offset
	}
	
	func botttomWithOffset(offset: CGFloat) -> CGFloat {
		return self.bottom + offset
	}
	
	func setScale(x: CGFloat, y: CGFloat, z: CGFloat) {
		// Returns an affine transformation matrix constructed from scaling values you provide.
		self.transform = CGAffineTransform(scaleX: x, y: y)
	}
	
	convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
		self.init(frame: CGRect(x: x, y: y, width: w, height: h))
	}
	
}
