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
                result
                    .flatMap(APIResult.Transformer.jsonToDicArray)
                    .flatMap(APIResult.Transformer.dicArrayToAPIModelArray)
                    .successHandler({ (cityList: [CityModel]) in
                        print(cityList)
                    })
            }

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