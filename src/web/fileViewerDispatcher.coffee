import React from "react"
import CodeViewer from "./codeViewer"
import FileDecrypter from "./fileDecrypter"

# Determine if we want to use CodeViewer or FileDecrypter
export default FileViewerDispatcher = (props) ->
  if props.location.search == "?crypt"
    <FileDecrypter id={props.match.params.id} />
  else
    <CodeViewer id={props.match.params.id} />