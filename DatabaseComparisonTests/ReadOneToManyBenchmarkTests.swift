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
        benchmaker.clearRealm()
        benchmaker.benchmarkInsertOneToManyByRealm()
        measure {
            benchmaker.benchmarkReadOneToManyByRealm()
        }
    }

    func testReadCoredataPerformance() throws {
        benchmaker.clearCoreData()
        benchmaker.benchmarkInsertOneToManyByCoreData()
        measure {
            benchmaker.benchmarkReadOneToManyByCoreData()
        }
    }

    func testReadGRDBPerformance() throws {
        benchmaker.clearGRDB()
        benchmaker.benchmarkInsertOneToManyByGRDB()
        measure {
            benchmaker.benchmarkReadOneToManyByGRDB()
        }
    }

    func  testReadFMDBPerformance() throws {
        benchmaker.clearFMDB()
        benchmaker.benchmarkInsertOneToManyByFMDB()
        measure {
            benchmaker.benchmarkReadOneToManyByFMDB()
        }
    }
}
