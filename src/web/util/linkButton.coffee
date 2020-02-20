import React, { useState } from "react"
import { Redirect } from "react-router-dom"

# A replacement of react Link that uses a button
export default LinkButton = (props) ->
  [jump, setJump] = useState false

  # We cannot just replace the button with a <Redirect/> when we switch
  # because it will cause visual breaks where the button disappears for
  # a short while before the actual switch happens.
  <React.Fragment>
    <button {...props} onClick={(e) => setJump true}/>
    {
      jump and
        <Redirect {...props} />
    }
  </React.Fragment>
