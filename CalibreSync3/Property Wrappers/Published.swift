//
//  Published.swift
//  CalibreSync3
//
//  Created by Sumanth Peddamatham on 12/14/19.
//  Copyright © 2019 Sumanth Peddamatham. All rights reserved.
//
//  Reference: https://stackoverflow.com/questions/57611658/swiftui-how-to-persist-published-variable-using-userdefaults

import Combine
import Foundation

private var cancellableSet: Set<AnyCancellable> = []

extension Published where Value: Codable {
  init(wrappedValue defaultValue: Value, key: String) {
    if let data = UserDefaults.standard.data(forKey: key) {
      do {
        let value = try JSONDecoder().decode(Value.self, from: data)
        self.init(initialValue: value)
      } catch {
        print("Error decoding user data")
        self.init(initialValue: defaultValue)
      }
    } else {
      self.init(initialValue: defaultValue)
    }

    projectedValue
      .sink { val in
        do {
          let data = try JSONEncoder().encode(val)
          UserDefaults.standard.set(data, forKey: key)
        } catch {
          print("Error while decoding user data")
        }
      }
      .store(in: &cancellableSet)
  }
}
