import React from "react"
import { BrowserRouter as Router, Route, Switch, Redirect } from "react-router-dom"
import { AnimatedSwitch, spring } from 'react-router-transition'
import ReactModal from "react-modal"
import Pastebin from "./pastebin"
import BinaryUpload from "./binaryUpload"
import FileViewerDispatcher from "./fileViewerDispatcher"

bounce = (val) ->
  spring val,
    stiffness: 330
    damping: 22

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
        <Router>
          <AnimatedSwitch
            atEnter={{ opacity: 0, translateY: -5 }}
            atLeave={{ opacity: bounce(0), translateY: bounce(-5) }}
            atActive={{ opacity: bounce(1), translateY: bounce(0) }}
            mapStyles={(styles) ->
              opacity: styles.opacity
              transform: "translateY(#{styles.translateY}%)"
            }
            className="switch-wrapper"
          >
            <Redirect exact from="/" to="/paste/text" />
            {
              # Use `render` instead of `component` to prevent re-rendering the child
              # when parent is re-rendered (however this prevents passing match props)
            }
            <Route
              exact path="/paste/text"
              render={() => <Pastebin openDialog={@openDialog}/>}
            />
            <Route
              exact path="/paste/binary"
              render={() => <BinaryUpload openDialog={@openDialog}/>}
            />
            <Route
              path="/paste/:id"
              component={FileViewerDispatcher}
            />
          </AnimatedSwitch>
        </Router>
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