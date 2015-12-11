//
//  URLImageView.swift
//  Where2Go
//
//  Created by Daliso Zuze on 11/12/2015.
//  Copyright © 2015 Daliso Zuze. All rights reserved.
//

import UIKit

class URLImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var imageURL:String? = nil {
        didSet {
            // fetch the image from the internet
            print("getting the cover photo image now...")
            let _ = FoursquareAPIClient.sharedInstance.taskForImage(imageURL!) { data, error in
                if let error = error {
                    print("Photo download error: \(error)")
                }
                if let data = data {
                    // Create the image
                    let image = UIImage(data: data)
                    print("got the image and updating the view now")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.image = image
                    })
                }
            }
        }
    }

}
