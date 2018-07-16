//
//  JXFlipPage.swift
//  JXFlodPage
//
//  Created by admin on 2018/6/18.
//  Copyright © 2018年 JJ. All rights reserved.
//

import UIKit

public let kJXFlipPageDefaultReusableIdentifier:String = "kJCFlipPageDefaultReusableIdentifier"
class JXFlipPage: UIView {

    
    private(set) var reuseIdentifier:String?
    var tempContentLable:UILabel?
    
    
   init(frame:CGRect ,reuseIdentifier:String) {
    super.init(frame: frame)
    self.reuseIdentifier = reuseIdentifier
    tempContentLable = UILabel.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    tempContentLable?.text = ""
    tempContentLable?.font = UIFont.boldSystemFont(ofSize: 300)
    tempContentLable?.textAlignment = .center
    tempContentLable?.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    self.addSubview(tempContentLable!)
    self.backgroundColor = UIColor.lightGray
    
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
