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

  @media (max-width: 1200px) {
    flex-direction: column;
  }
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

  > a > img {
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

const ScreenShots = styled.div`
  width: 350px;
  height: 700px;
  position: relative;
  > img {
    position: absolute;
    width: 100%;
  }
`

const Landing = () => {
  return (
    <Container>
      <Wrapper>
        <Title>
          <ScreenShots>
            <img src="/img/screenshot_intro.png"></img>
            <img
              src="/img/screenshot.png"
              style={{ width: '70%', left: '60%', top: 220 }}
            ></img>
          </ScreenShots>
        </Title>
        <AppstoreBadges>
          <h2>Get the app!</h2>
          <a
            href="https://docs.google.com/forms/d/e/1FAIpQLSdtU_cBdpUAdaLMvpHU5KeRU4fbNFgK1OigiJTZVt-OdwJCLw/viewform"
            target="_blank"
          >
            <img src="/img/google-play-badge.png"></img>
          </a>
          <a
            href="https://docs.google.com/forms/d/e/1FAIpQLSdtU_cBdpUAdaLMvpHU5KeRU4fbNFgK1OigiJTZVt-OdwJCLw/viewform"
            target="_blank"
          >
            <img src="/img/appstore-badge.png" style={{ marginTop: 10 }}></img>
          </a>
        </AppstoreBadges>
      </Wrapper>
      <GULogo>
        <img src="/img/gu_logo.jpg"></img>
      </GULogo>
    </Container>
  )
}

export default Landing
