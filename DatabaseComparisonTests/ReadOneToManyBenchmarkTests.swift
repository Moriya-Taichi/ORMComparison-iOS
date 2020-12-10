//
//  ReadOneToManyBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class ReadOneToMenyBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testReadRealmPerformance() throws {
        measure {
            benchmaker.benchmarkReadSimpleByRealm()
        }

        measure {
            benchmaker.benchmarkReadOneToOneByRealm()
        }

        measure {
            benchmaker.benchmarkReadOneToManyByRealm()
        }
    }

    func testReadCoredataPerformance() throws {
        measure {
            benchmaker.benchmarkReadSimpleByCoreData()
        }

        measure {
            benchmaker.benchmarkReadOneToOneByCoreData()
        }

        measure {
            benchmaker.benchmarkReadOneToManyByCoreData()
        }
    }

    func testReadGRDBPerformance() throws {
        measure {
            benchmaker.benchmarkReadSimpleByGRDB()
        }

        measure {
            benchmaker.benchmarkReadOneToOneByGRDB()
        }

        measure {
            benchmaker.benchmarkInsertOneToManyByGRDB()
        }
    }

    func  testReadFMDBPerformance() throws {
        measure {
            benchmaker.benchmarkReadSimpleByFMDB()
        }

        measure {
            benchmaker.benchmarkReadOneToOneByFMDB()
        }

        measure {
            benchmaker.benchmarkReadOneToManyByFMDB()
        }
    }
}
