//
//  ViewController.swift
//  Demo
//
//  Created by Carl Chen on 10/19/16.
//  Copyright © 2016 serious. All rights reserved.
//

import UIKit
import IronThrone

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        NetworkKit.requestAPI(apiHost: "opentest.seriousapps.cn"
            , apiName: "3/deal/list_channel.json"
            , method: .get)
            .response { (result) in
                print(result)
            }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

