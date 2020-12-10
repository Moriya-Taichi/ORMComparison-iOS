//
//  DatabaseComparisonTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/07.
//

import XCTest

class DatabaseComparisonTests: XCTestCase {

    let benchmaker = BenchmarkContainer.benchmarker

    func testInsertRealmPerformance() throws {
        benchmaker.clearRealm()
        measure {
            benchmaker.benchmarkInsertSimpleByRealm()
        }

        measure {
            benchmaker.benchmarkInsertOneToOneByRealm()
        }

        measure {
            benchmaker.benchmarkInsertOneToManyByRealm()
        }
    }

    func testInsertCoredataPerformance() throws {
        benchmaker.clearCoreData()
        measure {
            benchmaker.benchmarkInsertSimpleByCoreData()
        }

        measure {
            benchmaker.benchmarkInsertOneToOneByCoreData()
        }

        measure {
            benchmaker.benchmarkInsertOneToManyByCoreData()
        }
    }

    func testInsertGRDBPerformance() throws {
        benchmaker.clearGRDB()
        measure {
            benchmaker.benchmarkInsertSimpleByGRDB()
        }

        measure {
            benchmaker.benchmarkInsertOneToOneByGRDB()
        }

        measure {
            benchmaker.benchmarkInsertOneToManyByGRDB()
        }
    }

    func testInsertFMDBPerformance() throws {
        benchmaker.clearFMDB()

        measure {
            benchmaker.benchmarkInsertSimpleByFMDB()
        }

        measure {
            benchmaker.benchmarkInsertOneToOneByFMDB()
        }

        measure {
            benchmaker.benchmarkInsertOneToManyByFMDB()
        }
    }

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
