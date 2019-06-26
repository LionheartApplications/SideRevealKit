//
//  TouchContentScrollView.swift
//  SideRevealCollectionViewTest
//
//  Created by Stoyan Stoyanov on 25/06/2019.
//  Copyright © 2019 Lionheart Applications. All rights reserved.
//

import UIKit

// MARK: - Class Definition

/// `UIScrollView` subclass that captures only the touches that are over its content and not in the insert area.
final class TouchContentScrollView: UIScrollView {
    
    /// Specific area of the content view in which the touches will be allowed.
    var contentTouchArea: CGRect?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        // Makes the scroll view discard any touch outside of its content view
        // so `contentInset` area passes the touches up the responder chain
        
        var containsTouch = false
        subviews.forEach { (contentView) in
            guard contentView.bounds.contains(point) else { return }
            containsTouch = true
        }
        
        return containsTouch ? super.hitTest(point, with: event) : nil
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // disables the pan gesture recognizer of this scroll view
        // if it is touched in places other that the top slide handle
        
        guard gestureRecognizer.numberOfTouches == 1 else { return false }
        let point = gestureRecognizer.location(ofTouch: 0, in: self)
        
        var containsTouch = false
        subviews.forEach { [weak self] (contentView) in
            
            if let contentTouchArea = self?.contentTouchArea {
                guard contentTouchArea.contains(point) else { return }
                containsTouch = true
            } else {
                guard contentView.bounds.contains(point) else { return }
                containsTouch = true
            }
        }
        
        return containsTouch
    }
}
