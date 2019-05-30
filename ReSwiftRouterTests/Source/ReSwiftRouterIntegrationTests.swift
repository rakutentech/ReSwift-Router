//
//  SwiftFlowRouterTests.swift
//  SwiftFlowRouterTests
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Quick
import Nimble
import ReSwift
@testable import ReSwiftRouter


// ----------------------------------------------------------------------------------------------------
// MARK: - Routable
// ----------------------------------------------------------------------------------------------------

class MockRoutable:Routable
{
	var callsToPushRouteSegment:[(routeElement:RouteElementID, animated:Bool)] = []
	var callsToPopRouteSegment:[(routeElement:RouteElementID, animated:Bool)] = []
	var callsToChangeRouteSegment: [(from:RouteElementID, to:RouteElementID, animated:Bool)] = []
	
	
	func push(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
	{
		callsToPushRouteSegment.append((routeElement: segment.id, animated: animated))
		completion()
		return MockRoutable()
	}
	
	
	func pop(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler)
	{
		callsToPopRouteSegment.append((routeElement: segment.id, animated: animated))
		completion()
	}
	
	
	func change(_ from:RouteSegment, to:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
	{
		completion()
		callsToChangeRouteSegment.append((from: from.id, to: to.id, animated: animated))
		return MockRoutable()
	}
}


struct FakeAppState:StateType
{
	var navigationState = NavigationState()
}


func fakeReducer(action:Action, state:FakeAppState?) -> FakeAppState
{
	return state ?? FakeAppState()
}


func appReducer(action:Action, state:FakeAppState?) -> FakeAppState
{
	return FakeAppState(navigationState: NavigationReducer.handleAction(action, state: state?.navigationState))
}


// ----------------------------------------------------------------------------------------------------
// MARK: - SwiftFlowRouterIntegrationTests
// ----------------------------------------------------------------------------------------------------

class SwiftFlowRouterIntegrationTests:QuickSpec
{
	override func spec()
	{
		describe("Routing calls")
		{
			var store:Store<FakeAppState>!
			beforeEach
			{
				store = Store(reducer: appReducer, state: FakeAppState())
			}
			
			describe("Setup")
			{
				it("does not request the root view controller when no route is provided")
				{
					class FakeRootRoutable:Routable
					{
						var called = false
						func push(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
						{
							called = true
							return MockRoutable()
						}
					}
					
					let routable = FakeRootRoutable()
					let _ = Router(store: store, rootRoutable: routable)
					{
						state in
							state.select { $0.navigationState }
					}
					
					expect(routable.called).to(beFalse())
				}
				
				it("requests the root with identifier when an initial route is provided")
				{
					store.dispatch(SetRouteAction(["TabBarViewController"]))
					
					class FakeRootRoutable:Routable
					{
						var calledWithIdentifier:(RouteElementID?) -> Void
						init(calledWithIdentifier:@escaping (RouteElementID?) -> Void)
						{
							self.calledWithIdentifier = calledWithIdentifier
						}
						
						func push(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
						{
							calledWithIdentifier(segment.id)
							completion()
							return MockRoutable()
						}
					}
					
					waitUntil(timeout: 2.0)
					{
						fullfill in
							let rootRoutable = FakeRootRoutable
							{
								identifier in
								if identifier == "TabBarViewController"
								{
									fullfill()
								}
							}
							
							let _ = Router(store: store, rootRoutable: rootRoutable)
							{
								state in
									state.select { $0.navigationState }
							}
					}
				}
				
				it("calls push on the root for a route with two elements")
				{
					store.dispatch(SetRouteAction(["TabBarViewController", "SecondViewController"]))
					
					class FakeChildRoutable:Routable
					{
						var calledWithIdentifier:(RouteElementID?) -> Void
						init(calledWithIdentifier:@escaping (RouteElementID?) -> Void)
						{
							self.calledWithIdentifier = calledWithIdentifier
						}
						
						func push(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
						{
							calledWithIdentifier(segment.id)
							completion()
							return MockRoutable()
						}
					}
					
					waitUntil(timeout: 5.0)
					{
						completion in
						let fakeChildRoutable = FakeChildRoutable()
						{
							identifier in
								if identifier == "SecondViewController" { completion() }
						}
						
						class FakeRootRoutable:Routable
						{
							let injectedRoutable:Routable
							
							init(injectedRoutable:Routable)
							{
								self.injectedRoutable = injectedRoutable
							}
							
							func push(_ segment:RouteSegment, animated:Bool, completion:@escaping CompletionHandler) -> Routable
							{
								completion()
								return injectedRoutable
							}
						}
						
						let _ = Router(store: store, rootRoutable:FakeRootRoutable(injectedRoutable: fakeChildRoutable))
						{
							state in
							state.select
							{
								$0.navigationState
							}
						}
					}
				}
			}
		}
		
		describe("Route specific data")
		{
			var store:Store<FakeAppState>!
			beforeEach
			{
				store = Store(reducer: appReducer, state: nil)
			}
			
			context("When setting route specific data")
			{
				beforeEach
				{
					store.dispatch(SetRouteSpecificDataAction(route: Route(["part1", "part2"]), data: "UserID_10"))
				}
				
				it("allows accessing the data when providing the expected type")
				{
					let data:String? = store.state.navigationState.getRouteSpecificData(Route(["part1", "part2"]))
					expect(data).toEventually(equal("UserID_10"))
				}
			}
		}
		
		describe("Configuring animated/unanimated navigation")
		{
			var store:Store<FakeAppState>!
			var mockRoutable:MockRoutable!
			var router:Router<FakeAppState>!
			
			beforeEach
			{
				store = Store(reducer: appReducer, state: nil)
				mockRoutable = MockRoutable()
				router = Router(store: store, rootRoutable: mockRoutable)
				{
					state in
						state.select { $0.navigationState }
				}
				
				// silence router not read warning, need to keep router alive via reference
				_ = router
			}
			
			context("When dispatching an animated route change")
			{
				beforeEach
				{
					store.dispatch(SetRouteAction(["someRoute"], animated: true))
				}
				
				it("calls routables asking for an animated presentation")
				{
					expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
				}
			}
			
			context("When dispatching an unanimated route change")
			{
				beforeEach
				{
					store.dispatch(SetRouteAction(["someRoute"], animated: false))
				}
				
				it("calls routables asking for an animated presentation")
				{
					expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beFalse())
				}
			}
			
			context("When dispatching a default route change")
			{
				beforeEach
				{
					store.dispatch(SetRouteAction(["someRoute"]))
				}
				
				it("calls routables asking for an animated presentation")
				{
					expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
				}
			}
		}
	}
}
