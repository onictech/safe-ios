//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// `Database` defines the main interface to work with SQL database.
public protocol Database: class {

    /// True if the database
    var exists: Bool { get }

    /// Creates the database. Throws error if the database already exists.
    /// May throw error if unable to create the database for some other reason.
    ///
    /// - Throws: May throw error if some problem encountered.
    func create() throws

    /// Deletes the database. All active connections are closed automatically before destroying.
    ///
    /// - Throws: if unable to destroy the database.
    func destroy() throws

    /// Creates new connection to the database and opens it. The database must exist, otherwise error is thrown.
    ///
    /// - Returns: Initialized and opened connection.
    /// - Throws: error thrown if database does not exist or some problem creating connection encountered.
    func connection() throws -> Connection

    /// Closes opened connection that was created by `connection()` method. If the connection is already closed,
    /// the method throws error.
    ///
    /// - Parameter connection: connection that was created before.
    /// - Throws: if connection was closed, method throws error. May throw other error if closing failed.
    func close(_ connection: Connection) throws

    /// Executes arbitrary SQL statement, binding values from `bindings` and `dict` arguments to it.
    /// This method is meant for update queries.
    ///
    /// See `execute(sql:bindings:dict:resultMap:)` for executing SQL select queries that return result. That method
    /// is used under the hood by default protocol implement
    ///
    /// - Parameters:
    ///   - sql: SQL string to execute
    ///   - bindings: Array of optional bindable values to bind with SQL statement by array index.
    ///     You don't have to worry about indexes if you are using this method, just make sure you are passing as
    ///     many values as there are positional parameters in your SQL statement, otherwise it is treated as a
    ///     programmer's error and will crash.
    ///   - dict: Dictionary of bindable values to bind with SQL statement by keys.
    /// - Returns: result of the SQL statement is ignored.
    /// - Throws: may throw error if there is a problem with SQL statement or with the database.
    func execute(sql: String, bindings: [SQLBindable?], dict: [String: SQLBindable?]) throws

    /// Executes SQL command that returns some result. Each result row is transformed using `resultMap` closure.
    ///
    /// ## Discussion
    /// The default protocol implementation of this method opens connection, creates prepared statement with `sql`
    /// parameter, binds all `bindings` first, then binds all `dict` bindings.
    ///
    /// After that, it executes the statement.
    ///
    /// If SQL statement doesn't return results, then the method returns empty array.
    ///
    /// Otherwise, the returned `ResultSet` is passed to the `resultMap` closure after every call to
    /// `advanceToNextRow()`, while it returns true. The return value of the `resultMap` call is appended to a temporary
    /// array, which is finally returned from the method. Before returning, the method
    /// closes opened database connection.
    ///
    /// - Parameters:
    ///   - sql: SQL command to execute
    ///   - bindings: Array of optional positional bindings for SQL command
    ///     You don't have to worry about indexes if you are using this method, just make sure you are passing as
    ///     many values as there are positional parameters in your SQL statement, otherwise it is treated as a
    ///     programmer's error and will crash.
    ///   - dict: Dictionary of keyed bindings for SQL command
    ///   - resultMap: Transform of result row (`ResultSet`) to a return type T
    ///   - rs: `ResultSet` to convert to type T
    /// - Returns: Array of transformed result rows
    /// - Throws: may throw error if there was a problem in SQL statement, or in the database, or in transform closure.
    func execute<T>(sql: String,
                    bindings: [SQLBindable?],
                    dict: [String: SQLBindable?],
                    resultMap: (_ rs: ResultSet) throws -> T?) throws -> [T?]


}

/// Represents a connection to a database. Connections are supposed to be created by `Database` and also closed by it.
public protocol Connection: class {

    /// Creates a prepared statement - a compiled SQL command for further execution.
    ///
    /// Connection must be opened before this method is called.
    ///
    /// - Parameter statement: SQL command
    /// - Returns: compiled version of SQL command - prepared statement
    /// - Throws: Throws error if the SQL is invalid or there was some problem in the database.
    func prepare(statement: String) throws -> Statement
    /// Fetches last occurred error description
    ///
    /// - Returns: Human-readable error description.
    func lastErrorMessage() -> String?

}

/// Represents a prepared statement - a compiled SQL statement that can be executed.
/// You can bind values to position-based or name-based variables in SQL statement.
public protocol Statement: class {

