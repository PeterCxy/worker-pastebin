import React from "react"
import { Redirect } from "react-router-dom"
import Dropzone from "react-dropzone"

class BinaryUpload extends React.Component
  constructor: (props) ->
    super props
    @state =
      file: null
      uploading: false
      progress: 0
      switchToText: false

  onDrop: (files) =>
    @setState
      file: files[0]

  doUpload: =>
    @setState
      uploading: true
      progress: 0
    # Due to the lack of progress feature in current Fetch API
    # We have to use XHR for now. Dang.
    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener "progress", (e) =>
      if e.lengthComputable
        @setState
          progress: e.loaded / e.total
    xhr.addEventListener "readystatechange", =>
      if xhr.readyState == XMLHttpRequest.DONE
        @setState
          uploading: false
          file: null
        @props.openDialog do ->
          if xhr.status == 200
            <a href={xhr.responseText} target="_blank">
              https://{window.location.hostname}{xhr.responseText}
            </a>
          else
            xhr.responseText
    xhr.open 'PUT', '/paste/' + @state.file.name
    xhr.send @state.file

  progressText: ->
    txt = (@state.progress * 100).toFixed(2) + "%"
    if @state.progress < 0.1
      "0" + txt
    else
      txt

  render: ->
    if @state.switchToText
      return <Redirect to="/paste/text" />

    <div className="content-pastebin">
      <Dropzone onDrop={@onDrop}>
        {({getRootProps, getInputProps}) => 
          <section className="container">
            <div {...getRootProps({className: 'dropzone'})}>
              <input {...getInputProps()} />
              <p>Drag 'n' drop a file here to upload, or click to select</p>
            </div>
            <aside>
              <p>{
                if not @state.file
                  "No Selected File"
                else
                  "Selected File: #{@state.file.name}"
              }</p>
            </aside>
          </section>
        }
      </Dropzone>
      <div className="content-buttons">
        <button
          className="button-blue"
          disabled={@state.uploading}
          onClick={(ev) => @setState { switchToText: true }}
        >
          Text Mode
        </button>
        <button
          className="button-blue"
          disabled={@state.uploading or not @state.file}
          onClick={@doUpload}
        >
          {
            if not @state.uploading
              "Upload"
            else
              @progressText()
          }
        </button>
      </div>
    </div>

export default BinaryUpload