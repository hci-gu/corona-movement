import React from 'react'
import { BrowserRouter as Router, Switch, Route, Link } from 'react-router-dom'
import ReactDOM from 'react-dom'

import Landing from './components/Landing'
import User from './components/User'

ReactDOM.render(
  <React.StrictMode>
    <Router>
      <Switch>
        <Route path="/user/:userId">
          <User />
        </Route>
        <Route path="/">
          <Landing />
        </Route>
      </Switch>
    </Router>
  </React.StrictMode>,
  document.getElementById('root')
)
