import Foundation
import PromiseKit

@objc(HiveFile)
public class HiveFileHandle: Result, ResourceItem, FileItem {
    public typealias resourceType = HiveFileInfo
    public var drive: HiveDriveHandle?
    public var fileId: String
    public var pathName: String
    public var lastInfo: HiveFileInfo?
    var authHelper: AuthHelper?

    /// Creates an instance with the specified `info` and `authHelper`.
    ///
    /// - Parameters:
    ///   - info: The `HiveFileInfo` instance.
    ///   - authHelper: The `AuthHelper` instance
    init(_ info: HiveFileInfo, _ authHelper: AuthHelper) {
        self.lastInfo = info
        self.authHelper = authHelper
        self.fileId = info.attrDic![HiveFileInfo.itemId]!
        self.pathName = ""
    }
    
    /// Parent path
    ///
    /// - Returns: Returns the parent path of the subclasses
    public func parentPathName() -> String {
        return ""
    }

    /// Latst update for `HiveFile` subclasses
    ///
    /// - Returns: Returns the parent path of the subclasses
    public func lastUpdatedInfo() -> HivePromise<resourceType> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveFileHandle.resourceType>())
    }

    /// Latst update for `HiveFile` subclasses
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns the parent path of the subclasses
    public func lastUpdatedInfo(handleBy: HiveCallback<resourceType>) -> HivePromise<resourceType> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileInfo>(error: error)
    }

    /// Current File move to new path
    ///
    /// - Parameter newPath: The new path with the file
    /// - Returns: Returns `true` if the move succees, `false` otherwise.
    public func moveTo(newPath: String) -> HivePromise<HiveVoid> {
        return moveTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    /// Current File move to the new path
    ///
    /// - Parameters:
    ///   - newPath: The new path with the file
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the move succees, `false` otherwise.
    public func moveTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// Current file copy to the new path
    ///
    /// - Parameter newPath: The path to copy
    /// - Returns: Returns `true` if the copy succees, `false` otherwise.
    public func copyTo(newPath: String) -> HivePromise<HiveVoid> {
        return copyTo(newPath: newPath, handleBy: HiveCallback<HiveVoid>())
    }

    /// Current file copy to the new path
    ///
    /// - Parameters:
    ///   - newPath: The path to copy
    ///   - handleBy: The result
    /// - Returns: Returns `true` if the copy succees, `false` otherwise.
    public func copyTo(newPath: String, handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    /// Delete the current file
    ///
    /// - Returns: Returns `true` if the delete succees, `false` otherwise.
    public func deleteItem() -> HivePromise<HiveVoid> {
        return deleteItem(handleBy: HiveCallback<HiveVoid>())
    }

    /// Delete the current file
    ///
    /// - Parameter handleBy: The result
    /// - Returns: Returns `true` if the delete succees, `false` otherwise.
    public func deleteItem(handleBy: HiveCallback<HiveVoid>) -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    public func readData(_ length: Int) -> HivePromise<Data> {
        return readData(length, handleBy: HiveCallback<Data>())
    }

    public func readData(_ length: Int, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Data>(error: error)
    }

    public func readData(_ length: Int, _ position: UInt64) -> HivePromise<Data> {
        return readData(length, position, handleBy: HiveCallback<Data>())
    }

    public func readData(_ length: Int, _ position: UInt64, handleBy: HiveCallback<Data>) -> HivePromise<Data> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Data>(error: error)
    }

    public func writeData(withData: Data) -> HivePromise<Int32> {
        return writeData(withData: withData, handleBy: HiveCallback<Int32>())
    }

    public func writeData(withData: Data, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Int32>(error: error)
    }

    public func writeData(withData: Data, _ position: UInt64) -> HivePromise<Int32> {
        return writeData(withData: withData, position, handleBy: HiveCallback<Int32>())
    }

    public func writeData(withData: Data, _ position: UInt64, handleBy: HiveCallback<Int32>) -> HivePromise<Int32> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<Int32>(error: error)
    }

    public func commitData() -> HivePromise<HiveVoid> {
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveVoid>(error: error)
    }

    public func discardData() {}

    /// Close
    public func close() {
        // TODO
    }
}
