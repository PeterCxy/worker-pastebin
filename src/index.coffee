import * as util from './util'
import _ from './prelude'
import S3 from './aws/s3'
import config from '../config.json'

s3 = new S3 config

main = ->
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
    files = await s3.listObjects
      prefix: path
    break if !files.Contents or files.Contents.length == 0
  
  path = path + "/" + file
  len = req.headers.get "content-length"

  # Upload the file to S3
  try
    await s3.putObject path, req.body, # Expiration should be configured on S3 side
      ContentType: req.headers.get "content-type"
      ContentLength: len
  catch err
    console.log err
    return buildInvalidResponse err

  # Simply return the path in body
  new Response "/paste/" + id,
    status: 200

handleGET = (req, file) ->
  path = util.idToPath file
  # Find the file first, because ID is only the path part
  # We still need the real file name
  files = await s3.listObjects
    prefix: path
  if !files.Contents or files.Contents.length == 0
    return new Response "Not Found",
      status: 404
  # The full path to the original file
  fullPath = files.Contents[0].Key[0]
  fileName = fullPath.split('/')[-1]

  # Build options and downlaod the file from origin
  options = {}
  # Handle range header
  if req.headers.has "range"
    options["range"] = req.headers.get "range"

  resp = await s3.getObject fullPath, options
  if not resp.ok
    return new Response "Something went wrong",
      status: resp.status

  # Build response headers
  headers =
    'content-length': resp.headers.get 'content-length'
    # TODO: handle text/* with a code viewer of some sort
    'content-type': resp.headers.get 'content-type'

  # Prevent executing random HTML / XML by treating all text as `text/plain`
  if headers['content-type'].startsWith 'text/'
    headers['content-type'] = 'text/plain'

  # Add content-disposition header to indicate file name
  inline = util.shouldShowInline headers['content-type']
  headers['content-disposition'] =
    (if inline then 'inline;' else 'attachment;') + ' filename=' + fileName

  # Handle ranged resposes
  if resp.headers.has 'content-range'
    headers['content-range'] = resp.headers.get 'content-range'

  new Response resp.body,
    status: resp.status
    headers: headers


export default main