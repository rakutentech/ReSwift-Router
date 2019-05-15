//
// Route.swift
//

import ReSwift


// ----------------------------------------------------------------------------------------------------
// MARK: - Typealias
// ----------------------------------------------------------------------------------------------------

public typealias RouteElementID = String
public typealias RouteHash = Int
public typealias RoutePath = [RouteSegment]


///
/// Represents a single segment in a route path.
///
public struct RouteSegment
{
	public var id:RouteElementID = ""
	public var data:Any? = nil
}


///
/// A data type that represents a route, i.e. a sequence of RouteElementIDs that are used to navigate
/// to a specific view state.
///
/// A route contains a path which is an array of strings that represent the full route to a specific
/// view state. It also contains a root path which is an array only containing the first two segments
/// of the path. This root path is used to identify any stored multi nav state.
///
public struct Route:Hashable
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------

	///
	/// The full route path.
	///
	public var path:RoutePath = []
	
	///
	/// The root route, that is, the first two elements of the route.
	///
	public var root:RoutePath = []
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Accessors
	// ----------------------------------------------------------------------------------------------------
	
	///
	/// Number of segments in the route.
	///
	public var segmentCount:Int
	{
		get { return path.count }
	}
	
	///
	/// The route path as a URL-formatted string, e.g. "Root/MyPage/MyPagePointView/Article-1/Article-2".
	///
	public var pathString:String
	{
		get { return path.count > 1 ? path.map({ $0.id }).joined(separator: "/") : "" }
	}
	
	///
	/// The root route as a URL-formatted string.
	///
	public var rootString:String
	{
		get { return root.count > 1 ? root.map({ $0.id }).joined(separator: "/") : "" }
	}
	
	
	///
	/// Hash of the route.
	///
	public var hashValue:RouteHash
	{
		return pathString.hashValue
	}
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------
	
	///
	/// Default init. Required for creating a default Route!
	///
	public init()
	{
	}
	
	
	///
	/// Creates a new route with a path. If the root path is omitted it will be
	/// generated from the specified path.
	///
	public init(_ path:RoutePath = [], _ root:RoutePath? = nil)
	{
		self.path = path
		self.root = root ?? subPath(0 ..< 2)
	}
	
	
	///
	/// Init with an array of RouteElementIDs.
	///
	public init(_ array:[RouteElementID] = [], _ root:RoutePath? = nil)
	{
		var path = [RouteSegment]()
		for element in array
		{
			path.append(RouteSegment(id: element, data: nil))
		}
		self.path = path
		self.root = root ?? subPath(0 ..< 2)
	}
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Methods
	// ----------------------------------------------------------------------------------------------------
	
	///
	/// Returns a route that is a sub-route of this route.
	///
	public func subRoute(_ range:Range<Int>) -> Route
	{
		return Route(subPath(range))
	}
	
	
	///
	/// Returns a route path that is a sub-route of this route.
	///
	public func subPath(_ range:Range<Int>) -> [RouteSegment]
	{
		if (range.lowerBound >= 0 && range.upperBound <= path.count)
		{
			return Array(path[range])
		}
		return path.map { $0 }
	}
	
	
	///
	/// Creates a clone of the route.
	///
	public func clone() -> Route
	{
		let clonedRoute = Route(path.map { $0 }, root.map { $0 })
		return clonedRoute
	}
	
	
	///
	/// Creates a clone of the route with given segment appended to its end.
	///
	public func cloneAndAppend(_ segment:RouteSegment) -> Route
	{
		var clonedPath = path.map { $0 }
		clonedPath.append(segment)
		let clonedRoute = Route(clonedPath, root.map { $0 })
		return clonedRoute
	}
	
	
	///
	/// Creates a clone of the route with the last segment removed.
	///
	public func cloneAndRemoveLast() -> Route
	{
		var clonedPath = path.map { $0 }
		if (clonedPath.count > 0) { clonedPath.removeLast() }
		let clonedRoute = Route(clonedPath, root.map { $0 })
		return clonedRoute
	}
	
	
	public func toString() -> String
	{
		return "[Route path=\(pathString), root=\(rootString)]"
	}
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Subscript Access
	// ----------------------------------------------------------------------------------------------------
	
	subscript(i:Int) -> RouteSegment
	{
		get { return path[i] }
		set { path[i] = newValue }
	}
}


// ----------------------------------------------------------------------------------------------------
// MARK: - Operator Overloads
// ----------------------------------------------------------------------------------------------------

public func ==(lhs:Route, rhs:Route) -> Bool
{
	return lhs.hashValue == rhs.hashValue
}


public func ==(lhs:RouteSegment, rhs:RouteSegment) -> Bool
{
	return lhs.id == rhs.id
}