    /// Binds String value to indexed SQL variable (index is 1-based)
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - index: position to where to bind (1-based)
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: String, at index: Int) throws

    /// Binds binary Data value to indexed SQL variable (index is 1-based)
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - index: position to where to bind (1-based)
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: Data, at index: Int) throws

    /// Binds integer value to indexed SQL variable (index is 1-based)
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - index: position to where to bind (1-based)
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: Int, at index: Int) throws

    /// Binds double value to indexed SQL variable (index is 1-based)
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - index: position to where to bind (1-based)
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: Double, at index: Int) throws

    /// Binds NULL value to indexed SQL variable (index is 1-based)
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - index: position to where to bind (1-based)
    /// - Throws: May throw error if there is a problem in the database.
    func setNil(at index: Int) throws

    /// Binds String value to a named SQL variable
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - key: name of the variable in SQL command
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: String, forKey key: String) throws

    /// Binds binary Data value to a named SQL variable
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - key: name of the variable in SQL command
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: Data, forKey key: String) throws

    /// Binds integer value to a named SQL variable
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - key: name of the variable in SQL command
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: Int, forKey key: String) throws

    /// Binds double value to a named SQL variable
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - key: name of the variable in SQL command
    /// - Throws: May throw error if there is a problem in the database.
    func set(_ value: Double, forKey key: String) throws

    /// Binds NULL value to a named SQL variable
    ///
    /// - Parameters:
    ///   - value: value to bind
    ///   - key: name of the variable in SQL command
    /// - Throws: May throw error if there is a problem in the database.
    func setNil(forKey key: String) throws

    /// Executes prepared statement and optionally returns the `ResultSet`, if the statement returns any rows.
    ///
    /// - Returns: ResultSet if this is a query statement
    /// - Throws: May throw error if the statement invalid or there is some database problem.
    @discardableResult func execute() throws -> ResultSet?

    /// Binds array of supported bindable values (or nils) to the position variables in the statement.
    ///
    /// - Parameter bindings: Array of values to bind.
    /// - Throws: May throw error if there was a problem in the database.
    func bind(_ bindings: [SQLBindable?]) throws

    /// Binds array of supported bindable values (or nils) to the named variables in the statement.
    ///
    /// - Parameter bindings: Dictionary of values to bind.
    /// - Throws: May throw error if there was a problem in the database.
    func bind(_ bindings: [String: SQLBindable?]) throws

}

/// Represents one row of the query result. You can move to the next row with `ResultSet.advanceToNextRow()` method
/// and fetch column values of the current row as String, Int, Double, or Data.
public protocol ResultSet: class {

    /// Moves to the next result row, returning true when there is more to get,
    /// and false if that is the last result row.
    ///
    /// - Returns: true if more rows available, false if no more rows available.
    /// - Throws: Throws error if there was a problem in the database.
    func advanceToNextRow() throws -> Bool

    /// Fetch value at column `index` as a String
    ///
    /// - Parameter index: 0-based column index
    /// - Returns: String represntation of the value or nil if the result is NULL
    func string(at index: Int) -> String?
    func string(column: String) -> String?
    subscript(index: Int) -> String? { get }
    subscript(column: String) -> String? { get }

    /// Fetch value at column `index` as integer
    ///
    /// - Parameter index: 0-based column index
    /// - Returns: Value converted to integer, or nil if the value is NULL
    func int(at index: Int) -> Int?
    func int(column: String) -> Int?
    subscript(index: Int) -> Int? { get }
    subscript(column: String) -> Int? { get }

    /// Fetch value at column `index` as boolean
    ///
    /// - Parameter index: 0-based column index
    /// - Returns: Value converted to boolean, or nil if the value is NULL
    func bool(at index: Int) -> Bool?
    func bool(column: String) -> Bool?
    subscript(index: Int) -> Bool? { get }
    subscript(column: String) -> Bool? { get }

    /// Fetch value at column `index` as double
    ///
    /// - Parameter index: 0-based column index
    /// - Returns: Value converted to double, or nil if the value is NULL
    func double(at index: Int) -> Double?
    func double(column: String) -> Double?
    subscript(index: Int) -> Double? { get }
    subscript(column: String) -> Double? { get }

    /// Fetch value at column `index` as binary data
    ///
    /// - Parameter index: 0-based column index
    /// - Returns: Value converted to binary data, or nil if the value is NULL
    func data(at index: Int) -> Data?
    func data(column: String) -> Data?
    subscript(index: Int) -> Data? { get }
    subscript(column: String) -> Data? { get }

}

