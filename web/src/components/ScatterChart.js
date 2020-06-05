import React, { useEffect } from 'react'
import styled from 'styled-components'
import moment from 'moment'
import ReactTooltip from 'react-tooltip'
import { useRecoilValue } from 'recoil'
import { dayBreakdownSelector, maxStepsSelector } from '../state'

const Heading = styled.h2`
  text-align: center;
`

const Grid = styled.div`
  display: flex;
  flex-direction: column;
`

const Row = styled.div`
  margin-top: 5px;
  display: grid;
  grid-template-columns: 75px repeat(24, auto) 75px;
  grid-column-gap: 5px;

  > span {
    text-align: center;
    line-height: 20px;
    vertical-align: middle;
    font-size: 12px;
    border-bottom: 1px solid black;
  }
`

const Cell = styled.div`
  height: 20px;
`

const formatHour = (hour) =>
  moment().startOf('day').add(hour, 'hours').format('HH:mm')

const HourRow = () => (
  <Row>
    <div></div>
    {Array.from({ length: 24 }).map((_, i) => (
      <span key={`Hour_${i}`}>{formatHour(i)}</span>
    ))}
    <span>Antal steg</span>
  </Row>
)

const DateRow = ({ date, day, max }) => {
  return (
    <Row>
      <span
        style={{
          color: [0, 6].includes(day[0].weekday) ? '#69140E' : null,
        }}
      >
        {date}
      </span>
      {day.map((d, i) => (
        <Cell
          key={`Cell_${i}`}
          data-tip={`${date} ${formatHour(i)} - ${d.value}`}
          style={{
            border: `0.5px solid rgba(0, 243, 0, ${
              d.value ? Math.max(0.15, d.value / max) : 0.15
            })`,
            backgroundColor: `rgba(0, 243, 0, ${
              d.value ? Math.max(0.05, d.value / max) : 0
            })`,
          }}
        />
      ))}
      <span>
        {day
          .reduce((sum, { value }) => sum + (value ? value : 0), 0)
          .toLocaleString()}
      </span>
    </Row>
  )
}

const Chart = () => {
  const days = useRecoilValue(dayBreakdownSelector)
  const maxSteps = useRecoilValue(maxStepsSelector)

  useEffect(() => {
    ReactTooltip.rebuild()
  }, [days])

  return (
    <div>
      <Heading>Varje dag</Heading>
      <Grid>
        <HourRow />
        {Object.keys(days).map((key) => (
          <DateRow
            date={key}
            day={days[key]}
            max={maxSteps}
            key={`DateRow_${key}`}
          />
        ))}
        <HourRow />
      </Grid>
    </div>
  )
}

export default Chart
