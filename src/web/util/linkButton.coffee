import React from "react"
import { Redirect } from "react-router-dom"

# A replacement of react Link that uses a button
class LinkButton extends React.Component
  constructor: (props) ->
    super props
    @state =
      switch: false

  render: ->
    # We cannot just replace the button with a <Redirect/> when we switch
    # because it will cause visual breaks where the button disappears for
    # a short while before the actual switch happens.
    <React.Fragment>
      <button {...@props} onClick={(e) => @setState { switch: true }}/>
      {
        @state.switch and
          <Redirect {...@props} />
      }
    </React.Fragment>

export default LinkButton