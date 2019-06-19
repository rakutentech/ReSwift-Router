//
// SetRouteAction.swift
//

import ReSwift


///
/// SetRouteAction
///
public struct SetRouteAction: Action
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------

	public let route: Route
	public let animated: Bool


	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------

	///
	/// Init with given route.
	///
	public init(_ route: Route, animated: Bool = true)
	{
		self.route = route
		self.animated = animated
	}


	///
	/// Init with a route path.
	///
	public init(_ path: RoutePath, animated: Bool = true)
	{
		self.route = Route(path)
		self.animated = animated
	}


	///
	/// Init with an array of RouteElementIDs.
	///
	public init(_ path: [RouteElementID], animated: Bool = true)
	{
		self.route = Route(path)
		self.animated = animated
	}
}
