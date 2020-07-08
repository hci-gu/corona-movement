const chai = require('chai')
const testHelper = require('./integration/testHelper')

process.env.DB_NAME = 'coronamovement-test'
process.env.CONNECT_TO = 'mongodb://username:password@localhost:27017'

global.expect = chai.expect

before(() => testHelper.init())
