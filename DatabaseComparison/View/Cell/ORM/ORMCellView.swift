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
            descriptionLabel.text = "Apple純正のSQLiteのORM"
            imageView.image = UIImage(named: "CoreDataLogo")
        case .realm:
            nameLabel.text = "Realm"
            descriptionLabel.text = "様々なプラットフォームで提供されているDB"
            imageView.image = UIImage(named: "RealmLogo")
        case .grdb:
            nameLabel.text = "GRDB.swift"
            descriptionLabel.text = "Swiftyに書けるSQLiteのORM"
            imageView.image = UIImage(named: "GRDBLogo")
        case .fmdb:
            nameLabel.text = "FMDB"
            descriptionLabel.text = "obj-c時代に活躍したSQLiteのWrapper"
            imageView.image = UIImage(systemName: "square.3.stack.3d.top.fill")
            imageView.tintColor = .systemTeal
        case .userDefaults:
            nameLabel.text = "UserDefaults"
            descriptionLabel.text = "Apple純正のKVS"
            imageView.image = UIImage(systemName: "cylinder.split.1x2.fill")
            imageView.tintColor = .systemBlue
        }
    }
}
