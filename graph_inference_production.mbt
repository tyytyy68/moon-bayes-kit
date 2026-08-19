///|
/// Graph and probabilistic dependency utilities for structured models.
pub struct GraphEdge {
  from : Int
  to : Int
  weight : Double
  label : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn GraphEdge::new(from : Int, to : Int, weight : Double) -> GraphEdge {
  { from, to, weight, label: "" }
}

///|
pub struct WeightedGraph {
  nodes : Int
  directed : Bool
  edges : Array[GraphEdge]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn WeightedGraph::new(nodes : Int, directed : Bool) -> WeightedGraph {
  if nodes < 0 {
    abort("WeightedGraph: nodes must be non-negative")
  }
  { nodes, directed, edges: [] }
}

///|
pub fn WeightedGraph::add_edge(
  self : WeightedGraph,
  edge : GraphEdge,
) -> WeightedGraph {
  if edge.from < 0 ||
    edge.from >= self.nodes ||
    edge.to < 0 ||
    edge.to >= self.nodes {
    abort("WeightedGraph: edge endpoint out of range")
  }
  let edges = self.edges.copy()
  edges.push(edge)
  if !self.directed && edge.from != edge.to {
    edges.push({
      from: edge.to,
      to: edge.from,
      weight: edge.weight,
      label: edge.label,
    })
  }
  { ..self, edges, }
}

///|
pub fn WeightedGraph::neighbors(
  self : WeightedGraph,
  node : Int,
) -> Array[(Int, Double)] {
  if node < 0 || node >= self.nodes {
    abort("WeightedGraph: node out of range")
  }
  let result : Array[(Int, Double)] = []
  for edge in self.edges.iter() {
    if edge.from == node {
      result.push((edge.to, edge.weight))
    }
  }
  result
}

///|
pub fn WeightedGraph::degree(self : WeightedGraph, node : Int) -> Int {
  self.neighbors(node).length()
}

///|
pub fn WeightedGraph::edge_count(self : WeightedGraph) -> Int {
  self.edges.length()
}

///|
pub fn WeightedGraph::has_edge(
  self : WeightedGraph,
  from : Int,
  to : Int,
) -> Bool {
  self.edges.any(fn(edge) { edge.from == from && edge.to == to })
}

///|
pub fn WeightedGraph::total_weight(self : WeightedGraph) -> Double {
  self.edges.fold(init=0.0, (total, edge) => total + edge.weight)
}

///|
pub fn WeightedGraph::adjacency_matrix(
  self : WeightedGraph,
) -> Array[Array[Double]] {
  let matrix : Array[Array[Double]] = []
  for _ in 0..<self.nodes {
    let row : Array[Double] = []
    for _ in 0..<self.nodes {
      row.push(0.0)
    }
    matrix.push(row)
  }
  for edge in self.edges.iter() {
    matrix[edge.from][edge.to] = matrix[edge.from][edge.to] + edge.weight
  }
  matrix
}

///|
pub fn WeightedGraph::incoming(
  self : WeightedGraph,
  node : Int,
) -> Array[(Int, Double)] {
  let result : Array[(Int, Double)] = []
  for edge in self.edges.iter() {
    if edge.to == node {
      result.push((edge.from, edge.weight))
    }
  }
  result
}

///|
pub fn WeightedGraph::outgoing_weight(
  self : WeightedGraph,
  node : Int,
) -> Double {
  self.neighbors(node).fold(init=0.0, (total, item) => total + item.1)
}

///|
pub fn graph_bfs(graph : WeightedGraph, start : Int) -> Array[Int] {
  let visited : Array[Bool] = []
  for _ in 0..<graph.nodes {
    visited.push(false)
  }
  let queue : Array[Int] = [start]
  visited[start] = true
  let result : Array[Int] = []
  let mut cursor = 0
  while cursor < queue.length() {
    let node = queue[cursor]
    cursor = cursor + 1
    result.push(node)
    for item in graph.neighbors(node) {
      if !visited[item.0] {
        visited[item.0] = true
        queue.push(item.0)
      }
    }
  }
  result
}

///|
pub fn graph_dfs(graph : WeightedGraph, start : Int) -> Array[Int] {
  let visited : Array[Bool] = []
  for _ in 0..<graph.nodes {
    visited.push(false)
  }
  let stack : Array[Int] = [start]
  let result : Array[Int] = []
  while stack.length() > 0 {
    let node = stack[stack.length() - 1]
    let _ = stack.pop()
    if !visited[node] {
      visited[node] = true
      result.push(node)
      for item in graph.neighbors(node) {
        if !visited[item.0] {
          stack.push(item.0)
        }
      }
    }
  }
  result
}

///|
pub struct ShortestPath {
  distance : Double
  nodes : Array[Int]
  reachable : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn dijkstra(
  graph : WeightedGraph,
  start : Int,
  target : Int,
) -> ShortestPath {
  if start < 0 || target < 0 || start >= graph.nodes || target >= graph.nodes {
    abort("dijkstra: node out of range")
  }
  let distances : Array[Double] = []
  for _ in 0..<graph.nodes {
    distances.push(1.0 / 0.0)
  }
  let previous : Array[Int] = []
  let used : Array[Bool] = []
  for _ in 0..<graph.nodes {
    previous.push(-1)
    used.push(false)
  }
  distances[start] = 0.0
  for _ in 0..<graph.nodes {
    let mut candidate = -1
    for index in 0..<graph.nodes {
      if !used[index] &&
        (candidate < 0 || distances[index] < distances[candidate]) {
        candidate = index
      }
    }
    if candidate < 0 || distances[candidate] == 1.0 / 0.0 {
      break
    }
    used[candidate] = true
    for item in graph.neighbors(candidate) {
      let next = distances[candidate] + item.1
      if next < distances[item.0] {
        distances[item.0] = next
        previous[item.0] = candidate
      }
    }
  }
  if previous[target] < 0 && start != target {
    return { distance: distances[target], nodes: [], reachable: false }
  }
  let path : Array[Int] = []
  let mut cursor = target
  while cursor >= 0 {
    path.push(cursor)
    if cursor == start {
      break
    }
    cursor = previous[cursor]
  }
  for left in 0..<path.length() {
    for right in (left + 1)..<path.length() {
      if right > left && path[right] > -1 {
        let temp = path[left]
        path[left] = path[right]
        path[right] = temp
      }
    }
  }
  { distance: distances[target], nodes: path, reachable: true }
}

///|
pub fn pagerank(
  graph : WeightedGraph,
  damping : Double,
  iterations : Int,
) -> Array[Double] {
  if damping < 0.0 || damping > 1.0 || iterations < 0 {
    abort("pagerank: invalid inputs")
  }
  if graph.nodes == 0 {
    return []
  }
  let rank : Array[Double] = []
  for _ in 0..<graph.nodes {
    rank.push(1.0 / graph.nodes.to_double())
  }
  for _ in 0..<iterations {
    let next : Array[Double] = []
    for _ in 0..<graph.nodes {
      next.push((1.0 - damping) / graph.nodes.to_double())
    }
    for edge in graph.edges.iter() {
      let weight = graph.outgoing_weight(edge.from)
      if weight > 0.0 {
        next[edge.to] = next[edge.to] +
          damping * rank[edge.from] * edge.weight / weight
      }
    }
    for index in 0..<graph.nodes {
      rank[index] = next[index]
    }
  }
  rank
}

///|
pub fn graph_clustering_coefficient(
  graph : WeightedGraph,
  node : Int,
) -> Double {
  let neighbors = graph.neighbors(node).map(fn(item) { item.0 })
  if neighbors.length() < 2 {
    return 0.0
  }
  let mut links = 0
  for left in 0..<neighbors.length() {
    for right in (left + 1)..<neighbors.length() {
      if graph.has_edge(neighbors[left], neighbors[right]) {
        links = links + 1
      }
    }
  }
  2.0 *
  links.to_double() /
  (neighbors.length() * (neighbors.length() - 1)).to_double()
}

///|
pub struct MarkovChain {
  states : Int
  transition : Array[Array[Double]]
  initial : Array[Double]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn MarkovChain::new(
  transition : Array[Array[Double]],
  initial : Array[Double],
) -> MarkovChain {
  let states = transition.length()
  if states == 0 || initial.length() != states {
    abort("MarkovChain: dimension mismatch")
  }
  for row in transition.iter() {
    if row.length() != states {
      abort("MarkovChain: transition must be square")
    }
  }
  { states, transition, initial }
}

///|
pub fn MarkovChain::step(
  self : MarkovChain,
  distribution : Array[Double],
) -> Array[Double] {
  if distribution.length() != self.states {
    abort("MarkovChain: distribution dimension mismatch")
  }
  let result : Array[Double] = []
  for target in 0..<self.states {
    let mut value = 0.0
    for source in 0..<self.states {
      value = value + distribution[source] * self.transition[source][target]
    }
    result.push(value)
  }
  result
}

///|
pub fn MarkovChain::distribution(
  self : MarkovChain,
  steps : Int,
) -> Array[Double] {
  if steps < 0 {
    abort("MarkovChain: steps must be non-negative")
  }
  let mut result = self.initial.copy()
  for _ in 0..<steps {
    result = self.step(result)
  }
  result
}

///|
pub fn MarkovChain::stationary(
  self : MarkovChain,
  iterations : Int,
) -> Array[Double] {
  let mut result = self.initial.copy()
  for _ in 0..<iterations {
    result = self.step(result)
  }
  result
}

///|
pub fn MarkovChain::expected_state(
  self : MarkovChain,
  values : Array[Double],
  steps : Int,
) -> Double {
  let distribution = self.distribution(steps)
  if values.length() != self.states {
    abort("MarkovChain: state values dimension mismatch")
  }
  let mut result = 0.0
  for index in 0..<self.states {
    result = result + distribution[index] * values[index]
  }
  result
}

///|
pub struct TransitionEstimate {
  counts : Array[Array[Int]]
  probabilities : Array[Array[Double]]
  smoothing : Double
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn estimate_transitions(
  sequence : Array[Int],
  states : Int,
  smoothing : Double,
) -> TransitionEstimate {
  if sequence.length() < 2 || states <= 0 || smoothing < 0.0 {
    abort("estimate_transitions: invalid inputs")
  }
  let counts : Array[Array[Int]] = []
  for _ in 0..<states {
    let row : Array[Int] = []
    for _ in 0..<states {
      row.push(0)
    }
    counts.push(row)
  }
  for index in 1..<sequence.length() {
    counts[sequence[index - 1]][sequence[index]] = counts[sequence[index - 1]][sequence[index]] +
      1
  }
  let probabilities : Array[Array[Double]] = []
  for source in 0..<states {
    let row : Array[Double] = []
    let total = counts[source]
      .fold(init=0, (sum_value, value) => sum_value + value)
      .to_double() +
      smoothing * states.to_double()
    for target in 0..<states {
      row.push((counts[source][target].to_double() + smoothing) / total)
    }
    probabilities.push(row)
  }
  { counts, probabilities, smoothing }
}

///|
pub fn transition_log_likelihood(
  estimate : TransitionEstimate,
  sequence : Array[Int],
) -> Double {
  if sequence.length() < 2 {
    return 0.0
  }
  let mut result = 0.0
  for index in 1..<sequence.length() {
    let probability = estimate.probabilities[sequence[index - 1]][sequence[index]].max(
      0.000000000001,
    )
    result = result + uncertainty_log(probability)
  }
  result
}
