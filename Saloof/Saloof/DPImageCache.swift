//
//  DPImageCache.swift
//
//
//  Created by baophan on 6/22/15.
//
//

import UIKit

class DPImageCache: NSObject {
    static let CACHEPATH = "Saloof.Com.Images.Cache";
    internal static func cleanCace() {
        let cachePath = (NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask,
            true)[0] as! NSString).stringByAppendingPathComponent(CACHEPATH)
        let fileManage: NSFileManager = NSFileManager.defaultManager()
        if fileManage.contentsOfDirectoryAtPath(cachePath, error: nil)?.count != nil{
            var allFiles: Array = fileManage.contentsOfDirectoryAtPath(cachePath, error: nil)!
            for object in enumerate(allFiles) {
                fileManage.removeItemAtPath(cachePath.stringByAppendingPathComponent(
                    object.element as! String),
                    error: nil)
            }
        }
    }
    
    internal static func removeCachedImage(imageAddress: String) {
        var fileMan = NSFileManager.defaultManager()
        var cacheDir = (NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask, true)[0] as! NSString)
            .stringByAppendingPathComponent(DPImageCache.CACHEPATH)
        /*   // to print out contents of cache BEFORE delete
        if fileMan.contentsOfDirectoryAtPath(cacheDir, error: nil)?.count != nil {
            // see if our image exists
            var allFiles: Array = fileMan.contentsOfDirectoryAtPath(cacheDir, error: nil)!
            for object in enumerate(allFiles) {
                println("Before delete object: \(object)")
            }
        }*/
        if fileMan.fileExistsAtPath(cacheDir) {
            var imageId = imageAddress.kf_MD5()
            var imageCacheDir = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory,
                .UserDomainMask, true)[0] as! NSString
            var imageCachePath = imageCacheDir.stringByAppendingPathComponent(DPImageCache.CACHEPATH)
                .stringByAppendingPathComponent(imageId)
            var fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(imageCachePath) {
                //println("File exists to delete at path: \(imageCachePath)")
                fileManager.removeItemAtPath(imageCachePath, error: nil)
                //println("deleted item at path)")
            }
        }
        // to print out contents of cache AFTER delete
        /*
        if fileMan.contentsOfDirectoryAtPath(cacheDir, error: nil)?.count != nil {
            // see if our image exists
            var allFiles: Array = fileMan.contentsOfDirectoryAtPath(cacheDir, error: nil)!
            for object in enumerate(allFiles) {
                println("after delete object: \(object)")
            }
        }*/

    }
    
}

extension UIImageView {
    
    func setImageCacheWithAddress(imageAddress: String, placeHolderImage: UIImage) {
        
        CacheFileManage.checkCachePathOrCreateOne()
        var imageId = imageAddress.kf_MD5()
        var cacheDir = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory,
            .UserDomainMask, true)[0] as! NSString
        var cachePath = cacheDir.stringByAppendingPathComponent(DPImageCache.CACHEPATH)
            .stringByAppendingPathComponent(imageId)
        
        self.image = placeHolderImage
        let data = CacheFileManage.dataAtPath(cachePath)
        
        if data != nil {
            self.image = UIImage(data: data)
            return
        }
        
        if let url = NSURL(string: imageAddress) {
            var request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(
                request,
                queue: NSOperationQueue.mainQueue(),
                completionHandler: {
                    (response: NSURLResponse!, result: NSData!, error: NSError!) -> Void in
                    if error != nil {
                        self.image = placeHolderImage
                        return
                    }
                    if let data = result {
                        self.image = UIImage(data: data)
                        data.writeToFile("\(cachePath)", atomically: true)
                    }
            })
        }
    }
    
    private class CacheFileManage {
        
        private static func dataAtPath(cachePath: String) -> NSData! {
            var fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(cachePath) {
                return NSData(contentsOfFile: cachePath)
            }
            else {
                return nil
            }
        }
        
        private static func checkCachePathOrCreateOne() {
            var fileMan = NSFileManager.defaultManager()
            var cacheDir = (NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory,
                .UserDomainMask, true)[0] as! NSString)
                .stringByAppendingPathComponent(DPImageCache.CACHEPATH)
            if !fileMan.fileExistsAtPath(cacheDir) {
                fileMan.createDirectoryAtPath(
                    cacheDir,
                    withIntermediateDirectories: false,
                    attributes: nil,
                    error: nil)
            }
        }
        
    }
    
}

