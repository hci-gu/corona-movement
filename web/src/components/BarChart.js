import React from 'react'
import { useRecoilValue } from 'recoil'
import styled from 'styled-components'
import {
  BarChart,
  Bar,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
} from 'recharts'

import { dayTotalSelector, datesSelector } from '../state'

const Container = styled.div`
  width: 100%;
  height: 100px;
`

const DaysBarChart = ({ title, start, option, weekDays = true }) => {
  const days = useRecoilValue(dayTotalSelector)
  const [_, currentDate] = useRecoilValue(datesSelector)

  return (
    <Container>
      <ResponsiveContainer>
        <BarChart height={40} data={days}>
          <Bar dataKey="value">
            {days.map((entry, index) => (
              <Cell
                fill={entry.date >= currentDate ? '#0B500B' : '#9BF19B'}
                key={`cell-${index}`}
              />
            ))}
          </Bar>
          <XAxis dataKey="date" />
          <Tooltip />
        </BarChart>
      </ResponsiveContainer>
    </Container>
  )
}

export default DaysBarChart
