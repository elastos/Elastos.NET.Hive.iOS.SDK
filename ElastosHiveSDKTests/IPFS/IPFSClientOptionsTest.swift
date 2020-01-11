import XCTest
@testable import ElastosHiveSDK

class IPFSClientOptions: XCTestCase {
    private let STORE_PATH = "fakePath"

    func testBuild() {
        do {
            let options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("127.0.0.1", 10234))
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertNotNil(options.storePath)
            XCTAssertTrue(options.rpcNodes.count > 0)
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTFail()
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    func testBuildWithoutRpcNodes() {
        do {
            let _ = try IPFSClientOptionsBuilder()
                .withStorePath(using: STORE_PATH)
                .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    func testBuildWithoutStorePath() {
        do {
            let _ = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode("127.0.0.1", 1234))
                .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    override func setUp() {
    }

    override func tearDown() {
    }
}

