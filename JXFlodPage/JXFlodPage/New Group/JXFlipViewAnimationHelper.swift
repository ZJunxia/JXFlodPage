//
//  JXFlipViewAnimationHelper.swift
//  JXFlodPage
//
//  Created by admin on 2018/6/18.
//  Copyright © 2018年 JJ. All rights reserved.
//

import UIKit

public enum EFlipDirection:Int {
    case kEFlipDirectionToPrePage   = 0
    case kEFlipDirectionToNextPage
}

protocol JXFlipViewAnimationHelperDataSource:NSObjectProtocol {
    
    func flipViewAnimationHelperGetPreView(helper : JXFlipViewAnimationHelper) -> UIView?
    
    func flipViewAnimationHelperGetCurrentView(helper:JXFlipViewAnimationHelper) -> UIView
    
    func flipViewAnimationHelperGetNextView(helper:JXFlipViewAnimationHelper) -> UIView?
    
}

protocol JXFlipViewAnimationHelperDelegate:NSObjectProtocol {
    func flipViewAnimationHelperBeginAnimation(helper:JXFlipViewAnimationHelper)
    func flipViewAnimationHelperEndAnimation(helper:JXFlipViewAnimationHelper)
    func flipViewAnimationHelper(helper:JXFlipViewAnimationHelper ,direction:EFlipDirection)
    
    
}


class JXFlipViewAnimationHelper: NSObject {

