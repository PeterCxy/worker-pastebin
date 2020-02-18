import * as crypto from '../crypto'

# Implement AWS signature authentication
class AwsAuth
  constructor: (url, conf) ->
    @url = new URL url
    @date = new Date()
    @conf = conf
    @region = conf.region

  # Setters
  setMethod: (method) ->
    @method = method.toUpperCase()
    @
  setQueryStringMap: (qsMap) ->
    @qsMap = qsMap
    @
  setHeaderMap: (headerMap) ->
    # headers MUST contain `x-amz-content-sha256: UNSIGNED-PAYLOAD`
    @headerMap =
      'host': @url.host
    for [key, val] in Object.entries headerMap
      key = key.toLowerCase()
      val = val.trim()
      if key == "content-type" || key.startsWith "x-amz-"
        @headerMap[key] = val
    if !@headerMap['x-amz-content-sha256']
      throw "Must contain sha256 header"
    @
  setRegion: (region) ->
    @region = region
    @
  setService: (service) ->
    @service = service # "s3"
    @

  # Signature calculation: <https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html>
  authorizedHeader: (origHeader) ->
    origHeader['x-amz-date'] = @timeStampISO8601()
    origHeader['authorization'] = await @authorizationHeader()
  
  authorizationHeader: ->
    "AWS4-HMAC-SHA256 " + 
      "Credential=" + @credential() + "," +
      "SignedHeaders=" + @signedHeaders() + "," +
      "Signature=" + await @calculateSignature()

  credential: ->
    @conf.accessKeyId + "/" + @scope()
  
  calculateSignature: ->
    crypto.hex await crypto.HMAC_SHA256 await @signingKey(), await @stringToSign()

  signingKey: ->
    accessKey = crypto.utf8Bytes "AWS4" + @conf.secretAccessKey
    dateKey = await crypto.HMAC_SHA256 accessKey, @timeStampYYYYMMDD()
    dateRegionKey = await crypto.HMAC_SHA256 dateKey, @region
    dateRegionServiceKey = await crypto.HMAC_SHA256 dateRegionKey, @service
    crypto.HMAC_SHA256 dateRegionServiceKey, "aws4_request"
  
  stringToSign: ->
    "AWS4-HMAC-SHA256" + "\n" +
      @timeStampISO8601() + "\n" +
      @scope() + "\n" + 
      await crypto.hex await crypto.SHA256 @canonicalRequest()

  scope: ->
    @timeStampYYYYMMDD() + "/" +
      @region + "/" + @service + "/aws4_request"

  canonicalRequest: ->
    @method + "\n" +
      @canonicalURI() + "\n" +
      @canonicalQueryString() + "\n" +
      @canonicalHeaders() + "\n" +
      @signedHeaders() + "\n" +
      @headerMap['x-amz-content-sha256']

  canonicalURI: ->
    # new URL already handles URI encoding for the pathname. No need to repeat here.
    @url.pathname

  canonicalQueryString: ->
    return "" if not @qsMap
    [...Object.entries @qsMap].sort()
      .map (pair) ->
        pair.map (x) -> encodeURIComponent x
            .join "="
      .join "&"

  canonicalHeaders: ->
    ([...Object.entries @headerMap].sort()
      .map (pair) ->
        pair.join ':'
      .join "\n") + "\n" # There's a trailing "\n"

  signedHeaders: ->
    [...Object.entries @headerMap].sort()
      .map (pair) -> pair[0]
      .join ";"

  pad: (num) ->
    if num < 10
      "0" + num
    else
      num

  timeStampISO8601: ->
    @timeStampYYYYMMDD() + "T" +
      @pad(@date.getUTCHours()) +
      @pad(@date.getUTCMinutes()) +
      @pad(@date.getUTCSeconds()) + "Z"

  timeStampYYYYMMDD: ->
    @date.getUTCFullYear() +
      @pad(@date.getUTCMonth() + 1) +
      @pad(@date.getUTCDate())

export default AwsAuth