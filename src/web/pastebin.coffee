import React from "react"
import ContentEditable from "./util/contentEditable"

class Pastebin extends React.Component
  constructor: (props) ->
    super props
    @state =
      text: ""

  onEditTextUpdate: (ev) =>
    console.log ev.target.value
    @setState
      text: ev.target.value

  render: ->
    <div className="content-pastebin">
      <ContentEditable
        className="content-pastebin-edit"
        onUpdate={@onEditTextUpdate}
        value={@state.text}
        plainText/>
    </div>

export default Pastebin