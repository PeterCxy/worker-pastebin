import React from "react"
import * as util from "../util"

class HelpButton extends React.Component
  constructor: (props) ->
    super props

  showHelp: =>
    @props.openDialog do =>
      <React.Fragment>
        <p><strong>Angry.Im Pastebin Service</strong><br/>
           Source code:&nbsp;
          <a target="_blank" href="https://github.com/PeterCxy/worker-pastebin">
            https://github.com/PeterCxy/worker-pastebin
          </a>
        </p>
        <p>
          This application is intended as a programming practice.
          There is <strong>absolutely no guarantee</strong> on its functionality, security and reliability.
        </p>
        <p>
          <strong>Maximum file size: {util.humanFileSize util.MAX_UPLOAD_SIZE}</strong>, all uploads are kept for <strong>{util.FILE_LIFETIME}</strong> only.
        </p>
        <p>
          File uploads with <strong>"Encryption: ON"</strong> are encrypted with <i>AES-128-GCM</i> before uploading to server.
          The encryption key and IV (<i>Initialization Vector</i>) are generated <strong>in your browser</strong> and not uploaded to server.<br/>
          They are appended to the final uploaded URL in the form of {"\"#<key>-<iv>\""} (as a <a target="_blank" href="https://en.wikipedia.org/wiki/Fragment_identifier"><i>Fragment Identifier</i></a>),&nbsp;
          so that they will <strong>not</strong> be sent to the server as part of the URL when you access the file later from your browser.
        </p>
        <p>
          The decryption will also be done entirely in your browser. Therefore, it is not supported to access encrypted files outside of a modern browser.
        </p>
      </React.Fragment>

  render: ->
    <button
      className="button-blue"
      onClick={@showHelp}
    >
      Help
    </button>

export default HelpButton