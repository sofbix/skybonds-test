//
//  UIView.swift
//  skybonds
//
//  Created by Sergey Balalaev on 07.11.2019.
//  Copyright © 2019 Altarix. All rights reserved.
//

import UIKit

extension UIView {
    
    func addConstaintsToSuperview(
        leadingOffset: CGFloat = 0.0,
        trailingOffset: CGFloat = 0.0,
        topOffset: CGFloat = 0.0,
        bottomOffset: CGFloat = 0.0)
    {

        guard let superview = self.superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false

        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leadingOffset).isActive = true
        superview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailingOffset).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor, constant: topOffset).isActive = true
        superview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomOffset).isActive = true
    }

    func addConstaints(height: CGFloat, width: CGFloat) {
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
}
