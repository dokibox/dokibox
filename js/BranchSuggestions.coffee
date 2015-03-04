class BranchSuggestions

	constructor: ( branches, @attachedNode, @clickCb ) ->
		@parent = document.querySelector '#branch-suggestions'
		@list   = @parent.querySelector '#suggestion-list'
		@shown  = false

		@branches = { }
		@branchNames = [ ]
		for key of branches
			@branches[key] = @createElement key
			@branchNames.push key

		@branchNames.sort ( a, b ) ->
			c = a.toLowerCase( )
			d = b.toLowerCase( )
			return  0 if c is d
			return -1 if c < d
			return  1 if c > d

		oldResizeCb = window.onresize
		window.onresize = =>
			@reflow( )
			oldResizeCb( )

	createElement: ( name ) ->
			listItem = document.createElement 'li'
			listItem.className = "suggestion"
			listItem.innerHTML = name
			listItem.addEventListener 'click', @clickCb, no
			listItem

	show: ->
		return if @shown
		@shown = true
		@reflow( )

		fragment = document.createDocumentFragment( )
		for branchName in @branchNames
			@branches[branchName].innerHTML = branchName
			fragment.appendChild @branches[branchName]

		@list.appendChild fragment
		@parent.style.display = "block"

	clear: ->
		while @list.firstChild
			@list.removeChild @list.firstChild

	hide: ->
		return unless @shown
		@clear( )
		@parent.style.display = "none"
		@shown = false

	filter: ( string ) ->
		# Destroying and rebuilding the list is the easiest/laziest way to
		# do this.
		@clear( )
		fragment = document.createDocumentFragment( )
		for branchName in @branchNames
			# Don't use a regular expression to match because it will explode
			# on e.g. unclosed (. But do do case insensitive matching.
			if -1 < startIndex = branchName.toLowerCase( ).indexOf string.toLowerCase( )
				endIndex = startIndex + string.length
				match    = branchName[startIndex...endIndex]
				branch = @branches[branchName]
				branch.innerHTML = branchName[0...startIndex] + "<span class='match'>" + match + "</span>" + branchName[endIndex...branchName.length]
				fragment.appendChild branch

		@list.appendChild fragment

	reflow: ->
		return unless @shown
		bodyBounds         = document.querySelector('body').getBoundingClientRect( )
		inputBounds        = @attachedNode.getBoundingClientRect( )
		@parent.style.top  = inputBounds.top + inputBounds.height - bodyBounds.top + 'px'
		@parent.style.left = inputBounds.left + 'px'

window.BranchSuggestions = BranchSuggestions
