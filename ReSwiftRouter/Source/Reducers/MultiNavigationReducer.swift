//
// MultiNavigationReducer.swift
//

import ReSwift


///
/// Updates the multi navigation state.
///
public struct MultiNavigationReducer
{
	public static func handleAction(_ action:Action, state:MultiNavigationState?) -> MultiNavigationState
	{
		let state = state ?? MultiNavigationState()
		
		switch action
		{
			case let action as SetMultiRouteAction:
				return updateState(state, action)
			case let action as SetMultiRouteSpecificDataAction:
				return updateState(state, action)
			default:
				break
		}
		
		return state
	}
	
	
	///
	/// Updates the state with the provided action's route.
	///
	private static func updateState(_ state:MultiNavigationState, _ action:SetMultiRouteAction) -> MultiNavigationState
	{
		var state = state
		let key = action.route.rootString
		let value = action.route
		state.routeMap[key] = value
		return state
	}
	
	
	///
	/// Updates the state with the provided action's route-specific data.
	///
	private static func updateState(_ state:MultiNavigationState, _ action:SetMultiRouteSpecificDataAction) -> MultiNavigationState
	{
		var state = state
		let key = action.route.pathString
		let value = action.data
		state.routeSpecificDataMap[key] = value
		return state
	}
}
