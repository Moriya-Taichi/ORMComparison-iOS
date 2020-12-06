//
//  SelectView.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/12/07.
//

import UIKit

final class SelectViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let config = UICollectionLayoutListConfiguration(appearance: .plain)
            let layout = UICollectionViewCompositionalLayout.list(using: config)
            collectionView.collectionViewLayout = layout
            collectionView.delegate = self
        }
    }

    private let cellRegistration = UICollectionView
        .CellRegistration<UICollectionViewListCell, String> { cell, indexPath, item in
        var content = cell.defaultContentConfiguration()
        content.text = item
        cell.contentConfiguration = content
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, String> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, String>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let self = self else {
                return nil
            }
            return collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistration,
                for: indexPath,
                item: item
            )
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.select])
        snapshot.appendItems(["ORMの一覧", "ベンチマーク"])
        dataSource.apply(snapshot)
        navigationItem.title = "選択画面"
    }
}

extension SelectViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = indexPath.row == 0 ?
            ORMListViewController() :
            BenchmarkViewController()
        navigationController?.pushViewController(viewController, animated: true)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
