import { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import axios from 'axios'

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
