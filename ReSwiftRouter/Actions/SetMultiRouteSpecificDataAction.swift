//
// SetMultiRouteSpecificDataAction.swift
//

import ReSwift


///
/// Sets route-specific data for a multi navigation route.
///
public struct SetMultiRouteSpecificDataAction:Action
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------
	
	public let route:Route
	public let data:Any
	

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------
	
	///
	/// Init with route and route-specific data.
	///
	public init(route:Route, data:Any)
	{
		self.route = route
		self.data = data
	}
}
