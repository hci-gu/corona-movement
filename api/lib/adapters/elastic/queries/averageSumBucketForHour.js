module.exports = ({ from, to, dayFilter }) => ({
  aggs: {
    '2': {
      histogram: {
        field: 'time',
        interval: 60,
        min_doc_count: 0,
      },
      aggs: {
        '1': {
          avg_bucket: {
            buckets_path: '1-bucket>1-metric',
          },
        },
        '3': {
          avg: {
            field: 'value',
          },
        },
        '1-bucket': {
          date_histogram: {
            field: 'date',
            calendar_interval: '1d',
            time_zone: 'Europe/Stockholm',
            min_doc_count: 1,
          },
          aggs: {
            '1-metric': {
              sum: {
                field: 'value',
              },
            },
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
      field: 'date',
      format: 'date_time',
    },
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
        dayFilter,
        {
          match_phrase: {
            id,
          },
        },
        {
          range: {
            duration: {
              gte: 0,
              lt: 3600 * 1000,
            },
          },
        },
        {
          range: {
            date: {
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
