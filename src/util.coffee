import { detect as detectBrowser } from 'detect-browser'

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

# Determine if we show something inline or not
shouldShowInline = (mime) ->
  isText(mime) or
    mime.startsWith('image/') or
    mime.startsWith('audio/') or
    mime.startsWith('video/')

isText = (mime) ->
  mime.startsWith('text/') or
    mime == 'application/json' or
    mime == 'application/javascript'

# Determine if we consider the user a browser or not
isBrowser = (req) ->
  b = detectBrowser req.headers.get 'user-agent'
  b and (b.name != 'searchbot')

# Process progress text
progressText = (progress) ->
  txt = (progress * 100).toFixed(2) + "%"
  if progress < 0.1
    "0" + txt
  else
    txt

# Convert a file size to human-readable form
# <https://stackoverflow.com/questions/10420352/converting-file-size-in-bytes-to-human-readable-string>
humanFileSize = (bytes, si) ->
  thresh = if si then 1000 else 1024
  if Math.abs bytes < thresh
    bytes + " B"
  else
    units = do ->
      if si
        ['kB','MB','GB','TB','PB','EB','ZB','YB']
      else
        ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB']
    u = -1
    loop
      bytes /= thresh
      ++u
      break if not (Math.abs(bytes) >= thresh and u < units.length - 1)
    bytes.toFixed(1) + ' ' + units[u]

export {
  getFileName,
  validateLength,
  MAX_UPLOAD_SIZE,
  randomID,
  idToPath,
  shouldShowInline,
  isBrowser,
  isText,
  progressText,
  humanFileSize
}