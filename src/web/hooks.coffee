import React, { useState, useCallback, useEffect } from "react"
import ReactModal from "react-modal"

# Simple abstraction for a toggling state
export useToggle = (defVal) ->
  [state, setState] = useState defVal

  toggle = ->
    setState (prev) -> not prev

  [
    state,
    # toggle does not depend on reading any state
    useCallback(toggle, [])
  ]

# A hook to support opening dialogs from the code
# returns [openDialog, renderDialog]
# renderDialog should always be called somewhere
# when rending the page
export useDialog = ->
  [dialogOpen, setDialogOpen] = useState false
  [dialogMsg, setDialogMsg] = useState null

  openDialog = (msg) ->
    setDialogMsg msg
    setDialogOpen true

  renderDialog = ->
    <ReactModal
      isOpen={dialogOpen}
      className="ReactModal__Content_My"
      closeTimeoutMS={500}
    >
      <p>{dialogMsg}</p>
      <div className="dialog-buttons">
        <button
          className="button-blue"
          onClick={(e) -> setDialogOpen false}
        >
          Close
        </button>
      </div>
    </ReactModal>

  [
    # openDialog only *sets* state, and does not read
    useCallback(openDialog, []),
    # renderDialog basically depends on all state we have
    useCallback(renderDialog, [dialogOpen, dialogMsg])
  ]

# Handles shared file-uploading logic between text / binary pasting
export usePaste = (openDialog, callback) ->
  [pasting, setPasting] = useState false
  [progress, setProgress] = useState 0

  doPaste = (name, mime, content, transformUrl) ->
    # Unfortunately we have to all resort to using XHR here
    setProgress 0
    setPasting true

    # Build the XHR
    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener "progress", (e) ->
      if e.lengthComputable
        setProgress e.loaded / e.total
    xhr.addEventListener "readystatechange", ->
      if xhr.readyState == XMLHttpRequest.DONE
        setPasting false
        openDialog do ->
          if xhr.status == 200
            url = xhr.responseText
            url = transformUrl url if transformUrl
            <a href={url} target="_blank">
              https://{window.location.hostname}{url}
            </a>
          else
            xhr.responseText
        callback xhr.status, xhr.responseText if callback
    
    # Handle uploading
    xhr.open 'PUT', "/paste/" + name
    xhr.setRequestHeader "content-type", mime
    xhr.send content

  [
    # our paste only depends on *setting* states, no reading required
    # but all the callback it reads from its closure may change
    useCallback(doPaste, [openDialog, callback]),
    pasting,
    progress
  ]

# An effect that fetches the original pasted content,
# and then fires a callback that handles metadata and the response body
# it also stores the meta into a state and returns it every time
# this hook gets called, so callbacks are not necessary
# and if callback is not present, then the response body
# would simply be thrown away
export useFetchContent = (id, callback) ->
  [meta, setMeta] = useState null

  doFetch = ->
    resp = await fetch "/paste/#{id}?original"
    length = resp.headers.get 'content-length'
    mime = resp.headers.get 'content-type'
    [_, name] = resp.headers.get 'content-disposition'
                .split 'filename*='
    newMeta =
      name: name
      mime: mime
      length: length
    setMeta newMeta
    # We have to pass newMeta to callback because
    # the callback will not be aware of the meta update
    callback newMeta, resp if callback

  # Run the effect once on mount
  useEffect doFetch, []
  meta