# iOSWebServer

首先需要一個建立本地伺服器的套件[GCDWebServer](https://github.com/swisspol/GCDWebServer)：  
* 若直接Clone此專案，則利用Terminal將位置cd到此專案後輸入`pod install`  
* 若無Clone此專案，則一樣先開啟Terminal將位置cd到自己的專案後`pod init`，將出現在專案裡面的Podfile裡面加入`pod "GCDWebServer", "~> 3.0"`後，再回到Terminal上輸入`pod install`  

完成後即可開始架設iOS本地伺服器。
****

##### 進入專案裡面後，在`ViewController`檔案裡面的最頂端輸入：

`import GCDWebServer`

##### 之後自己寫一個Function，用來實體化GCDWebServer與實行必要的流程：

```swift
func initWebServer() {

    //實體化WebServer
    let webServer = GCDWebServer()
    
    //開設本地Api然後用GET的方法
    webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
        //這裡是當有人call這支Api時回傳的格式，這邊是用Json的格式裡面包利用QRcode掃描到的訊息
        return GCDWebServerDataResponse(jsonObject: self.dataArray) 
    })
    
    //之後開始執行本地Server端，後面的Port可以自行決定
    webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
}
```

##### 寫完Function後，記得在viewDidLoad裡面增加此Function：

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    initWebServer()
}
```

# QRcode掃描

##### 一樣在進入專案後，在`ViewController`檔案裡面輸入：

`import AVFoundation`

##### 增加AVFoundation裡面的Delegate：

`AVCaptureMetadataOutputObjectsDelegate`

##### 之後增加下面video的全域變數，用來讓相機的影像投影到手機畫面上，然後陣列用來儲存掃描後的資料：

```swift
var video = AVCaptureVideoPreviewLayer()
var dataArray:[String] = []
```

##### 然後在viewDidLoad增加以下的Code：

```swift
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
```

##### 再來增加Delegate的function，這個用來偵測掃掉的條碼是QrCode或者是BarCode

```swift
func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
}
```

##### 並在此Function增加以下程式碼

```swift 
//metadataObjects為掃描到的物件，若為空值則繼續搜尋
if metadataObjects.count != 0{
    //如果取得metadataObjects並能夠轉換成AVMetadataMachineReadableCodeObject(條碼訊息)，則進去判斷是否為QRcode或是Barcode
    if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
        if object.type == .qr{
            let alert = UIAlertController(title: "QRcode", message: object.stringValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (sender) in
                //按下OK後，就把掃描到的資訊都儲存在陣列裡面
                self.dataArray.append(object.stringValue!)
            }))
            self.present(alert, animated: true, completion: nil)
        }else if object.type == .ean13{
            let alert = UIAlertController(title: "Barcode", message: object.stringValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
```

##### 最後一定要在info裡面增加為何取用相機的隱私權設定

![](https://github.com/Yen-Chen/iOSWebServer/blob/master/info.png)

##### 這樣即可開啟QRcode開始掃描。
