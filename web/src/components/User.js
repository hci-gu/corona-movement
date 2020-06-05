import React from 'react'
import { useRecoilState, useRecoilValue } from 'recoil'
import styled from 'styled-components'
import moment from 'moment'
import Select from 'react-select'

import { useSteps } from '../hooks'
import {
  datePeriodOptions,
  datePeriodState,
  fetchDateForPeriod,
} from '../state'
import DaysSlider from './DaysSlider'
import BarChart from './BarChart'
import WeekdaySelect from './WeekdaySelect'
import StepsChart from './StepsChart'
import ScatterChart from './ScatterChart'

const Container = styled.div`
  margin: 0 auto;
  width: 90%;

  @media (max-width: 540px) {
    width: 95%;
  }
`

const Title = styled.h1`
  text-align: center;
`

const User = () => {
  const [selectedOption, setSelectedOption] = useRecoilState(datePeriodState)
  const from = useRecoilValue(fetchDateForPeriod)
  const to = moment().format('YYYY-MM-DD')
  useSteps(from, to)

  return (
    <Container>
      <Title>Coronamovement</Title>
      <Select
        value={selectedOption}
        onChange={setSelectedOption}
        options={datePeriodOptions}
      />
      <DaysSlider />
      <BarChart />
      <WeekdaySelect />
      <StepsChart />
      <ScatterChart />
    </Container>
  )
}

export default User
