//
//  loadNib.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import UIKit

extension UIView {
    func loadNib() {
        let layout = Bundle
            .main
            .loadNibNamed(
                String(describing: type(of: self)),
                owner: self
            )!.first as! UIView
        layout.frame = bounds
        addSubview(layout)
    }
}
