utf8Bytes = (str) ->
  new TextEncoder 'utf-8'
      .encode str

hex = (buf) -> (Array.prototype.map.call new Uint8Array(buf),
  (x) => ('00' + x.toString 16).slice(-2)).join ''

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

export {
  utf8Bytes,
  hex,
  HMAC_SHA256,
  SHA256,
  encryptFile
}