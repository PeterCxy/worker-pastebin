import config from '../config.json'
import AWS from 'aws-sdk'
import _ from './prelude'

loadAWSConfig = ->
  AWS.config.update config.aws

getS3 = ->
  new AWS.S3
    endpoint: new AWS.Endpoint config.s3.endpoint

uploadFile = (params) ->
  params['Bucket'] = config.s3.bucket
  getS3 _
    .putObject params
    .promise _

listFiles = (path) ->
  (await getS3 _
    .listObjects
      Bucket: config.s3.bucket
      Prefix: path
    .promise _)
    .Contents

export { loadAWSConfig, uploadFile, listFiles }