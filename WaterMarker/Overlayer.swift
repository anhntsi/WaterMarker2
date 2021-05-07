//
//  Overlayer.swift
//  WaterMarker
//
//  Created by Матвей Анисович on 3/24/21.
//

import Cocoa
import MetalPetal

enum WatermarkPosition {
    case topLeft, topRight, topCenter, center, leftCenter, rightCenter, bottomLeft, bottomRight, bottomCenter
    
    func getValue(imageWidth: Int, imageHeight: Int, watermarkWidth: Int, watermarkHeight: Int) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: watermarkWidth / 2, y: watermarkHeight / 2)
        case .topRight:
            return CGPoint(x: imageWidth - watermarkWidth / 2, y: watermarkHeight / 2)
        case .topCenter:
            return CGPoint(x: imageWidth / 2, y: watermarkHeight / 2)
        case .center:
            return CGPoint(x: imageWidth / 2, y: imageHeight / 2)
        case .leftCenter:
            return CGPoint(x: watermarkWidth / 2, y: imageHeight / 2)
        case .rightCenter:
            return CGPoint(x: imageWidth - watermarkWidth / 2, y: imageHeight / 2)
        case .bottomLeft:
            return CGPoint(x: watermarkWidth / 2, y: imageHeight - watermarkHeight / 2)
        case .bottomRight:
            return CGPoint(x: imageWidth - watermarkWidth / 2, y: imageHeight - watermarkHeight / 2)
        case .bottomCenter:
            return CGPoint(x: imageWidth / 2, y: imageHeight - watermarkHeight / 2)
        }
    }
}

class Overlayer {
    func overlay(_ img1cg:CGImage, with img2cg:CGImage, scaling: Double, alpha: Double) -> CGImage? {
        let img1 = MTIImage(cgImage: img1cg, isOpaque: false)
        let img2 = MTIImage(cgImage: img2cg, isOpaque: false).premultiplyingAlpha()
        
        // Watermark Layer
        let aspectWatermark = Double(img2cg.height) / Double(img2cg.width)
        
        let watermarkWidth = Int(Double(img1cg.width) * scaling)
        let watermarkHeight = Int(scaling * Double(img1cg.width) * Double(aspectWatermark))
        let position = WatermarkPosition.topCenter.getValue(imageWidth: img1cg.width, imageHeight: img1cg.height, watermarkWidth: watermarkWidth, watermarkHeight: watermarkHeight)
        let layer = MTILayer(content: img2, layoutUnit: .pixel, position: position, size: CGSize(width: watermarkWidth, height: watermarkHeight), rotation: 0, opacity: Float(alpha), blendMode: .normal)
        
        let filter = MTIMultilayerCompositingFilter()
        
        
        
        filter.inputBackgroundImage = img1
        filter.layers = [layer]
        
        
        guard let image = filter.outputImage else { return nil }
        
        
        let options = MTIContextOptions()
        guard let device = MTLCreateSystemDefaultDevice(), let context = try? MTIContext(device: device, options: options) else {
            return nil
        }

        do {
            let filteredImage = try context.makeCGImage(from: image)
            return filteredImage
        } catch {
            print(error)
        }
        return nil
    }
}
