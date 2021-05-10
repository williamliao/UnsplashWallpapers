//
//  ShareMethods.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/10.
//

import XCTest
@testable import UnsplashWallpapers

extension XCTestCase {
    
    func getFakeData() -> Data {
        // Prepare mock response.
        let jsonString = """
                         [
                            {
                              "id":"q8SwluCubVw",
                              "created_at":"2021-01-29T03:28:05-05:00",
                              "updated_at":"2021-05-09T10:48:56-04:00",
                              "promoted_at":"2021-04-20T16:03:01-04:00",
                              "width":4000,
                              "height":6000,
                              "color":"#26260c",
                              "blur_hash":"L55he{WC4pM|jGf+fkf50Noe?Ft6",
                              "description":"Back of a huge Monstera Deliciosa leaf found on the Road to Hana in Maui, Hawaii.",
                              "alt_description":"green leaf plant during daytime",
                              "urls":{
                                 "raw":"https://images.unsplash.com/photo-1611908829935-19fa66e22db3",
                                 "full":"https://images.unsplash.com/photo-1611908829935-19fa66e22db3",
                                 "regular":"https://images.unsplash.com/photo-1611908829935-19fa66e22db32",
                                 "small":"https://images.unsplash.com/photo-1611908829935-19fa66e22db30",
                                 "thumb":"https://images.unsplash.com/photo-1611908829935-19fa66e22db3"
                              },
                              "links":{
                                 "self":"https://api.unsplash.com/photos/q8SwluCubVw",
                                 "html":"https://unsplash.com/photos/q8SwluCubVw",
                                 "download":"https://unsplash.com/photos/q8SwluCubVw/download",
                                 "download_location":"https://api.unsplash.com/photos/q8SwluCubVw/download?ixid=Mnw4ODkyMXwwfDF8cmFuZG9tfHx8fHx8fHx8MTYyMDYyNTcyMA"
                              },
                              "categories":[
                                 
                              ],
                              "likes":97,
                              "liked_by_user":false,
                              "current_user_collections":[
                                 
                              ],
                              "sponsorship":null,
                              "user":{
                                 "id":"JleonBkhcPQ",
                                 "updated_at":"2021-05-08T03:52:22-04:00",
                                 "username":"schimiggy",
                                 "name":"Alexandra Tran",
                                 "first_name":"Alexandra",
                                 "last_name":"Tran",
                                 "twitter_username":"schimiggy",
                                 "portfolio_url":"https://schimiggy.com/links",
                                 "bio":"Seattle based blogger - I blog about yoga, fitness, wellness, finance, travel and food. Find me on Instagram and Pinterest @schimiggy",
                                 "location":"Seattle, WA",
                                 "links":{
                                    "self":"https://api.unsplash.com/users/schimiggy",
                                    "html":"https://unsplash.com/@schimiggy",
                                    "photos":"https://api.unsplash.com/users/schimiggy/photos",
                                    "likes":"https://api.unsplash.com/users/schimiggy/likes",
                                    "portfolio":"https://api.unsplash.com/users/schimiggy/portfolio",
                                    "following":"https://api.unsplash.com/users/schimiggy/following",
                                    "followers":"https://api.unsplash.com/users/schimiggy/followers"
                                 },
                                 "profile_image":{
                                    "small":"https://images.unsplash.com/profile-1583185413564-ef77cdce195c",
                                    "medium":"https://images.unsplash.com/profile-1583185413564-ef77cdce195c",
                                    "large":"https://images.unsplash.com/profile-1583185413564-ef77cdce195c"
                                 },
                                 "instagram_username":"schimiggy",
                                 "total_collections":0,
                                 "total_likes":2,
                                 "total_photos":116,
                                 "accepted_tos":true,
                                 "for_hire":true
                              },
                              "exif":{
                                 "make":"SONY",
                                 "model":"ILCE-7M3",
                                 "exposure_time":"1/125",
                                 "aperture":"6.3",
                                 "focal_length":"50.0",
                                 "iso":250
                              },
                              "location":{
                                 "title":null,
                                 "name":null,
                                 "city":null,
                                 "country":null,
                                 "position":{
                                    "latitude":null,
                                    "longitude":null
                                 }
                              },
                              "views":280116,
                              "downloads":3369
                            }

                            ]
                         """
        return jsonString.data(using: .utf8)!
    }
    
    func loadJsonData(file: String) -> Data? {
        //1
        if let jsonFilePath = Bundle(for: type(of:  self)).path(forResource: file, ofType: "json") {
            let jsonFileURL = URL(fileURLWithPath: jsonFilePath)
            //2
            if let jsonData = try? Data(contentsOf: jsonFileURL) {
                return jsonData
            }
        }
        //3
        return nil
    }
   
    func createMockSession(data: Data,
                            andStatusCode code: Int,
                            andError error: Error?) -> MockURLSession? {

        let response = HTTPURLResponse(url: URL(string: "TestUrl")!, statusCode: code, httpVersion: nil, headerFields: nil)
        return MockURLSession(completionHandler: (data, response, error))
    }
    
    func createMockSessionFromFile(fromJsonFile file: String,
                            andStatusCode code: Int,
                            andError error: Error?) -> MockURLSession? {

        let data = loadJsonData(file: file)
        let response = HTTPURLResponse(url: URL(string: "TestUrl")!, statusCode: code, httpVersion: nil, headerFields: nil)
        return MockURLSession(completionHandler: (data, response, error))
    }
}
