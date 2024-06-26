//
//  ViewController.swift
//  EsriMap
//
//  Created by Mohamed Ali on 15/04/2024.
//

import UIKit
import ArcGIS

class ViewController: UIViewController {
    
    @IBOutlet weak var map: AGSMapView!
    
    lazy var esri = EsriModule(mapView: map)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*esri.addFeatureLayer(featureLayerUrl: "https://services3.arcgis.com/GVgbJbqm8hXASVYi/arcgis/rest/services/Trailheads/FeatureServer/0",
                             lati: 30.06899,
                             long: 31.02079
                            )*/
        
        esri.loadWebMap(itemId: "41281c51f9de45edaf1c8ed44bb10e30") // MARK: - you can find the id from the host and get also the url of server.
    }


}

