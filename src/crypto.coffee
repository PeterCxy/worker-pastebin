utf8Bytes = (str) ->
  new TextEncoder 'utf-8'
      .encode str

fromUtf8Bytes = (bytes) ->
  new TextDecoder 'utf-8'
      .decode bytes

hex = (buf) -> (Array::map.call new Uint8Array(buf),
  (x) => ('00' + x.toString 16).slice(-2)).join ''

fromHex = (str) ->
  new Uint8Array str.match(/.{1,2}/g).map (byte) => parseInt byte, 16

HMAC_SHA256_KEY = (buf) ->
  crypto.subtle.importKey 'raw', buf,
    { name: 'HMAC', hash: 'SHA-256' }, true, [ 'sign' ]

HMAC_SHA256 = (key, str) ->
  cryptoKey = await HMAC_SHA256_KEY key
  buf = utf8Bytes str
  await crypto.subtle.sign "HMAC", cryptoKey, buf

SHA256 = (str) ->
  crypto.subtle.digest "SHA-256", utf8Bytes str

# For client-side encryption of files,
# always use AES-128-GCM
# Encrypt a File object
# Returns hexed key, iv, encrypted file name and mime type, and the encrypted ArrayBuffer
encryptFile = (file) ->
  # Generate a key to use
  keyParams =
    name: 'AES-GCM'
    length: 128
  keyUsage = ['encrypt', 'decrypt']
  key = await crypto.subtle.generateKey keyParams, true, keyUsage
  # Generate IV and configure the cipher
  iv = crypto.getRandomValues new Uint8Array 16
  algoParams =
    name: 'AES-GCM'
    iv: iv
    tagLength: 128
  # Encrypt
  encrypted = await crypto.subtle.encrypt algoParams, key, await file.arrayBuffer()
  name = hex await crypto.subtle.encrypt algoParams, key, utf8Bytes file.name
  mime = 'binary/' + hex await crypto.subtle.encrypt algoParams, key, utf8Bytes file.type
  exportedKey = hex await crypto.subtle.exportKey 'raw', key
  [exportedKey, hex(iv), name, mime, encrypted]

importKeyAndIv = (key, iv) ->
  key = fromHex key
  iv = fromHex iv
  key = await crypto.subtle.importKey 'raw', key,
    { name: "AES-GCM" }, false, ['encrypt', 'decrypt']
  algoParams =
    name: 'AES-GCM'
    iv: iv
    tagLength: 128
  [key, algoParams]

# Decrypt the name and mime-type of an encrypted file
decryptMetadata = (key, iv, name, mime) ->
  [key, algoParams] = await importKeyAndIv key, iv
  name = fromUtf8Bytes await crypto.subtle.decrypt algoParams, key, fromHex name
  mime = fromHex mime.replace /^binary\//, ""
  mime = fromUtf8Bytes await crypto.subtle.decrypt algoParams, key, mime
  [name, mime]

# Decrypt an encrypted ArrayBuffer
decryptFile = (key, iv, file) ->
  [key, algoParams] = await importKeyAndIv key, iv
  await crypto.subtle.decrypt algoParams, key, file

export {
  utf8Bytes,
  hex,
  HMAC_SHA256,
  SHA256,
  encryptFile,
  decryptMetadata,
  decryptFile
}