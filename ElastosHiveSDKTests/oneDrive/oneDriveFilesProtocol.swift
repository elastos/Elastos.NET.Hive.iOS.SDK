import XCTest
@testable import ElastosHiveSDK

class oneDriveFilesProtocolTest: XCTestCase {
    private let CLIENT_ID = "afd3d647-a8b7-4723-bf9d-1b832f43b881"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/onedrive"
    
    private var client: HiveClientHandle?
    private var filesProtocol: FilesProtocol?
    
    private let remoteStringName = "testString.txt"
    private let remoteDataName = "testData.txt"
    private let remoteDataFromFileName  = "testDataFromFile.txt"
    private let remoteDataFromInputStreamName = "testDataFromInputStream.txt"
    
    private let remoteStringContent = "this is test for String"
    private let remoteDataContent = "this is test for Data".data(using: .utf8)
    private let remoteDataFromFileContent  = "this is test for DataFromFile".data(using: .utf8)
    private let remoteDataFromInputStreamContent = "this is test for DataFromInputStream".data(using: .utf8)
    
    class FakeAuthenticator: Authenticator {
        func requestAuthentication(_ requestURL: String) -> Bool {
            DispatchQueue.main.sync {
                let authViewController: AuthWebViewController = AuthWebViewController()
                let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                rootViewController!.present(authViewController, animated: true, completion: nil)
                authViewController.loadRequest(requestURL)
            }
            return true
        }
    }
    
