import Foundation

class OneDriveHttpHeader {
    internal static let Authorization   = "Authorization"
    internal static let ContentType     = "Content-Type"
    internal static let ContentTypeValue    = "application/x-www-form-urlencoded"

   class func headers() -> Dictionary<String, String> {
        let accesstoken = HelperMethods.getKeychain(KEYCHAIN_ACCESS_TOKEN, KEYCHAIN_DRIVE_ACCOUNT) ?? ""
        return [ContentType: "application/json;charset=UTF-8", Authorization: "bearer \(accesstoken)"]
    }

   class func authHeaders() -> Dictionary<String, String> {
        return [ContentType: ContentTypeValue]
    }
}
