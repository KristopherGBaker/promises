// Copyright 2018 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

public extension Promise {
  public typealias Work = () throws -> Value

  /// Creates a pending promise to be resolved with the return value of `work` block which is
  /// executed asynchronously on the given `queue`.
  /// - parameters:
  ///   - queue: A queue to invoke the `work` block on.
  ///   - work: A block to perform any operations needed to resolve the promise.
  public convenience init(on queue: DispatchQueue = .main, _ work: @escaping Work) {
    let objCPromise = ObjCPromise<AnyObject>.__onQueue(queue) {
      do {
        let resolution = try work()
        return resolution as? NSError ?? Promise<Value>.asAnyObject(resolution)
      } catch let error {
        return error as NSError
      }
    }
    self.init(objCPromise)
    // Keep Swift wrapper alive for chained promise until `ObjCPromise` counterpart is resolved.
    objCPromise.__pendingObjects?.add(self)
  }
}
