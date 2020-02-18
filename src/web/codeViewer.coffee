import React from "react"
import { Redirect } from "react-router-dom"
import hljs from "highlight.js"

MAX_HIGHLIGHT_LENGTH = 10 * 1024 # 10 KiB

class CodeViewer extends React.Component
  constructor: (props) ->
    super props
    @state =
      code: "Loading..."
      switchToHome: false
      highlight: true

  componentDidMount: ->
    resp = await fetch "/paste/#{@props.match.params.id}?original"
    resp = await resp.text()
    if resp.length < MAX_HIGHLIGHT_LENGTH
      resp = hljs.highlightAuto(resp).value
    else
      @setState
        highlight: false

    @setState
      code: resp

  render: ->
    if @state.switchToHome
      return <Redirect push to="/paste/text" />

    <div className="content-pastebin">
      <div
        className="content-code-viewer"
      >
        {
          if @state.highlight
            <pre
              dangerouslySetInnerHTML={{__html: @state.code}}
            />
          else
            <pre>{@state.code}</pre>
        }
      </div>
      <div className="content-buttons">
        <button
          className="button-blue"
          onClick={(ev) => @setState { switchToHome: true }}
        >
          New Paste
        </button>
      </div>
    </div>

export default CodeViewer