//
//  MyAppErrorHandling.swift
//  StarWarsSpecies
//
//  Created by Saurabh Sikka on 11/10/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import Foundation

public enum MyAppErrorCode: Int {
    case InputStreamReadFailed           = -6000
    case OutputStreamWriteFailed         = -6001
    case ContentTypeValidationFailed     = -6002
    case StatusCodeValidationFailed      = -6003
    case DataSerializationFailed         = -6004
    case StringSerializationFailed       = -6005
    case JSONSerializationFailed         = -6006
    case PropertyListSerializationFailed = -6007
    /*
     Add custom error codes as you see fit
     */
    
}


//
//
//extension Alamofire.Request {
//    public func responseObject<T: ResponseObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self {
//        let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
//            guard error == nil else { return .Failure(error!) }
//            
//            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
//            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
//            
//            switch result {
//            case .Success(let value):
//                if let
//                    response = response,
//                    responseObject = T(response: response, representation: value)
//                {
//                    return .Success(responseObject)
//                } else {
//                    let failureReason = "JSON could not be serialized into response object: \(value)"
//                    /* let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason) */
//                    let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
//                    let error = NSError(domain: "com.MyAppName.error", code: MyAppErrorCode.JSONSerializationFailed.rawValue, userInfo: userInfo)
//                    return .Failure(error)
//                }
//            case .Failure(let error):
//                return .Failure(error)
//            }
//        }
//        
//        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
//    }
//}
