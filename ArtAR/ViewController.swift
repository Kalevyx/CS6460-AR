//
//  ViewController.swift
//  ArtAR
//
//  Created by C on 4/4/22.
//  Copyright © 2022 C. All rights reserved.
//
//  Credit: https://github.com/twostraws/SwiftOnSundays/tree/main/014%20SpotTheScientist, https://www.youtube.com/watch?v=P0JsbjbzG9A

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    static let spacing: Float = 0.005
    static let textNodeScale: Float = 0.002

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var segmentedController: UISegmentedControl!

    var artworks = [String: Artwork]()
    var lastImageAnchor: ARAnchor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()

        guard let images = ARReferenceImage.referenceImages(inGroupNamed: "artworks", bundle: nil) else {
            fatalError("Couldn't load tracking images")
        }

        configuration.trackingImages = images
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        self.lastImageAnchor = imageAnchor
        
        guard let name = imageAnchor.referenceImage.name else { return nil }
        guard let artwork  = artworks[name] else { return nil }
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi/2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
         
        let titleNode = textNode(artwork.name, font: UIFont.boldSystemFont(ofSize: 5), maxWidth: 70)
        titleNode.pivotOnTopLeft()
        titleNode.position.x += Float(plane.width / 2) + ViewController.spacing
        titleNode.position.y += Float(plane.height / 2)
        planeNode.addChildNode(titleNode)
        
        let artistNode = textNode(artwork.artist, font: UIFont.systemFont(ofSize: 2), maxWidth: 70)
        artistNode.pivotOnTopLeft()
        artistNode.position.x += Float(plane.width / 2) + ViewController.spacing
        artistNode.position.y = titleNode.position.y - titleNode.height - ViewController.spacing
        planeNode.addChildNode(artistNode)
        
        if (segmentedController.selectedSegmentIndex == 0) {
            let descriptionNode = textNode(artwork.description, font: UIFont.systemFont(ofSize: 3), maxWidth: 70)
            descriptionNode.pivotOnTopLeft()
            descriptionNode.position.x += Float(plane.width / 2) + ViewController.spacing
            descriptionNode.position.y = artistNode.position.y - artistNode.height - ViewController.spacing
            planeNode.addChildNode(descriptionNode)
        } else {
            let factNode = textNode(artwork.fact, font: UIFont.systemFont(ofSize: 3), maxWidth: 70)
            factNode.pivotOnTopLeft()
            factNode.position.x += Float(plane.width / 2) + ViewController.spacing
            factNode.position.y = artistNode.position.y - artistNode.height - ViewController.spacing
            planeNode.addChildNode(factNode)
        }

        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        if self.lastImageAnchor != nil {
            self.sceneView.session.remove(anchor: self.lastImageAnchor)
        }
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "artworks", withExtension: "json") else {
            fatalError("Unable to find JSON in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON")
        }
        
        let decoder = JSONDecoder()
        guard let loadedArtworks = try? decoder.decode([String: Artwork].self, from: data) else {
            fatalError("Unable to parse JSON")
        }
        
        artworks = loadedArtworks
    }
    
    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0)
        
        text.flatness = 0.1
        text.font = font
        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(ViewController.textNodeScale, ViewController.textNodeScale, ViewController.textNodeScale)
        
        return textNode
    }
}

extension SCNNode {
    var width: Float {
        return (boundingBox.max.x - boundingBox.min.x) * scale.x
    }
    
    var height: Float {
        return (boundingBox.max.y - boundingBox.min.y) * scale.y
    }
    
    func pivotOnTopLeft() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(min.x, max.y, 0)
    }
    
    func pivotOnTopCenter() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, max.y, 0)
    }
}
