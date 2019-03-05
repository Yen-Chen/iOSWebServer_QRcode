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
