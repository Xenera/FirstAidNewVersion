//
//  UshibyViewController.swift
//  FirstAidNewVersion
//
//  Created by Ернур Сункарбек on 03.09.16.
//  Copyright © 2016 ME. All rights reserved.
//

import UIKit

class UshibyViewController: UIViewController, UICollisionBehaviorDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    let data = ["Оказание первой помощи ↑"]
    let textViewData = [
        "Оказание первой медицинской помощи при ушибах, растяжениях и разрывах связок и мышц:\n1. Наложить холод на поврежденное место\n2. Наложить на поврежденное место тугую повязку\n3. Дать пострадавшему обезболивающее средство\n4. Обеспечить поврежденной конечности покой и придать ей возвышенное положение\n5. Доставить пострадавшего в мед.учреждение",
                         ]
    
    var views = [UIView]()
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var snap: UISnapBehavior!
    var previousTouchPoint: CGPoint!
    var viewDraging = false
    var viewPinned = false
    let imageArray = ["vyv1", "vyv2", "vyv3", "vyv4"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: self.view)
        gravity = UIGravityBehavior()
        
        animator.addBehavior(gravity)
        gravity.magnitude = 4
        
        
        
        var offset : CGFloat = self.view.frame.size.height - self.view.frame.size.height * 0.55
        
        for i in 0 ... data.count - 1 {
            if let view = addVC(atOffset: offset, textForHeader: data[i], textForTextView: textViewData[i]){
                views.append(view)
                offset -= 50
            }
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
    
    func addVC(atOffset offset:CGFloat, textForHeader data: AnyObject?, textForTextView text: AnyObject?) -> UIView? {
        
        let frameFOrView = self.view.bounds.offsetBy(dx: 0, dy: self.view.bounds.size.height - offset)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let stackElementVC = sb.instantiateViewControllerWithIdentifier("StackElement") as! stackVenoznoeViewController
        
        
        if let view = stackElementVC.view {
            view.frame = frameFOrView
            view.layer.cornerRadius = 5
            view.layer.shadowOffset = CGSize(width: 2, height: 2)
            view.layer.shadowColor = UIColor.blackColor().CGColor
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 0.5
            
            if let headerStr = data as? String{
                stackElementVC.headerString = headerStr
                
            }
            
            if let textForView = text as? String{
                stackElementVC.viewString = textForView
            }
            
            
            self.addChildViewController(stackElementVC)
            self.view.addSubview(view)
            stackElementVC.didMoveToParentViewController(self)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(UshibyViewController.handlePan(_:)))
            view.addGestureRecognizer(panGestureRecognizer)
            
            let collision = UICollisionBehavior(items: [view])
            collision.collisionDelegate = self
            animator.addBehavior(collision)
            
            let boundary = view.frame.origin.y + view.frame.size.height
            //lower boundary
            var boundaryStart = CGPoint(x: 0, y: boundary)
            var boundaryEnd = CGPoint(x: self.view.bounds.size.width, y: boundary)
            collision.addBoundaryWithIdentifier(1, fromPoint: boundaryStart, toPoint: boundaryEnd)
            
            //upper boundary
            boundaryStart = CGPoint(x: 0, y: 0)
            boundaryEnd = CGPoint(x: self.view.bounds.size.width, y: 0)
            collision.addBoundaryWithIdentifier(2, fromPoint: boundaryStart, toPoint: boundaryEnd)
            
            gravity.addItem(view)
            
            let itemBehavior = UIDynamicItemBehavior(items: [view])
            animator.addBehavior(itemBehavior)
            
            return view
        }
        return nil
    }
    
    func handlePan(gestureRecognizer : UIPanGestureRecognizer){
        
        let touchPoint = gestureRecognizer.locationInView(self.view)
        let draggedView = gestureRecognizer.view!
        
        if gestureRecognizer.state == .Began {
            let dragStartPoint = gestureRecognizer.locationInView(draggedView)
            
            if dragStartPoint.y < 200 {
                viewDraging = true
                previousTouchPoint = touchPoint
            }
        } else if gestureRecognizer.state == .Changed && viewDraging {
            let yOfset = previousTouchPoint.y - touchPoint.y
            
            draggedView.center = CGPoint(x: draggedView.center.x, y: draggedView.center.y - yOfset)
            previousTouchPoint = touchPoint
        } else if gestureRecognizer.state == .Ended && viewDraging {
            
            //pin
            pin(draggedView)
            
            //addVelocity
            addVelocity(toView: draggedView, fromGestoreRecognizer: gestureRecognizer)
            animator.updateItemUsingCurrentState(draggedView)
            viewDraging = false
        }
        
    }
    
    func pin(view : UIView) {
        let viewHasReachedPinLocation = view.frame.origin.y < 100
        
        if viewHasReachedPinLocation {
            if !viewPinned {
                var snapPosition = self.view.center
                snapPosition.y += 70
                
                snap = UISnapBehavior(item: view, snapToPoint: snapPosition)
                animator.addBehavior(snap)
                
                //setVisibility
                setVisibility(view, alpha: 0)
                viewPinned = true
            }
        }else {
            if viewPinned {
                animator.removeBehavior(snap)
                
                setVisibility(view, alpha: 1)
                
                viewPinned = false
            }
        }
    }
    
    func  setVisibility(view: UIView, alpha: CGFloat) {
        for aView in views {
            if aView != view {
                aView.alpha = alpha
            }
        }
    }
    
    func addVelocity(toView view: UIView, fromGestoreRecognizer panGesture: UIPanGestureRecognizer) {
        
        var velocity = panGesture.velocityInView(self.view)
        velocity.x = 0
        if let behavior = itemBehavior(forView: view) {
            behavior.addLinearVelocity(velocity, forItem: view)
        }
        
    }
    
    func itemBehavior(forView view: UIView) -> UIDynamicItemBehavior? {
        
        for behavior in animator.behaviors {
            if let itemBehavior = behavior as? UIDynamicItemBehavior {
                if let possibleView = itemBehavior.items.first as? UIView where possibleView == view {
                    return itemBehavior
                }
            }
        }
        
        return nil
    }
    
    //    func collisionBehior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: )
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if NSNumber(integerLiteral: 2).isEqual(identifier) {
            let view = item as! UIView
            pin(view)
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    //collectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UshibyCollectionViewCell
        
        cell.img.widthAnchor.constraintEqualToAnchor(collectionView.widthAnchor)
        cell.img.heightAnchor.constraintEqualToAnchor(collectionView.heightAnchor)
        
        
        cell.img.image = UIImage(named: imageArray[indexPath.row] + ".jpg")
        
        
        //        cell.widthAnchor.constraintEqualToAnchor(self.collectionView.widthAnchor, multiplier: 1.0)
        //        cell.heightAnchor.constraintEqualToAnchor(self.collectionView.heightAnchor, multiplier: 1.0)
        
        
        pageControl.numberOfPages = imageArray.count
        pageControl.currentPage = Int(indexPath.row)
        
        return cell
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size2 = CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height + 64)
        return size2
    }
}

