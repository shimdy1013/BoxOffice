//
//  ViewController.swift
//  TableSDY
//
//  Created by 심두용 on 2022/06/01.
//

import UIKit

struct MovieData : Codable {
    let boxOfficeResult : BoxOfficeResult
}

struct BoxOfficeResult : Codable {
    let dailyBoxOfficeList : [DailyBoxOfficeList]
}

struct DailyBoxOfficeList : Codable {
    let movieNm : String
    let audiCnt : String
    let audiAcc : String
    let rank : String
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var movieURL = "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=e41e4a9c0082d1e7ff5148f94e54abb4&targetDt="
    var movieData : MovieData?
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        movieURL += makeYesterdayString()
        getData()
        // Do any additional setup after loading the view.
    }
    
    func makeYesterdayString() -> String {
        let y  =  Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyyMMdd"
        let day = dateF.string(from: y)
        return day
    }
    
    func getData() {
        
        // 1. URL 만들기
        guard let url = URL(string: movieURL) else { return }
        
        // 2. URLSession 만들기
        let session = URLSession(configuration: .default)
        
        // 3. URLSession 인스턴스에게 task 주기
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(MovieData.self, from: JSONdata)
                self.movieData = decodedData
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            } catch {
                print(error)
            }
        }
        
        // 4. task 시작
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        cell.movieName.text = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].movieNm
        cell.movieRank.text = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].rank
        
        // cell.audiCount.text = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiCnt
        // cell.audiAccumulate.text = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiAcc
        if let aCnt = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiCnt {
            let numF = NumberFormatter()
            numF.numberStyle = .decimal
            let aCount = Int(aCnt)!
            let result = numF.string(for: aCount)!+"명"
            cell.audiCount.text = "어제 : \(result)"
            //cell.audiCount.text = "어제:\(aCnt)명"
             }
        if let aAcc = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiAcc {
            let numF = NumberFormatter()
            numF.numberStyle = .decimal
            let aAccumulate = Int(aAcc)!
            let result = numF.string(for: aAccumulate)!+"명"
            cell.audiAccumulate.text = "누적 : \(result)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "박스오피스(영화진흥위원회제공 : "+makeYesterdayString()+")"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? DetailViewController else { return }
        let myIndexPath = table.indexPathForSelectedRow!
        let row = myIndexPath.row
        dest.movieName = (movieData?.boxOfficeResult.dailyBoxOfficeList[row].movieNm)!
    }
}

