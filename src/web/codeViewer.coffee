import React from "react"
import hljs from "highlight.js"
import LinkButton from "./util/linkButton"

MAX_HIGHLIGHT_LENGTH = 10 * 1024 # 10 KiB

class CodeViewer extends React.Component
  constructor: (props) ->
    super props
    @state =
      code: "Loading..."
      highlight: true

  componentDidMount: ->
    resp = await fetch "/paste/#{@props.id}?original"
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
        <LinkButton
          className="button-blue"
          push
          to="/paste/text"
        >
          New Paste
        </LinkButton>
      </div>
    </div>

export default CodeViewer