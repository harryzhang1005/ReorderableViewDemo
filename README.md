# Reorder a View

Reorderable grid view solution implemented with Swift 4. <br>

It's UIScrollView subclass, not a collection view layout.<br>

It automatically sets horizontal item spacing by item widths. so items must be fixed-width.<br>
It also sets automatically its scroll view content size. <br>

If you call `gridView?.invalidateLayout()` after orientation changed, it will lays out the grid by new orientation.

```swift
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
  gridView?.setW(w: size.width, h: size.height)
  gridView?.invalidateLayout()
}
```

# Demo

![alt tag](reorder-view-demo.gif)

Happy coding :+1:  :sparkles:
