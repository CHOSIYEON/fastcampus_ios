//
//  ViewController.swift
//  TodoList
//
//  Created by Cho Si Yeon on 2022/02/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var tasks = [Task]() {
        didSet {
            // tasks 에 일이 추가될때마다 saveTasks() 호출되어 UserDefault 에 값이 저장되게 됨
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTask()
    }

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        
        // handler : registerButton 을 눌렀을 때, 실행될 함수 : 클로저
        // 클래스처럼 클로저는 참조 타입이기 때문에 클로저의 본문에서 self 로 인스턴스를 캡처할 때 강한 순환 참조가 발생할 수 있음
        // 강한 순환 참조란 ARC 의 단점이기도 한데, 두개의 객체가 상호 참조하는 경우 강한 순환 참조가 만들어짐
        // 이렇게 강한 순환 참조가 만들어지게 되면 이에 연관된 객체들은 레퍼런스의 카운트가 0에 도달하기 않게 되고 메모리 누수가 발생하게 됨
        // 이런 점을 해결하기 위해서 클로저의 선언부에서 캡처 목록을 정의하는 것으로 해결할 수 있음
        // weak, unknown 으로 캡처 목록을 정의함
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
        })
        
        // cancleButton 눌렀을 때, 아무것도 실행되지 않음 -> nil
        let cancleButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cancleButton)
        alert.addAction(registerButton)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할 일을 입력해주세요."
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTasks() {
        // 배열에 있는 요소들을 딕셔너리 형태로 저장
        let data = self.tasks.map {
            [
                "title" : $0.title,
                "done" : $0.done
            ]
        }
        
        // UserDefault 에 접근가능하게 만듬
        let userDefaults = UserDefaults.standard
        // 값 삽입
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTask() {
        let userDefaults = UserDefaults.standard
        // 값 가져오기, Any 타입으로 리턴됨 -> 딕셔너리 형태로 캐스팅
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            
            return Task(title: title, done: done)
        }
    }
}

extension ViewController: UITableViewDataSource {
    // 각 섹션에 표시할 행의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    // 특정 row 에 그리기 위한 cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeueReusableCell : 지정된 재사용 가능한 셀의 객체를 반환하고 이를 테이블뷰에 추가하는 역할
        // dequeueReusableCell 메소드를 사용하면 큐를 이용해 셀을 재사용 하게 됨
        // 테이블 뷰에 10개의 셀이 있다면 10개의 셀을 만들어 메모리에 올림
        // 그럼 테이블 뷰에 1000개의 셀이 있다면 1000개의 셀을 만들고 메모리에 할당해야하나? 만약 이렇다면 불필요한 메모리 낭비가 심해질 것
        // 큐를 사용해 셀을 재사용하면 이러한 메모리 낭비를 방지할 수 있음
        // 현재 내가 볼 수 있는 화면에 다섯개의 셀이 있다면 앱은 다섯개의 데이터만 받아와 메모리에 로드하게 되고,
        // 스크롤을 내리면서 점점 많은 데이터를 다섯개의 셀을 재사용하여 보여주게 됨
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    // 셀을 선택했을때, 어떤 셀이 선택되었는지 알려주는 메소드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
