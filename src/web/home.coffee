import React from "react"
import ReactModal from "react-modal"
import Pastebin from "./pastebin"

class Home extends React.Component
  constructor: (props) ->
    super props
    @state =
      dialogOpen: false
      dialogMsg: null

  openDialog: (msg) =>
    @setState
      dialogOpen: true
      dialogMsg: msg

  render: ->
    <div className="content-wrapper">
      <div className="content">
        <Pastebin openDialog={@openDialog}/>
      </div>
      {
        # Provide modal dialog for all child
        # passed through the openDialog prop
      }
      <ReactModal
        isOpen={@state.dialogOpen}
        className="ReactModal__Content_My"
        closeTimeoutMS={500}
      >
        <p>{@state.dialogMsg}</p>
        <div className="dialog-buttons">
          <button
            className="button-blue"
            onClick={(e) => @setState { dialogOpen: false }}
          >
            Close
          </button>
        </div>
      </ReactModal>
    </div>

export default Home