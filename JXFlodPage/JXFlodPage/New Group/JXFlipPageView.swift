//
//  JXFlipPageView.swift
//  JXFlodPage
//
//  Created by admin on 2018/6/18.
//  Copyright © 2018年 JJ. All rights reserved.
//

import UIKit

protocol JXFlipPageViewDataSource:NSObjectProtocol {
    
    func numberOfPagesInFlipPageView(flipPageView:JXFlipPageView) -> Int
    func flipPageView(flipPageView:JXFlipPageView, index:Int) -> JXFlipPage
}

class JXFlipPageView: UIView {

    let kReusableArraySize = 5
    
    weak var dataSource:JXFlipPageViewDataSource?
    
    var flipAnimationHelper:JXFlipViewAnimationHelper?
    var numberOfPages:Int? = 0
    var currPage:JXFlipPage?
    
    var currentIndex:Int? = 0
    var reusablePagesDic:[String:Any]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initlizeView()
    }
    
    
    deinit {
        if currPage == nil {
            currPage?.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}

extension JXFlipPageView {
    
    func reloadData() {
        cleanupPages()
        numberOfPages = self.pagesCount()
        if numberOfPages! > 0 {
            self.flipToPageAtIndex(pageNumber: 0, animation: false)
        }
    }
    
    func flipToPageAtIndex(pageNumber:Int,animation:Bool) {
        if pageNumber < numberOfPages! {
            if currPage != nil {
                currPage?.removeFromSuperview()
                currPage = nil
            }else{}
            currPage = self.dataSource?.flipPageView(flipPageView: self, index: pageNumber)
            self.reusableViewsWithReuseIdentifier(reuseIdentifier: (currPage?.reuseIdentifier)!).remove(currPage ?? nil!)
            self.addSubview(currPage!)
            currentIndex = pageNumber
            
        }else{}
        
    }
    
    func dequeueReusablePageWithReuseIdentifier(reuseIdentifier:String) -> JXFlipPage? {
        let page = self.reusableViewsWithReuseIdentifier(reuseIdentifier: reuseIdentifier).anyObject() as? JXFlipPage
        if page != nil {
            self.reusableViewsWithReuseIdentifier(reuseIdentifier: reuseIdentifier).remove(page as Any)
        }else{}
        if page == nil {
            return nil
        }
        return page!
        
    }
        
    func initlizeView() {
        flipAnimationHelper = JXFlipViewAnimationHelper.init(hostView: self)
        flipAnimationHelper?.dataSource = self
        flipAnimationHelper?.delegate = self
        currentIndex = -1
        numberOfPages = 0
    }
    
    
    func cleanupPages() {
        numberOfPages = 0
        if currPage != nil {
            recoveryPage(page: currPage!)
        }else{}
    }
    
    func pagesCount() -> Int {
        var count = 0
        count = (self.dataSource?.numberOfPagesInFlipPageView(flipPageView: self))!
        return count
        
    }
    
    func reusableViewsWithReuseIdentifier(reuseIdentifier:String) -> NSMutableSet {
        if reusablePagesDic == nil{
        reusablePagesDic = [String:AnyObject]()
        }else{}
        let reuseID:String = reuseIdentifier
        var reusablePages = reusablePagesDic![reuseID] as? NSMutableSet
        if reusablePages == nil {
            reusablePages = NSMutableSet()
            reusablePagesDic![reuseID] = reusablePages
        }
        
    return reusablePages!
        
    }
    
    
    func recoveryPage(page:JXFlipPage) {
        
        if (self.reusableViewsWithReuseIdentifier(reuseIdentifier: (currPage?.reuseIdentifier)!)).count < kReusableArraySize {
            self.reusableViewsWithReuseIdentifier(reuseIdentifier: (currPage?.reuseIdentifier)!).add(page)
        }else{}
        page.removeFromSuperview()
        
    }

}

extension JXFlipPageView:JXFlipViewAnimationHelperDelegate, JXFlipViewAnimationHelperDataSource {
    
    func flipViewAnimationHelperGetPreView(helper: JXFlipViewAnimationHelper) -> UIView? {
        var preView:UIView?
        if currentIndex! > 0 {
            preView = (self.dataSource?.flipPageView(flipPageView: self, index: currentIndex! - 1))!
        }else{}
        if preView == nil {
            return nil
        }
        
        return preView!
        
    }
    
    func flipViewAnimationHelperGetCurrentView(helper: JXFlipViewAnimationHelper) -> UIView {
        return currPage!
    }
    
    func flipViewAnimationHelperGetNextView(helper: JXFlipViewAnimationHelper) -> UIView? {
        var nextView:UIView?
        if currentIndex! < (numberOfPages! - 1) {
            nextView = (self.dataSource?.flipPageView(flipPageView: self, index: currentIndex! + 1))!
        }
        if nextView == nil {
            return nil
        }
        return nextView!
    }
    
    
    func flipViewAnimationHelperBeginAnimation(helper:JXFlipViewAnimationHelper) {
        currPage?.isHidden = true
    }
    func flipViewAnimationHelperEndAnimation(helper:JXFlipViewAnimationHelper) {
        currPage?.isHidden = false
    }
    func flipViewAnimationHelper(helper:JXFlipViewAnimationHelper ,direction:EFlipDirection) {
        var newIndex = currentIndex
        switch direction {
        case .kEFlipDirectionToPrePage:
            newIndex = currentIndex! - 1
        case .kEFlipDirectionToNextPage:
            newIndex = currentIndex! + 1
//        default:
//            break
        }
        if newIndex != currentIndex {
            currentIndex = newIndex
            if currPage != nil {
                self.recoveryPage(page: currPage!)
            }else{}
            currPage = (self.dataSource?.flipPageView(flipPageView: self, index: newIndex!))!
            self.addSubview(currPage!)
        }else{}
    }
    
    
}















