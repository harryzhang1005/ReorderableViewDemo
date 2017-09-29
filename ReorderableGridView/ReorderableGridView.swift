//
//  ReorderableGridView.swift
//  ReorderableGridView
//
//  Created by Harvey Zhang on 19/11/14.
//  Copyright (c) 2017 Happy Guy. All rights reserved.
//

import UIKit

protocol Reorderable {
    func didReorderStartedForView(view: ReorderableView)
    func didReorderedView(view: ReorderableView, pan: UIPanGestureRecognizer)
    func didReorderEndForView(view: ReorderableView, pan: UIPanGestureRecognizer)
}

protocol Draggable {
    func didDragStartedForView(ReorderableGridView: ReorderableGridView, view: ReorderableView)
    func didDraggedView(ReorderableGridView: ReorderableGridView, view: ReorderableView)
    func didDragEndForView(ReorderableGridView: ReorderableGridView, view: ReorderableView)
}

func == (lhs: GridPosition, rhs: GridPosition) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}

struct GridPosition: Equatable {
	
    var x: Int? = 0
    var y: Int? = 0
	
	// MARK: - Position
	
    func col() -> Int { return x! }
    func row() -> Int { return y! }
	
    func arrayIndex(colsInRow: Int) -> Int {
        let index = row()*colsInRow + col()
        return index
    }
	
	// MARK: - four directions
	
    func up() -> GridPosition? {
        if y! <= 0 {
            return nil
        } else {
            return GridPosition(x: x!, y: y!-1)
        }
    }
    
    func down() -> GridPosition {
        return GridPosition(x: x!, y: y!+1)
    }

    func left() -> GridPosition? {
        if x! <= 0 {
            return nil
        } else {
            return GridPosition (x: x!-1, y: y!)
        }
    }
    
    func right() -> GridPosition {
        return GridPosition (x: x!+1, y: y!)
    }
	
	// MARK: - Description
	
    func string() -> String { return "\(x!), \(y!)" }
    func detailedString() -> String { return "x: \(x!), y: \(y!)" }
}

struct Constants {
	static let kItemWidth: CGFloat = 180
	static let kItemsVerticalPadding: CGFloat = 20
	static let kItemBaseHeight: CGFloat = 100
	static let kItemTopViewHeight: CGFloat = 50
	static let kItemBottomViewHeight: CGFloat = 5
}

// Customize reorderable view
class ReorderableView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var delegate: Reorderable! = nil
    var pan: UIPanGestureRecognizer?
    var gridPosition: GridPosition?
    
	let animationDuration: TimeInterval = 0.25
    let reorderModeScale: CGFloat = 1.2
    let reorderModeAlpha: CGFloat = 0.6
    
    var isReordering: Bool = false {
        didSet {
            if isReordering {
                startReorderMode()
            } else {
                endReorderMode()
            }
        }
    }
	
    // MARK: - Lifecycle
	
	// Declarations from extensions cannot be overridden yet -- already done in UIView extension
//	convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
//        self.init(frame: CGRect (x: x, y: y, width: w, height: h))
//    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(gesture:)))
        doubleTap.numberOfTapsRequired = 1
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.delegate = self
        self.addGestureRecognizer(doubleTap)
		
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(gesture:)))
        longPress.numberOfTouchesRequired = 1
        longPress.delegate = self
        self.addGestureRecognizer(longPress)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
    // MARK: - Reorder Animations
    
    func startReorderMode() {
        addPan()
        
		superview?.bringSubview(toFront: self)

		UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.alpha = self.reorderModeAlpha
			self.setScale(x: self.reorderModeScale, y: self.reorderModeScale, z: self.reorderModeScale)
        })
    }
    
    func endReorderMode() {
		UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.alpha = 1
			self.setScale(x: 1, y: 1, z: 1)
        }) { finished -> Void in
            self.removePan()
        }
    }
	
    // MARK: - Gestures
    
    func addPan() {
		pan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        self.addGestureRecognizer(pan!)
    }
    
    func removePan() {
        self.removeGestureRecognizer(pan!)
    }
	
	@objc func longPressed(gesture: UITapGestureRecognizer) {
        if isReordering { return } else { isReordering = true }
		delegate?.didReorderStartedForView(view: self)
    }
    
    @objc func doubleTapped(gesture: UITapGestureRecognizer) {
        isReordering = !isReordering
        
        if isReordering {
			delegate?.didReorderStartedForView(view: self)
        }
    }
    
    @objc func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
		case .ended:
            isReordering = false
			delegate.didReorderEndForView(view: self, pan: pan!)
            
		case .changed:
			delegate.didReorderedView(view: self, pan: pan!)
        
        default:
            return
        }
    }
	
	// MARK: - UIGestureRecognizerDelegate
	
    // Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}

