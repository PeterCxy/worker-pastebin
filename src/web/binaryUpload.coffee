import React, { useState, useCallback } from "react"
import { useDropzone } from "react-dropzone"
import HelpButton from "./helpButton"
import LinkButton from "./util/linkButton"
import * as hooks from "./hooks"
import * as crypto from "../crypto"
import * as util from "../util"

export default BinaryUpload = ->
  [encrypt, toggleEncrypt] = hooks.useToggle false
  [encrypting, setEncrypting] = useState false
  [file, setFile] = useState null

  # Paste hook and event
  clearFile = (status) ->
    setFile null if status == 200
  [doPaste, pasting, progress] = hooks.usePaste useCallback clearFile, []

  # Dropzone hook and event
  onDrop = (files) ->
    setFile files[0]
  {getRootProps, getInputProps, isDragActive} = useDropzone
    onDrop: useCallback onDrop, []

  # Upload handler, we basically extend the Paste hook with encryption
  doUpload = ->
    if not encrypt
      doPaste file.name, file.type, file
    else
      # Handle encryption
      setEncrypting true
      [key, iv, name, mime, encrypted] = await crypto.encryptFile file
      setEncrypting false
      doPaste name, mime, encrypted, (url) ->
        url + "?crypt#" + key + "+" + iv
  doUpload = useCallback doUpload, [file, encrypt, doPaste]
  doUpload = hooks.useCheckSize file?.size, doUpload

  <div className="content-pastebin">
    <section className="container">
      <div {...getRootProps({className: 'dropzone'})}>
        <input {...getInputProps()} />
        <p>Drag 'n' drop a file here to upload, or click to select</p>
      </div>
      <aside>
        <p>{
          if not file
            "No Selected File"
          else
            "Selected File: #{file.name}"
        }</p>
      </aside>
    </section>
    <div className="content-buttons">
      <HelpButton />
      <button
        className="button-blue"
        disabled={pasting}
        onClick={toggleEncrypt}
      >
        { "Encrypt: " + if encrypt then "ON" else "OFF" }
      </button>
      <LinkButton
        className="button-blue"
        disabled={pasting}
        to="/paste/text"
      >
        Text Mode
      </LinkButton>
      <button
        className="button-blue"
        disabled={pasting or not file}
        onClick={doUpload}
      >
        {
          if encrypting
            "Encrypting"
          else if not pasting
            "Upload"
          else
            util.progressText progress
        }
      </button>
    </div>
  </div>