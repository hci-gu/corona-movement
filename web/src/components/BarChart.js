import React from 'react'
import moment from 'moment'
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

import { dayTotalSelector, datesSelector, datePeriodState } from '../state'

const Container = styled.div`
  width: 100%;
  height: 100px;
`

const DaysBarChart = () => {
  const days = useRecoilValue(dayTotalSelector)
  const datePeriod = useRecoilValue(datePeriodState).value
  const [start, current, now] = useRecoilValue(datesSelector)
  const cmpDate =
    datePeriod === 'same-period-1-year'
      ? moment(now).subtract(1, 'year').format('YYYY-MM-DD')
      : current

  const colorForDate = ({ date }) => {
    if (date >= start && date < cmpDate) return '#9BF19B'
    else if (date >= current) return '#0B500B'
    return 'gray'
  }

  return (
    <Container>
      <ResponsiveContainer>
        <BarChart height={40} data={days}>
          <Bar dataKey="value">
            {days.map((entry, index) => (
              <Cell fill={colorForDate(entry)} key={`cell-${index}`} />
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
