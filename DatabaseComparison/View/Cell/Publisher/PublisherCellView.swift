//
//  PublisherCellView.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import UIKit

final class PublisherCellView: UIView {

    @IBOutlet weak var publisherNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var bookCountLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    func configure(_ publisher: Publisher) {
        ownerNameLabel.text = publisher.owner.name
        publisherNameLabel.text = publisher.name
        bookCountLabel.text = String(publisher.books.count)
    }
}


