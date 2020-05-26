import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'
import styled from 'styled-components'
import axios from 'axios'
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
import Slider, { Range } from 'rc-slider'
import 'rc-slider/assets/index.css'

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
const Heading = styled.h2`
  text-align: center;
`

const formatKey = (value) =>
  moment().startOf('day').add(value, 'hours').format('HH:mm')

const useSteps = (from, to, weekDays) => {
  const [steps, setSteps] = useState({ result: [] })
  useEffect(() => {
    const getSteps = async () => {
      const id = window.location.pathname.replace('/', '')
      const response = await axios.get(
        `${process.env.REACT_APP_API}/${id}/weeks?from=${from}&to=${to}&weekDays=${weekDays}`
      )
      console.log(response)
      setSteps(response.data)
    }
    getSteps()
  }, [from])
  return steps.result
}

const StepsChart = ({ title, start, weekDays = true }) => {
  // compare with
  // const preCoronaSteps = useSteps(
  //   moment('2018-01-01').format('YYYY-MM-DDTHH:MM'),
  //   moment(start).format('YYYY-MM-DDTHH:MM'),
  //   weekDays
  // )
  // const postCoronaSteps = useSteps(
  //   moment(start).format('YYYY-MM-DDTHH:MM'),
  //   moment().format('YYYY-MM-DDTHH:MM'),
  //   weekDays
  // )

  // compare with same period 1 year ago
  // const preCoronaSteps = useSteps(
  //   moment(start).subtract(1, 'years').format('YYYY-MM-DDTHH:MM'),
  //   moment().subtract(1, 'years').format('YYYY-MM-DDTHH:MM'),
  //   weekDays
  // )
  // const postCoronaSteps = useSteps(
  //   moment(start).format('YYYY-MM-DDTHH:MM'),
  //   moment().format('YYYY-MM-DDTHH:MM'),
  //   weekDays
  // )

  // compare with 3 months back
  const preCoronaSteps = useSteps(
    moment(start).subtract(3, 'months').format('YYYY-MM-DDTHH:MM'),
    moment(start).format('YYYY-MM-DDTHH:MM'),
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

const App = () => {
  const [days, setDays] = useState(0)
  const fromDate = moment('2020-04-01').add(days, 'days').format('YYYY-MM-DD')

  return (
    <Container>
      <Title>Coronamovement</Title>
      <Title>{fromDate}</Title>
      <Slider min={-100} max={100} value={days} onChange={setDays} />
      <StepsChart title="Veckodagar" start={fromDate} />
      <StepsChart title="Helger" start={fromDate} weekDays={false} />
    </Container>
  )
}

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
)
