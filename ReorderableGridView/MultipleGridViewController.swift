//
//  MultipleGridViewController.swift
//  ReorderableGridView
//
//  Created by Harvey Zhang on 21/11/14.
//  Copyright (c) 2017 Happy Guy. All rights reserved.
//

import UIKit

class MultipleGridViewController: UIViewController, Draggable {

    // MARK: - Properties
	
    @IBOutlet var selectedItemsGridContainerView: UIView!	// hard-coded container view width = 234
    @IBOutlet var itemsGridContainerView: UIView!			// the rest of view's width
    
    var selectedItemsGrid: ReorderableGridView?	// how many items does user select
	
    var itemsGrid: ReorderableGridView?
    var itemCount: Int = 0				// how many items does the itemsGrid view contains
	
	var bgColor: UIColor?
    var borderColor: UIColor?
    var bottomColor: UIColor?
	
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		bgColor = UIColor.RGBColor(r: 242, g: 242, b: 242)
		borderColor = UIColor.RGBColor(r: 233, g: 233, b: 233)
		bottomColor = UIColor.RGBColor(r: 65, g: 65, b: 65)
        
        self.title = "Multiple Grid"
        self.navigationItem.title = "Multiple Grid View Demo"
        self.view.backgroundColor = bgColor
        
        selectedItemsGrid = ReorderableGridView(frame: selectedItemsGridContainerView.bounds, itemWidth: Constants.kItemWidth)
        selectedItemsGrid?.draggableDelegate = self
        selectedItemsGrid?.reorderable = false
        selectedItemsGrid?.clipsToBounds = false
        selectedItemsGridContainerView.addSubview(selectedItemsGrid!)

        itemsGrid = ReorderableGridView(frame: itemsGridContainerView.bounds, itemWidth: Constants.kItemWidth)
        itemsGrid?.draggableDelegate = self
        itemsGrid?.reorderable = false
		itemsGrid?.clipsToBounds = false
        itemsGridContainerView.addSubview(itemsGrid!)
        
        for _ in 0..<20 {
			itemsGrid?.addReorderableView(view: itemView())
        }
    }
    
	override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let grid = itemsGrid {
            grid.frame = itemsGridContainerView.bounds
            grid.invalidateLayout()
        }
        
        if let grid = selectedItemsGrid {
            grid.frame = selectedItemsGridContainerView.bounds
            grid.invalidateLayout()
        }
    }
    
    fileprivate func itemView() -> ReorderableView {
        let w: CGFloat = Constants.kItemWidth
        let h: CGFloat = Constants.kItemBaseHeight + CGFloat(arc4random()%100)
        
        let view = ReorderableView(x: 0, y: 0, w: w, h: h)
		view.tag = itemCount; itemCount += 1
		view.layer.borderColor = borderColor?.cgColor
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        let topView = UIView(x: 0, y: 0, w: view.w, h: Constants.kItemTopViewHeight)
        view.addSubview(topView)
        
        let itemLabel = UILabel(frame: topView.frame)
        itemLabel.center = topView.center
		itemLabel.font = UIFont.HelveticaNeue(type: .Thin, size: 20)
		itemLabel.textAlignment = NSTextAlignment.center
        itemLabel.textColor = bottomColor
        itemLabel.text = "\(view.tag)"
        itemLabel.layer.masksToBounds = true
        topView.addSubview(itemLabel)
        
        let separateLineLayer = CALayer()
        separateLineLayer.frame = CGRect(x: 0, y: topView.bottom, width: topView.w, height: 1)
		separateLineLayer.backgroundColor = borderColor?.cgColor
        topView.layer.addSublayer(separateLineLayer)
        
        let bottomView = UIView(frame: CGRect(x: 0, y: topView.bottom, width: view.w, height: view.h-topView.h))
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: (bottomView.h - Constants.kItemBottomViewHeight),
                                   width: bottomView.w, height: Constants.kItemBottomViewHeight)
		bottomLayer.backgroundColor = bottomColor?.cgColor
        bottomView.layer.addSublayer(bottomLayer)
        bottomView.layer.masksToBounds = true
        view.addSubview(bottomView)
        
        return view
    }
	
    // MARK: - Draggable methods
    
	func didDragStartedForView(ReorderableGridView reorderableGridView: ReorderableGridView, view: ReorderableView) {
        
    }
    
	func didDraggedView(ReorderableGridView reorderableGridView: ReorderableGridView, view: ReorderableView) {
        
    }
    
	func didDragEndForView(ReorderableGridView reorderableGridView: ReorderableGridView, view: ReorderableView) {
		
        if (reorderableGridView == itemsGrid!) { // drag items grid to selected items grid
			let convertedPos: CGPoint = self.view.convert(view.center, from: itemsGridContainerView)
			if (selectedItemsGridContainerView.frame.contains(convertedPos)) {
				itemsGrid?.removeReorderableView(view: view)
				selectedItemsGrid?.addReorderableView(view: view)
            } else {
                reorderableGridView.invalidateLayout()
            }
        }
        else if (reorderableGridView == selectedItemsGrid!) { // selected items grid to items grid
			let convertedPos: CGPoint = self.view.convert(view.center, from: selectedItemsGridContainerView)
			if (itemsGridContainerView.frame.contains(convertedPos)) {
				selectedItemsGrid?.removeReorderableView(view: view)
				itemsGrid?.addReorderableView(view: view)
            } else {
                reorderableGridView.invalidateLayout()
            }
        }
    }

    // MARK: - Interface Rotation
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		selectedItemsGrid?.frame = selectedItemsGridContainerView.bounds
		itemsGrid?.frame = itemsGridContainerView.bounds
		
		selectedItemsGrid?.invalidateLayout()
		itemsGrid?.invalidateLayout()
	}

}
