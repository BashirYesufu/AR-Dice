//
//  ViewController.swift
//  ARDicee
//
//  Created by mac on 2/3/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        //
        //        let sphere = SCNSphere(radius: 0.2)
        //
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //        let material = SCNMaterial()
        //        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        //        sphere.materials = [material]
        //
        //        let node = SCNNode()
        //        node.position = SCNVector3(0, 0.1, -0.5)
        //        node.geometry = sphere
        //
        //        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Dice Rendering Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
               addDice(atLoction: hitResult)
            }
        }
    }
    
    func addDice(atLoction location: ARHitTestResult) {
        // Create a new scene
        let position = location.worldTransform.columns.3
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                position.x,
                position.y + diceNode.boundingSphere.radius,
                position.z
            )
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(diceNode)
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice)
            }
        }
    }
    
    func roll(_ dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5
            )
        )
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    //MARK: - ARSceneView Delegate methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
       
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            let planeNode = createPlane(withPlaneAnchor: planeAnchor)
            node.addChildNode(planeNode)
        
    }
    
    // MARK: - Plane Rendering Methods
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(
            width: CGFloat(planeAnchor.extent.x),
            height: CGFloat(planeAnchor.extent.z)
        )
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        return planeNode
    }
}
