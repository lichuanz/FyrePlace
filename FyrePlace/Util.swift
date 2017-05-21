//
//  Util.swift
//  FyrePlace
//
//  Created by Steven Zhang on 2016-06-23.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import UIKit

func resizeImage(image: UIImage?, newSize: CGSize) -> UIImage {
    //
    var scaleFactor: CGFloat = 1.0
    let image = image
    var newSize = newSize
    if (image!.size.width > image!.size.height) {
        scaleFactor = image!.size.width / image!.size.height
        newSize.height = newSize.height / scaleFactor
    }
    else {
        scaleFactor = image!.size.height / image!.size.width;
        newSize.width = newSize.width / scaleFactor;
    }
    let newRect = CGRect(origin: CGPointZero, size: newSize)
    let imageRef = image!.CGImage
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
    let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
    CGContextConcatCTM(context, flipVertical)
    CGContextDrawImage(context, newRect, imageRef)
    let newImageRef = CGBitmapContextCreateImage(context)! as CGImage
    let newImage = UIImage(CGImage: newImageRef, scale: 1.0, orientation: image!.imageOrientation)
    UIGraphicsEndImageContext()
    return newImage
}



