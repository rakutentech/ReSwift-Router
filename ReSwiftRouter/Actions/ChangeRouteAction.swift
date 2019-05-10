//
// ChangeRouteAction.swift
//

import ReSwift


///
/// Changes a route by providing a route path to pop and another one to push.
///
public struct ChangeRouteAction:Action
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------
	
	public let suffixToPop:RoutePath
	public let suffixToPush:RoutePath
	public let animated:Bool
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------
	
	public init(_ suffixToPop:RoutePath, _ suffixToPush:RoutePath, _ animated:Bool = false)
	{
		self.suffixToPop = suffixToPop
		self.suffixToPush = suffixToPush
		self.animated = animated
	}
}
