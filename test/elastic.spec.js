const elastic = require(`${process.cwd()}/lib/adapters/elastic`)
const moment = require('moment')

describe('#elastic', () => {
  let testData
  beforeEach(() => {
    testData = [
      {
        value: 2,
        unit: 'COUNT',
        date_from: 1586242456029,
        date_to: 1586242458588,
        data_type: 'STEPS',
        platform_type: 'PlatformType.IOS',
      },
      {
        value: 19,
        unit: 'COUNT',
        date_from: 1586249009211,
        date_to: 1586249249655,
        data_type: 'STEPS',
        platform_type: 'PlatformType.IOS',
      },
      {
        value: 14,
        unit: 'COUNT',
        date_from: 1586249909597,
        date_to: 1586249914713,
        data_type: 'STEPS',
        platform_type: 'PlatformType.IOS',
      },
      {
        value: 15,
        unit: 'COUNT',
        date_from: 1586254107113,
        date_to: 1586254117342,
        data_type: 'STEPS',
        platform_type: 'PlatformType.IOS',
      },
      {
        value: 29,
        unit: 'COUNT',
        date_from: 1586258636734,
        date_to: 1586258713482,
        data_type: 'STEPS',
        platform_type: 'PlatformType.IOS',
      },
      {
        value: 17,
        unit: 'COUNT',
        date_from: 1586259780641,
        date_to: 1586259783200,
        data_type: 'STEPS',
        platform_type: 'PlatformType.IOS',
      },
    ]
  })

  describe('#transformHealthData', () => {
    it('correctly rounds and parses time', () => {
      const time = moment('2020-01-01T13:50')
      expect(
        moment(
          elastic.transformHealthData({
            value: 2,
            unit: 'COUNT',
            date_from: time.unix() * 1000,
            date_to: time.add(10, 'minutes').unix() * 1000,
            data_type: 'STEPS',
            platform_type: 'PlatformType.IOS',
          }).date
        ).format()
      ).to.eql(moment('2020-01-01T13:55').format())
    })

    it('rounds time to nearest 15min', () => {
      const parsed = testData
        .map(elastic.transformHealthData)
        .map((d) => d.time)
      expect(parsed).to.eql([540, 645, 660, 735, 810, 825])
    })
  })
})
