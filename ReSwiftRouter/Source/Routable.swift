//
//  Routable.swift
//

import UIKit


// ----------------------------------------------------------------------------------------------------
// MARK: - Typealias
// ----------------------------------------------------------------------------------------------------

public typealias CompletionHandler = () -> Void


// ----------------------------------------------------------------------------------------------------
// MARK: - Protocol
// ----------------------------------------------------------------------------------------------------

public protocol Routable
{
	func push(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
	func pop(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler)
	func change(_ from:RouteSegment, to:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
}


///
/// Protocol for routables so they can be initialized exclicitly. Implement this in your Routable if
/// it should be instantiated as a generic.
///
public protocol RoutableInitializable:Routable
{
	init(_ viewController:UIViewController)
}


// ----------------------------------------------------------------------------------------------------
// MARK: - Routable
// ----------------------------------------------------------------------------------------------------

extension Routable
{
	public func push(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
	{
		fatalError("This routable cannot change segments. You have not implemented it.")
	}
	
	
	public func pop(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler)
	{
		fatalError("This routable cannot change segments. You have not implemented it.")
	}
	
	
	public func change(_ from:RouteSegment, to:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
	{
		fatalError("This routable cannot change segments. You have not implemented it.")
	}
}
