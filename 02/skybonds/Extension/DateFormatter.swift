//
//  DateFormatter.swift
//  skybonds
//
//  Created by Sergey Balalaev on 08.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import Foundation

extension DateFormatter
{
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
    
    convenience init(dateStyle: DateFormatter.Style = .none, timeStyle: DateFormatter.Style = .none) {
        self.init()
        self.dateStyle = dateStyle
        self.timeStyle = timeStyle
    }
    
}
