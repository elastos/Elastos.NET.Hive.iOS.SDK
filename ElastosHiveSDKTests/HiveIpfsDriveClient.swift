
import XCTest
@testable import ElastosHiveSDK

class HiveIpfsDriveClient: XCTestCase, Authenticator {
    func requestAuthentication(_ requestURL: String) -> Bool {
        return true
    }

    var hiveClient: HiveClientHandle?
    var hiveParams: DriveParameter?
    var lock: XCTestExpectation?
    var timeOut: Double = 600.0

    override func setUp() {
        hiveParams = DriveParameter.createForIpfsDrive("uid-37dd2923-baf6-4aae-bc28-d4e5fd92a7b0", "/")
        HiveClientHandle.createInstance(hiveParams!)
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIpfs)
    }

    func test1_login() {
        lock = XCTestExpectation(description: "wait for test1_Login")
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            let result = self.hiveClient?.login(self as Authenticator)
            XCTAssertTrue(result!)
            self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeOut)
    }

    /*
    func test2_lastUpdatedInfo() {
        lock = XCTestExpectation(description: "wait for test2_lastUpdatedInfo")
        self.hiveClient?.lastUpdatedInfo().done({ (clientInfo) in
            XCTAssertNotNil(clientInfo)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }
 */

    func test3_defaultDriveHandle() {
        lock = XCTestExpectation(description: "wait for test3_defaultDriveHandle")
        self.hiveClient?.defaultDriveHandle().done({ (drive) in
            XCTAssertNotNil(drive)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }

    /*
    func test4_logout() {
        lock = XCTestExpectation(description: "wait for test4_logout")
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            let result = self.hiveClient?.logout()
            XCTAssertTrue(result!)
            self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeOut)
    }
 */
    
}