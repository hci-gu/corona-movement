import React from 'react'
import { useRecoilState, useRecoilValue } from 'recoil'
import styled from 'styled-components'
import moment from 'moment'
import Slider from 'rc-slider'
import { Handle } from 'rc-slider'
import 'rc-slider/assets/index.css'

import { startDate, sliderState, datesSelector } from '../state'

const Container = styled.div`
  height: 80px;
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
`

const Row = styled.div`
  width: 100%;
  display: grid;
  grid-template-columns: repeat(2, 100px);
  justify-content: space-between;
`

const SliderHandleDate = styled.span`
  position: absolute;
  width: 120px;
  left: -40px;
  margin-top: -37px;

  background-color: 'red';
`

const DaysSlider = () => {
  const [days, setDays] = useRecoilState(sliderState)
  const [start, current, now] = useRecoilValue(datesSelector)

  const min = moment(start).diff(moment(startDate), 'days')
  const max = moment(now).diff(moment(startDate), 'days')
  return (
    <Container>
      <Row>
        <span>{start}</span>
        <span>{now}</span>
      </Row>
      <Slider
        min={min}
        max={max}
        value={days}
        onChange={setDays}
        handle={(props) => (
          <Handle {...props}>
            <SliderHandleDate>{current}</SliderHandleDate>
          </Handle>
        )}
        trackStyle={{ backgroundColor: '#9BF19B' }}
        railStyle={{ backgroundColor: '#0B500B' }}
      />
    </Container>
  )
}

export default DaysSlider
