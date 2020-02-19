import React from "react"
import HelpButton from "./helpButton"
import LinkButton from "./util/linkButton"
import ContentEditable from "./util/contentEditable"

class Pastebin extends React.Component
  constructor: (props) ->
    super props
    @state =
      text: ""
      pasting: false
      highlight: false # Make this false by default to avoid blocking

  onEditTextUpdate: (ev) =>
    console.log ev.target.value
    @setState
      text: ev.target.value

  toggleHighlight: (ev) =>
    @setState (state, props) =>
      { highlight: not state.highlight }

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
        txt

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
        highlightCode={@state.highlight}
        plainText
      />
      <div className="content-buttons">
        <HelpButton openDialog={@props.openDialog} />
        <button
          className="button-blue"
          onClick={@toggleHighlight}
        >
          Highlight: {if @state.highlight then 'ON' else 'OFF'}
        </button>
        <LinkButton
          className="button-blue"
          disabled={@state.pasting}
          to="/paste/binary"
        >
          File Upload
        </LinkButton>
        <button
          className="button-blue"
          disabled={@state.pasting or @state.text.trim() is ""}
          onClick={@paste}
        >
          Paste
        </button>
      </div>
    </div>

export default Pastebin