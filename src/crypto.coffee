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

export {
  utf8Bytes,
  hex,
  HMAC_SHA256,
  SHA256
}