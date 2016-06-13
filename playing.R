library("RNeo4j")
library("igraph")
library("xts")


graph = startGraph("http://localhost:7474/db/data", username = "neo4j", password="password")

query = "match (f)-[l:LOGIN]->(t) return f.name AS from ,t.name AS to, l.time AS time, l.result AS result;"

g <- graph.data.frame(cypher(graph, query))


prettify <- function(g) {
#Aestethics
  E(g)[E(g)$result != c("fail")]$color <- "yellow"
  E(g)[E(g)$result == c("fail")]$color <- "red"
  E(g)$arrow.size <- 0.5
  V(g)$label.color <- "black"
  g
}

#just looking at failures...
failquery = "match (f)-[l:LOGIN { result: 'fail' }]->(t) return f.name AS from ,t.name AS to, l.time AS time, l.result AS result;"
failgraph <- graph.data.frame(cypher(graph, failquery))

#lets inspect more of the connections from webserver
logindata <- cypher(graph, "match (f) -[n]-> (t) where f.name = 'webserver.dmz.grifsec.com' return n.time, n.user;" )
#convert to posix dates
logindata$n.time <- as.POSIXct(as.integer(logindata$n.time), origin="1970-01-01")
#as xts
#data <- as.xts(logindata$n.time)

# bind 1, for each row
logincounts <- as.data.frame(cbind(logindata$n.time, c(1)))
colnames(logincounts) <- c("time","count")
logincounts$time <- as.integer(logincounts$time)
#summarize
logincounts <- aggregate(logincounts$count, by=list(logincounts$time), FUN=sum)
#and to ts
logincounts <- as.ts(logincounts)


