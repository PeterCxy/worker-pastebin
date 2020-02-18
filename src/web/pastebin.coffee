import React from "react"
import ContentEditable from "./util/contentEditable"

class Pastebin extends React.Component
  constructor: (props) ->
    super props
    @state =
      text: ""
      pasting: false

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

    # Dialog opening is provided by parent
    @props.openDialog do ->
      if resp.ok
        <a href={txt} target="_blank">
          https://{window.location.hostname}{txt}
        </a>
      else
        msg = txt

    @setState
      text: ""

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
    </div>

export default Pastebin