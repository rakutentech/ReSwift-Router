//
// PushRouteSegmentAction.swift
//

import ReSwift


///
/// Pushes a single route segment onto the routing stack.
///
public struct PushRouteSegmentAction: Action
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------

	public let segment: RouteSegment
	public let animated: Bool


	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------

	///
	/// Init with route segment.
	///
	public init(segment: RouteSegment, animated: Bool = true)
	{
		self.segment = segment
		self.animated = animated
	}


	///
	/// Init with a RouteElementID.
	///
	public init(elementID: RouteElementID, animated: Bool = true)
	{
		self.segment = RouteSegment(id: elementID, data: nil)
		self.animated = animated
	}
}
