//
//  WeatherInformation.swift
//  Weather
//
//  Created by Cho Si Yeon on 2022/02/27.
//

import Foundation

// Codable 은 자신을 반환하거나 외부 표현으로 변환할 수 있는 타입을 의미함
// 외부표현이란 JSON 과 같은 타입을 의미함
// Codable 은 Decodable 과 Encodable 프로토콜을 준수하는 타입
// Decodable 은 자신을 외부표현에서 디코딩 할 수 있는 타입
// Encodable 자신을 외부타입에서 인코딩 할 수 있는 타입
// 즉 WeatherInformation를 Json 형태로 만들거나 JSON 객체를 WeatherInformation 객체로 만들 수 있음
struct WeatherInformation: Codable {
  let weather: [Weather]
  let temp: Temp
  let name: String

  enum CodingKeys: String, CodingKey {
    case weather
    case temp = "main"
    case name
  }
}

struct Weather: Codable {
  let id: Int
  let main: String
  let description: String
  let icon: String
}

struct Temp: Codable {
  let temp: Double
  let feelsLike: Double
  let minTemp: Double
  let maxTemp: Double

  enum CodingKeys: String, CodingKey {
    case temp
    case feelsLike = "feels_like"
    case minTemp = "temp_min"
    case maxTemp = "temp_max"
  }
}
