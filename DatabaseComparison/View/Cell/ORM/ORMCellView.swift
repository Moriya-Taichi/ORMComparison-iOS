//
//  ORMCellView.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import UIKit

final class ORMCellView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    func configure(_ ormType: ORMType) {
        switch ormType {
        case .coredata:
            nameLabel.text = "CoreData"
            descriptionLabel.text = "Apple純正のSQLiteのORM、iCloudとの連携が特徴"
            imageView.image = UIImage(named: "CoreDataLogo")
        case .realm:
            nameLabel.text = "Realm"
            descriptionLabel.text = "様々なプラットフォームで提供されている独自のDB、高いパフォーマンスが売り"
            imageView.image = UIImage(named: "RealmLogo")
        case .grdb:
            nameLabel.text = "GRDB.swift"
            descriptionLabel.text = "この中では比較的新しいSQLiteのORM、Swiftyに書ける"
            imageView.image = UIImage(named: "GRDBLogo")
        case .fmdb:
            nameLabel.text = "FMDB"
            descriptionLabel.text = "obj-c時代に活躍したSQLiteのWrapper、今は進んで採用する必要はない"
            imageView.image = UIImage(systemName: "square.3.stack.3d.top.fill")
            imageView.tintColor = .systemTeal
        case .userDefaults:
            nameLabel.text = "UserDefaults"
            descriptionLabel.text = "Apple純正のKVS、軽いものを保存する用"
            imageView.image = UIImage(systemName: "cylinder.split.1x2.fill")
            imageView.tintColor = .systemBlue
        }
    }
}
