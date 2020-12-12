//
//  BenchmarkViewController.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/12/07.
//

import UIKit

final class BenchmarkViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton! {
        didSet {
            startButton.layer.cornerRadius = startButton.frame.height / 2
            startButton.backgroundColor = .systemBlue
            startButton.tintColor = .white
            startButton.titleLabel?.font = .systemFont(
                ofSize: 18,
                weight: .semibold
            )
        }
    }

    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var realmTimeLabel: UILabel!
    @IBOutlet weak var coredataTimeLabel: UILabel!
    @IBOutlet weak var grdbTimeLabel: UILabel!
    @IBOutlet weak var fmdbTimeLabel: UILabel!

    @IBAction func startButtonAction(_ sender: Any) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "ベンチマーク"
    }
}
