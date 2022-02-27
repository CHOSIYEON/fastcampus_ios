//
//  ViewController.swift
//  COVID19
//
//  Created by Cho Si Yeon on 2022/02/27.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var newCaseLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicatorView.startAnimating()
        // Alamofire 에서 responseData 의 경우 메인 스레드에서 동작
        self.fetchCovidOverview(completionHandler: { [weak self] result in // 순환참조 방지
            guard let self = self else { return } // 일시적으로 strong
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
            self.labelStackView.isHidden = false
            self.pieChartView.isHidden = false
            switch result {
            case let .success(result):
                self.configureStackView(koreaCovidOverview: result.korea)
                let covidOverViewList = self.makeCovidOverviewList(cityCovidOverview: result)
                self.configureChartView(covidOverviewList: covidOverViewList)
                
            case let .failure(error):
                debugPrint(error)
            }
            
        })
       
    }
    
    func configureStackView(koreaCovidOverview: CovidOverview) {
      self.totalCaseLabel.text = "\(koreaCovidOverview.totalCase) 명"
      self.newCaseLabel.text = "\(koreaCovidOverview.newCase) 명"
    }
    
    func makeCovidOverviewList(cityCovidOverview: CityCovidOverview) -> [CovidOverview] {
        return [
          cityCovidOverview.seoul,
          cityCovidOverview.busan,
          cityCovidOverview.daegu,
          cityCovidOverview.incheon,
          cityCovidOverview.gwangju,
          cityCovidOverview.daejeon,
          cityCovidOverview.ulsan,
          cityCovidOverview.sejong,
          cityCovidOverview.gyeonggi,
          cityCovidOverview.chungbuk,
          cityCovidOverview.chungnam,
          cityCovidOverview.jeonnam,
          cityCovidOverview.gyeongbuk,
          cityCovidOverview.gyeongnam,
          cityCovidOverview.jeju,
        ]
    }
    
    func configureChartView(covidOverviewList: [CovidOverview]) {
        self.pieChartView.delegate = self
        
        // CovidOverview 객체를 piechartentry 객체로 변환
        let entries = covidOverviewList.compactMap { [weak self] overview -> PieChartDataEntry? in
          guard let self = self else { return nil }
          return PieChartDataEntry(
            value: self.removeFormatString(string: overview.newCase),
            label: overview.countryName,
            data: overview
          )
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황")
        dataSet.sliceSpace = 1
        dataSet.entryLabelColor = .black
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueTextColor = .black
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.3

        dataSet.colors = ChartColorTemplates.vordiplom()
          + ChartColorTemplates.joyful()
          + ChartColorTemplates.colorful()
          + ChartColorTemplates.liberty()
          + ChartColorTemplates.pastel()
          + ChartColorTemplates.material()

        self.pieChartView.data = PieChartData(dataSet: dataSet)
        self.pieChartView.spin(duration: 0.3, fromAngle: pieChartView.rotationAngle, toAngle: pieChartView.rotationAngle + 80)
    }
    
    func removeFormatString(string: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    
    func fetchCovidOverview(
        // API 를 요청하고 JSon 데이터를 응답받거나 요청이 실패하였을 떄 completionHandler 클로저를 호출해 해당 클로저를 호출한 곳에서 응답 받은 데이터를 전달 하려고 함
        // 요청에 성공하면 (첫번쨰 제너릭???) CityCovidOverview 에 전달, 요청이 실패하거나 에러 발생시 Error 객체가 연관값으로 전달되게 만들어줌
        // 클로저를 escaping 클로저로 선언 해줘야 함
        // 클로저가 함수로 escape, 탈출한다는 의미
        // 함수의 인자로 클로저가 전달되지만 함수가 반환된 후에도 실행되는 것을 의미
        // 함수의 인자가 함수의 영역을 탈출하여 함수 밖에서도 사용할 수 있는 개념
        // 대표적으로 비동기 작업을 할떄 completionHandler 로 escaping 클로저를 많이 사용함
        // 보통 네트워킹 통신은 비동기로 작업됨
        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
    ) {
        let url = "https://api.corona-19.kr/korea/country/new/"
        let param = [
            "serviceKey": Bundle.main.apiKey
        ]
        
        AF.request(url, method: .get, parameters: param)
            // 응답데이터가 completionHandler 로 전달됨
            // 이 completionHandler 는 fetchCovidOverview 가 반환된 이후에 호출될 것
            // 서버에서 언제 데이터를 응답해줄지 모르기 때문
            // 만약 escaping 으로 선언해주지 않는다면 completionHandler 가 호출되기전에 함수가 종료되서
            // 서버의 응답을 받아도 실행 안될 것
            .responseData(completionHandler: { response in
                switch response.result {
                case let .success(data):
                  do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CityCovidOverview.self, from: data)
                    completionHandler(.success(result))
                  } catch {
                    completionHandler(.failure(error))
                  }
                case let .failure(error):
                  completionHandler(.failure(error))
                }
            })
    }
}

extension ViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let covidDetailViewController = self.storyboard?.instantiateViewController(identifier: "CovidDetailViewController") as? CovidDetailViewController else {
             return
           }
        guard let covidOverview = entry.data as? CovidOverview else { return }
        covidDetailViewController.covidOverview = covidOverview
        self.navigationController?.pushViewController(covidDetailViewController, animated: true)
    }
}

