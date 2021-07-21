//
//  Extension.swift
//  testcutimage
//
//  Created by User on 8/6/2021.
//

import UIKit

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
extension UIViewController {
  func presentDetail(_ viewControllerToPresent: UIViewController) {
    if let nav = UIApplication.topViewController()?.navigationController {
      nav.pushViewController(viewControllerToPresent, animated: true)
    }else {
      UIApplication.topViewController()?.present(viewControllerToPresent, animated: true, completion: nil)
    }
  }
  
  func dismissDetail() {
    if let nav = UIApplication.topViewController()?.navigationController {
      nav.popViewController(animated: true)
    }else {
      UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
  }
}
extension UIImage {
  var cgImagePropertyOrientation: CGImagePropertyOrientation {
    switch self.imageOrientation {
    case .up:
      return CGImagePropertyOrientation.up
    case .down:
      return CGImagePropertyOrientation.down
    case .left:
      return CGImagePropertyOrientation.left
    case .right:
      return CGImagePropertyOrientation.right
    case .upMirrored:
      return CGImagePropertyOrientation.upMirrored
    case .downMirrored:
      return CGImagePropertyOrientation.downMirrored
    case .leftMirrored:
      return CGImagePropertyOrientation.leftMirrored
    case .rightMirrored:
      return CGImagePropertyOrientation.rightMirrored
    default:
      return CGImagePropertyOrientation.up
    }
  }
  
  func fixOrientation() -> CIImage? {
    
    guard let cgImage = self.cgImage else {
      return nil
    }
    
    if self.imageOrientation == UIImage.Orientation.up {
      return CIImage(image: self)
    }
    
    let width  = self.size.width
    let height = self.size.height
    
    var transform = CGAffineTransform.identity
    
    switch self.imageOrientation {
    case .down, .downMirrored:
      transform = transform.translatedBy(x: width, y: height)
      transform = transform.rotated(by: CGFloat.pi)
      
    case .left, .leftMirrored:
      transform = transform.translatedBy(x: width, y: 0)
      transform = transform.rotated(by: 0.5*CGFloat.pi)
      
    case .right, .rightMirrored:
      transform = transform.translatedBy(x: 0, y: height)
      transform = transform.rotated(by: -0.5*CGFloat.pi)
      
    case .up, .upMirrored:
      break
    default:
      break;
    }
    
    switch self.imageOrientation {
    case .upMirrored, .downMirrored:
      transform = transform.translatedBy(x: width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
      
    case .leftMirrored, .rightMirrored:
      transform = transform.translatedBy(x: height, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
      
    default:
      break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    guard let colorSpace = cgImage.colorSpace else {
      return nil
    }
    
    guard let context = CGContext(
      data: nil,
      width: Int(width),
      height: Int(height),
      bitsPerComponent: cgImage.bitsPerComponent,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
    ) else {
      return nil
    }
    
    context.concatenate(transform);
    
    switch self.imageOrientation {
    
    case .left, .leftMirrored, .right, .rightMirrored:
      // Grr...
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
      
    default:
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    // And now we just create a new UIImage from the drawing context
    guard let newCGImg = context.makeImage() else {
      return nil
    }
    
    //        let img = UIImage(cgImage: newCGImg)
    let ciImage = CIImage(cgImage: newCGImg)
    return ciImage;
  }
  
  func resizeImage(targetSize: CGSize) -> UIImage? {
    let size = self.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
      newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
      newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(origin: .zero, size: newSize)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  convenience init?(_ pathUrl: URL, fileName: String) {
    let pUrl = pathUrl.appendingPathComponent(fileName)
    self.init(contentsOfFile: pUrl.absoluteString)
  }
}
