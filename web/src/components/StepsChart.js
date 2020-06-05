import React from 'react'
import { useRecoilValue } from 'recoil'
import styled from 'styled-components'
import moment from 'moment'
import {
  ResponsiveContainer,
  LineChart,
  Line,
  Legend,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
} from 'recharts'

import { stepsChartSelector } from '../state'

const Container = styled.div`
  height: 500px;
  padding-bottom: 100px;
`

const formatKey = (value) =>
  moment().startOf('day').add(value, 'hours').format('HH:mm')

const StepsChart = () => {
  const [preCoronaSteps, postCoronaSteps] = useRecoilValue(stepsChartSelector)

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
    <Container>
      <ResponsiveContainer>
        <LineChart data={steps}>
          <Line
            type="monotone"
            dataKey="preCorona"
            stroke="#9BF19B"
            animationDuration={50}
          />
          <Line
            type="monotone"
            dataKey="postCorona"
            stroke="#0B500B"
            animationDuration={50}
          />
          <CartesianGrid stroke="#ccc" />
          <XAxis dataKey="key" tickFormatter={formatKey} />
          <YAxis animationDuration={50} ticks={[0, 500, 1000, 1500, 2000]} />
          <Tooltip
            labelFormatter={formatKey}
            formatter={(val) => Math.round(val)}
          />
          <Legend />
        </LineChart>
      </ResponsiveContainer>
      <span>
        Antal steg innan: {preNumSteps}, efter: {postNumSteps}
      </span>
    </Container>
  )
}

export default StepsChart
