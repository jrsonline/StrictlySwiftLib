//
//  DataHelper.swift
//  
//
//  Created by RedPanda on 31-Oct-19.
//

import Foundation

// thanks to 'marius' https://stackoverflow.com/questions/39075043/how-to-convert-data-to-hex-string-in-swift?rq=1
extension Data {
    var hexEncodedString: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
