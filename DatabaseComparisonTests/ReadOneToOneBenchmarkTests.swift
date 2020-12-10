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
        measure {
            benchmaker.benchmarkReadOneToOneByRealm()
        }
    }

    func testReadCoredataPerformance() throws {
        measure {
            benchmaker.benchmarkReadOneToOneByCoreData()
        }
    }

    func testReadGRDBPerformance() throws {
        measure {
            benchmaker.benchmarkReadOneToOneByGRDB()
        }
    }

    func  testReadFMDBPerformance() throws {
        measure {
            benchmaker.benchmarkReadOneToOneByFMDB()
        }
    }
}

