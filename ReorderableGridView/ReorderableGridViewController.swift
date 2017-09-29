//
//  ViewController.swift
//  ReorderableGridView
//
//  Created by Harvey Zhang on 19/11/14.
//  Copyright (c) 2017 Happy Guy. All rights reserved.
//

import UIKit

class ReorderableGridViewController: UIViewController {

    // MARK: - Properties
	
	var bgColor: UIColor?
    var borderColor: UIColor?
    var bottomColor: UIColor?
    
    var gridView : ReorderableGridView?	// items' container view
    var itemCount: Int = 0				// how many items does the grid view contain

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		bgColor = UIColor.RGBColor(r: 242, g: 242, b: 242)
		borderColor = UIColor.RGBColor(r: 233, g: 233, b: 233)
		bottomColor = UIColor.RGBColor(r: 65, g: 65, b: 65)
		
		// If the view controller has a valid navigation item or tab-bar item, assigning a value to this property updates the title text of those objects.
        self.title = "Reorderable Grid"
        self.navigationItem.title = "Reorderable Grid View Demo"	// if no this line, default use self.title
        self.view.backgroundColor = bgColor
        
        setupGridView()
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
        if let grid = gridView {
            grid.invalidateLayout()
        }
    }
	
    // MARK: - Private helpers
	
    fileprivate func setupGridView() {
		let add = UIBarButtonItem (barButtonSystemItem: UIBarButtonSystemItem.add,
		                           target: self, action: #selector(addPressed(sender:)))
		let remove = UIBarButtonItem (barButtonSystemItem: UIBarButtonSystemItem.trash,
		                              target: self, action: #selector(removePressed(sender:)))
        
        self.navigationItem.leftBarButtonItem = add
        self.navigationItem.rightBarButtonItem = remove
		
		// Here hard-coded item width and items vertical padding
        gridView = ReorderableGridView(frame: view.frame, itemWidth: Constants.kItemWidth, verticalPadding: Constants.kItemsVerticalPadding)
        view.addSubview(gridView!)
        
        for _ in 0..<55 {
			gridView!.addReorderableView(view: itemView())
        }
    }
	
	// generate a reorderable view
    fileprivate func itemView() -> ReorderableView {
        let w: CGFloat = Constants.kItemWidth
        let h: CGFloat = Constants.kItemBaseHeight + CGFloat(arc4random()%100)	// in the range of [100, 200)
		
		/// a reorderable view
        let aView = ReorderableView(x: 0, y: 0, w: w, h: h)
		aView.tag = itemCount; itemCount += 1
		aView.layer.borderColor = borderColor?.cgColor
		aView.layer.backgroundColor = UIColor.white.cgColor
        aView.layer.borderWidth = 1
        aView.layer.cornerRadius = 5
        aView.layer.masksToBounds = true
		
		/// top view
        let topView = UIView(x: 0, y: 0, w: aView.w, h: Constants.kItemTopViewHeight)
        aView.addSubview(topView)
		
        let itemLabel = UILabel(frame: topView.frame)	// label on the top view
        itemLabel.center = topView.center
		itemLabel.font = UIFont.HelveticaNeue(type: .Thin, size: 20)
		itemLabel.textAlignment = NSTextAlignment.center
        itemLabel.textColor = bottomColor
        itemLabel.text = "\(aView.tag)"
        itemLabel.layer.masksToBounds = true
        topView.addSubview(itemLabel)
        
        let separateLineLayer = CALayer()
        separateLineLayer.frame = CGRect(x: 0, y: topView.bottom, width: topView.w, height: 1)
		separateLineLayer.backgroundColor = borderColor?.cgColor
        topView.layer.addSublayer(separateLineLayer)
		
		/// bottom view
        let bottomView = UIView(frame: CGRect(x: 0, y: topView.bottom, width: aView.w, height: aView.h-topView.h))
		
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: (bottomView.h - Constants.kItemBottomViewHeight),
                                   width: bottomView.w, height: Constants.kItemBottomViewHeight)
		bottomLayer.backgroundColor = bottomColor?.cgColor
		
		bottomView.layer.addSublayer(bottomLayer)
        bottomView.layer.masksToBounds = true
        aView.addSubview(bottomView)
        
        return aView
    }

    // MARK: - Add/Remove callback
    
    @objc func addPressed(sender: AnyObject) {
		gridView?.addReorderableView(view: itemView(), gridPosition: GridPosition(x: 0, y: 0))
    }
    
    @objc func removePressed(sender: AnyObject) {
		gridView?.removeReorderableViewAtGridPosition(gridPosition: GridPosition(x: 0, y: 0))
    }
	
    // MARK: - Interface Rotation

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		gridView?.setW(w: size.width, h: size.height)
		gridView?.invalidateLayout()
	}
	
}
