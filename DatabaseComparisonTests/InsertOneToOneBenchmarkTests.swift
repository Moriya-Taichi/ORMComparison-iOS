//
//  InsertOneToOneBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class InsertOneToOneBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testInsertRealmPerformance() throws {
        benchmaker.clearRealm()
        measure {
            benchmaker.benchmarkInsertOneToOneByRealm()
        }
    }

    func testInsertCoredataPerformance() throws {
        benchmaker.clearCoreData()
        measure {
            benchmaker.benchmarkInsertOneToOneByCoreData()
        }
    }

    func testInsertGRDBPerformance() throws {
        benchmaker.clearGRDB()
        measure {
            benchmaker.benchmarkInsertOneToOneByGRDB()
        }
    }

    func testInsertFMDBPerformance() throws {
        benchmaker.clearFMDB()
        measure {
            benchmaker.benchmarkInsertOneToOneByFMDB()
        }
    }
}
