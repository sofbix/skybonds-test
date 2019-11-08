//
//  UIColor.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var standartTextColor : UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "standartTextColor")!
        } else {
            return UIColor.white
        }
    }
    
}
