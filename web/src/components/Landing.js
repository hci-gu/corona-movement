import React from 'react'
import styled from 'styled-components'

const Container = styled.div`
  margin: 0 auto;
  width: 75%;

  @media (max-width: 540px) {
    width: 95%;
  }
`

const Wrapper = styled.div`
  margin-top: 200px;
  display: flex;
  justify-content: space-evenly;
  align-items: center;
`

const Title = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  > h1 {
    text-align: center;
    font-size: 54px;
    color: #131d29;
    margin-bottom: 0;
    letter-spacing: 1px;
  }
  > p {
    width: 500px;
  }
`

const AppstoreBadges = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  > img {
    width: 200px;
  }
`

const GULogo = styled.div`
  position: fixed;
  left: 0;
  bottom: 0;
  margin: 1rem;

  > img {
    width: 200px;
  }
`

const Landing = () => {
  return (
    <Container>
      <Wrapper>
        <Title>
          <h1>My Corona movement</h1>
          <p>
            Löksås ipsum regn dag sitt enligt jäst vad vidsträckt, på kan räv
            rännil tre ser sitt, om helt blev samtidigt att sällan tiden. Mot
            både vemod sjö vidsträckt gamla bland är, sax färdväg blev
            ordningens händer det hav dag, söka ta björnbär sjö åker brunsås.
            Händer göras dag har göras mjuka och räv därmed tiden rännil, mot
            samtidigt brunsås genom det för inom bra omfångsrik denna se, del
            samtidigt som sorgliga det miljoner strand sax av.
          </p>
        </Title>
        <AppstoreBadges>
          <h2>Snart kommer en app!</h2>
          <img src="/img/google-play-badge.png"></img>
          <img src="/img/appstore-badge.png" style={{ marginTop: 10 }}></img>
        </AppstoreBadges>
      </Wrapper>
      <GULogo>
        <img src="/img/gu_logo.jpg"></img>
      </GULogo>
    </Container>
  )
}

export default Landing
