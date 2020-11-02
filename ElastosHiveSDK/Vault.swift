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

public class Vault: NSObject {
    private var _files: FilesProtocol
    private var _database: DatabaseProtocol
    private var _scripting: ScriptingProtocol
    private var _keyValues: KeyValuesProtocol?

    private var _vaultProvider: String
    private var _ownerDid: String

    init(_ authHelper: VaultAuthHelper, _ vaultProvider: String, _ ownerDid: String) {
        self._files = FileClient(authHelper)
        self._database = DatabaseClient(authHelper)
        self._scripting = ScriptClient(authHelper)

        self._vaultProvider = vaultProvider
        self._ownerDid = ownerDid
    }

    public var providerAddress: String {
        return _vaultProvider
    }

    public var ownerDid: String {
        return _ownerDid
    }

    public var appDid: String {
        return "TODO"
    }

    public var appInstanceDid: String {
        return "TODO"
    }

    public var userDid: String {
        return "TODO"
    }

    public var database: DatabaseProtocol {
        return _database
    }

    public var files: FilesProtocol {
        return _files
    }

    public var keyValues: KeyValuesProtocol {
        return _keyValues!
    }

    public var scripting: ScriptingProtocol {
        return _scripting
    }
}
