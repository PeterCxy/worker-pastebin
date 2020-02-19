import React from "react"
import * as crypto from "../crypto"
import * as util from "../util"

class FileDecrypter extends React.Component
  constructor: (props) ->
    super props
    @originalUrl = "/paste/#{props.id}?original"
    # We simply let it fail if there's no key / iv provided in window.location.hash
    # also we don't care about decryption failure. Just let it look like a broken page
    # if someone tries to brute-force
    [key, iv] = window.location.hash.replace("#", "").split '+'
    @state =
      name: null
      mime: null
      length: null
      downloading: false
      decrypting: false
      progress: 0
      key: key
      iv: iv

  componentDidMount: ->
    # Fetch metadata to show to user
    # We can use fetch API here
    resp = await fetch @originalUrl
    # Fail silently as explained above
    return if not resp.ok
    mime = resp.headers.get 'content-type'
    [_, name] = resp.headers.get 'content-disposition'
                .split 'filename*='
    [name, mime] = await crypto.decryptMetadata @state.key, @state.iv, name, mime
    @setState
      name: name
      mime: mime
      length: parseInt resp.headers.get 'content-length'

  downloadFile: =>
    @setState
      downloading: true
      decrypting: false
      progress: 0
    # For progress, we have to use XHR
    xhr = new XMLHttpRequest()
    xhr.responseType = "arraybuffer"
    xhr.addEventListener 'progress', (e) =>
      if e.lengthComputable
        @setState
          progress: e.loaded / e.total
    xhr.addEventListener 'readystatechange', =>
      if xhr.readyState == XMLHttpRequest.DONE
        @setState
          downloading: false
        return if xhr.status != 200 # We always fail silently here
        @decryptFile xhr.response
    xhr.open 'GET', @originalUrl
    xhr.send()

  decryptFile: (file) =>
    @setState
      decrypting: true
    decrypted = await crypto.decryptFile @state.key, @state.iv, file
    util.browserSaveFile @state.mime, @state.name, decrypted
    @setState
      decrypting: false

  render: ->
    <div className="content-pastebin">{
      if not @state.name
        <p>Loading...</p>
      else
        <div className="content-file-info">
          <p>{@state.name}</p>
          <p>{@state.mime}</p>
          <p>{util.humanFileSize @state.length}</p>
          <button
            className="button-blue"
            disabled={@state.downloading}
            onClick={@downloadFile}
          >{
            if not @state.downloading
              "Download"
            else if @state.decrypting
              "Decrypting"
            else
              util.progressText @state.progress
          }</button>
        </div>
    }</div>

export default FileDecrypter