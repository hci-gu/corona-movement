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
    const match = data.find((o) => o.key === i)
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
    const days = get(weekdayState).value

    const datePeriod = get(datePeriodState).value
    const [start, current, now] = get(datesSelector)

    const cmpDate =
      datePeriod === 'same-period-1-year'
        ? moment(now).subtract(1, 'year').format('YYYY-MM-DD')
        : current

    return [
      filterDataIntoBuckets(
        steps,
        ({ date }) => date >= start && date < cmpDate,
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
    const from = get(fetchDateForPeriod)

    return [
      from,
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

export const datePeriodOptions = [
  { value: '3-months-back', label: 'Jämför med 3 månader tillbaka' },
  { value: 'same-period-1-year', label: 'Jämför med samma period förra året' },
  { value: 'all-historic-data', label: 'Jämför med all historisk data' },
]

export const datePeriodState = atom({
  key: 'datePeriodState',
  default: datePeriodOptions[0],
})

export const fetchDateForPeriod = selector({
  key: 'fetchDates',
  get: ({ get }) => {
    const option = get(datePeriodState)

    switch (option.value) {
      case '3-months-back':
        return moment(startDate).subtract(3, 'months').format('YYYY-MM-DD')
      case 'same-period-1-year':
        return moment(startDate).subtract(1, 'years').format('YYYY-MM-DD')
      case 'all-historic-data':
        return moment('2018-01-01').format('YYYY-MM-DD')
      default:
        return []
    }
  },
})

export const weekdayOptons = [
  {
    value: [0, 1, 2, 3, 4, 5, 6],
    label: 'Alla dagar',
  },
  {
    value: [1, 2, 3, 4, 5],
    label: 'Veckodagar',
  },
  {
    value: [0, 6],
    label: 'Helger',
  },
]

export const weekdayState = atom({
  key: 'weekdayState',
  default: weekdayOptons[1],
})
