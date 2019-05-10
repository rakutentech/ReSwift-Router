//
//  Router.swift
//

import ReSwift


// ----------------------------------------------------------------------------------------------------
// MARK: - Enum
// ----------------------------------------------------------------------------------------------------

enum RoutingActions
{
	case Push(responsibleRoutableIndex:Int, segmentToBePushed:RouteSegment)
	case Pop(responsibleRoutableIndex:Int, segmentToBePopped:RouteSegment)
	case Change(responsibleRoutableIndex:Int, segmentToBeReplaced:RouteSegment, newSegment:RouteSegment)
}


open class Router<State:StateType>:StoreSubscriber
{
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Typealias
	// ----------------------------------------------------------------------------------------------------
	
	public typealias NavigationStateTransform = (Subscription<State>) -> Subscription<NavigationState>
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Properties
	// ----------------------------------------------------------------------------------------------------
	
	private var _store:Store<State>
	private var _lastNavigationState = NavigationState()
	private var _routables:[Routable] = []
	private let _waitForRoutingCompletionQueue = DispatchQueue(label: "WaitForRoutingCompletionQueue", attributes: [])
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - Init
	// ----------------------------------------------------------------------------------------------------
	
	public init(store:Store<State>, rootRoutable:Routable, stateTransform:@escaping NavigationStateTransform)
	{
		_store = store
		_routables.append(rootRoutable)
		_store.subscribe(self, transform: stateTransform)
	}
	
	
	// ----------------------------------------------------------------------------------------------------
	// MARK: - StoreSubscriber
	// ----------------------------------------------------------------------------------------------------
	
	open func newState(state:NavigationState)
	{
		let routingActions = Router.routingActionsForTransitionFrom(_lastNavigationState.route, newRoute: state.route)
		
		routingActions.forEach
		{
			routingAction in
				print("[Routing] ReSwiftRouter processing [\(routingAction)] ...")
				let semaphore = DispatchSemaphore(value: 0)
				
				// Dispatch all routing actions onto this dedicated queue. This will ensure that
				// only one routing action can run at any given time. This is important for using this
				// Router with UI frameworks. Whenever a navigation action is triggered, this queue will
				// block (using semaphore_wait) until it receives a callback from the Routable
				// indicating that the navigation action has completed
				_waitForRoutingCompletionQueue.async
				{
					switch routingAction
					{
						case let .Pop(responsibleRoutableIndex, segmentToBePopped):
							DispatchQueue.main.async
							{
								self._routables[responsibleRoutableIndex].pop(segmentToBePopped, animated: state.changeRouteAnimated)
								{
									semaphore.signal()
								}
								
								self._routables.remove(at: responsibleRoutableIndex + 1)
							}
						case let .Change(responsibleRoutableIndex, segmentToBeReplaced, newSegment):
							DispatchQueue.main.async
							{
								self._routables[responsibleRoutableIndex + 1] = self._routables[responsibleRoutableIndex].change(segmentToBeReplaced, to: newSegment, animated: state.changeRouteAnimated)
								{
									semaphore.signal()
								}
							}
						case let .Push(responsibleRoutableIndex, segmentToBePushed):
							DispatchQueue.main.async
							{
								self._routables.append(self._routables[responsibleRoutableIndex].push(segmentToBePushed, animated: state.changeRouteAnimated)
								{
									semaphore.signal()
								})
							}
					}
					
					let waitUntil = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
					let result = semaphore.wait(timeout: waitUntil)
					
					if case .timedOut = result
					{
						print("[WARNING] [Routing] ReSwift Router is stuck waiting for a completion handler to be called. Ensure that you have called the completion handler in each Routable element. Set a symbolic breakpoint for the `ReSwiftRouterStuck` symbol in order to halt the program when this happens.")
						ReSwiftRouterStuck()
					}
				}
		}
		
		_lastNavigationState = state
	}
	

	// ----------------------------------------------------------------------------------------------------
	// MARK: - Route Transformation Logic
	// ----------------------------------------------------------------------------------------------------
	
