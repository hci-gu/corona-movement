module.exports = ({ from, to }) => ({
  aggs: {
    '2': {
      date_histogram: {
        field: 'date_from',
        calendar_interval: '1w',
        time_zone: 'Europe/Stockholm',
      },
      aggs: {
        '1': {
          sum: {
            field: 'value',
          },
        },
        '3': {
          serial_diff: {
            buckets_path: '3-metric',
          },
        },
        '3-metric': {
          sum: {
            field: 'value',
          },
        },
      },
    },
  },
  size: 0,
  stored_fields: ['*'],
  script_fields: {},
  docvalue_fields: [
    {
      field: 'date_from',
      format: 'date_time',
    },
    {
      field: 'date_to',
      format: 'date_time',
    },
  ],
  _source: {
    excludes: [],
  },
  query: {
    bool: {
      must: [],
      filter: [
        {
          range: {
            date_from: {
              gte: from,
              lte: to,
              format: 'strict_date_optional_time',
            },
          },
        },
      ],
      should: [],
      must_not: [],
    },
  },
})
