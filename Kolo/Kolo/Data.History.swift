//
//  Data.History.swift
//  Kolo
//
//  Created by Ivan Kh on 28.12.2021.
//

import Foundation
import CoreData


fileprivate extension String {
    static let history = "History"
    static let count = "count"
    static let host = "host"
}


extension History {
    static func mostVisitedSites(_ context: NSManagedObjectContext) throws -> [String] {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: .history)
        let nameExpr = NSExpression(forKeyPath: .host)
        let countExpr = NSExpressionDescription()
        let entity = History.entity()
        
        countExpr.name = .count
        countExpr.expression = NSExpression(forFunction: "\(String.count):", arguments: [ nameExpr ])
        countExpr.expressionResultType = .integer64AttributeType

        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToGroupBy = [ entity.propertiesByName[.host]! ]
        fetchRequest.propertiesToFetch = [ entity.propertiesByName[.host]!, countExpr ]

        let fetchResult = try context.fetch(fetchRequest)
        let result = fetchResult
            .sorted { ($0[String.count] as! Int) > ($1[String.count] as! Int) }
            .compactMap { $0[String.host] as? String }
        
        return result
    }
    
    static func add(to context: NSManagedObjectContext, url: URL) throws {
        let entity = History(context: context)
        
        entity.url = url.absoluteString
        entity.host = url.host
        
        try context.save()
    }
}
