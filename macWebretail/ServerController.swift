//
//  ServerController.swift
//  macWebretail
//
//  Created by Gerardo Grisolini on 02/06/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import Foundation

class ServerController {

    let currentDirectoryPath = "\(FileManager.default.currentDirectoryPath)/macWebretail.app/Contents/Resources"
    
    init() {
        if !FileManager.default.fileExists(atPath: currentDirectoryPath + "/Webretail") {
            let task = Process()
            task.currentDirectoryPath = currentDirectoryPath
            task.launchPath = "/usr/bin/unzip"
            task.arguments = [currentDirectoryPath + "/Webretail.zip"]
            task.launch()
        }
    }

    public func start() {
        let process = Process()
        process.currentDirectoryPath = currentDirectoryPath
        process.launchPath = currentDirectoryPath + "/Webretail"
        process.arguments = []
        process.launch()
    }

    public func stop() {
        let process = Process()
        process.launchPath = "/usr/bin/pkill"
        process.arguments = ["Webretail"]
        process.launch()
    }

    public var isRunning: Bool {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "ps gx | grep -v grep | grep 'Resources/Webretail' | awk '{print $1}'"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let pid = String(data: data, encoding: String.Encoding.utf8) {
            return !pid.isEmpty
        }
        
        return false
    }
}
