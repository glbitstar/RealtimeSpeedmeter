//
//  CSVLogger.swift
//  RealtimeSpeedmeter
//
//  Created by Atsushi Otsubo on 2023/01/28.
//

import Foundation

final class CSVLogger {
    private let lineFeedCode = "\n"
    private let comma = ","
    
    private var header: [String] = []
    private var body: [[String]] = [[]]
    private var outputDirectory: String = ""
    
    /// CSVファイルの出力先
    func set(outputDirectory: String) {
        self.outputDirectory = outputDirectory
    }
    
    /// CSVファイルのヘッダ(1行目)をセット
    func set(header: [String]) {
        self.header = header
    }
    
    /// CSVファイルのBody部の最終行に一行追加
    func appendBody(row: [String]) {
        if header.isEmpty { print("CSV header is Empty. You can use \"set(header: [String])\" function to set header.") }
        body.append(row)
    }
    
    /// CSVファイルのBody部をクリア
    func clearBody() { body = [[]] }
    
    /// CSVファイルへの保存 (ファイル名は時刻 [yyyyMMdd_HHmmss.csv])
    func save() {
        let now = Date()
        let formatter_csv = DateFormatter()
        formatter_csv.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = formatter_csv.string(from: now) + ".csv"
        save(with: fileName)
    }
    
    /// CSVファイルへの保存  (ファイル名指定 [fileName.csv])
    func save(with fileName: String) {
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let targetDirectoryPath = outputDirectory.isEmpty ?
            documentDirectoryFileURL : documentDirectoryFileURL.appending(path: outputDirectory)
            let targetFilePath = targetDirectoryPath.appending(component: fileName)
            
            do {
                let csvHeader = header.joined(separator: comma)
                let rows = body.map { $0.joined(separator: comma) }
                let csvBody = rows.joined(separator: lineFeedCode)
                let csvData = csvHeader + lineFeedCode + csvBody
                
                try csvData.write(to: targetFilePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error {
                print("CSV saving failed: \(error)")
            }
        }
    }
}
