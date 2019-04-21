import Foundation
import Swifter
import Unirest

@objc(OneDriveAuthHelper)
class OneDriveAuthHelper: AuthHelper {
    private var authInfo: AuthInfo?
    private var appId: String
    private var scopes: String
    private var redirectUrl: String
    private var authCode: String?
    let server = HttpServer()

    init(_ appId: String, _ scopes: Array<String>, _ redirectUrl: String) {
        self.appId = appId
        self.scopes = scopes.joined(separator: " ")
        self.redirectUrl = redirectUrl
    }

    func login(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
        if (!hasLogin()) {
            getAuthCode { (authCode, error) in
                guard error == nil else {
                    hiveError(error)
                    return
                }
                self.authCode = authCode
                self.requestAccessToken(authCode!, { (error) in
                    hiveError(error)
                })
                self.authCode = nil
                self.server.stop()
            }
        }
    }

    private func getAuthCode(_ authCode: @escaping (_ authCode: String?, _ error: HiveError?) -> Void) {
        do {
            server[""] = { request in
                guard request.queryParams.count > 0 || request.queryParams[0].0 != "code" else {
                     authCode(nil, .failue(des: "authCode obtain failed"))
                    return HttpResponse.ok(.json("nil" as AnyObject))
                }
                let authJson = request.queryParams[0]
                authCode(authJson.1,nil)
                return HttpResponse.ok(.json("nil" as AnyObject))
            }
            try server.start(44316)
        } catch {
            authCode(nil,(error as! HiveError))
        }
    }

    private func requestAccessToken(_ authorCode: String, _ hiveError: @escaping (_ error: HiveError?) -> Void) {
        let params: Dictionary<String, Any> = ["client_id" : appId,
                                               "code" : authorCode,
                                               "grant_type" : AUTHORIZATION_CODE,
                                               "redirect_uri" : redirectUrl]
        OneDriveHttpServer.post(TOKEN_URL, params, nil) { (response, error) in
            guard error == nil else {
                hiveError(error)
                return
            }
            self.authInfo = AuthInfo()
            self.authInfo?.accessToken = (response![ACCESS_TOKEN] as! String)
            self.authInfo?.refreshToken = (response![REFRESH_TOKEN] as! String)
            self.authInfo?.expiredIn = (response![EXPIRES_IN] as! Int64)
            self.authInfo?.scopes = (response![SCOPE] as! String)
            let expireTime = HelperMethods.getExpireTime(time: self.authInfo!.expiredIn)
            self.authInfo?.expiredTime = expireTime

            // todo  save to keychain: access_token & refresh_token & expire_time
            let accesstoken: String = self.authInfo!.accessToken // todo  save to keychain
            let keychain = KeychainSwift()
            keychain.set(accesstoken, forKey: ACCESS_TOKEN)
            hiveError(nil)
        }
    }
    
    private func refreshAccessToken(_ hiveError: @escaping (_ error: HiveError?) -> Void) {

        let scops = ["Files.ReadWrite","offline_access"]
        let scopStr = scops.joined(separator: " ")
        let refreshToken: String = authInfo!.refreshToken
        let params: Dictionary<String, Any> = ["client_id": appId,
                                               "refresh_token": refreshToken,
                                               "grant_type": REFRESH_TOKEN,
                                               "redirect_uri": redirectUrl,
                                               "scope": scopStr
                                ]
        OneDriveHttpServer.post(TOKEN_URL, params, nil) { (response, error) in
            guard error == nil else {
                hiveError(error)
                return
            }
            self.authInfo?.accessToken = (response![ACCESS_TOKEN] as! String)
            self.authInfo?.refreshToken = (response![REFRESH_TOKEN] as! String)
            self.authInfo?.expiredIn = (response![EXPIRES_IN] as! Int64)
            self.authInfo?.scopes = (response![SCOPE] as! String)
            let expireTime = HelperMethods.getExpireTime(time: self.authInfo!.expiredIn)
            self.authInfo?.expiredTime = expireTime

            // todo  save to keychain: access_token & refresh_token & expire_time
            let keychain = KeychainSwift()
            keychain.set(self.authInfo!.accessToken, forKey: ACCESS_TOKEN)
            hiveError(nil)
        }

    }
    
    private func hasLogin() -> Bool {
        return authInfo != nil;
    }
    
    private func isExpired() -> Bool {
        return (authInfo?.isExpired())!
    }
    
    override func checkExpired(_ hiveError: @escaping (_ error: HiveError?) -> Void) {
        if (isExpired()) {
            refreshAccessToken { (error) in
                hiveError(error)
            }
        }
    }
}
