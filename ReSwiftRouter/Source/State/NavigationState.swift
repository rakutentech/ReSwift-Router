//
//  NavigationState.swift
//

import ReSwift


// ----------------------------------------------------------------------------------------------------
// MARK: - Protocol
// ----------------------------------------------------------------------------------------------------

public protocol HasNavigationState
{
	var navigationState:NavigationState { get set }
}


// ----------------------------------------------------------------------------------------------------
// MARK: - NavigationState
// ----------------------------------------------------------------------------------------------------

public struct NavigationState
{
	public var route = Route()
	public var routeSpecificData:[RouteHash:Any] = [:]
	var changeRouteAnimated:Bool = true
	
	public init() { }
}


extension NavigationState
{
	public func getRouteSpecificData<T>(_ route:Route) -> T?
	{
		return routeSpecificData[route.hashValue] as? T
	}
}
