/*
 *  Copyright (c) 2015, Viachaslau Tratsiak.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */
package bakeneko.task;

class IllegalTaskStateException {
    public var message(default, null) : String;

    public function new(message : String) : Void {
        this.message = message;
    }
}
