//
//  MockData.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/23.
//

import Foundation

struct Mock {
    static let mockORMList: [ORMType] = [
        .coredata,
        .userDefaults,
        .realm,
        .grdb,
        .fmdb
    ]
    
    static let mockPublishers: [Publisher] = [
        Publisher(
            id: 1,
            name: "hoge-publisher-1",
            books: [
                Book(
                    id: 1,
                    name: "hoge-book-1",
                    price: 1000
                ),
                Book(
                    id: 2,
                    name: "hoge-book-2",
                    price: 100
                ),
                Book(
                    id: 3,
                    name: "hoge-book-3",
                    price: 100
                ),
                Book(
                    id: 4,
                    name: "hoge-book-4",
                    price: 100
                ),
                Book(
                    id: 5,
                    name: "hoge-book-5",
                    price: 100
                ),
                Book(
                    id: 6,
                    name: "hoge-book-6",
                    price: 1000
                ),
                Book(
                    id: 7,
                    name: "hoge-book-7",
                    price: 100
                ),
                Book(
                    id: 8,
                    name: "hoge-book-8",
                    price: 100
                ),
                Book(
                    id: 9,
                    name: "hoge-book-9",
                    price: 100
                ),
                Book(
                    id: 10,
                    name: "hoge-book-10",
                    price: 100
                )
            ],
            owner: .init(
                id: 1,
                name: "hoge-owner-1",
                age: 10,
                profile: "hogehogeのowner,idは1"
            )
        ),
        Publisher(
            id: 2,
            name: "hoge-publisher-2",
            books: [
                Book(
                    id: 11,
                    name: "hoge-book-11",
                    price: 1000
                ),
                Book(
                    id: 12,
                    name: "hoge-book-12",
                    price: 100
                ),
                Book(
                    id: 13,
                    name: "hoge-book-13",
                    price: 100
                ),
                Book(
                    id: 14,
                    name: "hoge-book-14",
                    price: 100
                ),
                Book(
                    id: 15,
                    name: "hoge-book-15",
                    price: 100
                ),
                Book(
                    id: 16,
                    name: "hoge-book-16",
                    price: 1000
                ),
                Book(
                    id: 17,
                    name: "hoge-book-17",
                    price: 100
                ),
                Book(
                    id: 18,
                    name: "hoge-book-18",
                    price: 100
                ),
                Book(
                    id: 19,
                    name: "hoge-book-19",
                    price: 100
                ),
                Book(
                    id: 20,
                    name: "hoge-book-20",
                    price: 100
                )
            ],
            owner: .init(
                id: 2,
                name: "hoge-owner-2",
                age: 10,
                profile: "hogehogeのowner,idは2"
            )
        ),
        Publisher(
            id: 3,
            name: "hoge-publisher-3",
            books: [
                Book(
                    id: 21,
                    name: "hoge-book-21",
                    price: 1000
                ),
                Book(
                    id: 22,
                    name: "hoge-book-22",
                    price: 100
                ),
                Book(
                    id: 23,
                    name: "hoge-book-23",
                    price: 100
                ),
                Book(
                    id: 24,
                    name: "hoge-book-24",
                    price: 100
                ),
                Book(
                    id: 25,
                    name: "hoge-book-25",
                    price: 100
                ),
                Book(
                    id: 26,
                    name: "hoge-book-26",
                    price: 1000
                ),
                Book(
                    id: 27,
                    name: "hoge-book-27",
                    price: 100
                ),
                Book(
                    id: 28,
                    name: "hoge-book-28",
                    price: 100
                ),
                Book(
                    id: 29,
                    name: "hoge-book-29",
                    price: 100
                ),
                Book(
                    id: 30,
                    name: "hoge-book-30",
                    price: 100
                )
            ],
            owner: .init(
                id: 1,
                name: "hoge-owner-1",
                age: 10,
                profile: "hogehogeのowner,idは1"
            )
        ),
        Publisher(
            id: 4,
            name: "hoge-publisher-4",
            books: [
                Book(
                    id: 31,
                    name: "hoge-book-31",
                    price: 1000
                ),
                Book(
                    id: 32,
                    name: "hoge-book-32",
                    price: 100
                ),
                Book(
                    id: 33,
                    name: "hoge-book-33",
                    price: 100
                ),
                Book(
                    id: 34,
                    name: "hoge-book-34",
                    price: 100
                ),
                Book(
                    id: 35,
                    name: "hoge-book-35",
                    price: 100
                ),
                Book(
                    id: 36,
                    name: "hoge-book-36",
                    price: 1000
                ),
                Book(
                    id: 37,
                    name: "hoge-book-37",
                    price: 100
                ),
                Book(
                    id: 38,
                    name: "hoge-book-38",
                    price: 100
                ),
                Book(
                    id: 39,
                    name: "hoge-book-39",
                    price: 100
                ),
                Book(
                    id: 40,
                    name: "hoge-book-40",
                    price: 100
                )
            ],
            owner: .init(
                id: 3,
                name: "hoge-owner-3",
                age: 10,
                profile: "hogehogeのowner,idは3"
            )
        ),
        Publisher(
            id: 5,
            name: "hoge-publisher-5",
            books: [
                Book(
                    id: 41,
                    name: "hoge-book-41",
                    price: 1000
                ),
                Book(
                    id: 42,
                    name: "hoge-book-42",
                    price: 100
                ),
                Book(
                    id: 43,
                    name: "hoge-book-43",
                    price: 100
                ),
                Book(
                    id: 44,
                    name: "hoge-book-44",
                    price: 100
                ),
                Book(
                    id: 45,
                    name: "hoge-book-45",
                    price: 100
                ),
                Book(
                    id: 46,
                    name: "hoge-book-46",
                    price: 1000
                ),
                Book(
                    id: 47,
                    name: "hoge-book-47",
                    price: 100
                ),
                Book(
                    id: 48,
                    name: "hoge-book-48",
                    price: 100
                ),
                Book(
                    id: 49,
                    name: "hoge-book-49",
                    price: 100
                ),
                Book(
                    id: 50,
                    name: "hoge-book-50",
                    price: 100
                )
            ],
            owner: .init(
                id: 4,
                name: "hoge-owner-4",
                age: 10,
                profile: "hogehogeのowner,idは4"
            )
        ),
        Publisher(
            id: 6,
            name: "hoge-publisher-6",
            books: [
                Book(
                    id: 51,
                    name: "hoge-book-51",
                    price: 1000
                ),
                Book(
                    id: 52,
                    name: "hoge-book-52",
                    price: 100
                ),
                Book(
                    id: 53,
                    name: "hoge-book-53",
                    price: 100
                ),
                Book(
                    id: 54,
                    name: "hoge-book-54",
                    price: 100
                ),
                Book(
                    id: 55,
                    name: "hoge-book-55",
                    price: 100
                ),
                Book(
                    id: 56,
                    name: "hoge-book-56",
                    price: 1000
                ),
                Book(
                    id: 57,
                    name: "hoge-book-57",
                    price: 100
                ),
                Book(
                    id: 58,
                    name: "hoge-book-58",
                    price: 100
                ),
                Book(
                    id: 59,
                    name: "hoge-book-59",
                    price: 100
                ),
                Book(
                    id: 60,
                    name: "hoge-book-60",
                    price: 100
                )
            ],
            owner: .init(
                id: 5,
                name: "hoge-owner-5",
                age: 10,
                profile: "hogehogeのowner,idは5"
            )
        ),
        Publisher(
            id: 7,
            name: "hoge-publisher-7",
            books: [
                Book(
                    id: 61,
                    name: "hoge-book-61",
                    price: 1000
                ),
                Book(
                    id: 62,
                    name: "hoge-book-62",
                    price: 100
                ),
                Book(
                    id: 63,
                    name: "hoge-book-63",
                    price: 100
                ),
                Book(
                    id: 64,
                    name: "hoge-book-64",
                    price: 100
                ),
                Book(
                    id: 65,
                    name: "hoge-book-65",
                    price: 100
                ),
                Book(
                    id: 66,
                    name: "hoge-book-66",
                    price: 1000
                ),
                Book(
                    id: 67,
                    name: "hoge-book-67",
                    price: 100
                ),
                Book(
                    id: 68,
                    name: "hoge-book-68",
                    price: 100
                ),
                Book(
                    id: 69,
                    name: "hoge-book-69",
                    price: 100
                ),
                Book(
                    id: 70,
                    name: "hoge-book-70",
                    price: 100
                )
            ],
            owner: .init(
                id: 6,
                name: "hoge-owner-6",
                age: 10,
                profile: "hogehogeのowner,idは6"
            )
        ),
        Publisher(
            id: 8,
            name: "hoge-publisher-8",
            books: [
                Book(
                    id: 71,
                    name: "hoge-book-71",
                    price: 1000
                ),
                Book(
                    id: 72,
                    name: "hoge-book-72",
                    price: 100
                ),
                Book(
                    id: 73,
                    name: "hoge-book-73",
                    price: 100
                ),
                Book(
                    id: 74,
                    name: "hoge-book-74",
                    price: 100
                ),
                Book(
                    id: 75,
                    name: "hoge-book-75",
                    price: 100
                ),
                Book(
                    id: 76,
                    name: "hoge-book-76",
                    price: 1000
                ),
                Book(
                    id: 77,
                    name: "hoge-book-77",
                    price: 100
                ),
                Book(
                    id: 78,
                    name: "hoge-book-78",
                    price: 100
                ),
                Book(
                    id: 79,
                    name: "hoge-book-79",
                    price: 100
                ),
                Book(
                    id: 80,
                    name: "hoge-book-80",
                    price: 100
                )
            ],
            owner: .init(
                id: 7,
                name: "hoge-owner-7",
                age: 10,
                profile: "hogehogeのowner,idは7"
            )
        ),
        Publisher(
            id: 9,
            name: "hoge-publisher-9",
            books: [
                Book(
                    id: 81,
                    name: "hoge-book-81",
                    price: 1000
                ),
                Book(
                    id: 82,
                    name: "hoge-book-82",
                    price: 100
                ),
                Book(
                    id: 83,
                    name: "hoge-book-83",
                    price: 100
                ),
                Book(
                    id: 84,
                    name: "hoge-book-84",
                    price: 100
                ),
                Book(
                    id: 85,
                    name: "hoge-book-85",
                    price: 100
                ),
                Book(
                    id: 86,
                    name: "hoge-book-86",
                    price: 1000
                ),
                Book(
                    id: 87,
                    name: "hoge-book-87",
                    price: 100
                ),
                Book(
                    id: 88,
                    name: "hoge-book-88",
                    price: 100
                ),
                Book(
                    id: 89,
                    name: "hoge-book-89",
                    price: 100
                ),
                Book(
                    id: 90,
                    name: "hoge-book-90",
                    price: 100
                )
            ],
            owner: .init(
                id: 8,
                name: "hoge-owner-8",
                age: 10,
                profile: "hogehogeのowner,idは8"
            )
        ),
        Publisher(
            id: 10,
            name: "hoge-publisher-10",
            books: [
                Book(
                    id: 91,
                    name: "hoge-book-91",
                    price: 1000
                ),
                Book(
                    id: 92,
                    name: "hoge-book-92",
                    price: 100
                ),
                Book(
                    id: 93,
                    name: "hoge-book-93",
                    price: 100
                ),
                Book(
                    id: 94,
                    name: "hoge-book-94",
                    price: 100
                ),
                Book(
                    id: 95,
                    name: "hoge-book-95",
                    price: 100
                ),
                Book(
                    id: 96,
                    name: "hoge-book-96",
                    price: 1000
                ),
                Book(
                    id: 97,
                    name: "hoge-book-97",
                    price: 100
                ),
                Book(
                    id: 98,
                    name: "hoge-book-98",
                    price: 100
                ),
                Book(
                    id: 99,
                    name: "hoge-book-99",
                    price: 100
                ),
                Book(
                    id: 100,
                    name: "hoge-book-100",
                    price: 100
                )
            ],
            owner: .init(
                id: 8,
                name: "hoge-owner-8",
                age: 10,
                profile: "hogehogeのowner,idは8"
            )
        )
    ]
}