    weak var dataSource:JXFlipViewAnimationHelperDataSource?
    weak var delegate:JXFlipViewAnimationHelperDelegate?
    
    
    fileprivate var hostView:UIView?
    fileprivate var panGesture:UIPanGestureRecognizer?
    fileprivate var canBeginAnimateWithPan:Bool?
    fileprivate var isAnimatingWithPan:Bool?
    fileprivate var isAnimationCompleted:Bool?
    fileprivate var isAnimationInited:Bool?
    fileprivate var currFlipDirection:EFlipDirection?
    fileprivate var startFlipAngle:CGFloat?
    fileprivate var endFlipAngle:CGFloat?
    fileprivate var panelLayer:CALayer?
    fileprivate var bgTopLayer:CALayer?
    fileprivate var bgBottomLayer:CALayer?
    fileprivate var flipLayer:CALayer?
    fileprivate var flipFrontSubLayer:CALayer?
    fileprivate var flipBackSubLayer:CALayer?
    
    
    init(hostView:UIView){
        super.init()
        self.hostView = hostView
        self.panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureHandler(recognizer:)))
        self.hostView?.addGestureRecognizer(self.panGesture!)
        self.canBeginAnimateWithPan = true
        self.canBeginAnimateWithPan = true
        self.isAnimationCompleted = true
        self.isAnimatingWithPan = false
        self.isAnimationInited = false
        
        
    }
    
    deinit {
        self.hostView?.removeGestureRecognizer(self.panGesture!)
        clearLayers()
        
    }
    
    
    
    
    @objc func panGestureHandler(recognizer:UIPanGestureRecognizer){
        if canBeginAnimateWithPan == false {
            return
        }else{}
        let translationY:CGFloat = recognizer.translation(in: hostView).y
        switch recognizer.state {
        case .began:
            if isAnimationCompleted == true {
                isAnimationCompleted = false
                isAnimatingWithPan = true
            }else{}
        case .changed:
            if isAnimatingWithPan == true {
                var canProgressAnimation:Bool = true
                if isAnimationInited == false {
                    currFlipDirection = (translationY > 0.0) ? .kEFlipDirectionToPrePage : .kEFlipDirectionToNextPage
                    
                    canProgressAnimation = beginFlipAnimationForDirection(direction: currFlipDirection!)
                    
                }else{}
                if canProgressAnimation == true {
                    var progress:CGFloat = translationY /  (hostView?.bounds.size.height)!
                    switch currFlipDirection {
                        
                    case .kEFlipDirectionToPrePage?:
                        progress = max(progress, 0)
                    case .kEFlipDirectionToNextPage?:
                        progress = min(progress, 0)
                    default:
                        break
                    }
                    progress = fabs(progress)
                    progressFlipAnimation(progress: progress)
                    
                }else{
                    endFlipAnimation()
                }
            }else{}
            
        case .cancelled:
            if isAnimatingWithPan == true {
                progressFlipAnimation(progress: 0.0, isCleanupWhenCompleted: true)
            }else{}
        case .failed:
            if isAnimatingWithPan == true {
                endFlipAnimation()
            }else{}
        case .ended:
            if isAnimatingWithPan == true {
                if fabs((translationY + recognizer.velocity(in: hostView).y / 4) / (hostView?.bounds.size.height)!) > 0.5 {
                    self.progressFlipAnimation(progress: 1.0, isCleanupWhenCompleted: true)
                    
                }else{
                    self.progressFlipAnimation(progress: 0.0, isCleanupWhenCompleted: true)
                }
            }else{}
            
        default:
            break
        }
        
    }
    
    
    func progressFlipAnimation(progress:CGFloat) {
        progressFlipAnimation(progress: progress, isCleanupWhenCompleted: false)
    }
    
    
    func progressFlipAnimation(progress:CGFloat ,isCleanupWhenCompleted:Bool) {
        let newAngle:CGFloat = startFlipAngle! + progress * (endFlipAngle! - startFlipAngle!)
        let duration = 0.5
        var endTransform:CATransform3D = CATransform3DIdentity
        endTransform.m34 = 1.0 / 2500.0
        endTransform = CATransform3DRotate(endTransform, newAngle, -1.0, 0.0, 0.0)
        flipLayer?.removeAllAnimations()
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        if isCleanupWhenCompleted {
            weak var weakSelf = self
            CATransaction.setCompletionBlock {
                
                let strongSelf = weakSelf
                strongSelf?.endFlipAnimation()
                if progress >= 1.0 && strongSelf?.delegate != nil {
                    strongSelf?.delegate?.flipViewAnimationHelper(helper: self, direction: (strongSelf?.currFlipDirection)!)
                }else{}
                
            }
        }else{}
        flipLayer?.transform = endTransform
        CATransaction.commit()
        
    }
    
    func beginFlipAnimationForDirection(direction:EFlipDirection) -> Bool {
        var canFlipPage:Bool = false
        assert(self.dataSource != nil, "dataSource是nil")
        var currView:UIView?
        var preView:UIView?
        var nextView:UIView?
        
        currView = self.dataSource?.flipViewAnimationHelperGetCurrentView(helper: self)
        switch direction {
        case .kEFlipDirectionToPrePage:
            preView = self.dataSource?.flipViewAnimationHelperGetPreView(helper: self)
            canFlipPage = (preView != nil)
        case .kEFlipDirectionToNextPage:
            nextView = self.dataSource?.flipViewAnimationHelperGetNextView(helper: self)
            
            canFlipPage = (nextView != nil)
            
        
        }
        
        if canFlipPage == true && currView != nil {
            rebuildLayers()
            bgTopLayer?.contentsGravity = kCAGravityBottom
            bgBottomLayer?.contentsGravity = kCAGravityTop
            flipFrontSubLayer?.contentsGravity = kCAGravityBottom
            flipBackSubLayer?.contentsGravity = kCAGravityTop
            
            switch direction {
            case .kEFlipDirectionToPrePage:
                let preImg:UIImage = snapShotFromView(view: preView!)
                let currImg:UIImage = snapShotFromView(view: currView!)
                
                bgTopLayer?.contents = preImg.cgImage
                bgBottomLayer?.contents = currImg.cgImage
                flipFrontSubLayer?.contents = currImg.cgImage
                flipBackSubLayer?.contents = preImg.cgImage
                
                flipLayer?.transform = CATransform3DIdentity
                
                startFlipAngle = 0.0
                endFlipAngle = -.pi
                
            case .kEFlipDirectionToNextPage:
                let nextImg:UIImage = snapShotFromView(view: nextView!)
                let currImg:UIImage = snapShotFromView(view: currView!)
                
                bgTopLayer?.contents = currImg.cgImage
                bgBottomLayer?.contents = nextImg.cgImage
                flipFrontSubLayer?.contents = nextImg.cgImage
                flipBackSubLayer?.contents = currImg.cgImage
                
                flipLayer?.transform = CATransform3DMakeRotation( -.pi, 1, 0, 0)
                
                startFlipAngle = -.pi
                endFlipAngle = 0.0
                
            }
            isAnimationInited = true
            if delegate != nil {
                delegate?.flipViewAnimationHelperBeginAnimation(helper: self)
                
            }else{}
            
        }else{}
        
        return canFlipPage
        
    }
    
    func endFlipAnimation() {
        self.clearLayers()
        isAnimationCompleted = true
        isAnimatingWithPan = false
        isAnimationInited = false
        if delegate != nil {
            delegate?.flipViewAnimationHelperEndAnimation(helper: self)
        }else{}
    }
    
    
    
    func clearLayers() {
        if bgTopLayer != nil {
            self.bgTopLayer?.removeFromSuperlayer()
            bgTopLayer = nil
        }
        if bgBottomLayer != nil {
            self.bgBottomLayer?.removeFromSuperlayer()
            bgBottomLayer = nil
        }
        if flipFrontSubLayer != nil {
            self.flipFrontSubLayer?.removeFromSuperlayer()
            flipFrontSubLayer = nil
        }
        if flipBackSubLayer != nil {
            self.flipBackSubLayer?.removeFromSuperlayer()
            flipBackSubLayer = nil
        }
        if flipLayer != nil {
            self.flipLayer?.removeAllAnimations()
            self.flipLayer?.removeFromSuperlayer()
            flipLayer = nil
        }
    }
    
    
    func rebuildLayers() {
        clearLayers()
        
        panelLayer = CALayer()
        panelLayer?.frame = (hostView?.layer.bounds)!
        hostView?.layer.addSublayer(panelLayer!)
        
        bgTopLayer = CALayer()
        bgTopLayer?.frame = CGRect(x: 0.0, y: 0.0, width: (panelLayer?.bounds.size.width)!, height: (panelLayer?.bounds.size.height)!/2.0)
        bgTopLayer?.isDoubleSided = false
        bgTopLayer?.masksToBounds = true
        bgTopLayer?.contentsScale = UIScreen.main.scale
        panelLayer?.addSublayer(bgTopLayer!)
        
        bgBottomLayer = CALayer()
        bgBottomLayer?.frame = CGRect(x: 0.0, y: (panelLayer?.bounds.size.height)!/2.0, width: (panelLayer?.bounds.size.width)!, height: (panelLayer?.bounds.size.height)!/2.0)
        bgBottomLayer?.isDoubleSided = false
        bgBottomLayer?.masksToBounds = true
        bgBottomLayer?.contentsScale = UIScreen.main.scale
        panelLayer?.addSublayer(bgBottomLayer!)
        
        flipLayer = CATransformLayer()
        flipLayer?.isDoubleSided = true
        flipLayer?.anchorPoint = CGPoint(x: 1, y: 1)
        flipLayer?.frame = CGRect(x: 0.0, y: 0.0, width: (panelLayer?.frame.size.width)!, height: (panelLayer?.bounds.size.height)!/2)
        flipLayer?.zPosition = 1000.0
        panelLayer?.addSublayer(flipLayer!)
        
        flipFrontSubLayer = CALayer()
        flipFrontSubLayer?.frame = (flipLayer?.bounds)!
        flipFrontSubLayer?.isDoubleSided = false
        flipFrontSubLayer?.masksToBounds = true
        flipFrontSubLayer?.contentsScale = UIScreen.main.scale
        flipLayer?.addSublayer(flipFrontSubLayer!)
        
        flipBackSubLayer = CALayer()
        flipBackSubLayer?.frame = (flipLayer?.bounds)!
        flipBackSubLayer?.isDoubleSided = false
        flipBackSubLayer?.masksToBounds = true
        flipBackSubLayer?.contentsScale = UIScreen.main.scale
        let transform:CATransform3D = CATransform3DMakeRotation(.pi, 1.0, 0.0, 0.0)
        flipBackSubLayer?.transform = transform
        flipLayer?.addSublayer(flipBackSubLayer!)
        
        
    }
    
    
    func snapShotFromView(view:UIView) -> UIImage {
        var image:UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
    
    
    
    
    
    
}
