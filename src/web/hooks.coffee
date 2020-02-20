import React, { useState } from "react"
import ReactModal from "react-modal"

# A hook to support opening dialogs from the code
# returns [openDialog, renderDialog]
# renderDialog should always be called somewhere
# when rending the page
export useDialog = ->
  [dialogOpen, setDialogOpen] = useState false
  [dialogMsg, setDialogMsg] = useState null

  openDialog = (msg) ->
    setDialogMsg msg
    setDialogOpen true

  renderDialog = ->
    <ReactModal
      isOpen={dialogOpen}
      className="ReactModal__Content_My"
      closeTimeoutMS={500}
    >
      <p>{dialogMsg}</p>
      <div className="dialog-buttons">
        <button
          className="button-blue"
          onClick={(e) -> setDialogOpen false}
        >
          Close
        </button>
      </div>
    </ReactModal>

  [openDialog, renderDialog]
