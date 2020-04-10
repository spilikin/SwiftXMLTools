//
//  Infoset+Parent.swift
//  XMLTools
//
//  Created on 28.06.18
//

import Foundation

extension Infoset {
    public func parent() -> Infoset {
        if selectedNodes.count > 0 {
            if let parentNode = selectedNodes[0].parentNode {
                return Infoset(parentNode)
            }
        }
        return Infoset.EMPTY
    }
}
