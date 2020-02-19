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
    # Use <ins> as a dumb wrapper because it does not actually create
    # an element around our tags.
    # (the semantics of <ins> is "inserted content", but this seems
    #  to be the only sane solution here)
    # <https://stackoverflow.com/questions/14162035/how-to-wrap-arbitrary-html-with-a-wrapper-without-breaking-markup>
    <ins>
      <button {...@props} onClick={(e) => @setState { switch: true }}/>
      {
        @state.switch and
          <Redirect {...@props} />
      }
    </ins>

export default LinkButton