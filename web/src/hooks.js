import { useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { useRecoilState } from 'recoil'
import { stepsState } from './state'
import axios from 'axios'
import moment from 'moment'

export const useSteps = (from, to) => {
  const [steps, setSteps] = useRecoilState(stepsState)
  const { userId } = useParams()
  useEffect(() => {
    const getSteps = async () => {
      const response = await axios.get(
        `${process.env.REACT_APP_API}/${userId}/hours?from=${from}&to=${to}`
      )
      const data = response.data
      const steps = data.result.map(({ key, value }) => ({
        date: moment(`${key}:00`).format('YYYY-MM-DD'),
        hours: new Date(`${key}:00`).getHours(),
        weekday: new Date(`${key}:00`).getDay(),
        value,
      }))
      setSteps(steps)
    }
    getSteps()
  }, [])
  return steps
}
