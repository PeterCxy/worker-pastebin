import React, { useState, useCallback, useContext } from "react"
import * as hooks from "./hooks"
import HelpButton from "./helpButton"
import LinkButton from "./util/linkButton"
import ContentEditable from "./util/contentEditable"

export default Pastebin = ->
  [highlight, toggleHighlight] = hooks.useToggle false
  [text, setText] = useState ""

  # Paste hook and events
  clearText = (status) ->
    setText "" if status == 200
  [doPaste, pasting, _] = hooks.usePaste useCallback clearText, []

  onEditTextUpdate = (ev) ->
    setText ev.target.value
  # onEditTextUpdate depends on absolutely nothing for reading
  onEditTextUpdate = useCallback onEditTextUpdate, []

  paste = ->
    # We force a single file name and mime type on web-pasted content
    doPaste "web_paste.txt", "text/plain", text
  # Paste depends only on the actual text
  # and of course the function doPaste
  paste = useCallback paste, [text, doPaste]
  paste = hooks.useCheckSize text.length, paste

  <div className="content-pastebin">
    <ContentEditable
      className="content-pastebin-edit"
      onUpdate={onEditTextUpdate}
      value={text}
      highlightCode={highlight}
      plainText
    />
    <div className="content-buttons">
      <HelpButton />
      <button
        className="button-blue"
        onClick={toggleHighlight}
      >
        Highlight: {if highlight then 'ON' else 'OFF'}
      </button>
      <LinkButton
        className="button-blue"
        disabled={pasting}
        to="/paste/binary"
      >
        File Upload
      </LinkButton>
      <button
        className="button-blue"
        disabled={pasting or text.trim() is ""}
        onClick={paste}
      >
        Paste
      </button>
    </div>
  </div>