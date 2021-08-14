//
//  MainViewController.swift
//  GoodWeather
//
//  Created by Taisei Sakamoto on 2021/03/13.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    //MARK: - Properties
    
    private let cityNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Seach"
        return tf
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "16℃"
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.text = "78.0%"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .lightGray
        return label
    }()
    
    let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Good Weather"
        
        let stack = UIStackView(arrangedSubviews: [cityNameTextField, temperatureLabel, humidityLabel])
        stack.axis = .vertical
        stack.spacing = 160
        
        view.addSubview(stack)
        stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                   constant: 24).isActive = true
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.cityNameTextField.rx.controlEvent(.editingDidEndOnExit)
            .asObservable()
            .map { self.cityNameTextField.text }
            .subscribe(onNext: { city in
                if let city = city {
                    if city.isEmpty {
                        self.displayWeather(nil)
                    } else {
                        self.fetchWeather(by: city)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func fetchWeather(by city: String) {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL.urlWeatherAPI(city: cityEncoded) else { return }
        
        let resource = Resource<WeatherResult>(url: url)
        
        /*
        let search = URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: WeatherResult.empty)
        */
        
        let search = URLRequest.load(resource: resource)
            .observe(on: MainScheduler.instance)
            .retry(3)
            .catch { error in
                print("DEBUG: \(error.localizedDescription)")
                return Observable.just(WeatherResult.empty)
            }.asDriver(onErrorJustReturn: WeatherResult.empty)
        
        search.map { "\($0.main.temp) ℉" }
            .drive(self.temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        search.map { "\($0.main.humidity) 💦"}
            .drive(self.humidityLabel.rx.text)
            .disposed(by: disposeBag)
        
//            .subscribe(onNext: { result in
//                let weather = result.main
//                self.displayWeather(weather)
//            }).disposed(by: disposeBag)
    }
    
    private func displayWeather(_ weather: Weather?) {
        if let weather = weather {
            self.temperatureLabel.text = "\(weather.temp) ℃"
            self.humidityLabel.text = "\(weather.humidity) 💦"
        } else {
            self.temperatureLabel.text = "🌎"
            self.humidityLabel.text = "🌫"
        }
    }
}
