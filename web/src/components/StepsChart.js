import React from 'react'
import styled from 'styled-components'
import moment from 'moment'
import {
  LineChart,
  Line,
  Legend,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
} from 'recharts'
import { useSteps } from '../hooks'

const Heading = styled.h2`
  text-align: center;
`

const formatKey = (value) =>
  moment().startOf('day').add(value, 'hours').format('HH:mm')

const datesForOption = (option, start) => {
  switch (option) {
    case '3-months-back':
      return [
        moment(start).subtract(3, 'months').format('YYYY-MM-DDTHH:MM'),
        moment(start).format('YYYY-MM-DDTHH:MM'),
      ]
    case 'same-period-1-year':
      return [
        moment(start).subtract(1, 'years').format('YYYY-MM-DDTHH:MM'),
        moment().subtract(1, 'years').format('YYYY-MM-DDTHH:MM'),
      ]
    case 'all-historic-data':
      return [
        moment('2018-01-01').format('YYYY-MM-DDTHH:MM'),
        moment(start).format('YYYY-MM-DDTHH:MM'),
      ]
    default:
      return []
  }
}

const StepsChart = ({ title, start, option, weekDays = true }) => {
  // compare with 3 months back
  const preCoronaDates = datesForOption(option, start)
  const preCoronaSteps = useSteps(
    preCoronaDates[0],
    preCoronaDates[1],
    weekDays
  )
  const postCoronaSteps = useSteps(
    moment(start).format('YYYY-MM-DDTHH:MM'),
    moment().format('YYYY-MM-DDTHH:MM'),
    weekDays
  )

  if (!preCoronaSteps.length || !postCoronaSteps.length)
    return <span>loading...</span>

  const steps = preCoronaSteps.map((v, i) => {
    return {
      key: v.key,
      preCorona: v.value,
      postCorona: postCoronaSteps[i].value,
    }
  })

  const preNumSteps = preCoronaSteps.reduce(
    (acc, curr) => acc + Math.round(curr.value),
    0
  )
  const postNumSteps = postCoronaSteps.reduce(
    (acc, curr) => acc + Math.round(curr.value),
    0
  )

  return (
    <div>
      <Heading>{title}</Heading>
      <LineChart width={1500} height={500} data={steps}>
        <Line type="monotone" dataKey="preCorona" stroke="#9BF19B" />
        <Line type="monotone" dataKey="postCorona" stroke="#0B500B" />
        <CartesianGrid stroke="#ccc" />
        <XAxis dataKey="key" tickFormatter={formatKey} />
        <YAxis />
        <Tooltip
          labelFormatter={formatKey}
          formatter={(val) => Math.round(val)}
        />
        <Legend />
      </LineChart>
      <span>
        Antal steg innan: {preNumSteps}, efter: {postNumSteps}
      </span>
    </div>
  )
}

export default StepsChart
