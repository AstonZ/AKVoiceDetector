//
//  VoiceTransViewController.swift
//  AKVoiceDetector
//
//  Created by Aston K Mac on 2017/10/27.
//  Copyright © 2017年 LowBee Tech. All rights reserved.
//

import UIKit


/// translate voice to Chinese charactors
class VoiceTransViewController: UIViewController {
    @IBOutlet weak var lbResult: UILabel!
    
    @IBOutlet weak var btnControl: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }

    
    @IBAction func onControl(_ sender: Any) {
        VoiceRecorder.shared.startRecognize { (status, tip) in
            self.updateUIWith(status: status, tip: tip)
        }
    }
    
}

extension VoiceTransViewController {
    
    private func updateUIWith(status: VoiceRecorder.RecognizerStatus, tip: String) -> () {
        
        var title = "开始"
        switch (status) {
        case .FreetoUse:
            self.btnControl.isEnabled = true
            self.btnControl.setTitle(title, for:.normal)
        case .Recoding:
            self.btnControl.isEnabled = true
            title = "请讲话，识别中，点击停止"
            self.btnControl.setTitle(title, for: .normal)
        case .SuccessWithResult:
            self.btnControl.isEnabled = true
            self.lbResult.text = tip
            title = "请讲话，识别中，点击停止"
            self.btnControl.setTitle(title, for: .normal)
        case .Finish:
            self.btnControl.isEnabled = true
            self.btnControl.setTitle(title, for:.normal)
        case .Unauthorized:
            self.btnControl.isEnabled = false
            self.btnControl.setTitle("用户未授权", for: .disabled)
        case .FailWithError:
            self.btnControl.isEnabled = true
            self.lbResult.text = "失败:\(tip)"
            self.btnControl.setTitle(title, for:.normal)
        }
    }
}
