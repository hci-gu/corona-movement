import { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import axios from 'axios'
import moment from 'moment'

export const useSteps = (from, to, weekDays) => {
  const [steps, setSteps] = useState({ result: [] })
  const { userId } = useParams()
  useEffect(() => {
    const getSteps = async () => {
      const response = await axios.get(
        `${process.env.REACT_APP_API}/${userId}/weeks?from=${from}&to=${to}&weekDays=${weekDays}`
      )
      setSteps(response.data)
    }
    getSteps()
  }, [from])
  return steps.result
}

export const useAllSteps = (from, to) => {
  const [steps, setSteps] = useState({ result: [] })
  const { userId } = useParams()
  useEffect(() => {
    const getSteps = async () => {
      const response = await axios.get(
        `${process.env.REACT_APP_API}/${userId}/hours?from=${from}&to=${to}`
      )
      const data = response.data
      const steps = data.result.map(({ key, value }) => ({
        date: moment(`${key}:00`).format('YYYY-MM-DD'),
        hours: (new Date(`${key}:00`)).getHours(),
        weekday: (new Date(`${key}:00`)).getDay(),
        value
      }))
      setSteps({ result: steps })
    }
    getSteps()
  }, [])
  return steps.result
}
