import React, { useState } from "react"
import hljs from "highlight.js"
import * as hooks from "./hooks"
import LinkButton from "./util/linkButton"

MAX_HIGHLIGHT_LENGTH = 10 * 1024 # 10 KiB

export default CodeViewer = (props) ->
  [code, setCode] = useState "Loading..."
  [highlight, setHighlight] = useState true

  # Fetch the content on first mount (and after first render)
  hooks.useFetchContent props.id, (meta, resp) ->
    resp = await resp.text()
    if meta.length < MAX_HIGHLIGHT_LENGTH
      setCode hljs.highlightAuto(resp).value
    else
      setHighlight false
      setCode resp

  <div className="content-pastebin">
    <div
      className="content-code-viewer"
    >
      {
        if highlight
          <pre
            dangerouslySetInnerHTML={{__html: code}}
          />
        else
          <pre>{code}</pre>
      }
    </div>
    <div className="content-buttons">
      <LinkButton
        className="button-blue"
        push
        to="/paste/text"
      >
        New Paste
      </LinkButton>
    </div>
  </div>