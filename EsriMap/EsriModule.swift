//
//  EsriModule.swift
//  EsriMap
//
//  Created by Mohamed Ali on 15/04/2024.
//

import ArcGIS
import Foundation

class EsriModule {
    
    private let api_key = "AAPK4e7cff31848045c08118ee9141e02188tPhTR2prd3o3aJcA3Ubbw2Zi2OghuIIw_LXulPMGPRNd1jIbeb-npYAYORM97hyz"
    let mapView: AGSMapView?
    private var graphicsOverlay = AGSGraphicsOverlay()
    public var points = Array<AGSPoint>()
    
    init(mapView: AGSMapView) {
        self.mapView = mapView
    }
    
    init() {
        mapView = nil
    }
    
    func getApiKey() -> String {
        return api_key
    }
    
    func getGraphicsOverlay() -> AGSGraphicsOverlay {
        return graphicsOverlay
    }
    
    func setGraphicsOverlay(graphicsOverlay: AGSGraphicsOverlay) {
        self.graphicsOverlay = graphicsOverlay
    }
    
    func showMap(lati: Double, long: Double) {
        // Create an instance of a map with ESRI topographic basemap.
        mapView!.map = AGSMap(basemapStyle: .arcGISImagery) // arcGISNavigation
        // mapView.touchDelegate = self

        // Add the graphics overlay.
        mapView!.graphicsOverlays.add(graphicsOverlay)
        
        // Zoom to a specific extent.
        mapView!.setViewpoint(AGSViewpoint(center: AGSPoint(x: long, y: lati, spatialReference: .wgs84()), scale: 5e4))
    }
    
    func addFeatureLayer(featureLayerUrl: String,lati: Double,long: Double) {
        let featureLayer: AGSFeatureLayer = {
            let featureServiceURL = URL(string: featureLayerUrl)!
            let trailheadsTable = AGSServiceFeatureTable(url: featureServiceURL)
            return AGSFeatureLayer(featureTable: trailheadsTable)
        }()
        
        let map = AGSMap(basemapStyle: .arcGISImagery)
        mapView!.map = map
        
//        map.operationalLayers.add(featureLayer)
        
        // Step 6: Set viewpoint to center on feature layer extent
        featureLayer.load { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                self.mapView!.setViewpoint(AGSViewpoint(center: AGSPoint(x: long, y: lati, spatialReference: .wgs84()), scale: 5e4))
            }
            else {
                if let extent = featureLayer.fullExtent {
                    // Set viewpoint with padding if needed
                    let viewpoint = AGSViewpoint(targetExtent: extent, rotation: 100) // Adjust padding as needed
                    self.mapView!.setViewpoint(viewpoint)
                    
                    map.operationalLayers.add(featureLayer)
                    self.mapView!.map = map
                }
            }
            
            
        }

    }
    
    func AddPointOnMap(point: AGSPoint,attribute: [String: AnyObject]) {
        // Normalize point.
        let normalizedPoint = AGSGeometryEngine.normalizeCentralMeridian(of: point) as! AGSPoint
        
        points.append(normalizedPoint)

        let graphic = graphicForPoint(normalizedPoint, Attribute: attribute)
        graphicsOverlay.graphics.add(graphic)
        
        graphicsOverlay.isVisible = true
        
        mapView!.setViewpointGeometry(graphicsOverlay.extent, padding: 30, completion: nil)
    }
    
    func ShowCalloutForPoint(graphic: AGSGraphic,point: AGSPoint) {
        // Hide the callout.
        mapView!.callout.dismiss()
        
        self.showCalloutForGraphic(graphic, tapLocation: point)
    }
    
    // MARK: TODO: Method returns a graphic object for the specified point and attributes.
    private func graphicForPoint(_ point: AGSPoint,Attribute: [String: AnyObject]) -> AGSGraphic {
        let markerImage = UIImage(named: "carpine")!
        let symbol = AGSPictureMarkerSymbol(image: markerImage)
        symbol.leaderOffsetY = markerImage.size.height / 2
        symbol.offsetY = markerImage.size.height / 2
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: Attribute)
        return graphic
    }
    // -------------------------------------------
    
    // MARK: TODO: Show callout for the graphic.
    private func showCalloutForGraphic(_ graphic: AGSGraphic,tapLocation: AGSPoint) {
        let cityString = graphic.attributes["title"] as? String ?? ""
       // let addressString = graphic.attributes["Address"] as? String ?? ""
        
        mapView!.callout.title = cityString
        // mapView.callout.detail = addressString
        
        mapView!.callout.isAccessoryButtonHidden = true
        mapView!.callout.show(for: graphic, tapLocation: tapLocation, animated: true)
    }
    // -------------------------------------------
    
    // MARK: - load Web map.
    // -------------------------------------------
    
    func loadWebMap(itemId: String) {
        
        /*
         let portal = AGSPortal.init(url: URL(string: portapleUrl)!, loginRequired: true)
         portal.credential = AGSCredential(user: portalUserName, password: portalPassword)
         */
         
        let portal = AGSPortal.arcGISOnline(withLoginRequired: false)
        let itemID = itemId
        let portalItem = AGSPortalItem(portal: portal, itemID: itemID)
        
        let map = AGSMap(item: portalItem)
        mapView!.map = map
        
        // Handle map loading completion or errors
        map.load(completion: { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading map: \(error.localizedDescription)")
            } else {
                print("Map loaded successfully!")
                // Optionally, set an initial viewpoint here if needed
            }
            
        })
    }
    
    // -------------------------------------------
    
    // method provides a line symbol for the route graphic
    private func routeSymbol() -> AGSSimpleLineSymbol {
        let symbol = AGSSimpleLineSymbol(style: .solid, color: .red, width: 5)
        return symbol
    }
    // -------------------------------------------
        
    
}