    func test_01_PutString() {
        let lock = XCTestExpectation(description: "testPutString")
        _ = self.filesProtocol!.putString(remoteStringContent, asRemoteFile: remoteStringName).done{ _ in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_01_PutStringHandle() {
        let lock = XCTestExpectation(description: "testPutString")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol!.putString(remoteStringContent, asRemoteFile: remoteStringName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_02_PutData() {
        let lock = XCTestExpectation(description: "testPutData")
        _ = self.filesProtocol!.putData(remoteDataContent!, asRemoteFile: remoteDataName).done{ _ in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_02_PutDataHandle() {
        let lock = XCTestExpectation(description: "testPutData")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol!.putData(remoteDataContent!, asRemoteFile: remoteDataName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_03_PutDataFromFile() {
        
        let lock = XCTestExpectation(description: "testPutDataFromFile")
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/\(remoteDataFromFileName)"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forUpdatingAtPath: path)!
        fileHndle.write(remoteDataFromFileContent!)
        let readerHndle = FileHandle(forReadingAtPath: path)
        readerHndle?.seek(toFileOffset: 0)
        _ = self.filesProtocol!.putDataFromFile(readerHndle!, asRemoteFile: remoteDataFromFileName).done{ re in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_03_PutDataFromFileHandle() {
        
        let lock = XCTestExpectation(description: "testPutDataFromFile")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/\(remoteDataFromFileName)"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forUpdatingAtPath: path)!
        fileHndle.write(remoteDataFromFileContent!)
        let readerHndle = FileHandle(forReadingAtPath: path)
        readerHndle?.seek(toFileOffset: 0)
        _ = self.filesProtocol!.putDataFromFile(readerHndle!, asRemoteFile: remoteDataFromFileName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_04_PutDataFromInputStream() {
        let lock = XCTestExpectation(description: "testPutDataFromInputStream")
        let input = InputStream.init(data: remoteDataFromInputStreamContent!)
        _ = self.filesProtocol!.putDataFromInputStream(input, asRemoteFile: remoteDataFromInputStreamName).done{ re in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_04_PutDataFromInputStreamHandle() {
        let lock = XCTestExpectation(description: "testPutDataFromInputStream")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        let input = InputStream.init(data: remoteDataFromInputStreamContent!)
        _ = self.filesProtocol!.putDataFromInputStream(input, asRemoteFile: remoteDataFromInputStreamName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_05_SizeofRemoteFile() {
        let lock = XCTestExpectation(description: "")
        self.filesProtocol?.sizeofRemoteFile(remoteStringName).done{ re in
            XCTAssertEqual(UInt64(self.remoteStringContent.count), re)
            lock.fulfill()
        }.catch{ error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_05_SizeofRemoteFileHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: UInt64) in
            XCTAssertEqual(UInt64(self.remoteStringContent.count), result)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol?.sizeofRemoteFile(remoteStringName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_06_GetString() {
        let lock = XCTestExpectation(description: "")
        self.filesProtocol?.getString(fromRemoteFile: remoteStringName).done{ re in
            XCTAssertEqual(self.remoteStringContent, re)
            lock.fulfill()
        }.catch{ error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_06_GetStringHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: String) in
            XCTAssertEqual(self.remoteStringContent, result)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol?.getString(fromRemoteFile: remoteStringName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_07_GetData() {
        let lock = XCTestExpectation(description: "")
        self.filesProtocol?.getData(fromRemoteFile: remoteDataName).done{ re in
            XCTAssertEqual(self.remoteDataContent, re)
            lock.fulfill()
        }.catch{ error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_07_GetDataHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Data) in
            XCTAssertEqual(self.remoteDataContent, result)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol?.getData(fromRemoteFile: remoteDataName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_08_GetDataToTargetFile() {
        let lock = XCTestExpectation(description: "")
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/\(remoteDataFromFileName)"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forWritingAtPath: path)!
        
        self.filesProtocol?.getDataToTargetFile(fromRemoteFile: remoteDataFromFileName, targetFile: fileHndle).done{ re in
            XCTAssertEqual(UInt64(self.remoteDataFromFileContent!.count), re)
            lock.fulfill()
        }.catch{ error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_08_GetDataToTargetFileHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: UInt64) in
            XCTAssertEqual(UInt64(self.remoteDataFromFileContent!.count), result)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/\(remoteDataFromFileName)"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forWritingAtPath: path)!
        
        _ = self.filesProtocol?.getDataToTargetFile(fromRemoteFile: remoteDataFromFileName, targetFile: fileHndle, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_09_GetDataToOutputStream() {
        let lock = XCTestExpectation(description: "")
        let output = OutputStream(toMemory: ())
        self.filesProtocol?.getDataToOutputStream(fromRemoteFile: remoteDataFromInputStreamName, output: output).done{ re in
            let data: Data = output.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)! as! Data
            XCTAssertEqual(UInt64(self.remoteDataFromInputStreamContent!.count), re)
            XCTAssertEqual(self.remoteDataFromInputStreamContent!, data)
            lock.fulfill()
        }.catch{ error in
            print(error)
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_09_GetDataToOutputStreamHandle() {
        let lock = XCTestExpectation(description: "")
        let output = OutputStream(toMemory: ())
        let handle: TestResultHandler = TestResultHandler({ (result: UInt64) in
            let data: Data = output.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)! as! Data
            XCTAssertEqual(UInt64(self.remoteDataFromInputStreamContent!.count), result)
            XCTAssertEqual(self.remoteDataFromInputStreamContent!, data)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol?.getDataToOutputStream(fromRemoteFile: remoteDataFromInputStreamName, output: output, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testDeleteRemoteFile() {
        let lock = XCTestExpectation(description: "")
        self.filesProtocol?.deleteRemoteFile(remoteStringName).done{ _ in
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testDeleteRemoteFileHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol?.deleteRemoteFile(remoteDataName, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testListRemoteFiles() {
        let lock = XCTestExpectation(description: "")
        self.filesProtocol?.listRemoteFiles().done{ list in
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testListRemoteFilesHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Array<String>) in
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = self.filesProtocol?.listRemoteFiles(handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    override func setUp() {
        do {
            let options = try OneDriveClientOptionsBuilder()
                .withClientId(CLIENT_ID)
                .withRedirectUrl(REDIRECT_URL)
                .withAuthenticator(FakeAuthenticator())
                .withStorePath(using: STORE_PATH)
                .build()
            
            XCTAssertNotNil(options)
            XCTAssertNotNil(options.clientId)
            XCTAssertNotNil(options.redirectUrl)
            XCTAssertNotNil(options.authenicator)
            XCTAssertNotNil(options.storePath)
            
            client = try HiveClientHandle.createInstance(withOptions: options)
            XCTAssertNotNil(client)
            
            let lock = XCTestExpectation(description: "wait for test connect.")
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                do {
                    try self.client?.connect()
                    XCTAssertTrue(self.client!.isConnected())
                    lock.fulfill()
                } catch HiveError.failue {
                    XCTFail()
                    lock.fulfill()
                } catch {
                    XCTFail()
                    lock.fulfill()
                }
            }
            self.wait(for: [lock], timeout: 100.0)
            XCTAssertTrue(client!.isConnected())
            filesProtocol = client!.asFiles()
            XCTAssertNotNil(filesProtocol)
            
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTFail()
        } catch HiveError.failue  {
            XCTFail()
        } catch {
            XCTFail()
        }
    }
    
    override func tearDown() {
        client?.disconnect()
        client = nil
    }
}