//
//  BookCellView.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import UIKit

final class BookCellView: UIView {

    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var bookPriceLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    func configure(_ book: Book) {
        bookNameLabel.text = book.name
        bookPriceLabel.text = String(book.price)
    }
}
