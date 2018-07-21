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
            , apiName: "mhw/v1/feed/index.json?no_sign=1&sm_id=sdlkfjsdf"
            , method: .get, parameters: nil, headers: nil)
            .response { (result) in
                print(result)
            }

//        NetworkKit.requestAPI(apiHost: "open.seriousapps.cn"
//            , apiName: "3/deal/list_channel.json"
//            , method: .get)
//            .response { (result) in
//                result
//                    .flatMap(Transformer.jsonToDicArray)
//                    .flatMap(ModelTransformer<CityModel>.dicArrayToAPIModelArray)
//                    .successHandler({ (cityList) in
//                        print(cityList)
//                    })
//                    .failureHandler({ (error) in
////                        let a = error.irt.showableString
//                    })
//            }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

struct CityModel {
    let cityID: Int64
    let cityName: String
}

extension CityModel: APIModelConvertible {
    static func toModel(dic: [String : Any]) -> CityModel? {
        guard let cityID = (dic["city_id"] as? NSNumber)?.int64Value, let cityName = dic["city_name"] as? String else {
            return nil
        }

        return CityModel(cityID: cityID, cityName: cityName)
    }
}
