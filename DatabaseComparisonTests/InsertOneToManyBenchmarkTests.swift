//
//  InsertOneToManyBenchmarkTests.swift
//  DatabaseComparisonTests
//
//  Created by Mori on 2020/12/10.
//

import XCTest

final class InsertOneToManyBenchmarkTests: XCTestCase {

    private let benchmaker = BenchmarkContainer.benchmarker

    func testInsertRealmPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearRealm()
            startMeasuring()
            benchmaker.benchmarkInsertOneToManyByRealm()
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
            benchmaker.benchmarkInsertOneToManyByCoreData()
            stopMeasuring()
        }
    }

    func testInsertGRDBPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearGRDB()
            startMeasuring()
            benchmaker.benchmarkInsertOneToManyByGRDB()
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
            benchmaker.benchmarkInsertOneToManyByFMDB()
            stopMeasuring()
        }
    }

    func testInsertGRDBSQLPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        option.iterationCount = 10
        measure(options: option) {
            benchmaker.clearGRDB()
            startMeasuring()
            benchmaker.benchmarkInsertOneToManyByGRDBSQL()
            stopMeasuring()
        }
    }
}
