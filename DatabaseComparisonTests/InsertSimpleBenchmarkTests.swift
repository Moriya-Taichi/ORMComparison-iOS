//
//  InsertSimpleBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class InsertSimpleBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testInsertRealmPerformance() throws {
        benchmaker.clearRealm()
        measure {
            benchmaker.benchmarkInsertSimpleByRealm()
        }
    }

    func testInsertCoredataPerformance() throws {
        benchmaker.clearCoreData()
        measure {
            benchmaker.benchmarkInsertSimpleByCoreData()
        }
    }

    func testInsertGRDBPerformance() throws {
        benchmaker.clearGRDB()
        measure {
            benchmaker.benchmarkInsertSimpleByGRDB()
        }
    }

    func testInsertFMDBPerformance() throws {
        benchmaker.clearFMDB()
        measure {
            benchmaker.benchmarkInsertSimpleByFMDB()
        }
    }
}
