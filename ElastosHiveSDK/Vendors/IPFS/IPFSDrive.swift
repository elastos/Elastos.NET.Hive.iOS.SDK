import Foundation
import PromiseKit
import Alamofire

@inline(__always) private func TAG() -> String { return "IPFSDrive" }

@objc(IPFSDrive)
internal class IPFSDrive: HiveDriveHandle {
    private var authHelper: AuthHelper
    internal static var hiveDriveInstance: HiveDriveHandle?

    init(_ info: HiveDriveInfo, _ authHelper: AuthHelper) {
        self.authHelper = authHelper
        super.init(.hiveIPFS, info)
        IPFSDrive.hiveDriveInstance = self
    }

    static func sharedInstance() -> IPFSDrive {
        return hiveDriveInstance as! IPFSDrive
    }

    override func lastUpdatedInfo() -> HivePromise<HiveDriveInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveDriveInfo>) -> HivePromise<HiveDriveInfo> {
        let promise = HivePromise<HiveDriveInfo> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let path = "/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let params = ["uid": uid, "path": path]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, params)
                }
                .done{ sueecee in
                    Log.d(TAG(), "lastUpdatedInfo succeed")
                    let dic: Dictionary<String, String> = [HiveDriveInfo.driveId: uid]
                    let driveInfo = HiveDriveInfo(dic)
                    self.lastInfo = driveInfo
                    handleBy.didSucceed(driveInfo)
                    resolver.fulfill(driveInfo)
                }
                .catch{ error in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "lastUpdatedInfo falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
            }
        }
        return promise
    }

    override func rootDirectoryHandle() -> HivePromise<HiveDirectoryHandle> {
        return rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func rootDirectoryHandle(handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_LS.rawValue
                let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                let path = "/".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let params = ["uid": uid, "path": path]

                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.request(url, .post, params)
                    }
                    .done{ success in
                        Log.d(TAG(), "rootDirectoryHandle succeed")
                        let dic = [HiveDirectoryInfo.itemId: uid]
                        let directoryInfo = HiveDirectoryInfo(dic)
                        let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = "/"
                        directoryHandle.drive = self
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    }
                    .catch{ error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "rootDirectoryHandle falied: %s", error.localizedDescription)
                        handleBy.runError(error)
                        resolver.reject(error)
                }
            }
            return promise
    }

    override func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_MKDIR.rawValue
                let uid = (authHelper as! IPFSAuthHelper).param.uid
                let path = withPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let param = ["uid": uid,"path": path]

                self.authHelper.checkExpired().then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                    }.then{ json -> HivePromise<String> in
                        return IPFSAPIs.getHash(path, self.authHelper)
                    }.then{  hash -> HivePromise<HiveVoid>  in
                        return IPFSAPIs.publish(hash, self.authHelper)
                    }.done{ success in
                        Log.d(TAG(), "createDirectory succeed")
                        let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                        let dic = [HiveDirectoryInfo.itemId: uid]
                        let directoryInfo = HiveDirectoryInfo(dic)
                        let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = withPath
                        directoryHandle.drive = self
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    }.catch{ error in
                        let hiveError = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "createDirectory falied: %s", error.localizedDescription)
                        resolver.reject(hiveError)
                        handleBy.runError(hiveError)
                }
            }
            return promise
    }

    override func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atPath: atPath,
                               handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    override func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {

            let promise = HivePromise<HiveDirectoryHandle> { resolver in
                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                let path = atPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let param = ["uid": uid, "path": path]

                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.request(url, .post, param)
                    }
                    .done{ success in
                        Log.d(TAG(), "directoryHandle succeed")
                        let dic = [HiveDirectoryInfo.itemId: uid]
                        let directoryInfo = HiveDirectoryInfo(dic)
                        let directoryHandle = IPFSDirectory(directoryInfo, self.authHelper)
                        directoryHandle.lastInfo = directoryInfo
                        directoryHandle.pathName = atPath
                        directoryHandle.drive = self
                        resolver.fulfill(directoryHandle)
                        handleBy.didSucceed(directoryHandle)
                    }
                    .catch{ error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                }
            }
            return promise
    }

    override func createFile(withPath: String) -> HivePromise<HiveFileHandle> {
        return createFile(withPath: withPath,
                          handleBy: HiveCallback<HiveFileHandle>())
    }

    override func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let path = withPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let promise = HivePromise<HiveFileHandle> { resolver in
                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.creatFile(withPath, self.authHelper)
                    }
                    .then{ json -> HivePromise<String> in
                        return IPFSAPIs.getHash("/", self.authHelper)
                    }
                    .then{ hash -> HivePromise<HiveVoid> in
                        return IPFSAPIs.publish(hash, self.authHelper)
                    }
                    .done{ success in
                        Log.d(TAG(), "createFile succeed")
                        let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                        let dic = [HiveFileInfo.itemId: uid]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = IPFSFile(fileInfo, self.authHelper)
                        fileHandle.pathName = withPath
                        fileHandle.lastInfo = fileInfo
                        fileHandle.drive = self
                        handleBy.didSucceed(fileHandle)
                        resolver.fulfill(fileHandle)
                    }
                    .catch{ error in
                        let hiveError = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "directoryHandle falied: %s", error.localizedDescription)
                        handleBy.runError(hiveError)
                        resolver.reject(hiveError)
                }
            }
            return promise
    }

    override func fileHandle(atPath: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }

    override func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
            let promise = HivePromise<HiveFileHandle> { resolver in
                let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
                let uid = (self.authHelper as! IPFSAuthHelper).param.uid
                let path = atPath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let param = ["uid": uid, "path": path]
                self.authHelper.checkExpired()
                    .then{ void -> HivePromise<JSON> in
                        return IPFSAPIs.request(url, .post, param)
                    }
                    .done{ success in
                        Log.d(TAG(), "fileHandle succeed")
                        let dic = [HiveFileInfo.itemId: uid]
                        let fileInfo = HiveFileInfo(dic)
                        let fileHandle = IPFSFile(fileInfo, self.authHelper)
                        fileHandle.lastInfo = fileInfo
                        fileHandle.pathName = atPath
                        fileHandle.drive = self
                        resolver.fulfill(fileHandle)
                        handleBy.didSucceed(fileHandle)
                    }
                    .catch{ error in
                        let error = HiveError.failue(des: error.localizedDescription)
                        Log.e(TAG(), "fileHandle falied: %s", error.localizedDescription)
                        resolver.reject(error)
                        handleBy.runError(error)
                }
            }
            return promise
    }

    override func getItemInfo(_ path: String) -> HivePromise<HiveItemInfo> {
        return getItemInfo(path, handleBy: HiveCallback<HiveItemInfo>())
    }

    override func getItemInfo(_ path: String, handleBy: HiveCallback<HiveItemInfo>) -> HivePromise<HiveItemInfo> {
        let promise = HivePromise<HiveItemInfo> { resolver in
            let url = URL_POOL[validIp] + HIVE_SUB_Url.IPFS_FILES_STAT.rawValue
            let uid = (self.authHelper as! IPFSAuthHelper).param.uid
            let param = ["uid": uid, "path": path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!]
            self.authHelper.checkExpired()
                .then{ void -> HivePromise<JSON> in
                    return IPFSAPIs.request(url, .post, param)
                }
                .done{ jsonData in
                    Log.d(TAG(), "getItemInfo succeed")
                    let dic = [HiveItemInfo.itemId: uid,
                               HiveItemInfo.name: PathExtracter(path).baseNamePart(),
                               HiveItemInfo.size: jsonData["Size"].stringValue,
                               HiveItemInfo.type: jsonData["Type"].stringValue]
                    let itemInfo = HiveItemInfo(dic)
                    resolver.fulfill(itemInfo)
                    handleBy.didSucceed(itemInfo)
                }
                .catch{ error in
                    let error = HiveError.failue(des: error.localizedDescription)
                    Log.e(TAG(), "getItemInfo falied: %s", error.localizedDescription)
                    resolver.reject(error)
                    handleBy.runError(error)
            }
        }
        return promise
    }
}
