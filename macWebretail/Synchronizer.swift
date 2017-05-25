//
//  Syncronizer.swift
//  iWebretail
//
//  Created by Gerardo Grisolini on 17/04/17.
//  Copyright © 2017 Gerardo Grisolini. All rights reserved.
//

import CoreData
import CloudKit

typealias ServiceResponse = (Data?) -> Void
struct Movement {
	var id: Int32
	var number: Int32
	var date: Date
	var causal: String
	var description: String
	var device: String
	var amount: Double
}
struct MovementArticle {
	var movementArticleBarcode : String = ""
	var movementArticleProduct : String = ""
	var movementArticleQuantity : Double = 0
	var movementArticlePrice : Double = 0
}

class Synchronizer {
	
	static let shared = Synchronizer()
	
	private let baseURL = "http://ec2-35-157-208-60.eu-central-1.compute.amazonaws.com/"
	private let deviceName = Host.current().localizedName!
	private var deviceToken: String = ""
	var isSyncing: Bool = false
	var movementId: Int32 = 0
	var movements: [Movement] = []
	var movementArticles: [MovementArticle] = []
	
	func iCloudUserIDAsync() {
		let container = CKContainer.default()
		container.fetchUserRecordID() {
			recordID, error in
			if error != nil {
				self.push(title: "iCloudUserID", message: error!.localizedDescription)
			} else {
				self.deviceToken = recordID!.recordName
				//print("fetched ID \(self.deviceToken)")
			}
		}
	}
	
	func synchronize() {
		if deviceToken.isEmpty { return }
		
		isSyncing = true
		
		makeHTTPGetRequest(url: "/api/movement", onCompletion: { data in
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for item in items {
						let causal = item["movementCausal"] as! [String: Any]
						let desc = item["movementDesc"] as! String
						let movement = Movement(
							id: item["movementId"] as! Int32,
							number: item["movementNumber"] as! Int32,
							date: (item["movementDate"] as! String).toShortDate(),
							causal: causal["causalName"] as! String,
							description: desc.isEmpty ? "..." : desc,
							device: item["movementDevice"] as! String,
							amount: item["movementAmount"] as! Double
						)
						self.movements.append(movement)
					}
				} catch {
					self.push(title: "Synchronize", message: error.localizedDescription)
				}
				self.isSyncing = false
			}
		})

		while isSyncing {
			usleep(1000000)
		}
	}

	func getBarcodes() {
		if deviceToken.isEmpty { return }
		
		isSyncing = true
		
		self.movementArticles.removeAll()
		
		makeHTTPGetRequest(url: "/api/movementarticle/\(movementId)", onCompletion: { data in
			if let usableData = data {
				do {
					let items = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments) as! [NSDictionary]
					
					for item in items {
						var movementArticle = MovementArticle()
						movementArticle.setJSONValues(item: item)
						self.movementArticles.append(movementArticle)
					}
				} catch {
					self.push(title: "getBarcodes", message: error.localizedDescription)
				}
				self.isSyncing = false
			}
		})
		
		while isSyncing {
			usleep(1000000)
		}
	}

	internal func makeHTTPGetRequest(url: String, onCompletion: @escaping ServiceResponse) {
		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Basic \(self.deviceName):\(self.deviceToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "GET"
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
			if self.onResponse(response: response as? HTTPURLResponse, error: error) {
				onCompletion(data)
			}
		})
		task.resume()
	}
	
	internal func makeHTTPPostRequest(url: String, body: NSDictionary, onCompletion: @escaping ServiceResponse) {

		var request =  URLRequest(url: URL(string: baseURL + url)!)
		request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
		request.addValue("Basic \(self.deviceName):\(self.deviceToken)", forHTTPHeaderField: "Authorization")
		request.httpMethod = "POST"
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 0))
		} catch let error as NSError {
			print(error)
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			data, response, error -> Void in
			if self.onResponse(response: response as? HTTPURLResponse, error: error) {
				onCompletion(data)
			}
		})
		task.resume()
	}

	internal func onResponse(response: HTTPURLResponse?, error: Error?) -> Bool {

		if error != nil {
			self.isSyncing = false
			self.push(title: "Error", message: error!.localizedDescription)
			return false
		}
		if response!.statusCode == 401 {
			self.isSyncing = false
			self.push(title: "Unauthorized", message: "Access is denied due to invalid credentials")
			return false
		}
		return true
	}

	// MARK: - Notification
	
	func push(title: String, message: String) {
		//print("\(title): \(message)")
		let notification = NSUserNotification()
		notification.title = title
		notification.informativeText = message
		notification.soundName = NSUserNotificationDefaultSoundName
		NSUserNotificationCenter.default.deliver(notification)
	}
}
