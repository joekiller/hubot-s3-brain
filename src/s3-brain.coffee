util  = require 'util'
aws   = require 'aws2js'

module.exports = (robot) ->

  loaded            = false
  key               = process.env.HUBOT_S3_BRAIN_ACCESS_KEY_ID
  secret            = process.env.HUBOT_S3_BRAIN_SECRET_ACCESS_KEY
  bucket            = process.env.HUBOT_S3_BRAIN_BUCKET
  # default to 30 minutes (in seconds)
  save_interval     = process.env.HUBOT_S3_BRAIN_SAVE_INTERVAL || 30 * 60
  brain_dump_path   = "#{bucket}/brain-dump.json"

  if !key && !secret && !bucket
    throw new Error('S3 brain requires HUBOT_S3_BRAIN_ACCESS_KEY_ID, ' +
      'HUBOT_S3_BRAIN_SECRET_ACCESS_KEY and HUBOT_S3_BRAIN_BUCKET configured')

  save_interval = parseInt(save_interval)
  if isNaN(save_interval)
    throw new Error('HUBOT_S3_BRAIN_SAVE_INTERVAL must be an integer')

  s3 = aws.load('s3', key, secret)

  store_brain = (brain_data, callback) ->
    if !loaded
      robot.logger.debug 'Not saving to S3, because not loaded yet'
      return

    buffer = new Buffer(JSON.stringify(brain_data))
    headers =
      'Content-Type': 'application/json'

    s3.putBuffer brain_dump_path, buffer, 'private', headers, (err, response) ->
      if err
        robot.logger.error util.inspect(err)
      else if response
        robot.logger.debug "Saved brain to S3 path #{brain_dump_path}"

      if callback then callback(err, response)

  store_current_brain = () ->
    store_brain robot.brain.data

  s3.get brain_dump_path, 'buffer', (err, response) ->
    # unfortunately S3 gives us a 403 if we have access denied OR
    # the file is simply missing, so no way of knowing if IAM policy is bad
    save_handler = (e, r) ->
      if e then throw new Error("Error contacting S3:\n#{util.inspect(e)}")

    # try to store an empty placeholder to see if IAM settings are valid
    if err then store_brain {}, save_handler

    if response && response.buffer
      robot.brain.mergeData JSON.parse(response.buffer.toString())
    else
      robot.brain.mergeData {}

  robot.brain.on 'loaded', () ->
    loaded = true
    robot.brain.resetSaveInterval(save_interval)
    store_current_brain()

  robot.brain.on 'save', () ->
    store_current_brain()

  robot.brain.on 'close', ->
    store_current_brain()
