//
//  ReadSimpleBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class ReadSimpleBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testReadRealmPerformance() throws {
        benchmaker.clearRealm()
        benchmaker.benchmarkInsertSimpleByRealm()
        measure {
            benchmaker.benchmarkReadSimpleByRealm()
        }
    }

    func testReadCoredataPerformance() throws {
        benchmaker.clearCoreData()
        benchmaker.benchmarkInsertSimpleByCoreData()
        measure {
            benchmaker.benchmarkReadSimpleByCoreData()
        }
    }

    func testReadGRDBPerformance() throws {
        benchmaker.clearGRDB()
        benchmaker.benchmarkInsertSimpleByGRDB()
        measure {
            benchmaker.benchmarkReadSimpleByGRDB()
        }
    }

    func  testReadFMDBPerformance() throws {
        benchmaker.clearFMDB()
        benchmaker.benchmarkInsertSimpleByFMDB()
        measure {
            benchmaker.benchmarkReadSimpleByFMDB()
        }
    }
}
