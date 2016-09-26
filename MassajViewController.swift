//
//  MassajViewController.swift
//  FirstAidNewVersion
//
//  Created by Ернур Сункарбек on 03.09.16.
//  Copyright © 2016 ME. All rights reserved.
//

import UIKit

class MassajViewController: UIViewController, UICollisionBehaviorDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    let data = ["Наружный массаж сердца ↑",
                "Оптимальное соотношение",
                "Количество циклов",
                ]
    let textViewData = [
        "1. Расположите ладонь выше мечевидного отростка так, чтобы большой палец был направлен на подбородок или живот пострадавшего. Чтобы непрямой массаж сердца был эффективным, его необходимо проводить на жесткой ровной поверхности.\n2. Переместить центр тяжести на грудину и проводить непрямой массаж сердца прямыми руками\n3. Надавить на грудную клетку.\n   Продавливать грудную клетку на 3-5 см с частатой не реже 60 раз в мин.\nКаждое нажатие следует начинать только после того, как грудная клетка вернется в исходное положение",
        "Оптимальное соотношение надавливании на грудную клетку и вдохов искусственного дыхания  15:2\n2 вдоха 15 надавливаний на грудину",
        "Количество циклов вдохов и надавливании за 1 минуту:\n\nВдохов:\n   - взрослого человека - 12 – 16\n   - у новорожденных и детей до 4 мес. жизни – 40\n   - в 4-6 мес. - 40-35\n   - в 7 мес. – 2 года -35-30\n   - в 2-4 года - 30-25\n   - в 4-6 лет – около 25\n   - в 6-12 лет - 22-20\n   - в 12-15 лет – 20 - 18\n\nНадавливаний на грудину:\n   - взрослого человека 60 – 80\n   - новорожденного – 140\n   - у детей 6 мес. – 130 – 135\n   - до 1 года – 120 – 125\n   - 2 лет – 110 – 115\n   - 3 лет – 105 – 110\n   - 4 лет – 100 – 105\n   - 5 лет – 100\n   - 6 лет – 90 – 95\n   - 7 лет – 85 – 90\n   - 8-9 лет – 80 – 85\n   - 10-12 лет – 80\n   - 13-15 лет – 75"
    ]
    
    var views = [UIView]()
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var snap: UISnapBehavior!
    var previousTouchPoint: CGPoint!
    var viewDraging = false
    var viewPinned = false
    let imageArray = ["isk1", "isk2", "isk3", "isk4", "isk5"]
    
    
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
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MassajViewController.handlePan(_:)))
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MassajCollectionViewCell
        
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
