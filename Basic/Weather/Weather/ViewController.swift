//
//  ViewController.swift
//  Weather
//
//  Created by Cho Si Yeon on 2022/02/27.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func tapPatchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
          self.getCurrentWeather(cityName: cityName)
          self.view.endEditing(true)
        }
    }
    
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        // weather 배열의 첫번째 요소가 상수 weather 에 대입
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))°C"
        self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))°C"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=***REMOVED***") else { return }
        
        let session = URLSession(configuration: .default)
        
        // dataTask 가 API 를 호출하고 서버에서 응답오면 Completion Handler 클로저가 호출됨
        // 클로저 안 data 파라미터에는 서버로부터 응답받은 데이터, respone: HTTP 해더 및 상태 코드, error: 요청 실패시 에러 객체 전달, 성공시 nil 반환
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
    
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                
                // 네트워크 작업은 별도의 스레드에서 진행되며 응답이 온다해도 자동으로 메인스레드로 돌아오지 않음
                // UI 작업이 메인스레드에서 할 수 있도록 만들어줘야함
                DispatchQueue.main.async {
                  self?.weatherStackView.isHidden = false
                  self?.configureView(weatherInformation: weatherInformation)
                }
            } else {
                guard let errorMesaage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMesaage.message)
                }
            }
        }.resume()
    }
}

