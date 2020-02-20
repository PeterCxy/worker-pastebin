import React, { useState, useEffect, useCallback, useMemo } from "react"
import LinkButton from "./util/linkButton"
import * as hooks from "./hooks"
import * as crypto from "../crypto"
import * as util from "../util"

export default FileDecrypter = (props) ->
  [downloading, setDownloading] = useState false
  [decrypting, setDecrypting] = useState false
  [downloaded, setDownloaded] = useState null

  # Fetch credentials from location once
  fetchCredentials = ->
    [key, iv] = window.location.hash.replace("#", "").split '+'
    return
      key: key
      iv: iv
  credentials = useMemo fetchCredentials, []

  # Handle object URL revocation before unmount
  # (though this will be fired every time `downloaded` changes,
  #  but that only changes when we finish downloading, and
  #  also the registered clean-up will be run after the final unmount)
  # (it is necessary to bind to "downloaded" otherwise the closure
  #  will hold stale references)
  urlRevokeHandler = ->
    return ->
      URL.revokeObjectURL downloaded if downloaded
  useEffect urlRevokeHandler, [downloaded]

  # Fetch meta (only fetches on first mount; subsequent calls return the same state)
  origMeta = hooks.useFetchContent props.id

  # Create decrypted metadata
  decryptMeta = ->
    if (not origMeta) or (not credentials)
      return null
    else
      [name, mime] = await crypto.decryptMetadata credentials.key, credentials.iv,
                            origMeta.name, origMeta.mime
      return
        name: name
        mime: mime
        length: origMeta.length
  meta = hooks.useAsyncMemo null, decryptMeta, [origMeta, credentials]

  # Handle decryption
  decryptFile = (file) ->
    setDecrypting true
    decrypted = await crypto.decryptFile credentials.key, credentials.iv, file
    blob = new Blob [decrypted],
      type: meta.mime
    setDownloaded URL.createObjectURL blob
  decryptFile = useCallback decryptFile, [credentials, meta]

  # Handle file downloads
  # We don't need to share logic via hooks with CodeViewer
  # because this is a whole new fetch session that CodeViewer
  # never shares.
  [_, progress, beginXHR] = hooks.useXhrProgress()
  downloadFile = ->
    setDownloading true
    xhr = beginXHR()
    xhr.responseType = "arraybuffer"
    xhr.addEventListener 'readystatechange', =>
      if xhr.readyState == XMLHttpRequest.DONE
        if xhr.status == 200
          await decryptFile xhr.response
        setDownloading false
    xhr.open 'GET', "/paste/#{props.id}?original"
    xhr.send()
  downloadFile = useCallback downloadFile, [meta, decryptFile]

  <div className="content-pastebin">{
    if not meta
      <p>Loading...</p>
    else
      <div className="content-file-info">
        <p>{meta.name}</p>
        <p>{meta.mime}</p>
        <p>{util.humanFileSize meta.length}</p>
        {
          if not downloaded
            <button
              className="button-blue"
              disabled={downloading}
              onClick={downloadFile}
            >{
              if not downloading
                "Download"
              else if decrypting
                "Decrypting"
              else
                util.progressText progress
            }</button>
          else
            # Use an actual link here instead of triggering click
            # on a hidden link, because on some browsers it doesn't work
            <a
              className="button-blue"
              href={downloaded}
              download={meta.name}
            >
              Save File
            </a>
        }{
          # In-browser previewing for certain file types
          # we can't just use this for all because it cannot handle file name
          downloaded and util.shouldShowInline(meta.mime) and
            <a
              className="button-blue"
              href={downloaded}
              target="_blank"
            >
              Preview
            </a>
        }
        <br/>
        <LinkButton
          className="button-blue"
          push
          to="/paste/text"
        >
            Home
        </LinkButton>
      </div>
  }</div>