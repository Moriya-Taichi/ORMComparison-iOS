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
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearRealm()
            startMeasuring()
            benchmaker.benchmarkInsertOneToOneByRealm()
            stopMeasuring()
        }
    }

    func testInsertCoredataPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearCoreData()
            startMeasuring()
            benchmaker.benchmarkInsertOneToOneByCoreData()
            stopMeasuring()
        }
    }

    func testInsertGRDBPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearRealm()
            startMeasuring()
            benchmaker.benchmarkInsertOneToOneByGRDB()
            stopMeasuring()
        }
    }

    func testInsertFMDBPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearFMDB()
            startMeasuring()
            benchmaker.benchmarkInsertOneToOneByFMDB()
            stopMeasuring()
        }
    }

    func testInsertGRDBSQLPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearRealm()
            startMeasuring()
            benchmaker.benchmarkInsertOneToOneByGRDBSQL()
            stopMeasuring()
        }
    }
}
