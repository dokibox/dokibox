items = {}
commitMap = {}
currentBranch = "master"
currentTime = new Date()
builds = $("#builds")
repo = "https://github.com/mileswu/dokibox/commit/"

$.get "https://s3.amazonaws.com/dokibox-builds/", (data) ->
	contents = $(data).find("Contents")
	for c in [contents.length-1..0] by -1
		content = $(contents[c])
		if content.find("Key").text()[-7..-1] is ".tar.gz"
			item = parseContents content
			unless items[item.file.branch]
				items[item.file.branch] = []
				commitMap[item.file.branch] = {}
			items[item.file.branch].push item
	items[currentBranch].sort (a, b) ->
		b.date.raw - a.date.raw
	for item, index in items[currentBranch]
		commitMap[currentBranch][item.file.commit] = index
		builds.append """
			<li class="branch-#{item.file.branch} entry">
					<div class="size">#{item.size}</div>
					<div class="info time" id="#{item.file.commit}">Built #{item.date.text}</div>
					<a href="#{repo}#{item.file.commit}">
						<div class="commit">
							<svg height="32" width="32" version="1.1" xmlns="http://www.w3.org/2000/svg">
								<path fill="#ccc" stroke="#000000" d="M15.999,0.748c-8.635,0-15.638,7.001-15.638,15.64c0,6.908,4.48,12.769,10.696,14.837c0.782,0.145,1.067-0.339,1.067-0.753c0-0.372-0.013-1.355-0.021-2.66c-4.349,0.944-5.267-2.097-5.267-2.097c-0.711-1.807-1.737-2.287-1.737-2.287c-1.42-0.97,0.107-0.952,0.107-0.952c1.57,0.112,2.396,1.612,2.396,1.612c1.395,2.39,3.659,1.699,4.551,1.3c0.142-1.011,0.545-1.7,0.993-2.091c-3.472-0.395-7.124-1.737-7.124-7.729c0-1.707,0.61-3.103,1.61-4.196c-0.161-0.396-0.698-1.985,0.152-4.139c0,0,1.313-0.42,4.301,1.604c1.248-0.348,2.585-0.521,3.915-0.527c1.328,0.006,2.666,0.18,3.915,0.527c2.985-2.024,4.296-1.604,4.296-1.604c0.853,2.153,0.316,3.743,0.155,4.139c1.002,1.093,1.608,2.489,1.608,4.196c0,6.007-3.657,7.33-7.141,7.716c0.562,0.483,1.062,1.438,1.062,2.896c0,2.09-0.019,3.777-0.019,4.29c0,0.418,0.281,0.906,1.075,0.751c6.208-2.072,10.686-7.93,10.686-14.835C31.638,7.749,24.636,0.748,15.999,0.748" stroke-width="0" stroke-opacity="1"></path>
							</svg>
						</div>
					</a>
					<a href="https://s3.amazonaws.com/dokibox-builds/#{item.file.full}">
						<div class="download">
							<svg height="32" width="32" version="1.1" xmlns="http://www.w3.org/2000/svg">
								<path fill="#ccc" stroke="#000000" d="M18.8,8.66L16,11.1L13.2,8.66L13.2,16.4L9.27,15.4L16,24.2L22.7,15.4L18.8,16.7Z" stroke-width="0" stroke-opacity="1"></path>
								<path fill="#ccc" stroke="#000000" d="M16,0.341C7.35,0.341,0.341,7.35,0.341,16C0.341,24.65,7.351,31.7,16.041,31.7S31.741,24.69,31.741,16C31.7,7.35,24.6,0.341,16,0.341ZM16,27.5C9.67,27.5,4.5,22.37,4.5,16C4.5,10.64,8.18,6.14,13.14,4.9L16,7.32L18.82,4.89C23.8,6.14,27.5,10.6,27.5,16C27.5,22.3,22.3,27.5,16,27.5Z" stroke-width="0" stroke-opacity="1"></path>
								<path fill="#ccc" stroke="#000000" d="M18.8,7.98L18.8,5.66L16,8.1L13.2,5.66L13.2,7.98L16,10.4Z" stroke-width="0" stroke-opacity="1"></path>
							</svg>
						</div>
					</a>
			</li>
		"""

parseContents = (contents) ->
	item = {
		file: parseFilename contents.find("Key").text()
		date: parseDate currentTime, new Date contents.find("LastModified").text()
		hash: contents.find("ETag").text()[1...-1].split('-')[0]
		size: humanizeSize contents.find("Size").text()
	}

parseFilename = (fullFileName) ->
	file = {
		full: fullFileName
	}
	# horrible monstrosities.
	[file.branch, file.commit] = fullFileName.match(/.+\/(.+?).tar.gz/)[1].match(/(.+)-(.+?$)/)[1..2]
	file

humanizeSize = (size) ->
	post = [' B', ' KiB', ' MiB', ' GiB', ' TiB', ' PiB', ' EiB', ' ZiB', ' YiB']
	dum = size
	count = 0
	while Math.floor dum # 0 == false
		dum /= 1024
		count++
	Math.round(size/(Math.pow(1024,(count-1)))*100)/100 + post[count-1]

niceFormatDate = (date) ->
	pad = (n) -> return  if n < 10 then "0"+n else n
	return "#{date.getFullYear()}-#{pad date.getMonth() + 1}-#{pad date.getDate()} at #{pad date.getHours()}:#{pad date.getMinutes()}"

parseDate = (now, date) ->
	return {
		alt: "on #{niceFormatDate date}"
		raw: date
		text: humanizeDate now, date
	}

humanizeDate = (now, date) ->
	pluralize = (quantity) -> if quantity is 1 then '' else 's'
	text = ""
	diff = Math.round (now - date)/1000
	if diff < 60 # less than one minute
		text = "less than a minute ago."
		return text

	diff = Math.round diff/60
	if diff < 60 # less than one hour
		text = "#{diff} minute#{pluralize diff} ago."
		return text

	minutes = diff % 60
	diff = Math.round diff/60
	if diff < 24 # less than one day
		m = if minutes > 0 then ", #{minutes} minute#{pluralize minutes}" else ""
		text = "#{diff} hour#{pluralize diff}#{m} ago."
		return text

	hours = diff % 24
	diff = Math.round diff/24
	if diff < 7 # less than a week
		h = if hours > 0 then ", #{hours} hour#{pluralize hours}" else ""
		text = "#{diff} day#{pluralize diff}#{h} ago."
		return text

	weeks = Math.round diff/7
	days = diff % 7
	if weeks < 5
		d = if days > 0 then ", #{days} day#{pluralize days}" else ""
		text = "#{weeks} week#{pluralize weeks}#{d} ago."
		return text
	else
		text = "on #{niceFormatDate date}"
		return text
