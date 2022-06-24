//
//  Note+Ext.swift
//  Mooskine
//
//  Created by Mitchell Salcido on 6/22/22.
//  Copyright © 2022 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Note {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
        self.text = "New Note"
    }
}
