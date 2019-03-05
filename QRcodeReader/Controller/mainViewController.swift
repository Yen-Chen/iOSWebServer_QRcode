//
//  mainViewController.swift
//  QRcodeReader
//
//  Created by Huang on 2018/9/27.
//  Copyright © 2018 陳鍵群. All rights reserved.
//

import UIKit
import AVFoundation
import GCDWebServer

class mainViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    var video = AVCaptureVideoPreviewLayer()
    var dataArray:[String] = []
    @IBOutlet weak var scanView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWebServer()
        //用來管理擷取活動和協調輸人及輸出數據流的對象
        let session = AVCaptureSession()

        //取得後鏡頭
        let captureDevice = AVCaptureDevice.default(for: .video)

        do{
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        }
        catch{
            print("ERROR")
        }

        //AVCapturePhotoOutput 將鏡頭資料輸出成靜態圖片
        //AVCaptureMovieFileOutput 將鏡頭資料與麥克風資料輸出成QuickTime格式檔案
        //AVCaptureVideoDataOutput 將鏡頭資料輸出成原始未壓縮資料，讓我們可以進行特別處理，例如加上特效
        //AVCaptureAudioDataOutput 將麥克風資料輸出成原始資料，讓我們可以進一步處理
        //AVCaptureMetadataOutput 辨識鏡頭掃描到的條碼資料

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.ean13]
        video = AVCaptureVideoPreviewLayer(session: session) //用來顯示相機畫面
        video.frame = scanView.frame
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill //設置相機畫面的顯示方式
        view.layer.addSublayer(video)
        view.bringSubview(toFront: scanView)

        session.startRunning()

    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //metadataObjects為掃描到的物件，若為空值則繼續搜尋
        if metadataObjects.count != 0{
            //如果取得metadataObjects並能夠轉換成AVMetadataMachineReadableCodeObject(條碼訊息)，則進去判斷是否為QRcode或是Barcode
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                if object.type == .qr{
                    let alert = UIAlertController(title: "QRcode", message: object.stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (sender) in
                        self.dataArray.append(object.stringValue!)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }else if object.type == .ean13{
                    let alert = UIAlertController(title: "QRcode", message: object.stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func initWebServer() {
        let webServer = GCDWebServer()
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(jsonObject: self.dataArray)
        })
        webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
        
        print("Visit \(webServer.serverURL) in your web browser")
    }
    
}



