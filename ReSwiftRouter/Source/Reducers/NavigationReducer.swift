//
//  NavigationReducer.swift
//

import ReSwift


///
/// The Navigation Reducer handles the state slice concerned with storing the current navigation
/// information. Note, that this reducer is **not** a *top-level* reducer, you need to use it within
/// another reducer and pass in the relevant state slice. Take a look at the specs to see an
/// example set up.
///
public struct NavigationReducer
{
	public static func handleAction(_ action: Action, state: NavigationState?) -> NavigationState
	{
		let state = state ?? NavigationState()

		switch action
		{
			case let action as SetRouteAction:
				return updateState(state, action)
			default:
				break
		}

		return state
	}


	///
	/// Updates the state with the provided action's route.
	///
	private static func updateState(_ state: NavigationState, _ action: SetRouteAction) -> NavigationState
	{
		var state = state
		state.route = action.route
		state.changeRouteAnimated = action.animated
		return state
	}
}
