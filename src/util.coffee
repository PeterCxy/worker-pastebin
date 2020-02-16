# Maimum upload size (in bytes)
MAX_UPLOAD_SIZE = 10 * 1024 * 1024 # 10 MB

# Validate content-length header
validateLength = (req) ->
  (Number.parseInt req.headers.get "content-length") <= MAX_UPLOAD_SIZE

# Only accept paths like `/paste/:file_name`
# No further slahses are supported
getFileName = (url) ->
  url = new URL url
  if url.pathname[0] isnt '/'
    return null
  parts = url.pathname.split '/'
  if parts.length isnt 3
    return null
  if parts[1] isnt 'paste'
    return null
  return parts[2]

# Generate random file ID
DICTIONARY = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
ID_LENGTH = 6

randomID = ->
  [0..ID_LENGTH].map =>
    DICTIONARY[Math.floor Math.random() * DICTIONARY.length]
  .join ''

# Convert a random ID into file path
idToPath = (id) ->
  id.split ''
    .join '/'

# Convert a ReadableStream into Blob
# AWS-SDK does not support ReadableStream, unfortunately
readToBlob = (stream) ->
  reader = stream.getReader()
  ret = []
  loop
    { done, value } = await reader.read()
    break if done
    ret.push value
  new Blob ret

export {
  getFileName,
  validateLength,
  MAX_UPLOAD_SIZE,
  randomID,
  idToPath,
  readToBlob
}