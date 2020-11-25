//
//  PublisherListViewController.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import Combine
import UIKit

final class PublisherListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var anyCancellable = Set<AnyCancellable>()

    private let publisherCellRegistration = UICollectionView.CellRegistration<PublisherCell, Publisher> { cell, indexPath, publisher in
        cell.configure(publisher)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, CellItem> = {
        return .init(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, cellItem -> UICollectionViewCell? in
            guard let self = self else {
                return nil
            }
            switch cellItem {
            case let .publisher(publisher):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.publisherCellRegistration,
                    for: indexPath,
                    item: publisher
                )
            case .book:
                return nil
            }
        }
    }()

    var viewModel: PublisherListViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        let listConfigure = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfigure)
        collectionView.collectionViewLayout = layout
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.dataSource = dataSource
        bind()
    }

    private func bind() {
        guard let viewModel = viewModel else {
            return
        }

        viewModel.loadInput.send(())

        viewModel
            .publishersOutput
            .sink {[weak self] publishers in
                var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
                snapshot.appendSections([.publisher])
                snapshot.appendItems(publishers.map { CellItem.publisher($0) })
                self?.dataSource.apply(snapshot)
            }
            .store(in: &anyCancellable)

        viewModel
            .selectPublisherOutput
            .sink { [weak self] publisher in
                let viewController = PublisherViewController()
                viewController.publisher = publisher
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            .store(in: &anyCancellable)
    }
}

extension PublisherListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.selectInput.send(indexPath.row)
    }
}
