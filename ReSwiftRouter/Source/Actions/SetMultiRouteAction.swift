//
//  SetMultiRouteAction.swift
//

import ReSwift


///
/// A ReSwift action that sets the multi navigation route for a specific top route.
///
public struct SetMultiRouteAction:Action
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------
	
	public let route:Route
	public let animated:Bool
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------
	
	///
	/// Init with route.
	///
	public init(route:Route, animated:Bool = true)
	{
		self.route = route
		self.animated = animated
	}
}
