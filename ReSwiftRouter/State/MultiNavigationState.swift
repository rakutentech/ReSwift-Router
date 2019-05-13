//
// MultiNavigationState.swift
//

import ReSwift


///
/// A state that stores a dictionary with routes mapped by string keys.
/// The keys represent a root route and the mapped routes are the stored routes of that top-level route.
///
/// This state should be solely used to store/restore the full route of each tabbar and should only be
/// accessed in the rerouting middleware!
///
public struct MultiNavigationState
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------
	
	public var routeMap:[String:Route] = [:]
	public var routeSpecificDataMap:[String:Any] = [:]
	
}