extension String {
    func kf_MD5() -> String {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            let MD5Calculator = MD5(data)
            let MD5Data = MD5Calculator.calculate()
            let resultBytes = UnsafeMutablePointer<CUnsignedChar>(MD5Data.bytes)
            let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.length)
            var MD5String = ""
            for c in resultEnumerator {
                MD5String += String(format: "%02x", c)
            }
            return MD5String
        } else {
            return self
        }
    }
}

func arrayOfBytes<T>(value:T, length:Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (sizeofValue(value) * 8)
    var v = value
    
    var valuePointer = UnsafeMutablePointer<T>.alloc(1)
    valuePointer.memory = value
    
    var bytesPointer = UnsafeMutablePointer<UInt8>(valuePointer)
    var bytes = [UInt8](count: totalBytes, repeatedValue: 0)
    for j in 0..<min(sizeof(T),totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).memory
    }
    
    valuePointer.destroy()
    valuePointer.dealloc(1)
    
    return bytes
}

extension Int {
    func bytes(_ totalBytes: Int = sizeof(Int)) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
}

extension NSMutableData {
    func appendBytes(arrayOfBytes: [UInt8]) {
        self.appendBytes(arrayOfBytes, length: arrayOfBytes.count)
    }
}

class HashBase {
    
    var message: NSData
    
    init(_ message: NSData) {
        self.message = message
    }
    
    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ len:Int = 64) -> NSMutableData {
        var tmpMessage: NSMutableData = NSMutableData(data: self.message)
        
        // Step 1. Append Padding Bits
        tmpMessage.appendBytes([0x80]) // append one bit (UInt8 with one bit) to message
        
        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.length;
        var counter = 0;
        while msgLength % len != (len - 8) {
            counter++
            msgLength++
        }
        var bufZeros = UnsafeMutablePointer<UInt8>(calloc(counter, sizeof(UInt8)))
        tmpMessage.appendBytes(bufZeros, length: counter)
        
        return tmpMessage
    }
}

func rotateLeft(v:UInt32, n:UInt32) -> UInt32 {
    return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
}

class MD5 : HashBase {
    
    private let s: [UInt32] = [7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
        5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
        4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
        6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21]
    
    private let k: [UInt32] = [0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,
        0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,
        0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,
        0x6b901122,0xfd987193,0xa679438e,0x49b40821,
        0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,
        0xd62f105d,0x2441453,0xd8a1e681,0xe7d3fbc8,
        0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,
        0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,
        0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,
        0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,
        0x289b7ec6,0xeaa127fa,0xd4ef3085,0x4881d05,
        0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
        0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,
        0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,
        0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,
        0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391]
    
    private let h:[UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
    
    func calculate() -> NSData {
        var tmpMessage = prepare()
        
        // hash values
        var hh = h
        
        // Step 2. Append Length a 64-bit representation of lengthInBits
        var lengthInBits = (message.length * 8)
        var lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage.appendBytes(reverse(lengthBytes));
        
        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        var leftMessageBytes = tmpMessage.length
        for (var i = 0; i < tmpMessage.length; i = i + chunkSizeBytes, leftMessageBytes -= chunkSizeBytes) {
            let chunk = tmpMessage.subdataWithRange(NSRange(location: i, length: min(chunkSizeBytes,leftMessageBytes)))
            let bytes = tmpMessage.bytes;
            
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            var M:[UInt32] = [UInt32](count: 16, repeatedValue: 0)
            let range = NSRange(location:0, length: M.count * sizeof(UInt32))
            chunk.getBytes(UnsafeMutablePointer<Void>(M), range: range)
            
            // Initialize hash value for this chunk:
            var A:UInt32 = hh[0]
            var B:UInt32 = hh[1]
            var C:UInt32 = hh[2]
            var D:UInt32 = hh[3]
            
            var dTemp:UInt32 = 0
            
            // Main loop
            for j in 0..<k.count {
                var g = 0
                var F:UInt32 = 0
                
                switch (j) {
                case 0...15:
                    F = (B & C) | ((~B) & D)
                    g = j
                    break
                case 16...31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                    break
                case 32...47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                    break
                case 48...63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                    break
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ k[j] &+ M[g]), s[j])
                A = dTemp
            }
            
            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        
        var buf: NSMutableData = NSMutableData();
        hh.map({ (item) -> () in
            var i:UInt32 = item.littleEndian
            buf.appendBytes(&i, length: sizeofValue(i))
        })
        
        return buf.copy() as! NSData;
    }
}
