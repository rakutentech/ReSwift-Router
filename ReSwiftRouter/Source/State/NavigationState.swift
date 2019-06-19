//
//  NavigationState.swift
//

import ReSwift


// ----------------------------------------------------------------------------------------------------
// MARK: - Protocol
// ----------------------------------------------------------------------------------------------------

public protocol HasNavigationState
{
	var navigationState: NavigationState
	{
		get set
	}
}


// ----------------------------------------------------------------------------------------------------
// MARK: - NavigationState
// ----------------------------------------------------------------------------------------------------

public struct NavigationState
{
	public var route = Route()
	var changeRouteAnimated: Bool = true


	public init()
	{
	}
}
