//
//  ViewController.swift
//  JXFlodPage
//
//  Created by admin on 2018/7/16.
//  Copyright © 2018年 JJ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var flipPage:JXFlipPageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        flipPage = JXFlipPageView.init(frame: view.bounds)
        view.addSubview(flipPage!)
        flipPage?.dataSource = self
        flipPage?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController:JXFlipPageViewDataSource {
    func numberOfPagesInFlipPageView(flipPageView: JXFlipPageView) -> Int {
        return 20
    }
    
    func flipPageView(flipPageView: JXFlipPageView, index: Int) -> JXFlipPage {
        let kpageID = "numberPageID"
        
        
        var page = flipPageView.dequeueReusablePageWithReuseIdentifier(reuseIdentifier: kpageID)
        
        
        if page == nil {
            page = JXFlipPage.init(frame: flipPageView.bounds, reuseIdentifier: kpageID)
        }
        if (index%3 == 0)
        {
            page!.backgroundColor = UIColor.blue
        }
        else if (index%3 == 1)
        {
            page!.backgroundColor = UIColor.green
        }
        else if (index%3 == 2)
        {
            page!.backgroundColor = UIColor.red
        }else{}
        page!.tempContentLable?.text = String.init(format: "%d", index)
        return page!
    }
    
    
    
    
    
    
    
    
}
