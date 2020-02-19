import React from "react"
import CodeViewer from "./codeViewer"
import FileDecrypter from "./fileDecrypter"

class FileViewerDispatcher extends React.Component
  constructor: (props) ->
    super props

  render: ->
    if @props.location.search == "?crypt"
      <FileDecrypter id={@props.match.params.id} />
    else
      <CodeViewer id={@props.match.params.id} />

export default FileViewerDispatcher