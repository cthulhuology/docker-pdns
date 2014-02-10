#!/bin/bash
#
# This script configures an example.com domain demonstrating how to use the API
#


# create the domain entry, so that we can key off this domain for all future calls
curl localhost:5380/create_domain/example.com/master/admin

# create a start of authority for example.com so we can serve as it's root nameserver
curl localhost:5380/create_soa/example.com/ns.example.com.%20admin.example.com.%202013111311%2010800%203600%20604800%203600

# Add an A record for the nameserver itself (loopback for testing)
curl localhost:5380/create_a/example.com/ns1/127.0.0.1

# Add an A record for the websocket server
curl localhost:5380/create_a/example.com/ws/127.0.0.1

# Add the NS record to match the SOA
curl localhost:5380/create_ns/example.com/ns1

# Add a WebSocket server SRV record
curl localhost:5380/create_srv/example.com/ws/_ws._tcp.example.com.%2086400%20IN%20SRV%200%205%208080%20ws.example.com.

# Finaly look at the output of our handiwork!
curl localhost:5380/list_domain/example.com
