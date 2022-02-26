//
//  ViewController.swift
//  pomodoro
//
//  Created by Cho Si Yeon on 2022/02/23.
//

import UIKit
import AudioToolbox

enum TimerStaus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    var duration = 60
    var timerStauts: TimerStaus = .end
    var timer: DispatchSourceTimer?
    var currentSeconds = 0 // 현재 카운트 다운 되고 있는 시간을 초로 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
        
    }
    
    func setTimerInfoViewVisible(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }

    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }

    func startTimer() {
        if self.timer == nil {
            // queue: 어떤 스레드 큐에서 반복 동작할 것인지 정해주면 됨
            // timer 가 돌때마다 UI 관련 작업을 해줘야함 -> 메인스레드
            // 메인 스레드는 오직 한개만 존재하는 스레드, 우리가 작성하는 일반적인 모든 코드는 스레드에서 실행됨
            // 우리가 작성한 코드가 코코아 에서 실행되는데 이 코코아가 코드를 메인스레드에서 호출하기 때문
            // 메인스레드는 인터페이스 스레드라고도 부름
            // 유저가 인터페이스에 접근하면 이벤트는 메인 스레드에 전달되고, 우리가 작성한 코드는 이에 반응함
            // 이말은 인터페이스와 관련된 코드는 반드시 메인스레드에서 작동되어야함을 의미 -> UI 관련 작업은 항상 메인스레드에서
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                // self 가 strong 이 되게 만들어줌
                guard let self = self else { return }
                
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)

                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStauts == .pause {
            self.timer?.resume()
        }
        self.timerStauts = .end
        self.cancelButton.isEnabled = false
        self.setTimerInfoViewVisible(isHidden: true)
        self.datePicker.isHidden = false
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        
        // 타이머를 해제할 때 꼭 nil 을 할당하여 해제 시켜줘야함
        // 근데 일시정지 suspend() 된 상태에서 nil 을 할당하게 되면 아직 할일이 있다고 판단, 에러남 -> resume() 해줘야함
        self.timer = nil
    }
    
    @IBAction func tapCancleButton(_ sender: UIButton) {
        switch self.timerStauts {
        case .start, .pause:
            self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        
        switch self.timerStauts {
        case .end:
            self.currentSeconds = self.duration
            self.timerStauts = .start
            self.setTimerInfoViewVisible(isHidden: false)
            self.datePicker.isHidden = true
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
            
        case .start:
            self.timerStauts = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend() // 타이머 일시정지
            
        case .pause:
            self.timerStauts = .start
            self.toggleButton.isSelected = true
            self.timer?.resume() // 타이머 재시작
        }
        
    }
}

