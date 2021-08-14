//
//  URL+ Extension.swift
//  GoodWeather
//
//  Created by Taisei Sakamoto on 2021/03/15.
//

import Foundation

extension URL {
    static func urlWeatherAPI(city: String) -> URL? {
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=b75e17061f4ebf9de3270b99184080be")
    }
}
