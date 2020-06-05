import React from 'react'
import { RecoilRoot } from 'recoil'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'
import ReactDOM from 'react-dom'
import ReactTooltip from 'react-tooltip'

import Landing from './components/Landing'
import PrivacyPolicy from './components/PrivacyPolicy'
import User from './components/User'

ReactDOM.render(
  <React.StrictMode>
    <RecoilRoot>
      <Router>
        <Switch>
          <Route path="/user/:userId">
            <User />
            <ReactTooltip place="bottom" type="dark" effect="float" />
          </Route>
          <Route path="/privacy">
            <PrivacyPolicy />
          </Route>
          <Route path="/">
            <Landing />
          </Route>
        </Switch>
      </Router>
    </RecoilRoot>
  </React.StrictMode>,
  document.getElementById('root')
)