/// Marker protocol for data types supported for binding to an SQL statement.
/// The default types are Int, Double, String, and Data
public protocol SQLBindable {}

extension Int: SQLBindable {}
extension Double: SQLBindable {}
extension String: SQLBindable {}
extension Data: SQLBindable {}
extension Bool: SQLBindable {}


public extension Statement {

    func bind(_ bindings: [SQLBindable?]) throws {
        try bindings.enumerated().map { ($0 + 1, $1) }.forEach { index, value in
            guard let value = value else {
                try setNil(at: index)
                return
            }
            switch value {
            case let int as Int: try set(int, at: index)
            case let double as Double: try set(double, at: index)
            case let string as String: try set(string, at: index)
            case let data as Data: try set(data, at: index)
            case let bool as Bool: try set(bool == false ? 0 : 1, at: index)
            default: preconditionFailure("Unrecognized SQLBindable type at index \(index - 1)")
            }
        }
    }

    func bind(_ bindings: [String: SQLBindable?]) throws {
        try bindings.forEach { key, value in
            guard let value = value else {
                try setNil(forKey: key)
                return
            }
            switch value {
            case let int as Int: try set(int, forKey: key)
            case let double as Double: try set(double, forKey: key)
            case let string as String: try set(string, forKey: key)
            case let data as Data: try set(data, forKey: key)
            case let bool as Bool: try set(bool == false ? 0 : 1, forKey: key)
            default: preconditionFailure("Unrecognized SQLBindable type for key \(key)")
            }
        }
    }

}

public extension Database {

    func execute(sql: String,
                 bindings: [SQLBindable?] = [],
                 dict: [String: SQLBindable?] = [:]) throws {
        let map: (ResultSet) throws -> Void? = { _ in nil }
        _ = try self.execute(sql: sql, bindings: bindings, dict: dict, resultMap: map)
    }

    func execute<T>(sql: String,
                    bindings: [SQLBindable?] = [],
                    dict: [String: SQLBindable?] = [:],
                    resultMap: (ResultSet) throws -> T?) throws -> [T?] {
        let conn = try connection()
        defer { try? close(conn) }
        return try conn.execute(sql: sql, bindings: bindings, dict: dict, resultMap: resultMap)
    }

}

public extension Connection {

    func execute(sql: String,
                 bindings: [SQLBindable?] = [],
                 dict: [String: SQLBindable?] = [:]) throws {
        let map: (ResultSet) throws -> Void? = { _ in nil }
        _ = try self.execute(sql: sql, bindings: bindings, dict: dict, resultMap: map)
    }

    func execute<T>(sql: String,
                    bindings: [SQLBindable?] = [],
                    dict: [String: SQLBindable?] = [:],
                    resultMap: (ResultSet) throws -> T?) throws -> [T?] {
        let stmt = try prepare(statement: sql)
        try stmt.bind(bindings)
        try stmt.bind(dict)
        guard let rs = try stmt.execute() else { return [] }
        var result = [T?]()
        while try rs.advanceToNextRow() {
            try result.append(resultMap(rs))
        }
        return result
    }

}


public class ResultSetRowIterator {

    private var index = 0
    private let rs: ResultSet

    public init(_ rs: ResultSet) {
        self.rs = rs
    }

    public func nextString() -> String? {
        defer { next() }
        return rs.string(at: index)
    }

    public func nextInt() -> Int? {
        defer { next() }
        return rs.int(at: index)
    }

    public func nextDouble() -> Double? {
        defer { next() }
        return rs.double(at: index)
    }

    public func nextData() -> Data? {
        defer { next() }
        return rs.data(at: index)
    }

    private func next() {
        index += 1
    }

}

public extension ResultSet {

    func rowIterator() -> ResultSetRowIterator {
        return ResultSetRowIterator(self)
    }

    subscript(index: Int) -> Int? {
        return int(at: index)
    }

    subscript(index: Int) -> Bool? {
        return bool(at: index)
    }

    subscript(index: Int) -> String? {
        return string(at: index)
    }

    subscript(index: Int) -> Double? {
        return double(at: index)
    }

    subscript(index: Int) -> Data? {
        return data(at: index)
    }

    subscript(column: String) -> Int? {
        return int(column: column)
    }

    subscript(column: String) -> Bool? {
        return bool(column: column)
    }

    subscript(column: String) -> String? {
        return string(column: column)
    }

    subscript(column: String) -> Double? {
        return double(column: column)
    }

    subscript(column: String) -> Data? {
        return data(column: column)
    }

}
