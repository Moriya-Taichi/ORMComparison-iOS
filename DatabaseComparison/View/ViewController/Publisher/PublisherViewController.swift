//
//  PublisherViewController.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import Combine
import UIKit

final class PublisherViewController: UIViewController {

    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var publisherNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var ownerAgeLabel: UILabel!
    @IBOutlet weak var ownerProfileLabel: UILabel!

    var publisher: Publisher?

    private let bookCellRegistration = UICollectionView.CellRegistration<BookCell, Book> { cell, indexPath, book in
        cell.configure(book)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, CellItem> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, CellItem>(
            collectionView: bookCollectionView
        ) { [weak self] collectionView, indexPath, cellItem -> UICollectionViewCell? in
            guard let self = self else {
                return nil
            }
            switch cellItem {
            case .publisher:
                return nil
            case let .book(book):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.bookCellRegistration,
                    for: indexPath,
                    item: book
                )
            }
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let publisher = publisher else {
            return
        }

        publisherNameLabel.text = publisher.name
        ownerNameLabel.text = publisher.owner.name
        ownerAgeLabel.text = String(publisher.owner.age)
        ownerProfileLabel.text = publisher.owner.profile
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
        snapshot.appendSections([.book])
        snapshot.appendItems(publisher.books.map { CellItem.book($0) }, toSection: .book)
        dataSource.apply(snapshot)
    }
}
