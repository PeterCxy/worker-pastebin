import React from "react"
import ReactDOM from "react-dom"
import hljs from "highlight.js"

# Wrapper for a content-editable div
# <https://stackoverflow.com/questions/22677931/react-js-onchange-event-for-contenteditable>
class ContentEditable extends React.Component
  constructor: (props) ->
    super props

  getText: ->
    console.log @domNode.innerHTML
    do =>
      if @props.plainText
        @domNode.innerText
      else
        @domNode.innerHTML
    .replace /\u200C/g, ''

  setText: (text) ->
    if @props.plainText
      @domNode.innerText = text
    else
      @domNode.innerHTML = text

  codeHighlight: ->
    if @props.plainText and @props.highlightCode
      @domNode.innerHTML = hljs.highlightAuto(@domNode.innerText).value

  componentDidMount: ->
    @domNode = ReactDOM.findDOMNode @

  componentWillUnmount: ->
    @domNode = null

  shouldComponentUpdate: (nextProps) ->
    nextProps.value != @getText() or
      nextProps.plainText != @props.plainText or
      nextProps.highlightCode != @props.highlightCode

  componentDidUpdate: ->
    #if @props.value != @getText()
    @setText @props.value
    # Note that we will only update when the value passed by parent
    # is different than what we know, i.e. the parent requested
    # a change in value
    @codeHighlight()

  emitUpdate: =>
    if @props.onUpdate
      # Note that the parent is expected to send the content back to us
      # via `@props.value`
      @props.onUpdate
        target:
          value: @getText()

  onBlur: =>
    @codeHighlight()
    @emitUpdate()

  onPaste: (ev) =>
    return false if not @props.plainText
    # <https://developer.mozilla.org/en-US/docs/Web/API/Element/paste_event>
    paste = (event.clipboardData || window.clipboardData).getData 'text'
    selection = window.getSelection()
    return false if not selection.rangeCount
    selection.deleteFromDocument()
    selection.getRangeAt 0
            .insertNode document.createTextNode paste
    @emitUpdate()
    ev.preventDefault()

  onKeyDown: (ev) =>
    if ev.keyCode == 13
      # Without U+200C, the new line will not work properly
      document.execCommand 'insertHTML', false, '<br>\u200C'
      ev.preventDefault()

  render: ->
    <div
      className={"#{@props.className} editable"}
      onInput={@emitUpdate}
      onBlur={@onBlur}
      onPaste={@onPaste}
      onKeyDown={@onKeyDown}
      spellCheck={false}
      contentEditable/>

export default ContentEditable