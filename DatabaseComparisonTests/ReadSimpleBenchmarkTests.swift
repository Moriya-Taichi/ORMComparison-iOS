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
        measure {
            benchmaker.benchmarkReadSimpleByRealm()
        }
    }

    func testReadCoredataPerformance() throws {
        measure {
            benchmaker.benchmarkReadSimpleByCoreData()
        }
    }

    func testReadGRDBPerformance() throws {
        measure {
            benchmaker.benchmarkReadSimpleByGRDB()
        }
    }

    func  testReadFMDBPerformance() throws {
        measure {
            benchmaker.benchmarkReadSimpleByFMDB()
        }
    }
}
