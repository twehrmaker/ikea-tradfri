Coap = require('node-coap-client').CoapClient
{ URL } = require 'url'

Property = require './Property'
Device   = require './Device'
Group    = require './Group'

DEVICE = '15001'
GROUP  = '15004'

class CoAP extends Property

  constructor: (@hub, securityId) ->
    super()
    Coap.setSecurityParams @hub,
      psk:
        Client_identity: securityId
    @url = new URL "coaps://#{@hub}:5684"

  @property 'deviceURL',
    get: ->
      url = new URL @url.href
      url.pathname = DEVICE
      url

  @property 'groupURL',
    get: ->
      url = new URL @url.href
      url.pathname = GROUP
      url

  GET: (url) ->          # Returns a promise
    Coap.request url, 'get',
      keepAlive: false
      confirmable: false
      observe: false
    .then (result) ->
      JSON.parse result.payload.toString()

  reset: ->
    Coap.reset @hub

  devices: ->
    @GET @deviceURL

  device: (id) ->
    url = @deviceURL
    url.pathname += '/' + id
    @GET url
    .then (raw) =>
      new Device raw

  groups: ->
    @GET @groupURL

  group: (id) ->
    url = @groupURL
    url.pathname += '/' + id
    @GET url
    .then (raw) =>
      new Group raw, @

module.exports = CoAP
