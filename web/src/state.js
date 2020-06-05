import { atom, selector, selectorFamily } from 'recoil'
import moment from 'moment'

export const startDate = '2020-04-01'
export const fetchFrom = () =>
  moment(startDate).subtract(3, 'months').format('YYYY-MM-DD')

const group = (array, keyFn) => {
  const obj = array.reduce((obj, x) => {
    const key = keyFn(x)
    if (!obj[key]) {
      obj[key] = []
    }
    obj[key].push(x)
    return obj
  }, {})
  return Object.keys(obj).map((key) => ({
    key: key,
    values: obj[key],
  }))
}

const putDataInBuckets = (data) =>
  Array.from({ length: 24 }).map((_, i) => {
    const match = data.find((o) => o.key == i)
    if (match) {
      return match
    }
    return {
      key: i,
      value: 0,
    }
  })

const filterDataIntoBuckets = (data, filter, days) =>
  putDataInBuckets(
    group(data.filter(filter), ({ hours }) => hours).map(({ key, values }) => ({
      key,
      value:
        values
          .filter(({ weekday }) => days.includes(weekday))
          .reduce((sum, x) => sum + x.value, 0) /
        Math.max(
          [...new Set(values.filter(({ weekday }) => days.includes(weekday)))]
            .length,
          1
        ),
    }))
  )

export const stepsState = atom({
  key: 'stepsState',
  default: [],
})

export const stepsChartSelector = selector({
  key: 'stepsChart',
  get: ({ get }) => {
    const steps = get(stepsState)
    const days = [1, 2, 3, 4, 5]
    const [start, current] = get(datesSelector)

    return [
      filterDataIntoBuckets(
        steps,
        ({ date }) => date >= start && date < current,
        days
      ),
      filterDataIntoBuckets(steps, ({ date }) => date >= current, days),
    ]
  },
})

export const maxStepsSelector = selector({
  key: 'maxSteps',
  get: ({ get }) => {
    const steps = get(stepsState)

    return Math.max.apply(
      null,
      steps.map((d) => (d.value ? d.value : 0))
    )
  },
})

export const dayBreakdownSelector = selector({
  key: 'dayBreakdown',
  get: ({ get }) => {
    const steps = get(stepsState)

    return steps.reduce((dates, curr) => {
      if (dates[curr.date]) {
        dates[curr.date][curr.hours] = { ...curr, index: 1 }
      } else {
        dates[curr.date] = Array.from({ length: 24 }).map((_, i) => ({
          index: 1,
          hours: i,
          value: 0,
          date: curr.date,
          weekday: curr.weekday,
        }))
      }
      return dates
    }, {})
  },
})

export const dayTotalSelector = selector({
  key: 'dayTotal',
  get: ({ get }) => {
    const days = get(dayBreakdownSelector)

    return Object.keys(days).map((key) => {
      return {
        date: key,
        value: days[key].reduce((sum, day) => sum + day.value, 0),
      }
    })
  },
})

export const sliderState = atom({
  key: 'sliderState',
  default: 0,
})

export const datesSelector = selector({
  key: 'dates',
  get: ({ get }) => {
    const days = get(sliderState)

    return [
      fetchFrom(),
      moment(startDate).add(days, 'days').format('YYYY-MM-DD'),
      moment().format('YYYY-MM-DD'),
    ]
  },
})

export const isCurrentDateAtom = selectorFamily({
  key: 'current-date',
  get: (date) => ({ get }) => {
    const [_, currentDate] = get(datesSelector)
    return currentDate === date
  },
})
