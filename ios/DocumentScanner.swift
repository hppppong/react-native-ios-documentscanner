//
//  DocumentScanner.swift
//  AppTest
//
//  Created by User on 14/5/2021.
//

import UIKit
import VisionKit
import Vision
import React

@objc(RNDocumentScanner)
@available(iOS 13.0, *)
class RNDocumentScanner: NSObject {
    
    let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var callback: RCTResponseSenderBlock!
    var callbackParams: [Any] = []
    let keyWindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow})
    var isReturned: Bool = false
    var originalImagePath: String = ""
    var imagePath: String = ""
    
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    func createDirectories(_ path: String) -> String {
        var directoryComp = path.split(separator: "/")
        
        if !directoryComp.contains("Applications") {
            let docuDirectoryComp = documentsDirectory.absoluteString.replacingOccurrences(of: "file://", with: "").split(separator: "/")
            directoryComp = docuDirectoryComp + directoryComp
        }
        
        let directory = directoryComp.joined(separator: "/").replacingOccurrences(of: "file://", with: "")
        let directoryURL = URL(fileURLWithPath: directory)
        if !FileManager().fileExists(atPath: directoryURL.absoluteString) {
            try? FileManager().createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: [:])
        }
        
        return directoryURL.absoluteString
    }
    
    @objc func startScan(_ savePath: NSDictionary, success callback: @escaping RCTResponseSenderBlock) {
        
        guard VNDocumentCameraViewController.isSupported else {
            return
        }
        
        self.isReturned = false
        self.callback = callback
        
        let originalImagePath = savePath.value(forKey: "originalImagePath") as? String ?? ""
        self.originalImagePath = originalImagePath
        let imagePath = savePath.value(forKey: "imagePath") as? String ?? ""
        self.originalImagePath = createDirectories(originalImagePath as String)
        self.imagePath = createDirectories(imagePath as String)
        
        DispatchQueue.main.async {
            let scannerVC = VNDocumentCameraViewController()
            scannerVC.delegate = self
            UIApplication.topViewController()?.presentDetail(scannerVC)
        }
    }
    
    @objc func dismiss() {
        if !isReturned {
            self.callback(self.callbackParams)
            isReturned = true
        }
        
        DispatchQueue.main.async {
            UIApplication.topViewController()?.dismissDetail()
        }
    }
    
    @objc func detectRectangle(_ path: NSString, success callback: @escaping RCTResponseSenderBlock) {
        let p = URL(fileURLWithPath: path as String)
        
        self.isReturned = false
        self.callback = callback
        
        let orientation = UIImage(contentsOfFile: path as String)?.cgImagePropertyOrientation
        let requestHandler = VNImageRequestHandler(url: p, orientation: orientation ?? .up)
        
        let request = VNDetectRectanglesRequest { request, error in
            self.completedVisionRequest(request, error: error)
        }
        
        request.maximumObservations = 5
        request.maximumAspectRatio = 1.0
        
        request.minimumAspectRatio = 0.3
        request.minimumSize = 0.2
        request.minimumConfidence = 0.5
        
        // perform additional request configuration
        request.usesCPUOnly = false //allow Vision to utilize the GPU
        
        DispatchQueue.global().async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Error: Rectangle detection failed - vision request failed.")
            }
        }
    }
    
    func completedVisionRequest(_ request: VNRequest?, error: Error?) {
        // Only proceed if a rectangular image was detected.
        guard let rectangles = request?.results as? [VNRectangleObservation] else {
            guard let error = error else { return }
            print("Error: Rectangle detection failed - Vision request returned an error. \(error.localizedDescription)")
            
            if !isReturned {
                isReturned = true
            }
            
            return
        }
        
        let rect = [rectangles.max(by: { ($0.boundingBox.width * $0.boundingBox.height) < ($1.boundingBox.width * $1.boundingBox.height) }) ?? .init()]
        // do stuff with your rectangles
        let dict = rect.map({
            Rectangle(x: $0.boundingBox.origin.x,
                      y: $0.boundingBox.origin.y,
                      width: $0.boundingBox.width,
                      height: $0.boundingBox.height)
                .nsDictionary
        })
        
        if !isReturned {
            callback(dict)
            isReturned = true
        }
        
    }
}

@available(iOS 13.0, *)
extension RNDocumentScanner: VNDocumentCameraViewControllerDelegate{
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // save scan
        var originalImageList: [String] = []
        var imageList: [String] = []
        
        let originalURL = scan.value(forKey: "_scannedDocumentImageDirectoryURL") as? URL ?? documentsDirectory
        let originalPath = URL(string: originalURL.absoluteString.replacingOccurrences(of: "file://", with: "")) ?? documentsDirectory
        var originalImages = (try? FileManager().contentsOfDirectory(atPath: originalPath.absoluteString)) ?? []
        
        let originalUIImages = originalImages.map({ UIImage(contentsOfFile: originalPath.appendingPathComponent($0).absoluteString) ?? UIImage()
        })
        
        let maxSize = originalUIImages.max(by: {($0.size.width * $0.size.height) < ($1.size.width * $1.size.height)})?.size ?? CGSize.zero
        originalImages = originalImages.filter({ UIImage(originalPath, fileName: $0)?.size == maxSize })
        
        originalImages = originalImages.sorted(by: {
            let currOriginalImageUrl = originalPath.appendingPathComponent($0)
            let currOriginalImagePath = currOriginalImageUrl.absoluteString
            let currModifyDate = (try? FileManager().attributesOfItem(atPath: currOriginalImagePath)[.creationDate] as? Date) ?? Date()
            
            let nextOriginalImageUrl = originalPath.appendingPathComponent($1)
            let nextOriginalImagePath = nextOriginalImageUrl.absoluteString
            let nextModifyDate = (try? FileManager().attributesOfItem(atPath: nextOriginalImagePath)[.creationDate] as? Date) ?? Date()
            return nextModifyDate > currModifyDate
        })
        
        for index in 0..<scan.pageCount {
            let fileName = UUID().uuidString
            //original
            let originalImage = originalImages[index]
            let originalImagePath = originalPath.appendingPathComponent(originalImage)
            let originalUIImage = UIImage(contentsOfFile: originalImagePath.absoluteString)
            let originalImageData = originalUIImage?.pngData()
            let originalDestPath = URL(string: self.originalImagePath + "/" + fileName + ".png") ?? documentsDirectory
            
            //cropped
            let scannedImage = scan.imageOfPage(at: index)
            let imageData = scannedImage.pngData()
            let destPath = URL(string: self.imagePath + "/" + fileName + ".png") ?? documentsDirectory
            
            do {
                try originalImageData?.write(to: originalDestPath)
                originalImageList.append(originalDestPath.absoluteString.replacingOccurrences(of: "file://", with: ""))
                
                try imageData?.write(to: destPath)
                imageList.append(destPath.absoluteString.replacingOccurrences(of: "file://", with: ""))
                
            } catch (let error) {
                print(error)
            }
        }
        
        let dict = ["originalImageList": originalImageList, "imageList": imageList] as NSDictionary
        self.callbackParams = [dict]
        self.dismiss()
        
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        self.callbackParams = []
        self.dismiss()
    }
}
