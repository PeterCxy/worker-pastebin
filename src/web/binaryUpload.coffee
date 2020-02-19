import React from "react"
import Dropzone from "react-dropzone"
import LinkButton from "./util/linkButton"
import * as crypto from "../crypto"
import * as util from "../util"

class BinaryUpload extends React.Component
  constructor: (props) ->
    super props
    @state =
      file: null
      uploading: false
      progress: 0
      encrypt: false
      encrypting: false

  onDrop: (files) =>
    @setState
      file: files[0]

  doUpload: =>
    key = null
    iv = null
    @setState
      uploading: true
      encrypting: @state.encrypt
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
          encrypting: false
          file: null
        @props.openDialog do =>
          if xhr.status == 200
            url = if not @state.encrypt
              xhr.responseText
            else
              xhr.responseText + "?crypt#" + key + "+" + iv
            <a href={url} target="_blank">
              https://{window.location.hostname}{url}
            </a>
          else
            xhr.responseText

    if not @state.encrypt
      xhr.open 'PUT', '/paste/' + @state.file.name
      xhr.send @state.file
    else
      [key, iv, name, mime, encrypted] = await crypto.encryptFile @state.file
      xhr.open 'PUT', '/paste/' + name
      xhr.setRequestHeader 'content-type', mime
      xhr.send encrypted
      @setState
        encrypting: false

  progressText: ->
    util.progressText @state.progress

  toggleEncrypt: =>
    @setState (state, props) ->
      { encrypt: not state.encrypt }

  render: ->
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
          onClick={@toggleEncrypt}
        >
          { "Encrypt: " + if @state.encrypt then "ON" else "OFF" }
        </button>
        <LinkButton
          className="button-blue"
          disabled={@state.uploading}
          to="/paste/text"
        >
          Text Mode
        </LinkButton>
        <button
          className="button-blue"
          disabled={@state.uploading or not @state.file}
          onClick={@doUpload}
        >
          {
            if not @state.uploading
              "Upload"
            else if @state.encrypting
              "Encrypting"
            else
              @progressText()
          }
        </button>
      </div>
    </div>

export default BinaryUpload