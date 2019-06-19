//
//  Routable.swift
//

import UIKit


// ----------------------------------------------------------------------------------------------------
// MARK: - Typealias
// ----------------------------------------------------------------------------------------------------

public typealias CompletionHandler = () -> Void


// ----------------------------------------------------------------------------------------------------
// MARK: - RoutableViewController
// ----------------------------------------------------------------------------------------------------

///
/// To be implemented by view controllers that want to be called by routables as a result of a
/// routing change/puish/pop action.
///
public protocol RoutableViewController
{
	///
	/// Tells a view controller that the routing has changed and that the view should update
	/// according to the provided ID. The ID represents the route segment.
	///
	/// The method needs to return the viewcontroller used for the sub routable.
	///
	func routeToSubView(_ id:String, _ animated:Bool) -> UIViewController?
}


// ----------------------------------------------------------------------------------------------------
// MARK: - Routable
// ----------------------------------------------------------------------------------------------------

public protocol Routable
{
	func push(_ segment: RouteSegment, animated: Bool, completion: @escaping CompletionHandler) -> Routable
	func pop(_ segment: RouteSegment, animated: Bool, completion: @escaping CompletionHandler)
	func change(_ from: RouteSegment, to: RouteSegment, animated: Bool, completion: @escaping CompletionHandler) -> Routable
}


extension Routable
{
	public func change(_ from: RouteSegment, to: RouteSegment, animated: Bool, completion: @escaping CompletionHandler) -> Routable
	{
		fatalError("This routable cannot change segments. You have not implemented it.")
	}


	public func push(_ segment: RouteSegment, animated: Bool, completion: @escaping CompletionHandler) -> Routable
	{
		fatalError("This routable cannot change segments. You have not implemented it.")
	}


	public func pop(_ segment: RouteSegment, animated: Bool, completion: @escaping CompletionHandler)
	{
		fatalError("This routable cannot change segments. You have not implemented it.")
	}
}


// ----------------------------------------------------------------------------------------------------
// MARK: - BaseRoutable
// ----------------------------------------------------------------------------------------------------

///
/// Routable class that can used as base for routables. It provides a lot of the shared functionality
/// such as taking care of navigating to sub views and default implementation for change/push/pop.
///
open class BaseRoutable: Routable
{
	let _viewController:UIViewController?


	public required init(_ viewController: UIViewController?)
	{
		_viewController = viewController
	}


	public func change(_ from: RouteSegment, to: RouteSegment, animated: Bool, completion: @escaping CompletionHandler) -> Routable
	{
		completion()
		return self
	}


	public func push(_ segment: RouteSegment, animated: Bool, completion: @escaping CompletionHandler) -> Routable
	{
		completion()
		return self
	}


	public func pop(_ segment: RouteSegment, animated: Bool, completion: @escaping CompletionHandler)
	{
		completion()
	}


	///
	/// Navigates to a sub view. The routableType's view controller needs to implement RoutableViewController.
	///
	public func navigateToSubView<T:BaseRoutable>(_ id:String, _ routableType:T.Type, _ animated:Bool = true, _ completion:@escaping CompletionHandler) -> T
	{
		/* Is this routable's viewController a navigation controller that has a
		   navigatable view controller as it's first sub view controller? */
		if let navigationController = _viewController as? UINavigationController,
		   navigationController.viewControllers.isEmpty == false,
		   let subViewController = navigationController.viewControllers[0] as? RoutableViewController,
		   let vc = subViewController.routeToSubView(id, animated)
		{
			completion()
			return routableType.init(vc)
		}

		/* Or is this routable's viewController a navigatable view controller? */
		if let routableViewController = _viewController as? RoutableViewController,
		   let vc = routableViewController.routeToSubView(id, animated)
		{
			//print("[TRACE] [Routing] routableType=\(routableType), viewController=\(vc)")
			completion()
			return routableType.init(vc)
		}

		print("[ERROR] [Routing] BaseRoutable: Failed to navigate to route segment with ID \"\(id)\". Is \(String(describing: _viewController)) a RoutableViewController?")

		completion()
		return routableType.init(nil)
	}
}
