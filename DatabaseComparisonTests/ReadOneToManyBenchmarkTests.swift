//
//  ReadOneToManyBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class ReadOneToManyBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testReadRealmPerformance() throws {
        measure {
            benchmaker.benchmarkReadOneToManyByRealm()
        }
    }

    func testReadCoredataPerformance() throws {
        measure {
            benchmaker.benchmarkReadOneToManyByCoreData()
        }
    }

    func testReadGRDBPerformance() throws {
        measure {
            benchmaker.benchmarkInsertOneToManyByGRDB()
        }
    }

    func  testReadFMDBPerformance() throws {
        measure {
            benchmaker.benchmarkReadOneToManyByFMDB()
        }
    }
}
