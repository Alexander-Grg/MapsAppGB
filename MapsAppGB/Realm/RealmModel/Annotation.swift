//
//  Annotation.swift
//  MapsAppGB
//
//  Created by Alexander Grigoryev on 7.11.2022.
//

import RealmSwift
import Foundation

class AnnotationRealm: Object  {
    @Persisted var latitude: Double = 0.0
    @Persisted var longitute: Double = 0.0
    @Persisted(primaryKey: true) var id = UUID()

    convenience init(original: AnnotationOriginal) {
        self.init()
        self.latitude = original.lat
        self.longitute = original.long
    }
}

class AnnotationOriginal {
    var lat: Double
    var long: Double
    
    init(lat: Double, long: Double) {
        self.lat = lat
        self.long = long
    }
}
