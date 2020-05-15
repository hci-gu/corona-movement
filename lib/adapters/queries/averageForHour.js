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
          avg: {
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
        {
          match_all: {},
        },
        {
          match_all: {},
        },
        {
          range: {
            duration: {
              gte: 0,
              lt: 3600 * 1000,
            },
          },
        },
        dayFilter,
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
