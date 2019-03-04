//
//  ViewController.swift
//  DetectionApps
//
//  Created by Handy Handy on 22/11/18.
//  Copyright © 2018 Handy Handy. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
	
	let model = RunWalk()
	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    
    @IBAction func searchDidTap(_ sender: UIButton) {
        // object responsible to handle photo library / camera access
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        // alert controller > element to present message to the user
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // add button to the alert
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            // define the source for image picker
            imagePicker.sourceType = .photoLibrary
            // present the image picker
            self.present(imagePicker, animated: true, completion: nil)
        }))
		alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
			// define the source for image picker
			imagePicker.sourceType = .camera
			// present the image picker
			self.present(imagePicker, animated: true, completion: nil)
		}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action) in
            print("cancel")
        }))
        
        
        // function to present viewControllers
        present(alert, animated: true, completion: nil)
    }
    
    func updateResult(currentImage: UIImage) {
        // function for update the result of image and calculate the probability
		do{
			guard let image = currentImage.pixelBuffer() else {return}
			guard let item = try? model.prediction(image: image) else{return}
			
			print(item.classLabel)
			print(item.classLabelProbs)
			
			guard let probability = item.classLabelProbs["\(item.classLabel)"] else{return}
			resultLabel.text = "\(item.classLabel) ~ \(round(probability * 100))%"
		}catch{
			print("Error \(error.localizedDescription)")
		}
    }
    

}


// MARK: - UIImagePickerControllerDelegate
// the image picker uses a navigation controller structure, so we need to include the navigation delegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // function triggered when the user cancel the photo selection
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        
        // after cancel dismiss the picker screen
        picker.dismiss(animated: true, completion: nil)
    }
    
    // function triggered when the user selects a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get the selected image
        // the info parameter has a lot of information about the image
        // the key to access the original image is UIImagePickerControllerOriginalImage
        guard let photo = info[.originalImage] as? UIImage else {return}
        
        // present the selected image in imageView
        guard let image = photo.resizeTo(size: 224.0) else {return}
        imageView.image = image
        updateResult(currentImage: image)
        // after getting the image dismiss the picker screen
        picker.dismiss(animated: true, completion: nil)
    }
    
}


