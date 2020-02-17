import React from "react"
import ReactDOM from "react-dom"

elem = document.createElement "div"
document.body.appendChild elem

ReactDOM.render <div>
  <h1>Hello, world</h1>
</div>, elem