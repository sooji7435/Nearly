//
//  RealtimeDBViewModel.swift
//  Nearly
//
//  Created by 박윤수 on 1/7/26.
//

import FirebaseDatabase
import Combine


class RealtimeDBViewModel: ObservableObject {
    
    @Published var ref: DatabaseReference! = Database.database().reference()
    
    let dateFormatter = DateFormatter()


    
    
    

}

