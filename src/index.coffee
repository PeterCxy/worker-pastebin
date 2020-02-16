import * as util from './util'
import * as s3 from './s3'
import _ from './prelude'

main = ->
  s3.loadAWSConfig _

  addEventListener 'fetch', (event) =>
    event.respondWith handleRequest event

buildInvalidResponse = (msg) ->
  if not msg
    msg = "Invalid Request"
  new Response msg,
    status: 400

handleRequest = (event) ->
  # Validate file name first, since this is shared logic
  file = util.getFileName event.request.url
  if not file
    return buildInvalidResponse _

  # Handle PUT and GET separately
  if event.request.method == "PUT"
    handlePUT event.request, file
  else if event.request.method == "GET"
    handleGET event.request, file
  else
    buildInvalidResponse _

handlePUT = (req, file) ->
  if not util.validateLength req
    return buildInvalidResponse "Maximum upload size: " + util.MAX_UPLOAD_SIZE
  
  # Generate a valid ID first
  id = null
  path = null
  loop
    id = util.randomID _
    path = util.idToPath id
    files = await s3.listFiles path
    break if !files or files.length == 0
  
  path = path + "/" + file
  len = req.headers.get "content-length"

  # Upload the file to S3
  try
    await s3.uploadFile
      Key: path
      ContentType: req.headers.get "content-type"
      ContentLength: len
      Body: await util.readToBlob req.body
  catch err
    console.log err
    return buildInvalidResponse err

  # Simply return the path in body
  new Response "/paste/" + id,
    status: 200

handleGET = (req, file) ->
  new Response "Hello, Coffee! file: " + file,
    headers:
      "content-type": "text/plain"

export default main