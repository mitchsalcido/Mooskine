//
//  Notebook+Ext.swift
//  Mooskine
//
//  Created by Mitchell Salcido on 6/22/22.
//  Copyright © 2022 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Notebook {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
    }
}
