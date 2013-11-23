updateTime = ->
	now = new Date()
	$(".info").each ->
		info = $(@)
		info.text "Built #{humanizeDate now, items[currentBranch][commitMap[currentBranch][info.attr("id")]].date.raw}"

$(document).ready ->
	window.setInterval updateTime, 60000
