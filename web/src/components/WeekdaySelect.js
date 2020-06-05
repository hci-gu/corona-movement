import React from 'react'
import { useRecoilState, useRecoilValue } from 'recoil'
import styled from 'styled-components'
import Select from 'react-select'

import { weekdayState, weekdayOptons } from '../state'

const Container = styled.div`
  margin: 30px auto;
  width: 400px;
`

const WeekdaySelect = () => {
  const [selectedOption, setSelectedOption] = useRecoilState(weekdayState)

  return (
    <Container>
      <Select
        value={selectedOption}
        onChange={setSelectedOption}
        options={weekdayOptons}
        styles={{
          control: (provided) => ({
            ...provided,
            fontSize: 24,
          }),
        }}
      />
    </Container>
  )
}

export default WeekdaySelect
