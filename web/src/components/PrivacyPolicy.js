import React from 'react'
import styled from 'styled-components'

const Container = styled.div`
  width: 50%;
  min-width: 600px;
  margin: 50px auto;
`

export default () => {
  return (
    <Container>
      <p>
        <h1>Privacy policy</h1>
        My Corona movement (MCM) is duty-bound to protect your integrity. This
        document describes what information MCM collects via its website/app and
        how it uses the information collected. This privacy policy applies to
        MCM's website and app.
        <br></br>
        <h1>Personal data</h1>
        The term ‘personal data’ refers to any information relating to an
        identified or identifiable natural person. MCM treats all personal data
        according to the General Data Protection Regulation (GDPR).
        <br></br>
        <br></br>
        Personal data that MCM collects include, but are not necessarily limited
        to, name, e-mail address, activity data ( tracked steps ). MCM collects
        personal data with the aim of facilitating communication with you as a
        user and provide . MCM collects personal data in the following
        scenarios:
        <br></br>- When you, as a user, choose to create a user account through
        MCM’s app and provide information about yourself.
        <br></br>- When you, as a user, choose to contact MCM through one of our
        web contact forms.
        <br></br>
        <br></br>
        You are welcome to contact us about the personal data that MCM holds
        about you (sebastian.andreasson@ait.gu.se). We strive to ensure that all
        personal data kept by MCM are correct and up to date.
      </p>
    </Container>
  )
}
