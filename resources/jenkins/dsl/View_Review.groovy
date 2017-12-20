categorizedJobsView('Review')
{
	jobs
	{
		regex('(.)*_Review_(.)*')
	}

	categorizationCriteria
	{
		regexGroupingRule('([a-z|0-9|.])+_Review_(.)*', 'Branches')
	}

	categorizationCriteria
	{
		regexGroupingRule('Review_Libs', 'Libraries')
	}

	categorizationCriteria
	{
		regexGroupingRule('(.)*__Review_Trigger', 'Sub-Trigger')
	}

	columns
	{
		status()
		weather()
		categorizedJob()
		lastSuccess()
		lastFailure()
		lastDuration()
		lastBuildConsole()
		buildButton()
	}
}
