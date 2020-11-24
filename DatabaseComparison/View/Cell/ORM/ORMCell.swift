//
//  ORMCell.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import UIKit

final class ORMCell: UICollectionViewCell {

    @IBOutlet weak var ormCellView: ORMCellView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func configure(_ ormType: ORMType) {
        ormCellView.configure(ormType)
    }
}
