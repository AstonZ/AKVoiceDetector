//
//  VoiceRecorder.swift
//  AKVoiceDetector
//
//  Created by Aston K Mac on 2017/10/27.
//  Copyright © 2017年 LowBee Tech. All rights reserved.
//

import AVFoundation
import Speech



class VoiceRecorder: NSObject {
    
    public enum RecognizerStatus {
        case FreetoUse
        case Recoding
        case Unauthorized
        case SuccessWithResult
        case FailWithError
        case Finish
    }
    
    typealias RecognizerCallback = (_ status: RecognizerStatus,_ tip:NSString) -> ()
    
    var completion :(RecognizerStatus, String)->()
    
    let audioEngine: AVAudioEngine!
    
    let recognizer: SFSpeechRecognizer!
    var recongRequest: SFSpeechAudioBufferRecognitionRequest?
    var recongTask: SFSpeechRecognitionTask?
    
    
    //MARK: - Singelton
    static let shared = VoiceRecorder()
    private override init() {
        
        self.audioEngine = AVAudioEngine.init()
        
        //device local scale
        let scale = Locale.init(identifier: "zh-CN")
        self.recognizer = SFSpeechRecognizer.init(locale: scale)
        self.completion = {_,_ in}
        super.init()
        
        self.recognizer.delegate = self
        
        //request for authorization
        SFSpeechRecognizer.requestAuthorization { (status) in
            
            switch (status){
            case .authorized:
                print("OK to Use")
            case .denied, .restricted:
                print("User Rejected")
            case .notDetermined:
                print("User determing")
            }
            
            
        }//request
        
        
    }
    
    public func startRecognize(completion:@escaping (RecognizerStatus, String) -> () = {_,_  in}) -> (){
        
        self.completion = completion
        // check authority
        switch (SFSpeechRecognizer.authorizationStatus()) {
            
        case .authorized:
            print("OK to Use")
        case .denied, .restricted:
            print("User Rejected")
            self.completion(.Unauthorized, "Device Rejected")
            return
        case .notDetermined:
            self.completion(.Unauthorized, "Wait user to determin")
            return
        }
        
        if self.audioEngine.isRunning {
            self.audioEngine.stop()
            self.recongRequest?.endAudio()
            print("stop recognize")
            self.completion(.FreetoUse, "OK to use")
            
        }else{
            self.completion(.Recoding, "Recording")
            self.startRecoding()
        }
    }
    
    private func startRecoding (completion:@escaping (RecognizerStatus, String) -> () = {_,_  in} ) {
        
        //stop task
        if self.recongTask != nil{
            self.recongTask!.cancel()
            self.recongTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        try? audioSession.setCategory(AVAudioSessionCategoryRecord)
        try? audioSession.setMode(AVAudioSessionModeMeasurement)
        try? audioSession.setActive(true)
        
        self.recongRequest = SFSpeechAudioBufferRecognitionRequest.init()
        let inputNode = self.audioEngine.inputNode
        self.recongRequest?.shouldReportPartialResults = true
        
        //start recog
        self.recongTask = self.recognizer.recognitionTask(with: self.recongRequest!, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if let pieceResult = result {
                let txt = pieceResult.bestTranscription.formattedString
                print("translate = \(txt)")
                
                isFinal = pieceResult.isFinal
                self.completion(.SuccessWithResult, txt)
            }
            
            
            if isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recongRequest = nil
                self.completion(.Finish, "recognition finished")
            }
            
            
            if error != nil {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recongRequest = nil
                self.completion(.FailWithError, error.debugDescription)
            }

        })//Task
        
        let recordFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordFormat) { (buffuer, _) in
            self.recongRequest?.append(buffuer)
        }
        
        self.audioEngine.prepare()
        try? self.audioEngine.start()
        
    }
}


extension VoiceRecorder: SFSpeechRecognizerDelegate{
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available {
            print("is available")
        }else{
            print("not avaliable")

        }
        
    }
}

