express = require 'express'

class Node
  openTag: "<"
  openClosingTag: "</"
  closeTag: ">"
  closeEmptyTag: "/>"
  constructor: (type, attributes) ->
    @type = type
    @attributes = {}
    @children = []
    @attr name, value for name, value of attributes if attributes
  attr: (name, value) ->
    @attributes[name] = value
    return @
  addChild: (node) ->
    @children.push node
    return @
  to_s: ->
    tag = [@type]
    tag.push "#{key}='#{value}'" for key, value of @attributes

    if @children.length > 0
      children = (child.to_s() for child in @children)
      return [@openTag, tag.join(" "), @closeTag, children.join(""), @openClosingTag, @type, @closeTag].join("")
    else
      return [@openTag, tag.join(" "), @closeEmptyTag].join("")


class ContentNode extends Node
  content: (value) ->
    @content = value
    return @
  prepend: (value) ->
    @content = [value, @content].join("")
    return @
  append: (value) ->
    @content = [@content, value].join("")
    return @
  addChild: (node) ->
  to_s: ->
    tag = [@type]
    tag.push "#{key}='#{value}'" for key, value of @attributes
    return [@openTag, tag.join(" "), @closeTag, @content, @openClosingTag, @type, @closeTag].join("")


class SVG
  constructor: (options) ->
    @options = options

    @size = (@options.dotSize+@options.radius) * 2

    @svgElement = new Node('svg', {
      xmlns: "http://www.w3.org/2000/svg"
      version: 1.1
      width: [@size, "px"].join("")
      height: [@size, "px"].join("")
    })

  generateCircleDot: (i) ->
    xPos  = (@options.radius * (1 + Math.cos(2 * Math.PI * i / @options.dots - Math.PI / 2)) + @options.dotSize)
    xPos  = Math.round(xPos * 100) / 100
    yPos  = (@options.radius * (1 + Math.sin(2 * Math.PI * i / @options.dots - Math.PI / 2)) + @options.dotSize)
    yPos  = Math.round(yPos * 100) / 100
    delay = Math.round(@options.duration*i*100/@options.dots)/100
    n = new Node("circle", {
        r: @options.dotSize
        cx: xPos
        cy: yPos
      })
    if delay and @options.type == 'fade'
      n.attr("style", "-webkit-animation-delay:#{delay}s;animation-delay:#{delay}s")
    return n

  render: ->

  getSVG: ->
    return [
      "<?xml version='1.0' standalone='no'?>"
      "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>"
      @svgElement.to_s()
    ].join("")


class Fade extends SVG
  render: ->
    color = if @options.color then "fill:##{@options.color};" else ""
    @svgElement.addChild(
      new ContentNode("style")
        .content("@keyframes fade{0%{opacity:#{@options.maxOpacity}}to{opacity:#{@options.minOpacity}}}@-webkit-keyframes fade{0%{opacity:#{@options.maxOpacity}}to{opacity:#{@options.minOpacity}}}")
        .append("circle{#{color}opacity:#{@options.minOpacity};animation:fade #{@options.duration}s infinite;-webkit-animation:fade #{@options.duration}s infinite;}")
    )
    group = new Node("g")
    @svgElement.addChild(group)
    group.addChild(@generateCircleDot(i)) for i in [0...@options.dots]
    return @getSVG()


class Rotate extends SVG
  render: ->
    style = new ContentNode("style")
        .content("@keyframes rotate{0%{transform:rotate(0deg)}to{transform:rotate(360deg)}}@-webkit-keyframes rotate{0%{-webkit-transform:rotate(0deg)}to{-webkit-transform:rotate(360deg);}}")
        .append("g{animation:rotate #{@options.duration}s infinite linear;-webkit-animation:rotate #{@options.duration}s infinite linear;transform-origin:#{@size/2}px #{@size/2}px;-webkit-transform-origin:#{@size/2}px #{@size/2}px;}")
    style.append("circle{fill:##{@options.color};}") if @options.color
    @svgElement.addChild(style)
    group = new Node("g")
    @svgElement.addChild(group)
    group.addChild(@generateCircleDot(i)) for i in [0...@options.dots]
    return @getSVG()

################################################################################

app = express()
app.configure ->
  app.set 'title', 'SVG Spin Generator'
  return

app.get '/', (req, res) ->
  res.sendfile(__dirname + '/static/home.html')

app.get '/:type/:color?/:dots?/:dotSize?/:radius?/:duration?/:minOpacity?/:maxOpacity?', (req, res) ->

  options =
    type: req.params.type or 'fade'
    color: req.params.color or null
    dots: parseInt(req.params.dots or 12, 10)
    dotSize: parseFloat(req.params.dotSize or 2)
    radius: parseFloat(req.params.radius or 10)
    duration: parseFloat(req.params.duration or 1.2)
    minOpacity: parseFloat(req.params.minOpacity or 0.3)
    maxOpacity: parseFloat(req.params.maxOpacity or 1)

  res.set {
    'Content-Type': 'image/svg+xml'
    #expires, last mod and other cache awesomeness
  }

  if options.type == 'fade'
    res.send new Fade(options).render()
  else if options.type == 'rotate'
    res.send new Rotate(options).render()
  else
    res.set({'Content-Type': 'text/plain'}).status(404).send('Error 404')
  return

port = process.env.PORT or 3000
app.listen port, ->
  console.log "Server started on port " + port
