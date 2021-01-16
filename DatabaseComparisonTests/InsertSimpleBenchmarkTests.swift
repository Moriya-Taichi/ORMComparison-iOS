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
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(options: option) {
            benchmaker.clearRealm()
            startMeasuring()
            benchmaker.benchmarkInsertSimpleByRealm()
            stopMeasuring()
        }
    }

    func testInsertCoredataPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(options: option) {
            benchmaker.clearCoreData()
            startMeasuring()
            benchmaker.benchmarkInsertSimpleByCoreData()
            stopMeasuring()
        }
    }

    func testInsertCoredataBIRPerfomance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(options: option) {
            benchmaker.clearCoreData()
            startMeasuring()
            benchmaker.benchmarkInsertSimpleByCoreDataBIR()
            stopMeasuring()
        }
    }

    func testInsertGRDBPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(options: option) {
            benchmaker.clearGRDB()
            startMeasuring()
            benchmaker.benchmarkInsertSimpleByGRDB()
            stopMeasuring()
        }
    }

    func testInsertFMDBPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(options: option) {
            benchmaker.clearFMDB()
            startMeasuring()
            benchmaker.benchmarkInsertSimpleByFMDB()
            stopMeasuring()
        }
    }

    func testInsertGRDBSQLPerformance() throws {
        let option = XCTMeasureOptions()
        option.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(options: option) {
            benchmaker.clearGRDB()
            startMeasuring()
            benchmaker.benchmarkInsertSimpleByGRDBSQL()
            stopMeasuring()
        }
    }
}
