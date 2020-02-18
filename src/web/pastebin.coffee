import React from "react"
import ReactModal from "react-modal"
import ContentEditable from "./util/contentEditable"

class Pastebin extends React.Component
  constructor: (props) ->
    super props
    @state =
      text: ""
      pasting: false
      dialogMsg: null
      dialogOpen: false

  onEditTextUpdate: (ev) =>
    console.log ev.target.value
    @setState
      text: ev.target.value

  paste: =>
    return if @state.text.trim() == ""
    # Set the state first to disable the button
    @setState
      pasting: true
    # For things pasted through the web interface,
    # we always assume the name is `web_paste.txt`,
    # and the content type is always `text/plain`.
    resp = await fetch "/paste/web_paste.txt",
      method: 'PUT'
      headers:
        'content-type': 'text/plain'
      body: @state.text
    console.log resp
    txt = await resp.text()
    console.log txt
    if resp.ok
      msg =
        <a href={txt} target="_blank">
          https://{window.location.hostname}{txt}
        </a>
    else
      msg = txt

    @setState
      text: ""
      # Open dialog
      dialogOpen: true
      dialogMsg: msg

    # Reset the button
    @setState
      pasting: false

  render: ->
    <div className="content-pastebin">
      <ContentEditable
        className="content-pastebin-edit"
        onUpdate={@onEditTextUpdate}
        value={@state.text}
        highlightCode
        plainText
      />
      <div className="content-buttons">
        <button
          className="button-blue"
          disabled={@state.pasting}
          onClick={@paste}
        >
          Paste
        </button>
      </div>
      <ReactModal
        isOpen={@state.dialogOpen}
        className="ReactModal__Content_My"
        closeTimeoutMS={500}
      >
        <p>{@state.dialogMsg}</p>
        <div className="dialog-buttons">
          <button
            className="button-blue"
            onClick={(e) => @setState { dialogOpen: false }}
          >
            Close
          </button>
        </div>
      </ReactModal>
    </div>

export default Pastebin