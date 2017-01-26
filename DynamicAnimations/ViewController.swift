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
  
  // 1. You must have a "strong" reference to the dynamic animator. If you define one locally in a function, the animator
  //    will not work and it will look like nothing has happened.
  var dynamicAnimator: UIDynamicAnimator? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    setupViewHierarchy()
    configureConstraints()
    
    // 2. The reference view is used to give dynamic objects a defined coordinate space.
    self.dynamicAnimator = UIDynamicAnimator(referenceView: view)
  }
  
  
  // 3. Why is this code added in viewDidAppear instead of viewDidLoad?
  //
  //    The frames of views are not guaranteed to be set in viewDidLoad (and in fact, they aren't ever). But, in order
  //    to calculate something's (physics-based!) dynamics, it must have a defined size. A defined size allows the engine
  //    to have calculations run based on defaults (such as mass, elasticity, gravity, etc.).
  //    If you try to add dynamic behaviors to an item before its bounds are set, your app will crash.
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    
    // 3. Gravity behavior adds well, gravity to an item. By default a gravity behavior has a CGVector of (0.0, 1.0),
    //    meaning it has 0 movement in the x-axis and 1.0 in the y-axis. 1.0 is considered "standard" and is suppose to
    //    mimic earth's gravity
    //    let gravityBehavior = UIGravityBehavior(items: [blueView])
    
    //    A. Angle corresponds to the x-axis rotational movement, in radians.
    //    gravityBehavior.angle = CGFloat.pi / 6.0
    //    gravityBehavior.magnitude = 0.2
    
    //    B. All behaviors must be added to a UIDynamicAnimator object
    //    self.dynamicAnimator?.addBehavior(gravityBehavior)
    
    // 4. Collision adds "borders/edges" to your views so that they have a physical, 2D shape. The borders can be set to
    //    bounds of the UIDynamicItem, which in the case of a UIView is just its bounds.
    //    let collisionBehavior = UICollisionBehavior(items: [blueView])
    //    collisionBehavior.translatesReferenceBoundsIntoBoundary = true
    //    self.dynamicAnimator?.addBehavior(collisionBehavior)
    //  
    
    // 5. You can define a number of other properties for a UIDynamicItem through the parent behavior class,
    //    UIDynamicItemBehavior. One of those properties is an item's elasticity, or how much it will bounce when it
    //    interacts with another item.
    //    let elasticBehavior = UIDynamicItemBehavior(items: [blueView])
    //    elasticBehavior.elasticity = 0.5
    //    self.dynamicAnimator?.addBehavior(elasticBehavior)

    
    // 6. We can save ourselves a little bit of typing if we plan on having views with similar behaviors in a single
    //    animator. In this case, we create a UIDynamicBehavior subclass, named BounceyViewBehavior, that adds on 3
    //    different behaviors: gravity, collision, and elasticity (UIDynamicItemBehavior). Any UIDynamicItems can have
    //    these behaviors attached to them, including buttons.
    let bouncyBehavior = BouncyViewBehavior(items: [blueView, redView, snapButton, deSnapButton])
    self.dynamicAnimator?.addBehavior(bouncyBehavior)
    
    
    // 7. It is possible to setup "invisible" barriers by defining a collision behavior with a boundary. In this instance,
    //    we use a view (greenView) just to properly position the edges of a boundry by using the view's frame. We then
    //    make the view invisible and run the simulator. Because only the redview is given this behavior, it is the only one
    //    that interacts with the boundry... the blue view just keeps going and falls to the bottom of the screen.
    let barrierBehavior = UICollisionBehavior(items: [redView])
    //    greenView.isHidden = true // < -- uncomment to test
    barrierBehavior.addBoundary(withIdentifier: "Barrier" as NSString,
      from: CGPoint(x: greenView.frame.minX, y: greenView.frame.minY),
      to: CGPoint(x: greenView.frame.maxX, y: greenView.frame.minY))
    
    self.dynamicAnimator?.addBehavior(barrierBehavior)
  }
  
  private func configureConstraints() {
    self.edgesForExtendedLayout = []
    
    // blue view start in the upper middle
    blueView.snp.makeConstraints { (view) in
      view.top.centerX.equalToSuperview()
      view.size.equalTo(CGSize(width: 100, height: 100))
    }
    
    // red view starts in the upper left
    redView.snp.makeConstraints { (view) in
      view.top.leading.equalToSuperview()
      view.size.equalTo(CGSize(width: 100, height: 100))
    }
    
    // green view sits on the centerY
    greenView.snp.makeConstraints { (view) in
      view.leading.trailing.centerY.equalToSuperview()
      view.height.equalTo(20.0)
    }
  
    snapButton.snp.makeConstraints { (view) in
      view.centerX.equalToSuperview()
      view.bottom.equalToSuperview().inset(50.0)
    }
    
    deSnapButton.snp.makeConstraints { (view) in
      view.centerX.equalToSuperview()
      view.top.equalTo(snapButton.snp.bottom).offset(8.0)
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
    
    //    A snap behavior "snaps"/binds a UIDynamicItem to a specific point, and holds it there.
    //    The damping ratio determines how "springy" the snapping animation will be
    let snappingBehavior = UISnapBehavior(item: blueView, snapTo: self.view.center)
    snappingBehavior.damping = 1.0
    self.dynamicAnimator?.addBehavior(snappingBehavior)
  }
  
  internal func deSnapFromCenter() {
    
    //   There are many possible ways to accomplish removing the snapping behavior of teh blue view. In this implementation,
    //    We map over the UIDynamicAnimator's behaviors property to iterrate through its array of UIDynamicBehavior. We use
    //    the "is" operator to check for class type. We're specifically interested in removing the snapping behavior, so
    //    we check for UISnapBehavior. When one is found, we ask the dynamicAnimator to remove it. 
    
    //    A. Because we only remove the snap behavior, the gravity and collision behaviors still are in effect and the 
    //       view falls down and comes to rest at the bottom of self.view
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

// See above for notes
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

