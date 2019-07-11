import Foundation
import PromiseKit

/// In order to implement the optional protocol, protocol extension is adopted.
protocol DirectoryItem {}

extension DirectoryItem{
    public func createDirectory(withPath: String) -> HivePromise<HiveDirectoryHandle> {
        return createDirectory(withPath: withPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func createDirectory(withPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atPath: String) -> HivePromise<HiveDirectoryHandle>{
        return directoryHandle(atPath: atPath, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func directoryHandle(atPath: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withPath: String) -> HivePromise<HiveFileHandle>{
        return createFile(withPath: withPath, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func createFile(withPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atPath: String) -> HivePromise<HiveFileHandle>{
        return fileHandle(atPath: atPath, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func fileHandle(atPath: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func createDirectory(withName: String) -> HivePromise<HiveDirectoryHandle>{
        return createDirectory(withName: withName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func createDirectory(withName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func directoryHandle(atName: String) -> HivePromise<HiveDirectoryHandle>{
        return directoryHandle(atName: atName, handleBy: HiveCallback<HiveDirectoryHandle>())
    }
    public func directoryHandle(atName: String, handleBy: HiveCallback<HiveDirectoryHandle>)
        -> HivePromise<HiveDirectoryHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveDirectoryHandle>(error: error)
    }

    public func createFile(withName: String) -> HivePromise<HiveFileHandle>{
        return createFile(withName: withName, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func createFile(withName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }

    public func fileHandle(atName: String) -> HivePromise<HiveFileHandle>{
        return fileHandle(atName: atName, handleBy: HiveCallback<HiveFileHandle>())
    }
    public func fileHandle(atName: String, handleBy: HiveCallback<HiveFileHandle>)
        -> HivePromise<HiveFileHandle>{
        let error = HiveError.failue(des: "Dummy")
        return HivePromise<HiveFileHandle>(error: error)
    }
}
