import AwsAuth from "./auth"
import { parseStringPromise as parseXML } from "xml2js"

class S3
  constructor: (@conf) ->
    @baseURL = @conf.s3.endpoint + "/" + @conf.s3.bucket + "/"

  # Wrapper of Fetch API with automatic AWS signature
  # Note that query string in url is not supported
  # options.method must be specified
  request: (url, qsMap, options) ->
    # We only support unsigned payload for now
    options.headers['x-amz-content-sha256'] = 'UNSIGNED-PAYLOAD'

    # Sign the request
    auth = new AwsAuth url, @conf.aws
      .setMethod options.method
      .setQueryStringMap qsMap
      .setHeaderMap options.headers
      .setService "s3"

    # Write needed authorization headers to header object
    await auth.authorizedHeader options.headers
    fetch url + "?" + auth.canonicalQueryString(), options

  # Used for some requests to convert params to snake-cased x-amz-*
  camelToSnake: (str) ->
    str.replace /([A-Z])/g, "-$1"
      .toLowerCase()[1..]

  makeHeaders: (params) -> Object.fromEntries do =>
    Object.entries params
      .map ([key, val]) =>
        key = @camelToSnake key
        if not (key == "expires" or key.startsWith "content-" or key.startsWith "cache-")
          key = 'x-amz-' + key
        [key, val]

  # See AWS docs for params
  # params are passed in query string
  # Paging not implemented yet; Need to 
  listObjects: (params) ->
    # Send request using params as query string
    resp = await @request @baseURL, params,
      method: "GET"
      headers:
        'x-amz-request-payer': 'requester'
    txt = await resp.text()
    console.log txt
    if not resp.ok
      # no error handling yet
      throw txt
    result = await parseXML txt
    if not result.ListBucketResult
      return null
    result.ListBucketResult

  # params are in CamelCase, but converted to x-amz-* headers automatically
  # Content* headers are exempt from the x-amz-* prefix, as well as Expires
  # data can be a buffer or a readable stream
  putObject: (key, data, params) ->
    # Convert camel-cased params to snake-cased headers
    headers = @makeHeaders params
    
    # Send request
    resp = await @request @baseURL + key, null,
      method: 'PUT'
      headers: headers
      body: data

    txt = await resp.text()
    console.log txt
    if not resp.ok
      # no error handling yet
      throw resp.status
    else
      txt

  # params are processed similar to putObject
  # returns the full response object (because content-range may be needed)
  getObject: (key, params) ->
    @request @baseURL + key, null,
      method: 'GET'
      headers: @makeHeaders params

export default S3