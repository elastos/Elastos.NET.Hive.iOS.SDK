/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import ObjectMapper

public class ScriptInsertExecutableBody: ScriptRootBody {
    private var _collection: String?
    private var _document: Dictionary<String, Any>?
    private var _options: Dictionary<String, Any>?
    
    public override init() {
        super.init()
    }

    public init(_ collection: String, _ document: Dictionary<String, Any>, _ options:  Dictionary<String, Any>?) {
        self._collection = collection
        self._document = document
        self._options = options
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    public override func mapping(map: Map) {
        _collection <- map["collection"]
        _document <- map["document"]
        _options <- map["options"]
    }
}
