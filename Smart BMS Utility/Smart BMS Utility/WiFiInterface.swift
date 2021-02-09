////
////  WiFiInterface.swift
////  Smart BMS Utility
////
////  Created by Justin Kühner on 12.10.20.
////
//
//import UIKit
//import SwiftSocket
//
//class WiFiInterface {
//    
//    static var broadcastConnection: UDPBroadcastConnection!
//    static var connectedIPAddr = ""
//    
//    static var port: UInt16 = 45874
//    static private var setupDone = false
//    
//    static private var udpClient: UDPClient!
//    
//    static func setupUDPServer() {
//        if !setupDone {
//            print("WiFiInterface: setupUDPServer()")
//            NotificationCenter.default.addObserver(self, selector: #selector(sendRequest), name: NSNotification.Name("WiFiPacketSendNeeded"), object: nil)
//            
//            do {
//                broadcastConnection = try UDPBroadcastConnection(
//                    port: 45874 , bindIt: true,
//                    handler: { [self] (ipAddress: String, port: Int, response: Data) -> Void in
//                        guard true else { return }
//                        print("UDP connection received from \(ipAddress):\(port), length: \(response.count)")
//                        
//                        if DevicesController.connectionMode == .wifi && ipAddress == self.connectedIPAddr {
//                            BMSData.dataToBMSReading(bytes: [UInt8](response))
//                        }
//                        else {
//                            print("Received packet but it is not wanted!")
//                        }
//                    },
//                    errorHandler: { [self] (error) in
//                        guard self != nil else { return }
//                        print("Something went wrong: \(error)")
//                })
//            } catch {
//                print("WiFiInterface: \(error.localizedDescription)")
//            }
//        }
//        setupDone = true
//    }
//    
//    static func updateClient() {
//        udpClient = UDPClient(address: connectedIPAddr, port: Int32(self.port))
//    }
//    
//    @objc static func sendRequest() {
//        let request = bmsRequest()
//        print("Sendrequest to \(udpClient.address) on port \(udpClient.port)")
//        udpClient.send(data: request.generateBasicInfoRequest())
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            udpClient.send(data: request.generateVoltageRequest())
//        }
//    }
//
//}
