//
// PopRouteSegmentAction.swift
//

import ReSwift


///
/// Removes the last added route segment from the routing stack and navigates back accordingly.
///
public struct PopRouteSegmentAction: Action
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------

	public let animated: Bool


	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------

	public init(animated: Bool = true)
	{
		self.animated = animated
	}
}
