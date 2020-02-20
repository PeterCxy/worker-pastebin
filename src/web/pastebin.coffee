import React, { useState } from "react"
import * as hooks from "./hooks"
import HelpButton from "./helpButton"
import LinkButton from "./util/linkButton"
import ContentEditable from "./util/contentEditable"

export default Pastebin = ->
  [openDialog, renderDialog] = hooks.useDialog()
  [highlight, toggleHighlight] = hooks.useToggle false
  [text, setText] = useState ""
  [doPaste, pasting, _] = hooks.usePaste openDialog, null, (status) ->
    setText "" if status == 200

  onEditTextUpdate = (ev) ->
    setText ev.target.value

  paste = ->
    doPaste "web_paste.txt", "text/plain", text

  <div className="content-pastebin">
    {renderDialog()}
    <ContentEditable
      className="content-pastebin-edit"
      onUpdate={onEditTextUpdate}
      value={text}
      highlightCode={highlight}
      plainText
    />
    <div className="content-buttons">
      <HelpButton openDialog={openDialog} />
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