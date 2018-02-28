//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController,CLLocationManagerDelegate,changeCityNameDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var switchButton: UISwitch!
    let data = WeatherDataModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchButton.isOn = false
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String,parameter:[String:String]){
        Alamofire.request(url, method: .get, parameters: parameter).responseJSON { response in
            if response.result.isSuccess{
                print("success")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                
                self.updateWeatherData(resultJSON: weatherJSON)
            }else{
                print("fail to get data!")
                self.cityLabel.text = "fail to get data"
            }
           
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(resultJSON:JSON){
        if let temp = resultJSON["main"]["temp"].double {
        data.tempResult = Int(temp - 273.15)
        data.city = resultJSON["name"].stringValue
        data.condition = resultJSON["weather"][0]["icon"].intValue
        data.weatherIcon = data.updateWeatherIcon(condition: data.condition)
        updateUIWithWeatherData()
     }
    
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        temperatureLabel.text = "\(data.tempResult)°"
        cityLabel.text = data.city
        weatherIcon.image = UIImage(named:data.weatherIcon)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("we got it")
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            let param : [String : String] = ["lat" : latitude,"lon" : longitude,"appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameter: param)
        }else{
            cityLabel.text = "Connection Issues!"
        }
        
    }
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Connection issues!"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city:String){
        let param : [String : String] = ["q" : city,"appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameter: param)
        switchButton.isOn=false
        
       
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
               destinationVC.delegate = self
        }
    }
    
    
    @IBAction func switchTemp(_ sender: UISwitch) {
        switchButton.isOn = true
        let tempSwitch = (data.tempResult * 9)/5 + 32
        temperatureLabel.text = "\(tempSwitch)℉"
    }
    
    
}


