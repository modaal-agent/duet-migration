// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

// The coexistence shim for the worker seam: adopts a Duet worker into a
// CombineRIBs Interactor's active bracket, so a legacy app converts its
// workers one at a time while Routers still stand — the strangler discipline
// applied to the data layer. Once every worker's host is a shell
// (`StoreHost.adopt`), delete this package's dependency; nothing else in a
// migrated app should import CombineRIBs and Duet in one file.
//
// Dual-import discipline: CombineRIBs exports `Working`/`Worker` too, so the
// bare identifier never appears in a dual-import file — this shim
// module-qualifies both sides and is the single sanctioned exception to the
// rule "unqualified `Working` and `import CombineRIBs` may not share a file".

import Combine
import CombineRIBs
import DuetShells

extension CombineRIBs.InteractorScope {
  /// Runs `worker` inside this Interactor's active bracket: activation starts
  /// `run()` in a dedicated task, deactivation (or cancelling the returned
  /// token) cancels it. Deviation from the Duet-native bracket, by design:
  /// RIBs re-fires the bracket on every activate cycle, so re-activation
  /// re-enters `run()` on the SAME instance — run() bodies keep their
  /// machinery in locals (the `untilCancelled()` shape) and re-entry is fresh
  /// by construction. Hold the token like any `cancelOnDeactivate` sink.
  public func adopt(_ worker: some DuetShells.Working) -> AnyCancellable {
    var task: Task<Void, Never>?
    let subscription = isActiveStream
      .removeDuplicates()
      .sink { isActive in
        if isActive {
          guard task == nil else { return }
          task = Task { await worker.run() }
        } else {
          task?.cancel()
          task = nil
        }
      }
    return AnyCancellable {
      subscription.cancel()
      task?.cancel()
      task = nil
    }
  }
}
