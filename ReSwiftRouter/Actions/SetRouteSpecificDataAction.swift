//
// SetRouteSpecificDataAction.swift
//

import ReSwift


///
/// SetRouteSpecificData
///
public struct SetRouteSpecificDataAction:Action
{
	public let route:Route
	public let data:Any
	
	
	public init(route:Route, data:Any)
	{
		self.route = route
		self.data = data
	}
}
