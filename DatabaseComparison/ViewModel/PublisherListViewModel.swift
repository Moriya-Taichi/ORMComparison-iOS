//
//  PublisherListViewModel.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/23.
//

import Combine

final class PublisherListViewModel {

    private let store: PublisherStore
    private var anyCancellable = Set<AnyCancellable>()
    private let publishersState = CurrentValueSubject<[Publisher], Never>([])

    let loadInput = PassthroughSubject<Void, Never>()
    let selectInput = PassthroughSubject<Int, Never>()

    let publishersOutput = PassthroughSubject<[Publisher], Never>()
    let selectPublisherOutput = PassthroughSubject<Publisher, Never>()

    init (store: PublisherStore) {
        self.store = store

        loadInput
            .sink { [weak self] _ in
                let publishers = store.read()
                self?.publishersState.value = publishers
                if publishers.isEmpty {
                    Mock.mockPublishers.forEach { publisher in
                        store.create(publisher: publisher)
                    }
                    self?.publishersState.value = store.read()
                }
            }
            .store(in: &anyCancellable)

        publishersState
            .sink { [weak self] publishers in
                self?.publishersOutput.send(publishers)
            }
            .store(in: &anyCancellable)

        selectInput
            .sink { [weak self] index in
                guard let self = self else {
                    return
                }
                let publisher = self.publishersState.value[index]
                self.selectPublisherOutput.send(publisher)
            }
            .store(in: &anyCancellable)
    }
}

