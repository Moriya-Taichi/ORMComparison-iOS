//
//  ReadOneToOneBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class ReadOneToOneBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testReadRealmPerformance() throws {
        benchmaker.clearRealm()
        benchmaker.benchmarkInsertOneToOneByRealm()
        measure {
            benchmaker.benchmarkReadOneToOneByRealm()
        }
    }

    func testReadCoredataPerformance() throws {
        benchmaker.clearCoreData()
        benchmaker.benchmarkInsertOneToOneByCoreData()
        measure {
            benchmaker.benchmarkReadOneToOneByCoreData()
        }
    }

    func testReadGRDBPerformance() throws {
        benchmaker.clearGRDB()
        benchmaker.benchmarkInsertOneToOneByGRDB()
        measure {
            benchmaker.benchmarkReadOneToOneByGRDB()
        }
    }

    func  testReadFMDBPerformance() throws {
        benchmaker.clearFMDB()
        benchmaker.benchmarkInsertOneToOneByFMDB()
        measure {
            benchmaker.benchmarkReadOneToOneByFMDB()
        }
    }
}

