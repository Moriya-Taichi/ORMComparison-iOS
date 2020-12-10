//
//  InsertOneToManyBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class InsertOneToManyBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testInsertRealmPerformance() throws {
        benchmaker.clearRealm()
        measure {
            benchmaker.benchmarkInsertOneToManyByRealm()
        }
    }

    func testInsertCoredataPerformance() throws {
        benchmaker.clearCoreData()
        measure {
            benchmaker.benchmarkInsertOneToManyByCoreData()
        }
    }

    func testInsertGRDBPerformance() throws {
        benchmaker.clearGRDB()
        measure {
            benchmaker.benchmarkInsertOneToManyByGRDB()
        }
    }

    func testInsertFMDBPerformance() throws {
        benchmaker.clearFMDB()
        measure {
            benchmaker.benchmarkInsertOneToManyByFMDB()
        }
    }
}
