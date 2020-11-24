//
//  PublisherCell.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/23.
//

import UIKit

final class PublisherCell: UICollectionViewCell {

    @IBOutlet weak var publisherCellView: PublisherCellView!

    func configure(_ publisher: Publisher) {
        publisherCellView.configure(publisher)
    }
}
