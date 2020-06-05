import React, { useState } from 'react'
import styled from 'styled-components'
import moment from 'moment'
import Select from 'react-select'

import { useSteps } from '../hooks'
import { fetchFrom } from '../state'
import DaysSlider from './DaysSlider'
import BarChart from './BarChart'
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

const options = [
  { value: '3-months-back', label: 'Jämför med 3 månader tillbaka' },
  { value: 'same-period-1-year', label: 'Jämför med samma period förra året' },
  { value: 'all-historic-data', label: 'Jämför med all historisk data' },
]

const User = () => {
  const [selectedOption, setSelectedOption] = useState(options[0])
  const fromDate = fetchFrom()
  const to = moment().format('YYYY-MM-DD')
  useSteps(fromDate, to)

  return (
    <Container>
      <Title>Coronamovement</Title>
      <Select
        value={selectedOption}
        onChange={setSelectedOption}
        options={options}
      />
      <DaysSlider />
      <BarChart />
      <StepsChart
        title="Veckodagar"
        start={fromDate}
        option={selectedOption.value}
      />
      {/* <StepsChart
        title="Helger"
        start={fromDate}
        option={selectedOption.value}
        weekDays={false}
      /> */}
      <ScatterChart />
    </Container>
  )
}

export default User
