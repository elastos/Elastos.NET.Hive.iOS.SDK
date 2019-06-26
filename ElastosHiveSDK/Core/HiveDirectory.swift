import Foundation
import PromiseKit

@objc(HiveDirectory)
public class HiveDirectoryHandle: Result, ResourceItem, FileItem, DirectoryItem {
    
    public typealias resourceType = HiveDirectoryInfo
    public var drive: HiveDriveHandle?
    public var directoryId: String
    public var pathName: String
    public var lastInfo: HiveDirectoryInfo?
    internal var authHelper: AuthHelper

    /// Creates an instance with the specified `info` and `authHelper`.
    ///
    /// - Parameters:
    ///   - info: The `DirectoryInfo` instance
    ///   - authHelper: The `AuthHelper` instance of the subclasses
    init(_ info: HiveDirectoryInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.directoryId = lastInfo!.attrDic![HiveDirectoryInfo.itemId]!
        self.pathName = ""
    }

    /// Parent path
    ///
    /// - Returns: Returns the parent path of the subclasses
    public func parentPathName() -> String {
        return ""
    }

    /// Latst update for `HiveDirectory` subclasses
    ///
    /// - Returns: Returns the last update info for the sbclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveDirectoryHandle.resourceType>())
    }

    /// Latst update for `HiveDirectory` subclasses
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns the last update info for the sbclasses
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryInfo>(error: error)
    }

    /// Create a directory
    ///
    /// - Parameter withName: The name with the create directory.
    /// - Returns: Returns a directory for subclassees
    public func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Create a directory
    ///
    /// - Parameters:
    ///   - withName: The name with the create directory
    ///   - handleBy: The result
    /// - Returns: Returns a directory for subclasses
    public func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    /// Request a directory with the current directory
    ///
    /// - Parameter atName: The name with the request directory
    /// - Returns: Returns a directory with the given name for subclassses
    public func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle> {
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }

    /// Request a directory with the current directory
    ///
    /// - Parameters:
    ///   - atName: The name with the request directory
    ///   - handleBy: The result
    /// - Returns: Returns a directory with the given name for subclasses
    public func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>) ->
        HivePromise<HiveDirectoryHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    /// Create a file with the current directory
    ///
    /// - Parameter withName: The name with the create file
    /// - Returns: Returns a file with the given name for subclasses
    public func createFile(withName: String) -> HivePromise<HiveFileHandle> {
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Create a file with the current directory
    ///
    /// - Parameters:
    ///   - withName: The name with the create file
    ///   - handleBy: The result
    /// - Returns: Returns a file with the given name for subclasses
    public func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    /// Requst a file with the current directory
    ///
    /// - Parameter atName: The name with the request file
    /// - Returns: Returns a file with the given name for subclasses
    public func fileHandle(atName: String) -> HivePromise<HiveFileHandle> {
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }

    /// Requst a file with the current directory
    ///
    /// - Parameters:
    ///   - atName: The name with the request file
    ///   - handleBy: The result
    /// - Returns: Resturns a file with the given name for subclasses
    public func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>) ->
        HivePromise<HiveFileHandle> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    /// List for current directory
    ///
    /// - Returns: Returns list for current directory
    public func getChildren() -> HivePromise<HiveChildren> {
        return getChildren(handleBy: HiveCallback<HiveChildren>())
    }

    /// List for current directory
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Resturns children for current directory
    public func getChildren(handleBy: HiveCallback<HiveChildren>) -> HivePromise<HiveChildren> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveChildren>(error: error)
    }

    /// Current directory move to the new path
    ///
    /// - Parameter newPath: The new path with the directory
    /// - Returns: Returns `true` if the move succees, `false` otherwise.
    public func moveTo(newPath: String) -> HivePromise<Bool> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    /// Current directory move to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path with the directory
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the move succees, `false` otherwise.
    public func moveTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    /// Current directory copy to the new path
    ///
    /// - Parameter newPath: The new path to copy
    /// - Returns: Returns `true` if the copy succees, `false` otherwise.
    public func copyTo(newPath: String) -> HivePromise<Bool> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<Bool>())
    }

    /// Current directory copy to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path to copy
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the copy succees, `false` otherwise.
    public func copyTo(newPath: String, handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    /// Delete the current directory
    ///
    /// - Returns: Returns `true` if the delete succees, `false` otherwise.
    public func deleteItem() -> HivePromise<Bool> {
        return deleteItem(handleBy: HiveCallback<Bool>())
    }

    /// Delete the current directory
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns `true` if the delete succees, `false` otherwise.
    public func deleteItem(handleBy: HiveCallback<Bool>) -> HivePromise<Bool> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Bool>(error: error)
    }

    /// Close
    public func close() {
        // TODO
    }
}
