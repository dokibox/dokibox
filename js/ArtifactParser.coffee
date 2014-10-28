# repo = "https://github.com/mileswu/dokibox/commit/"

class ArtifactParser

	constructor: ( @artifactListUrl, @repositoryUrl ) ->
		# artifacts is a hash of arrays. Each key is a branch, and the
		# corresponding value is a sorted array of the builds in that
		# branch.
		@artifacts = { }

		# displayBranch is a string corresponding to the branch that will
		# have its builds displayed. By default, it is "master".
		@displayBranch = "master"
		@now = moment( )

	createElement: ( index, build ) ->
		# https://developer.mozilla.org/en-US/docs/Web/API/Element
		listItem = document.createElement 'li'
		listItem.className = "branch-#{build.file.branch} entry"
		listItem.id = index
		listItem.innerHTML = """
			<div class="size">#{build.size.nice}</div>
			<div class="info">#{build.date.text}</div>
			<a href="#{@repositoryUrl}commit/#{build.file.commit}">
				<div class="commit">
					<svg height="32" width="32" version="1.1" xmlns="http://www.w3.org/2000/svg">
						<path d="M15.999,0.748c-8.635,0-15.638,7.001-15.638,15.64c0,6.908,4.48,12.769,10.696,14.837c0.782,0.145,1.067-0.339,1.067-0.753c0-0.372-0.013-1.355-0.021-2.66c-4.349,0.944-5.267-2.097-5.267-2.097c-0.711-1.807-1.737-2.287-1.737-2.287c-1.42-0.97,0.107-0.952,0.107-0.952c1.57,0.112,2.396,1.612,2.396,1.612c1.395,2.39,3.659,1.699,4.551,1.3c0.142-1.011,0.545-1.7,0.993-2.091c-3.472-0.395-7.124-1.737-7.124-7.729c0-1.707,0.61-3.103,1.61-4.196c-0.161-0.396-0.698-1.985,0.152-4.139c0,0,1.313-0.42,4.301,1.604c1.248-0.348,2.585-0.521,3.915-0.527c1.328,0.006,2.666,0.18,3.915,0.527c2.985-2.024,4.296-1.604,4.296-1.604c0.853,2.153,0.316,3.743,0.155,4.139c1.002,1.093,1.608,2.489,1.608,4.196c0,6.007-3.657,7.33-7.141,7.716c0.562,0.483,1.062,1.438,1.062,2.896c0,2.09-0.019,3.777-0.019,4.29c0,0.418,0.281,0.906,1.075,0.751c6.208-2.072,10.686-7.93,10.686-14.835C31.638,7.749,24.636,0.748,15.999,0.748"></path>
					</svg>
				</div>
			</a>
			<a href="#{@artifactListUrl}#{build.file.full}">
				<div class="download">
					<svg height="32" width="32" version="1.1" xmlns="http://www.w3.org/2000/svg">
						<path d="M18.8,8.66L16,11.1L13.2,8.66L13.2,16.4L9.27,15.4L16,24.2L22.7,15.4L18.8,16.7Z"></path>
						<path d="M16,0.341C7.35,0.341,0.341,7.35,0.341,16C0.341,24.65,7.351,31.7,16.041,31.7S31.741,24.69,31.741,16C31.7,7.35,24.6,0.341,16,0.341ZM16,27.5C9.67,27.5,4.5,22.37,4.5,16C4.5,10.64,8.18,6.14,13.14,4.9L16,7.32L18.82,4.89C23.8,6.14,27.5,10.6,27.5,16C27.5,22.3,22.3,27.5,16,27.5Z"></path>
						<path d="M18.8,7.98L18.8,5.66L16,8.1L13.2,5.66L13.2,7.98L16,10.4Z"></path>
					</svg>
				</div>
			</a>
		"""

		listItem

	insertRange: ( element, [rangeStart, rangeEnd] ) ->
		fragment = document.createDocumentFragment( )

		for index in [rangeStart .. rangeEnd] by 1
			fragment.appendChild @createElement index, @artifacts[@displayBranch][index]

		element.appendChild fragment

	fetchListing: ( @parsingFinishedCallback ) ->
		@listRequest = new XMLHttpRequest( )
		@listRequest.open "get", @artifactListUrl
		@listRequest.onload = @parseRequest
		@listRequest.send( )

	parseRequest: =>
		builds = @listRequest.responseXML.getElementsByTagName "Contents"
		for buildIndex in [builds.length-1 .. 0] by -1
			buildXml = builds[buildIndex]
			build = @parseContents buildXml
			if build isnt null
				@artifacts[build.file.branch] ?= []
				@artifacts[build.file.branch].push build

		@artifacts[@displayBranch].sort ( a, b ) ->
			b.date.raw - a.date.raw

		@parsingFinishedCallback( )

	parseContents: ( buildXml ) ->
		name = buildXml.getElementsByTagName( "Key" )[0].textContent
		if name[-7..-1] isnt ".tar.gz"
			return null
		else
			return {
				file: @parseFile name
				date: @parseDate buildXml.getElementsByTagName( "LastModified" )[0].textContent
				hash: @parseHash buildXml.getElementsByTagName( "ETag" )[0].textContent[2 .. -2]
				size: @formatSize buildXml.getElementsByTagName( "Size" )[0].textContent
			}

	parseHash: ( hash ) ->
		{
			raw: hash
			text: "MD5: " + hash.toUpperCase( )
		}

	parseFile: ( fileName ) ->
		file = {
			full: fileName
		}
		# horrible monstrosities.
		[file.branch, file.commit] = fileName.match(/.+\/(.+?).tar.gz/)[1].match(/(.+)-(.+?$)/)[1..2]
		file.commitText = "Commit " + file.commit[0..9].toUpperCase( )
		file

	parseDate: ( dateString ) ->
		date = {
			raw: moment( dateString )
		}
		date.alt = date.raw.format( "[Built on] YYYY-MM-DD [at] HH:mm")
		if @now.diff( date.raw, 'months' ) > 3
			date.text = date.alt
		else
			date.text = 'Built ' + date.raw.fromNow( )

		date

	sizeSuffix: [' B', ' KiB', ' MiB', ' GiB', ' TiB', ' PiB', ' EiB', ' ZiB', ' YiB']
	formatSize: ( size ) ->
		dum = size
		count = 0
		while 0 < Math.floor dum
			dum /= 1024
			count++
		return {
			raw: size
			text: "#{size} Bytes"
			nice: Math.round(size/(Math.pow(1024,(count-1)))*100)/100 + @sizeSuffix[count-1]
		}

window.ArtifactParser = ArtifactParser
