listElement = document.querySelector "ul#builds"

unfuckHierarchy = ( targetNode, parentNode ) ->
	switch targetNode.tagName
		when 'SVG', 'svg'
			targetNode = parentNode
			parentNode = targetNode.parentNode.parentNode
		when 'PATH', 'path'
			targetNode = parentNode.parentNode
			parentNode = targetNode.parentNode.parentNode
		when 'DIV'
			# It is apparently impossible to hover over an <a> element.
			switch targetNode.className
				when 'download', 'commit'
					parentNode = targetNode.parentNode.parentNode
		when 'LI'
			return [false, false]

	return [targetNode, parentNode]

mouseover = ( ev ) ->
	[targetNode, parentNode] = unfuckHierarchy ev.target, ev.target.parentNode

	if targetNode is false
		return false

	[lastTarget, lastParent] = @lastNode or []
	if lastParent is parentNode
		clearTimeout @mouseOutTimer
	if targetNode is lastTarget
		return false

	identity = targetNode.className
	index = parentNode.id
	artifact = @artifacts[@displayBranch][index]

	info = parentNode.querySelector ".info"
	switch identity
		when 'size'
			info.textContent = artifact.size.text
		when 'info'
			info.textContent = artifact.date.alt
		when 'commit'
			info.textContent = artifact.file.commitText
		when 'download'
			info.textContent = artifact.hash.text

	false

mouseout = ( ev ) ->
	[targetNode, parentNode] = unfuckHierarchy ev.target, ev.target.parentNode

	if targetNode is false
		return false

	@lastNode = [targetNode, parentNode]
	@mouseOutTimer = setTimeout =>
		@lastNode = [null, null]
		identity = targetNode.className
		index = parentNode.id

		info = parentNode.querySelector ".info"
		info.textContent = @artifacts[@displayBranch][index].date.text
	, 1

dokiboxArtifacts = new window.ArtifactParser "https://s3.amazonaws.com/dokibox-builds/", "https://github.com/dokibox/dokibox/"
dokiboxArtifacts.fetchListing ->
	mouseOverCb = ( ev ) =>
		mouseover.call @, ev
	mouseOutCb = ( ev ) =>
		mouseout.call @, ev

	clickListener = ( build ) ->
		build.querySelector( 'div.download' ).addEventListener 'click', ( ev ) ->
			build.removeEventListener "mouseover", mouseOverCb, false
			build.removeEventListener "mouseout", mouseOutCb, false

	@insertRange listElement, [0, 9]

	builds = document.querySelectorAll "li.entry"

	for build in builds
		build.addEventListener "mouseover", mouseOverCb, false
		build.addEventListener "mouseout", mouseOutCb, false

		clickListener build
