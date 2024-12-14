 // Speech recognizer and audio components  
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) // Locale can be changed  
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?  
    private var recognitionTask: SFSpeechRecognitionTask?  
    private let audioEngine = AVAudioEngine()  
  
    // UI Components  
    private let textView = UITextView()  
    private let startButton = UIButton(type: .system)  
  
    override func viewDidLoad() {  
        super.viewDidLoad()  
        view.backgroundColor = .white  
  
        setupUI()  
        requestSpeechAuthorization()  
    }  
  
    // MARK: - UI Setup  
    private func setupUI() {  
        textView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 300)  
        textView.font = UIFont.systemFont(ofSize: 18)  
        textView.isEditable = false  
        view.addSubview(textView)  
  
        startButton.frame = CGRect(x: 20, y: 420, width: view.frame.width - 40, height: 50)  
        startButton.setTitle("Start Listening", for: .normal)  
        startButton.addTarget(self, action: #selector(startStopListening), for: .touchUpInside)  
        view.addSubview(startButton)  
    }  
  
    // MARK: - Speech Authorization  
    private func requestSpeechAuthorization() {  
        SFSpeechRecognizer.requestAuthorization { status in  
            DispatchQueue.main.async {  
                switch status {  
                case .authorized:  
                    self.startButton.isEnabled = true  
                case .denied, .restricted, .notDetermined:  
                    self.startButton.isEnabled = false  
                    self.textView.text = "Speech recognition is not available."  
                @unknown default:  
                    self.startButton.isEnabled = false  
                }  
            }  
        }  
    }  
  
    // MARK: - Start or Stop Listening  
    @objc private func startStopListening() {  
        if audioEngine.isRunning {  
            stopListening()  
            startButton.setTitle("Start Listening", for: .normal)  
        } else {  
            startListening()  
            startButton.setTitle("Stop Listening", for: .normal)  
        }  
    }  
  
    private func startListening() {  
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {  
            textView.text = "Speech recognizer is not available."  
            return  
        }  
  
        // Initialize recognition request and task  
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  
        guard let recognitionRequest = recognitionRequest else {  
            textView.text = "Unable to create recognition request."  
            return  
        }  
  
        recognitionRequest.shouldReportPartialResults = true  
  
        do {  
            let audioSession = AVAudioSession.sharedInstance()  
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)  
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)  
        } catch {  
            textView.text = "Failed to configure audio session."  
            return  
        }  
  
        let inputNode = audioEngine.inputNode  
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in  
            if let result = result {  
                self.textView.text = result.bestTranscription.formattedString  
            }  
            if error != nil || (result?.isFinal ?? false) {  
                self.stopListening()  
                self.startButton.setTitle("Start Listening", for: .normal)  
            }  
        }  
  
        // Capture audio input  