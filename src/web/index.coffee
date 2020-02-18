import React from "react"
import ReactDOM from "react-dom"
import "./styles/index.scss"
import "highlight.js/scss/github.scss"
import Home from "./home"

elem = document.createElement "div"
document.body.appendChild elem

ReactDOM.render <Home/>, elem