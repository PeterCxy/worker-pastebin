import React from "react"
import Pastebin from "./pastebin"

class Home extends React.Component
  constructor: (props) ->
    super props

  render: ->
    <div className="content-wrapper">
      <div className="content">
        <Pastebin />
      </div>
    </div>

export default Home