http = require 'http'
qs   = require 'querystring'

twilio = require 'twilio'
xmpp   = require 'simple-xmpp'


xmpp.on 'online', ->
  console.log 'XMPP client is online'

xmpp.on 'error', (err) ->
  console.log "XMPP Error: #{err}"


validateRequest = (request, params) ->
  # Todo: actually validate things
  return true


server = http.createServer (request, response) ->
  postBody = ''
  request.on 'data', (chunk) ->
    postBody += chunk.toString()

  request.on 'end', ->
    postData = qs.parse postBody
    unless postData.Body and validateRequest(request, postData)
      console.log 'Invalid request', request.headers, postData
      response.write 'Nothing here'
      return response.end()

    console.log "Queing message to be sent: #{postData.Body}"
    xmpp.probe process.env.REDUCTIVE_MY_JID, ->
      console.log "Sending: #{postData.Body}"
      xmpp.send process.env.REDUCTIVE_MY_JID, postData.Body

  response.write 'Hello World'
  response.end()

server.listen 1337

xmpp.connect
  jid: process.env.REDUCTIVE_JID
  password: process.env.REDUCTIVE_PASS
  host: 'talk.google.com'
  port: 5222
