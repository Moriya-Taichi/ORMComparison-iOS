//
//  ORMListView.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import UIKit

final class ORMListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let listConfigure = UICollectionLayoutListConfiguration(appearance: .plain)
            let layout = UICollectionViewCompositionalLayout.list(using: listConfigure)
            collectionView.collectionViewLayout = layout
        }
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, ORMType> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, ORMType>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, type -> UICollectionViewCell? in
            guard let self = self else {
                return nil
            }
            return collectionView.dequeueConfiguredReusableCell(
                using: self.cellRagistration,
                for: indexPath,
                item: type
            )
        }
        return dataSource
    }()

    private let cellRagistration = UICollectionView.CellRegistration<ORMCell, ORMType>(
        cellNib: UINib(
            nibName: String(describing: ORMCell.self),
            bundle: nil
        )
    ) { cell, indexPath, type in
        cell.configure(type)
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        navigationItem.title = "ORMの一覧"
        collectionView.delegate = self
        var snapshot = NSDiffableDataSourceSnapshot<Section, ORMType>()
        snapshot.appendSections([.orm])
        snapshot.appendItems(Mock.mockORMList)
        dataSource.apply(snapshot)
    }

    private func createViewModel(type: ORMType) -> PublisherListViewModel {
        switch type {
        case .coredata:
            return PublisherListViewModel(store: Container.coredataStore)
        case .userDefaults:
            return PublisherListViewModel(store: Container.userDefaultsStore)
        case .realm:
            return PublisherListViewModel(store: Container.realmStore)
        case .grdb:
            return PublisherListViewModel(store: Container.grdbPublisherStore)
        case .fmdb:
            return PublisherListViewModel(store: Container.fmdbPublisherStore)
        }
    }
}

extension ORMListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = Mock.mockORMList[indexPath.row]
        let viewModel = createViewModel(type: item)
        let viewController = PublisherListViewController()
        viewController.viewModel = viewModel
        self.navigationController?.pushViewController(viewController, animated: true)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
