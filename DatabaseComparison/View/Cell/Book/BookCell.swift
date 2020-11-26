//
//  BookCell.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import UIKit

final class BookCell: UICollectionViewCell {

    @IBOutlet weak var bookCellView: BookCellView!

    func configure(_ book: Book) {
        bookCellView.configure(book)
    }
}
