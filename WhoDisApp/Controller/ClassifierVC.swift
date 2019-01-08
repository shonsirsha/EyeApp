//
//  ClassifierVC.swift
//  WhoDisApp
//
//  Created by Sean Saoirse on 26/11/18.
//  Copyright © 2018 Sean Saoirse. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ClassifierVC: UIViewController {

    @IBOutlet weak var classficationData: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var classificationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func processClassifications(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let classifications = request.results as? [VNClassificationObservation] else {
                self.classificationLabel.text = "Unable to classify image.\n\(error?.localizedDescription ?? "Error")"
                return
            }
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                let topClassifications = classifications.prefix(1)
                let descriptions = topClassifications.map { classification in
                    return String(format: "%.2f", classification.confidence * 100) + "% – " + classification.identifier
                }
                self.classificationLabel.text = "Classification:\n" + descriptions.joined()
            }
        }
    }
    
    func updateClassification(image: UIImage){
        classificationLabel.text = "Classifying..."
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)), let ciImage = CIImage(image: image) else {
            //display another error wtf
            displayError()
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async{
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            
            do{
                try handler.perform([self.classificationRequest])
            }catch{
                print("Failed to perform classification. \n \(error.localizedDescription)")
            }

        }
        
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do{
            let model = try VNCoreMLModel(for: FruitClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                //process the classifications
                self.processClassifications(request: request, error: error)
                
            })
            
            request.imageCropAndScaleOption = .centerCrop
            return request
        }catch{
            fatalError("Failed to load ML Model \(error)")
        }
    }()
    
   
    func displayError() {
        classificationLabel.text = "Something went wrong...\n Please try again."
    }

    @IBAction func cameraBtnPressed(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }

}

extension ClassifierVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {fatalError("No image returned...")}
        
        imageView.image = image
        
        updateClassification(image: image)
        
        //use image to make predicitons
        
    }
}
