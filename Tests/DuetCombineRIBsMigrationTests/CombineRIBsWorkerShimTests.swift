// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import CombineRIBs
import DuetCombineRIBsMigration
import DuetShells
import XCTest

/// Shim receipts: a Duet worker bracketed by a REAL CombineRIBs Interactor's
/// activate/deactivate cycle — no scope double. Settling is bounded yields,
/// never wall-clock.
@MainActor
final class CombineRIBsWorkerShimTests: XCTestCase {

  private var interactor: Interactor!
  private var worker: BracketRecordingWorker!
  private var token: AnyCancellable?

  override func setUp() {
    super.setUp()
    interactor = Interactor()
    worker = BracketRecordingWorker()
  }

  override func tearDown() {
    token = nil
    if interactor.isActive { interactor.deactivate() }
    super.tearDown()
  }

  func testStartsRunOnActivationAndCancelsOnDeactivation() async {
    token = interactor.adopt(worker)
    XCTAssertFalse(worker.started)

    interactor.activate()
    await settleUntil { self.worker.started }
    XCTAssertTrue(worker.started)
    XCTAssertFalse(worker.finished)

    interactor.deactivate()
    await settleUntil { self.worker.finished }
    XCTAssertTrue(worker.finished)
  }

  func testAdoptingAnAlreadyActiveInteractorStartsImmediately() async {
    interactor.activate()
    token = interactor.adopt(worker)
    await settleUntil { self.worker.started }
    XCTAssertTrue(worker.started)
  }

  func testCancellingTheTokenStopsTheWorkerWithoutDeactivating() async {
    interactor.activate()
    token = interactor.adopt(worker)
    await settleUntil { self.worker.started }

    token = nil
    await settleUntil { self.worker.finished }
    XCTAssertTrue(worker.finished)
    XCTAssertTrue(interactor.isActive)
  }

  func testReactivationReentersRunOnTheSameInstance() async {
    // The legacy bracket's semantics, receipt-pinned: RIBs re-fires the
    // bracket per activate cycle (the Duet-native bracket is one instance
    // per mount instead).
    token = interactor.adopt(worker)
    interactor.activate()
    await settleUntil { self.worker.runs == 1 }
    interactor.deactivate()
    await settleUntil { self.worker.finished }

    interactor.activate()
    await settleUntil { self.worker.runs == 2 }
    XCTAssertEqual(worker.runs, 2)
  }

  /// Yields until `condition` holds, bounded — a failed condition surfaces as
  /// the caller's assertion, never a hang.
  private func settleUntil(_ condition: () -> Bool, maxYields: Int = 10_000) async {
    var budget = maxYields
    while !condition() && budget > 0 {
      await Task.yield()
      budget -= 1
    }
  }
}

/// Parks until cancelled; records both ends of the bracket and re-entries.
private final class BracketRecordingWorker: DuetShells.Working, @unchecked Sendable {
  private(set) var started = false
  private(set) var finished = false
  private(set) var runs = 0

  func run() async {
    started = true
    runs += 1
    await untilCancelled()
    finished = true
  }
}