// Customize reorderable view container
class ReorderableGridView: UIScrollView, Reorderable {
	
    // MARK: - Properties
    
    var itemWidth: CGFloat?
    var verticalPadding: CGFloat?
    var horizontalPadding: CGFloat?
    var colsInRow: Int?	// items/each-row
	
	var visibleRect: CGRect?
	
    var reorderable: Bool = true
    var draggable: Bool = true
    
    var draggableDelegate: Draggable?
    
    var reorderableViews: [ReorderableView] = []
	
    // MARK: - Observers
    
    var currentCol: Int = 0 {
        didSet {
            if currentCol > colsInRow!-1 {
                currentCol = 0
                currentRow += 1
            }
			else if currentCol < 0 {
                currentCol = colsInRow!-1
                currentRow -= 1
            }
        }
    }
    
    var currentRow: Int = 0 {
        didSet {
            if currentRow < 0 {
                currentRow = 0
            }
        }
    }

    override var contentOffset: CGPoint {
        didSet {
            visibleRect? = CGRect(origin: contentOffset, size: frame.size)
            checkReusableViewsInVisibleRect()
        }
    }
	
    // MARK: - Lifecycle
    
    init(frame: CGRect, itemWidth: CGFloat, verticalPadding: CGFloat = 10) {
        super.init(frame: frame)
		
        self.itemWidth = itemWidth
        self.verticalPadding = verticalPadding
        self.visibleRect = frame
        
        invalidateLayout()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
    // MARK: - ScrollView
    
    func setContentHeight(height: CGFloat) {
        contentSize = CGSize(width: w, height: height)
    }
    
    func addContentHeight(height: CGFloat) {
		setContentHeight(height: contentSize.height + height)
    }

    func isViewInVisibleRect(view: ReorderableView) -> Bool {
        if let rect = visibleRect {
			return view.frame.intersects(rect)
        } else {
            return false
        }
    }
    
    func checkReusableViewsInVisibleRect() {
        for aView in reorderableViews {
			if isViewInVisibleRect(view: aView) {
                if let superView = aView.superview { // is already added to view stack
                    if superView == self { // already added
                        continue
                    } else {
                        // FIXME: another view is super !
                        continue
                    }
                }
				else { // add it to superview
                    if let gridPos = aView.gridPosition {
                        addSubview(aView)	// add it to superview
						placeView(view: aView, toGridPosition: gridPos)
                    } else { // not initilized yet
                        continue
                    }
                }
            }
			else { // should removed
                if let superView = aView.superview { // is already alled to view hierarchy
                    if superView == self {
                        aView.removeFromSuperview()	// remove
                    } else {
                        // FIXME: another view is super !
                        continue
                    }
                } else {
					// already removed
                    continue
                }
            }
        }//for-loop
    }
	
    // MARK: - Layout
    
    func invalidateLayout() {
        colsInRow = Int(self.w / itemWidth!)
        horizontalPadding = (self.w - (CGFloat(colsInRow!) * itemWidth!)) / (CGFloat(colsInRow!) - 1)
        contentSize.height = contentOffset.y + h
        
        currentCol = 0
        currentRow = 0

        if reorderableViews.isEmpty {
            return
        }
        
        for i in 0...reorderableViews.count-1 {
            let y = currentRow
			let x = currentCol; currentCol += 1
            let gridPosition = GridPosition(x: x, y: y)
			placeView(view: reorderableViews[i], toGridPosition: gridPosition)
        }
    }
    
    func placeView(view: ReorderableView, toGridPosition: GridPosition) {
        view.gridPosition = toGridPosition
        view.delegate = self	// reorderable delegate
        
		let pos = gridPositionToViewPosition(gridPosition: toGridPosition)
		view.setPosition(position: pos)
        
		let height = view.botttomWithOffset(offset: verticalPadding!)
		
        if height > contentSize.height {
			setContentHeight(height: height)
        }
    }
    
    func insertViewAtPosition(view: ReorderableView, position: GridPosition) {
        if (view.gridPosition == position) {
            return
        }

		reorderableViews.remove(at: view.gridPosition!.arrayIndex(colsInRow: colsInRow!))
		reorderableViews.insert(view, at: position.arrayIndex(colsInRow: colsInRow!))
        invalidateLayout()
    }
	
    // MARK: - Grid
    
    func gridPositionToViewPosition(gridPosition: GridPosition) -> CGPoint {
		
		let x: CGFloat = (CGFloat(gridPosition.x! - 1) * (itemWidth! + verticalPadding!)) + itemWidth!
        var y: CGFloat = 0
        
        if let up = gridPosition.up() {
			y = viewAtGridPosition(gridPosition: up)!.bottom + verticalPadding!
        }
        
        return CGPoint(x: x, y: y)
    }
    
    func viewAtGridPosition(gridPosition: GridPosition) -> ReorderableView? {
		let index = gridPosition.arrayIndex(colsInRow: colsInRow!)
        if (index < reorderableViews.count) {
            return reorderableViews[index]
        } else {
            return nil
        }
    }
	
    // MARK: - Adding and Removing
    
    func addReorderableView(view: ReorderableView) {
        super.addSubview(view)
		
        reorderableViews.append(view)
        invalidateLayout()
    }
    
    func addReorderableView(view: ReorderableView, gridPosition: GridPosition) {
        super.addSubview(view)
        
		var addingIndex = gridPosition.arrayIndex(colsInRow: colsInRow!)
        if addingIndex >= reorderableViews.count {
            addingIndex = reorderableViews.count
        }
        
		reorderableViews.insert(view, at: addingIndex)
        invalidateLayout()
    }
    
    func removeReorderableViewAtGridPosition(gridPosition: GridPosition) {
		if let view = viewAtGridPosition(gridPosition: gridPosition) {
			reorderableViews.remove(at: gridPosition.arrayIndex(colsInRow: colsInRow!))
            
            view.removeFromSuperview()
            invalidateLayout()
        }
    }
    
    func removeReorderableView(view: ReorderableView) {
        if let pos = view.gridPosition {
			removeReorderableViewAtGridPosition(gridPosition: pos)
        } else {
            print("view is not in grid hierarchy")
        }
    }
	
    // MARK: - Reorderable methods
    
    func didReorderStartedForView(view: ReorderableView) {
		draggableDelegate?.didDragStartedForView(ReorderableGridView: self, view: view)
    }

    func didReorderedView(view: ReorderableView, pan: UIPanGestureRecognizer) {
    
        if !draggable {
            return
        } else {
			draggableDelegate?.didDraggedView(ReorderableGridView: self, view: view)
        }
        
		let location = pan.location(in: self)
        view.center = location

        if !reorderable {
            return
        }
        
        let col: Int = min(Int(location.x) / Int(itemWidth! + horizontalPadding!), colsInRow!-1)
		let _ : Int = reorderableViews.count/colsInRow!
        
        var gridPos = GridPosition(x: col, y: 0)
		
		for row in 0..<reorderableViews.count/colsInRow! {
            gridPos.y = row
            
			if let otherView = viewAtGridPosition(gridPosition: gridPos) {
                if otherView == view {
                    continue
                }
                
				if otherView.frame.contains(location) {
                    //println("im at \(col), \(row), im " + view.gridPosition!.string())
					insertViewAtPosition(view: view, position: gridPos)
                }
            }
        }
		
    }
    
    func didReorderEndForView (view: ReorderableView, pan: UIPanGestureRecognizer) {
        if reorderable {
            invalidateLayout()
        }
        
        if draggable {
			draggableDelegate?.didDragEndForView(ReorderableGridView: self, view: view)
        }
    }
	
}
