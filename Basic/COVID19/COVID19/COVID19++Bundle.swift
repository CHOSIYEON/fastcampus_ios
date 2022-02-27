//
//  COVID19++Bundle.swift
//  COVID19
//
//  Created by Cho Si Yeon on 2022/02/27.
//

import Foundation

extension Bundle {
    var apiKey: String {
        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["API_KEY"] as? String else { fatalError("INFO 에 API_KEY 설정을 해주세요!")}
        return key
    }
}
