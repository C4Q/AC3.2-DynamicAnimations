//
//  ViewController.swift
//  DynamicAnimations
//
//  Created by Louis Tur on 1/26/17.
//  Copyright © 2017 AccessCode. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
  
  var dynamicAnimator: UIDynamicAnimator? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    setupViewHierarchy()
    configureConstraints()
    
    self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
//    let gravityBehavior = UIGravityBehavior(items: [blueView])
//    gravityBehavior.angle = CGFloat.pi / 6.0
//    gravityBehavior.magnitude = 0.2
//    self.dynamicAnimator?.addBehavior(gravityBehavior)
//
//    let collisionBehavior = UICollisionBehavior(items: [blueView])
//    collisionBehavior.translatesReferenceBoundsIntoBoundary = true
//    self.dynamicAnimator?.addBehavior(collisionBehavior)
//    
//    let elasticBehavior = UIDynamicItemBehavior(items: [blueView])
//    elasticBehavior.elasticity = 0.5
//    self.dynamicAnimator?.addBehavior(elasticBehavior)

    let bouncyBehavior = BouncyViewBehavior(items: [blueView, redView, snapButton, deSnapButton])
    self.dynamicAnimator?.addBehavior(bouncyBehavior)
    
    let barrierBehavior = UICollisionBehavior(items: [redView])
    greenView.isHidden = true
    barrierBehavior.addBoundary(withIdentifier: "Barrier" as NSString,
      from: CGPoint(x: greenView.frame.minX, y: greenView.frame.minY),
      to: CGPoint(x: greenView.frame.maxX, y: greenView.frame.minY))
    
    self.dynamicAnimator?.addBehavior(barrierBehavior)
  }
  
  private func configureConstraints() {
    self.edgesForExtendedLayout = []
    
    blueView.snp.makeConstraints { (view) in
      view.top.centerX.equalToSuperview()
      view.size.equalTo(CGSize(width: 100, height: 100))
    }
    
    redView.snp.makeConstraints { (view) in
      view.top.leading.equalToSuperview()
      view.size.equalTo(CGSize(width: 100, height: 100))
    }
    
    snapButton.snp.makeConstraints { (view) in
      view.centerX.equalToSuperview()
      view.bottom.equalToSuperview().inset(50.0)
    }
    
    deSnapButton.snp.makeConstraints { (view) in
      view.centerX.equalToSuperview()
      view.top.equalTo(snapButton.snp.bottom).offset(8.0)
    }
    
    greenView.snp.makeConstraints { (view) in
      view.leading.trailing.centerY.equalToSuperview()
      view.height.equalTo(20.0)
    }
  }
  
  private func setupViewHierarchy() {
    self.view.addSubview(blueView)
    self.view.addSubview(redView)
    self.view.addSubview(greenView)
    
    self.view.addSubview(snapButton)
    self.view.addSubview(deSnapButton)
    
    self.snapButton.addTarget(self, action: #selector(snapToCenter), for: .touchUpInside)
    self.deSnapButton.addTarget(self, action: #selector(deSnapFromCenter), for: .touchUpInside)
  }
  
  
  internal func snapToCenter() {
    let snappingBehavior = UISnapBehavior(item: blueView, snapTo: self.view.center)
    snappingBehavior.damping = 1.0
    self.dynamicAnimator?.addBehavior(snappingBehavior)
  }
  
  internal func deSnapFromCenter() {
    
    // what to do... what. to. do?
    
    let _ = dynamicAnimator?.behaviors.map {
      if $0 is UISnapBehavior {
        self.dynamicAnimator?.removeBehavior($0)
      }
    }
    
  }
  
  // MARK: -
  internal lazy var blueView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = .blue
    return view
  }()
  
  internal lazy var redView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = .red
    return view
  }()
  
  internal lazy var greenView: UIView = {
    let view: UIView = UIView()
    view.backgroundColor = .green
    return view
  }()
  
  internal lazy var snapButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setTitle("SNAP!", for: .normal)
    return button
  }()
  
  internal lazy var deSnapButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.setTitle("(de)SNAP!", for: .normal)
    return button
  }()

}

class BouncyViewBehavior: UIDynamicBehavior {
  
  override init() {
  }
  
  convenience init(items: [UIDynamicItem]) {
    self.init()
    
    let gravityBehavior = UIGravityBehavior(items: items)
    //    gravityBehavior.angle = CGFloat.pi / 6.0
    gravityBehavior.magnitude = 0.2
    self.addChildBehavior(gravityBehavior)
    
    let collisionBehavior = UICollisionBehavior(items: items)
    collisionBehavior.translatesReferenceBoundsIntoBoundary = true
    self.addChildBehavior(collisionBehavior)
    
    let elasticBehavior = UIDynamicItemBehavior(items: items)
    elasticBehavior.elasticity = 0.5
    elasticBehavior.addAngularVelocity(CGFloat.pi / 6.0, for: items.first!)
    self.addChildBehavior(elasticBehavior)
  }
}

