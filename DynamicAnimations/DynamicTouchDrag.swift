//
//  DynamicTouchDrag.swift
//  DynamicAnimations
//
//  Created by Louis Tur on 1/26/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import UIKit
import SnapKit

// Stage 4 ensures that only tapping inside of the bounds of the view will cause the animations to happen
class TouchAnimatorViewController: UIViewController {
  
  var animator: UIViewPropertyAnimator? = nil
  let squareSize = CGSize(width: 100.0, height: 100.0)
  var viewIsCurrentlyHeld: Bool = false
  
  var dynamicAnimator: UIDynamicAnimator? = nil
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViewHierarchy()
    configureConstraints()
    
    self.dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    let collisionBehavior = UICollisionBehavior(items: [darkBlueView])
    collisionBehavior.translatesReferenceBoundsIntoBoundary = true
    dynamicAnimator?.addBehavior(collisionBehavior)
    
    let gravityBehavior = UIGravityBehavior(items: [darkBlueView])
    gravityBehavior.angle = CGFloat.pi / 2.0
    dynamicAnimator?.addBehavior(gravityBehavior)
  }
  
  
  // MARK: - Setup
  private func configureConstraints() {
    darkBlueView.snp.makeConstraints{ view in
      view.center.equalToSuperview()
      view.size.equalTo(squareSize)
    }
  }
  
  private func setupViewHierarchy() {
    self.view.backgroundColor = .white
    self.view.isUserInteractionEnabled = true
    
    view.addSubview(darkBlueView)
  }
  
  
  // MARK: - Movement
  internal func move(view: UIView, to point: CGPoint) {
    //    if animator!.isRunning {
    //      animator?.addAnimations {
    //        self.view.layoutIfNeeded()
    //      }
    //    }
    
    let _ = self.dynamicAnimator?.behaviors.map {
      if $0 is UISnapBehavior {
        self.dynamicAnimator?.removeBehavior($0)
      }
    }
    
    let snapBehavior = UISnapBehavior(item: view, snapTo: point)
    self.dynamicAnimator?.addBehavior(snapBehavior)
    
    //    view.snp.remakeConstraints { (view) in
    //      view.center.equalTo(point)
    //      view.size.equalTo(squareSize)
    //    }
    
  }
  
  internal func pickUp(view: UIView) {
    animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: {
      view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    })
    
    animator?.startAnimation()
  }
  
  internal func putDown(view: UIView) {
    let _ = self.dynamicAnimator?.behaviors.map {
      if $0 is UISnapBehavior {
        self.dynamicAnimator?.removeBehavior($0)
      }
    }
    
    animator = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn, animations: {
      view.transform = CGAffineTransform.identity
    })
    
    animator?.startAnimation()
  }
  
  internal func addGravity(to view: UIView) {
    let collisionBehavior = UICollisionBehavior(items: [darkBlueView])
    collisionBehavior.translatesReferenceBoundsIntoBoundary = true
    dynamicAnimator?.addBehavior(collisionBehavior)
    
    let gravityBehavior = UIGravityBehavior(items: [darkBlueView])
    gravityBehavior.angle = CGFloat.pi / 2.0
    dynamicAnimator?.addBehavior(gravityBehavior)
  }
  
  
  // MARK: - Tracking Touches
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let touchWasInsideOfDarkBlueView = darkBlueView.frame.contains(touch.location(in: view))
    
    if touchWasInsideOfDarkBlueView {
      print("Touch detected in blue view")
      pickUp(view: darkBlueView)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    putDown(view: darkBlueView)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    // note: this example is buggy because touchesMoved will allow the view to snap into place even
    // if the initial touch event was not in the bounds of the blue view
    move(view: darkBlueView, to: touch.location(in: view))
  }
  
  
  // MARK: - Views
  internal lazy var darkBlueView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = .blue
    return view
  }()
}
