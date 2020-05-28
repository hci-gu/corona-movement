import React, { useState } from 'react'
import styled from 'styled-components'
import moment from 'moment'
import Select from 'react-select'
import Slider from 'rc-slider'
import 'rc-slider/assets/index.css'

import StepsChart from './StepsChart'

const Container = styled.div`
  margin: 0 auto;
  width: 80%;

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
  const [days, setDays] = useState(0)
  const [selectedOption, setSelectedOption] = useState(options[0])
  const fromDate = moment('2020-04-01').add(days, 'days').format('YYYY-MM-DD')

  return (
    <Container>
      <Title>Coronamovement</Title>
      <Select
        value={selectedOption}
        onChange={setSelectedOption}
        options={options}
      />
      <Title>{fromDate}</Title>
      <Slider min={-100} max={100} value={days} onChange={setDays} />
      <StepsChart
        title="Veckodagar"
        start={fromDate}
        option={selectedOption.value}
      />
      <StepsChart
        title="Helger"
        start={fromDate}
        option={selectedOption.value}
        weekDays={false}
      />
    </Container>
  )
}

export default User
