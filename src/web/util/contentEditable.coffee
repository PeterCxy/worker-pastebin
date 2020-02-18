import React from "react"
import ReactDOM from "react-dom"

# Wrapper for a content-editable div
# <https://stackoverflow.com/questions/22677931/react-js-onchange-event-for-contenteditable>
class ContentEditable extends React.Component
  constructor: (props) ->
    super props

  getText: ->
    if @props.plainText then @domNode.innerText else @domNode.innerHTML

  setText: (text) ->
    if @props.plainText
      @domNode.innerText = text
    else
      @domNode.innerHTML = text

  componentDidMount: ->
    @domNode = ReactDOM.findDOMNode @

  componentWillUnmount: ->
    @domNode = null

  shouldComponentUpdate: (nextProps) ->
    nextProps.value != @getText()

  componentDidUpdate: ->
    if @props.value != @getText()
      @setText @props.value

  emitUpdate: =>
    if @props.onUpdate
      # Note that the parent is expected to send the content back to us
      # via `@props.value`
      @props.onUpdate
        target:
          value: @getText()

  onPaste: (ev) =>
    return false if not @props.plainText
    # <https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event>
    paste = (event.clipboardData || window.clipboardData).getData 'text'
    selection = window.getSelection()
    return false if not selection.rangeCount
    selection.deleteFromDocument()
    selection.getRangeAt 0
            .insertNode document.createTextNode paste
    ev.preventDefault()

  render: ->
    <div
      className={"#{@props.className} editable"}
      onInput={@emitUpdate}
      onBlur={@emitUpdate}
      onPaste={@onPaste}
      spellCheck={false}
      contentEditable/>

export default ContentEditable