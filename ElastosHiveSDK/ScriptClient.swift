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

public class ScriptClient: ScriptingProtocol {
    private static let TAG = "ScriptClient"
    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    public func registerScript(_ name: String, _ executable: Executable) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, nil, executable, 0)
        }
    }

    public func registerScript(_ name: String, _ condition: Condition, _ executable: Executable) -> HivePromise<Bool> {

        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.registerScriptImp(name, condition, executable, 0)
        }
    }

    private func registerScriptImp(_ name: String, _ accessCondition: Condition?, _ executable: Executable, _ tryAgain: Int) -> HivePromise<Bool> {
        HivePromise<Bool> { resolver in

            var param = ["name": name] as [String : Any]
            if let _ = accessCondition {
                param["accessCondition"] = try accessCondition!.jsonSerialize()
            }
            param["executable"] = try executable.jsonSerialize()
            let url = VaultURL.sharedInstance.registerScript()
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                registerScriptImp(name, accessCondition, executable, 1).done { success in
                    resolver.fulfill(success)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            resolver.fulfill(true)
        }
    }

    public func callScript<T>(_ name: String, _ config: CallConfig?, _ resultType: T.Type) -> HivePromise<T> {
        return self.authHelper.checkValid().then { _ -> HivePromise<T> in
            if config == nil {
                return self.callScriptImpl(name, nil, resultType, 0)
            }
            else if config!.isKind(of: UploadCallConfig.self) {
                return self.uploadImp(name, config! as! UploadCallConfig, resultType, 0)
            }
            else if config!.isKind(of: DownloadCallConfig.self) {
                return self.downloadImp(name, config! as! DownloadCallConfig, resultType, 0)
            }
            else if config!.isKind(of: GeneralCallConfig.self) {
                return self.callScriptImpl(name, (config! as! GeneralCallConfig), resultType, 0)
            }
            else {
                // This code will never be executed.
                return self.callScriptImpl(name, config as? GeneralCallConfig, resultType, 0)
            }
        }
    }

    private func callScriptImpl<T>(_ scriptName: String, _ config: GeneralCallConfig?, _ resultType: T.Type, _ tryAgain: Int) -> HivePromise<T> {
        return HivePromise<T> { resolver in
            var param = ["name": scriptName] as [String : Any]
            if config != nil && config?.params != nil {
                param["params"] = config!.params!
            }
            
            let ownerDid = authHelper.ownerDid
            if ownerDid != nil{
                var dic = ["target_did": ownerDid!]
                let appDid = config?.appDid
                if let _ = appDid {
                    dic["target_app_did"] = appDid!
                }
                param["context"] = dic
            }
            let url = VaultURL.sharedInstance.call()
            let response = Alamofire.request(url,
                                method: .post,
                                parameters: param,
                                encoding: JSONEncoding.default,
                                headers: Header(authHelper).headers()).responseJSON()
            let json = try VaultApi.handlerJsonResponse(response)
            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)

            if isRelogin {
                try self.authHelper.signIn()
                callScriptImpl(scriptName, config, resultType, 1).done { result in
                    resolver.fulfill(result)
                }.catch { error in
                    resolver.reject(error)
                }
            }
            if resultType.self == OutputStream.self {
                let data = try JSONSerialization.data(withJSONObject: json.dictionaryObject as Any, options: [])
                let outputStream = OutputStream(toMemory: ())
                outputStream.open()
                self.writeData(data: data, outputStream: outputStream, maxLengthPerWrite: 1024)
                outputStream.close()
                resolver.fulfill(outputStream as! T)
            }
            // The String type
            else if resultType.self == String.self {
                let dic = json.dictionaryObject
                let data = try JSONSerialization.data(withJSONObject: dic as Any, options: [])
                let str = String(data: data, encoding: String.Encoding.utf8)
                resolver.fulfill(str as! T)
            }
            // The Dictionary type
            else if resultType.self == Dictionary<String, Any>.self {
                let dic = json.dictionaryObject
                resolver.fulfill(dic as! T)
            }
            // The JSON type
            else if resultType.self == JSON.self {
                resolver.fulfill(json as! T)
            }
            // the Data type
            else {
                let data = try JSONSerialization.data(withJSONObject: json.dictionaryObject as Any, options: [])
                resolver.fulfill(data as! T)
            }
        }
    }
    
    private func uploadImp<T>(_ scriptName: String, _ config: UploadCallConfig, _ resultType: T.Type, _ tryAgain: Int) -> HivePromise<T> {
        return HivePromise<T> { resolver in
            let url = VaultURL.sharedInstance.call()
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                do {
                    let data: Data = try Data(contentsOf: URL(fileURLWithPath: config.filePath))
                    multipartFormData.append(data, withName: "data", fileName: "test.txt", mimeType: "multipart/form-data")
                    var param: [String: Any] = ["name": scriptName]
                    if let _ = config.params {
                        param["params"] = config.params!
                    }
                    let data1 = try JSONSerialization.data(withJSONObject: param, options: [])
                    let str = String(data: data1, encoding: String.Encoding.utf8)
                    multipartFormData.append(str!.data(using: .utf8)!, withName: "metadata" )
                } catch {
                    resolver.reject(error)
                }
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: Header(authHelper).headers()) { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { [self] response in
                        do {
                            let json = JSON(response.result.value as Any)
                            let isRelogin = try VaultApi.handlerJsonResponseCanRelogin(json, tryAgain: tryAgain)
                            if isRelogin {
                                try self.authHelper.signIn()
                                uploadImp(scriptName, config, resultType, 1).done { result in
                                    resolver.fulfill(result)
                                }.catch { error in
                                    resolver.reject(error)
                                }
                            }
                            if resultType.self == OutputStream.self {
                                let data = try JSONSerialization.data(withJSONObject: json.dictionaryObject as Any, options: [])
                                let outputStream = OutputStream(toMemory: ())
                                outputStream.open()
                                self.writeData(data: data, outputStream: outputStream, maxLengthPerWrite: 1024)
                                outputStream.close()
                                resolver.fulfill(outputStream as! T)
                            }
                            else if resultType.self == String.self {
                                let dic = json.dictionaryObject
                                let data = try JSONSerialization.data(withJSONObject: dic as Any, options: [])
                                let str = String(data: data, encoding: String.Encoding.utf8)
                                resolver.fulfill(str as! T)
                            }
                            else {
                                let data = try JSONSerialization.data(withJSONObject: json.dictionaryObject as Any, options: [])
                                resolver.fulfill(data as! T)
                            }
                        }
                        catch {
                            resolver.reject(error)
                        }
                    }
                case .failure(let encodingError):
                    Log.e(ScriptClient.TAG, "upload ERROR: ", encodingError.localizedDescription)
                    resolver.reject(HiveError.failure(des: encodingError.localizedDescription))
                }
            }
        }
    }

    private func downloadImp<T>(_ scriptName: String, _ config: DownloadCallConfig, _ resultType: T.Type, _ tryAgain: Int) -> HivePromise<T> {
        return HivePromise<T> { resolver in
            let url = VaultURL.sharedInstance.call()
            var params = ["name": scriptName] as [String : Any]
            if config.params != nil && config.params!.count > 0 {
                params["params"] = config.params!
            }
            let response = Alamofire.request(url,
                                             method: .post,
                                             parameters: params,
                                             encoding: JSONEncoding.default,
                                             headers: Header(authHelper).headers()).responseData()
            
            do {
                let relogin = try VaultApi.handlerDataResponse(response, tryAgain)
                if relogin {
                    try self.authHelper.signIn()
                    self.downloadImp(scriptName, config, resultType, 1).done { result in
                        resolver.fulfill(result)
                    }.catch { error in
                        resolver.reject(error)
                    }
                }
                if resultType.self == OutputStream.self {
                    let outputStream = OutputStream(toMemory: ())
                    outputStream.open()
                    self.writeData(data: response.data!, outputStream: outputStream, maxLengthPerWrite: 1024)
                    outputStream.close()
                    resolver.fulfill(outputStream as! T)
                }
                else if resultType.self == String.self {
                    let str = String(data: response.data!, encoding: String.Encoding.utf8)
                    resolver.fulfill(str as! T)
                }
                else {
                    resolver.fulfill(response.data as! T)
                }
            }
            catch {
                resolver.reject(error)
            }
        }
    }

    private func writeData(data: Data, outputStream: OutputStream, maxLengthPerWrite: Int) {
        let size = data.count
        data.withUnsafeBytes({(bytes: UnsafePointer<UInt8>) in
            var bytesWritten = 0
            while bytesWritten < size {
                var maxLength = maxLengthPerWrite
                if size - bytesWritten < maxLengthPerWrite {
                    maxLength = size - bytesWritten
                }
                let n = outputStream.write(bytes.advanced(by: bytesWritten), maxLength: maxLength)
                bytesWritten += n
                print(n)
            }
        })
    }
}
