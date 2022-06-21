//
//  ViewController.swift
//  pee2sample
//
//  Created by Nikolas Omelianov on 21.06.2022.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print(peerID)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
            if let session = self?.mcSession, !session.connectedPeers.contains(peerID) {
                browser.invitePeer(peerID, to: session, withContext: nil, timeout: 60)
            }
            
        }
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print(peerID)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mcSession)
    }
    

    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .optional)
        mcSession.delegate = self
        
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "my-test")
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "my-test")
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    

    func sendImage(img: UIImage) {
        if mcSession.connectedPeers.count > 0 {
            if let imageData = img.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    func startHosting(action: UIAlertAction!) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "nik-kb", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
        
//        advertiser.startAdvertisingPeer()
    }

    func sendText(txt: String) {
        if mcSession.connectedPeers.count > 0 {
            let dtst = "\(peerID) tcp: hi"
            let dtst2 =  "\(peerID) udp: hi"
            let dt = dtst.data(using: .utf8)
            let dt2 = dtst2.data(using: .utf8)
            try? mcSession.send(dt!, toPeers: mcSession.connectedPeers, with: .reliable)
            print("attempt dt")
            try? mcSession.send(dt2!, toPeers: mcSession.connectedPeers, with: .unreliable)
            print("attempt dt2")
//            if let dt = txt.data(using: .utf8)  {
//                do {
//                    try mcSession.send(dt, toPeers: mcSession.connectedPeers, with: .reliable)
//                } catch let error as NSError {
//                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "OK", style: .default))
//                    present(ac, animated: true)
//                }
//            }
        }
    }
    
    func joinSession(action: UIAlertAction!) {
        let mcBrowser = MCBrowserViewController(serviceType: "nik-kb", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
        
    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        startHosting(action: .none)
    }
    @IBAction func joinTapped(_ sender: UIButton) {
        joinSession(action: .none)
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        sendText(txt: "\(Int.random(in: 0...9))")
    }
    
    
}

extension ViewController: MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(#function,  #line)
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(#function,  #line)
        if let image = UIImage(data: data) {
                DispatchQueue.main.async { [unowned self] in
                    // do something with the image
                }
            }
        if let txt = String(data: data, encoding: .utf8)  {
            print("data is --> ", txt)
        }
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print(#function,  #line)
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print(#function,  #line)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print(#function,  #line)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        print(#function,  #line)
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        print(#function,  #line)
        dismiss(animated: true)
    }
    
}

