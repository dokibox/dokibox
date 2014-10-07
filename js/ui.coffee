# updateTime = ->
# 	now = new Date()
# 	$(".info").each ->
# 		info = $(@)
# 		info.text "Built #{humanizeDate now, items[currentBranch][commitMap[currentBranch][info.attr("id")]].date.raw}"

# $(document).ready ->
# 	window.setInterval updateTime, 60000

listElement = document.querySelector "#builds"

dokiboxArtifacts = new window.ArtifactParser "https://s3.amazonaws.com/dokibox-builds/", "https://github.com/mileswu/dokibox/", ( ) ->
	@insertRange listElement, [0, 19]

dokiboxArtifacts.fetchListing( )