	private static func getLargestCommonSubroute(_ oldRoute:Route, newRoute:Route) -> Int
	{
		var largestCommonSubroute = -1
		while (largestCommonSubroute + 1 < newRoute.segmentCount && largestCommonSubroute + 1 < oldRoute.segmentCount && newRoute[largestCommonSubroute + 1] == oldRoute[largestCommonSubroute + 1])
		{
			largestCommonSubroute += 1
		}
		
		return largestCommonSubroute
	}
	
	
	///
	/// Maps Route index to Routable index. Routable index is offset by 1 because the root Routable
	/// is not represented in the route, e.g.
	/// route = ["tabBar"]
	/// routables = [RootRoutable, TabBarRoutable]
	///
	private static func getRoutableIndexForSegment(_ segment:Int) -> Int
	{
		return segment + 1
	}
	
	
	private static func routingActionsForTransitionFrom(_ oldRoute:Route, newRoute:Route) -> [RoutingActions]
	{
		var routingActions:[RoutingActions] = []
		
		// Find the last common subroute between two routes
		let commonSubroute = getLargestCommonSubroute(oldRoute, newRoute: newRoute)
		if commonSubroute == oldRoute.segmentCount - 1 && commonSubroute == newRoute.segmentCount - 1
		{
			return []
		}
		
		// Keeps track which element of the routes we are working on
		// We start at the end of the old route
		var routeBuildingIndex = oldRoute.segmentCount - 1
		
		// Pop all route segments of the old route that are no longer in the new route
		// Stop one element ahead of the commonSubroute. When we are one element ahead of the
		// commmon subroute we have three options:
		//
		// 1. The old route had an element after the commonSubroute and the new route does not
		//    we need to pop the route segment after the commonSubroute
		// 2. The old route had no element after the commonSubroute and the new route does, we
		//    we need to push the route segment(s) after the commonSubroute
		// 3. The new route has a different element after the commonSubroute, we need to replace
		//    the old route element with the new one
		while routeBuildingIndex > commonSubroute + 1
		{
			let routeSegmentToPop = oldRoute[routeBuildingIndex]
			let popAction = RoutingActions.Pop(responsibleRoutableIndex: getRoutableIndexForSegment(routeBuildingIndex - 1), segmentToBePopped: routeSegmentToPop)
			routingActions.append(popAction)
			routeBuildingIndex -= 1
		}
		
		// This is the 1. case:
		// "The old route had an element after the commonSubroute and the new route does not
		//  we need to pop the route segment after the commonSubroute"
		if oldRoute.segmentCount > newRoute.segmentCount
		{
			let popAction = RoutingActions.Pop(responsibleRoutableIndex: getRoutableIndexForSegment(routeBuildingIndex - 1), segmentToBePopped: oldRoute[routeBuildingIndex])
			routingActions.append(popAction)
			routeBuildingIndex -= 1
		}
		// This is the 3. case:
		// "The new route has a different element after the commonSubroute, we need to replace
		//  the old route element with the new one"
		else if oldRoute.segmentCount > (commonSubroute + 1) && newRoute.segmentCount > (commonSubroute + 1)
		{
			let changeAction = RoutingActions.Change(responsibleRoutableIndex: getRoutableIndexForSegment(commonSubroute), segmentToBeReplaced: oldRoute[commonSubroute + 1], newSegment: newRoute[commonSubroute + 1])
			routingActions.append(changeAction)
		}
		
		// Push remainder of elements in new Route that weren't in old Route, this covers
		// the 2. case:
		// "The old route had no element after the commonSubroute and the new route does,
		//  we need to push the route segment(s) after the commonSubroute"
		let newRouteIndex = newRoute.segmentCount - 1
		
		while routeBuildingIndex < newRouteIndex
		{
			let routeSegmentToPush = newRoute[routeBuildingIndex + 1]
			let pushAction = RoutingActions.Push(responsibleRoutableIndex: getRoutableIndexForSegment(routeBuildingIndex), segmentToBePushed: routeSegmentToPush)
			routingActions.append(pushAction)
			routeBuildingIndex += 1
		}
		
		return routingActions
	}
}


func ReSwiftRouterStuck()
{
}
