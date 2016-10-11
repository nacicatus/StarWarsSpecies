//
//  Species.swift
//  StarWarsSpecies
//
//  Created by Saurabh Sikka on 11/10/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum SpeciesFields: String {
    case Name = "name"
    case Classification = "classification"
    case Designation = "designation"
    case AverageHeight = "average_height"
    case SkinColors = "skin_colors"
    case HairColors = "hair_colors"
    case EyeColors = "eye_colors"
    case AverageLifespan = "average_lifespan"
    case Homeworld = "homeworld"
    case Language = "language"
    case People = "people"
    case Films = "films"
    case Created = "created"
    case Edited = "edited"
    case Url = "url"
}

class StarWarsSpecies {
    var idNumber: Int?
    var name: String?
    var classification: String?
    var designation: String?
    var averageHeight: Int?
    var skinColors: String?
    var hairColors: String? // TODO: array
    var eyeColors: String? // TODO: array
    var averageLifespan: Int?
    var homeworld: String?
    var language: String?
    var people: [String]?
    var films: [String]?
    var created: NSDate?
    var edited: NSDate?
    var url: String?
    
    
    required init(json: JSON, id: Int?) {
        self.idNumber = id
        self.name = json[SpeciesFields.Name.rawValue].stringValue
        self.classification = json[SpeciesFields.Classification.rawValue].stringValue
        self.designation = json[SpeciesFields.Designation.rawValue].stringValue
        self.averageHeight = json[SpeciesFields.AverageHeight.rawValue].int
    }
    
    
    // Here comes the Alamofire and SwiftyJSON
    
    // MARK: - Endpoints
    class func endPointForSpecies() -> String {
        return "https://swapi.co/api/species/"
    }
    
    /*
     We’ll use a custom response serializer & accessor method with Alamofire to process the JSON into StarWarsSpecies and SpeciesWrapper objects with SwiftyJSON to keep the JSON handling concise.
     */
    
    // To keep the details of the internals of SpeciesWrapper within the SpeciesWrapper/StarWarsSpecies classes, we’ve defined one private function that gets us the SpeciesWrapper from a given URL string.
    
    private class func getSpeciesAtPath(path: String, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
        
        /* Within getSpeciesAtPath we’re making sure that the URL string starts with https:// instead of http:
         That’s because swapi.co supports HTTPS but the URLs it returns in the JSON have http:// instead. This tweak is needed because of App Transport Security in iOS 9.
         */
        
        let securePath = path.stringByReplacingOccurrencesOfString("http://", withString: "https://", options: .AnchoredSearch)
        Alamofire.request(.GET, securePath).responseSpeciesArray { (response) in
            completionHandler(response.result.value, response.result.error)
        }
        
    }
    
    
    // Then to actually access that function we’ve defined 2 convenience functions: getSpecies load the initial species (from GET .../species/)....
    
    class func getSpecies(completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
        getSpeciesAtPath(StarWarsSpecies.endPointForSpecies(), completionHandler: completionHandler)
    }
    
    
    // .... and getMoreSpecies takes a SpeciesWrapper and loads the species at the URL in the next property.
    
    class func getMoreSpecies(wrapper: SpeciesWrapper?, completionHandler: (SpeciesWrapper?, NSError?) -> Void) {
        guard let nextPath = wrapper?.next else {
            completionHandler(nil, nil)
            return
        }
        getSpeciesAtPath(nextPath, completionHandler: completionHandler)
    }
    
    
    
    
} // end of class declaration


// Now we need to actually implement responseSpeciesArray with its custom response serializer:


extension Alamofire.Request {
    
    
    func responseSpeciesArray(completionHandler: Response<SpeciesWrapper, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<SpeciesWrapper, NSError> { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
            case .Success(let value):
                
                let json = SwiftyJSON.JSON(value)
                let wrapper = SpeciesWrapper()
                wrapper.next = json["next"].stringValue
                wrapper.previous = json["previous"].stringValue
                wrapper.count = json["count"].intValue
                
                var allSpecies = [StarWarsSpecies]()
                print(json)
                let results = json["results"]
                print(results)
                for jsonSpecies in results
                {
                    print(jsonSpecies.1)
                    let species = StarWarsSpecies(json: jsonSpecies.1, id: Int(jsonSpecies.0))
                    allSpecies.append(species)
                }
                wrapper.species = allSpecies
                return .Success(wrapper)
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer,
                        completionHandler: completionHandler)
    }
    
    

    
}







