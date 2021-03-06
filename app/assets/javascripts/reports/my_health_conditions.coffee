@healthConditionsReady = () ->
  # Creating network
  myNetwork = Network()

  d3.json "my_health_conditions_data.json", (json) ->
    myNetwork("#health-conditions", json)
  myNetwork.toggleLayout("force")

Network = () ->
  width = 800
  height = 800
  # allData will store the unfiltered data
  allData = []
  curLinksData = []
  curNodesData = []
  linkedByIndex = {}
  # these will hold the svg groups for
  # accessing the nodes and links display
  nodesG = null
  linksG = null
  # these will point to the circles and lines
  # of the nodes and links
  node = null
  link = null
  # variables to refect the current settings
  # of the visualization
  layout = "force"
  # our force directed layout
  force = d3.layout.force()
  # color function used to color nodes
  nodeColors = d3.scale.category20()
  network = (selection, data) ->
    # main implementation
    # format our data
    allData = setupData(data)

    # create our svg and groups
    vis = d3.select(selection).append("svg")
      .attr("width", "800px")
      .attr("height", "800px")
      .attr("viewBox", "0 0 800 800")
      .attr("preserveAspectRatio", "xMidYMid")
    linksG = vis.append("g").attr("id", "links")
    nodesG = vis.append("g").attr("id", "nodes")

    aspect = 1
    chart = $("#health-conditions svg")
    $(window).on 'resize', ->
      targetWidth = Math.min(chart.parent().parent().width(), $(window).width())
      chart.attr 'width', targetWidth
      chart.attr 'height', targetWidth / aspect
      return

    # setup the size of the force environment
    force.size([width, height])

    setLayout("force")

    # perform rendering and start force layout
    update()

  # private function, called everytime a parameter changes and the network needs to be reset
  update = () ->
    # filter data for current settings
    curNodesData = allData.nodes
    curLinksData = allData.links
    # Reset nodes in force layout, then update to enter/exit for nodes
    force.nodes(curNodesData)
    updateNodes()
    # Show links in force layout, then update to enter/exit for links
    force.links(curLinksData)
    updateLinks()
    # Start
    force.start()

  # public function
  network.toggleLayout = (newLayout) ->
    update()
    force.on("tick", forceTick)
      .charge(-1500)
      .linkDistance(300)

  setupData = (data) ->
    # initialize circle radius scale
    countExtent = d3.extent(data.nodes, (d) -> d.frequency)
    circleRadius = d3.scale.sqrt().range([10, 50]).domain(countExtent)

    # Initialize x/y coordinate and radius of each node
    data.nodes.forEach (n) ->
      n.x = randomnumber=Math.floor(Math.random()*width)
      n.y = randomnumber=Math.floor(Math.random()*height)
      n.radius = circleRadius(n.frequency)
    # IDs -> node objects
    nodesMap = mapNodes(data.nodes)
    # Switch links to point to node objects instead of id's, and sort links
    data.links.forEach (l) ->
      l.source = nodesMap.get(l.source)
      l.target = nodesMap.get(l.target)
      linkedByIndex["#{l.source.id},#{l.target.id}"] = 1
    return data

  # Helper function to map node id's to node objects.
  # Returns d3.map of ids -> nodes
  mapNodes = (nodes) ->
    nodesMap = d3.map()
    nodes.forEach (n) ->
      nodesMap.set(n.id, n)
    nodesMap

  updateNodes = () ->
    node = nodesG.selectAll("circle.node")
      .data(curNodesData, (d) -> d.id)
    node.enter().append("circle")
      .attr("class", "none")
      .attr("id", (d) -> d.id)
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
      .attr("r", (d) -> d.radius)
      .style("fill", (d) -> nodeColors(d.artist))
      .style("stroke", (d) -> strokeFor(d))
      .style("stroke-width", 1.0)
    node.on("mouseover", showDetails)
      .on("mouseout", hideDetails)
    node.on("click", showInfo)
    node.exit().remove()

  updateLinks = () ->
    link = linksG.selectAll("line.link")
      .data(curLinksData, (d) -> "#{d.source.id}_#{d.target.id}")
    link.enter().append("line")
      .attr("class", "link")
      .attr("stroke", "#ddd")
      .attr("stroke-opacity", 0.8)
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)
    link.exit().remove()


  # switches force to new layout parameters
  setLayout = (newLayout) ->
    layout = newLayout
    if layout == "force"
      force.on("tick", forceTick)
        .charge(-1500)
        .linkDistance(300)
    else if layout == "radial"
      force.on("tick", radialTick)
        .charge(charge)

  forceTick = (e) ->
    node
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
    link
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)
  # Helper function that returns stroke color for
  # particular node.
  strokeFor = (d) ->
    d3.rgb(nodeColors(d.artist)).darker().toString()


  return network

showInfo = (d, i) ->
  content = "<h2>" + d.name + "</h2>"
  content += "<p class='lead'> Experienced by <span class='f500'>" + Number((d.frequency).toFixed(2)) + "%</span> of the MyApnea community."
  $("#health-conditions-info").html(content)

showDetails = (d,i) ->
  $("#tooltip").removeClass "hidden"
  $("#tooltip").html(d.name)
  if d.x > 400
    $("#tooltip").css("left", d.x + 30 + d.frequency/2)
  else
    $("#tooltip").css("left", d.x - 30 - d.frequency/2)
  if d.y > 400
    $("#tooltip").css("top", d.y + 30 + d.frequency/2)
  else
    $("#tooltip").css("top", d.y - 30 - d.frequency/2)


hideDetails = (d,i) ->
  $("#tooltip").addClass "hidden"
