import Foundation
import PromiseKit
import Alamofire
@inline(__always) private func TAG() -> String { return "OneDriveDirectory" }

class OneDriveDirectory: HiveDirectoryHandle {
    var name: String?

    override init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        super.init(info, authHelper)
    }

    override func parentPathName() -> String {
        return HelperMethods.prePath(self.pathName)
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDirectoryInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryInfo>) -> HivePromise<HiveDirectoryInfo> {
        let promise = HivePromise<HiveDirectoryInfo> { resolver in
            _ = self.authHelper.checkExpired().done({ (result) in

                var url = OneDriveURL.API + "/root"
                if self.pathName != "/" {
                    let ecurl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    url  = OneDriveURL.API + "/root:\(ecurl)"
                }
                Alamofire.request(url,
                                  method: .get, parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            guard dataResponse.response?.statusCode == 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                            handleBy.runError(error)
                            resolver.reject(error)
                            return
                        }
                        Log.d(TAG(), "lastUpdatedInfo succeed")
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let dirId = jsonData["id"].stringValue
                        let directoryInfo = HiveDirectoryInfo(dirId)
                        directoryInfo.installValue(jsonData)
                        self.lastInfo = directoryInfo
                        handleBy.didSucceed(directoryInfo)
                        resolver.fulfill(directoryInfo)
                    })
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (result) in

                    let params: Dictionary<String, Any> = ["name": withPath,
                                                           "folder": [: ],
                                                           "@microsoft.graph.conflictBehavior": "fail"]
                    var url = OneDriveURL.API + "/root/children"
                    if self.pathName != "/" {
                        let ecUrl = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        url = OneDriveURL.API + "/root:\(ecUrl):/children"
                    }
                    Alamofire.request(url, method: .post,
                                      parameters: params,
                                      encoding: JSONEncoding.default,
                                      headers: (OneDriveHttpHeader.headers()))
                        .responseJSON(completionHandler: { (dataResponse) in
                            guard dataResponse.response?.statusCode == 201 else{
                                guard dataResponse.response?.statusCode == 401 else {
                                    let error = HiveError.failue(des: TOKEN_INVALID)
                                    Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                                    resolver.reject(error)
                                    handleBy.runError(error)
                                    return
                                }
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            Log.d(TAG(), "createDirectory succeed")
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let dirId = jsonData["id"].stringValue
                            let dirInfo = HiveDirectoryInfo(dirId)
                            dirInfo.installValue(jsonData)
                            let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                            dirHandle.name = jsonData["name"].string
                            var path = self.pathName + "/" + withPath
                            if self.pathName ==  "/" {
                                path = self.pathName + withPath
                            }
                            dirHandle.pathName = path
                            dirHandle.lastInfo = dirInfo
                            dirHandle.drive = self.drive

                            handleBy.didSucceed(dirHandle)
                            resolver.fulfill(dirHandle)
                        })
                }).catch({ (err) in
                    let error = HiveError.failue(des: err.localizedDescription)
                    Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
            }
            return promise
    }

    override func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (result) in

                    var path = self.pathName + "/" + atPath
                    if self.pathName == "/" {
                        path = self.pathName + atPath
                    }
                    let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let url = OneDriveURL.API + "/root:\(ecUrl)"
                    Alamofire.request(url,
                                      method: .get,
                                      parameters: nil,
                                      encoding: JSONEncoding.default,
                                      headers: (OneDriveHttpHeader.headers()))
                        .responseJSON(completionHandler: { (dataResponse) in
                            guard dataResponse.response?.statusCode == 200 else{
                                guard dataResponse.response?.statusCode == 401 else {
                                    let error = HiveError.failue(des: TOKEN_INVALID)
                                    Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                                    resolver.reject(error)
                                    handleBy.runError(error)
                                    return
                                }
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            Log.d(TAG(), "directoryHandle succeed")
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let dirId = jsonData["id"].stringValue
                            let dirInfo = HiveDirectoryInfo(dirId)
                            dirInfo.installValue(jsonData)
                            let dirHandle = OneDriveDirectory(dirInfo, self.authHelper)
                            dirHandle.name = jsonData["name"].string
                            dirHandle.pathName = path
                            dirHandle.lastInfo = dirInfo
                            dirHandle.drive = self.drive

                            handleBy.didSucceed(dirHandle)
                            resolver.fulfill(dirHandle)
                        })
                }).catch({ (err) in
                    let error = HiveError.failue(des: err.localizedDescription)
                    Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
            }
            return promise
    }

    override func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) -> HivePromise<HiveFileHandle> {
        let promise = HivePromise<HiveFileHandle> { resolver in
            _ = self.authHelper.checkExpired().done({ (result) in
                var path = self.pathName + "/" + withPath
                if self.pathName == "/" {
                    path = self.pathName + withPath
                }
                let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = OneDriveURL.API + "/root:\(ecUrl):/content"
                let params = ["@microsoft.graph.conflictBehavior": "fail"]
                Alamofire.request(url,
                                  method: .put,
                                  parameters: params,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 201 else{
                            guard dataResponse.response?.statusCode == 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "createFile falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "createFile falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "createFile succeed")
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let fileId = jsonData["id"].stringValue
                        let fileInfo = HiveFileInfo(fileId)
                        fileInfo.installValue(jsonData)
                        let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                        fileHandle.name = jsonData["name"].string
                        fileHandle.pathName = path
                        fileHandle.drive = self.drive
                        fileHandle.lastInfo = fileInfo

                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)
                    })
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "createFile falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                _ = self.authHelper.checkExpired().done({ (result) in

                    var path = self.pathName + "/" + atPath
                    if self.pathName == "/" {
                        path = self.pathName + atPath
                    }
                    let ecUrl = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    let url = OneDriveURL.API + "/root:\(ecUrl)"
                    Alamofire.request(url,
                                      method: .get,
                                      parameters: nil,
                                      encoding: JSONEncoding.default,
                                      headers: (OneDriveHttpHeader.headers()))
                        .responseJSON(completionHandler: { (dataResponse) in
                            guard dataResponse.response?.statusCode == 200 else{
                                guard dataResponse.response?.statusCode == 401 else {
                                    let error = HiveError.failue(des: TOKEN_INVALID)
                                    Log.e(TAG(), "fileHandle falied: %s", error.localizedDescription)
                                    resolver.reject(error)
                                    handleBy.runError(error)
                                    return
                                }
                                let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                                Log.e(TAG(), "fileHandle falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            Log.d(TAG(), "fileHandle succeed")
                            let jsonData = JSON(dataResponse.result.value as Any)
                            let fileId = jsonData["id"].stringValue
                            let fileInfo = HiveFileInfo(fileId)
                            fileInfo.installValue(jsonData)
                            let fileHandle = OneDriveFile(fileInfo, self.authHelper)
                            fileHandle.name = jsonData["name"].string
                            fileHandle.pathName = path
                            fileHandle.drive = self.drive
                            fileHandle.lastInfo = fileInfo

                            handleBy.didSucceed(fileHandle)
                            resolver.fulfill(fileHandle)
                        })
                }).catch({ (err) in
                    let error = HiveError.failue(des: err.localizedDescription)
                    Log.e(TAG(), "fileHandle falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
                })
            }
            return promise
    }

    override func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    override func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let promise = HivePromise<HiveChildren> { resolver in
            _ = self.authHelper.checkExpired().done({ (result) in
                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                var url = "\(OneDriveURL.API)/root:\(path):/children"
                if self.pathName == "/" {
                    url = "\(OneDriveURL.API)/root/children"
                }
                Alamofire.request(url,
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            guard dataResponse.response?.statusCode == 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "getChildren falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "getChildren falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "getChildren succeed")
                        let jsonData = JSON(dataResponse.result.value as Any)
                        let children = HiveChildren()
                        children.installValue(jsonData)
                        resolver.fulfill(children)
                        handleBy.didSucceed(children)
                    })
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "getChildren falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper.checkExpired().done({ (result) in

                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):\(path)"
                let params: Dictionary<String, Any> = ["parentReference": ["path": "/drive/root:" + newPath],
                                                       "name": self.name!,
                                                       "@microsoft.graph.conflictBehavior": "fail"]
                Alamofire.request(url,
                                  method: .patch,
                                  parameters: params,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 200 else{
                            guard dataResponse.response?.statusCode == 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "moveTo falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "moveTo falied: %s", error.localizedDescription)
                            self.pathName = newPath + self.name!
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "moveTo succeed")
                        resolver.fulfill(true)
                        handleBy.didSucceed(true)
                    })
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "moveTo falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    override func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper.checkExpired().done({ (result) in

                let path = ("/" + self.pathName).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                var url = OneDriveURL.API + ONEDRIVE_ROOTDIR + ":" + path + ":/copy"
                if newPath == "/" {
                    url = OneDriveURL.API + ONEDRIVE_ROOTDIR + "/copy"
                }
                let params: Dictionary<String, Any> = ["parentReference" : ["path": "/drive/root:\(newPath)"],
                                                       "name": self.name as Any,
                                                       "@microsoft.graph.conflictBehavior": "fail"]
                Alamofire.request(url, method: .post,
                                  parameters: params,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 202 else{
                            guard dataResponse.response?.statusCode == 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "copyTo falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "copyTo falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        let urlString = dataResponse.response?.allHeaderFields["Location"] as? String ?? ""
                        self.pollingCopyresult(urlString, { (result) in
                            if result == true {
                                Log.d(TAG(), "copyTo succeed")
                                resolver.fulfill(true)
                                handleBy.didSucceed(true)
                            }
                            else {
                                let error = HiveError.failue(des: "Operation failed")
                                Log.e(TAG(), "copyTo falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                            }
                        })
                    })
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "copyTo falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    override func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let promise = HivePromise<Bool>{ resolver in
            _ = self.authHelper.checkExpired().done({ (result) in

                let path = self.pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let url: String = "\(OneDriveURL.API)\(ONEDRIVE_ROOTDIR):/\(path)"
                Alamofire.request(url,
                                  method: .delete,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: (OneDriveHttpHeader.headers()))
                    .responseJSON(completionHandler: { (dataResponse) in
                        guard dataResponse.response?.statusCode == 204 else{
                            guard dataResponse.response?.statusCode == 401 else {
                                let error = HiveError.failue(des: TOKEN_INVALID)
                                Log.e(TAG(), "deleteItem falied: %s", error.localizedDescription)
                                resolver.reject(error)
                                handleBy.runError(error)
                                return
                            }
                            let error = HiveError.failue(des: HelperMethods.jsonToString(dataResponse.data!))
                            Log.e(TAG(), "deleteItem falied: %s", error.localizedDescription)
                            resolver.reject(error)
                            handleBy.runError(error)
                            return
                        }
                        Log.d(TAG(), "deleteItem succeed")
                        self.pathName = ""
                        self.drive = nil
                        self.directoryId = ""
                        self.lastInfo = nil
                        resolver.fulfill(true)
                        handleBy.didSucceed(true)
                    })
            }).catch({ (err) in
                let error = HiveError.failue(des: err.localizedDescription)
                Log.e(TAG(), "deleteItem falied: %s", error.localizedDescription)
                resolver.reject(error)
                handleBy.runError(error)
            })
        }
        return promise
    }

    override func close() {
        // TODO
    }

    private func pollingCopyresult(_ url: String, _ copyResult: @escaping (_ isSucceed: Bool) -> Void) {
        Alamofire.request(url,
                          method: .get,
                          parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { (dataResponse) in
                let jsonData = JSON(dataResponse.result.value as Any)
                let stat = jsonData["status"].stringValue
                if stat == "completed" {
                    copyResult(true)
                    return
                }else if stat == "failed" {
                    copyResult(false)
                    return
                }else {
                    self.pollingCopyresult(url, copyResult)
                }
        }
    }

}
