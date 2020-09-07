import React from 'react'
import styled from 'styled-components'

const Container = styled.div`
  margin: 0 auto;
  width: 75%;
  min-height: 100vh;

  @media (max-width: 640px) {
    width: 100%;
    padding: 1em;
  }
`

const Wrapper = styled.div`
  margin-top: 200px;
  display: flex;
  justify-content: space-evenly;

  @media (max-width: 1200px) {
    margin-top: 100px;
    flex-direction: column;
  }
`

const Title = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;

  > h1 {
    text-align: center;
    font-size: 64px;
    line-height: 64px;
    color: #131d29;
    margin-bottom: 0;
    letter-spacing: 1px;
  }
  h2 {
    margin: 0;
    font-weight: 100;
    text-align: center;
  }
  > p {
    text-align: justify;
    font-weight: 300;
    margin-top: 50px;
    width: 500px;
  }

  @media (max-width: 640px) {
    > p {
      width: 100%;
    }
  }
`

const AppstoreBadges = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;

  > span {
    font-weight: bold;
    font-size: 20px;
  }

  > a > img {
    width: 200px;
  }
`

const GULogo = styled.div`
  left: 0;
  bottom: 0;
  margin: 1rem;

  > img {
    width: 120px;
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

  @media (max-width: 640px) {
    margin: 0 auto;
    width: 50%;
    height: auto;
    display: flex;
    justify-items: center;

    > img {
      position: inherit;
    }

    > img:nth-of-type(2) {
      visibility: hidden;
    }
  }
`

const Footer = styled.div`
  width: 100%;
  display: flex;
  align-items: center;

  border-top: 1px solid black;

  > * {
  }
  > a {
    margin-left: 50px;
    color: black;
  }
`

const Landing = () => {
  return (
    <>
      <Container>
        <Wrapper>
          <Title>
            <h1>WFH movement</h1>
            <h2>Have your movement patterns changed?</h2>
            <p>
              Compare your movement patterns before and after working from home.
              <br></br>
              <br></br>
              Using this app you get a way to visualize steps data from sources
              such as Apple Health, Google fitness and Garmin to get an idea of
              how your movement patterns have changed after working from home.
            </p>
            <AppstoreBadges>
              <span>Get the app!</span>
              <a
                href="https://play.google.com/store/apps/details?id=com.wfhmovement.app"
                target="_blank"
                rel="noopener noreferrer"
              >
                <img
                  src="/img/google-play-badge.png"
                  alt="Google play button"
                ></img>
              </a>
              <a
                href="https://apps.apple.com/us/app/id1518224904"
                target="_blank"
                rel="noopener noreferrer"
              >
                <img
                  src="/img/appstore-badge.png"
                  alt="Appstore button"
                  style={{ marginTop: 10 }}
                ></img>
              </a>
            </AppstoreBadges>
          </Title>
          <ScreenShots>
            <img
              src="/img/screenshot_intro.png"
              alt="screenshot of app intro"
            ></img>
            <img
              alt="screenshot of app step details"
              src="/img/screenshot.png"
              style={{ width: '70%', left: '60%', top: 220 }}
            ></img>
          </ScreenShots>
        </Wrapper>
      </Container>
      <Footer>
        <GULogo>
          <img src="/img/gu_logo.jpg" alt="Gothenburg University logo"></img>
        </GULogo>
        <a href="/privacy">Privacy policy</a>
        <a href="mailto:sebastian.andreasson@ait.gu.se">Contact</a>
      </Footer>
    </>
  )
}

export default Landing
