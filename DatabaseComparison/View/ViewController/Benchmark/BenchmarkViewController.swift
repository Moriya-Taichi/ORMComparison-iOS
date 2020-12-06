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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "ベンチマーク"
    }
}
