//
//  ViewController.swift
//  Image_Text_Detection
//
//  Created by Ahmet Turan Balkan on 22.01.2018.
//  Copyright © 2018 ATB. All rights reserved.
//

import UIKit
import Vision
import ImageIO

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var textImageView: UIImageView!
    
    var convertedCIImage : CIImage?
    
    lazy var textRectangleRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.textObservationCompleted)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.launchCharacterDetection()
    }
    
    func launchCharacterDetection() {
        guard let uiImage = UIImage.init(named: "line-indent.jpg")
            else { fatalError("could not load uiimage") }
        guard let ciImage = CIImage(image: uiImage)
            else { fatalError("cannot convert uiimage to ciimage") }
        
        convertedCIImage = ciImage.oriented(forExifOrientation: Int32(uiImage.imageOrientation.rawValue))
        
        textImageView.image = uiImage
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation:  CGImagePropertyOrientation(rawValue: UInt32(uiImage.imageOrientation.rawValue))!)
        
  
      
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([self.textRectangleRequest])
                
            } catch {
                print(error)
            }
        }
    }
    
    func textObservationCompleted (request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNTextObservation]
            else { print("something went wrong with VNTextObservation")
                return
        }
        guard observations.first != nil else {
            return
        }
        DispatchQueue.main.async {
            self.textImageView.subviews.forEach({ (s) in
                s.removeFromSuperview()
            })
            for box in observations {
                let view = Helper.createOutlineRect(withColor: UIColor.red)
                view.frame = Helper.transformRect(fromRect: box.boundingBox, toViewRect: self.textImageView)
                self.textImageView.image = self.textImageView.image
                self.textImageView.addSubview(view)
                
                guard let chars = box.characterBoxes else {
                    print("no characters found")
                    return
                }
                for char in chars
                {
                    let view = Helper.createOutlineRect(withColor: UIColor.green)
                    view.frame = Helper.transformRect(fromRect: char.boundingBox, toViewRect: self.textImageView)
                    self.textImageView.image = self.textImageView.image
                    self.textImageView.addSubview(view)
                }
            }
        }
    }
    
}

