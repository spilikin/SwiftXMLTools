//
//  Infoset+QName.swift
//  XMLTools
//  
//  Created on 06.07.18
//

import Foundation

extension Infoset {
    
    public var qnameValue: QName? {
        guard let name = stringValue else {
            return nil
        }

        if name.range(of: ":") != nil {
            let tuple = name.components(separatedBy: ":")
            if let uri = contextElement()?.resolveURI(forPrefix: tuple[0]) {
                return QName(tuple[1], uri: uri)
            } else if let uri = contextElement()?.resolveURIFromSource(forPrefix: tuple[0]) {
                return QName(tuple[1], uri: uri)
            }

            return nil
        } else if namespaceContext.defaultURI != nil {
            return QName(name, uri: namespaceContext.defaultURI!)
        }
        return QName(name)
    }
    
}
