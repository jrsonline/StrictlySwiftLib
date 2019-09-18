//
//  FileHelper.swift
//  StrictlySwift
//
//  Created by strictlyswift on 11-May-19.
//

import Foundation

/// A sequence of lines read from a text file. The file is closed when the sequence goes out of scope
/// (is deinitialised).
/// It's also possible to read from a file handle, in which case the handle is NOT closed automatically.
public class FileLinesSequence: Sequence {
    let handle: FileHandle
    let encoding: String.Encoding
    let delimiter: Character
    private let ownedHandle : Bool
    
    public func makeIterator() -> FileLinesIterator {
        return FileLinesIterator(handle: self.handle, encoding: self.encoding, delimiter: self.delimiter)
    }
    
    public init(handle: FileHandle, encoding: String.Encoding, delimiter: Character) {
        self.handle = handle
        self.ownedHandle = false
        self.encoding = encoding
        self.delimiter = delimiter
    }
    
    public init?(fromFile file: String, encoding: String.Encoding, delimiter: Character) {
        guard let handle = FileHandle(forReadingAtPath: file) else { return nil }
        self.handle = handle
        self.encoding = encoding
        self.ownedHandle = true
        self.delimiter = delimiter
    }
    
    deinit {
        if self.ownedHandle {
            self.handle.closeFile()
        }
    }
    
    /// count  returns the number of lines in the file, plus one for the EOF (end of file).
    /// It remembers the current file offset, reads the whole file, and then restores the file offset
    /// (so although the file is consumed, this should not affect other operations)
    public var count: Int { get {
        let fileOffset = handle.offsetInFile
        handle.seek(toFileOffset: 0)
        let result = self.reduce(0) { (c,p) in c+1 }
        handle.seek(toFileOffset: fileOffset)
        
        return result
        }
    }
    
    /// underestimatedCount  returns  number of lines in the file, plus one for the EOF.
    /// It just calls 'count'.
    public var underestimatedCount : Int { get {
        return self.count
        }
    }
}

public struct FileLinesIterator: IteratorProtocol {
    private let handle: FileHandle
    private let encoding: String.Encoding
    private var moreToRead = true
    private let delimiter: Character
    
    private var newLineByte : UInt8 //= FileLinesIterator.newLineData.first!
    static private var chunkSize = 30
    
    
    public init(handle: FileHandle, encoding: String.Encoding, delimiter: Character) {
        self.handle = handle
        self.encoding = encoding
        self.delimiter = delimiter
        self.newLineByte = String(delimiter).data(using: self.encoding)!.first!
    }
    
    mutating public func next() -> String? {
        guard self.moreToRead else { return nil }
        
        var searchingForNewline = true   // true while looking for newline
        var currentLine = ""
        while searchingForNewline {
            let chunk = self.handle.readData(ofLength: FileLinesIterator.chunkSize)
            if chunk.count == 0 {
                self.moreToRead = false
                break
            }
            
            if let nextNewLineIdx = chunk.firstIndex(of: self.newLineByte) {
                // we read up to the newline
                currentLine.append(String(data: chunk[0..<nextNewLineIdx], encoding: self.encoding) ?? "")
                
                // Position the file pointer right after the newline
                let newOffset = self.handle.offsetInFile - UInt64(chunk.count) + UInt64(chunk.startIndex.distance(to: nextNewLineIdx)) + 1
                self.handle.seek(toFileOffset: newOffset)
                searchingForNewline = false

            } else {
                // if this chunk doesn't contain a newline, append to the current & carry on looking
                currentLine.append(String(data: chunk, encoding: self.encoding) ?? "")
            }
            
        }
        return currentLine
    }
}

public extension FileHandle {
    /// For a file handle, returns a sequence of lines (delimiter terminated) in the file.
    ///
    /// - Parameters:
    ///   - encoding: Encoding to use, defaults to UTF8
    ///   - delimiter: Line delimiter character, defaults to \n
    func lines(encoding: String.Encoding = .utf8, delimiter: Character = "\n") -> FileLinesSequence {
        return FileLinesSequence(handle: self, encoding: encoding, delimiter: delimiter)
    }
}

